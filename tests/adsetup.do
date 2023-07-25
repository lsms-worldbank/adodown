    * KB root path
    if c(username) == "wb462869" {
        local clone "C:\Users\wb462869\github\adodown"
    }

    * AS root path
    if c(username) == "<computer username>" {
        local clone "<clone file path>"
    }


    * Folder paths
    local ado   "`clone'/ado"
    local tests "`clone'/tests"
    local adsetup_out "`tests'/outputs/adosetup"

    * Load the command directly from the ado file
    run "`clone'/ado/adsetup.ado"
    * Load utility functions that delete old test putput and set up folders
    run "`tests'/test_utils.do"

    *********
    * Test 1 - passing all package meta information in options

    * Set up the folders needed for ths
    local test1_fldr "`adsetup_out'/test1-options"
    ie_recurse_rmdir, folder("`test1_fldr'") okifnotexist //Delete existing test results
    ie_recurse_mkdir, folder("`test1_fldr'")              //Make sure folder exists

    * Run adsetup with all required info specified in options
    adsetup, folder("`test1_fldr'") yesconfirm ///
        author("John Doe")  ///
        name("myprog1")  ///
        description("My awesome Stata tool")  ///
        url("https://github.com/worldbank-lsms/adodown") ///
        contact("jdoe@worldbank.org")


    *********
    * Test 2 - manually enter all package meta information

    * Set up the folders needed for ths
    local test2_fldr "`adsetup_out'/test2-manual"
    ie_recurse_rmdir, folder("`test2_fldr'") okifnotexist //Delete existing test results
    ie_recurse_mkdir, folder("`test2_fldr'")              //Make sure folder exists

    * Run adsetup with all required info specified in options
    adsetup, folder("`test2_fldr'")
