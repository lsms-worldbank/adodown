{smcl}
{* *! version 0.1 12FEB2024}{...}
{hline}
{pstd}help file for {hi:ad_setup}{p_end}
{hline}

{title:Title}

{phang}{bf:ad_setup} - Sets up the initial package folder in the {inp:adodown} workflow. 
{p_end}

{title:Syntax}

{phang}{bf:ad_setup} , {bf:{ul:adf}older}({it:string}) [ {bf:{ul:n}ame}({it:string}) {bf:{ul:d}escription}({it:string}) {bf:{ul:a}uthor}({it:string}) {bf:{ul:c}ontact}({it:string}) {bf:{ul:u}rl}({it:string}) {bf:{ul:auto}prompt} {bf:{ul:git}hub} ]
{p_end}

{synoptset 19}{...}
{synopthdr:options}
{synoptline}
{synopt: {bf:{ul:adf}older}({it:string})}Location where package folder will be created{p_end}
{synopt: {bf:{ul:n}ame}({it:string})}Name of package{p_end}
{synopt: {bf:{ul:d}escription}({it:string})}Description of package{p_end}
{synopt: {bf:{ul:a}uthor}({it:string})}Author or authors{p_end}
{synopt: {bf:{ul:c}ontact}({it:string})}Contact information{p_end}
{synopt: {bf:{ul:u}rl}({it:string})}URl (for example to repo hosting the package){p_end}
{synopt: {bf:{ul:auto}prompt}}Suppress the prompt for missing non-required input{p_end}
{synopt: {bf:{ul:git}hub}}Add GitHub template files without prompting{p_end}
{synoptline}

{title:Description}

{pstd}This command creates the initial folder template needed to write and document Stata command packages in the {inp:adodown} workflow. 
{p_end}

{pstd}This workflow makes it easier to create Stata command and packages both ready for distribution on SSC and from a GitHub repository. This workflow also makes writing both web-documentation and helpfiles easier. The helpfiles are written in markdown files that are then used both to render Stata helpfile in {inp:.sthlp}-format and to render web documentation that can, for example, be hosted in a GitHub Page. 
{p_end}

{title:Options}

{pstd}{bf:{ul:adf}older}({it:string}) is used to indicate the location where package folder will be created. This folder can for example be a newly created GitHub repository cloned to the local computer.
{p_end}

{pstd}{bf:{ul:n}ame}({it:string}) specifies the name of the package that will be created. This is the name that would then be used in {inp:ssc install <name>} or {inp:net install <name>}. A command with the same name will be created and added to the package. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively. 
{p_end}

{pstd}{bf:{ul:d}escription}({it:string}) specifies the description of the package. This is the description paragraph that will displayed when using {inp:ssc describe <name>} or {inp:net describe <name>}. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively. 
{p_end}

{pstd}{bf:{ul:a}uthor}({it:string}) specifies the name of the author or authors of this package. This information will be included when using {inp:ssc describe <name>} or {inp:net describe <name>}. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively. 
{p_end}

{pstd}{bf:{ul:c}ontact}({it:string}) specifies the contact information where a users of this package can ask for support. This information will be included when using {inp:ssc describe <name>} or {inp:net describe <name>}. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively. 
{p_end}

{pstd}{bf:{ul:u}rl}({it:string}) specifies a website for where this code is hosted. This should not be where the web-documentation generated in the adodown is hosted, but where the source code is hosted. The web-documentation will include a link pointing to the URL. If using GitHub, then the intended URL should be on this format: https://github.com/lsms-worldbank/adodown. This information will be included when using {inp:ssc describe <name>} or {inp:net describe <name>}. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively. 
{p_end}

{pstd}{bf:{ul:auto}prompt} suppresses the prompt for missing non-required input, such as package description or author. If this options is used, the command will assume that GitHub templates should not be used. When this option is used, the command will still prompt the user for the package name unless that is provided in {inp:name()} as that information is required. 
{p_end}

{pstd}{bf:{ul:git}hub} makes the command add template files useful if the package is stored in a GitHub repository. The two files that are added are a .gitignore file and a GitHub Actions template. The .gitignore is tailored to adodown styled packages such that only required files are pushed to the repository. This template may be modified if preferred or needed. The Github Actions template includes instructions for an automated workflow to generate web based documentation. Read more about this workflow and how to enable it in your repository here. TODO: Add link to vignette when live.
{p_end}

{title:Examples}

{pstd}This example creates a package folder for a package named {inp:my_package} in the location that the local {inp:myfolder} points to. 
{p_end}

{input}{space 8}* point a local to the folder where the package will be created
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
{space 8}ad_setup, adfolder("`myfolder'") autoprompt    /// 
{space 8}     name("`pkg'") author("`aut'") desc("`des'") /// 
{space 8}     url("`url'") contact("`con'") 
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
