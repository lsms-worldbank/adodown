cap program drop   ad_command
    program define ad_command

    syntax anything , folder(string) pkgname(string) [debug]

    *******************************************************
    * Create locals

    * Template root url
    local branch "main"
    local gh_account_repo "lsms-worldbank/adodown"
    local repo_url "https://raw.githubusercontent.com/`gh_account_repo'"
    local template_url "`repo_url'/`branch'/ado/templates"

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
    local cname = trim("`cname'")

    * Test that subcommand is either create or remove
    if !(inlist("`scmd'","create", "remove")) {
      noi di as error "{pstd}The subcommand {inp:{it:`scmd'}} in {inp:ad_command {it:`scmd' `cname'}} is not valid. It may only be {inp:ad_command {it:create `cname'}} or {inp:ad_command {it:remove `cname'}}.{p_end}"
      error 198
      exit
    }

    * create mode
      * prepare ado and md
      * create ado and md
      * Add sthlp and ado to pkg file
    * remove mode
      * Prompt user
      * remove ado md
      * Remove sthlp and ado from pkg file

    *******************************************************
    * Confirming that the folder is a valid adodown folder

    if !missing("`debug'") noi di as text "Testing adodown folder"

    * Confirming that the folder used in folder() exists
    local folderstd	= subinstr(`"`folder'"',"\","/",.)

    local folder_error "FALSE"

    * Test the folder passed in option
    mata : st_numscalar("r(dirExist)", direxists("`folderstd'"))
    if `r(dirExist)' == 0  {
      local folder_error "TRUE"
      local missing_flds `" "`folder'" "'
    }

    * Test for adodown folders expected in the folder
    foreach ad_fld in ado mdhlp sthlp {
      mata : st_numscalar("r(dirExist)", direxists("`folderstd'/`ad_fld'"))
      if `r(dirExist)' == 0  {
        local folder_error "TRUE"
        local missing_flds `"`missing_flds' "`folder'/`ad_fld'" "'
      }
    }

    * Output errors and list missing folders
    if ("`folder_error'" == "TRUE") {
      noi di as error "{pstd}The folder in option {inp:folder()} is not valid adodown folder. The following folders were expected but not found:{p_end}"
      foreach miss_fold of local missing_flds {
        noi di as text `"{pstd}- `miss_fold'/{p_end}"'
      }
      error 99
      exit
    }

    * Test that the package file exists
    local pkgname = subinstr("`pkgname'",".pkg","",.)
    cap confirm file "`folderstd'/`pkgname'.pkg"
    if _rc {
      noi di as error "{pstd}The package file {inp:`folder'/`pkgname'.pkg} was expected but not found.{p_end}"
      error 99
      exit
    }

    *******************************************************
    * Check if files exists for this command already and throw errors

    if !missing("`debug'") noi di as text "Checking files already exist"

    local cname = subinstr("`cname'",".ado","",.)

    local adof "`folderstd'/ado/`cname'.ado"
    local mdhf "`folderstd'/mdhlp/`cname'.md"
    local sthf "`folderstd'/sthlp/`cname'.sthlp"

    * Checking if file exists or not
    foreach f in adof mdhf sthf {
      cap confirm file "``f''"
      if _rc local `f'_exists "FALSE"
      else   local `f'_exists "TRUE"
    }

    * Thorw errors for create
    if ("`scmd'" == "create") {
      if ("`adof_exists'" == "TRUE") | ("`mdhf_exists'" == "TRUE") {
        noi di as error "{pstd}One or several files already exists where a file needs to be created: {p_end}"
        if ("`adof_exists'" == "TRUE") noi di as text `"{pstd}- `adof'{p_end}"'
        if ("`mdhf_exists'" == "TRUE") noi di as text `"{pstd}- `mdhf'{p_end}"'
      }
    }

    * Thorw errors for remove
    if ("`scmd'" == "remove") {
      if ("`adof_exists'" == "FALSE") | ("`mdhf_exists'" == "FALSE") {
        noi di as error "{pstd}One or several files to be removed did not exist: {p_end}"
        if ("`adof_exists'" == "FALSE") noi di as text `"{pstd}- `adof'{p_end}"'
        if ("`mdhf_exists'" == "FALSE") noi di as text `"{pstd}- `mdhf'{p_end}"'
      }
    }

    *******************************************************
    * Check if files exists for this command already and throw errors

    if ("`scmd'" == "create") {

      *******************
      * Get all templates and store in temporary files
      noi di as text "{pstd}Accessing template files from `repo_url'. This might take a minute.{p_end}"
      local ad_templates ado mdh
      foreach adt of local ad_templates {

        tempfile `adt'_template
        if "`adt'" == "ado" local template "ad-ado-command.ado"
        if "`adt'" == "mdh" local template "ad-mdhlp-command.md"

        * Get file from GitHub repo and store in temporary file
        if !missing("`debug'") noi di as text `"Get file: `template_url'/`template'"
        cap copy "`template_url'/`template'" ``adt'_template', replace
        if _rc == 631 {
          noi di as error "{pstd}This command only works with an internet connection, and you do not seem to have an internet connection. {it:(Offline mode will be implemented.)}{p_end}""
          error 631
          exit
        }
        else if _rc {
          copy "`template_url'/`template'" ``adt'_template', replace
        }
        if !missing("`debug'") noi di as text `"  Saved in ``adt'_template'"
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
          local line = subinstr("`macval(line)'","ADCOMMANDNAME","`cname'",.)
          file write ``adt'_write' "`macval(line)'" _n
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
      file open `pkg_read'  using "`folderstd'/`pkgname'.pkg", read
      file open `pkg_write' using `pkg_out', write

      * Read first line
      file read `pkg_read' line
      while r(eof)==0 {
        * Replace placeholder with command name

        if (strpos("`macval(line)'","*** adofiles")) {
          file write `pkg_write' "`macval(line)'" _n "f ado/`cname'.ado" _n
        }
        else if (strpos("`macval(line)'","*** helpfiles")) {
          file write `pkg_write' "`macval(line)'" _n "f sthlp/`cname'.sthlp" _n
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
      * Write .ado and .mdhlp files
      foreach adt of local ad_templates {
          copy "``adt'_out'" "``adt'f'"
      }
      *Write package file
      copy "`pkg_out'" "`folderstd'/`pkgname'.pkg", replace

      noi di as res "{pstd}Command `cname' was succesfully added to package `pkgname'{p_end}"

    }




end
