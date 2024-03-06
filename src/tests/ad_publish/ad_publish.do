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

    local pkg "test1"
    local ad_publish_out "`testfldr'/ad_publish/outputs"
    local pkg_fldr "`ad_publish_out'/test1"

    * Reset the folder
    if 1 {
      rec_rmdir, folder("`ad_publish_out'") okifnotexist
      rec_mkdir, folder("`pkg_fldr'")
      //Set up test project
      ad_setup, adfolder("`pkg_fldr'") autoprompt name("`pkg'") author("Krikkan")
      ad_command create mycmd1, adf("`pkg_fldr'") pkg("`pkg'")
      ad_command create mycmd2, adf("`pkg_fldr'") pkg("`pkg'")
      ad_command create mycmd3, adf("`pkg_fldr'") pkg("`pkg'")
    }

    * Test basic case of the command ad_get_pkg_meta
    ad_publish, adf("`pkg_fldr'") ssczip
    return list

