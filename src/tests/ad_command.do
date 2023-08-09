   * KB root path
    if c(username) == "wb462869" {
        local clone "C:\Users\wb462869\github\adodown"
    }

    * AS root path
    if c(username) == "<computer username>" {
        local clone "<clone file path>"
    }

    * Folder paths
    local ado         "`clone'/src/ado"
    local tests       "`clone'/src/tests"
    local out_command "`tests'/outputs/ad_command"

    * Load the command directly from the ado file
    run "`ado'/ad_command.ado"
    run "`ado'/ad_setup.ado"
    * Load utility functions that delete old test putput and set up folders
    run "`tests'/test_utils.do"

    * Set up the folders needed for ths
    local mvp_fldr "`out_command'/test-mvp"
    qui rec_rmdir, folder("`mvp_fldr'") okifnotexist //Delete existing test results
    qui rec_mkdir, folder("`mvp_fldr'")              //Make sure folder exists

    ad_setup, adfolder("`mvp_fldr'") autoconfirm ///
        author("A") name("my_mvp_pkg") ///
        description("d") url("u")  ///
        contact("c")

    ad_command create mycmd1, adfolder("`mvp_fldr'") pkgname("my_mvp_pkg")
    ad_command create mycmd2, adfolder("`mvp_fldr'") pkgname("my_mvp_pkg")
    ad_command remove mycmd1, adfolder("`mvp_fldr'") pkgname("my_mvp_pkg")
    ad_command create mycmd3, adfolder("`mvp_fldr'") pkgname("my_mvp_pkg")
