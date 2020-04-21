#!/usr/bin/env bash

#######################################################
#
# Core functions used by scripts
#
#######################################################

#######################################################
# For UI (curses)
#######################################################

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
bold=`tput bold`

reset=`tput sgr0`
#######################################################
# Common variables
#######################################################
userDir=`pwd`
SFDX_CLI_EXEC=sfdx
orgName=
scratchOrg=
runUnitTests=
quietly=
installBase=

#######################################################
# Utility to  reset cursor
#
#######################################################
function resetCursor() {
    echo "${reset}" 
}
#######################################################
# Utility print out error
#
#######################################################
function handleError() {
	echo "${red}${bold}"
	printf >&2 "\n\tERROR: $1"" Aborted\n"; 
	resetCursor;
	exit -1; 
}
#######################################################
# Utility print out error
#
#######################################################
function runFromRoot() {
	local cdir=`pwd | grep "/scripts"`
    if [ ! -z $cdir ]; then
       cd ../;
    fi
    userDir=`pwd`;
}
#######################################################
# Utility called when user aborts ( reset )
#
#######################################################
function shutdown() {
  tput cnorm # reset cursor
  cd $userDir;
  resetCursor
}

#######################################################
# SFDX present
#
#######################################################
function print(){
    if [ -z $quietly ]; then
        echo "${green}${bold}$1";
        resetCursor;
    fi
}
#######################################################
# SFDX present
#
#######################################################
function checkForSFDX(){
	type $SFDX_CLI_EXEC >/dev/null 2>&1 || { handleError " $0 requires sfdx but it's not installed or found in PATH."; }
}
#######################################################
# Utility for help
#
#######################################################
function help() {

    echo "${green}${bold}"
    echo ""
    echo "Usage: $0 [ -u <username|targetOrg> | -t | -v | -q | -b | -h ]"
	printf "\n\t -u <username|targetOrg>"
	printf "\n\t -t run unit tests"
	printf "\n\t -v turn on debug"
    printf "\n\t -q run quietly"
    printf "\n\t -b install Only ACCC base (i.e. ACCC Common -- NO Platform Events/CDC)"
	printf "\n\t -h the help\n"
    resetCursor;
	exit 0
}

#######################################################
# Command Line Arguments
#
#######################################################
function getCommandLineArgs() {
	while getopts u:svhqtb option
	do
		case "${option}"
		in
			u) orgName=${OPTARG};;
			v) set -xv;;
            s) scratchOrg=1;;
			t) runUnitTests=1;;
            b) installBase=1;;
            q) quietly=1;;
			h) help; exit 1;;
		esac
	done
    #if no org, then creating a scratch org
    if [ -z $orgName ]; then
        scratchOrg=1;
    fi
}
#######################################################
# Determine CI Environment
#
#######################################################
function isCIEnvironment() {
    # determine who is running
    if [[ ! -z "${IS_CI}" ]]; then
        print "Script is running on CI Environment"
        SFDX_CLI_EXEC=node_modules/sfdx-cli/bin/run
    fi
}
#######################################################
# Scratch Org
#
#######################################################
function createScratchOrg() {
    
    if [ ! -z $scratchOrg ]; then
        print "Creating Scratch org..."
        # get username
        orgName=`$SFDX_CLI_EXEC force:org:create -s -f config/project-scratch-def.json -d 2 --json |  grep username | awk '{ print $2}' | sed 's/"//g'`
        print "Scratch org created (user=$orgName)."
    fi
}

#######################################################
# Run Apex Unit Tests  
#
#######################################################
function runApexTests() {
    
   if [ ! -z $runUnitTests ]; then
       print "Running Apex Unit Tests (target=$orgName) [w/ core-coverage]"
       # run tests
       $SFDX_CLI_EXEC force:apex:test:run -r human -c -u "$orgName" -w 30 
     fi
}
#######################################################
# set permissions
#
#######################################################
function setPermissions() {
    print "Setting up permissions."
    $SFDX_CLI_EXEC force:user:permset:assign -n ACCC_Org_Events_BigObject -u "$orgName"
}
#######################################################
# Install Packages
#
#######################################################
function installPackages() {

    if [ ! -z $orgName ]; then
        local step=0;
        
        # get our package ids ( do not want to keep updating this script)
         cat sfdx-project.json | grep 04t | awk '{print $1" "$2}' | sed 's/["|,|:]//g' | while read line ; do
            local pgkId=`echo $line | awk '{print $2}'`
            local name=`echo $line | awk '{print $1}'`
            print "Installing package $name ($pgkId) for $orgName"
            $SFDX_CLI_EXEC force:package:install -a package --package "$pgkId" --wait 20 --publishwait 20 -u "$orgName" 
            #check for install just the base/common
            if [ ! -z $installBase ]; then
                ((step=step+1));
            fi
            # just installing the common ??
            if [ $step -eq 2 ]; then
                print "Only Accc Common installed!"
                break;
            fi
        done
    fi

}
#######################################################
# Push to Scratch Orgs
#
#######################################################
function pushToScratch() {
    if [ ! -z $orgName ]; then
        print "pushing content to scratch org ..."
        $SFDX_CLI_EXEC force:source:push -u "$orgName"
    fi
}
#######################################################
# Open Org
#
#######################################################
function openOrg() {
    if [ ! -z $orgName ]; then
        print "Launching Org now ..."
        $SFDX_CLI_EXEC force:org:open -u "$orgName"
    fi
}
#######################################################
# complete
#
#######################################################
function complete() {
    print "Note: Cache Partion ('work') is created but you must allocate Organization Space [due to fault in cache partition initialization]."
    print "      *** If you forget to set the partition ApexCacheTest and ApexCacheMgrTest will fail. ***"
}
