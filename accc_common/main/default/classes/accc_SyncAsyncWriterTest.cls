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
 * @author Bill Anderson
 *
 * @description  Test class for the  accc_SyncAsyncWriter methods
 * @group Test Layer
 */
@isTest
private class accc_SyncAsyncWriterTest {
    @isTest
    static void testSyncAsyncWriterAdd() {
        // arrange
        final String msg = 'Testaccc_QueableSObjectsTest';

        Boolean isAsyncDone = false;
        Id theId = null;
        // startTest/stopTest block to force async processes
        //   to run in the test.
        Test.startTest();
        AcccApplicationLog__c acct =  createALog(msg, true);
        theId = acct.Id;
		// act
		accc_SyncAsyncWriter writer = new accc_SyncAsyncWriter(new List<AcccApplicationLog__c> {acct }, false);
		writer.execute();
		Test.stopTest();

		// Validate that the job has run
		// by verifying that the record was created.
		// This query returns only the log created in test context by the
		// Queueable class method.
		// assert
		List<AcccApplicationLog__c> returnedAccts = [SELECT Id  FROM AcccApplicationLog__c];
		System.assertNotEquals(null, returnedAccts);
		System.assertEquals(1, returnedAccts.size());
		System.assertEquals(theId, returnedAccts[0].Id);

		System.assertEquals(isAsyncDone, writer.isAsyncWrite);
		System.assertEquals(true, writer.theException == null);
	}

	@isTest
	static  void testSyncAsyncWriterRemove() {
		// arrange
		final String msg = 'Testaccc_QueableSObjectsTest';

		Boolean isAsyncDone = false;


		// startTest/stopTest block to force async processes
		//   to run in the test.
		Test.startTest();
		AcccApplicationLog__c acct =  createALog(msg, true);
		List<AcccApplicationLog__c> returnedAccts = [SELECT Id  FROM AcccApplicationLog__c];
		// assert
		System.assertNotEquals(null, returnedAccts);
		System.assertEquals(1, returnedAccts.size());
		// act
		accc_SyncAsyncWriter writer = new accc_SyncAsyncWriter(new List<AcccApplicationLog__c> {acct }, true);

		writer.execute();

		Test.stopTest();

		// Validate that the job has run
		// by verifying that the record was created.
		// This query returns only the Log created in test context by the
		// Queueable class method.
		// assert
		returnedAccts = [SELECT Id FROM AcccApplicationLog__c];
		System.assertEquals(0, returnedAccts.size());

		System.assertEquals(isAsyncDone, writer.isAsyncWrite);
		System.assertEquals(true, writer.theException == null);

	}

	@isTest
	static  void testSyncAsyncWriterBadData() {
		// arrange
		Boolean isAsyncDone = false;

		// startTest/stopTest block to force async processes
		//   to run in the test.
		Test.startTest();
		// act
		accc_SyncAsyncWriter writer = new accc_SyncAsyncWriter(null);

		writer.execute();

		Test.stopTest();

		// Validate that the job
		System.assertEquals(isAsyncDone, writer.isAsyncWrite);
		System.assertEquals(true, writer.theException == null);
	}
	//
	@isTest
	static  void testSyncAsyncWriterAddAsync() {
		// arrange
		final String msg = 'Testaccc_QueableSObjectsTest';

		Boolean isAsyncDone = true;

		// startTest/stopTest block to force async processes
		//   to run in the test.
		Test.startTest();
		AcccApplicationLog__c acct = createALog(msg, false);
		// act
		accc_SyncAsyncWriter writer = new accc_SyncAsyncWriter(new List<AcccApplicationLog__c> {acct }, false);
		accc_SyncAsyncWriter.m_makeAsync = true;
		writer.execute();
		writer.theException = new accc_ApexApplicationException('Test');
		Test.stopTest();

		// Validate that the job has run
		// by verifying that the record was created.
		// This query returns only the AcccApplicationLog__c created in test context by the
		// Queueable class method.
		// assert
		List<AcccApplicationLog__c> returnedAccts = [SELECT Id,Message__c  FROM AcccApplicationLog__c  ];
		System.assertNotEquals(null, returnedAccts);
		System.assertEquals(1, returnedAccts.size());
		System.assertEquals(msg, returnedAccts[0].Message__c);

		System.assertEquals(isAsyncDone, writer.isAsyncWrite);
		System.assertEquals(true, writer.theException != null);
	}

	@isTest
	static  void testSyncAsyncWriterForceSyncCauseException() {
		// arrange
		final String msg = 'Testaccc_QueableSObjectsTest';

		Boolean isAsyncDone = true;

		// startTest/stopTest block to force async processes
		// to run in the test.
		Test.startTest();
		AcccApplicationLog__c acct =  createALog(msg, false);

		// act
		accc_SyncAsyncWriter writer = new accc_SyncAsyncWriter(new List<AcccApplicationLog__c> {acct }, false, true);
		accc_SyncAsyncWriter.m_makeAsync = true;
		writer.execute();

		Test.stopTest();

		// Validate that the job has run
		// by verifying that the record was created.
		// This query returns only the AcccApplicationLog__c created in test context by the
		// Queueable class method.
		// assert
		List<AcccApplicationLog__c> returnedAccts = [SELECT Id  FROM AcccApplicationLog__c];
		System.assertEquals(0, returnedAccts.size());
		System.assertEquals(true, writer.theException != null);
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
	} // end of createALog
}