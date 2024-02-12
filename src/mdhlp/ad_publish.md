# Title

__ad_publish__ - This command is used for short description.

# Syntax

__ad_publish__ , __**adf**older__(_string_) [__undoc_cmds__(_string_) __nogen_sthlp__]

| _options_ | Description |
|-----------|-------------|
| __**adf**older__(_string_) | Location where package folder already exists |
| __undoc_cmds__(_string_) | List undocumented ado-files expected to not have a help-file |
| __nogen_sthlp__ | Do not run `ad_sthlp` on the package   |

# Description

This command is intended to be used when preparing a package for publication. Unless the option `nogen_sthlp` is used, this command uses the command `ad_sthlp()` (also in this `adodown` package) to generates the `.sthlp`-files from the `.mdhlp`-files.

It then takes package version and Stata version from the `.pkg`-file in this package, and applies that together with the current date to the version meta data and settings in the `.ado`-files and the `.sthlp`-files.

# Options

__**adf**older__(_string_) is used to indicate the location of where the adodown-styled package folder already exist.

__undoc_cmds__(_string_) lists commands that are undocumented. Undocumented commands are not expected to have an help-file. This command throws an error if an expected help-file is missing. Undocumented commands are typically commands for testing or commands used as a utility in other commands in this package.

__nogen_sthlp__ disables the generation of `.sthlp`-files from the `.mdhlp`-files. If not used this command will run `ad_sthlp()` on the package in `adfolder()`.

# example

## Example 1

This example assumes that there is already a adodown-styled package folder at the location the local `myfolder` is pointing to, and that some commands have already been created. Any mdhlp-files in the `mdhlp` folder in the folder `myfolder` is pointing to will be rendered to Stata helpfile format and saved in the `sthlp` folder. Then the command will update the version meta data 

```
* point a local to the folder where the package will be created
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
