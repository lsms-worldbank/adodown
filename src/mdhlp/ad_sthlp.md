# Title

__ad_sthlp__ - Converts mdhlp-files to sthlp-files in the `adodown` workflow.

# Syntax

__ad_sthlp__ , __**adf**older__(_string_) [__commands__(_string_) __nopkgmeta__]

| _options_ | Description |
|------------------|-------------|
| __**adf**older__(_string_) | Location where package folder already exists |
| __commands__(_string_) | List specific command to convert. Default is all in package |
| __nopkgmeta__ | Do not look for a `.pkg` file for package metadata |

Read [this helpfile](https://lsms-worldbank.github.io/adodown/reference/ad_sthlp.html) in the `adodown`'s package web-documentation where you also find articles with guides and best practices related to the commands in this package.

# Description

This command renders Stata helpfiles in the `.sthlp` format
written in the mdhlp-files written in markdown.
The sthlp-files are then intended to be included instead
of the mdhlp-files when distributing the command using
either `ssc install` or `net install`.

In the `adodown` workflow the mdhlp-files are expected to be stored in a folder `mdhlp` in the folder that __**adf**older__(_string_) points to, and the sthlp-files are expected to be written to a folder `sthlp` in the same location. If the package folder was set up using `ad_setup` and the commands were added to the package folder using `ad_command`, then this is already the case.

# Options

__**adf**older__(_string_) is used to indicate the location of where the adodown-styled package folder already exist.

__commands__(_string_) is used list individual commands to convert from `mdhlp` to `sthlp`. One or several commands can be listed. The default when this option is not used is to convert all `mdhlp` files in the package.

__nopkgmeta__ tells the command to not look for a `.pkg` file for version number and version date.
The default is that the header of the `.sthlp` file is populated from the meta information in the `.pkg` file.
This option allows this command to be used for `.mdhlp` files not part of an `adodown` styled package.
If this option is used, the string _NOPKGMETA_ is used as both version number and version date in the header.

# Examples

## Example 1

This example assumes that there is already a adodown-styled package folder at the location the local `myfolder` is pointing to, and that some commands have already been created. Any mdhlp-files in the `mdhlp` folder in the folder `myfolder` is pointing to will be rendered to Stata helpfile format and saved in the `sthlp` folder.

```
* point a local to the folder where the package will be created
local myfolder "path/to/folder"

* Render the Stata helpfiles
ad_sthlp, adf("`myfolder'")
```

## Example 2

This example includes the steps for how to create the adodown-styled package folder in the location the local `myfolder` is pointing to, creating some commands and then render the template mdhlp-files to Stata helpfiles.

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
ad_setup, adfolder("`myfolder'") autoconfirm    ///
     name("`pkg'") author("`aut'") desc("`des'") ///
     url("`url'") contact("`con'")

* Add command mycmd to the package folder
ad_command create mycmd1, adf("`myfolder'") pkg("`pkg'")
ad_command create mycmd2, adf("`myfolder'") pkg("`pkg'")

* Render the Stata helpfiles
ad_sthlp, adf("`myfolder'")
```

# Feedback, bug reports and contributions

Read more about the commands in this package on the [GitHub repository](https://github.com/lsms-worldbank/adodown) for the `adodown` package.

Please use the [issues feature](https://github.com/lsms-worldbank/adodown/issues) e to communicate any feedback, report bugs, or to make feature requests.

PRs with suggestions for improvements are also greatly appreciated.

# Authors

LSMS Team, The World Bank lsms@worldbank.org
