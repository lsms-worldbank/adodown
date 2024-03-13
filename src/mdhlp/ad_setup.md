# Title

__ad_setup__ - Sets up the initial package folder in the `adodown` workflow.

# Syntax

__ad_setup__ , __**adf**older__(_string_) [ __**n**ame__(_string_) __**d**escription__(_string_) __**a**uthor__(_string_) __**c**ontact__(_string_) __**u**rl__(_string_) __**auto**prompt__ __**git**hub__ ]

| _options_ | Description |
|--------------------|-------------|
| __**adf**older__(_string_)    | Location where to create the adodown-styled package |
| __**n**ame__(_string_)        | Name of package |
| __**d**escription__(_string_) | Description of package |
| __**a**uthor__(_string_)      | Author or authors |
| __**c**ontact__(_string_)     | Contact information |
| __**u**rl__(_string_)         | URL (for example to repo hosting the package) |
| __**auto**prompt__            | Suppress the prompt for missing non-required input  |
| __**git**hub__                | Add GitHub files without prompting  |

Read [this helpfile](https://lsms-worldbank.github.io/adodown/reference/ad_setup.html) in the `adodown`'s package web-documentation where you also find articles with guides and best practices related to the commands in this package.

# Description

This command creates the initial folder template needed to write and document Stata command packages in the `adodown` workflow.

This workflow makes it easier to create Stata command and packages both ready for distribution on SSC and from a GitHub repository. This workflow also makes writing both web-documentation and helpfiles easier. The helpfiles are written in markdown files that are then used both to render Stata helpfile in `.sthlp`-format using the `ad_sthlp` command, and to render web documentation that can, for example, be hosted in a GitHub Page.

# Options

__**adf**older__(_string_) is used to indicate the location where package folder will be created. This folder can, for example, be a newly created GitHub repository cloned to the local computer.

__**n**ame__(_string_) specifies the name of the package that will be created. This is the name that will then be used in `ssc install <name>` or `net install <name>`. A command with the same name will be created and added to the package. While this option is optional, this package meta data is required. If a name is not provided in this option, then the user will be prompted to enter the name interactively.

__**d**escription__(_string_) specifies the description of the package. This is the description paragraph that will displayed when using `ssc describe <name>` or `net describe <name>`. If a description is not provided in this option, then the user will be prompted to enter the description interactively. Since this meta data is not required, the user can leave it empty.

__**a**uthor__(_string_) specifies the name of the author or authors of this package. This information will be included when using `ssc describe <name>` or `net describe <name>`. While this option is optional, this package meta data is required. If an author is not provided in this option, then the user will be prompted to enter the name interactively.

__**c**ontact__(_string_) specifies the contact information where a users of this package can ask for support. This information will be included when using `ssc describe <name>` or `net describe <name>`. If contact information is not provided in this option, then the user will be prompted to enter the contact information interactively. Since this meta data is not required, the user can leave it empty.

__**u**rl__(_string_) specifies a website for where this code is hosted. This should not be where the web-documentation generated in the adodown is hosted, but where the source code is hosted. The web-documentation will include a link pointing to the URL. If using GitHub, then the intended URL should be on this format: https://github.com/lsms-worldbank/adodown. This information will be included when using `ssc describe <name>` or `net describe <name>`. If a URL is not provided in this option, then the user will be prompted to enter the URL interactively. Since this meta data is not required, the user can leave it empty.

__**auto**prompt__ suppresses the prompt for missing non-required input, such as package description or author. If this options is used, the command will assume that GitHub templates should not be used. When this option is used, the command will still prompt the user for the package name unless that is provided in `name()` or `author()` as that information is required.

__**git**hub__ makes the command add files useful if the package is stored in a GitHub repository. The two files that are added are a `.gitignore` file and a GitHub Actions workflow `.yaml` file. The `.gitignore` is tailored to `adodown` styled packages such that only required files are pushed to the repository. This ignore template may be modified if preferred or needed. The Github Actions workflow file includes instructions for an automated workflow to generate web based documentation. Read more about this workflow and how to enable it in your repository here. See guidelines for this workflow [here](https://lsms-worldbank.github.io/adodown/articles/web-documenation-using-github-actions.html).

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

Read more about the commands in this package on the [GitHub repository](https://github.com/lsms-worldbank/adodown) for the `adodown` package.

Please use the [issues feature](https://github.com/lsms-worldbank/adodown/issues) e to communicate any feedback, report bugs, or to make feature requests.

PRs with suggestions for improvements are also greatly appreciated.

# Authors

LSMS Team, The World Bank lsms@worldbank.org
