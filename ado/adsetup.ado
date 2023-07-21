cap program drop   adsetup
    program define adsetup

    syntax, folder(string) [packagename(string) author(string) yesall debug]

    * Locals pointing to all folders to be setup
    local folders "ado dev mdhlp stlhp tests vignettes"

    * Locals pointing to all template files to be used
    foreach fld of local folders {
      local ad_f_read_`fld'  "adtemplate_`fld'_README.md"
    }
    local ad_f_pkg "adtemplate_package.pkg"
    local ad_f_toc "adtemplate_stata.toc"

    *****************************************************
    * Handle package meta information

    * Test inputs provided passed in syntax
    local allsyntaxinputok "TRUE"
    foreach inputtype in packagename author {
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
    userinputs, packagename("`packagename'") author("`author'") `debug'
    if "`r(inputbreak)'" == "TRUE" {
      error 1
      exit
    }
    if missing("`packagename'") local packagename `r(packagename)'
    if missing("`author'")      local author `r(author)'

    *****************************************************
    * Test that package can be created




    *****************************************************
    * Confirm meta data
    if missing("`yesall'") {
      local confirm_col 55
      noi di as text "{pstd}Please confirm all package meta information:{p_end}"
      noi di as text ""
      noi di as text "{pmore}Stata package name: {inp:`packagename'}{p_end}"
      noi di as text "{pmore}Package author name(s): {inp:`author'}{p_end}"
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


end

* Handler for all inputs
cap program drop   userinputs
    program define userinputs, rclass

    syntax, [packagename(string) author(string) debug]

    if (missing("`packagename'") | missing("`author'")) {

      noi di as txt "{pstd}Please enter the package meta information needed to set up this package template:{p_end}"

      local inputbreak "FALSE"

      * Ask for package name
      if missing("`packagename'") & "`inputbreak'" == "FALSE" {
        inputprompter, inputtype("packagename") inputprompt("Type name of Stata package:") `debug'
        local inputbreak "`r(inputbreak)'"
        return local packagename "`r(verifiedinput)'"
      }

      * Ask for author name
      if missing("`author'") & "`inputbreak'" == "FALSE" {
        inputprompter, inputtype("author") inputprompt("Type name of author(s):")
        local inputbreak "`r(inputbreak)'"
        return local author "`r(verifiedinput)'"
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
      if "`inputtype'" == "packagename" {
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
