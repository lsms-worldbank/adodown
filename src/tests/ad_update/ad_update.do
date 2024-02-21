
    cap which repkit
    if _rc == 111 {
        di as error `"{pstd}This test file use features from the package {browse "https://dime-worldbank.github.io/repkit/":repkit}. Click {stata ssc install repkit} to install it and run this file again.{p_end}"'
    }

    *************************************
    * Set root path
    * TODO: Update with reprun once published

    di "Your username: `c(username)'"
    * Set each user's root path
    if "`c(username)'" == "`c(username)'" {
        global root "C:/Users/wb462869/github/adodown"
    }
    * Set all other user's root paths on this format
    if "`c(username)'" == "" {
        global root ""
    }

    * Set global to the test folder
    global src   "${root}/src"
    global tests "${src}/tests"

    * Set up a dev environement for testing locally
    cap mkdir    "${tests}/dev-env"
    repado using "${tests}/dev-env"

    * If not already installed in dev-env, add repkit to the dev environment
    cap which repkit
    if _rc == 111 ssc install repkit

    /* TODO: Uncomment once adodown is published
    * If not already installed, add adodown to the dev environment
    cap which adodown
    if _rc == 111 ssc install adodown
    */

    * Install the latest version of adodown to the dev environment
    cap net uninstall adodown
    net install adodown, from("${src}") replace

    local name "test1"
    local ad_update_out "${tests}/outputs/ad_update"
    local test_fldr "`ad_update_out'/test1"
    
    * Reset the folder
    if 1 {
      rec_rmdir, folder("`ad_update_out'") okifnotexist
      rec_mkdir, folder("`test_fldr'")
      //Set up test project
      ad_setup, adfolder("`test_fldr'") autoprompt name("`name'") author("Krikkan") 
    }

    
  * Test basic case of the command ad_update
  ad_update, adfolder("`test_fldr'") pkgname("`name'") newtitle("test title")
    
  ad_update, adfolder("`test_fldr'") pkgname("`name'") newcontact("krik@kan.com")
    
  ad_update, adfolder("`test_fldr'") pkgname("`name'") newpkgversion("minor, samedayok")
    
  ad_update, adfolder("`test_fldr'") pkgname("`name'") newpkgversion("minor, samedayok")
    
  ad_update, adfolder("`test_fldr'") pkgname("`name'") newpkgversion("major, samedayok")

  ad_update, adfolder("`test_fldr'") pkgname("`name'") newpkgversion("minor, samedayok")    // Add more tests here...
