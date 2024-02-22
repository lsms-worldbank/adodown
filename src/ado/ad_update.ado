*! version 0.5 20240222 - LSMS Team, World Bank - lsms@worldbank.org

cap program drop   ad_update
    program define ad_update

qui {

    version 14.1

    * Update the syntax. This is only a placeholder to make the command run
    syntax, ADFolder(string) PKGname(string) ///
      [ newtitle(string) newpkgversion(string) newstataversion(string) newauthor(string) newcontact(string) newurl(string)]

    * Standardize folder
    local folderstd	= subinstr(`"`adfolder'"',"\","/",.)

    * Get meta data from package file
    ad_pkg_meta, adfolder(`"`folderstd'"')
    local current_pkgdate = `r(date)'
    local current_pkgv = "`r(package_version)'"
    cap assert "`pkgname'" == "`r(pkgname)'"
    if _rc {
      noi di as error `"{pstd}The package name used in {res:pkgname()} does not match the pkg-file found in location "`adfolder'".{p_end}"'
      error 99
      exit
    }

    * Test that at least some option is provided
    if missing( "`newtitle'`newpkgversion'`newstataversion'`newauthor'`newcontact'`newurl'" ) {
      noi di as error "{pstd}At least one meta data of {res:newpkgversion()}, {res:newstataversion()}, {res:newauthor()}, or {res:newcontact()} must be provided.{p_end}"
      error 99
      exit
    }

    * Test that pkgversion is either minor or major
    if !missing("`newpkgversion'") {

      * Split suboption and clean up gettoken output
      gettoken newpkg_type sameday : newpkgversion , p(",")
      local newpkg_type = trim("`newpkg_type'")
      local sameday = trim(subinstr("`sameday'",",","",1))

      if !(inlist("`newpkg_type'", "minor", "major")) {
        noi di as error "{pstd}The new version type valu in {res:pkgversion()} is only allowed to be either {it:minor} or {it:major}.{p_end}"
        error 99
        exit
      }

      if !missing("`sameday'") {
        if "`sameday'" != "samedayok" {
          noi di as error "{pstd}The only allowed sub-option in  {res:pkgversion()} is {it:samedayok}. Meaning that only these values are allowed: {res:pkgversion(minor)}, {res:pkgversion(minor, samedayok)}, {res:pkgversion(major)}, or {res:pkgversion(major, samedayok)}.{p_end}"
          error 99
          exit
        }
      }
      else {
        qui adodown formatteddate
        local new_pkgdate = `"`r(formatteddate)'"'
        cap assert `current_pkgdate' < `new_pkgdate'
        if _rc {
          noi di as error "{pstd}The sub-option in {it:samedayok} was not used in {res:pkgversion()} but the current date in the pkg-file is not older than today.{p_end}"
          error 99
          exit
        }
      }

      gettoken major_pkgv minor_pkgv : current_pkgv , p(".")
      local major_pkgv = trim("`major_pkgv'")
      local minor_pkgv = trim(subinstr("`minor_pkgv'",".","",1))

      if "`newpkg_type'" == "major" {
        local major_pkgv = `major_pkgv' + 1
        local minor_pkgv = 0
      }
      if "`newpkg_type'" == "minor" local minor_pkgv = `minor_pkgv' + 1

      local generated_pkgversion = "`major_pkgv'.`minor_pkgv'"
    }

    noi ad_pkg_meta , adfolder(`"`folderstd'"') newtitle("`newtitle'") newpkgversion("`generated_pkgversion'") newstataversion("`newstataversion'") newauthor("`newauthor'") newcontact("`newcontact'") newurl("`newurl'") newdate("`newdate'")



}
end
