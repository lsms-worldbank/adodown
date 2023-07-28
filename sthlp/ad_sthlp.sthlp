{smcl}
{title:Title}

{p 4 4 2}
{bf:ad_sthlp} - Renders sthlp-files from mdhlp-files in the adodown workflow.

{title:Syntax}

{p 4 4 2}
{bf:ad_sthlp} , {ul:adf}older({it:string})

{col 5}{it:options}{col 23}Description
{space 4}{hline 31}
{col 5}{ul:adf}older({it:string}){col 23}Location where package folder already exists
{space 4}{hline 31}

{title:Description}

{p 4 4 2}
This command renders Stata helpfiles in the {c 96}.sthlp{c 96} format written in the mdhlp-files written in markdown. The sthlp-files are then intended to be included instead of the mdhlp-files when distributing the command using either either {c 96}ssc install{c 96} or {c 96}net install{c 96}.

{p 4 4 2}
In the adodown workflow the mdhlp-files are expected to be stored in a folder {c 96}mdhlp{c 96} in the folder that {ul:adf}older({it:string}) points to, and the sthlp-files are expted to be written to a folder {c 96}sthlp{c 96} in the same location. If the package folder was set up using {c 96}ad_setup{c 96} and the commands were added to the package folder using {c 96}ad_command{c 96}, then this is already the case.

{title:Options}

{p 4 4 2}
{ul:adf}older({it:string}) is used to indicate the location of where the adodown-styled package folder already exist.

{title:Examples}

{p 4 4 2}
{bf:Example 1}

{p 4 4 2}
This example assumes that there is already a adodown-styled package folder at the location the local {c 96}myfolder{c 96} is pointing to, and that some commands have already been created. Any mdhlp-files in the {c 96}mdhlp{c 96} folder in the folder {c 96}myfolder{c 96} is pointing to will be rendered to Stata helpfile format and saved in the {c 96}sthlp{c 96} folder.

{c 96}{c 96}{c 96} 
{break}    * point a local to the folder where the package will be created
local myfolder "path/to/folder"

{break}    * Render the Stata helpfiles
ad_sthlp, adf("{c 96}myfolder{c 39}")
{c 96}{c 96}{c 96} 

{p 4 4 2}
{bf:Example 2}

{p 4 4 2}
This example includes the steps for how to create the adodown-styled package folder in the location the local {c 96}myfolder{c 96} is pointing to, creating some commands and then render the template mdhlp-files to Stata helpfiles.

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
ad_command create mycmd1, adf("{c 96}myfolder{c 39}") pkg("{c 96}pkg{c 39}")
ad_command create mycmd2, adf("{c 96}myfolder{c 39}") pkg("{c 96}pkg{c 39}")

{break}    * Render the Stata helpfiles
ad_sthlp, adf("{c 96}myfolder{c 39}")
{c 96}{c 96}{c 96} 

{title:Feedback, bug reports and contributions}

{p 4 4 2}
Please use the  {browse "https://github.com/lsms-worldbank/adodown/issues":issues feature} on the GitHub repository for the adodown package to communicate any feedback, report bugs, or to make feature requests.

{title:Authors}

{break}    * Author: John Doe
{break}    * Support: jdoe@worldbank.org


