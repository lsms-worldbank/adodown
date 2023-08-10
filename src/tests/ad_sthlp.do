   * KB root path
    if c(username) == "wb462869" {
        local clone "C:\Users\wb462869\github\adodown"
    }

    * AS root path
    if c(username) == "<computer username>" {
        local clone "<clone file path>"
    }

    * Folder paths
    local ado       "`clone'/src/ado"
    local tests     "`clone'/src/tests"
    local out_sthlp "`tests'/outputs/ad_sthlp"

    * Load the command directly from the ado file
    run "`ado'/ad_command.ado"
    run "`ado'/ad_setup.ado"
    run "`ado'/ad_sthlp.ado"
    * Load utility functions that delete old test putput and set up folders
    run "`tests'/test_utils.do"
    
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
    ad_setup, adf("`mvp_f'") autocon ///
        a("`aut'") n("`pkg'") d("`des'") u("`url'") c("`con'")
    ad_command create mycmd1, adf("`mvp_f'") pkg("`pkg'")
    ad_command create mycmd2, adf("`mvp_f'") pkg("`pkg'")  
    ad_command create mycmd3, adf("`mvp_f'") pkg("`pkg'")
    
    * Test rendering files
    ad_sthlp, adf("`mvp_f'")
    
    
  
    