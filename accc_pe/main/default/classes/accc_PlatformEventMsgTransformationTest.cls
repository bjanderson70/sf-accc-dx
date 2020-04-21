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
 *
 * @author Bill Anderson
 * @description  Test Platform event message transformation
 * @group Common Test Layer
 */
@isTest
private class accc_PlatformEventMsgTransformationTest {


    static public final String ACCC_LOG_EVENT_VERSION = '1.0.0.0';
    @isTest
    static void translateFromObjectToApplicationLogTest() {
        String msg = 'testtranslateToApplicationLog';
        accc_Log__e loge = new accc_Log__e(Message__c = msg);
        AcccApplicationLog__c apl = accc_PlatformEventMsgTransformation.translate(loge);

        system.assertEquals(true, apl.Message__c.contains(msg));
    } // end of translateFromObjectToApplicationLogTest

    @isTest
    static void translateToListLogETest() {
        String msg = 'testtranslateToListLogE';
        List<AcccApplicationLog__c> apl = new List<AcccApplicationLog__c> { new AcccApplicationLog__c(Message__c = msg)};
        List<accc_Log__e> loge = accc_PlatformEventMsgTransformation.translate(apl);
        system.assertEquals(true, loge[0].Message__c.contains(msg));
    } // end of translateToListLogETest

    @isTest
    static void testtranslateToListApplicationLog() {
        String msg = 'testtranslateToListApplicationLog';
        List<accc_Log__e> loge = new List<accc_Log__e> {new accc_Log__e(Message__c = msg)};
        List<AcccApplicationLog__c> apl = accc_PlatformEventMsgTransformation.translate(loge);
        system.assertEquals(true, apl[0].Message__c.contains(msg));
    } // end of testtranslateToListApplicationLog

    @isTest
    static void testtranslateToListApplicationLogWithNull() {

        List<accc_Log__e> loge = null;
        List<AcccApplicationLog__c> apl = accc_PlatformEventMsgTransformation.translate(loge);
        system.assertEquals(true, apl == null);
    } // end of testtranslateToListApplicationLogWithNull

    @isTest
    static void testtranslateToListLogEWithNull() {

        List<AcccApplicationLog__c> apl = null;
        List<accc_Log__e> loge = accc_PlatformEventMsgTransformation.translate(apl);
        system.assertEquals(true, loge == null);
    } // end of testtranslateToListLogEWithNull

    @isTest
    static void testtranslateLogEntry() {

        List<ACCC_Log_Event__e> apl = generateLogEvent(10);
        List<AcccApplicationLog__c> loge = accc_PlatformEventMsgTransformation.translate(apl);
        system.assertEquals(true, loge.size() == apl.size());
    } // end of testtranslateLogEntry

    @isTest
    static void translateFromAppLogTest() {
        // assign
        List<AcccApplicationLog__c> apl = accc_PlatformEventMsgTransformationTest.generateAppLog(10);
        Map<String,AcccApplicationLog__c> mapBySource= new  Map<String,AcccApplicationLog__c>();

        for ( integer inx=0; inx < apl.size(); inx++) {
            mapBySource.put(apl[inx].Source__c,apl[inx]);
        }
        //act
        List<accc_PlatformEventDAOLog> loge = accc_PlatformEventMsgTransformation.translateFromAppLog(apl);
        // assert
        system.assertEquals(true, loge.size() == apl.size());
        for ( integer jnx=0; jnx<loge.size(); jnx++ ) {
            // assert
            system.assertEquals(loge[jnx].json,mapBySource.get(loge[jnx].name).Message__c );
        }

    }  // end of translateFromAppLogTest
    /////////////////////////////////////////////////////////////////////////////
    // Helper Method
    /////////////////////////////////////////////////////////////////////////////

    public static List<ACCC_Log_Event__e> generateLogEvent(integer count){
        List<ACCC_Log_Event__e> entries = new List<ACCC_Log_Event__e>();
        ACCC_Log_Event__e datum;
        Integer ctSize = accc_CDCEventBase.CDC_KNOWN_CHANGE_TYPES.size()-1,
                index=0;
        Id userId = UserInfo.getUserId();
        String uname = UserInfo.getName();
        Account acct= new Account();

        for ( integer inx=0; inx < count; inx++) {
            entries.add( new ACCC_Log_Event__e( Action__c= accc_CDCEventBase.CDC_KNOWN_CHANGE_TYPES[index++],
                                                External_Id__c=accc_ApexUtilities.newGuid(),
                                                TransactionId__c = accc_ApexUtilities.newGuid(),
                                                Exception__c = (index == 3) ? 'accc_ApexApplicationException {}' : '',
                                                Payload__c = JSON.serialize(acct),
                                                UserId__c = userId,
                                                Version__c = ACCC_LOG_EVENT_VERSION,
                                                Sequence_Number__c = 1,
                                                Total_Number__c=1,
                                                DateTime__c = (inx/2)<2?DateTime.now():null
                                                )
                         );
            index = index > ctSize ? 0 : index;
        }
        return entries;
    }// end of generateLogEvent

    public static List<AcccApplicationLog__c> generateAppLog(integer count) {
        List<AcccApplicationLog__c> data = new List<AcccApplicationLog__c>();
        for (integer inx=0; inx<count; inx++) {
            data.add ( new AcccApplicationLog__c( UserRoleId__c =userinfo.getProfileId()
                                                  , DebugLevel__c = 'Debug'
                                                  , Message__c = 'Message__c:'+inx
                                                  , Exception__c=null
                                                  , IntegrationPayload__c ='IntegrationPayload__c:'+inx
                                                  , InvocationType__c='InvocationType__c:'+inx
                                                  , profileId__c=userinfo.getProfileId()
                                                  , ReferenceId__c='ReferenceId__c:'+inx
                                                  , ReferenceInfo__c='ReferenceInfo__c:'+inx
                                                  , Source__c='Source__c:'+inx
                                                  , SourceFunction__c='SourceFunction__c:'+inx
                                                  , StackTrace__c=''
                                                  , Statistics__c=''
                                                  ));
        }
        return data;
    }// end of generateAppLog
}// end of accc_PlatformEventMsgTransformationTest
