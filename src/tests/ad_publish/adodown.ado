*! version 0.1 20230724 LSMS Team, World Bank lsms@worldbank.org

cap program drop   adodown
    program define adodown, rclass

    version 13.0

    * UPDATE THESE LOCALS FOR EACH NEW VERSION PUBLISHED
  	local version "1.0"
  	local versionDate "05NOV2023"
    local cmd    "adodown"

  	syntax [anything]

  	version 12

    * Prepare returned locals
    return local versiondate     "`versionDate'"
    return local version		      = `version'

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

      * Replace placeholder for code block
      local line : subinstr local line "```" "%%%CODEBLOCK%%%", count(local has_CODEBLOCK)
    }
end
