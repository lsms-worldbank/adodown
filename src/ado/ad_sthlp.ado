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

      * Read first line then iterate until end of file (eof)
      file read `md_fh' line
      local codeblock 0
      local paragraph 0
      while r(eof)==0 {

        noi di `"LINE: `macval(line)'"'

        * Replace Stta tricky markdown syntax with tokens
        local line : subinstr local line "```" "%%%CODEBLOCK%%%"

        * Title 1 heading #
        if (substr(trim(`"`macval(line)'"'),1,2) == "# ") {
          local line = trim(subinstr("`macval(line)'","# ","",1))
          file write `st_fh' "{title:`line'}" _n
        }

        * Title 1 heading #
        else if (substr(trim(`"`macval(line)'"'),1,3) == "## ") {
          local line = trim(subinstr("`macval(line)'","## ","",1))
          file write `st_fh' "{dlgtab:`line'}" _n
        }

        * Code block ```
        else if strpos(`"`macval(line)'"',"%%%CODEBLOCK%%%") {
          if (`codeblock' == 0) file write `st_fh' "{input}"
          else file write `st_fh' "{text}" _n
          local codeblock !`codeblock'
        }

        * Empty line
        else if (trim(`"`macval(line)'"') == "") {
          if (`paragraph' == 1) {
            file write `st_fh' "{p_end}" _n _n
            local paragraph !`paragraph'
          }
          else file write `st_fh' "" _n
        }

        * Write line
        else {

          if (`paragraph' == 0 & `codeblock' == 0 ) {
            file write `st_fh' "{pstd}"
            local paragraph !`paragraph'
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
      copy ``file_name'' `"`sthlp'/`file_name'.smcl"', replace
    }

    * Output confirmation of files converted
    noi di as res `"{pstd}Mdhlp files successfully converted to sthlp files. The follwoing sthlp file(s) were created:{p_end}"'
    foreach file_name of local file_names {
      noi di as text `"{pstd}- {view "`sthlp'/`file_name'.smcl":`file_name'.smcl}.{p_end}"'
    }
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
