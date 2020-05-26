/**
 * Copyright (c) 2019-2020, Bill Anderson.  All rights reserved.
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
 * @File Name          : accc_ApexJSONObjectParserTest.cls
 * @Description        : Test accc_ApexJSONObjectParser
 * @Author             : Bill Anderson
 * @Group              : Test Layer
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    2/8/2020   Bill Anderson     Initial Version
 **/
@isTest
private class accc_ApexJSONObjectParserTest {

    // classname
    static final String CLASSNAME = 'AcccApplicationLog__c';
    // expected JSON string (ignore OwnerId and Username)
    static final String ONE_JSON_PARSED_STRING =' {'
                                                 +' "LogCode__c" : "DEBUG",'
                                                 +' "DebugLevel__c" : "DEBUG",'
                                                 +' "Message__c" : "one",'
                                                 +' "Source__c" : "AcccApplicationLog__c",'
                                                 +' "OwnerId" : "005iaua9810j1213",'
                                                 +' "Username__c" : "005iaua9810j1213" '
                                                 +' }';
    // expected JSON string (ignore OwnerId and Username)
    static final String JSON_PARSED_STRING = '['
                                             +' {'
                                             +' "LogCode__c" : "DEBUG",'
                                             +' "DebugLevel__c" : "DEBUG",'
                                             +' "Message__c" : "one",'
                                             +' "Source__c" : "AcccApplicationLog__c",'
                                             +' "OwnerId" : "005iaua9810j1213",'
                                             +' "Username__c" : "005iaua9810j1213" '
                                             +' },'
                                             +' {'
                                             +' "LogCode__c" : "DEBUG",'
                                             +' "DebugLevel__c" : "DEBUG",'
                                             +' "Message__c" : "two",'
                                             +' "Source__c" : "AcccApplicationLog__c",'
                                             +' "OwnerId" : "005iaua9810j1213",'
                                             +' "Username__c" : "005iaua9810j1213"'
                                             +' },'
                                             +' {'
                                             +' "LogCode__c" : "DEBUG",'
                                             +' "DebugLevel__c" : "DEBUG",'
                                             +' "Message__c" : "three",'
                                             +' "Source__c" : "AcccApplicationLog__c",'
                                             +' "OwnerId" : "005iaua9810j1213",'
                                             +' "Username__c" : "005iaua9810j1213"'
                                             +' }'
                                             +']';



    @isTest static void parseJSONTest() {
        // assign
        accc_ApexJSONObjectParser parser =new accc_ApexJSONObjectParser();

        AcccApplicationLog__c logdata = new AcccApplicationLog__c(
            LogCode__c=LoggingLevel.DEBUG.name(),
            DebugLevel__c=LoggingLevel.DEBUG.name(),
            Source__c=CLASSNAME
            );

        // act
        String json  = parser.parse(logdata);
        // assert
        system.assertNotEquals(null, json);
        system.assertEquals(true, json.containsIgnoreCase('debug'));
        system.assertEquals(true, json.containsIgnoreCase('AcccApplicationLog__c'));
        system.assertEquals (true, json.containsIgnoreCase ('Source__c'));
        // go back to original
        AcccApplicationLog__c nlogdata = (AcccApplicationLog__c)parser.parse(json,AcccApplicationLog__c.class);
        // assert
        system.assertEquals(logdata.LogCode__c,nlogdata.LogCode__c );
        system.assertEquals(logdata.DebugLevel__c,nlogdata.DebugLevel__c);
        system.assertEquals (logdata.Source__c,nlogdata.Source__c);

    } // end of parseJSONTest

    @isTest static void parseJSONCollectionTest() {
        // assign
        accc_ApexJSONObjectParser parser =new accc_ApexJSONObjectParser();

        final Integer EXPECTED_SIZE=3;
        List<AcccApplicationLog__c> logdata;
        List<String> messages= new List<String> {
            'one','two','three'
        };
        Integer count=0;
        // act
        logdata = (List<AcccApplicationLog__c>)parser.parse(JSON_PARSED_STRING,List<AcccApplicationLog__c>.class);
        // assert
        system.assertNotEquals(null, logdata);
        system.assertEquals(EXPECTED_SIZE, logdata.size());
        for ( AcccApplicationLog__c item: logdata) {
            system.assertEquals( LoggingLevel.DEBUG.name(),item.LogCode__c);
            system.assertEquals( LoggingLevel.DEBUG.name(),item.DebugLevel__c);
            system.assertEquals ( CLASSNAME,item.Source__c);
            system.assertEquals ( messages[count++],item.Message__c);
        }

    } // end of parseJSONCollectionTest

    @isTest static void parseObjectTest() {
        // assign
        accc_ApexJSONObjectParser parser =new accc_ApexJSONObjectParser();
        LoggingLevel level = LoggingLevel.DEBUG;

        List<AcccApplicationLog__c> logdata;
        List<String> messages= new List<String> {
            'one','two','three'
        };
        logdata=accc_MessageTransformation.translate(level,messages);
        // act
        String json = parser.parse((List<Object>)logdata);
        // assert

        system.assertNotEquals(null, json);
        system.assertEquals(true, json.containsIgnoreCase('debug'));
        system.assertEquals(true, json.containsIgnoreCase('AcccApplicationLog__c'));

    }// end of parseObjectTest

    @isTest static void parseExceptionTest() {
        // assign
        accc_ApexJSONObjectParser parser =new accc_ApexJSONObjectParser();
        accc_ApexJSONObjectParser.CAUSE_EXCEPTION=true;
        AcccApplicationLog__c logdata = new AcccApplicationLog__c();

        // act
        String json  = parser.parse(logdata);
        // assert
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, json);
        // act
        Object rlist  = parser.parse (accc_ApexConstants.EMPTY_JSON_s,List<AcccApplicationLog__c>.class);
        // assert
        system.assertEquals(null, rlist);
        // act
        json  = parser.parse (new List<AcccApplicationLog__c>());
        // assert
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, json);

    }   // end of parseExceptionTest
}// end of accc_ApexJSONObjectParserTest