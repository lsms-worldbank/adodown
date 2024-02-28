
    cap which repkit
    if _rc == 111 {
        di as error `"{pstd}This test file use features from the package {browse "https://dime-worldbank.github.io/repkit/":repkit}. Click {stata ssc install repkit} to install it and run this file again.{p_end}"'
    }

    *************************************
    * Set root path
    * TODO: Update with reprun once published

    di "Your username: `c(username)'"
    * Set each user's root path
    if "`c(username)'" == "wb462869" {
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

    * Install the latest version of adodown to the dev environment
    cap net uninstall adodown
    net install adodown, from("${src}") replace
    
    local pkg "test1"
    local ad_publish_out "${tests}/outputs/ad_publish"
    local test_fldr "`ad_publish_out'/test1"
    
    * Reset the folder
    if 1 {
      rec_rmdir, folder("`ad_publish_out'") okifnotexist
      rec_mkdir, folder("`test_fldr'")
      //Set up test project
      ad_setup, adfolder("`test_fldr'") autoprompt name("`pkg'") author("Krikkan") 
      ad_command create mycmd1, adf("`test_fldr'") pkg("`pkg'")
      ad_command create mycmd2, adf("`test_fldr'") pkg("`pkg'")
      ad_command create mycmd3, adf("`test_fldr'") pkg("`pkg'")
    }

    * Test basic case of the command ad_get_pkg_meta
    ad_publish, adf("`test_fldr'") ssczip
    return list
    // Add more tests here...
