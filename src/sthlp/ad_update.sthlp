{smcl}
{* *! version 0.2 20240520}{...}
{hline}
{pstd}help file for {hi:ad_update}{p_end}
{hline}

{title:Title}

{phang}{bf:ad_update} - This command is used for short description.
{p_end}

{title:Syntax}

{phang}{bf:ad_update} , {bf:{ul:adf}older}({it:string}) {bf:{ul:pkg}name}({it:string}) [ {bf:{ul:newtit}le}({it:string}) {bf:{ul:newpkg}version}({c -(}{it:minor}/{it:major}{c )-}[,{it:samedayok}]) {bf:{ul:newsta}taversion}({it:stata} {it:version}) {bf:{ul:newaut}hor}({it:string}) {bf:{ul:newcon}tact}({it:string}) {bf:newurl}({it:string})]
{p_end}

{synoptset 50}{...}
{synopthdr:options}
{synoptline}
{synopt: {bf:{ul:adf}older}({it:string})}Location of the adodown-styled package{p_end}
{synopt: {bf:{ul:pkg}name}({it:string})}Name of package that exists in the location {inp:adfolder()} points to.{p_end}
{synopt: {bf:{ul:newtit}le}({it:string})}Update the title row shown in {inp:net describe <pkgname>}{p_end}
{synopt: {bf:{ul:newpkg}version}({c -(}{it:minor}/{it:major}{c )-}[,{it:samedayok}])}Increments the package version number with an {c 34}minor{c 34} (X.++X) or {c 34}major{c 34} (++X.X) increase{p_end}
{synopt: {bf:{ul:newsta}taversion}({it:stata} {it:version})}Update the version the Stata package targets{p_end}
{synopt: {bf:{ul:newaut}hor}({it:string})}Update the name of the author or authors of the package{p_end}
{synopt: {bf:{ul:newcon}tact}({it:string})}Update the contact information for support{p_end}
{synopt: {bf:newurl}({it:string})}Update the URL for this package{p_end}
{synoptline}

{phang}Read {browse "https://lsms-worldbank.github.io/adodown/reference/ad_update.html":this helpfile} in the {inp:adodown}{c 39}s package web-documentation where you also find articles with guides and best practices related to the commands in this package. 
{p_end}

{title:Description}

{pstd}Several other commands in the {inp:adodown} package reads meta data from the {inp:.pkg} file. 
Since the content of that file is read programmatically by those commands,
it is important that the format of that file is as those commands expect.
Therefore, that file should only be edited using this command {inp:ad_update}. 
{p_end}

{title:Options}

{pstd}{bf:{ul:adf}older}({it:string}) is used to indicate the location of where the adodown-styled package folder already exist.
{p_end}

{pstd}{bf:{ul:pkg}name}({it:string}) is the name of the package expected to be found in the {inp:adfolder()}. 
{p_end}

{pstd}{bf:{ul:newtit}le}({it:string}) updates the title row shown in, for example, {inp:ssc describe adodown}. This should be a short description of the package. The title will be the name of the package followed by a colon and then the content provided in this option. While not technically required, the practice is to start the title with the word module. Such as in {c 34}module to{c 34}, {c 34}module that generates{c 34} etc. See {inp:ssc describe} for packages you like for more examples. 
{p_end}

{pstd}{bf:{ul:newpkg}version}({c -(}{it:minor}/{it:major}{c )-}[,{it:samedayok}]) increments the package version number. This option takes either the string {it:minor} or the string {it:major}. A package version number is on the format X.X where the number before the decimal point indicates major version and the number after the decimal point indicates minor version. If using {it:major} in this option then the major version is incremented by 1 and the minor is reset to 0. If {it:minor} is used, then the major version is unchanged and the minor version is incremented by 1. When the package version is updated, then the package distribution date is also updated.
{p_end}

{pstd}After {it:minor}/{it:major} this option allows the sub-option {it:samedayok}. Without this sub-option, this command throws an error if the version is tried to be incremented a second time the same day. This is to prevent that the package version is updated multiple times if the command for whatever reason is run several times after each other.
{p_end}

{pstd}{bf:{ul:newsta}taversion}({it:stata} {it:version}) the package and each command needs to target a specific version. This makes sure that the commands will behave identical when used in the target version or any more recent version. The commands will not work in earlier versions of Stata than this target version. After updating this value, run {inp:ad_publish} and test all commands extensively. In the adodown workflow all commands in a package must target the same Stata version. 
{p_end}

{pstd}{bf:{ul:newaut}hor}({it:string}) updates the name of the author or authors of the package. This information will also be used in the version header for all ado-files in this package.
{p_end}

{pstd}{bf:{ul:newcon}tact}({it:string}) updates the contact information for the package. This information will also be used in the version header for all ado-files in this package.
{p_end}

{pstd}{bf:newurl}({it:string}) updates the URL listed for this package. Typically this is the GitHub repository used to develop this package. This should not be the web-documentation that {inp:adodown} can generate in GitHub pages, as {inp:adodown} use this information to link back to the repository from that web-documentation. 
{p_end}

{title:Examples}

{dlgtab:Example 1}

{pstd}This example assumes that there is already a adodown-styled package folder at the location the local {inp:myfolder} is pointing to. Then the title is update to {inp:{c 39}<pkgname>{c 39}: module to do great data work{c 34}}, the minor version is incremented by 1 and the Stata target version is set to 14.1. 
{p_end}

{input}{space 8}* point a local to the folder where the package is located
{space 8}local myfolder "path/to/folder"
{space 8}* Package meta info
{space 8}local pkg "my_package"
{space 8}
{space 8}* Add command mycmd to the package folder
{space 8}ad_update , adfolder("`myfolder'") pkg("`pkg'") /// 
{space 8}  newtitle("module to do great data work") newpkgversion(minor) newstataversion(14.1)
{text}
{title:Feedback, bug reports and contributions}

{pstd}Read more about the commands in this package on the {browse "https://github.com/lsms-worldbank/adodown":GitHub repository} for the {inp:adodown} package. 
{p_end}

{pstd}Please use the {browse "https://github.com/lsms-worldbank/adodown/issues":issues feature} e to communicate any feedback, report bugs, or to make feature requests.
{p_end}

{pstd}PRs with suggestions for improvements are also greatly appreciated.
{p_end}

{title:Authors}

{pstd}LSMS Team, The World Bank lsms@worldbank.org
{p_end}
