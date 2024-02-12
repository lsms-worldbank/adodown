*! version 0.1 20230724 LSMS Team, World Bank lsms@worldbank.org

cap program drop   ad_command
    program define ad_command

qui {

version 14.1

    syntax anything , ADFolder(string) PKGname(string) [UNDOCumented debug]

    *******************************************************
    * Test inputs

    * Test that ad_command is followed by exactly two words
    if (`: list sizeof anything' != 2) {
      noi di as error "{pstd}The command must specified {inp:ad_command {it:subcommand commandname}}, where {inp:{it:subcommand}} and {inp:{it:commandname}} may only be one word each. You entered {inp:ad_command `anything'}.{p_end}"
      error 198
      exit
    }

    *Parse out the sub-command and the command name
    gettoken scmd cname : anything
    local scmd  = trim("`scmd'")
    local cname = trim(subinstr("`cname'",".ado","",.))

    * Test that subcommand is either create or remove
    if !(inlist("`scmd'","create", "remove")) {
      noi di as error "{pstd}The subcommand {inp:{it:`scmd'}} in {inp:ad_command {it:`scmd' `cname'}} is not valid. It may only be {inp:ad_command {it:create `cname'}} or {inp:ad_command {it:remove `cname'}}.{p_end}"
      error 198
      exit
    }

    *******************************************************
    * Confirming that the folder is a valid adodown folder

    * Confirming that the folder used in adfolder() exists
    local folderstd	= subinstr(`"`adfolder'"',"\","/",.)
    local srcfolder	= `"`folderstd'/src"'

    local folder_error "FALSE"

    * Test the folder passed in option
    mata : st_numscalar("r(dirExist)", direxists("`folderstd'"))
    if `r(dirExist)' == 0  {
      local folder_error "TRUE"
      local missing_flds `" "`adfolder'" "'
    }

    * Test for adodown folders expected in the folder
    foreach ad_fld in ado mdhlp sthlp tests {
      mata : st_numscalar("r(dirExist)", direxists("`srcfolder'/`ad_fld'"))
      if `r(dirExist)' == 0  {
        local folder_error "TRUE"
        local missing_flds `"`missing_flds' "`srcfolder'/`ad_fld'" "'
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

    * Test that the package file exists
    local pkgname = subinstr("`pkgname'",".pkg","",.)
    cap confirm file "`srcfolder'/`pkgname'.pkg"
    if _rc {
      noi di as error "{pstd}The package file {inp:`srcfolder'/`pkgname'.pkg} was expected but not found.{p_end}"
      error 99
      exit
    }

    *******************************************************
    * Check if files exists for this command already and throw errors

    if !missing("`debug'") noi di as text "Checking files already exist"

    * Locals for refrences to the files assocaited with this command
    local adof     "`srcfolder'/ado/`cname'.ado"
    local mdhf     "`srcfolder'/mdhlp/`cname'.md"
    local sthf     "`srcfolder'/sthlp/`cname'.sthlp"
    local tst_fldr "`srcfolder'/tests/`cname'"
    local tstf     "`tst_fldr'/`cname'.do"

    * Checking if file exists or not
    foreach f in adof mdhf sthf tstf {
      cap confirm file "``f''"
      if _rc {
        local `f'_exists "FALSE"
        local f_exists_f = trim("`f_exists_f' `f'")
      }
      else {
        local `f'_exists "TRUE"
        local f_exists_t = trim("`f_exists_t' `f'")
      }
    }

    * Throw errors if files to be created already exists
    if ("`scmd'" == "create") & !missing("`f_exists_t'") {
      noi di as error _n "{pstd}One or several files already exists where a file needs to be created: {p_end}"
      foreach f of local f_exists_t {
        noi di as text `"{pstd}- ``f''{p_end}"'
      }
      error 99
      exit
    }

    * List files that does not exist - this is not an error
    if ("`scmd'" == "remove") & !missing("`f_exists_f'") {
      noi di as text _n "{pstd}One or several files to be removed did not exist: {p_end}"
      foreach f of local f_exists_f {
        noi di as text `"{pstd}- ``f''{p_end}"'
      }
    }

    *******************************************************
    *******************************************************
    * Carry out subcommand create

    if ("`scmd'" == "create") {

      *******************
      * Get all templates and store in temporary files
      local ad_templates "ado tst"

      * Unless undocumented is used, add mdh
      if missing("`undocumented'") {
        local ad_templates "`ad_templates' mdh"
      }

      foreach adt of local ad_templates {

        tempfile `adt'_template
        if "`adt'" == "ado" local template "ad-cmd-command.ado"
        if "`adt'" == "mdh" local template "ad-cmd-command.md"
        if "`adt'" == "tst" local template "ad-cmd-command.do"

        * Get template file and store in temporary file
        if !missing("`debug'") noi di as text `"Get template file: `template' and store in `adt'_template "'
        cap findfile `template'
        if (_rc == 0) {
          * Copy file found in findfile to tempfile
          copy "`r(fn)'" ``adt'_template', replace
        }
        *handle findfile errors
        else if (_rc == 601) {
          noi di as error "{pstd}The template file {inp:`template'} cannot be found. Make sure that {inp:adodown} is installed correctly.{p_end}"
          findfile `template'
        }
        else {
          noi di as error "{pstd}Unhandled adodown error in findfile.{p_end}"
          findfile `template'
        }

        if !missing("`debug'") noi di as text `"  Saved in ``adt'_template'"'
      }

      *******************
      * Populate templates

      foreach adt of local ad_templates {

        tempfile `adt'_out
        tempname `adt'_read `adt'_write

        * Open template to read from and new tempfile to write to
        file open ``adt'_read'  using ``adt'_template', read
        file open ``adt'_write' using ``adt'_out'  , write

        * Read first line
        file read ``adt'_read' line
        while r(eof)==0 {
          * Replace placeholder with command name
          local line = subinstr(`"`macval(line)'"',"ADCOMMANDNAME","`cname'",.)
          local line = subinstr(`"`macval(line)'"',"ADCLONEPATH",`"`adfolder'"',.)
          local line = subinstr(`"`macval(line)'"',"ADPKGNAME","`pkgname'",.)
          file write ``adt'_write' `"`macval(line)'"' _n
          * Read next line
          file read ``adt'_read' line
        }

        file close ``adt'_write'
        file close ``adt'_read'
      }

      *******************
      * Update package file
      tempfile pkg_out
      tempname pkg_read pkg_write

      * Open template to read from and new tempfile to write to
      file open `pkg_read'  using "`srcfolder'/`pkgname'.pkg", read
      file open `pkg_write' using `pkg_out', write

      * Read first line
      file read `pkg_read' line
      while r(eof)==0 {
        * Replace placeholder with command name

        if (strpos("`macval(line)'","*** adofiles")) {
          file write `pkg_write' "`macval(line)'" _n "f ado/`cname'.ado" _n
        }
        else if (strpos("`macval(line)'","*** helpfiles")) {
          * Only add sthlp file if command is documented
          file write `pkg_write' "`macval(line)'" _n
          if missing("`undocumented'") file write `pkg_write' "f sthlp/`cname'.sthlp" _n
        }
        else {
          file write `pkg_write' "`macval(line)'" _n
        }

        * Read next line
        file read `pkg_read' line
      }

      file close `pkg_write'
      file close `pkg_read'


      *******************
      * Write files to disk
      * Write .ado and .mdhlp files and .do test file

      cap mkdir "`tst_fldr'"

      foreach adt of local ad_templates {
          copy "``adt'_out'" "``adt'f'"
      }
      *Write package file
      copy "`pkg_out'" "`srcfolder'/`pkgname'.pkg", replace

      * Convert the first version of the sthlp file
      if missing("`undocumented'") {
        qui ad_sthlp, adfolder("`adfolder'") commands("`cname'")
      }

      noi di as res "{pstd}Command {it:`cname'} was succesfully added to package {it:`pkgname'}.{p_end}"

    }

    *******************************************************
    *******************************************************
    * Carry out subcommand remove

    if ("`scmd'" == "remove") {

      *******************
      * Update package file in tempfile
      tempfile pkg_out
      tempname pkg_read pkg_write

      * Open template to read from and new tempfile to write to
      file open `pkg_read'  using "`srcfolder'/`pkgname'.pkg", read
      file open `pkg_write' using `pkg_out', write

      * Read first line
      file read `pkg_read' line
      while r(eof)==0 {
        * Replace placeholder with command name

        if (strpos("`macval(line)'","f ado/`cname'.ado")) {
          // Do not copy line to be removed
        }
        else if (strpos("`macval(line)'","f sthlp/`cname'.sthlp")) {
          // Do not copy line to be removed
        }
        else {
          file write `pkg_write' "`macval(line)'" _n
        }

        * Read next line
        file read `pkg_read' line
      }

      file close `pkg_write'
      file close `pkg_read'

      **************************
      * Prompt users that files will be deleted

      * Prompt if any files associated with the command to remove exists
      if !missing("`f_exists_t'") {
        noi di as text _n "{pstd}{red:Warning:} The following files for command {inp:`cname'} are about to be deleted:{p_end}"
        foreach f of local f_exists_t {
          noi di as text `"{pstd}- ``f''{p_end}"'
        }
        noi di as text _n "{pstd}And any reference to files associated with the command {inp:`cname'} will be removed from the {inp:`pkgname'.pkg} file. {p_end}" _n

        global adremove_confirmation ""
        while (upper("${adremove_confirmation}") != "Y" & upper("${adremove_confirmation}") != "BREAK") {
          noi di as txt `"{pstd}Enter "Y" to confirm or enter "BREAK" to abort."', _request(adremove_confirmation)
        }
        if upper("${adremove_confirmation}") == "BREAK" {
          noi di as txt "{pstd}Removal aborted - nothing was changed.{p_end}"
          error 1
          exit
        }
      }
      * Prompt if no files associated with the command to remove exists
      else {
        noi di as text _n "{pstd}{red:Warning:} No files associated with a command named exists {inp:`cname'}. No files will be removed. Continuing only makes sure that no file references to a command with that name exists in the {inp:`pkgname'.pkg} file.{p_end}" _n

        global adremove_confirmation ""
        while (upper("${adremove_confirmation}") != "Y" & upper("${adremove_confirmation}") != "BREAK") {
          noi di as txt `"{pstd}Enter "Y" to continue or enter "BREAK" to abort."', _request(adremove_confirmation)
        }
        if upper("${adremove_confirmation}") == "BREAK" {
          noi di as txt "{pstd}Removal aborted - nothing was changed.{p_end}"
          error 1
          exit
        }
      }


      **************************
      * Remove the command

      * Delete files associated with this command
      foreach f of local f_exists_t {
        rm "``f''"
      }

      *Copy updated tempfile to package file
      copy "`pkg_out'" "`srcfolder'/`pkgname'.pkg", replace

      noi di as res "{pstd}Command {it:`cname'} was succesfully removed from package {it:`pkgname'}.{p_end}"

    }
}

// Remove when command is no longer in beta
noi adodown "beta ad_command"

end
