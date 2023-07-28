{smcl}
{title:Title}

{p 4 4 2}
{bf:ad_command} - Creates or removes commands in the adodown workflow.

{title:Syntax}

{p 4 4 2}
{bf:ad_command} {it:subcommand} {it:commandname} , {ul:adf}older({it:string}) {ul:pkg}name({it:string})

{p 4 4 2}
where {it:subcommand} is either {c 96}create{c 96} or {c 96}remove{c 96} and {it:commandname} is the name of the new command to create or the existing command to remove.

{col 5}{it:options}{col 23}Description
{space 4}{hline 31}
{col 5}{ul:adf}older({it:string}){col 23}Location where package folder already exists
{col 5}{ul:pkg}name({it:string}){col 23}Name of package that exists in the location adfolder() points to.
{space 4}{hline 31}

{title:Description}

{p 4 4 2}
This command is only intended to be used in package folders set up in the adodown workflow using the command {c 96}ad_setup{c 96}.

{p 4 4 2}
This command creates new commands in the package or removes existing commands from it. When creating a command, a template for the ado-file is created in the ado folder, a template for the mdhlp-file is created in the mdhlp folder,
and the ado-file and the sthlp file is addended to the pkg-file in that package folder.

{p 4 4 2}
Note that the using {c 96}net install{c 96} will not work immediately after creating a command with this file as the pkg-file points to the sthlp-file that is not yet rendered. Use the command {c 96}ad_sthlp{c 96} to render that command.

{title:Options}

{p 4 4 2}
{it:subcommand} as specified in {c 96}ad_command <subcommand> <commandname>{c 96} can either be {c 96}create{c 96} or {c 96}remove{c 96}. {c 96}create{c 96} is used when creating a new command and {c 96}remove{c 96} when removing and existing command.

{p 4 4 2}
{it:commandname} as specified in {c 96}ad_command <subcommand> <commandname>{c 96} is the name of the command to be created or removed. If a command is created then an error is thrown if the name is already used by an existing command, and an error will be thrown when removing a command if the name is not used by any existing commands.

{p 4 4 2}
{ul:adf}older({it:string}) is used to indicate the location of where the adodown-styled package folder already exist.

{p 4 4 2}
{ul:pkg}name({it:string}) is the name of the package expected to be found in the adfolder().

{title:Examples}

{p 4 4 2}
{bf:Example 1}

{p 4 4 2}
This example assumes that there is already a adodown-styled package folder at the location the local {c 96}myfolder{c 96} is pointing to.

{c 96}{c 96}{c 96} 
{break}    * point a local to the folder where the package will be created
local myfolder "path/to/folder"

{break}    * Package meta info
local pkg "my_package"

{break}    * Add command mycmd to the package folder
ad_command create mycmd, adf("{c 96}myfolder{c 39}") pkg("{c 96}pkg{c 39}")
{c 96}{c 96}{c 96} 


{p 4 4 2}
{bf:Example 2}

{p 4 4 2}
This example includes the steps for how to create the adodown-styled package folder in the location the local {c 96}myfolder{c 96} is pointing to.

{c 96}{c 96}{c 96} 
{break}    * point a local to the folder where the package will be created
local myfolder "path/to/folder"

{break}    * Package meta info
local pkg "my_package"
local aut "John Doe"
local des "This packages does amazing thing A, B and C."
local url "https://github.com/lsms-worldbank/adodown"
local con "jdoe@worldbank.org"

{break}    * Set up adodown-styled package folder
ad_setup, adfolder("{c 96}myfolder{c 39}") autoconfirm    ///
     name("`pkg'") author("`aut'") desc("`des'") ///
     url("`url'") contact("`con'")

{break}    * Add command mycmd to the package folder
ad_command create mycmd, adf("{c 96}myfolder{c 39}") pkg("{c 96}pkg{c 39}")
{c 96}{c 96}{c 96} 

{title:Feedback, bug reports and contributions}

{p 4 4 2}
Please use the  {browse "https://github.com/lsms-worldbank/adodown/issues":issues feature} on the GitHub repository for the adodown package to communicate any feedback, report bugs, or to make feature requests.

{title:Authors}

{break}    * Author: John Doe
{break}    * Support: jdoe@worldbank.org


