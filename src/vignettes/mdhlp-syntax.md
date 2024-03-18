# mdhlp syntax documentation

This article provides documentation for how to write helpfiles
in an adodown styled Stata package using mdhlp files.
The mdhlp files are used as source both when building web based documentation
and when rendering Stata helpfiles in `.sthlp` format.

## Start with template

We recommend that you use a template and do not start with an empty file.
Easiest is to use `ad_command` when starting a new command to create both
the `.ado` in the ado-folder for the code of the command,
and the `.md` in the mdhlp-folder for the documentation.
If you for any reason can not, or do not want, to use `ad_command`,
but still want use this workflow,
then you can manually download the template from
[here](https://github.com/lsms-worldbank/adodown/blob/main/src/ado/templates/ad-cmd-command.md).

## Syntax supported when rendering .sthlp files

This is how `ad_sthlp` will render markdown syntax to
the SMCL format that is used in Stata helpfiles.

#### Overview

| Markdown syntax | Description | SMCL syntax | Comment |
| ---  | --- | --- | --------- |
|   | Paragraph | Using `{pstd}`/`{p_end}` tags  | In markdown a paragraph is not defined by a character. Instead, a paragraph is defined as text between empty lines with no other formatting (part from inline formatting). In the _Title_ and _Syntax_ sections the `{phang}` tag is used instead of `{pstd}`. |
| `#`  | Header level 1 | Using `{title:}` tag  | |
| `##` | Header level 2 | Using `{dlgtab:}` tag  | No formatting applied if using  more `#`. As in `###`, `####` etc. |
| `__ __` | Inline bold font | Using `{bf:}` tag | Ignored within code formatting |
| `** **` | Inline underlined font | Using `{ul:}` tag  | Ignored unless used for text already in bold font |
| `_ _` | Inline italic font | Using `{it:}` tag | Ignored in bold font |
| `` ` ` `` | Inline code font | Using `{inp:}` tag | All other inline formatting is ignored within the `` ` `` tags |
| ```` ``` ```` / ```` ``` ```` | Multiline code block | Using `{input}`/`{text}` tags | Ignores all formatting within the ```` ``` ```` tags  |
| ` [ ]( ) ` | Hyperlinks | Using `{browse link:text}` tags | May not be combined with other types of formatting |
| `|   |   |` / `|--|--|` / `|   |   |`  | Syntax tables | Using `{synopt}` table syntax | Only works for a two-column table in the _Syntax_ section. The symbol `\|` is not allowed in a cell of a table. |
| `<!--` / `-->` | Comments | Commented lines are ignored | Supports both multi and single line comments  |

#### Paragraphs

Text that are not formatted as tables, headers or code blocks that follows
an empty line will be interpreted as a paragraph and the `{pstd}` will be used.

The `{pstd}` tag will be added in the beginning of the first line of text,
and `{p_end}` will added on it's own line
before the first subsequent empty line.
This means that lines of text only separated by a line breaks will
still be considered the same paragraph as long as there are no empty lines.

In the _Title_ and _Syntax_ sections,
the `{phang}` tag is used instead of `{pstd}`.
This is to highlight the command name in the special paragraphs
typically found in those sections.

#### Headers

`ad_sthlp` has support for two header levels corresponding to
markdowns header levels `#` for level 1 and `##` for level 2.
Level 1 headers are formatted using the `{title}` tag
when rendered to Stata helpfiles,
and level 2 headers are formatted using the `{dlgtb}` tag.

There is no established convention in the Stata community
that `{title}` and `{dlgtb}` have a
level 1 and 2 relation between each other.
This is simply a subjective implementation of `ad_sthlp`.

###### Level 1 - Title
Any line that starts with `#` will be treated as a level 1 heading and
rendered as a title using the `{title}` tag.
Everything that follows `#` will be used as the title text.
Adding other types of formatting to the title text might work,
but it is not supported, and therefore not recommended.

###### Level 2 - Dialogue Tab
Any line that starts with `##` will be treated as a level 2 heading and
rendered as a dialogue tab using the `{dlgtab}` tag.
Everything that follows `##` will be used as the dialogue tab text.
Adding other types of formatting to the dialogue box text might work,
but it is not supported, and therefore not recommended.

#### Inline text formatting

######  Bold inline formatting

Text between `__` (two `_` underscores) tags, as in `__bold text__`,
is formatted as `{bf:bold text}` when rendered to Stata helpfiles.

###### Italic formatting

Text between `_` (a single underscore) tags, as in `_italicized text_`,
is formatted as `{it:italicized text}` when rendered to Stata helpfiles.

It is not possible to italicize a word with `_`,
as `_` in an italicized word will always be interpreted as
the end of italic formatting.

It is not possible to italicize bold font text.
This is to make it possible to express as command name like
`ad_sthlp` in bold font.
`_` is therefore ignored in bold font.

###### Underlined inline formatting

Text between `** **` tags in bold font text, as in `__**underlined text**__`,
is formatted as `{bf:{ul:italicized text}}` when rendered to Stata helpfiles.

Note that underlined format is ignored unless it is applied
to text already formatted with bold font.
This is due to underlined formatting not existing in markdown,
and markdown is used for the web documentation in the adodown workflow.
The recommendation is therefore to use underlined formatting sparsely.

However, underlined formatting has one important function in Stata helpfiles.
It indicates the shortest allowed abbreviations of command and option names.
Since abbreviations are only allowed for options in community written commands
we will only focus on underlined formatting for abbreviations in option names.

Option names are in bold font,
and underline font should therefore only be used on text in bold font.
This reduces the risk of relying too much on underlined formatting
when writing Stata helpfiles
and then realizing underlining is not supported in web documentation.

###### Suggested formatting of command and option names

Here are recommendations on how combine inline formatting to
format syntax of command names and command option names.

| Example      | Description  |  
| ---          | ---          |  
| `__ad_sthlp__` | Command named `ad_sthlp`. Do not use underline in command names as abbreviations are not allowed in names of community written commands. |
| `__option__` | Option named `option`. No parameter is allowed. No abbreviation is allowed. |
| `__**opt**ion__` | Option named `option`. No parameter is allowed. The option named is allowed to abbreviate to `opt`. |
| `__option__(_string_)` | Option named `option`. A string parameter is expected. No abbreviation is allowed. |
| `__**opt**ion__(_string_)` | Option named `option`. A string parameter is expected. The option named is allowed to abbreviate to `opt`. |

###### Code inline formatting

Any text between two `` ` `` on the same line will be formatted
using the `{input}` tag.
You may not split the two `` ` `` across multiple lines.
If unmatched `` ` `` are found, then a warning will be issued.

It is not possible to show a backtick `` ` `` in an inline comment.
For example when trying to show a local referenced as in
`` open `folder'/myfile.dta ``.
The `` ` `` in the inline formatting will always be
interpreted as the end of the inline code formatting
when converted to Stata help files.
It is still possible to show the backtick `` ` `` in code blocks (see below).

All other formatting will be ignored in text that is formatted as a code.
This means that `cd` in `ab_cd_ef` will not be italicized.
The `_` signs will be kept and formatted as code.

#### Code blocks formatting

Any text between lines that starts with ```` ``` ````
(commonly referred to as a code block)
will be formatted using the `{input}` tag.
Any text following on the same line as ```` ``` ```` will
be ignored when converting to Stata help files.
Code blocks are suitable for longer examples of code.

The initial ```` ``` ```` will be replaced with the `{input}` tag,
and the ending ```` ``` ```` will be replaced with `{text}`.
The text in-between is indented 8 blank spaces
(twice the indent for `{pstd}`).

#### Hyperlinks

Markdown links on the format
`[adodown](https://github.com/lsms-worldbank/adodown)`
will be converted to SMCL links on the format
`{browse "https://github.com/lsms-worldbank/adodown":adodown}`.
Only links to internet URLs are supported.
Creating hyperlinks to resources installed in the local Stata installation,
for example `{help : generate}`, are currently not supported.

#### Syntax option tables

The only supported table is the syntax option table in the _Syntax_ section.
This is a table that list all the options in the first column and
provide a short description in the second column.
The table may only be exactly two columns wide.
When rendered into a Stata helpfile the column titles will be
"_options_" and "Description" which is the Stata defaults.
Only "_options_" will be italicized.

Tables in any other section than the _Syntax_ section
will be ignored in the current version of `ad_sthlp`.
Until support for tables in other sections are implemented,
the recommendation is to use vignette articles to document anything
best described in a table.

#### Comments

Any line that starts with `<!--` will be treated as a comment and be ignored
when converting to `.sthlp` format.
A comment ends with `-->`.
If `<!--` and `-->` are on multiple lines, then both those lines,
as well as any lines in-between those lines, will be treated as comments.

Anything on the same line as `-->` will be treated as a comment
even if it comes after `-->`.
A line with any text before `<!--` will not be treated as a comment
and a warning will be thrown.
Due to these two behaviors it is not possible to do an inline comment
where only part of a line is a comment.
Hence, the line `Not a comment <!-- comment --> not a comment` will
be converted verbatim and everything,
including the `<!--` and `-->` tags,
will be displayed when viewing the helpfile.
