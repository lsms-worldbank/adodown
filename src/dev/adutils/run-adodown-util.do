  * Kristoffer's root path
  if "`c(username)'" == "wb462869" {
      global clone "C:/Users/wb462869/github/adodown"
  }

  * Set global to ado_fldr
  global src_fldr  "${clone}/src"
  global test_fldr "${src_fldr}/tests"

  * Install the version of this package in 
  * the plus-ado folder in the test folder
  repado , adopath("${test_fldr}/plus-ado/") mode(strict)
  cap net uninstall adodown
  net install adodown, from("${src_fldr}") replace


  //ad_command create adodown , adf("${clone}") pkg(adodown)


  ad_sthlp , adf("${clone}")
