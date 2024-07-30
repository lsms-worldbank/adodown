*! version 0.4 20240730 - LSMS Team, World Bank - lsms@worldbank.org

cap program drop   adodown
    program define adodown, rclass

qui {

    version 14.1

    * Do not manually edit these locals. They are updated with ad_publish in the adodown workflow
    local version "0.4" 
    local versionDate "20240730" 
    local cmd         "adodown"

  	syntax [anything]

    * Prepare returned locals
    return local versiondate   "`versionDate'"
    return local version		  = `version'

    if missing(`"`anything'"') {
      * Display output
      noi di ""
      local vtitle "This version of {inp:`cmd'} installed is version:"
      local btitle "This version of {inp:`cmd'} was released on:"
      local col2 = max(strlen("`vtitle'"),strlen("`btitle'"))
      noi di as text _col(4) "`vtitle'" _col(`col2')"`version'"
      noi di as text _col(4) "`btitle'" _col(`col2')"`versionDate'"
    }
    else {

      * Tokenize the subcommand and its potential options
      tokenize `anything'
      local subcmd "`1'"
      local subtwo "`2'"
      local subthree "`3'"
      local subfour "`4'"

      if ("`subcmd'" == "beta") {

        noi di _n "{hline}" _n
        noi di as text "{pstd}{ul:{red:Warning:} This command {inp:`subtwo'} is currently only released as a beta release}{p_end}" _n
        noi di as text `"{pstd}We're excited to introduce a beta release of the command {inp:`subtwo'}. Feedback from users like you will help us refine and finalize this command. We, especially during the beta phase, welcome bug reports, feature requests, and any other comments at: {browse "https://github.com/lsms-worldbank/adodown/issues"}.{p_end}"' _n
        noi di as text "{pstd}Please note that during the beta release we might rename or remove options without building in backward compatibility, and some still experimental features might not be fully documented.{p_end}" _n
        noi di _n "{hline}"
      }

      * Get standardized date
      else if ("`subcmd'" == "formatteddate") {
          local formatteddate: display %tdCCYYNNDD `= date("`c(current_date)'","DMY")'
          return local formatteddate "`formatteddate'"
      }


      * Valid verison
      else if ("`subcmd'" == "validstataversion") {
          return local valid_stata_versions "12 12.0 12.1 13 13.0 13.1 14 14.0 14.1 14.2 15 15.0 15.1 16.0 16.1 17.0 18.0"
      }



      else {
        noi di "{pstd}The sub-command [`subcmd'] used with `cmd' is not valid.{p_end}"
        error 99
        exit
      }
    }
}
end
