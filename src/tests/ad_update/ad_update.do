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

    local name "mvp1"
    local ad_update_out "`testfldr'/ad_update/outputs"
    local mvp1_fldr "`ad_update_out'/mvp1"

    * Reset the folder
    if (1) {
      rec_rmdir, folder("`ad_update_out'") okifnotexist
      rec_mkdir, folder("`mvp1_fldr'")
      //Set up test project
      ad_setup, adfolder("`mvp1_fldr'") autoprompt name("`name'") author("Krikkan")
    }


    * Test basic case of the command ad_update
    ad_update, adfolder("`mvp1_fldr'") pkgname("`name'") newtitle("test title")

    ad_update, adfolder("`mvp1_fldr'") pkgname("`name'") newcontact("krik@kan.com")

    ad_update, adfolder("`mvp1_fldr'") pkgname("`name'") newpkgversion("minor, samedayok")

    ad_update, adfolder("`mvp1_fldr'") pkgname("`name'") newpkgversion("minor, samedayok")

    ad_update, adfolder("`mvp1_fldr'") pkgname("`name'") newpkgversion("major, samedayok")

    ad_update, adfolder("`mvp1_fldr'") pkgname("`name'") newpkgversion("minor, samedayok")    
