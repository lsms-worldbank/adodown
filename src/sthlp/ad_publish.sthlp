{smcl}
{* 01 Jan 1960}{...}
{hline}
{pstd}help file for {hi:ad_sthlp}{p_end}
{hline}

{title:Title}

{phang}{bf:ad_sthlp} - Renders sthlp-files from mdhlp-files in the {inp:adodown} workflow.
{p_end}

{title:Syntax}

{phang}{bf:ad_sthlp} , {bf:{ul:adf}older}({it:string})
{p_end}

{synoptset 16}{...}
{synopthdr:options}
{synoptline}
{synopt: {bf:{ul:adf}older}({it:string})}Location where package folder already exists{p_end}
{synoptline}

{title:Description}

{pstd}This command renders Stata helpfiles in the {inp:.sthlp} format
written in the mdhlp-files written in markdown.
The sthlp-files are then intended to be included instead
of the mdhlp-files when distributing the command using
either {inp:ssc install} or {inp:net install}.
{p_end}

{pstd}In the {inp:adodown} workflow the mdhlp-files are expected to be stored in a folder {inp:mdhlp} in the folder that {bf:{ul:adf}older}({it:string}) points to, and the sthlp-files are expected to be written to a folder {inp:sthlp} in the same location. If the package folder was set up using {inp:ad_setup} and the commands were added to the package folder using {inp:ad_command}, then this is already the case.
{p_end}

{title:Options}

{pstd}{bf:{ul:adf}older}({it:string}) is used to indicate the location of where the adodown-styled package folder already exist.
{p_end}

{title:Examples}

{dlgtab:Example 1}

{pstd}This example assumes that there is already a adodown-styled package folder at the location the local {inp:myfolder} is pointing to, and that some commands have already been created. Any mdhlp-files in the {inp:mdhlp} folder in the folder {inp:myfolder} is pointing to will be rendered to Stata helpfile format and saved in the {inp:sthlp} folder.
{p_end}

{input}{space 8}* point a local to the folder where the package will be created
{space 8}local myfolder "path/to/folder"

{space 8}* Render the Stata helpfiles
{space 8}ad_sthlp, adf("")
{text}
{dlgtab:Example 2}

{pstd}This example includes the steps for how to create the adodown-styled package folder in the location the local {inp:myfolder} is pointing to, creating some commands and then render the template mdhlp-files to Stata helpfiles.
{p_end}

{input}{space 8}* point a local to the folder where the package will be created
{space 8}local myfolder "path/to/folder"

{space 8}* Package meta info
{space 8}local pkg "my_package"
{space 8}local aut "John Doe"
{space 8}local des "This packages does amazing thing A, B and C."
{space 8}local url "https://github.com/lsms-worldbank/adodown"
{space 8}local con "jdoe@worldbank.org"

{space 8}* Set up adodown-styled package folder
{space 8}ad_setup, adfolder("") autoconfirm    ///
{space 8}     name("") author("") desc("") ///
{space 8}     url("") contact("")

{space 8}* Add command mycmd to the package folder
{space 8}ad_command create mycmd1, adf("") pkg("")
{space 8}ad_command create mycmd2, adf("") pkg("")

{space 8}* Render the Stata helpfiles
{space 8}ad_sthlp, adf("")
{text}
{title:Feedback, bug reports and contributions}

{pstd}Please use the {browse "https://github.com/lsms-worldbank/adodown/issues":issues feature} on the GitHub repository for the {inp:adodown} package to communicate any feedback, report bugs, or to make feature requests.
{p_end}

{title:Authors}

{pstd}Author: John Doe
Support: jdoe@worldbank.org
{p_end}
