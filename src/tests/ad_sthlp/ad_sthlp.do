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
    * Run tests

    * Folder paths
    local out_sthlp "${testfldr}/ad_sthlp/outputs"

    * Load utility functions that delete old test putput and set up folders
    run "${testfldr}/test_utils.do"

    * Set up the folders needed for ths
    local mvp_f "`out_sthlp'/test-mvp"
    qui rec_rmdir, folder("`mvp_f'") okifnotexist //Delete existing test results
    qui rec_mkdir, folder("`mvp_f'")              //Make sure folder exists

    * Package meta info
    local pkg "my_mvp_pkg"
    local aut "John Doe"
    local des "This packages does amazing thing A, B and C."
    local url "https://github.com/lsms-worldbank/adodown"
    local con "jdoe@worldbank.org"

    *set up folder
    ad_setup, adf("`mvp_f'") autoprompt ///
        a("`aut'") n("`pkg'") d("`des'") u("`url'") c("`con'")
    ad_command create mycmd1, adf("`mvp_f'") pkg("`pkg'")
    ad_command create mycmd2, adf("`mvp_f'") pkg("`pkg'")
    ad_command create mycmd3, adf("`mvp_f'") pkg("`pkg'")

    * Test rendering files
    ad_sthlp, adf("`mvp_f'") nopkgmeta
    ad_sthlp, adf("`mvp_f'")
