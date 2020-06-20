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
 * @description  Test message transformation
 * @group Common Test Layer
 */
@isTest
private class accc_MessageTransformationTest {

    @isTest
    static void testtranslateToApplicationLog() {
        String msg = 'testtranslateToApplicationLog';
        Object loge = msg;
        AcccApplicationLog__c apl = accc_MessageTransformation.translate(LoggingLevel.DEBUG, loge);
        system.assertEquals(true, apl.DebugLevel__c == LoggingLevel.DEBUG.name());
        system.assertEquals(true, apl.Message__c.contains(msg));
    } // end of testtranslateToApplicationLog

    @isTest
    static void testtranslateListObjectToApplList() {
        String msg = 'testtranslateToListLogE';
        integer inx = 0;
        List<Object> apl = new List<Object> { '1', '2', '3'};
        List<AcccApplicationLog__c> alog = accc_MessageTransformation.translate(LoggingLevel.INFO, apl);
        for ( Object aMsg : apl) {
            system.assertEquals(true, alog[inx].Message__c.contains((String)aMsg));
            inx++;
        }
    } // end of testtranslateListObjectToApplList

    @isTest
    static void mapFromTest() {
        // assign
        List<AcccApplicationLog__c> entries=accc_MessageTransformationTest.makeApplicationLog(10);
        // act
        List<accc_Org_Events__b> result=accc_MessageTransformation.mapFrom(entries);
        //assert
        system.assertEquals(entries.size(), result.size());
        for (accc_Org_Events__b item: result ) {
            AcccApplicationLog__c datum= (AcccApplicationLog__c)JSON.deserialize(item.Event_Json__c, AcccApplicationLog__c.class);
            system.assertEquals(true,  datum.Message__c.contains('Message__c'));
            system.assertEquals (true,  datum.Source__c.contains ('Source__c'));
            system.assertEquals (accc_MessageTransformation.ACCCAPPLICATION_LOG_NAME,  item.Event_Name__c);
        }
    }// end of mapFromTest

    @isTest
    static void mergeApplicationLogDataTest() {
        // assign
        List<AcccApplicationLog__c> entries=accc_MessageTransformationTest.makeApplicationLog(3);
        // act
        for (AcccApplicationLog__c item : entries) {
            String result=accc_MessageTransformation.mergeApplicationLogData(item);

            system.assertEquals(true,  result.contains('Message__c'));
            system.assertEquals (true,  result.contains ('Source__c'));
            system.assertEquals (true,  result.contains ('SourceFunction__c'));
        }
    }// end of mergeApplicationLogDataTest

    @isTest
    static void mergeApplicationLogDataForcingEmptyTest() {
        // assign
        accc_MessageTransformation.FORCE_EMPTY_TEST=true;
        AcccApplicationLog__c entry=new AcccApplicationLog__c();
        // act
        String result=accc_MessageTransformation.mergeApplicationLogData(entry);

        system.assertEquals(true,  result.contains('Debug Level'));
        system.assertEquals (true,  result.contains ('Message'));
        system.assertEquals (true,  result.contains ('Integration Payload'));
        system.assertEquals (true,  result.contains ('User Role Id'));
        system.assertEquals (true,  result.contains ('Profile Id'));
        
    } // end of mergeApplicationLogDataTest

    /////////////////////////////////////////////////////////////////////////////////////
    // Helper Method
    /////////////////////////////////////////////////////////////////////////////////////

    private static List<AcccApplicationLog__c> makeApplicationLog(integer count) {
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
    }    // end of makeApplicationLog

}     // end of accc_MessageTransformationTest