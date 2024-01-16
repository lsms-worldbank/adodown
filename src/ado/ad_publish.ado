*! version XX XXXXXXXXX ADAUTHORNAME ASCONTACTINFO

cap program drop   ad_publish
    program define ad_publish

    * Update the syntax. This is only a placeholder to make the command run
    syntax, ADFolder(string) pkgversion(string) undoc_cmds(string) [debug]

    ****
    ** Test folder input input

    * Standardize folder
    local folderstd	= subinstr(`"`adfolder'"',"\","/",.)
    local srcfolder	= `"`adfolder'/src"'
    local adofolder	= `"`srcfolder'/ado"'
    local sthfolder	= `"`srcfolder'/sthlp"'

    * Test for adodown folders expected in the folder
    foreach ad_fld in folderstd srcfolder adofolder sthfolder {
      mata : st_numscalar("r(dirExist)", direxists("``ad_fld''"))
      if `r(dirExist)' == 0  {
        local folder_error "TRUE"
        local missing_flds `"`missing_flds' "``ad_fld''" "'
      }
    }
    * Output errors and list missing folders
    if ("`folder_error'" == "TRUE") {
      noi di as error "{pstd}The folder in option {inp:adfolder()} is not valid adodown folder. The following folders were expected but not found:{p_end}"
      foreach miss_fold of local missing_flds {
        noi di as text `"{pstd}- `miss_fold'/{p_end}"'
      }
      error 99
      exit
    }

    ****
    ** Test and initiate folder locals

    local date

    * test version number



    ****
    ** List all ado-files and helpfiles to make sure required files exists

    * List ado-files
    local adofiles : dir `"`adofolder'"' files "*.ado"	, respectcase
    foreach adofile of local adofiles {
      local cmds "`cmds'" + subinstr("`adofile'",".ado","",1)
    }

    * List sthlp files
    local sthfiles : dir `"`sthfolder'"' files "*.sthlp"	, respectcase
    foreach sthfile of local sthfiles {
      local hlps "`hlps'" + subinstr("`sthfile'",".sthlp","",1)
    }


    * List docummented commands - i.e. ado files apart from undocummented files
    * These are the commands that we expect a helpfile for
    local doc_cmds : cmds - undoc_cmds

    * Get local with for docummented commands without helpfule and
    * helpfiles without documented commands
    local doc_cmds_without_hlp : cmds - hlps
    local hlps_without_doc_cmd : hlps - cmds

    * Test if any commands listed as undocummented commmands are not found
    local undoc_cmds_not_found : undoc_cmds - cmds

    local ado_sthlp_error 0

    * List if there are any commands listed as undoccumented not found
    if !missing("`miss_undoc_cmds'") {
      noi di as error "{pstd}The commands {inp:`miss_undoc_cmds'} listed as undocummented commands were not found in the ado folder {inp:`adofolder'}.{p_end}"
      local ado_sthlp_error 1
    }

    * List if there are any commands listed as undoccumented not found
    if !missing("`doc_cmds_without_hlp'") {
      noi di as error "{pstd}The command(s) {inp:`doc_cmds_without_hlp'} in the {inp:`adofolder'} folder does not have any help-file(s) in the {inp:`sthfolder'} folder.{p_end}"
      local ado_sthlp_error 1
    }

    * List if there are any commands listed as undoccumented not found
    if !missing("`hlps_without_doc_cmd'") {
      noi di as error "{pstd}The help-file(s) {inp:`hlps_without_doc_cmd'} in the {inp:`sthfolder'} folder does not have any command(s) in the {inp:`adofolder'} folder.{p_end}"
      local ado_sthlp_error 1
    }

    * Throw error for missing files
    if ("`ado_sthlp_error'" == 1) {
      error 99
      exit
    }


    ****
    ** List all sthlp files


    *Make sure that all commands
    local miss_docs : doc_cmds - sthfiles


    //TODO : implement command here


    // Remove when command is no longer in beta
    noi adodown "beta ad_publish"
end
