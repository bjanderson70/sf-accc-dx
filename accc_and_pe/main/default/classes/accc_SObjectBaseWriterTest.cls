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
 *
 * @author Bill Anderson
 * @description  Test class for the  accc_SObjectBaseWriter methods
 * @group Test Layer
 */
@isTest
private class accc_SObjectBaseWriterTest {

    @isTest
    static void testAdd() {
        // arrange
        final String msg = 'Testaccc_QueableSObjectsTest';

        // startTest/stopTest block to force async processes
        //   to run in the test.
        Test.startTest();
        AcccApplicationLog__c acct = createALog(msg,false);
        // act
        accc_SObjectBaseWriter writer = new accc_SObjectBaseWriter(new List<AcccApplicationLog__c> {acct });
        writer.execute();
        Test.stopTest();

        // assert
        List<AcccApplicationLog__c> returnedAccts = [SELECT Id FROM AcccApplicationLog__c ];

        System.assertNotEquals(null, returnedAccts);
        System.assertEquals(1, returnedAccts.size());
        System.assertEquals(true, writer.theException == null);

    }

    @isTest
    static void testRemove() {
        // arrange
        final String msg = 'Testaccc_QueableSObjectsTest';


        // startTest/stopTest block to force async processes
        //   to run in the test.
        Test.startTest();
        AcccApplicationLog__c acct = createALog(msg,true);
        List<AcccApplicationLog__c> returnedAccts = [SELECT Id,Message__c FROM AcccApplicationLog__c ];
        // assert
        System.assertNotEquals(null, returnedAccts);
        System.assertEquals(1, returnedAccts.size());
        System.assertEquals(msg, returnedAccts[0].Message__c);
        // act
        accc_SObjectBaseWriter writer = new accc_SObjectBaseWriter(new List<AcccApplicationLog__c> {acct }, true);
        writer.execute();
        Test.stopTest();

        // Validate that the job has run
        // by verifying that the record was not created.
        // assert
        returnedAccts = [SELECT Id FROM AcccApplicationLog__c];
        System.assertEquals(0, returnedAccts.size());
        System.assertEquals(true, writer.theException == null);

    }

    @isTest
    static void testAddBadData() {
        // arrange
        final String msg = 'Testaccc_QueableSObjectsTest';

        // startTest/stopTest block to force async processes
        //   to run in the test.
        Test.startTest();
        AcccApplicationLog__c acct = createALog(msg,false);
        // act
        accc_SObjectBaseWriter writer = new accc_SObjectBaseWriter(null, true);
        writer.execute();
        Test.stopTest();

        // Validate that the job has run
        // by verifying that the record was not created.
        // assert
        List<AcccApplicationLog__c> returnedAccts = [SELECT Id FROM AcccApplicationLog__c];
        System.assertEquals(0, returnedAccts.size());
    }
    @isTest
    static void testException() {
        // arrange
        final String msg = 'Testaccc_QueableSObjectsTest';


        // startTest/stopTest block to force async processes
        //   to run in the test.
        Test.startTest();
        AcccApplicationLog__c acct = createALog(msg,false);
        // act
        accc_SObjectBaseWriter writer = new accc_SObjectBaseWriter(new List<AcccApplicationLog__c> {acct }, true);
        accc_SObjectBaseWriter.m_testToCaseException = true;
        writer.execute();
        Test.stopTest();

        // Validate that the jobdid not run
        // assert
        List<AcccApplicationLog__c> returnedAccts = [SELECT Id FROM AcccApplicationLog__c];
        System.assertEquals(0, returnedAccts.size());
        System.assertEquals(true, writer.theException != null);
    }

    @isTest
    static void testhasID() {
        // arrange
        final String msg = 'Testaccc_QueableSObjectsTest';

        // startTest/stopTest block to force async processes
        //   to run in the test.
        Test.startTest();
        AcccApplicationLog__c acct = createALog(msg,false);
        // act
        accc_SObjectBaseWriter writer = new accc_SObjectBaseWriter(new List<Sobject> {acct});
        // assert
        System.assertEquals(false, writer.hasID());
        writer.execute();
        Test.stopTest();

        // Validate that the job has run
        // by verifying that the record was created.
        // assert
        List<AcccApplicationLog__c> returnedAccts = [SELECT Id FROM AcccApplicationLog__c];
        System.assertEquals(1, returnedAccts.size());
        // it should be present now
        System.assertEquals(true, writer.hasID());
    }
    /**
     * @description create an log -- may need to plug into your log creator for tests
     *
     * @param msg msg for the AcccApplicationLog__c
     * @param doInsert do insert
     *
     * @return an AcccApplicationLog__c
     */
    static AcccApplicationLog__c createALog(String msg, Boolean doInsert) {
        AcccApplicationLog__c aal = new AcccApplicationLog__c (Message__c = msg );
        if ( doInsert ) {
            insert aal;
        }
        return aal;
    }     // end of createALog
} // end of accc_SObjectBaseWriterTest