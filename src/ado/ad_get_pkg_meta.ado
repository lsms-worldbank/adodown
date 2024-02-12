*! version 0.1 20230724 LSMS Team, World Bank lsms@worldbank.org

cap program drop   ad_get_pkg_meta
    program define ad_get_pkg_meta, rclass

qui {

    version 14.1

    * Update the syntax. This is only a placeholder to make the command run
    syntax , ADFolder(string)


    * Test and standardize folder local
    local adfolderstd	= subinstr(`"`adfolder'"',"\","/",.)
    mata : st_numscalar("r(dirExist)", direxists("`adfolderstd'"))
    if `r(dirExist)' == 0  {
      noi di as error `"{phang}The folder used in adfolder(`adfolder') does not exist.{p_end}"'
      error 99
      exit
    }
    * Local to the src/ folder
    local srcfolderstd `"`adfolder'/src"'

    * List .pkg files in src folder and then make sure there is only one
    local pkgfile : dir `"`srcfolderstd'"' files "*.pkg"	, respectcase
    local count_pkg : list sizeof pkgfile
    if (`count_pkg' != 1) {
      * Erros message for missing pkg file
      if (`count_pkg' == 0) local pkgerr "No"
      * Error message for multiple files
      if (`count_pkg' > 1 ) local pkgerr "Multiple"

      noi di as error `"{phang}`pkgerr' package files on format {res:.pkg} was found in {res:"`srcfolderstd'/}. Exactly one is required.{p_end}"'
      error 99
      exit
    }

    * Remove "" that was needed if multiple files found
    local pkgfile `pkgfile'

    * Open template to read from and new tempfile to write to
    tempname fh
    file open `fh' using `"`srcfolderstd'/`pkgfile'"', read

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

      * Test if line is beginning of next section
      if (substr("`line'",1,3) == "***") {
        local section = trim(substr("`line'",4,.))
      }

      * If not, process content of section
      else {
        if ("`section'" == "version") {
          verify_package_version, line(`"`line'"')
          local pkg_v `r(pkg_v)'
        }
        else if ("`section'" == "name") {
          local pkgname = subinstr("`pkgfile'",".pkg","",.)
          verify_name, line(`"`line'"') pkgname(`pkgname')
          noi return list
        }
        else if ("`section'" == "description") {
          //do nothing for now
        }
        else if ("`section'" == "stata") {
          verify_stata_version, line(`"`line'"')
          local sta_v `r(sta_v)'
        }

        else if ("`section'" == "author") {
          extract_value, line("`line'") line_lead("d Author: ") ///
            format_error("{res:d Author: <name>} where {res:<name>} is any string.")
          local author "`r(value)'"
        }

        else if ("`section'" == "contact") {
          extract_value, line("`line'") line_lead("d Contact: ") ///
            format_error("{res:d Contact: <contact>} where {res:<contact>} is any string.")
          local contact "`r(value)'"
        }

        else if ("`section'" == "url") {
          extract_value, line("`line'") line_lead("d URL: ") ///
            format_error("{res:d URL: <url>} where {res:<url>} is any string.")
          local url "`r(value)'"
        }

        else if ("`section'" == "date") {
          extract_value, line("`line'") line_lead("d Distribution-Date: ") ///
            format_error("{res:d Distribution-Date: <date>} where {res:<date>} is a date on format {res:YYYYMMDD}.")
          local date "`r(value)'"
        }

        else if ("`section'" == "adofiles") {
          extract_value, line("`line'") line_lead("f ") ///
            format_error("{res:f ado/<commandname>.ado} where {res:<commandname>} is the name of a command.")
          local adofiles `"`adofiles' "`r(value)'""'
        }

        else if ("`section'" == "helpfiles") {
          extract_value, line("`line'") line_lead("f ") ///
            format_error("{res:f stlhp/<commandname>.sthlp} where {res:<commandname>} is the name of a command.")
          local hlpfiles `"`hlpfiles' "`r(value)'""'
        }

        else if ("`section'" == "ancillaryfiles") {
          noi extract_value, line("`line'") line_lead("f ") line_lead2("F ") ///
            format_error("{res:f <path_and_file>} or {res:F <path_and_file>} where {res:<path_and_file>} is the relative path from {res:src/} and the file name of the ancillary files.")
          local ancfiles `"`ancfiles' "`r(value)'""'
        }

        else {
          noi di "`section'"
          noi di "`line'"
        }
      }

      * Read next line
      file read `fh' line
    }

    * Return locals
    return local stata_version   `sta_v'
    return local package_version `pkg_v'
    return local date            `date'

    return local author          = trim("`author'")
    return local contact         = trim("`contact'")
    return local url             = trim("`url'")
    return local adofiles        = trim(`"`adofiles'"')
    return local hlpfiles        = trim(`"`hlpfiles'"')
    return local ancfiles        = trim(`"`ancfiles'"')
}
end


cap program drop   verify_package_version
    program define verify_package_version, rclass

    syntax, line(string)

    if (substr("`line'",1,2) == "v ") {
      local pkg_v = substr("`line'",3,.)
      //TODO: test that version is valid
      return local pkg_v `pkg_v'
    }
    else {
      noi di as error `"{phang}.pkg file error in line {res:`line'}. Only rows on format {res:v x.y} where {res:x} and {res:y} are integers are allowed.{p_end}"'
      error 99
      exit
    }
end

cap program drop   verify_name
    program define verify_name, rclass

    syntax, line(string) pkgname(string)

    * Test that line is "d <pkgname>".
    * This verifies that the pkg file name matches the name in the file
    if ("`line'" == "d `pkgname'") {
      // line is correclty formatted pkgname - OK
      // Nothing needs to be returned as this infor was already known
    }
    else {
      noi di as error `"{phang}.pkg file error in line {res:`line'}. Only rows on format {res:d `pkgname'} are allowed in this section.{p_end}"'
      error 99
      exit
    }
end


cap program drop   verify_stata_version
    program define verify_stata_version, rclass
    syntax, line(string)
    if (substr("`line'",1,16) == "d Version: Stata") {
      local sta_v = trim(substr("`line'",17,.))
      //TODO: test that version is valid
      return local sta_v `sta_v'
    }
    else {
      noi di as error `"{phang}.pkg file error in line {res:`line'}. Only rows on format {res:v x.y} where {res:x} and {res:y} are integers are allowed.{p_end}"'
      error 99
      exit
    }
end



* Generic function to get a single line value
cap program drop   extract_value
    program define extract_value, rclass

    syntax, line(string) line_lead(string) [line_lead2(string)] format_error(string)

    local ll_len = strlen("`line_lead'")
    local ll_len2 = strlen("`line_lead2'")

    if (substr("`line'",1,`ll_len') == "`line_lead'") {
      return local value = trim(substr("`line'",`ll_len'+1,.))
    }
    else if !missing("`line_lead2'") & (substr("`line'",1,`ll_len2') == "`line_lead2'") {
      return local value = trim(substr("`line'",`ll_len2'+1,.))
    }
    else {
      noi di as error `"{phang}.pkg file error in line {res:`line'}. Valid formats for this row is only `format_error' {p_end}"'
      error 99
      exit
    }
end
