cap program drop   adtemplatebuild
    program define adtemplatebuild, rclass
    syntax, folder(string) templates(string)
    
    local templates_in  "`folder'/dev/templatefolder"
    local templates_out "`folder'/dev/templates"

    foreach template of local templates {
        
        local t_file   ""
        local t_slash_folder ""
        local t_hyphe_folder ""
        
        tokenize "`template'" , parse("/") 
        local i = 1
        while (`i'>0) {
            local thistoken = "``i''"
            local nexttoken = "``++i''"
            if missing("`nexttoken'") {
                local t_file "`thistoken'"
                local i = 0 //to end the while loop
            }
            else if "`thistoken'" != "/" {
                local t_slash_folder "`t_folder'/`thistoken'"
                local t_hyphe_folder "`t_folder'-`thistoken'"
            }
        }
        
        * Create to and from paths and names, and then copy template file
        local t_from "`templates_in'`t_slash_folder'/`t_file'" 
        local t_to   "`templates_out'/ad`t_hyphe_folder'-`t_file'"
        copy "`t_from'" "`t_to'" , replace
        
   
        
        di "f /ancillary/adtemplate`t_hyphe_folder'-`t_file'""
        
    }

end

local templates "package.pkg stata.toc"
local templates "`templates' ado/README.md"
local templates "`templates' dev/README.md"
local templates "`templates' mdhlp/README.md"
local templates "`templates' sthlp/README.md"
local templates "`templates' tests/README.md"
local templates "`templates' vignettes/README.md"

adtemplatebuild, folder("C:\Users\wb462869\github\adodown-stata") templates("`templates'")