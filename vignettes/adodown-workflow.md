# The adodown workflow

## Intro

The adodown workflow is intended to make it easier to
set up and maintain Stata packages.
Such that, more time can be spend writing code
instead of modifying pkg-files etc.

The adodown workflow also allows you to write documentation in markdown format,
which is a format that is quicker to learn that Stata's `smcl`.
This mean that you do not have access to all the features in `smcl`,
but you can still write great documentation
with the features you still have access to.

Another, and perhaps greater, advantage of
writing the documentation in markdown files is that those files
can automatically be rendered into web-based documentation.
The part of adodown that renders the web-based documentation is
written in R and uses [Quarto](https://quarto.org/).
However, if you are hosting your adodown-styled Stata package on GitHub.com,
then you do not need to know R or Quarto,
as rendering the web-based documentation can be automated with GitHub actions.
