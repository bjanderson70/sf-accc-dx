/**
 * Copyright (c) 2016-2020, Bill anderson.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *   * Neither the name of Bill anderson nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @author Bill anderson
 * @description
 *
 * @File Name          : accc_ApexSObjectTypesUtilsTest.cls
 * @Description        : Test Common utilities for sobject types
 * @Author             : Bill Anderson
 * @Group              : Miscellaneous
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    2/25/2019   Bill Anderson     Initial Version
 **/
@isTest
private class accc_ApexSObjectTypesUtilsTest {

    // default values in object
    static final Set<String> DEFAULT_SETTINGS = new Set<String> {
        'Debug','Info'
    };
    @isTest
    static void createSObjectAndCopyListTest(){
        // assign
        List<AcccApplicationLog__c> logs = accc_ApexSObjectTypesUtilsTest.createTestLogs();
        // act
        List<AcccApplicationLog__c> clogs = (List<AcccApplicationLog__c> )accc_ApexSObjectTypesUtils.createSObjectAndCopy(logs);
        // assert
        system.assertEquals(logs.size(), clogs.size());
        for ( integer inx=0; inx < logs.size(); ++inx) {
            system.assertEquals(logs[inx].DebugLevel__c, clogs[inx].DebugLevel__c);
        }
    }
    @isTest
    static void createSObjectAndCopyTest(){
        // assign
        AcccApplicationLog__c log = accc_ApexSObjectTypesUtilsTest.createALog('Warn');
        // act
        AcccApplicationLog__c clog = (AcccApplicationLog__c )accc_ApexSObjectTypesUtils.createSObjectAndCopy(log);
        // assert
        system.assertEquals(log, clog);

    }
    /////////////////////////////////////////////////////////////////////////////
    // Private Methods
    /////////////////////////////////////////////////////////////////////////////
    /**
     * createTestLogs
     * @description create test records
     * @return collection of records
     */
    @TestVisible
    static List<AcccApplicationLog__c> createTestLogs() {
        final List<AcccApplicationLog__c> logs = new List<AcccApplicationLog__c>();

        for (String item: DEFAULT_SETTINGS) {
            logs.add(accc_ApexSObjectTypesUtilsTest.createALog(item));
        }
        return logs;
    }   // end of createTestLogs
    /**
     * createTestLogs
     * @description create test records
     * @return collection of records
     */
    @TestVisible
    static AcccApplicationLog__c createALog(String name) {
        return new AcccApplicationLog__c(DebugLevel__c=name);
    } // end of createTestLogs
}
