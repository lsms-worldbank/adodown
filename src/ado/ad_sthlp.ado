cap program drop   ad_sthlp
    program define ad_sthlp
  qui {

    syntax, ADFolder(string) [debug]

    *******************************************************
    * Create locals

    local hlpflds md st

    *******************************************************
    * Test folder input to make sure it is an adodown folder

    ** Standardize slashes in file paths
    local folderstd	= subinstr(`"`adfolder'"',"\","/",.)
    local srcfolder	= `"`adfolder'/src"'


    ** Test if parameter folders exist
    foreach fld of local hlpflds {
      local `fld'hlp "`srcfolder'/`fld'hlp"
    }

    * Test for adodown folders expected in the folder
    foreach ad_fld in folderstd srcfolder mdhlp sthlp {
      mata : st_numscalar("r(dirExist)", direxists("``ad_fld''"))
      if `r(dirExist)' == 0  {
        local folder_error "TRUE"
        local missing_flds `"`missing_flds' "``ad_fld''" "'
      }
    }
    * Output errors and list missing folders
    if ("`folder_error'" == "TRUE") {
      noi di as error "{pstd}The folder in option {inp:adfolder()} is not valid adodown folder. The following folders were expected but not found:{p_end}"
      foreach miss_fold of local missing_flds {
        noi di as text `"{pstd}- `miss_fold'/{p_end}"'
      }
      error 99
      exit
    }

    *******************************************************
    * Prepare list of files to convert

    *List files, directories and other files
    local mdfiles : dir `"`mdhlp'"' files "*"	, respectcase

    foreach mdfile of local mdfiles {
      split_file_extentsion, file(`"`mdfile'"')
      local file_ext "`r(file_ext)'"
      local file_name "`r(file_name)'"

      if "`file_ext'" != ".md" {
        local notmd_files "`notmd_files' "`mdfile'""
      }
      else if "`mdfile'" == "README.md" {
        //Do nothing, alwas skip this file
      }
      else {
        local file_names "`file_names' `file_name'"
      }
    }

    if (!missing("`notmd_files'")) {
      noi di as text `"{pstd}{red:Warning:}Only files on format {inp:.md} is expected to be in the "`fld'hlp" folder. In the adodown workflow only markdown files should be saved in this folder. The follwoing file(s) will be skipped:{p_end}"'
      foreach notmd_files of local notmd_files {
        noi di as text `"{pstd}- `notmd_files'{p_end}"'
      }
    }

    *******************************************************
    * Render mdhlp files into tempfiles

    * Loop over all mdhlp files
    foreach file_name of local file_names {

      * Initiate the tempfile handlers and tempfiles needed
      tempname md_fh st_fh
      tempfile `file_name'

      * Open template to read from and new tempfile to write to
      file open `md_fh' using "`mdhlp'/`file_name'.md"  , read
      file open `st_fh' using ``file_name'' , write

      * Write the smcl tag at top of file to
      file write `st_fh' "{smcl}" _n "{* 01 Jan 1960}{...}" _n ///
        "{hline}" _n "help file for {hi:`file_name'}" _n "{hline}" _n _n

      * Read first line then iterate until end of file (eof)
      file read `md_fh' line
      local codeblock 0
      local paragraph 0
      local table     0
      while r(eof)==0 {

        * Replace Stata tricky markdown syntax with tokens
        local line : subinstr local line "```" "%%%CODEBLOCK%%%"

        * Replace ` with input tags - but ignore text in a code block
        if (`codeblock' == 0) {
          apply_inline_formatting, line("`macval(line)'")
          local line "`r(line)'"
        }

        * Code block ```
        if strpos(`"`macval(line)'"',"%%%CODEBLOCK%%%") {
          if (`codeblock' == 0) file write `st_fh' "{input}"
          else file write `st_fh' "{text}" _n
          local codeblock = !`codeblock'
        }

        * Title 1 heading #
        else if (substr(trim(`"`macval(line)'"'),1,2) == "# ") {
          local title = trim(subinstr("`macval(line)'","# ","",1))
          file write `st_fh' "{title:`title'}" _n
        }

        * Title 2 heading ##
        else if (substr(trim(`"`macval(line)'"'),1,3) == "## ") {
          local title = trim(subinstr("`macval(line)'","## ","",1))
          file write `st_fh' "{dlgtab:`title'}" _n
        }

        * Empty lines
        else if (trim(`"`macval(line)'"') == "") {
          if (`paragraph' == 1) {
            file write `st_fh' "{p_end}" _n _n
            local paragraph = !`paragraph'
          }
          else file write `st_fh' "" _n
        }

        * Table
        else if (substr(trim(`"`macval(line)'"'),1,1) == "|") {
          file write `st_fh' `"`macval(line)'"' _n
        }

        * Write line
        else {

          if (`paragraph' == 0 & `codeblock' == 0 ) {
            file write `st_fh' "{pstd}"
            local paragraph = !`paragraph'
          }

          local indent ""
          if (`codeblock' == 1) local indent "{space 8}"
          file write `st_fh' `"`indent'`macval(line)'"' _n
        }

        * Read next line
        file read `md_fh' line
      }
      file close `md_fh'
      file close `st_fh'
    }

    *******************************************************
    * Copy tempfiles to disk

    * Copy all the tempfiles to disk
    foreach file_name of local file_names {
      copy ``file_name'' `"`sthlp'/`file_name'.sthlp"', replace
    }

    * Output confirmation of files converted
    noi di as res `"{pstd}Mdhlp files successfully converted to sthlp files. The follwoing sthlp file(s) were created:{p_end}"'
    foreach file_name of local file_names {
      noi di as text `"{pstd}- {view "`sthlp'/`file_name'.sthlp":`file_name'.sthlp}{p_end}"'
    }
  }

end

* Splits a file name into its name and its extension
cap program drop   	apply_inline_formatting
  	program define	apply_inline_formatting, rclass

    syntax, [line(string)]

    * Initiate span locals
    local code_span 0
    local bold_span 0
    local ulin_span 0
    local ital_span 0

    local n = strlen("`line'")
    local i 1
    while (`i' <= `n') {

        * Switch between start and end tags for
        if (`code_span' == 0) local ctag "{inp:"
        else local ctag "}"
        if (`bold_span' == 0) local btag "{bf:"
        else local btag "}"
        if (`ulin_span' == 0) local utag "{ul:"
        else local utag "}"
        if (`ital_span' == 0) local itag "{it:"
        else local itag "}"

        local dtag  "{c S|}"
        local lctag "{c -(}"
        local rctag "{c )-}"

        local pre   = substr("`line'",1,`i'-1)
        local post1 = substr("`line'",`i'+1,.)
        local post2 = substr("`line'",`i'+2,.)

        * CODE SPAN
        if (substr("`line'",`i',1) == "`") {
            local line "`pre'`ctag'`post1'"
            local code_span !`code_span'
            local i = `i' + strlen("`ctag'")
        }

        * BOLD SPAN
        else if (substr("`line'",`i',2) == "__") {
            * Ignore __ for bold face in code spans
            if (`code_span') local i = `i' + 1
            else {
                local line "`pre'`btag'`post2'"
                local bold_span !`bold_span'
                local i = `i' + strlen("`btag'")
            }
        }
        * UNDERLINE SPAN
        else if (substr("`line'",`i',2) == "**") {
            * Ignore ** for underline in code spans or outside of bold spans
            if (`code_span') | (!`bold_span') local i = `i' + 1
            else {
                local line "`pre'`utag'`post2'"
                local ulin_span !`ulin_span'
                local i = `i' + strlen("`utag'")
            }
        }
        * ITALIC SPAN
        else if (substr("`line'",`i',1) == "_") {
            * Ignore _ for italic in code spans or in block spans
            if (`code_span') | (`bold_span') local i = `i' + 1
            else {
                local line "`pre'`itag'`post1'"
                local ital_span !`ital_span'
                local i = `i' + strlen("`itag'")
            }
        }

        * Stata/smcl tricky characters $, {, and }
        else if (substr("`line'",`i',1) == "$") {
          local line "`pre'`dtag'`post1'"
          local i = `i' + strlen("`dtag'")
        }
        else if (substr("`line'",`i',1) == "{") {
          local line "`pre'`lctag'`post1'"
          local i = `i' + strlen("`lctag'")
        }
        else if (substr("`line'",`i',1) == "}") {
          local line "`pre'`rctag'`post1'"
          local i = `i' + strlen("`rctag'")
        }

        * No special character skip to next character in line
        else local i = `i' + 1
        * Keep updating n as line grows longer as smcl characters are added
        local n = strlen("`line'")
    }

    return local line "`line'"

end


* Splits a file name into its name and its extension
cap program drop 	split_file_extentsion
	program define	split_file_extentsion, rclass

	syntax, file(string)

	**Find the last . in the file path and find extension after it
  local dot_index = strpos(strreverse("`file'"),".")

	** Find file name and extension based on the last dot in the file
	local file_ext  = substr("`file'",-`dot_index',.)
  local file_name = substr("`file'",1,strlen("`file'")-`dot_index')

	return local file_ext "`file_ext'"
  return local file_name "`file_name'"

end
