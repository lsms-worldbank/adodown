cap program drop   ad_sthlp
    program define ad_sthlp
  qui {

    syntax, folder(string) [debug]

    *******************************************************
    * Create locals

    local hlpflds md st

    *******************************************************
    * Test folder input to make sure it is an adodown folder

    ** Standardize slashes in file paths
    local folderstd	= subinstr(`"`folder'"',"\","/",.)
    ** Test if parameter folders exist
    foreach fld of local hlpflds {
      local `fld'hlp "`folderstd'/`fld'hlp"
    }

    * Test for adodown folders expected in the folder
    foreach ad_fld in folderstd mdhlp sthlp {
      mata : st_numscalar("r(dirExist)", direxists("``ad_fld''"))
      if `r(dirExist)' == 0  {
        local folder_error "TRUE"
        local missing_flds `"`missing_flds' "``ad_fld''" "'
      }
    }
    * Output errors and list missing folders
    if ("`folder_error'" == "TRUE") {
      noi di as error "{pstd}The folder in option {inp:folder()} is not valid adodown folder. The following folders were expected but not found:{p_end}"
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
        local prepped_mdfiles "`prepped_mdfiles' `file_name'"
      }
    }

    if (!missing("`notmd_files'")) {
      noi di as text `"{pstd}{red:Warning:}Only files on format {inp:.md} is expected to be in the "`fld'hlp" folder. In the adodown workflow only markdown files should be saved in this folder. The follwoing file(s) will be skipped:{p_end}"'
      foreach notmd_files of local notmd_files {
        noi di as text `"{pstd}- `notmd_files'{p_end}"'
      }
    }

    *******************************************************
    * Convert files

    foreach file_name of local prepped_mdfiles {

      * Generate the sthlp file from the markdown source
      qui markdoc "`mdhlp'/`file_name'.md", mini export(sthlp) replace suppress

      * markdoc does not allow to specify a location for the output,
      * it will always save in the same file as the source file.
      * Copy stlhp file to output folder for this experiment,
      * and then delete the file where markdoc wrote it
      copy "`mdhlp'/`file_name'.sthlp" "`sthlp'/`file_name'.sthlp", replace
      rm   "`mdhlp'/`file_name'.sthlp"

      * Names to be outputted
      local sthlp_files "`sthlp_files' `file_name'"
    }

    * Output confirmation of files converted
    noi di as res `"{pstd}Mdhlp files successfully converted to sthlp files. The follwoing sthlp file(s) were created:{p_end}"'
    foreach sthlp_file of local sthlp_files {
      noi di as text `"{pstd}- {view "`sthlp'/`sthlp_file'.sthlp":`sthlp_file'.sthlp}.{p_end}"'
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
