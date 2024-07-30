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

## GitHub requirements

This guide assumes you host
your `adodown` styled Stata package in a GitHub repository
and that you will publish your web documentation using GitHub Pages.
If this does not apply to you,
see the last section of this page for other options.

On GitHub this workflow use GitHub actions to publish the GitHub page.
At the time of writing this documentation,
GitHub actions were free on public repositories.
But please confirm this at
[GitHub Actions pricing page](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions).

## adodown - GitHub pages - step-by-step guide

To enable `adodown` to publish web documentation you need to complete three steps.
There is no requirement on the order you do the steps,
but unless the order below is used,
you will get error notifications until all steps are completed.

### Step 1 - Enable GitHub Pages

You typically need admin access to your repo to complete these step.
Click on the repository _Settings_ tab or go to
`https://github.com/<account_name>/<repo_name>/settings`.
If you cannot access this page you do not have admin access to this repo.

Then go to _Pages_ >> _Build and Deployment_ >> _Source_.
Then select _GitHub Actions_ in the drop-down.

### Step 2 - Authenticate GitHub Actions

You need to create a personal access token to allow
a GitHub Action to publish a GitHub Page.

Go to your GitHub profile settings by
clicking your profile picture and then select _Settings_.
Then navigate to _Developer settings_ >> _Personal access tokens_ >>
_Fine-grained tokens_ >> _Generate new token_.
Select _Generate New Token (Classic)_.

You can name this token anything but name it something that
makes you know what it is used for.
In the GitHub Action this token will be called _ACTIONS_DEPLOY_KEY_
so you can use the same name (_Note_) here.
You also need to generate an expiration date for this token.
After the token expires, you need to come back and repeat this step.

You then have to define a scope for this token. You can select "Repo".
Then click generate token.

Store this token in a secure place like a password manager.
If someone gets access to your key, then they can impersonate you on GitHub.
You will never again be able to make GitHub to show it to you.
If you lose access to the key,
then you will have to repeat this step and generate a new key.

### Step 3 - Add the GitHub Action Workflow

If you are starting a new `adodown` project then, run `ad_setup` and
say yes when asked if you want to set up GitHub templates.
Once this is done you only need to push a commit
and the web documentation will be published.
The web documentation will then be updated each time you
push anything to the `main`/`master` branch.

If you had already set up your `adodown` package,
and if you opt-in to create the GitHub templates,
then the web documentation will update each time you
push anything to the `main`/`master` branch.

If you had already set up your `adodown` package,
but you did not opt-in for the GitHub templates,
then you need to set up the workflow file manually.
To do so, copy the content on
[this page](https://raw.githubusercontent.com/lsms-worldbank/adodown/main/src/ado/templates/ad-gh-workflows.yaml)
into a file you save under the exact path
`.github/workflows/build_adodown_site.yaml`.
Then push this in a commit
and the web documentation will be published.
The web documentation will then be updated each time you
push anything to the `main`/`master` branch.

### View the web site

Wait a minute or two after completing all the three steps above and then go to
`https://github.com/<account_name>/<repo_name>/settings/pages`.
The URL to the web based documentation is then listed at the top of the page.

## Optional steps

### Add a your own logo icon

The [R tool adodownr](https://github.com/arthur-shaw/adodown) used to build this web documentation
allows you to add a custom logo to the web browser tab of your web documentation.
To do so, save the logo in a square sized `.png` file called `logo.png`.
Save the file in `/src/dev/assets/logo.png`.
Push the file to the repo and then the web documentation will be recreated with this logo in the web browser tab.

## Web documentation in other locations

It is possible to use the `adodown(r)` tools to generate web documentation
even when not using a GitHub repository to host the code or
when not using GitHub pages to host documentation.
However, then you need to install the R-tool `adodownr` on your own computer,
and run it yourself to build the website.
See the documentation for `adodownr` for more [details](https://github.com/lsms-worldbank/adodownr).
