#!/usr/bin/env bash
############################################################################
# Copyright (c) 2020, Salesforce.  All rights reserved.
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
# This script installs the ACCC packages into a scratch org
# run this script with -h for more information
#
#      wf_install -h
#
#   [NOTE: this installs ALL Packages as 'push' grabs ALL folders from the project (-b is ignored)]
#
#       (this script uses funcs.sh)
#######################################################

# functions to process ( order matters)
functions=(checkForSFDX runFromRoot createScratchOrg installComponents  pushToScratch setupOrg runApexTests complete openOrg)

#######################################################
# soure common functions
#
#######################################################
function sourceFunctions() {
    if [[ -f "funcs.sh" ]]; then
        source funcs.sh
    elif  [[ -f "./scripts/funcs.sh" ]]; then
            source ./scripts/funcs.sh
    elif  [[ -f "../../funcs.sh" ]]; then
            source ../../funcs.sh
    elif  [[ -f "../../../funcs.sh" ]]; then
            source ../../../funcs.sh
    fi
}
#######################################################
# Setup Org
#
#######################################################
function setupOrg() {
    
     if [[ -f "setupOrg.sh" ]]; then
        setupOrg.sh -u "$orgName"
    else
        if [[ -f "./scripts/setupOrg.sh" ]]; then
            ./scripts/setupOrg.sh -u "$orgName"
        else
            if [[ -f "../setupOrg.sh" ]]; then
                ../setupOrg.sh -u "$orgName"
            fi
        fi
    fi
}

#######################################################
# Install Components (as from sdfx-project.json )
#
#######################################################
function installComponents() {
    #
    echo 
    print "NOTE: .... All Packages are combined into one WF-COE [installComponents]... "
    echo
    #  "force-di": "04t3Z0000000bmEQAQ" >> NOTE: This packages HAS NOT BEEN PROMOTED; thus, not available to Prod
    #$SFDX_CLI_EXEC force:package:install --package 04t3Z0000000bmEQAQ -u "$orgName" -w 30  -k test1234
    # "fflib-apex-mock": "04t3Z000000DF9VQAW" >> NOTE: This packages HAS NOT BEEN PROMOTED; thus, not available to Prod
    #$SFDX_CLI_EXEC force:package:install --package 04t3Z000000DF9VQAW -u "$orgName" -w 30  -k pass1234
    # "fflib-apex-common" >> NOTE: This packages HAS NOT BEEN PROMOTED; thus, not available to Prod
    #$SFDX_CLI_EXEC force:package:install --package 04t3Z000000DF9aQAG -u "$orgName" -w 30  -k pass1234
    # Below is the Most up-to-date ACCC --> ACCC_PE_TH_One_Package@1.5.5-1
    #
    #  $SFDX_CLI_EXEC force:package:install --package 04t6g000008fChCAAU -u "$orgName" -w 30  
    #
    # Wells Fargo's ACCC version
    # $SFDX_CLI_EXEC force:package:install --package 04t3Z0000000bn7QAA -u "$orgName" -w 30

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
