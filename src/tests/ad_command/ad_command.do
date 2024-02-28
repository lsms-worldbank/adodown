    ************************
    * Set up root paths if not already set, and set up dev environment

    version 14.1

    reproot, project("adodown") roots("clone") prefix("adwn_")
    global testfldr "${adwn_clone}/src/tests"

    * Install the version of this package in
    * the plus-ado folder in the test folder
    cap mkdir    "${testfldr}/dev-env"
    repado using "${testfldr}/dev-env"

    cap net uninstall adodown
    net install adodown, from("${adwn_clone}/src") replace

    ************************
    * Set up command specific test folders and resources

    * Load utility functions that delete old test putput and set up folders
    run "${testfldr}/test_utils.do"

    * Command specific test outputs
    local out_command "${testfldr}/outputs/ad_command"

    * Clean up and recreate the test output folders
    local mvp_fldr "`out_command'/test-mvp"
    qui rec_rmdir, folder("`mvp_fldr'") okifnotexist //Delete existing test results
    qui rec_mkdir, folder("`mvp_fldr'")              //Make sure folder exists

    ************************
    * Run tests

    * Set up a test project
    ad_setup, adfolder("`mvp_fldr'") autoprompt ///
        author("A") name("my_mvp_pkg") ///
        description("d") url("u")  ///
        contact("c") github

    * Test the ad_command command
    ad_command create mycmd1, adfolder("`mvp_fldr'") pkgname("my_mvp_pkg")
    ad_command create mycmd2, adfolder("`mvp_fldr'") pkgname("my_mvp_pkg")
    ad_command remove mycmd1, adfolder("`mvp_fldr'") pkgname("my_mvp_pkg")
    ad_command create mycmd3, adfolder("`mvp_fldr'") pkgname("my_mvp_pkg")
