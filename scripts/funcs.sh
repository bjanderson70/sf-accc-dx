#!/usr/bin/env bash
############################################################################
# Copyright (c) 2020-2021-2021, Salesforce.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#   + Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#   + Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#
#   + Neither the name of Salesforce nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
############################################################################

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
installPack=
installBase=
shellLocation=`basename $0`;
numOfSODays="2";
devhub=;
sObjectName=;
sObjectNameNeed=1;
domainName=;
templateDir=;
outputDir=;

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
    if [ ! -z ${cdir} ]; then
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
    if [ -z ${quietly} ]; then
        echo "${green}${bold}$1";
        resetCursor;
    fi
}
#######################################################
# SFDX present
#
#######################################################
function checkForSFDX(){
	type $SFDX_CLI_EXEC >/dev/null 2>&1 || { handleError " $shellLocation requires sfdx but it's not installed or found in PATH."; }
}

#######################################################
# Set the Sobject Need ( by default it is on)
#
#######################################################
function needSObjectName() {
    sObjectNameNeed=$1
}

#######################################################
# Utility for help
#
#######################################################
function help() {

    echo "${green}${bold}"
    echo ""
    echo "Usage: $shellLocation -v <Dev-Hub> [ -u <username|targetOrg> | -l <num of Days to keep Scratch Org, default to 2> | -i | -t | -d | -q | -h ]"
	printf "\n\t -u <username|targetOrg>"
	printf "\n\t -v <username|dev-hub-alias>"
	printf "\n\t -l <# of days to keep scratch org , defaults to $numOfSODays days>"
	printf "\n\t -t run unit tests"
	printf "\n\t -d turn on debug"
    printf "\n\t -i install/re-install packages; otherwise, will PUSH source to target"
    printf "\n\t -q run quietly"
    printf "\n\t -h the help\n"
    resetCursor;
	exit 0
}
#######################################################
# Utility for help for generators
#
#######################################################
function help2() {

    echo "${green}${bold}"
    echo ""
    echo "Usage: $shellLocation -d <pluralized-domain-name> -s <SObject-Name>| -h | -m ]"
	printf "\n\t -d <pluralized-domain-name>, i.e. Accounts, Contacts, Leads, etc."
    if [  ${sObjectNameNeed} -eq 1 ]; then
	    printf "\n\t -s <SObject-Name>, i.e. Account, Contact, Lead, etc."
    fi
    printf "\n\t -m run in debug-mode"
    printf "\n\t -h the help\n"
    resetCursor;
	exit 0
}
#######################################################
# Utility for help for generators
#
#######################################################
function help3() {

    echo "${green}${bold}"
    echo ""
    echo "Usage: $shellLocation -v <Dev-Hub> | -h | -d ]"
	printf "\n\t -v <Dev-Hub> [REQUIRED]"
    printf "\n\t -d run in debug-mode"
    printf "\n\t -h the help\n"
    resetCursor;
	exit 0
}

#######################################################
# Command Line Arguments (for generators)
#
#######################################################
function getCommandLineArgs2() {

	while getopts d:s:mh option
	do
	   case "${option}"
	   in
	    s) sObjectName=${OPTARG};;
	    d) domainName=${OPTARG};;
	    m) set -xv;;
	    h) help2;;
	   esac
	done
    # need sObjectName
    if [ -z ${sObjectName} ]; then
        if [  ${sObjectNameNeed} -eq 1 ]; then
            handleError "Need to know the SObject Name  "
        fi
    fi
	#need to know domainName
    if [ -z ${domainName} ]; then
        handleError "Need to know the Domain Name  "
    fi
}
#######################################################
# Command Line Arguments
#
#######################################################
function getCommandLineArgs3() {

	while getopts l:v:dh option
	do
	   case "${option}"
	   in
	    l) numOfSODays=${OPTARG};;
		v) devhub=${OPTARG};;
	    d) set -xv;;
	    h) help3;;
	   esac
	done

	#need to know dev-hub
    if [ -z ${devhub} ]; then
        handleError "Need to know the Dev-Hub when creating scratch org "
    fi
}
#######################################################
# Command Line Arguments
#
#######################################################
function getCommandLineArgs() {

	while getopts u:l:v:dsihqtb option
	do
	   case "${option}"
	   in
	    u) orgName=${OPTARG};;
	    l) numOfSODays=${OPTARG};;
		v) devhub=${OPTARG};;
	    d) set -xv;;
        s) scratchOrg=1;;
	    t) runUnitTests=1;;
        b) installBase=1;;
        q) quietly=1;;
        i) installPack=1;;
	    h) help;;
	   esac
	done
    #if no org, then creating a scratch org
    if [ -z ${orgName} ]; then
        scratchOrg=1;
    fi
	#need to know dev-hub
    if [ -z ${devhub} ]; then
        handleError "Need to know the Dev-Hub when creating scratch org "
    fi
}
#######################################################
# Determine CI Environment
#
#######################################################
function isCIEnvironment() {
    # determine who is running
    if [[ ! -z ${IS_CI} ]]; then
        print "Script is running on CI Environment"
        SFDX_CLI_EXEC=node_modules/sfdx-cli/bin/run
    fi
}
#######################################################
# Scratch Org
#
#######################################################
function createScratchOrg() {

    if [ ! -z ${scratchOrg} ]; then
        print "Creating Scratch org..."
        # create scratch
        $SFDX_CLI_EXEC force:org:create -v "$devhub" -s -f config/project-scratch-def.json -d $numOfSODays --json > .$$_orgCreate
        #check status
        if [[ $? > 0 ]]; then
            cat .$$_orgCreate
            echo
            rm .$$_orgCreate
			handleError "Problem creating scratch Org (could be network issues, permissions, or limits) [sfdx force:org:create -s -f config/project-scratch-def.json -d $numOfSODays --json] "
		fi
        orgName=`cat ".$$_orgCreate" |  grep username | awk '{ print $2}' | sed 's/"//g'`;
        rm .$$_orgCreate;

        print "Scratch org created (user=$orgName)."

    fi

}

#######################################################
# Run Apex Unit Tests
#
#######################################################
function runApexTests() {

   if [ ! -z ${runUnitTests-x} ]; then
       print "Running Apex Unit Tests (target=$orgName) [w/ core-coverage]"
       # run tests
       $SFDX_CLI_EXEC force:apex:test:run -r human -c -u "$orgName" -w 30
   fi
}
#######################################################
# make the output dir
#
#######################################################
function makeOutputDir() {

    base=$(dirName $0)
    baseOutput="$base/output"

    if [ ! -d "$baseOutput" ]; then
        mkdir "$baseOutput"

    fi
    outputDir="$baseOutput"
}
#######################################################
# make the output dir
#
#######################################################
function getTemplatesDir() {
      set -xv
      pwd
    base=`pwd`
    #$(dirName $0)
    baseOutput="$base/templates"
    templateDir="${baseOutput}"

    [ ! -d "${baseOutput}" ] && handleError "Could not find the templates: $baseOutput"

}
#######################################################
# set permissions
#
#######################################################
function setPermissions() {
    print "Setting up permissions."
	# place here, if any
}
#######################################################
# Install Packages
#
#######################################################
function installPackages() {

     if [ ! -z ${orgName} ]; then
        local step=0;
        print "installing content to org [$orgName]..."
        # get our package ids ( do not want to keep updating this script)
         cat sfdx-project.json | grep 04t | sed 's/["|,|:]//g' | awk '{print $1" "$2}'| while read line ; do
            local pgkId=`echo $line | awk '{print $2}'`
            local name=`echo $line | awk '{print $1}'`
            print "Installing package $name ($pgkId) for $orgName"
            $SFDX_CLI_EXEC force:package:install -a package --package "$pgkId" --wait 30 --publishwait 30 -u "$orgName"
            #check for install just the base/common
            if [ ! -z ${installBase} ]; then
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
# Push or Install Source
#
#######################################################
function pushOrInstall() {
    if [ -z ${installPack} ]; then
        pushToScratch
    else
        installPackages
    fi
}
#######################################################
# Push to Scratch Orgs
#
#######################################################
function pushToScratch() {
    if [ ! -z ${orgName} ]; then
        print "pushing content to scratch org [$orgName]..."
        $SFDX_CLI_EXEC force:source:push -u "$orgName"
    fi
}
#######################################################
# Open Org
#
#######################################################
function openOrg() {
    if [ ! -z ${orgName} ]; then
        print "Launching Org now [setup]..."
        $SFDX_CLI_EXEC force:org:open -u "$orgName" -p "lightning/setup/SetupOneHome/home"
    fi
}
#######################################################
# complete
#
#######################################################
function complete() {
    print "      *** Completed ***"
}
