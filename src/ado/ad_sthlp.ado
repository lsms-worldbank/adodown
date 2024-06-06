*! version 0.3 20240606 - LSMS Team, World Bank - lsms@worldbank.org

cap program drop   ad_sthlp
    program define ad_sthlp

qui {

    version 14.1

    syntax, ADFolder(string) ///
      [ ///
        commands(string) ///
        nopkgmeta ///
        debug ///
      ]

    noi di ""

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

    * Get default values if version number or date is missing
    if ("`pkgmeta'" == "nopkgmeta") {
      local vnum  "NOPKGMETA"
      local vdate "NOPKGMETA"
    }
    else {
      ad_pkg_meta, adfolder(`"`folderstd'"')
      local vnum  "`r(package_version)'"
      local vdate "`r(date)'"
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
      file write `st_fh' "{smcl}" _n "{* *! version `vnum' `vdate'}{...}" _n ///
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
          noi escape_tricky_characters, line(`"`macval(line)'"') table(`table')
          local line `"`r(escaped_line)'"'

          *Switch back to ` - This is now safe as all ' are escaped and none of them will pair up with a ' to be interpreted as a local
          local line : subinstr local line "%%%CODEINLINE%%%" "`", all

          * Apply all inline formatting ` _ __ ** and escape $ { }
          * and get position of beg and end comment tags
          if (`codeblock' == 0 & !missing(`"`macval(line)'"')) {
            noi apply_inline_formatting, line(`"`macval(line)'"')
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
                noi write_table, handle(`st_fh') tbl_str(`"`tbl_str'"')
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
qui {
    syntax, [line(string) table(string)]

    local esc_line ""

    * Loop over all characters in the string
    local n = strlen(`"`macval(line)'"')
    local i 1
    while (`i' <= `n') {
        * Get next character
        local c = substr(`"`macval(line)'"',`i',1)

        * Get next 2 characters
        local c2 = substr(`"`macval(line)'"',`i',2)

        * escape ', $ and "
        local c : subinstr local c "'"   "{c 39}"
        local c : subinstr local c "$"   "{c S|}"
        local c : subinstr local c `"""' "{c 34}"

        * Since { and } are used in the escapes above,
        * we need to test if c is longer than 1,
        * and only replace { and } if c still has lenth 1
        if strlen("`c'") == 1 local c : subinstr local c "{" "{c -(}"
        if strlen("`c'") == 1 local c : subinstr local c "}" "{c )-}"

        * Allow escaping of | in tables
        if (`table' & `"`c'"' == "\") {
          if (`"`c2'"' == "\|") {
            local c "{c 124}"
            * skip one extra character as two characters were replaces
            local `++i'
          }
        }

        * Add charchter with escape if needed
        local esc_line "`esc_line'`c'"
        local `++i'
    }

    * Return escape
    return local escaped_line `"`macval(esc_line)'"'
}
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

            * Get next character to see if it is a single italized _word_ or a word _with_underscore_
            local next_char = substr("`line'",`i'+1,1)

            * Ignore _ for italic in code spans or in bold spans
            if (`code_span') | (`bold_span') local i = `i' + 1

            * Italic span only ends on "_" if followed by " ", ")", ",", "." or ":"
            else if (!`ital_span' | inlist("`next_char'"," ", ")", ",", ".", ":", "/", "{", "}", "[") | inlist("`next_char'", "]")) {

                local line "`pre'`itag'`post1'"
                local ital_span !`ital_span'
                local i = `i' + strlen("`itag'")
            }
            else {
              *Just go to next char, _ was in the middle of the word as in _code_list_
              local i = `i' + 1
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
    noi parse_hyperlinks, line(`"`line'"')

    * Return line with inline smcl formatting
    return local line `"`r(line)'"'
    return local com_pos_beg `com_pos_beg'
    return local com_pos_end `com_pos_end'
end

* write smcl tables from md strings
cap program drop   	write_table
  	program define	write_table, rclass
qui {
    syntax, handle(string) tbl_str(string)

    * Get the count of columns in this table
    local title_row : word 1 of `tbl_str'
    noi parse_table_row, row("`title_row'")
    local c_count = `r(c_count)'

    * Parse synopt table - used when there are two columns
    if (`c_count' == 2) {
      parse_synopt_table, md_tblstr(`"`tbl_str'"') handle(`handle')
    }
    * For all other columns, use manually created table
    else {
      parse_nonsynopt_table, md_tblstr(`"`tbl_str'"') handle(`handle')
    }
}
end

cap program drop   	parse_synopt_table
  	program define	parse_synopt_table, rclass

    syntax, md_tblstr(string) handle(string)

    * Prepare titles
    local title_row : word 1 of `md_tblstr'
    noi parse_table_row, row("`title_row'")
    local title1 = "`r(c1)'"
    local title2 = "`r(c2)'"

    if (lower("`title1'") == "options" & lower("`title2'") == "description") {
      local title1 = "{it:`title1'}"
    }

    * Syntax table always has exectly two columns
    local c_exp_count 2
    local c1_max_l    0
    local c2_max_l    0

    * Initiate locals and loop over all table rows
    local md_row_i 0
    local sy_row_i 0
    foreach row of local md_tblstr {

        * Skip header and |---|---| row
        if (`++md_row_i') > 2 {

           noi parse_table_row, row("`row'")
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
    //file write `handle' "{synopthdr:options}" _n
    file write `handle' "{p2coldent:`title1'}`title2'{p_end}" _n
    file write `handle' "{synoptline}" _n
    forvalues row = 1/`r_exp_count' {
       file write `handle' "`row_`row''" _n
    }
    file write `handle' "{synoptline}" _n _n

end

cap program drop   	parse_nonsynopt_table
  	program define	parse_nonsynopt_table, rclass

    syntax, md_tblstr(string) handle(string)

    * Initiate locals
    local header 1
    local r_count = -1 //start at -1 row to account for |---|---| rows
    local smcl_tblstr ""

    **********************************
    * Parse row

    * Loop over the marksdown string
    foreach tablerow of local md_tblstr {
       * Parste the markdown string
       parse_table_row, row("`tablerow'")
       * If the first header row
       if `header' {
         * Save number of columns in the header row
         local c_count = `r(c_count)'
         * For each column:
         forvalue c = 1/`c_count' {
            * Column length is length of text + 2 for space before and after
            local lmax_`c' = `r(c`c'_l)' + 2
            * Get title value
            local h_`c' = "`r(c`c')'"
         }
         * Remaining rows are non-header
         local header 0
       }
       * Non header rows
       else {
         * Keep a count of number of rows
         local r_count = `r_count' + 1
         * For each column:
         forvalue c = 1/`c_count' {
            * For each row, take this value lenght if it is the longest
            local lmax_`c' = max(`lmax_`c'',`r(c`c'_l)' + 2)
            * Get the value for this cell
            local r`r_count'_`c' = "`r(c`c')'"
         }
       }
    }

    **********************************
    * Calculate column width and position

    * Set indent and calculate cummulative columns
    local indent = 4
    local col = `indent'
    forvalue c = 1/`c_count' {
      * Calculate cummulative column
      local col = `col' + `lmax_`c'' + 1
      * Save cummulative column for this column
      local col`c' = `col'
    }

    **********************************
    * Genereate the smcl table tring

    * Top border
    local row = "{col `indent'}{c TLC}{hline `lmax_1'}"
    forvalue c = 2/`c_count' {
      local row = "`row'{c TT}{hline `lmax_`c''}"
    }
    local smcl_tblstr `"`smcl_tblstr' "`row'{c TRC}""'

    * Title row
    local row = "{col `indent'}{c |}"
    forvalue c = 1/`c_count' {
      local row = "`row' `h_`c''{col `col`c''}{c |}"
    }
    local smcl_tblstr `"`smcl_tblstr' "`row'""'

    * Below title border
    local row = "{col `indent'}{c LT}{hline `lmax_1'}"
    forvalue c = 2/`c_count' {
      local row = "`row'{c +}{hline `lmax_`c''}"
    }
    local smcl_tblstr `"`smcl_tblstr' "`row'{c RT}""'

    * Generate all data rows
    forvalue r = 1/`r_count' {
      local row = "{col `indent'}{c |}"
      forvalue c = 1/`c_count' {
        local row = "`row' `r`r'_`c''{col `col`c''}{c |}"
      }
      local smcl_tblstr `"`smcl_tblstr' "`row'""'
    }

    * Generate end boarder
    local row = "{col `indent'}{c BLC}{hline `lmax_1'}"
    forvalue c = 2/`c_count' {
      local row = "`row'{c BT}{hline `lmax_`c''}"
    }
    local smcl_tblstr `"`smcl_tblstr' "`row'{c BRC}""'

    * Write the table
    foreach row of local smcl_tblstr {
       file write `handle' "`row'" _n
    }
    file write `handle' "" _n

end

cap program drop   	parse_table_row
  	program define	parse_table_row, rclass
qui {
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
}
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
   local rest_of_line = substr(`"`line'"',`lp3_i'+1,.)

   * Remove smcl formatting from within links
   hyperlink_sanitize_smcl, link(`"`link'"') text(`"`text'"')
   local link `"`r(link)'"'
   local text `"`r(text)'"'

   //If text exists after link, parse that string recurisively for more links
   if !missing("`rest_of_line'") {
     * Recursivley parse rest of line for more links and
     * then return the line with smcl link
     noi parse_hyperlinks, line(`"`rest_of_line'"')
     local rest_of_line "`r(line)'"
   }
   //return the line
   return local line `"`pre'{browse "`link'":`text'}`rest_of_line'"'
 }

 * No link found, return line as is
 else return local line `"`line'"'
end

* If a hyperlink is identified, then there should be no smcl formatting in it
* Most common is _ as in "[sel_add_metadata]" that
* becomes "[sel{it:add}metadata"
cap program drop 	hyperlink_sanitize_smcl
	program define	hyperlink_sanitize_smcl, rclass

  syntax , link(string) text(string)

  * Loop over link and text to find {it and return them back to _
  foreach link_part in link text {
    * test if there are any {it: in link_part
    local smcl_it_exist = strpos(`"``link_part''"',"{it:")
    while (`smcl_it_exist') {
      * Get part before and after {it:
      local first = substr(`"``link_part''"',1,`smcl_it_exist'-1)
      local rest  = substr(`"``link_part''"',`smcl_it_exist',.)

      * Replace {it: and }
      local rest = subinstr(`"`rest'"',"{it:","_",1)
      local rest = subinstr(`"`rest'"',"}","_",1)

      * Combine the two parts and test if there are more {it:
      local `link_part' = "`first'`rest'"
      local smcl_it_exist = strpos(`"``link_part''"',"{it:")
    }
  }
  return local link `"`link'"'
  return local text `"`text'"'

end



cap program drop 	display_len
	program define	display_len, rclass

	syntax, [str(string)]

    if missing("`str'") return local dlen 0
    else {
      local str_len = strlen("`str'")
      local tag_len = 0
      * For each tag "{bf:my string}" etc, count number of such tage and
      * remove the lenght of "{bf:}" and count only the lenght of "my string"
      foreach tag in inp bf ul it {
        local str : subinstr local str "{`tag':" "", all count(local count)
        local tag_len = `tag_len' + (`count' * strlen("{`tag':}"))
      }
      * For each tag "{c 124}" etc, remove 1 less thatn the length
      * of "{c 124}". 1 less as it will be replaced with a character
      * with lengt 1
      foreach tag in "{c 124}" "{c 39}" "{c S|}" "{c 34}" "{c -(}" "{c )-}"  {
        local str : subinstr local str "`tag'" "", all count(local count)
        local tag_len = `tag_len' + (`count' * (strlen("`tag'")-1))
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
