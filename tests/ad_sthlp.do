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
    local out_sthlp "`tests'/outputs/ad_sthlp"

    * Load the command directly from the ado file
    run "`clone'/ado/ad_command.ado"
    run "`clone'/ado/ad_setup.ado"
    run "`clone'/ado/ad_sthlp.ado"
    * Load utility functions that delete old test putput and set up folders
    run "`tests'/test_utils.do"
    
    * Set up the folders needed for ths
    local mvp_fldr "`out_sthlp'/test-mvp"
    qui rec_rmdir, folder("`mvp_fldr'") okifnotexist //Delete existing test results
    qui rec_mkdir, folder("`mvp_fldr'")              //Make sure folder exists
    
    * Setup needed to test sthlp
    ad_setup, folder("`mvp_fldr'") yesconfirm author("A") name("mypkg") description("d") url("u") contact("c")
    ad_command create mycmd1, folder("`mvp_fldr'") pkgname("mypkg")
    ad_command create mycmd2, folder("`mvp_fldr'") pkgname("mypkg")  
    ad_command create mycmd3, folder("`mvp_fldr'") pkgname("mypkg")
    
    ad_sthlp, folder("`mvp_fldr'")