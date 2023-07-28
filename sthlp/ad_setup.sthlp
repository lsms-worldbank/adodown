{smcl}
{title:Title}

{p 4 4 2}
{bf:ad_setup} - Sets up the initial package folder in the adodown workflow.

{title:Syntax}

{p 4 4 2}
{bf:ad_setup} , {ul:adf}older({it:string}) [ {ul:n}ame({it:string}) {ul:d}escription({it:string}) {ul:a}uthor({it:string}) {ul:c}ontact({it:string}) {ul:u}rl({it:string}) {ul:autocon}firm

{col 5}{it:options}{col 25}Description
{space 4}{hline 33}
{col 5}{ul:adf}older({it:string}){col 25}Location where package folder will be created
{col 5}{ul:n}ame({it:string}){col 25}Name of package
{col 5}{ul:d}escription({it:string}){col 25}Description of package
{col 5}{ul:a}uthor({it:string}){col 25}Author or authors
{col 5}{ul:c}ontact({it:string}){col 25}Contact information
{col 5}{ul:u}rl({it:string}){col 25}URl (for example to repo hosting the package)
{col 5}{ul:autocon}firm{col 25}Suppress the prompt asking user to confirm package creation
{space 4}{hline 33}

{title:Description}

{p 4 4 2}
This command creates the initial folder template needed to write and document Stata command packages in the adodown workflow.

{p 4 4 2}
This workflow makes it easier to create Stata command and packages both ready for distribution on SSC and from a GitHub repository. This workflow also makes writing both web-documentation and helpfiles easier. The helpfiles are written in markdown files that are then used both to render Stata helpfile in {c 96}.sthlp{c 96}-format and to render web documentation that can, for example, be hosted in a GitHub Page.

{title:Options}

{p 4 4 2}
{ul:adf}older({it:string}) is used to indicate the location where package folder will be created. This folder can for example be a newly created GitHub repository cloned to the local computer.

{p 4 4 2}
{ul:n}ame({it:string}) specifies the name of the package that will be created. This is the name that would then be used in {c 96}ssc install <name>{c 96} or {c 96}net install <name>{c 96}. A command with the same name will be created and added to the package. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively.

{p 4 4 2}
{ul:d}escription({it:string}) specifies the description of the package. This is the description paragraph that will displayed when using {c 96}ssc describe <name>{c 96} or {c 96}net describe <name>{c 96}. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively.

{p 4 4 2}
{ul:a}uthor({it:string}) specifies the name of the author or authors of this package. This information will be included when using {c 96}ssc describe <name>{c 96} or {c 96}net describe <name>{c 96}. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively.

{p 4 4 2}
{ul:c}ontact({it:string}) specifies the contact information where a users of this package can ask for support. This information will be included when using {c 96}ssc describe <name>{c 96} or {c 96}net describe <name>{c 96}. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively.

{p 4 4 2}
{ul:u}rl({it:string}) specifies a website for where this code is hosted. This should not be where the web-documentation generated in the adodown is hosted, but where the source code is hosted. The web-documentation will include a link pointing to the URL. If using GitHub, then the intended URL should be on this format: https://github.com/lsms-worldbank/adodown. This information will be included when using {c 96}ssc describe <name>{c 96} or {c 96}net describe <name>{c 96}. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively.

{title:Examples}

{p 4 4 2}
This example creates a package folder for a package named {c 96}my_package{c 96} in the location that the local {c 96}myfolder{c 96} points to.

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
     name("`pkg'") author("`aut'") desc("`des'") /// url("`url'") contact("`con'")
{c 96}{c 96}{c 96} 

{title:Feedback, bug reports and contributions}

{p 4 4 2}
Please use the  {browse "https://github.com/lsms-worldbank/adodown/issues":issues feature} on the GitHub repository for the adodown package to communicate any feedback, report bugs, or to make feature requests.

{title:Authors}

{p 4 4 2}
Author: John Doe
Support: jdoe@worldbank.org


