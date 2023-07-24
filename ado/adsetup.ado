cap program drop   adsetup
    program define adsetup

    syntax, folder(string) [ ///
      name(string) ///
      author(string) ///
      description(string) ///
      url(string) ///
      yesconfirm ///
      debug ///
      ]



    ****************************************************
    * Test input - except package meta information

    local folderstd	= subinstr(`"`folder'"',"\","/",.)
    mata : st_numscalar("r(dirExist)", direxists("`folderstd'"))
    if `r(dirExist)' == 0  {
      noi di as error `"{phang}The folder used in folder(`folder') does not exist.{p_end}"'
      error 99
      exit
    }

    //TODO: test when yesconfirm can be used

    ****************************************************
    * Set up locals used accross the command

    * Locals pointing to all folders to be setup
    local folders "ado dev mdhlp sthlp tests vignettes"

    * Locals pointing to all template files to be used
    foreach fld of local folders {
      local ad_templates "`ad_templates' ad-`fld'-README.md"
    }
    local ad_templates "`ad_templates' ad-package.pkg"
    local ad_templates "`ad_templates' ad-stata.toc"

    * Template root url
    local branch "main"
    local gh_account_repo "kbjarkefur/adodown-stata"
    local repo_url "https://raw.githubusercontent.com/`gh_account_repo'"
    local template_url "`repo_url'/`branch'/ado/templates"

    * Meta information types
    local inputtypes name author url description

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
      if !missing("`debug'") noi di as text "testfolder create: `folderstd'/`fld'"
      mata : st_numscalar("r(dirExist)", direxists("`folderstd'/`fld'"))
      if `r(dirExist)' == 1  {
        noi di as error `"{phang}A folder with the name ("`folderstd'/`fld'") already exists.{p_end}"'
        local folder_error 1
      }
    }
    if (`folder_error' == 1) {
      error 99
      exit
    }

    * Get all templates and store in temporary files
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
    if missing("`yesconfirm'") {
      local confirm_col 55
      noi di as text "{pstd}Please confirm all package meta information:{p_end}"
      noi di as text ""
      noi di as text "{pmore}Stata package name: {inp:`name'}{p_end}"
      noi di as text "{pmore}Package author name(s): {inp:`author'}{p_end}"
      noi di as text "{pmore}Package description: {inp:`name'}{p_end}"
      noi di as text "{pmore}Package URL (for example repo): {inp:`author'}{p_end}"
      noi di as text ""

      global adinp_confirmation ""
      while (upper("${adinp_confirmation}") != "Y" & upper("${adinp_confirmation}") != "BREAK") {
        noi di as txt `"{pstd}Enter "Y" to confirm and create the package template or enter "BREAK" to abort."', _request(adinp_confirmation)
      }
      if upper("${adinp_confirmation}") == "BREAK" {
        noi di as txt "{pstd}Package template aborted - nothing was created.{p_end}"
        error 1
        exit
      }
    }

    *****************************************************
    * Create template

    foreach ad_t of local ad_templates {

        template_parser, template("`ad_t'")
        local t_tempfile "`r(t_tempfile)'"
        local t_folder   "`r(t_folder)'"
        local t_file     "`r(t_file)'"

        * If not already created, create folder
        mata : st_numscalar("r(dirExist)", direxists("`folderstd'/`t_folder'"))
        if `r(dirExist)' == 0 mkdir "`folderstd'/`t_folder'"
        *Copy file to location
        copy ``t_tempfile'' "`folderstd'/`t_folder'/`t_file'"

        if !missing("`debug'") noi di as text `"File created: `t_folder'/`t_file'"
    }

    noi di as res `"{pstd}Package template successfully created at: `folder' {p_end}"'


end

* Handler for all inputs
cap program drop   userinputs
    program define userinputs, rclass

    syntax, [name(string) author(string) description(string) url(string) debug]

    if (missing("`name'") | missing("`author'") | missing("`description'") | missing("`url'")) {

      noi di as txt "{pstd}Please enter the package meta information needed to set up this package template. Type BREAK to cancel.{p_end}"

      local inputbreak "FALSE"

      * Ask for package name
      if missing("`name'") & "`inputbreak'" == "FALSE" {
        inputprompter, inputtype("name") inputprompt("Enter name of Stata package:") `debug'
        local inputbreak "`r(inputbreak)'"
        return local name "`r(verifiedinput)'"
      }

      * Ask for author name
      if missing("`author'") & "`inputbreak'" == "FALSE" {
        inputprompter, inputtype("author") inputprompt("Enter name of author(s):")
        local inputbreak "`r(inputbreak)'"
        return local author "`r(verifiedinput)'"
      }

      * Ask for author name
      if missing("`description'") & "`inputbreak'" == "FALSE" {
        inputprompter, inputtype("description") inputprompt("Enter package description:")
        local inputbreak "`r(inputbreak)'"
        return local description "`r(verifiedinput)'"
      }

      * Ask for author name
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

      * Test author name
      else if "`inputtype'" == "author" {
        //No tests for author - included as placeholder for future tests
      }

      * Test description
      else if "`inputtype'" == "description" {
        //No tests for author - included as placeholder for future tests
      }

      * Test URL
      else if "`inputtype'" == "url" {
        //No tests for author - included as placeholder for future tests
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

    syntax, template(string)

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

    * Return template file name and its folder path
    return local t_file     "`t_file'"
    return local t_folder   "`t_folder'"

end
