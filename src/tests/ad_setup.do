    * KB root path
    if c(username) == "wb462869" {
        local clone "C:\Users\wb462869\github\adodown"
    }

    * AS root path
    if c(username) == "<computer username>" {
        local clone "<clone file path>"
    }


    * Folder paths
    local ado          "`clone'/src/ado"
    local tests        "`clone'/src/tests"
    local ad_setup_out "`tests'/outputs/ad_setup"

    * Load the command directly from the ado file
    run "`ado'/ad_setup.ado"
    run "`ado'/ad_command.ado"
    * Load utility functions that delete old test putput and set up folders
    run "`tests'/test_utils.do"

    *********
    * Test 1 - passing all package meta information in options

    * Set up the folders needed for ths
    local test1_fldr "`ad_setup_out'/test1-options"
    rec_rmdir, folder("`test1_fldr'") okifnotexist //Delete existing test results
    rec_mkdir, folder("`test1_fldr'")              //Make sure folder exists

    * Run ad_setup with all required info specified in options
    ad_setup, adfolder("`test1_fldr'") autoconfirm debug ///
        author("John Doe")  ///
        name("myprog1")  ///
        description("My awesome Stata tool")  ///
        url("https://github.com/worldbank-lsms/adodown") ///
        contact("jdoe@worldbank.org")


    *********
    * Test 2 - manually enter all package meta information
    *Change to if 1 to run this section
        if 0 {
        * Set up the folders needed for ths
        local test2_fldr "`ad_setup_out'/test2-manual"
        rec_rmdir, folder("`test2_fldr'") okifnotexist //Delete existing test results
        rec_mkdir, folder("`test2_fldr'")              //Make sure folder exists
        * Run ad_setup with all required info specified in options
        ad_setup, adfolder("`test2_fldr'")
    }

