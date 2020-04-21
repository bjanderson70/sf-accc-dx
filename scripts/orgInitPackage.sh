#!/usr/bin/env bash

#######################################################
#
# This script installs the ACCC packages
# run this script with -h for more information
#
#      orgInitPackage -h
#
#       (this script uses funcs.sh)
#######################################################

# functions to process ( order matters)
functions=(checkForSFDX\
            runFromRoot\
			createScratchOrg\
			installPackages\
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



#######################################################
# MAIN
#
# Steps to take 
#
#######################################################
# source our common functions
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