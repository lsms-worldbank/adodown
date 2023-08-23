{smcl}
{* 01 Jan 1960}{...}
{hline}
{pstd}help file for {hi:ad_command}{p_end}
{hline}

{title:Title}

{phang}{bf:ad_command} - Creates or removes commands in the {inp:adodown} workflow.
{p_end}

{title:Syntax}

{phang}{bf:ad_command} {it:subcommand} {it:commandname} , {bf:{ul:adf}older}({it:string}) {bf:{ul:pkg}name}({it:string})
{p_end}

{phang}where {it:subcommand} is either {inp:create} or {inp:remove} and {it:commandname} is the name of the new command to create or the existing command to remove.
{p_end}

{synoptset 16}{...}
{synopthdr:options}
{synoptline}
{synopt: {bf:{ul:adf}older}({it:string})}Location where package folder already exists{p_end}
{synopt: {bf:{ul:pkg}name}({it:string})}Name of package that exists in the location {inp:adfolder()} points to.{p_end}
{synoptline}

{title:Description}

{pstd}This command is only intended to be used in package folders set up in the {inp:adodown} workflow using the command {inp:ad_setup}.
{p_end}

{pstd}This command creates new commands in the package or removes existing commands from it. When creating a command, a template for the ado-file is created in the ado folder, a template for the mdhlp-file is created in the mdhlp folder,
and the ado-file and the sthlp file is addended to the pkg-file in that package folder.
{p_end}

{pstd}Note that the using {inp:net install} will not work immediately after creating a command with this file as the pkg-file points to the sthlp-file that is not yet rendered. Use the command {inp:ad_sthlp} to render that command.
{p_end}

{title:Options}

{pstd}{it:subcommand} as specified in {inp:ad_command <subcommand> <commandname>} can either be {inp:create} or {inp:remove}. {inp:create} is used when creating a new command and {inp:remove} when removing and existing command.
{p_end}

{pstd}{it:commandname} as specified in {inp:ad_command <subcommand> <commandname>} is the name of the command to be created or removed. If a command is created then an error is thrown if the name is already used by an existing command, and an error will be thrown when removing a command if the name is not used by any existing commands.
{p_end}

{pstd}{bf:{ul:adf}older}({it:string}) is used to indicate the location of where the adodown-styled package folder already exist.
{p_end}

{pstd}{bf:{ul:pkg}name}({it:string}) is the name of the package expected to be found in the {inp:adfolder()}.
{p_end}

{title:Examples}

{dlgtab:Example 1}

{pstd}This example assumes that there is already a adodown-styled package folder at the location the local {inp:myfolder} is pointing to.
{p_end}

{input}{space 8}* point a local to the folder where the package will be created
{space 8}local myfolder "path/to/folder"

{space 8}* Package meta info
{space 8}local pkg "my_package"

{space 8}* Add command mycmd to the package folder
{space 8}ad_command create mycmd, adf("") pkg("")
{text}
{dlgtab:Example 2}

{pstd}This example includes the steps for how to create the adodown-styled package folder in the location the local {inp:myfolder} is pointing to.
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
{space 8}ad_command create mycmd, adf("") pkg("")
{text}
{title:Feedback, bug reports and contributions}

{pstd}Please use the {browse "https://github.com/lsms-worldbank/adodown/issues":issues feature} on the GitHub repository for the {inp:adodown} package to communicate any feedback, report bugs, or to make feature requests.
{p_end}

{title:Authors}

{pstd}* Author: John Doe
* Support: jdoe@worldbank.org
{p_end}
