# Test command ad_setup

The only thing needed to run the test is to open file `adodown\tests\ad_setup.do` and edit the root path at the top of the folder to point to the clone in your file system.

```
* AS root path
if c(username) == "<computer username>" {
    local clone "<clone file path>"
}
```

Test 1 shows how the command can run with no manual input. All package meta information is in the command options. In test 2 no package meta information is passed as options. Instead, the command will prompt the user to enter it manually. You can mix passing meta info in options and provide manually.

See outputs of tests here: `adodown\tests\outputs\ad_setup`

## Current features

* The command has 4 stages
  * Test package meta info passed in options
  * Prompt user for package meta info that was not passed in info
  * Prepare and test the folder template creation:
    * Test that folders can be created
    * Get templates from repo
  * Once testing is successful, prompt user to confirm (unless option `autoconfirm` is used)
  * Then create the templates
    * Populate pkg file and toc file with package meta info
    * Only now create all the folder and files
* The command sets up folders and use templates stored here: `adodown\ado\templates`.
  * Currently the command downloads the templates from the repo over https. That is ok and should remain one option.
  I think there should be an offline option. I have ideas for that. Stata's ancillary files was not the best fit for this.
* The command populates the pkg file such that it can be updated by future commands used when a user wants to create a new command.
