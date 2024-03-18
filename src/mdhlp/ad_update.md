# Title

__ad_update__ - This command is used for short description.

# Syntax

__ad_update__ , __**adf**older__(_string_) __**pkg**name__(_string_) [ __**newtit**le__(_string_) __**newpkg**version__({_minor_/_major_}[,_samedayok_]) __**newsta**taversion__(_stata_ _version_) __**newaut**hor__(_string_) __**newcon**tact__(_string_) __newurl__(_string_)]

| _options_ | Description |
|-----------|-------------|
| __**adf**older__(_string_) | Location of the adodown-styled package |
| __**pkg**name__(_string_) | Name of package that exists in the location `adfolder()` points to. |
| __**newtit**le__(_string_) | Update the title row shown in `net describe <pkgname>` |
| __**newpkg**version__({_minor_/_major_}[,_samedayok_]) | Increments the package version number with an "minor" (X.++X) or "major" (++X.X) increase |
| __**newsta**taversion__(_stata_ _version_) | Update the version the Stata package targets |
| __**newaut**hor__(_string_) | Update the name of the author or authors of the package |
| __**newcon**tact__(_string_) | Update the contact information for support |
| __newurl__(_string_) | Update the URL for this package |

Read the `adodown` package's [web-documentation]((https://lsms-worldbank.github.io/adodown/) where you find all helpfiles for the commands in this package, as well as articles with guides and best-practices related to the commands in this package.

# Description

Several other commands in the `adodown` package reads meta data from the `.pkg` file.
Since the content of that file is read programmatically by those commands,
it is important that the format of that file is as those commands expect.
Therefore, that file should only be edited using this command `ad_update`.

# Options

__**adf**older__(_string_) is used to indicate the location of where the adodown-styled package folder already exist.

__**pkg**name__(_string_) is the name of the package expected to be found in the `adfolder()`.

__**newtit**le__(_string_) updates the title row shown in, for example, `ssc describe adodown`. This should be a short description of the package. The title will be the name of the package followed by a colon and then the content provided in this option. While not technically required, the practice is to start the title with the word module. Such as in "module to", "module that generates" etc. See `ssc describe` for packages you like for more examples.

__**newpkg**version__({_minor_/_major_}[,_samedayok_]) increments the package version number. This option takes either the string _minor_ or the string _major_. A package version number is on the format X.X where the number before the decimal point indicates major version and the number after the decimal point indicates minor version. If using _major_ in this option then the major version is incremented by 1 and the minor is reset to 0. If _minor_ is used, then the major version is unchanged and the minor version is incremented by 1. When the package version is updated, then the package distribution date is also updated.

After _minor_/_major_ this option allows the sub-option _samedayok_. Without this sub-option, this command throws an error if the version is tried to be incremented a second time the same day. This is to prevent that the package version is updated multiple times if the command for whatever reason is run several times after each other.

__**newsta**taversion__(_stata_ _version_) the package and each command needs to target a specific version. This makes sure that the commands will behave identical when used in the target version or any more recent version. The commands will not work in earlier versions of Stata than this target version. After updating this value, run `ad_publish` and test all commands extensively. In the adodown workflow all commands in a package must target the same Stata version.

__**newaut**hor__(_string_) updates the name of the author or authors of the package. This information will also be used in the version header for all ado-files in this package.

__**newcon**tact__(_string_) updates the contact information for the package. This information will also be used in the version header for all ado-files in this package.

__newurl__(_string_) updates the URL listed for this package. Typically this is the GitHub repository used to develop this package. This should not be the web-documentation that `adodown` can generate in GitHub pages, as `adodown` use this information to link back to the repository from that web-documentation.

# Examples

## Example 1

This example assumes that there is already a adodown-styled package folder at the location the local `myfolder` is pointing to. Then the title is update to `'<pkgname>': module to do great data work"`, the minor version is incremented by 1 and the Stata target version is set to 14.1.

```
* point a local to the folder where the package is located
local myfolder "path/to/folder"
* Package meta info
local pkg "my_package"

* Add command mycmd to the package folder
ad_update , adfolder("`myfolder'") pkg("`pkg'") ///
  newtitle("module to do great data work") newpkgversion(minor) newstataversion(14.1)
```

# Feedback, bug reports and contributions

Read more about the commands in this package on the [GitHub repository](https://github.com/lsms-worldbank/adodown) for the `adodown` package.

Please use the [issues feature](https://github.com/lsms-worldbank/adodown/issues) e to communicate any feedback, report bugs, or to make feature requests.

PRs with suggestions for improvements are also greatly appreciated.

# Authors

LSMS Team, The World Bank lsms@worldbank.org
