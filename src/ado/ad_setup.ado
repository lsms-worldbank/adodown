cap program drop   ad_setup
    program define ad_setup
qui {
    syntax, ADFolder(string) [ ///
      Name(string)             ///
      Description(string)      ///
      Author(string)           ///
      Contact(string)          ///
      Url(string)              ///
      AUTOprompt                 ///
      GIThub                   ///
      debug                    ///
      ]

    ****************************************************
    * Test input - except package meta information

    local adfolderstd	= subinstr(`"`adfolder'"',"\","/",.)
    mata : st_numscalar("r(dirExist)", direxists("`adfolderstd'"))
    if `r(dirExist)' == 0  {
      noi di as error `"{phang}The folder used in adfolder(`adfolder') does not exist.{p_end}"'
      error 99
      exit
    }
    * Local to the src/ folder
    local srcfolderstd `"`adfolder'/src"'

    ****************************************************
    * Set up locals used accross the command

    * Meta information types
    local inputtypes name description author contact url

    * Template root url
    local branch "main"
    local gh_account_repo "lsms-worldbank/adodown"
    local repo_url "https://raw.githubusercontent.com/`gh_account_repo'"
    local template_url "`repo_url'/`branch'/src/ado/templates"

    * Locals pointing to all template files to be used in the src folder
    local src_tfs ""
    local src_tfs "`src_tfs' ad-src-package.pkg"
    local src_tfs "`src_tfs' ad-src-stata.toc"
    local src_tfs "`src_tfs' ad-src-ado-README.md"
    local src_tfs "`src_tfs' ad-src-dev-README.md"
    local src_tfs "`src_tfs' ad-src-mdhlp-README.md"
    local src_tfs "`src_tfs' ad-src-sthlp-README.md"
    local src_tfs "`src_tfs' ad-src-tests-README.md"
    local src_tfs "`src_tfs' ad-src-vignettes-README.md"
    local src_tfs "`src_tfs' ad-src-dev-description.txt"

    * Extract from template names all folders needed
    local src_folders ""
    foreach template of local src_tfs {
      template_parser, template("`template'")
      local this_folder "`r(t_folder)'"
      local src_folders : list src_folders | this_folder
    }

    * Locals pointing to all template files for the github option
    local gh_tfs ""
    local gh_tfs "`gh_tfs' ad-gh.gitignore"
    local gh_tfs "`gh_tfs' ad-gh-workflows.yaml"

    *****************************************************
    * Handle package meta information

    * Test inputs provided passed in syntax
    local allsyntaxinputok "TRUE"
    foreach inputtype of local inputtypes {
      if !missing("``inputtype''") {
        noi inputconfirm syntax `inputtype' "``inputtype''"
        if "`r(inputok)'" == "FALSE" {
            local allsyntaxinputok "FALSE"
            noi di as error "{pstd}Package meta data used in `inputtype'(``inputtype'') is not valid.{p_end}"
        }
      }
    }
    * Throw error if any syntax provided inputs cannot be verified
    if "`allsyntaxinputok'" == "FALSE" {
      error 99
      exit
    }

    * Handle user inputs
    * Prepare params name("`name'") author("`author'") url("`url'") etc.
    foreach inputtype of local inputtypes {
      local useinp_params "`useinp_params' `inputtype'("``inputtype''")"
    }
    noi userinputs, inputtypes(`inputtypes') `debug' `autoprompt' `useinp_params'
    if "`r(inputbreak)'" == "TRUE" {
      noi di as txt "{pstd}Package template creation aborted - nothing was created.{p_end}"
      error 1
      exit
    }
    foreach inputtype of local inputtypes {
      if missing("``inputtype''") local `inputtype' `r(`inputtype')'
    }

    *****************************************************
    * Prompt user if GH files should be created

    if missing("`github'") & missing("`autoprompt'") {
      noi di ""
      noi di as text "{pstd}Are you setting up this package template folder in  GitHub repository and want to add GitHub template files for the adodown workflow? This includes adding a .gitignore template and a Github Actions workflow template for automatic web documentation.{p_end}"
      noi di as text ""

      global ghinp_confirmation ""
      while (!inlist(upper("${ghinp_confirmation}"),"Y","N","BREAK")) {
        noi di as txt `"{pstd}Enter "Y" to to add the GitHub templates, or "N" to not add them. Enter "BREAK" to abort"', _request(ghinp_confirmation)
      }

      * Set local github as if the option was used
      if upper("${ghinp_confirmation}") =="Y" {
        local github "github"
      }
      else if upper("${ghinp_confirmation}") =="BREAK" {
        noi di as txt "{pstd}Package template creation aborted - nothing was created.{p_end}"
        error 1
        exit
      }
    }

    *****************************************************
    * Test that package can be created

    * Test that folders to be created does not already exist
    local test_folders "`src_folders'"
    if !missing("`github'") local test_folders "`src_folders' .github/workflows"

    local folder_error 0
    foreach folder of local test_folders {
      if !missing("`debug'") noi di as text "testfolder create: `adfolderstd'/`folder'"
      mata : st_numscalar("r(dirExist)", direxists("`adfolderstd'/`folder'"))
      if `r(dirExist)' == 1  {
        noi di as error `"{phang}A folder with the name ("`adfolderstd'/`folder'") already exists.{p_end}"'
        local folder_error 1
      }
    }
    if (`folder_error' == 1) {
      error 99
      exit
    }


    * Get all templates and store in temporary files
    noi di as text "{pstd}Accessing template files from `repo_url'. This might take a minute.{p_end}"
    foreach template of local src_tfs {

      * Get tempfile name from template name
      template_parser, template("`template'")
      local tempfile = "`r(t_tempfile)'"
      tempfile `tempfile'

      * Get file from GitHub repo and store in temporary file
      if !missing("`debug'") noi di as text `"Get file: `template_url'/`template''"
      cap copy "`template_url'/`template'" ``tempfile'', replace
      if _rc == 631 {
        noi di as error "{pstd}This command only works with an internet connection, and you do not seem to have an internet connection. {it:(Offline mode will be implemented.)}{p_end}""
        error 631
        exit
      }
      else if _rc {
        copy "`template_url'/`template'" ``tempfile'', replace
      }
    }


    * Get github templates
    if !missing("`github'") {
      foreach template of local gh_tfs {
        if !missing("`debug'") noi di as text `"Get file: `template_url'/`template''"
        * Get file from GitHub repo and store in temporary file
        local tempfile = subinstr("`template'","-","_",.)
        local tempfile = subinstr("`tempfile'",".","_",.)
        tempfile `tempfile'
        copy "`template_url'/`template'" ``tempfile'', replace
      }
    }

    *****************************************************
    * Confirm meta data

    if missing("`autoprompt'") {

      * Prepare Github output
      if !missing("`github'") local gh_conf "GitHub templates file will be created."
      else local gh_conf "No GitHub templates file will be created."

      noi di as text ""
      noi di as text "{pstd}Before any files are created on your disk, please confirm the following information:{p_end}"
      noi di as text ""
      noi di as text "{pmore}Stata package name: {inp:`name'}{p_end}"
      noi di as text "{pmore}Package location: {inp:`adfolder'}{p_end}"
      noi di as text "{pmore}Package description: {inp:`description'}{p_end}"
      noi di as text "{pmore}Package author name(s): {inp:`author'}{p_end}"
      noi di as text "{pmore}Contact information: {inp:`contact'}{p_end}"
      noi di as text "{pmore}Package URL (for example repo): {inp:`url'}{p_end}"
      noi di as text ""
      noi di as text "{pmore}`gh_conf'{p_end}"
      noi di as text ""

      global adinp_confirmation ""
      while (!inlist(upper("${adinp_confirmation}"),"Y", "BREAK")) {
        noi di as txt `"{pstd}Enter "Y" to confirm and create the package template or enter "BREAK" to abort."', _request(adinp_confirmation)
      }
      if upper("${adinp_confirmation}") == "BREAK" {
        noi di as txt "{pstd}Package template creation aborted - nothing was created.{p_end}"
        error 1
        exit
      }
    }

    *****************************************************
    * Populate templates

    * Populate the pkg tempfile
    populate_pkg, pkg_template(`src_package_pkg') name("`name'") description("`description'") author("`author'") contact("`contact'") url("`url'")

    * Populate the toc tempfile
    populate_toc, toc_template(`src_stata_toc') name("`name'")

    *****************************************************
    * Everything is ready - create template on disk

    * Create all folders needed
    foreach folder of local src_folders {
      recursive_mkdir, folder(`"`adfolderstd'/`folder'"')
    }

    * Copy all templates files to their folders
    foreach template of local src_tfs {
        * Get file/folder name from template name and write file
        template_parser, template("`template'") name("`name'")
        copy ``r(t_tempfile)'' `"`adfolderstd'/`r(t_folder)'/`r(t_file)'"'
        if !missing("`debug'") noi di as text `"File created:/`r(t_folder)'/`r(t_file)'"'
    }

    * Copy the github template to the folders
    if !missing("`github'") {
      foreach template of local gh_tfs {

        * Generate tempfile name
        local tempfile = subinstr("`template'","-","_",.)
        local tempfile = subinstr("`tempfile'",".","_",.)

        * Get special folder location
        if "`template'" == "ad-gh.gitignore" {
          local filename ".gitignore"
          local folder   ""
        }
        else if "`template'" == "ad-gh-workflows.yaml" {
          local filename "build_adodown_site.yaml"
          local folder   "/.github/workflows"
        }

        * Create folders if needed
        recursive_mkdir, folder(`"`adfolderstd'`folder'"')
        * Copy file to location
        copy ``tempfile'' `"`adfolderstd'`folder'/`filename'"'
        if !missing("`debug'") noi di as text `"File created:`folder'/`filename'"'
      }
    }

    * Add a command with the same name as the package to the package template
    qui ad_command create `name', adfolder("`adfolder'") pkgname("`name'")

    noi di as res `"{pstd}Package template for package {inp:`name'} successfully created in: `adfolder'{p_end}"'
}
end

* Handler for all inputs
cap program drop   userinputs
    program define userinputs, rclass
qui {
    syntax, [inputtypes(string) name(string) description(string) author(string) contact(string) url(string) autoprompt debug]

    local prompt_intro `"Please enter the package meta information needed to set up this package template. Type "BREAK" to cancel."'
    local name_prompt "Enter name of Stata package {it:(required)}:"
    local description_prompt "Enter package description {it:(optional)}:"
    local author_prompt "Enter name of author(s) {it:(optional)}:"
    local contact_prompt "Enter contact information {it:(optional)}:"
    local url_prompt  "Enter package URL. For example GitHub repo {it:(optional)}:"

    * Test if autoprompt was not used
    if missing("`autoprompt'") {

      * Autoprompt not used, prompt for any information not provided
      if (missing("`name'") | missing("`description'") | missing("`author'") | missing("`contact'") | missing("`url'")) {

        noi di ""
        noi di as txt `"{pstd}`prompt_intro' Press ENTER with no input to leave an optional input blank.{p_end}"'
        local inputbreak "FALSE"

        foreach inputtype of local inputtypes {
          * Ask for input if missin
          if missing("``inputtype''") & "`inputbreak'" == "FALSE" {
            noi di ""
            noi inputprompter, `debug' ///
              inputtype("`inputtype'") ///
              inputprompt("``inputtype'_prompt'")
            local inputbreak "`r(inputbreak)'"
            return local `inputtype' "`r(verifiedinput)'"
          }
        }
        return local inputbreak "`inputbreak'"
      }
    }
    else {

      * Autoprompt was used, prompt anyway if name is missing as it is required
      if missing("`name'") {

        noi di ""
        noi di as txt `"{pstd}`prompt_intro'{p_end}"'
        local inputbreak "FALSE"

        * Ask for package name
        if missing("`name'") & "`inputbreak'" == "FALSE" {
          noi di ""
          noi inputprompter, inputtype("name") inputprompt("`name_prompt'") `debug'
          local inputbreak "`r(inputbreak)'"
          return local name "`r(verifiedinput)'"
        }
        return local inputbreak "`inputbreak'"
      }
    }



}
end

* Prompting for each input
cap program drop   inputprompter
    program define inputprompter, rclass
qui {
    syntax, inputtype(string) inputprompt(string) [required debug]

    if!missing("`debug'") noi di "inputprompter inputtype: `inputtype'"
    if!missing("`debug'") noi di "inputprompter inputprompt: `inputprompt'"

    local   inputbreak  "FALSE"
    local   inputok     "FALSE"
    global adinp_userinput ""
    while ("`inputok'" == "FALSE" & "`inputbreak'" == "FALSE") {
      noi di as txt "{pstd}`inputprompt'", _request(adinp_userinput)
      noi inputconfirm prompt `inputtype' "${adinp_userinput}"
      local inputbreak "`r(inputbreak)'"
      local inputok    "`r(inputok)'"
    }

    return local inputbreak    "`inputbreak'"
    return local verifiedinput "`r(verifiedinput)'"
}
end

* Test input provided either through syntax or prompt
cap program drop   inputconfirm
    program define inputconfirm, rclass
qui {
    args case inputtype userinput

    local error 0

    * Test for BREAK in all inputs for users to exit command
    if upper("`userinput'") == "BREAK" return local inputbreak "TRUE"

    * Test the different user inputs
    else {

      return local inputbreak "FALSE"

      * Test package name
      if "`inputtype'" == "name" {
          * Test one word
          if `: word count `userinput'' > 1 {
            noi di as error "{pstd}The package name may only include one word.{p_end}"
            local error 1
          }
          * Test only lower case
          if "`userinput'" != lower("`userinput'") {
            noi di as error "{pstd}The package name must only be lower case.{p_end}"
            local error 1
          }
          if "`userinput'" == "" {
            noi di as error "{pstd}The package name may not be blank.{p_end}"
            local error 1
          }
      }

      * Inputs with no tests
      else if inlist("`inputtype'","description","author","contact","url") {
        //No tests for these inputs
      }

      else {
        noi di as error "{pmore}Internal error in inputconfirm. Incorrect input type in: [`inputtype']{p_end}"
        error 99
        exit
      }

      if `error' == 0 {
        return local inputok "TRUE"
        return local verifiedinput "`userinput'"
      }
      else {
        return local inputok "FALSE"
        if ("`case'" == "prompt") noi di "{pstd}Invalid input. You entered: [`userinput']. Try again.{p_end}"
      }
   }
}
end

* Prompting for each input
cap program drop   template_parser
    program define template_parser, rclass

    syntax, template(string) [name(string)]

    local template = subinstr("`template'","ad-","",1)

    * Create the tempfile name
    local t_tempfile = "`template'"
    local t_tempfile = subinstr("`t_tempfile'","-","_",.)
    local t_tempfile = subinstr("`t_tempfile'",".","_",.)
    * Return tempfile name
    return local t_tempfile     "`t_tempfile'"
    return local t_tempfile_len = strlen("`t_tempfile'") // Needed to check that name is len<32

    * Get file name and folder path
    local dash_index = strpos(strreverse("`template'"),"-")  // Get pos of last hyphen from end
    local t_file     = substr("`template'",1-`dash_index',.) // Get string after pos of last hyphen
    local t_len      = strlen("`t_tempfile'")
    * If the template name has folders, parse and prep that part
    if (`dash_index' > 0) {
        local t_folder   = substr("`template'",1,`t_len'-`dash_index') // Get string up to last hyphen
        local t_folder   = subinstr("`t_folder'","-","/",.) // Convert remaining hyphen to slashes
    }
    else local t_folder ""

    * Update the
    if (!missing("`name'") & "`t_file'" == "package.pkg") {
      local t_file "`name'.pkg"
    }

    * Return template file name and its folder path
    return local t_file     "`t_file'"
    return local t_folder   "`t_folder'"

end

* Populating the tempfile
cap program drop   populate_pkg
    program define populate_pkg, rclass

    syntax, pkg_template(string) name(string) [description(string) author(string) contact(string) url(string)]

    * Initiate the tempfile handlers and tempfiles needed
    tempname pkg_read pkg_write
    tempfile pkg_output

    * Open template to read from and new tempfile to write to
    file open `pkg_read'  using `pkg_template', read
    file open `pkg_write' using `pkg_output'  , write

    * Read first line
    file read `pkg_read' line

    * Write lines as-is until section
    local section "write_asis"
    while r(eof)==0 {


        if "`line'" == "*** version" local section "write_asis"
        if "`line'" == "*** name" {
            local section "write_custom"
            file write `pkg_write' "`macval(line)'" _n "d `name'" _n
        }
        if "`line'" == "*** description" {
            local section "write_custom"
            file write `pkg_write' "`macval(line)'" _n "d `description'" _n "d" _n
        }
        if "`line'" == "*** stata" {
            local section "write_custom"
            file write `pkg_write' "`macval(line)'" _n "d Version: Stata 14.1" _n "d" _n
        }
        if "`line'" == "*** author" {
            local section "write_custom"
            file write `pkg_write' "`macval(line)'" _n "d Author: `author'" _n
        }
        if "`line'" == "*** contact" {
            local section "write_custom"
            file write `pkg_write' "`macval(line)'" _n "d Contact: `contact'" _n
        }
        if "`line'" == "*** url" {
            local section "write_custom"
            file write `pkg_write' "`macval(line)'" _n "d URL: `url'" _n "d" _n
        }
        if "`line'" == "*** date" {
            local section "write_custom"
            local date: display %tdCCYYNNDD `= date("`c(current_date)'","DMY")'
            file write `pkg_write' "`macval(line)'" _n "d Distribution-Date: `date'" _n "d" _n
        }
        if "`line'" == "*** adofiles" local section "write_asis"
        if "`line'" == "*** helpfiles" local section "write_asis"
        if "`line'" == "*** ancillaryfiles" local section "write_asis"
        if "`line'" == "*** end" local section "write_asis"

        * Write as-is sections
        if "`section'" == "write_asis" file write `pkg_write' "`macval(line)'" _n

        * Read next line
        file read `pkg_read' line
    }
    file close `pkg_read'
    file close `pkg_write'

    * Overwrite the template tempfiel with the populated file
    copy `pkg_output' `pkg_template', replace
end

cap program drop   populate_toc
    program define populate_toc, rclass

    syntax, toc_template(string) name(string)

    * Initiate the tempfile handlers and tempfiles needed
    tempname toc_read toc_write
    tempfile toc_output

    * Open template to read from and new tempfile to write to
    file open `toc_read'  using `toc_template', read
    file open `toc_write' using `toc_output'  , write

    * Read first line
    file read `toc_read' line

    * Write lines as-is until section
    local section "write_asis"
    while r(eof)==0 {

        if "`line'" == "*** version" local section "write_asis"
        if "`line'" == "*** packages" {
            local section "write_custom"
            file write `toc_write' "`macval(line)'" _n "p `name'" _n _n
        }

        * Write as-is sections
        if "`section'" == "write_asis" file write `toc_write' "`macval(line)'" _n

        * Read next line
        file read `toc_read' line
    }
    file close `toc_read'
    file close `toc_write'

    * Overwrite the template tempfiel with the populated file
    copy `toc_output' `toc_template', replace
end

* Recursively create folders, such that folder(abc/def) first create a folder
* "abc" and then in it a folder "def"
cap program drop recursive_mkdir
	program define recursive_mkdir

	syntax, folder(string)
	*Test if this folder exists
	mata : st_numscalar("r(dirExist)", direxists(`"`folder'"'))
	*Folder does not exist, find parent folder and make recursive call
	if (`r(dirExist)' == 0) {
		*Get the parent folder of folder
		local lastSlash = strpos(strreverse(`"`folder'"'),"/")
		local parentFolder = substr(`"`folder'"',1,strlen("`folder'")-`lastSlash')
		local thisFolder = substr(`"`folder'"', (-1 * `lastSlash')+1 ,.)
		*Recursively create parent folders
		noi recursive_mkdir , folder(`"`parentFolder'"')
		*Create this folder as the parent folder is certain to exist now
		noi mkdir "`folder'"
	}
end
