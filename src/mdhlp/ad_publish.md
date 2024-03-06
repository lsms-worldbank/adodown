# Title

__ad_publish__ - This command is used to set up a package for publication

# Syntax

__ad_publish__ , __**adf**older__(_string_) [__**und**ocumented__(_string_) __ssczip__ __nogen_sthlp__]

| _options_ | Description |
|-----------|-------------|
| __**adf**older__(_string_) | Location of the adodown-styled package |
| __**und**ocumented__(_string_) | List undocumented ado-files expected to not have a help-file |
| __ssczip__ | Generates a Zip-archive ready to send to SSC  |
| __nogen_sthlp__ | Do not run `ad_sthlp` on the package   |

Read [this helpfile](https://lsms-worldbank.github.io/adodown/reference/ad_publish.html) in the `adodown`'s package web-documentation where you also find articles with guides and best practices related to the commands in this package.

# Description

This command is intended to be used when preparing a package for publication. Unless the option `nogen_sthlp` is used, this command uses the command `ad_sthlp()` (also in this `adodown` package) to generates the `.sthlp`-files from the `.mdhlp`-files.

It then takes package version and Stata version from the `.pkg`-file in this package, and applies that together with the current date to the version meta data and settings in the `.ado`-files and the `.sthlp`-files.

# Options

__**adf**older__(_string_) is used to indicate the location of where the adodown-styled package folder already exist.

__**und**ocumented__(_string_) lists commands that are undocumented. Undocumented commands are not expected to have an help-file. This command throws an error if an expected help-file is missing. Undocumented commands are typically commands for testing or commands used as a utility in other commands in this package.

__ssczip__ generates a zip-archive ready to send to SSC. This zip-archive only include the ado-files, sthlp-files and ancillary files listed in the pkg-file. SSC require that all files are included without any subfolders, or any pkg-files or toc-files.

__nogen_sthlp__ disables the generation of `.sthlp`-files from the `.mdhlp`-files. If not used this command will run `ad_sthlp()` on the package in `adfolder()`.

# example

## Example 1

This example assumes that there is already a adodown-styled package folder at the location the local `myfolder` is pointing to, and that some commands have already been created. Any mdhlp-files in the `mdhlp` folder in the folder `myfolder` is pointing to will be rendered to Stata helpfile format and saved in the `sthlp` folder. Then the command will update the version meta data

```
* point a local to the folder where the package is located
local myfolder "path/to/folder"

* Render the Stata helpfiles
ad_publish, adf("`myfolder'")
```

# Feedback, bug reports and contributions

Read more about the commands in this package on the [GitHub repository](https://github.com/lsms-worldbank/adodown) for the `adodown` package.

Please use the [issues feature](https://github.com/lsms-worldbank/adodown/issues) e to communicate any feedback, report bugs, or to make feature requests.

PRs with suggestions for improvements are also greatly appreciated.

# Authors

LSMS Team, The World Bank lsms@worldbank.org
