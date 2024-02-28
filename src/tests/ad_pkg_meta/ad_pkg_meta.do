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

    * Test basic case of the command ad_pkg_meta
    ad_pkg_meta, adf("${adwn_clone}/src)
    return list
