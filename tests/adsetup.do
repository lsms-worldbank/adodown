
 local clone "C:\Users\wb462869\github\adodown-stata"
 
 local ado   "`clone'/ado"
 local tests "`clone'/tests"

 run "`ado'\adsetup.ado"
 
 adsetup, folder("`tests'/outputs") author("Kristoffer Bjarkefur") packagename("myprog") yesall
 
adsetup, folder("`tests'/outputs") 