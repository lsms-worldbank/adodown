# Title

__ad_command__ - Creates or removes commands in the `adodown` workflow.

# Syntax

__ad_command__ _subcommand_ _commandname_ , __**adf**older__(_string_) __**pkg**name__(_string_) [__**undoc**umented__]

where _subcommand_ is either `create` or `remove` and _commandname_ is the name of the new command to create or the existing command to remove.

| _options_ | Description |
|------------------|-------------|
| __**adf**older__(_string_) | Location where package folder already exists |
| __**pkg**name__(_string_) | Name of package that exists in the location `adfolder()` points to. |
| __**undoc**umented__ | used to create an undocumented command.


# Description

This command is only intended to be used in package folders set up in the `adodown` workflow using the command `ad_setup`.

This command creates new commands in the package or removes existing commands from it. When creating a command, a template for the ado-file is created in the ado folder, a template for the mdhlp-file is created in the mdhlp folder,
and the ado-file and the sthlp file is addended to the pkg-file in that package folder.

Note that the using `net install` will not work immediately after creating a command with this file as the pkg-file points to the sthlp-file that is not yet rendered. Use the command `ad_sthlp` to render that command.

# Options

_subcommand_ as specified in `ad_command <subcommand> <commandname>` can either be `create` or `remove`. `create` is used when creating a new command and `remove` when removing and existing command.

_commandname_ as specified in `ad_command <subcommand> <commandname>` is the name of the command to be created or removed. If a command is created then an error is thrown if the name is already used by an existing command, and an error will be thrown when removing a command if the name is not used by any existing commands.

__**adf**older__(_string_) is used to indicate the location of where the adodown-styled package folder already exist.

__**pkg**name__(_string_) is the name of the package expected to be found in the `adfolder()`.

__**undoc**umented__  is used to create an undocumented command.
An undocumented command is a command that not intended to be used by the user,
and only be used by other commands in the same package.
In practice, this means that no helpfile is created for this command.

# Examples

## Example 1

This example assumes that there is already a adodown-styled package folder at the location the local `myfolder` is pointing to.

```
* point a local to the folder where the package will be created
local myfolder "path/to/folder"

* Package meta info
local pkg "my_package"

* Add command mycmd to the package folder
ad_command create mycmd, adf("`myfolder'") pkg("`pkg'")
```


## Example 2

This example includes the steps for how to create the adodown-styled package folder in the location the local `myfolder` is pointing to.

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
ad_command create mycmd, adf("`myfolder'") pkg("`pkg'")
```

# Feedback, bug reports and contributions

Read more about the commands in this package on the [GitHub repository](https://github.com/lsms-worldbank/adodown) for the `adodown` package.

Please use the [issues feature](https://github.com/lsms-worldbank/adodown/issues) e to communicate any feedback, report bugs, or to make feature requests.

PRs with suggestions for improvements are also greatly appreciated.

# Authors

LSMS Team, The World Bank lsms@worldbank.org
