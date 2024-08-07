{smcl}
{* *! version 0.4 20240730}{...}
{hline}
{pstd}help file for {hi:ad_sthlp}{p_end}
{hline}

{title:Title}

{phang}{bf:ad_sthlp} - Converts mdhlp-files to sthlp-files in the {inp:adodown} workflow. 
{p_end}

{title:Syntax}

{phang}{bf:ad_sthlp} , {bf:{ul:adf}older}({it:string}) [{bf:commands}({it:string}) {bf:nopkgmeta}]
{p_end}

{synoptset 16}{...}
{p2coldent:{it:options}}Description{p_end}
{synoptline}
{synopt: {bf:{ul:adf}older}({it:string})}Location of the adodown-styled package{p_end}
{synopt: {bf:commands}({it:string})}List specific command to convert. Default is all in package{p_end}
{synopt: {bf:nopkgmeta}}Do not look for a {inp:.pkg} file for package metadata{p_end}
{synoptline}

{phang}Read the {inp:adodown} package{c 39}s {browse "https://lsms-worldbank.github.io/adodown/":web-documentation} where you find all helpfiles for the commands in this package, as well as articles with guides and best-practices related to the commands in this package. 
{p_end}

{title:Description}

{pstd}This command renders Stata helpfiles in the {inp:.sthlp} format 
written in the {inp:mdhlp}-files written in markdown. 
The {inp:sthlp}-files are then intended to be included instead 
of the {inp:mdhlp}-files when distributing the command using 
either {inp:ssc install} or {inp:net install}. 
{p_end}

{pstd}In the {inp:adodown} workflow the {inp:mdhlp}-files are expected to be stored in a folder {inp:mdhlp} in the folder that {bf:{ul:adf}older}({it:string}) points to, and the {inp:sthlp}-files are expected to be written to a folder {inp:sthlp} in the same location. If the package folder was set up using {inp:ad_setup} and the commands were added to the package folder using {inp:ad_command}, then this is already the case. 
{p_end}

{pstd}See {browse "https://lsms-worldbank.github.io/adodown/articles/mdhlp-syntax.html":this article} about valid syntax in the {inp:mdhlp} files. 
{p_end}

{title:Options}

{pstd}{bf:{ul:adf}older}({it:string}) is used to indicate the location of where the adodown-styled package folder already exist.
{p_end}

{pstd}{bf:commands}({it:string}) is used to list individual commands to convert from {inp:mdhlp} to {inp:sthlp}. One or several commands can be listed. The default when this option is not used is to convert all {inp:mdhlp} files in the mdhlp folder to sthlp-files. 
{p_end}

{pstd}{bf:nopkgmeta} tells the command to not look for a {inp:.pkg} file for version number and version date. 
The default is that the header of the {inp:.sthlp} file is populated from the meta information in the {inp:.pkg} file. 
This option allows this command to be used for {inp:.mdhlp} files not part of an {inp:adodown} styled package. 
If this option is used, the string {it:NOPKGMETA} is used as both version number and version date in the header.
{p_end}

{title:Examples}

{dlgtab:Example 1}

{pstd}This example assumes that there is already a adodown-styled package folder at the location the local {inp:myfolder} is pointing to, and that some commands have already been created. Any mdhlp-files in the {inp:mdhlp} folder in the folder {inp:myfolder} is pointing to will be rendered to Stata helpfile format and saved in the {inp:sthlp} folder. 
{p_end}

{input}{space 8}* point a local to the folder where the package is located
{space 8}local myfolder "path/to/folder"
{space 8}
{space 8}* Render the Stata helpfiles
{space 8}ad_sthlp, adf("`myfolder'") 
{text}
{dlgtab:Example 2}

{pstd}This example includes the steps for how to create the adodown-styled package folder in the location the local {inp:myfolder} is pointing to, creating some commands and then render the template mdhlp-files to Stata helpfiles. 
{p_end}

{input}{space 8}* point a local to the folder where the package is located
{space 8}local myfolder "path/to/folder"
{space 8}
{space 8}* Package meta info
{space 8}local pkg "my_package"
{space 8}local aut "John Doe"
{space 8}local des "This packages does amazing thing A, B and C."
{space 8}local url "https://github.com/lsms-worldbank/adodown"
{space 8}local con "jdoe@worldbank.org"
{space 8}
{space 8}* Set up adodown-styled package folder
{space 8}ad_setup, adfolder("`myfolder'") autoconfirm    /// 
{space 8}     name("`pkg'") author("`aut'") desc("`des'") /// 
{space 8}     url("`url'") contact("`con'") 
{space 8}
{space 8}* Add command mycmd to the package folder
{space 8}ad_command create mycmd1, adf("`myfolder'") pkg("`pkg'") 
{space 8}ad_command create mycmd2, adf("`myfolder'") pkg("`pkg'") 
{space 8}
{space 8}* Render the Stata helpfiles
{space 8}ad_sthlp, adf("`myfolder'") 
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
