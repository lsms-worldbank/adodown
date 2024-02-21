  * Kristoffer's root path
  if "`c(username)'" == "wb462869" {
      global clone "C:/Users/wb462869/github/adodown"
  }

  * Set global to ado_fldr
  global src_fldr  "${clone}/src"
  global test_fldr "${src_fldr}/tests"

  * Set up a dev environement for testing locally
  repado , adopath("${test_fldr}/dev-env/") mode(strict)
  cap net uninstall adodown
  net install adodown, from("${src_fldr}") replace

  ad_publish, adf("${clone}") undocumented(ad_pkg_meta) ssczip
