    * KB root path
    if c(username) == "wb462869" {
        local clone "C:\Users\wb462869\github\adodown"
    }

    * AS root path
    if c(username) == "<computer username>" {
        local clone "<clone file path>"
    }

    * Folder paths
    local tests        "`clone'/src/tests"
    local ad_setup_out "`tests'/outputs/ad_setup"

    * Install the package
    qui ieboilstart, version(14) adopath("`clone'\src\tests\installation", strict)
    net uninstall adodown 
    net install   adodown , from("`clone'\src")

    * Load utility functions that delete old test putput and set up folders
    run "`tests'/test_utils.do"

    rec_rmdir, folder("`ad_setup_out'") okifnotexist //Delete existing test results
    rec_mkdir, folder("`ad_setup_out'")              //Make sure folder exists

    *********
    * Test 1 - passing all package meta information in options

    * Set up the folders needed for ths
    local test1_fldr "`ad_setup_out'/test1-options"
    rec_mkdir, folder("`test1_fldr'")              //Make sure folder exists

    * Run ad_setup with all required info specified in options
    ad_setup, adfolder("`test1_fldr'") autoprompt debug ///
        author("John Doe")  ///
        name("myprog1")  ///
        description("My awesome Stata tool")  ///
        url("https://github.com/worldbank-lsms/adodown") ///
        contact("jdoe@worldbank.org") github

    *********
    * Test 2 - manually enter all package meta information
    *Set up the folders needed for ths
    local test2_fldr "`ad_setup_out'/test2-autoprompt"
    rec_mkdir, folder("`test2_fldr'")              //Make sure folder exists

    * Run ad_setup with all required info specified in options
    ad_setup, adfolder("`test2_fldr'") autoprompt name("testautoprompt") 
        
        
    *********
    * Test 3 - manually enter all package meta information
    *Change to if 1 to run this section
        if 0 {
        * Set up the folders needed for ths
        local test3_fldr "`ad_setup_out'/test3-manual"
        rec_mkdir, folder("`test3_fldr'")              //Make sure folder exists
        
        * Run ad_setup with all required info specified in options
        ad_setup, adfolder("`test3_fldr'") author("KB") contact("kbjarlefur@asdfd.sda")
    }
