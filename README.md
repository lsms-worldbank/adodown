# `adodown`

Utilities for streamlining Stata package development
<img src='src/dev/assets/logo.png' align="right" height="139" />

<!-- badges: start -->
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

For developers, `adodown` offers workflow commands that automate manual tasks at each stage of development.
At project's start, `adodown` creates the necessary scaffolding for the package (e.g., folders, `pkg` file, etc).
For each package command, it uses templates to create necessary files (i.e., `ado`, documentation, unit test) and
adds appropriate entries in the `pkg` file.
For documentation, it allows developers draft in plain Markdown while creating standard help files in SMCL.
And for publication, adodown collects the required files,
puts them in proper format, and prepares a `zip` file for SSC submission.

Also, `adodown` automatically deploys a package documentation website.
For users, this provides an easy way to discover packages, to understand what they do,
and to explore how commands work--all without installing the package.
For developers, this provides packages with a welcome web presence and offers a home for additional documentation
(e.g., how-to guides, technical notes, FAQs),
and keeps HTML documentation up to date with SMCL documentation through continuous deployment via GitHub Actions.

## Commands

| Command | Description |
| --- | --- |
| [ad_command](https://lsms-worldbank.github.io/adodown/reference/ad_command.html) | Add new or remove existing command to the package |
| [ad_publish](https://lsms-worldbank.github.io/adodown/reference/ad_publish.html) | Run all tasks intended to be done before publishing |
| [ad_setup](https://lsms-worldbank.github.io/adodown/reference/ad_setup.html) | Create up a new `adodown`-styled package |
| [ad_sthlp](https://lsms-worldbank.github.io/adodown/reference/ad_sthlp.html) | Convert the `mdhlp`-files to `SMCL` format and save in `sthlp`-files |
| [ad_update](https://lsms-worldbank.github.io/adodown/reference/ad_update.html) | Update meta information stored in the `pkg`-file.
| [adodown](https://lsms-worldbank.github.io/adodown/reference/adodown.html) | Package command with utilities for the rest of the package |

##  Installation

To install the latest published version of the package:

```stata
* install the package from the SSC package repository
ssc install adodown
```

To update the package:

```stata
* check for updates
* if any are available, apply them
adoupdate adodown
```

### Development version

The version of `adodown` on SSC corresponds to the code in the `main` branch of [the package's GitHub repository](https://github.com/lsms-worldbank/adodown).

To get a bug fix or test bleeding-edge features, you can install code from other branches of the repository.
To install the version in a particular branch:

```stata
* set tag to be the name of the target branch
* for example, the development branch, which contains code for the next release
local tag "dev"
* download the code from that GitHub branch
* install the package
net install adodown, ///
  from("https://raw.githubusercontent.com/lsms-worldbank/adodown/`tag'/src") replace
```

### Previous versions

If you need to install a previously releases version of `adodown`, then you can use the following method.
This can be useful, for example, during reproducibility verifications.
To install the version in a particular release,
set the local `tag` to the target release you want to install in this code:

```stata
* set the tag to the name of the target release
* for example v1.0, say, if the current version were v2.0
local tag "v1.0"
* download the code from that GitHub release
* install the package
net install adodown, ///
  from("https://raw.githubusercontent.com/lsms-worldbank/adodown/`tag'/src") replace
```

## Learn more

To learn more about the package:

- Consult the [reference documentation](https://lsms-worldbank.github.io/adodown/reference/)
- Read how-to articles

## Contact

LSMS Team, World Bank
lsms@worldbank.org
