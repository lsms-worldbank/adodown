  
  * Set root globals
  reproot, project("adodown") roots("clone") prefix("adwn_")
  local srcfldr "${adwn_clone}/src"
  local testfldr "`srcfldr'/tests"


  * Set up a dev environement for testing locally
  repado , adopath("`testfldr'/dev-env/") mode(strict)
  cap net uninstall adodown
  net install adodown, from("`srcfldr'") replace

  //ad_update , adf("${adwn_clone}") pkg("adodown") newpkgversion(minor)
  
  ad_sthlp , adf("${adwn_clone}") //pkg("adodown") 
    
 // ad_publish, adf("${adwn_clone}") undocumented(ad_pkg_meta) ssczip
