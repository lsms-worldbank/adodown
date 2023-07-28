# Title

__ad_sthlp__ - Renders sthlp-files from mdhlp-files in the adodown workflow.

# Syntax

__ad_sthlp__ , **adf**older(_string_)

| _options_ | Description |
|------------------|-------------|
| **adf**older(_string_) | Location where package folder already exists |


# Description

This command renders Stata helpfiles in the `.sthlp` format written in the mdhlp-files written in markdown. The sthlp-files are then intended to be included instead of the mdhlp-files when distributing the command using either either `ssc install` or `net install`.

In the adodown workflow the mdhlp-files are expected to be stored in a folder `mdhlp` in the folder that **adf**older(_string_) points to, and the sthlp-files are expted to be written to a folder `sthlp` in the same location. If the package folder was set up using `ad_setup` and the commands were added to the package folder using `ad_command`, then this is already the case.

# Options

**adf**older(_string_) is used to indicate the location of where the adodown-styled package folder already exist.

# Examples

__Example 1__

This example assumes that there is already a adodown-styled package folder at the location the local `myfolder` is pointing to, and that some commands have already been created. Any mdhlp-files in the `mdhlp` folder in the folder `myfolder` is pointing to will be rendered to Stata helpfile format and saved in the `sthlp` folder.

```
* point a local to the folder where the package will be created
local myfolder "path/to/folder"

* Render the Stata helpfiles
ad_sthlp, adf("`myfolder'")
```

__Example 2__

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

Please use the [issues feature](https://github.com/lsms-worldbank/adodown/issues) on the GitHub repository for the adodown package to communicate any feedback, report bugs, or to make feature requests.

# Authors

* Author: John Doe
* Support: jdoe@worldbank.org
