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
 * @description  Translate messages from one type to another
 * @group Common Layer
 */
public without sharing class accc_MessageTransformation {

    public static final String ACCCAPPLICATION_LOG_NAME = 'AcccApplicationLog__c';
    /**
     * @description translate a log record into an AcccApplicationLog__c
     *
     * @param LoggingLevel logging level
     * @param Object the message
     * @return AcccApplicationLog__c
     */
    public static AcccApplicationLog__c translate(LoggingLevel level, Object message) {
        AcccApplicationLog__c result = null;

        if ( message != null ) {
            Id userId = UserInfo.getUserId();
            String lvlName = level.name();
            Type theType = message instanceof AcccApplicationLog__c ?  AcccApplicationLog__c.class : null;

            if ( AcccApplicationLog__c.class == theType ) {
                result = (AcccApplicationLog__c)message;
                if ( result != null ) {
                    result.LogCode__c = lvlName;
                    result.DebugLevel__c = lvlName;
                    if ( result.Username__c== null) {
                        result.Username__c=userId;
                    }
                    if ( result.OwnerId== null) {
                        result.OwnerId=userId;
                    }
                }
            } else {
                result = new AcccApplicationLog__c(LogCode__c = lvlName,
                                                   DebugLevel__c = lvlName,
                                                   Message__c =  accc_StringUtilities.toJsonString(message),//accc_ApexUtilities.toString(message),
                                                   Source__c = ACCCAPPLICATION_LOG_NAME,
                                                   OwnerId = userId,
                                                   Username__c = userId);
            }
        }
        return result;
    } // end of translate

    /**
     * @description translate a log record into an AcccApplicationLog__c
     *
     * @param LoggingLevel logging level
     * @param List<Object> the messages
     * @return List<AcccApplicationLog__c>
     */
    public static List<AcccApplicationLog__c> translate(LoggingLevel level, List<Object> messages) {
        List<AcccApplicationLog__c> result = null;
        AcccApplicationLog__c item = null;

        if ( messages != null && messages.size() > 0) {
            result = new List<AcccApplicationLog__c> ();
            for ( integer inx = 0; inx < messages.size(); inx++) {
                item = accc_MessageTransformation.translate(level, messages[inx]);
                if ( item != null ) {
                    result.add(item);
                }
            }
        }
        return result;
    } // end of translate

    /**
     * @description map from big objects
     *
     * @param entries collection of accc_PlatformEventDAOLog
     * @return collection of accc_Org_Events__b
     */
    public static List<accc_Org_Events__b> mapFrom(List<AcccApplicationLog__c> entries) {
        List<accc_Org_Events__b> results = new List<accc_Org_Events__b>();
        String json=null, cjson=null;
        Decimal truncate=0;
        DateTime dte=null;
        if (entries != null && entries.size() > 0) {
            for (AcccApplicationLog__c item : entries) {
                json = accc_StringUtilities.THE_PARSER.parse(item);
                cjson = json.replaceFirst('^(.{' + accc_ApexConstants.MAX_JSON_SIZE +'}).*', '$1');
                truncate =cjson.length() != json.length() ? 1 : 0;
                dte = item.createdDate == null ? DateTime.now() : item.createdDate;
                results.add(  new accc_Org_Events__b(
                                  Event_Name__c = ACCCAPPLICATION_LOG_NAME,
                                  Event_Date__c = dte,
                                  Event_Date_Day__c = dte.day(),
                                  Event_Date_Month__c = dte.month(),
                                  Event_Date_Year__c = dte.year(),
                                  Event_Json__c = json,
                                  Event_Truncated__c = truncate,
                                  Number_Of_Events__c = 1
                                  )
                              );
            }
        }

        return results;
    }  // end of mapFrom
    /**
     * @description  merge all fields into a single string for consumption
     *
     * @param AcccApplicationLog__c the application log
     * @return string, merge data of ApplicationLog
     */
    public static string mergeApplicationLogData(AcccApplicationLog__c datum) {
        String result = '';
        String placeholder = 'User Role Id: {0}\n,Debug Level: {1},\nMessage: {2},\nException: {3},\nIntegration Payload: {4},\nProfile Id: {5},\nReference Id: {6},\nReference Info: {7},\nSource: {8},\nSource Function: {9},\nStack Trace: {10}\nStatistics: {11}\nCreated Date: {12}\nLast Modified Date: {13}\n';

        if ( datum != null ) {
            List<String> fillers = new List<String> {

                datum.UserRoleId__c
                , datum.DebugLevel__c
                , datum.Message__c
                , datum.Exception__c
                , datum.IntegrationPayload__c
                , datum.InvocationType__c
                , datum.profileId__c
                , datum.ReferenceId__c
                , datum.ReferenceInfo__c
                , datum.Source__c
                , datum.SourceFunction__c
                , datum.StackTrace__c
                , datum.Statistics__c
                , string.valueOf(datum.createdDate)
                , string.valueOf(datum.lastModifiedDate)
            };

            result = String.format(placeholder, fillers);
        }
        return result;

    } // end of mergeApplicationLogData

} // end of accc_MessageTransformation