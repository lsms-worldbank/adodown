# Build and deploy web documentation

One of the main motivations for the `adodown` workflow is to
make it easy to generate user-friendly web documentation.
Web documentation creates a web site where users can browse documentation
without first having to install the package from, for example, SSC.
It also allows you to write supporting documentation
that are not exactly help files.
Such as this page you are reading right now.

While encouraged,
generating web documentation is optional in the `adodown` workflow.
It is perfectly possible to use `adodown` to benefit from
standardized Stata package practices without using web documentation.
If you do not want to generate web documentation,
then there is no need for you to follow the steps in this guide.

## Web documentation using GitHub Pages

This guide assumes you host
your `adodown` styled Stata package in a GitHub repository
and that you will publish your web documentation using GitHub Pages.
If this does not apply to you,
see the last section of this page for other options.

This guide will show how to set up an automated workflow
to build and deploy your web documentation using GitHub Actions.
You do not need to know how to create GitHub Actions yourself,
as you will be provided with all the templates you need.
This page include a step-by-step guide for how to set it up,
and it is not difficult.

However, you do need to have admin access to
the repository you use in order to enable GitHub Actions.
If you are not the owner of the repository where you are setting this up,
or the repository is hosted on an organization account,
then we recommend that you talk to the owner or account admin
before following this guide.

### GitHub Actions pricing

At the time of writing this guide,
GitHub Action is free when used on public repositories,
and has a small charge on private repositories
if the usage exceeds a free quota.
Therefore, in a typical case,
using GitHub Actions in the `adodown` workflow will be free.
GitHub may make changes to their GitHub Actions pricing at any time,
so if this information is important to you, then please confirm costs at the
[GitHub Actions pricing page](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions).

## Step-by-step guide

_THIS GUIDE IS A DRAFT TO BE USED IN DEVELPMENT - FOR NOW, THIS GUIDE IS EUQALLY MUCH A TODO LIST FOR THE DEVELOPMENT TEAM AS IT IS A GUIDE FOR A USER_

#### 1. Create and clone a repository for your Stata package

Create a GitHub repository for the Stata package.
Initiate the repository by creating a `README.md` file in the top directory.
Feel free to populate this file with content at any point.
The only other file that may be created manually is the `.gitignore` file.

Clone the repository to your computer.

**TODO:** Move this step into a general vignette for how to set up a adodown styled Stata package. As this is not specific to how to set up Github Actions.

**TODO:** Suggest a gitignore template - see [Stata adodown issue #3](https://github.com/lsms-worldbank/adodown/issues/3).

#### 2. Set up adodown styled Stata package

Use the command `ad_setup` to create an
`adodown` styled Stata package in the clone.

**TODO:** Move this step into a general vignette for how to set up a adodown styled Stata package. As this is not specific to how to set up Github Actions.

#### 3. Add GitHub Actions workflow

In the top directory of your clone, create a folder called `.github`
(the `.` is important).
In that folder create a folder called `workflows`.
In that folder create a file called `build_adodown_site.yaml`.
Copy the content of
https://github.com/lsms-worldbank/adodown/blob/main/src/ado/templates/ad-build_adodown_site.yaml
and paste the into the yaml-file you just created.
Commit this file to the repository.

**TODO:** Automate this step to be part of `ad_setup` - see [Stata adodown issue #2](https://github.com/lsms-worldbank/adodown/issues/2).

**TODO:** When implemented as a part of `ad_setup`, consider replacing this with a manual step to add this if it was not added from before.

#### 4. Add a logo icon

The [R tool adodown ](https://github.com/arthur-shaw/adodown)
requires that you add a logo icon to the repo.
This logo must be for format `.png` and called `logo.png`.
It can be stored anywhere in the repo.
It is not allowed to have two files with the name `logo.png` in the repo.

**TODO:** Have a default behavior when this file does not exists such that it is not a requirement. - see [R adodown issue #6](https://github.com/arthur-shaw/adodown/issues/6).

#### 5. Make sure that there is only one file with format `.pkg`

The [R tool adodown ](https://github.com/arthur-shaw/adodown)
requires that you only have one file of the format `.pkg` in the repository.
One `.pkg` is created by `ad_setup` and
if you have not created any other `.pkg` manually this will not be an issue.

**TODO:** Only look for the `.pkg` file in the exact location `/src/` - see [R adodown issue #5](https://github.com/arthur-shaw/adodown/issues/5).

#### 6. Allow GitHub Actions

While `build_adodown_site.yaml` includes all instructions needed to
build and deploy the web site with the web documentation,
you need to enable GitHub Actions for those instructions to be applied.

To enable GitHub Actions,
go to `https://github.com/<account_name>/<repo_name>/settings/actions`.
You can also click yourself here by clicking on the _Settings_ tab,
then _Actions_ in the menu to the left and then _General_.
You only have access to these setting pages
if you are the owner of the personal account hosting the repository,
or if have admin access if the repository is hosted on an organization account.

On this page, make the following two changes:

* In the _Actions permissions_ section,
make sure that "_Allow all actions and reusable workflows_" option is selected.
This allows GitHub Actions to be run for this repository.
* In the _Workflow permissions_ section,
make sure that the "_Read and write permissions_" option is selected.
This allow a GitHub Action to make changes to the repository.

If your repository is hosted on an organization account,
then these settings might be affected by global organization account settings.
The organization account admin can set these changes globally at
`https://github.com/organizations/<account_name>/settings/actions`

#### 7. Make one commit to the `main` branch

In this section we will refer to the default branch as `main`.
This is synonymous with `master`,
but we encourage everyone to use `main` over `master`.
The `adodown` workflow will work with either of these names.

The GitHub Actions work flow is set up to re-build and re-deploy
the web documentation each time the `main` branch is updated.
To build it the first time, make any commit to the `main` branch.
This includes making a merge to the `main` branch.

The GitHub Action workflow creates a new branch called `gh-pages`.
This branch should never be modified manually.

#### 8. Set up GitHub Pages

The last step is to tell GitHub there is a web site intended to be shown
as a GitHub Pages site in the `gh-pages` branch.
To do so, go to
`https://github.com/<account_name>/<repo_name>/settings/pages`.
You can also click yourself here by clicking on the _Settings_ tab,
and then _Pages_ in the menu to the left.
You only have access to these setting pages
if you are the owner of the personal account hosting the repository,
or if have admin access if the repository is hosted on an organization account.

On this page, make the following changes:

* In the _Build and deployment_ section:
  * In the sub-section "_Source_" make sure "_Deployed from a branch_" is selected.
  * In the sub-section "_Branch_" make sure "_gh-pages_" is selected as branch and that "_/docs_" is selected as the root folder.

#### 9. View the web site

Wait a minute or two after completing the previous step
and then refresh the page
`https://github.com/<account_name>/<repo_name>/settings/pages`.
The URL to the web based documentation is then listed at the top of the page.

From now on, this page is updated each time
anything is pushed to the `main` branch.
Not that a merge to the `main` branch is considered a push.

## Web documentation in other locations

It is possible to use the `adodown` tools to generate web documentation
even when not using a GitHub repository to host the code or
when not using GitHub pages to host documentation.
However, then you need to install the R-tool adodown on your own computer,
and run it yourself to build the website.
See the documentation for the R-tool adodown (TODO: ADD LINK) for how to do that.
