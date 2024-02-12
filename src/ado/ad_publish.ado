*! version 0.1 20230724 LSMS Team, World Bank lsms@worldbank.org

cap program drop   ad_publish
    program define ad_publish

qui {

    version 14.1

    * Update the syntax. This is only a placeholder to make the command run
    syntax, ADFolder(string) [UNDocumented(string) nogen_sthlp ssczip debug]

    ****
    ** Test folder input input

    * Standardize folder
    local folderstd	= subinstr(`"`adfolder'"',"\","/",.)
    local srcfolder	= `"`adfolder'/src"'
    local adofolder	= `"`srcfolder'/ado"'
    local sthfolder	= `"`srcfolder'/sthlp"'
    local sscfolder	= `"`srcfolder'/dev/ssc"'

    * Test for adodown folders expected in the folder
    foreach ad_fld in folderstd srcfolder adofolder sthfolder {
      mata : st_numscalar("r(dirExist)", direxists("``ad_fld''"))
      if `r(dirExist)' == 0  {
        local folder_error "TRUE"
        local missing_flds `"`missing_flds' "``ad_fld''" "'
      }
    }
    * Output errors and list missing folders
    if ("`folder_error'" == "TRUE") {
      noi di as error "{pstd}The folder in option {inp:adfolder()} is not valid adodown folder. The following folders were expected but not found:{p_end}"
      foreach miss_fold of local missing_flds {
        noi di as text `"{pstd}- `miss_fold'/{p_end}"'
      }
      error 99
      exit
    }

    ********************************************************
    ** Get Meta data

    * Get meta data from package file
    ad_get_pkg_meta, adfolder(`"`folderstd'"')
    local pkgname    "`r(pkgname)'"
    local stata_vnum "`r(stata_version)'"
    local pkg_vnum   "`r(package_version)'"
    local vdate      "`r(date)'"
    local author     "`r(author)'"
    local contact    "`r(contact)'"
    local pkg_ados  `"`r(adofiles)'"'
    local pkg_hlps  `"`r(hlpfiles)'"'
    local pkg_ancs  `"`r(ancfiles)'"'

    local ado_v_header "*! version `pkg_vnum' `vdate' `author' `contact'"

    ********************************************************
    ** Generate the sthlp files

    if ("`render'" != "nogen_sthlp") {
      cap ad_sthlp, adfolder(`"`folderstd'"')
      if _rc {
        noi di as error "{pstd}Error when rendering the .sthlp files from .mdhlp files. Run command {cmd:ad_sthlp()} and fix the error or use option {opt:nogen_sthlp} to not render the files and see if package can be published anyway.{p_end}"
        * Run it again without cap to return the error
        noi ad_sthlp, adfolder(`"`folderstd'"') vnum("`pkg_vnum'") vdate("`vdate'")
      }
    }


    ********************************************************
    ** List all ado-files and helpfiles to make sure required files exists

    * List ado-files
    local adofiles : dir `"`adofolder'"' files "*.ado"	, respectcase
    foreach adofile of local adofiles {
      local cmds = "`cmds' " + subinstr("`adofile'",".ado","",1)
    }

    * List sthlp files
    local sthfiles : dir `"`sthfolder'"' files "*.sthlp"	, respectcase
    foreach sthfile of local sthfiles {
      local hlps = "`hlps' " + subinstr("`sthfile'",".sthlp","",1)
    }

    local ado_sthlp_error 0

    * Test if cmd in undocumented is not a command
    local invalid_undocumented : list undocumented - cmds
    if !missing("`invalid_undocumented'") {
      noi di as error "{pstd}The command(s) {inp:`invalid_undocumented'} used in {opt:undocumented(`undocumented')} is not a command in the ado-folder.{p_end}"
      local ado_sthlp_error 1
    }

    * Test for helpfiles without ado-files
    local sthlp_without_ado : list hlps - cmds
    if !missing("`sthlp_without_ado'") {
      noi di as error "{pstd}The help-files(s) {inp:`sthlp_without_ado'} in the {inp:`sthfolder'} folder does not have any command(s) in the {inp:`adofolder'} folder.{p_end}"
      local ado_sthlp_error 1
    }

    * Test if any commands listed as undocummented commmands are not found
    local ado_without_sthlp : list cmds - hlps
    local ado_without_sthlp : list ado_without_sthlp - undocumented
    if !missing("`ado_without_sthlp'") {
      noi di as error "{pstd}The command(s) {inp:`ado_without_sthlp'} in the {inp:`adofolder'} folder does not have any help-file(s) in the {inp:`sthfolder'} folder.{p_end}"
      local ado_sthlp_error 1
    }

    * Throw error for missing files
    if (`ado_sthlp_error' == 1) {
      error 99
      exit
    }

    ********************************************************
    ** pdate versioning meta data in adofiles

    foreach ado of local cmds {
      noi update_ado_version,           ///
        vhead("`ado_v_header'")         ///
        pkg_vnum("`pkg_vnum'")          ///
        stata_vnum("`stata_vnum'")      ///
        file(`"`adofolder'/`ado'.ado"') ///
        vdate("`vdate'")
    }

    ********************************************************
    ** generate the zip-file for ssc

    if !missing("`ssczip'") {

      local old_pwd `c(pwd)'

      * Create the ssc-version folder
      cap mkdir "`sscfolder'"
      local vfldr "`sscfolder'/v`pkg_vnum'"
      cap mkdir "`vfldr'"

      * Copy all files in the pkg file to the ssc-version folder
      foreach ado of local pkg_ados {
        split_file_extentsion, file("`ado'")
        copy `"`adofolder'/`r(file_name)'"' `"`vfldr'/`r(file_name)'"', replace
      }
      foreach hlp of local pkg_hlps {
        split_file_extentsion, file("`hlp'")
        copy `"`sthfolder'/`r(file_name)'"' `"`vfldr'/`r(file_name)'"', replace
      }
      foreach anc of local pkg_ancs {
        split_file_extentsion, file("`anc'")
        copy `"`srcfolder'/`anc'"' `"`vfldr'/`r(file_name)'"', replace
      }

      local zipfile "`vfldr'/`pkgname'.zip"
      cap rm "`zipfile'"

      * Change pwd to ssc-version folder
      cd "`vfldr'"

      * Compress the package the way ssc wants it
      zipfile * , saving("`zipfile'", replace)
      noi di as text "{pstd}Zip-archive ready to send to SSC was saved at  {res:`zipfile'}.{p_end}"

      * Restore the pwd
      cd "`old_pwd'"
    }

    // Remove when command is no longer in beta
    noi adodown "beta ad_publish"
}
end

cap program drop   update_ado_version
    program define update_ado_version

    syntax, vhead(string) pkg_vnum(string) stata_vnum(string) file(string) vdate(string)

    * Open template to read from and new tempfile to write to
    tempname ado_old ado_new
    tempfile new_adofile
    file open `ado_old' using `"`file'"', read
    file open `ado_new' using `new_adofile' , write

    local syntax_over = 0
    local version_header_used  = 0
    local version_setting_used = 0

    * Write remaining file
    file read `ado_old' line
    while r(eof)==0 {

        * Escape all characters that will mess with str end or start
        local line : subinstr local line `"""' `"" _char(34) ""', all
        local line : subinstr local line "'"   `"" _char(39) ""', all
        local line : subinstr local line "`"   `"" _char(96) ""', all
        local line : subinstr local line "$"   `"" _char(36) ""', all

        * This command only make changes to items before the first "syntax"
        * So do not perform any replacements after the initial syntax
        if (`syntax_over' != 1) {

          * Test if this line is the syntax line
          if (substr(ustrtrim("`line'"),1,6) == "syntax") {
            * If it is, set local to 1 and just write the line
            local syntax_over 1
            file write `ado_new' "`line'" _n
          }

          * Test if line is version header
          else if (substr(ustrtrim("`line'"),1,10) == "*! version") {
            * Update the version header
            file write `ado_new' "`vhead'" _n
            * Indicate that version header is used
            local version_header_used  = 1
          }

          * Test if line is stata version seting
          else if (substr(ustrtrim("`line'"),1,7) == "version") {
            file write `ado_new' "    version `stata_vnum'" _n
            * Indicate that version header is used
            local version_setting_used  = 1
          }

          * Test if line is stata version seting
          else if (substr(ustrtrim("`line'"),1,14) == "local version ") {
            file write `ado_new' `"    local version "`pkg_vnum'" "' _n
            * Indicate that version header is used
            local version_setting_used  = 1
          }

          * Test if line is stata version seting
          else if (substr(ustrtrim("`line'"),1,17) == "local versionDate") {
            file write `ado_new' `"    local versionDate "`vdate'" "' _n
            * Indicate that version header is used
            local version_setting_used  = 1
          }

          * Before syntax but wite line as is
          else file write `ado_new' "`line'" _n
        }
        * Before syntax but wite line as is
        else file write `ado_new' "`line'" _n

        * REad next line
        file read `ado_old' line
    }

    file close `ado_old'
    file close `ado_new'

    ************************
    * Test that required items were found

    if (`version_header_used' == 0) {
      noi di as error `"{pstd}The ado-file {inp:`file'} does not have a version header.{p_end}"'
      error 99
      exit
    }

    if (`version_setting_used' == 0) {
      noi di as error `"{pstd}The ado-file {inp:`file'} does not set Stata version before syntax.{p_end}"'
      error 99
      exit
    }

    ************************
    * Overwrite org fine with tempfile

    copy "`new_adofile'" `"`file'"', replace

end


* Splits a file name into its name and its extension
cap program drop 	split_file_extentsion
	program define	split_file_extentsion, rclass

	syntax, file(string)

  local file	= subinstr(`"`file'"',"\","/",.)

	**Find the last / in the file path
  local slash_index = strpos(strreverse("`file'"),"/")

	** Find file name and extension based on the last / in the file
	return local file_name  = substr("`file'",1-`slash_index',.)
end
