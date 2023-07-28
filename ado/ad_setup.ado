cap program drop   ad_setup
    program define ad_setup

    syntax, ADFolder(string) [ ///
      Name(string) ///
      Description(string) ///
      Author(string) ///
      Contact(string) ///
      Url(string) ///
      AUTOCONfirm ///
      debug ///
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

    //TODO: test when autoconfirm can be used

    ****************************************************
    * Set up locals used accross the command

    * Locals pointing to all folders to be setup
    local folders "ado dev mdhlp sthlp tests vignettes"

    * Locals pointing to all template files to be used
    foreach fld of local folders {
      local ad_templates "`ad_templates' ad-`fld'-README.md"
    }
    local ad_templates "`ad_templates' ad-dev-description.txt"
    local ad_templates "`ad_templates' ad-package.pkg"
    local ad_templates "`ad_templates' ad-stata.toc"

    * Template root url
    local branch "main"
    local gh_account_repo "lsms-worldbank/adodown"
    local repo_url "https://raw.githubusercontent.com/`gh_account_repo'"
    local template_url "`repo_url'/`branch'/ado/templates"

    * Meta information types
    local inputtypes name description author contact url

    *****************************************************
    * Handle package meta information

    * Test inputs provided passed in syntax
    local allsyntaxinputok "TRUE"
    foreach inputtype of local inputtypes {
      if !missing("``inputtype''") {
        inputconfirm syntax `inputtype' "``inputtype''"
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
    userinputs, `debug' `useinp_params'
    if "`r(inputbreak)'" == "TRUE" {
      noi di as txt "{pstd}Package template creation aborted - nothing was created.{p_end}"
      error 1
      exit
    }
    foreach inputtype of local inputtypes {
      if missing("``inputtype''") local `inputtype' `r(`inputtype')'
    }


    *****************************************************
    * Test that package can be created

    * Test that folders to be created does not already exist
    local folder_error 0
    foreach fld of local folders {
      if !missing("`debug'") noi di as text "testfolder create: `adfolderstd'/`fld'"
      mata : st_numscalar("r(dirExist)", direxists("`adfolderstd'/`fld'"))
      if `r(dirExist)' == 1  {
        noi di as error `"{phang}A folder with the name ("`adfolderstd'/`fld'") already exists.{p_end}"'
        local folder_error 1
      }
    }
    if (`folder_error' == 1) {
      error 99
      exit
    }

    * Get all templates and store in temporary files
    noi di as text "{pstd}Accessing template files from `repo_url'. This might take a minute.{p_end}"
    foreach ad_t of local ad_templates {

      * Get tempfile name from template name
      template_parser, template("`ad_t'")
      local tempfile = "`r(t_tempfile)'"
      tempfile `tempfile'

      * Get file from GitHub repo and store in temporary file
      if !missing("`debug'") noi di as text `"Get file: `template_url'/`ad_t''"
      cap copy "`template_url'/`ad_t'" ``tempfile'', replace
      if _rc == 631 {
        noi di as error "{pstd}This command only works with an internet connection, and you do not seem to have an internet connection. {it:(Offline mode will be implemented.)}{p_end}""
        error 631
        exit
      }
      else if _rc {
        copy "`template_url'/`ad_t'" ``tempfile'', replace
      }
      if !missing("`debug'") noi di as text `"  Saved in ``tempfile''"
    }


    *****************************************************
    * Confirm meta data
    if missing("`autoconfirm'") {
      noi di as text "{pstd}Please confirm all package meta information:{p_end}"
      noi di as text ""
      noi di as text "{pmore}Stata package name: {inp:`name'}{p_end}"
      noi di as text "{pmore}Package description: {inp:`description'}{p_end}"
      noi di as text "{pmore}Package author name(s): {inp:`author'}{p_end}"
      noi di as text "{pmore}Contact information: {inp:`contact'}{p_end}"
      noi di as text "{pmore}Package URL (for example repo): {inp:`url'}{p_end}"
      noi di as text ""

      global adinp_confirmation ""
      while (upper("${adinp_confirmation}") != "Y" & upper("${adinp_confirmation}") != "BREAK") {
        noi di as txt `"{pstd}Enter "Y" to confirm and create the package template or enter "BREAK" to abort."', _request(adinp_confirmation)
      }
      if upper("${adinp_confirmation}") == "BREAK" {
        noi di as txt "{pstd}Package template creation aborted - nothing was created.{p_end}"
        error 1
        exit
      }
    }

    *****************************************************
    * Create template

    * Populate the pkg tempfile
    populate_pkg, pkg_template(`package_pkg') name("`name'") description("`description'") author("`author'") contact("`contact'") url("`url'")

    * Populate the toc tempfile
    populate_toc, toc_template(`stata_toc') name("`name'")

    foreach ad_t of local ad_templates {

        template_parser, template("`ad_t'") name("`name'")
        local t_tempfile "`r(t_tempfile)'"
        local t_folder   "`r(t_folder)'"
        local t_file     "`r(t_file)'"

        * If not already created, create folder
        mata : st_numscalar("r(dirExist)", direxists("`adfolderstd'/`t_folder'"))
        if `r(dirExist)' == 0 mkdir "`adfolderstd'/`t_folder'"
        *Copy file to location
        copy ``t_tempfile'' "`adfolderstd'/`t_folder'/`t_file'"

        if !missing("`debug'") noi di as text `"File created: `t_folder'/`t_file'"
    }

    qui ad_command create `name', adfolder("`adfolder'") pkgname("`name'")

    noi di as res `"{pstd}Package template for package {inp:`name'} successfully created in: `adfolder'{p_end}"'

end

* Handler for all inputs
cap program drop   userinputs
    program define userinputs, rclass

    syntax, [name(string) description(string) author(string) contact(string)   url(string) debug]

    if (missing("`name'") | missing("`description'") | missing("`author'") | missing("`contact'") | missing("`url'")) {

      noi di as txt `"{pstd}Please enter the package meta information needed to set up this package template. Type "BREAK" to cancel.{p_end}"'

      local inputbreak "FALSE"

      * Ask for package name
      if missing("`name'") & "`inputbreak'" == "FALSE" {
        inputprompter, inputtype("name") inputprompt("Enter name of Stata package:") `debug'
        local inputbreak "`r(inputbreak)'"
        return local name "`r(verifiedinput)'"
      }

      * Ask for description
      if missing("`description'") & "`inputbreak'" == "FALSE" {
        inputprompter, inputtype("description") inputprompt("Enter package description:")
        local inputbreak "`r(inputbreak)'"
        return local description "`r(verifiedinput)'"
      }

      * Ask for author name
      if missing("`author'") & "`inputbreak'" == "FALSE" {
        inputprompter, inputtype("author") inputprompt("Enter name of author(s):")
        local inputbreak "`r(inputbreak)'"
        return local author "`r(verifiedinput)'"
      }

      * Ask for contact
      if missing("`contact'") & "`inputbreak'" == "FALSE" {
        inputprompter, inputtype("contact") inputprompt("Enter contact information:")
        local inputbreak "`r(inputbreak)'"
        return local contact "`r(verifiedinput)'"
      }

      * Ask for package url
      if missing("`url'") & "`inputbreak'" == "FALSE" {
        inputprompter, inputtype("url") inputprompt("Enter package URL (for example GitHub repo):")
        local inputbreak "`r(inputbreak)'"
        return local url "`r(verifiedinput)'"
      }

      return local inputbreak "`inputbreak'"

    }

end

* Prompting for each input
cap program drop   inputprompter
    program define inputprompter, rclass

    syntax, inputtype(string) inputprompt(string) [debug]

    if!missing("`debug'") noi di "inputprompter inputtype: `inputtype'"
    if!missing("`debug'") noi di "inputprompter inputprompt: `inputprompt'"

    local   inputbreak  "FALSE"
    local   inputok     "FALSE"
    global adinp_userinput ""
    while ("`inputok'" == "FALSE" & "`inputbreak'" == "FALSE") {
      noi di as txt "{pstd}`inputprompt'", _request(adinp_userinput)
      inputconfirm prompt `inputtype' "${adinp_userinput}"
      local inputbreak "`r(inputbreak)'"
      local inputok    "`r(inputok)'"
    }

    return local inputbreak    "`inputbreak'"
    return local verifiedinput "`r(verifiedinput)'"

end

* Test input provided either through syntax or prompt
cap program drop   inputconfirm
    program define inputconfirm, rclass

    args case inputtype userinput

    if!missing("`debug'") noi di "inputconfirm inputtype: `inputtype'"
    if!missing("`debug'") noi di "inputconfirm userinput: `userinput'"

    local error 0

    * Test for BREAK in all inputs for users to exit command
    if upper("`userinput'") == "BREAK" return local inputbreak "TRUE"

    * Test the different user inputs
    else {

      return local inputbreak "FALSE"

      * Test package name
      if "`inputtype'" == "name" {
          * Test one word
          if `: word count `userinput'' != 1 {
            noi di as error "{pstd}The package name may only include one word.{p_end}"
            local error 1
          }
          * Test only lower case
          if "`userinput'" != lower("`userinput'") {
            noi di as error "{pstd}The package name must only be lower case.{p_end}"
            local error 1
          }
      }

      * Test description
      else if "`inputtype'" == "description" {
        //No tests for description - included as placeholder for future tests
      }

      * Test author name
      else if "`inputtype'" == "author" {
        //No tests for author - included as placeholder for future tests
      }

      * Test contact information
      else if "`inputtype'" == "contact" {
        //No tests for contact - included as placeholder for future tests
      }

      * Test URL
      else if "`inputtype'" == "url" {
        //No tests for url - included as placeholder for future tests
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

    syntax, pkg_template(string) name(string) description(string) author(string) contact(string) url(string)

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
