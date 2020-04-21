#!/usr/bin/env bash

#######################################################
#
# This script installs the ACCC packages into a scratch org
# run this script with -h for more information
#
#      orgInit -h
#
#   [NOTE: this installs ALL Packages as 'push' grabs ALL folders from the project (-b is ignored)]
#
#       (this script uses funcs.sh)
#######################################################


# functions to process ( order matters)
functions=(checkForSFDX\
            runFromRoot\
			createScratchOrg\
            pushToScratch\
            setPermissions\
            runApexTests\
            complete\
            openOrg
            )
#######################################################
# soure common functions
#
#######################################################
function sourceFunctions() {
    if [[ -f "funcs.sh" ]]; then
        source funcs.sh
    else
        if [[ -f "./scripts/funcs.sh" ]]; then
            source ./scripts/funcs.sh
        fi
    fi
}

# source functions
sourceFunctions
#reset console
trap shutdown EXIT
# cli arguments first
getCommandLineArgs "$@"

print "Running ..."
#run functions
for functionsToCall in "${functions[@]}"
do  	  
	$functionsToCall
done
