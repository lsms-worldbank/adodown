# Title

__ad_setup__ - Sets up the initial package folder in the `adodown` workflow.

# Syntax

__ad_setup__ , **adf**older(_string_) [ **n**ame(_string_) **d**escription(_string_) **a**uthor(_string_) **c**ontact(_string_) **u**rl(_string_) **auto**prompt **git**hub

| _options_ | Description |
|--------------------|-------------|
| **adf**older(_string_)    | Location where package folder will be created |
| **n**ame(_string_)        | Name of package |
| **d**escription(_string_) | Description of package |
| **a**uthor(_string_)      | Author or authors |
| **c**ontact(_string_)     | Contact information |
| **u**rl(_string_)         | URl (for example to repo hosting the package) |
| **auto**prompt              | Suppress the prompt for missing non-required input  |
| **git**hub                | Add GitHub template files without prompting  |

# Description

This command creates the initial folder template needed to write and document Stata command packages in the `adodown` workflow.

This workflow makes it easier to create Stata command and packages both ready for distribution on SSC and from a GitHub repository. This workflow also makes writing both web-documentation and helpfiles easier. The helpfiles are written in markdown files that are then used both to render Stata helpfile in `.sthlp`-format and to render web documentation that can, for example, be hosted in a GitHub Page.

# Options

**adf**older(_string_) is used to indicate the location where package folder will be created. This folder can for example be a newly created GitHub repository cloned to the local computer.

**n**ame(_string_) specifies the name of the package that will be created. This is the name that would then be used in `ssc install <name>` or `net install <name>`. A command with the same name will be created and added to the package. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively.

**d**escription(_string_) specifies the description of the package. This is the description paragraph that will displayed when using `ssc describe <name>` or `net describe <name>`. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively.

**a**uthor(_string_) specifies the name of the author or authors of this package. This information will be included when using `ssc describe <name>` or `net describe <name>`. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively.

**c**ontact(_string_) specifies the contact information where a users of this package can ask for support. This information will be included when using `ssc describe <name>` or `net describe <name>`. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively.

**u**rl(_string_) specifies a website for where this code is hosted. This should not be where the web-documentation generated in the adodown is hosted, but where the source code is hosted. The web-documentation will include a link pointing to the URL. If using GitHub, then the intended URL should be on this format: https://github.com/lsms-worldbank/adodown. This information will be included when using `ssc describe <name>` or `net describe <name>`. While this option is optional, this package meta data is required. So if this option is not used, the user will be prompted to enter the name interactively.

**auto**prompt suppresses the prompt for missing non-required input, such as package description or author. If this options is used, the command will assume that GitHub templates should not be used. When this option is used, the command will still prompt the user for the package name unless that is provided in `name()` as that information is required.

**git**hub makes the command add template files useful if the package is stored in a GitHub repository. The two files that are added are a .gitignore file and a GitHub Actions template. The .gitignore is tailored to adodown styled packages such that only required files are pushed to the repository. This template may be modified if preferred or needed. The Github Actions template includes instructions for an automated workflow to generate web based documentation. Read more about this workflow and how to enable it in your repository here. TODO: Add link to vignette when live.

# Examples

This example creates a package folder for a package named `my_package` in the location that the local `myfolder` points to.

```
* point a local to the folder where the package will be created
local myfolder "path/to/folder"

* Package meta info
local pkg "my_package"
local aut "John Doe"
local des "This packages does amazing thing A, B and C."
local url "https://github.com/lsms-worldbank/adodown"
local con "jdoe@worldbank.org"

* Set up adodown-styled package folder
ad_setup, adfolder("`myfolder'") autoprompt    ///
     name("`pkg'") author("`aut'") desc("`des'") ///
     url("`url'") contact("`con'")
```

# Feedback, bug reports and contributions

Please use the [issues feature](https://github.com/lsms-worldbank/adodown/issues) on the GitHub repository for the `adodown` package to communicate any feedback, report bugs, or to make feature requests.

# Authors

* Author: John Doe
* Support: jdoe@worldbank.org
