*! version 0.1 20240306 - LSMS Team, World Bank - lsms@worldbank.org

cap program drop   ad_pkg_meta
    program define ad_pkg_meta, rclass

qui {

    version 14.1

    syntax ,  [ADFolder(string) pkgfile(string) pkgname(string) newtitle(string) newpkgversion(string) newstataversion(string) newauthor(string) newcontact(string) newurl(string) newdate(string)]

    if missing("`adfolder'`pkgfile'") {
      noi di as error `"{phang}Either {opt:adfolder()} or {opt:pkgfile()} must be used.{p_end}"'
      error 99
      exit
    }

    if !missing("`pkgfile'") {
      assert !missing("`pkgname'")
    }
    else {

      * Test and standardize folder local
      local adfolderstd	= subinstr(`"`adfolder'"',"\","/",.)
      mata : st_numscalar("r(dirExist)", direxists("`adfolderstd'"))
      if `r(dirExist)' == 0  {
        noi di as error `"{phang}The folder used in adfolder(`adfolder') does not exist.{p_end}"'
        error 99
        exit
      }
      * Local to the src/ folder
      local srcfolderstd `"`adfolder'/src/"'

      * List .pkg files in src folder and then make sure there is only one
      local pkgfile : dir `"`srcfolderstd'"' files "*.pkg"	, respectcase
      local count_pkg : list sizeof pkgfile
      if (`count_pkg' != 1) {
        * Erros message for missing pkg file
        if (`count_pkg' == 0) local pkgerr "No"
        * Error message for multiple files
        if (`count_pkg' > 1 ) local pkgerr "Multiple"

        noi di as error `"{phang}`pkgerr' package files on format {res:.pkg} was found in {res:"`srcfolderstd'}. Exactly one is required.{p_end}"'
        error 99
        exit
      }

      * Remove "" that was needed if multiple files found
      local pkgfile `pkgfile'
      local pkgname = subinstr("`pkgfile'",".pkg","",.)
    }

    * Test if file should be updated
    local update ""
    if !missing( "`newtitle'`newpkgversion'`newstataversion'`newauthor'`newcontact'`newurl'" ) {
      local update "update"
    }

    * Tests and handling of new date
    if !missing("`newdate'") & !missing("`newpkgversion'") {
      noi di as error `"{phang}{opt:newdate()} may only be used if {opt:newpkgversion()} is also used.{p_end}"'
      error 99
      exit
    }
    if missing("`newdate'") & !missing("`newpkgversion'") {
      qui adodown formatteddate
      local newdate = `"`r(formatteddate)'"'
    }

    * Add Stata's weird description requirement that when listing multiple emails, @@ must be used.
    if !missing("`newcontact'") {
      local newcontact = subinstr("`newcontact'","@","@@",.)
    }

    * Open template to read from and new tempfile to write to
    tempname fh newpkg_write
    tempfile pkg_out
    file open `fh' using `"`srcfolderstd'`pkgfile'"', read
    file open `newpkg_write' using `pkg_out', write

    * Initiate section local
    local section ""

    local adofiles ""
    local hlpfiles ""
    local ancfiles ""

    * Read first line
    file read `fh' line
    while r(eof)==0 {

      * Trim spaces leading and trailing line
      local line = trim("`line'")

      * Skip empty lines
      if !missing("`line'") {

        * Test if line is beginning of next section
        if (substr("`line'",1,3) == "***") {
          local section = trim(substr("`line'",4,.))
          file write `newpkg_write' "`line'" _n
        }

        * Test if empty line
        else if (trim("`line'") == "d") {
          * Empty lines are ok apart from in these sections.
          if inlist("`section'","version", "title") {
            noi di as error `"{phang}Empty {res:d} line is not allowed in section version or title.{p_end}"'
          }
          file write `newpkg_write' "`line'" _n
        }

        * If neither section head or empty line, process content of section
        else {
          if ("`section'" == "version") {
            verify_package_version, line(`"`line'"') newpkgversion("`newpkgversion'")
            file write `newpkg_write' "`r(newline)'" _n
            local pkg_v `r(pkg_v)'
          }
          else if ("`section'" == "title") {
            verify_title, line(`"`line'"') pkgname(`pkgname') newtitle("`newtitle'")
            file write `newpkg_write' "`r(newline)'" _n
            local pkgname "`pkgname'"
          }
          else if ("`section'" == "description") {
            //do nothing for now
            file write `newpkg_write' "`line'" _n
          }
          else if ("`section'" == "stata") {
            verify_stata_version, line(`"`line'"') newstataversion("`newstataversion'")
            file write `newpkg_write' "`r(newline)'" _n
            local sta_v `r(sta_v)'
          }

          else if ("`section'" == "author") {
            extract_value, line("`line'") line_lead("d Author: ") ///
              format_error("{res:d Author: <name>} where {res:<name>} is any string.") newvalue("`newauthor'")
              file write `newpkg_write' "`r(newline)'" _n
            local author "`r(value)'"
          }

          else if ("`section'" == "contact") {
            extract_value, line("`line'") line_lead("d Contact:") ///
              format_error("{res:d Contact: <contact>} where {res:<contact>} is any string.") emptyok  newvalue("`newcontact'")
              file write `newpkg_write' "`r(newline)'" _n
            local contact =subinstr("`r(value)'","@@","@",.)
          }

          else if ("`section'" == "url") {
            extract_value, line("`line'") line_lead("d URL:") ///
              format_error("{res:d URL: <url>} where {res:<url>} is any string.") emptyok  newvalue("`newurl'")
              file write `newpkg_write' "`r(newline)'" _n
            local url "`r(value)'"
          }

          else if ("`section'" == "date") {
            extract_value, line("`line'") line_lead("d Distribution-Date: ") ///
              format_error("{res:d Distribution-Date: <date>} where {res:<date>} is a date on format {res:YYYYMMDD}.") newvalue("`newdate'")
              file write `newpkg_write' "`r(newline)'" _n
            local date "`r(value)'"
          }

          else if ("`section'" == "adofiles") {
            extract_value, line("`line'") line_lead("f ") ///
              format_error("{res:f ado/<commandname>.ado} where {res:<commandname>} is the name of a command.")
            local adofiles `"`adofiles' "`r(value)'""'
            file write `newpkg_write' "`line'" _n
          }

          else if ("`section'" == "helpfiles") {
            extract_value, line("`line'") line_lead("f ") ///
              format_error("{res:f stlhp/<commandname>.sthlp} where {res:<commandname>} is the name of a command.")
            local hlpfiles `"`hlpfiles' "`r(value)'""'
            file write `newpkg_write' "`line'" _n
          }

          else if ("`section'" == "ancillaryfiles") {
            noi extract_value, line("`line'") line_lead("f ") line_lead2("F ") ///
              format_error("{res:f <path_and_file>} or {res:F <path_and_file>} where {res:<path_and_file>} is the relative path from {res:src/} and the file name of the ancillary files.")
            local ancfiles `"`ancfiles' "`r(value)'""'
            file write `newpkg_write' "`line'" _n
          }

          else {
            //noi di "`section'"
            //noi di "`line'"

            file write `newpkg_write' "`line'" _n
          }
        }
      }
      else {
        file write `newpkg_write' "`line'" _n
      }

      * Read next line
      file read `fh' line
    }

    file close `fh'
    file close `newpkg_write'

    * Return locals
    return local pkgname        "`pkgname'"
    return local stata_version   `sta_v'
    return local package_version `pkg_v'
    return local date            `date'

    return local author          = trim("`author'")
    return local contact         = trim("`contact'")
    return local url             = trim("`url'")
    return local adofiles        = trim(`"`adofiles'"')
    return local hlpfiles        = trim(`"`hlpfiles'"')
    return local ancfiles        = trim(`"`ancfiles'"')

    if ("`update'" != "update") {
      noi di as result "{pstd}Package file {it:`pkgfile'} verified.{p_end}"
    }
    else {

      * Run the new file again in the command to make sure the output is valid
      ad_pkg_meta, pkgfile(`"`pkg_out'"') pkgname("`pkgname'")

      * Output is valid, overwrite file
      copy "`pkg_out'"  `"`srcfolderstd'`pkgfile'"', replace
      noi di as result `"{pstd}Package file {it:`srcfolderstd'`pkgfile'} updated.{p_end}"'
    }

}
end


cap program drop   verify_package_version
    program define verify_package_version, rclass

    syntax, line(string) [newpkgversion(string)]

    if (substr("`line'",1,2) == "v ") {
      // Get current version
      local pkg_v = substr("`line'",3,.)

      //Update to new verison if applicable
      if !missing("`newpkgversion'") local pkg_v "`newpkgversion'"

      //Return values
      return local pkg_v "`pkg_v'"
      local line = ustrtrim(stritrim("v `pkg_v'"))
      return local newline "`line'"
    }
    else {
      noi di as error `"{phang}.pkg file error in line {res:`line'}. Only rows on format {res:v x.y} where {res:x} and {res:y} are integers are allowed.{p_end}"'
      error 99
      exit
    }
end

cap program drop   verify_title
    program define verify_title, rclass

    syntax, line(string) pkgname(string) [newtitle(string)]

    local pkgname_upper = strupper("`pkgname'")

    * Test that line is "d <PKGNAME>".
    * This verifies that the pkg file name matches the title in the file
    local ll_len = strlen("d '`pkgname_upper''")
    if (substr("`line'",1,`ll_len') == "d '`pkgname_upper''") {

      //Update to new verison if applicatble
      if !missing("`newtitle'") {
        local line "d '`pkgname_upper'': `newtitle'"
      }

      //Return values
      local line = ustrtrim(stritrim(`"`line'"'))
      return local newline "`line'"

    }
    else {
      noi di as error `"{phang}.pkg file error in title line {res:`line'}. Only rows on format {res:d '`pkgname_upper'' <title>} are allowed. Package name must be upper case only and {res:<title>} is the together with the package name the title that shows up when using {res:net}/{res:ssc} {res:describe}.{p_end}"'
      error 99
      exit
    }
end


cap program drop   verify_stata_version
    program define verify_stata_version, rclass
    syntax, line(string) [newstataversion(string)]
    if (substr("`line'",1,25) == "d Requires: Stata version") {
      local sta_v = trim(substr("`line'",26,.))

      //Update to new verison if applicatble
      if !missing("`newstataversion'") local sta_v "`newstataversion'"

      //Return values
      return local sta_v "`sta_v'"
      local line = ustrtrim(stritrim("d Requires: Stata version `sta_v'"))
      return local newline "`line'"

    }
    else {
      noi di as error `"{phang}.pkg file error in line {res:`line'}. Only rows on format {res:d Requires: Stata version x.y} where {res:x} and {res:y} are integers are allowed.{p_end}"'
      error 99
      exit
    }
end



* Generic function to get a single line value
cap program drop   extract_value
    program define extract_value, rclass

    syntax, line(string) line_lead(string) [line_lead2(string)] format_error(string) [emptyok newvalue(string)]

    local ll_len = strlen("`line_lead'")
    local ll_len2 = strlen("`line_lead2'")

    if (substr("`line'",1,`ll_len') == "`line_lead'") {
      return local value = trim(substr("`line'",`ll_len'+1,.))
      if !missing("`newvalue'") {
        local line "`line_lead' `newvalue'"
      }
    }
    else if !missing("`line_lead2'") & (substr("`line'",1,`ll_len2') == "`line_lead2'") {
      return local value = trim(substr("`line'",`ll_len2'+1,.))
      if !missing("`newvalue'") {
        local line "`line_lead2' `newvalue'"
      }
    }
    else {
      noi di as error `"{phang}.pkg file error in line {res:`line'}. Valid formats for this row is only `format_error' {p_end}"'
      error 99
      exit
    }
    local line = ustrtrim(stritrim("`line'"))
    return local newline "`line'"
end
