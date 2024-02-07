*! version XX XXXXXXXXX ADAUTHORNAME ASCONTACTINFO

cap program drop   ad_sthlp
    program define ad_sthlp
  qui {

    syntax, ADFolder(string) [commands(string) debug]

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
      noi di as text `"{pstd}{red:Warning:}Only files on format {inp:.md} is expected to be in the "`fld'hlp" folder. In the adodown workflow only markdown files should be saved in this folder. The following file(s) will be skipped:{p_end}"'
      foreach notmd_files of local notmd_files {
        noi di as text `"{pstd}- `notmd_files'{p_end}"'
      }
    }

    * If running st_hlp on only specific commands
    if !missing("`commands'") {
      * Make sure all commands in comamnds() were found
      local commands_not_found : list commands - file_names
      if !missing("`commands_not_found'") {
        noi di as error `"{pstd}.mdhlp help files was not found for all commands listed in option {opt commands(`commands')}. For the command(s) [`commands_not_found'] no .mdhlp was found in the "src/mdhlp" folder.{p_end}"'
      }
      * Only use the commands
      local file_names "`commands'"
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
        "{hline}" _n "{pstd}help file for {hi:`file_name'}{p_end}" _n "{hline}" _n _n

      * Read first line then iterate until end of file (eof)
      file read `md_fh' line
      local codeblock       0
      local mdcomment       0
      local paragraph       0
      local table           0
      local last_line_empty 0
      local tbl_str         ""
      while r(eof)==0 {

        * Reset line write locals
        local line2write ""
        local newlines   1

        * Replace placeholder for code block
        local line : subinstr local line "```" "%%%CODEBLOCK%%%", count(local has_CODEBLOCK)
        local line : subinstr local line "`"   "%%%CODEINLINE%%%", all

        * Add trailing space to line with ` as it
        * prevents lines to evaluate with trailing `" which breaks the code
        local hasinline = strpos(`"`macval(line)'"',"%%%CODEINLINE%%%")
        if (`hasinline') local line = `"`macval(line)' "'

        * Write codeblock by itself as it should allow
        * special characters tricky in the rest of the code flow
        if (`codeblock' == 1 & `has_CODEBLOCK' == 0) {
          local line : subinstr local line "%%%CODEINLINE%%%" "`", all
          local line = `"{space 8}`macval(line)'"'
          file write `st_fh' `"`macval(line)'"' _newline(1)
        }
        else {

          * Replace Stata tricky markdown syntax with smcl escapes
          escape_tricky_characters, line(`"`macval(line)'"')
          local line `"`r(escaped_line)'"'

          *Switch back to ` - This is now safe as all ' are escaped and none of them will pair up with a ' to be interpreted as a local
          local line : subinstr local line "%%%CODEINLINE%%%" "`", all

          * Apply all inline formatting ` _ __ ** and escape $ { }
          * and get position of beg and end comment tags
          if (`codeblock' == 0 & !missing(`"`macval(line)'"')) {
            apply_inline_formatting, line(`"`macval(line)'"')
            local line       `"`r(line)'"'
            local com_pos_beg `r(com_pos_beg)'
            local com_pos_end `r(com_pos_end)'
          }
          else {
            local com_pos_beg 0
            local com_pos_end 0
          }

          if (`mdcomment' == 0 & `codeblock' == 0) {
            if (`com_pos_beg' == 1) local mdcomment = 1
            else if (`com_pos_beg' != 0) {
              noi di "{pstd}{red:Warning:} Comment found but will be ignored as it is not at beginning of the line.{p_end}"
            }
          }

          if (`mdcomment' == 0) {
            * Code block ```
            if strpos(`"`line'"',"%%%CODEBLOCK%%%") {
              if (`codeblock' == 0) {
                local line2write "{input}"
                local newlines   0
              }
              else local line2write "{text}"
              local codeblock = !`codeblock'
            }

            * Title 1 heading #
            else if (substr(trim(`"`line'"'),1,2) == "# ") {
              local title1 = trim(subinstr(`"`line'"',"# ","",1))
              local line2write `"{title:`title1'}"'
            }

            * Title 2 heading ##
            else if (substr(trim(`"`line'"'),1,3) == "## ") {
              local title2 = trim(subinstr("`line'","## ","",1))
              local line2write `"{dlgtab:`title2'}"'
            }

            * Table | --- | --- |
            else if (substr(trim(`"`line'"'),1,1) == "|") {
              local tbl_str `"`tbl_str' "`line'""'
              local table 1
            }

            * Empty lines
            else if (trim(`"`line'"') == "") {
              * Write end of pragraph tag
              if (`paragraph' == 1) {
                local line2write "{p_end}"
                local newlines 2
                local paragraph = !`paragraph'
              }
              * End of table - write the table and reset table locals
              else if (`table' == 1) {
                write_table, handle(`st_fh') tbl_str(`"`tbl_str'"') section("`title1'")
                local table = 0
                local tbl_str = ""
                local last_line_empty 1
              }
              * Just write the empty line
              else if (`last_line_empty' == 0) {
                file write `st_fh' "" _n
                local last_line_empty 1
              }
            }

            * Write line
            else {

              * If beginning of paragraph, add paragraph tag
              local ptag ""
              if (`paragraph' == 0 & `codeblock' == 0 ) {
                if inlist("`title1'", "Title", "Syntax") local ptag "{phang}"
                else local ptag "{pstd}"
                local paragraph = !`paragraph'
              }

              * Prepare line to write
              local line2write `"`ptag'`line'"'
            }
          }
          * Line is comment - test if end of comment
          else if (`com_pos_end' > 0) local mdcomment = 0

          * Write the line if applicable
          if !missing(`"`line2write'"') {
            file write `st_fh' `"`line2write'"' _newline(`newlines')

            * Special cases that will appear as an empty line
            if (inlist(`"`line2write'"', "{p_end}", "{text}")) {
              local last_line_empty 1
            }
            * Last line is not an empty line
            else local last_line_empty 0
          }
        }

        * Read next line
        file read `md_fh' line
      }

      * Make sure to close open paragraphs before saving the file
      if (`paragraph' == 1) {
        file write `st_fh' "{p_end}" _n
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
    noi di as res `"{pstd}Mdhlp files successfully converted to sthlp files. The following sthlp file(s) were created:{p_end}"'
    foreach file_name of local file_names {
      noi di as text `"{pstd}- {view "`sthlp'/`file_name'.sthlp":`file_name'.sthlp}{p_end}"'
    }
  }

  // Remove when command is no longer in beta
  noi adodown "beta ad_sthlp"

end

* Escapes ', $, { and } that never means anything in md formatting.
* ` is not handled here as it means something in md formatting
cap program drop   	escape_tricky_characters
  	program define	escape_tricky_characters, rclass

    syntax, [line(string)]

    local esc_line ""

    * Loop over all characters in the string
    local n = strlen(`"`macval(line)'"')
    local i 1
    while (`i' <= `n') {
        * Get next character
        local c = substr(`"`macval(line)'"',`i',1)

        * escape ', $ and "
        local c : subinstr local c "'"   "{c 39}"
        local c : subinstr local c "$"   "{c S|}"
        local c : subinstr local c `"""' "{c 34}"

        * Since { and } are used in the escapes above,
        * we need to test if c is longer than 1,
        * which is only willbe if it was escaped above
        if strlen("`c'") == 1 local c : subinstr local c "{" "{c -(}"
        if strlen("`c'") == 1 local c : subinstr local c "}" "{c )-}"

        * Add charchter with escape if needed
        local esc_line "`esc_line'`c'"
        local `++i'
    }

    * Return escape
    return local escaped_line `"`macval(esc_line)'"'
end

* Splits a file name into its name and its extension
cap program drop   	apply_inline_formatting
  	program define	apply_inline_formatting, rclass

    syntax, line(string)

    * Initiate span locals
    local code_span 0
    local bold_span 0
    local ulin_span 0
    local ital_span 0

    * Initiate comment locals
    local com_pos_beg 0
    local com_pos_end 0

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

        * Look for comment tags
        else if !(`code_span') & (substr("`line'",`i',4) == "<!--") {
          if (`com_pos_beg' == 0) {
            local com_pos_beg `i'
            local i = `i' + 1
          }
        }

        else if !(`code_span') & (substr("`line'",`i',4) == "-->") {
          if (`com_pos_end' == 0) {
            local com_pos_end `i'
            local i = `i' + 1
          }
        }

        * No special character skip to next character in line
        else local i = `i' + 1
        * Keep updating n as line grows longer as smcl characters are added
        local n = strlen("`line'")
    }

    * Parse and convert hyperlinks
    parse_hyperlinks, line(`"`line'"')

    * Return line with inline smcl formatting
    return local line `"`r(line)'"'
    return local com_pos_beg `com_pos_beg'
    return local com_pos_end `com_pos_end'
end

* write smcl tables from md strings
cap program drop   	write_table
  	program define	write_table, rclass

    syntax, handle(string) tbl_str(string) section(string)

    if ("`section'" == "Syntax") {

      * Syntax table always has exectly two columns
      local c_exp_count 2
      local c1_max_l    0
      local c2_max_l    0

      * Initiate locals and loop over all table rows
      local md_row_i 0
      local sy_row_i 0
      foreach row of local tbl_str {

          * Skip header and |---|---| row
          if (`++md_row_i') > 2 {

             parse_table_row, row("`row'")
             local row_`++sy_row_i' "{synopt: `r(c1)'}`r(c2)'{p_end}"
             * Test the the number of columns are as expected
             if (`r(c_count)' != `c_exp_count') {
                 noi di as error "Not the correct amounts of cols in row `row_i'"
                 exit
             }
             * Keep track of longest value in each column
             forvalues col = 1/`r(c_count)' {
                  local c`col'_max_l = max(`c`col'_max_l',`r(c`col'_l)')
             }
          }
      }
      local r_exp_count = `sy_row_i'

      * Write syntax option table to file
      file write `handle' "{synoptset `c1_max_l'}{...}" _n
      file write `handle' "{synopthdr:options}" _n
      file write `handle' "{synoptline}" _n
      forvalues row = 1/`r_exp_count' {
         file write `handle' "`row_`row''" _n
      }
      file write `handle' "{synoptline}" _n _n

    }
    else {
      //TODO: implement support for other tables

      // * Get header row from md table str
      // local header : word 1 of `tbl_str'
      //
      // * Parse header to get expecte number of columns
      // parse_table_row, row("`header'")
      // local c_exp_count = `r(c_count)'
      //
      // forvalues col = 1/`r(c_count)' {
      //     local c`col'_title  "`r(c`col')'"
      //     local c`col'_max_l "`r(c`col'_l)'"
      // }
    }

end

cap program drop   	parse_table_row
  	program define	parse_table_row, rclass

    syntax, row(string)

    tokenize "`row'", parse("|")

    local more_cols 1
    local tok_i 0
    local col_i 0
    while (`more_cols') {
        if missing("``++tok_i''") local more_cols 0
        else if ("``tok_i''" != "|") {
            return local c`++col_i' = trim("``tok_i''")
            display_len, str(`=trim("``tok_i''")')
            return local c`col_i'_l = `r(dlen)'
        }
    }
    return local c_count `col_i'

end

cap program drop   	parse_hyperlinks
     program define	parse_hyperlinks, rclass

 syntax , line(string)

 * Parse hyperlink
 local n = strlen(`"`line'"')
 local i 1
 local link_part 0
 local curly_open 0
 while (`i' <= `n') {

   * Get the next s1 and the next two s2 characters
   local s1 = substr(`"`line'"',`i',1)
   local s2 = substr(`"`line'"',`i',2)

   * Add smcl tags count - always reset link part when encountering smcl tag
   if (`"`s1'"'=="{") {
     local curly_open `++curly_open'
     local link_part 0
   }

   * Reduce smcl tag count
   else if (`"`s1'"'=="}") {
     local curly_open `--curly_open'
   }

   * If not withing any smcl formatting, test for link
   else if (`curly_open' == 0) {

       * Beg of link token, if expected increment link part otherwise reset
       if (`"`s1'"'=="[") {
           if (`link_part' == 0) {
               local link_part = 1
               local lp1_i = `i'
           }
           else local link_part = 0
       }
       * Mid of link token, if expected increment link part otherwise reset
       else if (`"`s2'"'=="](") {
           if (`link_part' == 1) {
               local link_part = 2
               local lp2_i = `i'
               local `++i'
           }
           else local link_part = 0
       }
       * End of link token, if expected increment link part otherwise reset
       else if (`"`s1'"'==")") {
           if (`link_part' == 2) {
               local link_part = 3
               local lp3_i = `i'
           }
           else local link_part = 0
       }
       * This is not a corrctly formatted link
       else if (`"`s1'"'=="]") | ("`s1'"=="(") local link_part = 0
   }

   * Link found - therefore end the while loop
   if (`link_part' == 3) local i = `n'

   * go to next character in string
   local `++i'
 }

 * While loop ended, if link found, build smcl link and recurse on remainder
 if (`link_part' == 3) {
   * Get the line before [
   local pre  = substr(`"`line'"',1,`lp1_i'-1)
   * Get the text bewtween [ and ](
   local text = substr(`"`line'"',`lp1_i'+1,`lp2_i'-`lp1_i'-1)
   * Get link between ]( and )
   local link = substr(`"`line'"',`lp2_i'+2,`lp3_i'-`lp2_i'-2)

   * Make a recurisive call on the rest of the line
   local post = substr(`"`line'"',`lp3_i'+1,.)
   parse_hyperlinks, line(`"`post'"')

   * Return the line with smcl link
   return local line `"`pre'{browse "`link'":`text'}`r(line)'"'
 }
 * No link found, return line as is
 else return local line `"`line'"'

end

cap program drop 	display_len
	program define	display_len, rclass

	syntax, [str(string)]

    if missing("`str'") return local dlen 0
    else {
      local str_len = strlen("`str'")
      local tag_len = 0
      foreach tag in inp bf ul it {
        local str : subinstr local str "{`tag':" "", all count(local count)
        local tag_len = `tag_len' + (`count' * strlen("{`tag':}"))
      }
      return local dlen = (`str_len' - `tag_len')
    }
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
