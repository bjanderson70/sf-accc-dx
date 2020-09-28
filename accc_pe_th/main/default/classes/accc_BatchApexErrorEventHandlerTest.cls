/**
 * Copyright (c) 2016-2020, Bill Anderson.  All rights reserved.
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
 *   * Neither the name of Bill Anderson nor the names of its
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
 * @author Bill Anderson
 *
 * Borrowed w/ modifications from https://raw.githubusercontent.com/afawcett/force-brf/master/force-brf/test/classes/brf_BatchableErrorTestJob.cls
 *
 * @description Encapsulates all behaviour logic relating to the Testing accc_BatchApexErrorEventHandlerTest
 *
 * @group Platform Events Handling
 */
@isTest
private class accc_BatchApexErrorEventHandlerTest {

    public final static String DEFAULT_LOG_CODE_DATA = '* TEST - DEFAULT_LOG_CODE_DATA - TEST';

    @IsTest
    private static void whenJobExceptionThenLogGeneratedAndHandlerCalled() {

        // Given
        AcccApplicationLog__c testMsgLog = accc_BatchApexErrorEventHandlerTest.createNewMsgLog();
        testMsgLog.LogCode__c = accc_TestBatchableErrorTestJob.CAUSE_BAD_FLOW_NAME;
        update testMsgLog;
        List<AcccApplicationLog__c> testRecords = new List<AcccApplicationLog__c> { testMsgLog };
        accc_TestBatchableErrorTestJob job = new accc_TestBatchableErrorTestJob(testRecords);

        // When
        Test.startTest();
        Id jobId = Database.executeBatch(job);
        List<AcccApplicationLog__c> results = [select Id, LogCode__c,Source__c from AcccApplicationLog__c];
        Test.stopTest();

        // Then (failures captured)
        System.assertEquals(1, (Integer) [select count() from AcccApplicationLog__c where LogCode__c = :accc_TestBatchableErrorTestJob.CAUSE_BAD_FLOW_NAME]);

    }// end of whenJobExceptionThenLogGeneratedAndHandlerCalled

    @IsTest
    private static void whenNoJobExceptionThenDoNotLogGeneratedAndHandlerCalled() {

        // Given
        AcccApplicationLog__c testMsgLog = accc_BatchApexErrorEventHandlerTest.createNewMsgLog();
        List<AcccApplicationLog__c> testRecords = new List<AcccApplicationLog__c> { testMsgLog };
        accc_TestBatchableErrorTestJob job = new accc_TestBatchableErrorTestJob(testRecords);

        // When
        Test.startTest();
        Id jobId = Database.executeBatch(job);
        Test.stopTest();

        // Then (failures captured)
        System.assertEquals(1, (Integer)[select count() from AcccApplicationLog__c Where LogCode__c = :accc_TestBatchableErrorTestJob.CAUSE_GOOD_FLOW_NAME]);

    } // end of whenNoJobExceptionThenDoNotLogGeneratedAndHandlerCalled

    @IsTest
    private static void whenJobExceptionDoNoWork() {

        // Given
        AcccApplicationLog__c testMsgLog = accc_BatchApexErrorEventHandlerTest.createNewMsgLog();
        String testMsgLogName = testMsgLog.Name;
        List<AcccApplicationLog__c> testRecords = new List<AcccApplicationLog__c> { testMsgLog };
        accc_TestBatchableErrorTestJob job = new accc_TestBatchableErrorTestJob(testRecords);
        // nothing is logged in accc_BatchApexErrorEventHandler
        accc_BatchApexErrorEventHandler.causeExceptionForTesting = true;
        // When
        Test.startTest();
        Id jobId = Database.executeBatch(job);
        Test.stopTest();

        // Then (failures captured)
        System.assertEquals(1, (Integer) [select count() from AcccApplicationLog__c Where LogCode__c = :accc_TestBatchableErrorTestJob.CAUSE_GOOD_FLOW_NAME]);
 
    } // end of whenJobExceptionDoNoWork

	////////////////////////////////////////////////////////////
	// Helpers
	////////////////////////////////////////////////////////////

    static AcccApplicationLog__c createNewMsgLog() {
        return accc_BatchApexErrorEventHandlerTest.createNewMsgLog(DEFAULT_LOG_CODE_DATA);

    }// end of createNewMsgLog

    static AcccApplicationLog__c createNewMsgLog(String lcode) {
        AcccApplicationLog__c msglg = new AcccApplicationLog__c();
        msglg.LogCode__c = lcode;

        insert msglg;
        return msglg;

    }// end of createNewMsgLog
} // end of accc_BatchApexErrorEventHandlerTest