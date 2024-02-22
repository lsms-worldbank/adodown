{smcl}
{* *! version 0.1 20230724}{...}
{hline}
{pstd}help file for {hi:ad_publish}{p_end}
{hline}

{title:Title}

{phang}{bf:ad_publish} - This command is used for short description.
{p_end}

{title:Syntax}

{phang}{bf:ad_publish} , {bf:{ul:adf}older}({it:string}) [{bf:{ul:und}ocumented}({it:string}) {bf:ssczip} {bf:nogen_sthlp}]
{p_end}

{synoptset 20}{...}
{synopthdr:options}
{synoptline}
{synopt: {bf:{ul:adf}older}({it:string})}Location where package folder already exists{p_end}
{synopt: {bf:{ul:und}ocumented}({it:string})}List undocumented ado-files expected to not have a help-file{p_end}
{synopt: {bf:ssczip}}Generates a Zip-archive ready to send to SSC{p_end}
{synopt: {bf:nogen_sthlp}}Do not run {inp:ad_sthlp} on the package{p_end}
{synoptline}

{title:Description}

{pstd}This command is intended to be used when preparing a package for publication. Unless the option {inp:nogen_sthlp} is used, this command uses the command {inp:ad_sthlp()} (also in this {inp:adodown} package) to generates the {inp:.sthlp}-files from the {inp:.mdhlp}-files. 
{p_end}

{pstd}It then takes package version and Stata version from the {inp:.pkg}-file in this package, and applies that together with the current date to the version meta data and settings in the {inp:.ado}-files and the {inp:.sthlp}-files. 
{p_end}

{title:Options}

{pstd}{bf:{ul:adf}older}({it:string}) is used to indicate the location of where the adodown-styled package folder already exist.
{p_end}

{pstd}{bf:{ul:und}ocumented}({it:string}) lists commands that are undocumented. Undocumented commands are not expected to have an help-file. This command throws an error if an expected help-file is missing. Undocumented commands are typically commands for testing or commands used as a utility in other commands in this package.
{p_end}

{pstd}{bf:ssczip} generates a zip-archive ready to send to SSC. This zip-archive only include the ado-files, sthlp-files and ancillary files listed in the pkg-file. SSC require that all files are included without any subfolders, or any pkg-files or toc-files. 
{p_end}

{pstd}{bf:nogen_sthlp} disables the generation of {inp:.sthlp}-files from the {inp:.mdhlp}-files. If not used this command will run {inp:ad_sthlp()} on the package in {inp:adfolder()}. 
{p_end}

{title:example}

{dlgtab:Example 1}

{pstd}This example assumes that there is already a adodown-styled package folder at the location the local {inp:myfolder} is pointing to, and that some commands have already been created. Any mdhlp-files in the {inp:mdhlp} folder in the folder {inp:myfolder} is pointing to will be rendered to Stata helpfile format and saved in the {inp:sthlp} folder. Then the command will update the version meta data 
{p_end}

{input}{space 8}* point a local to the folder where the package will be created
{space 8}local myfolder "path/to/folder"
{space 8}
{space 8}* Render the Stata helpfiles
{space 8}ad_publish, adf("`myfolder'") 
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
