    ************************
    * Set up root paths if not already set, and set up dev environment

    version 14.1

    reproot, project("adodown") roots("clone") prefix("adwn_")
    local testfldr "${adwn_clone}/src/tests"

    * Install the version of this package in
    * the plus-ado folder in the test folder
    cap mkdir    "`testfldr'/dev-env"
    repado using "`testfldr'/dev-env"

    cap net uninstall adodown
    net install adodown, from("${adwn_clone}/src") replace

    ************************
    * Run tests

    * Folder paths
    local out_sthlp "`testfldr'/ad_sthlp/outputs"

    * Set up the folders needed for ths
    local test_all_syntax "`out_sthlp'/test-all-syntax"

    * Test rendering files
    ad_sthlp, adf("`test_all_syntax'")
    
