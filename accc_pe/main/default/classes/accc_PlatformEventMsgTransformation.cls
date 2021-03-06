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
 * @description  Translate event messages to another type
 * @group Event Layer
 */
public inherited sharing  class accc_PlatformEventMsgTransformation {

    /**
     * @description translate a ApplicationLog to a accc_Log__e
     *
     * @param appLog Application Log
     * @return accc_Log__e
     */
    public static accc_Log__e translate(AcccApplicationLog__c datum) {
        accc_Log__e result = null;

        if ( datum != null ) {
            result = new accc_Log__e(LogCode__c = accc_ApexUtilities.toString(datum.LogCode__c),
                                     Message__c = accc_MessageTransformation.mergeApplicationLogData(datum),
                                     Username__c = UserInfo.getUserId());
        }
        return result;

    }  // end of translate
       /**
        * @description translate a ApplicationLog to a accc_Log__e
        *
        * @param appLog Application Log
        * @return accc_Log__e
        */
    public static List<accc_Log__e> translate(List<AcccApplicationLog__c> listDatum) {
        List<accc_Log__e> result = null;

        if ( listDatum != null && listDatum.size() > 0) {
            accc_Log__e elog;
            result = new List<accc_Log__e>();
            for (AcccApplicationLog__c datum : listDatum) {
                elog = accc_PlatformEventMsgTransformation.translate(datum);
                if ( elog != null) {
                    result.add(elog);
                }
            }
        }
        return result;

    } // end of translate

    /**
     * @description translate a accc_Log__e to a AcccApplicationLog__c
     *
     * @param datum, accc_Log__e
     * @return AcccApplicationLog__c
     */
    public static AcccApplicationLog__c translate(accc_Log__e datum) {
        AcccApplicationLog__c result = null;

        if ( datum != null ) {
            Id userId = datum.Username__c == null? UserInfo.getUserId() :datum.Username__c;
            result = new AcccApplicationLog__c(LogCode__c =  accc_ApexUtilities.toString(datum.LogCode__c),
                                               Message__c =   accc_ApexUtilities.toString(datum.Message__c),
                                               Source__c = 'Log Platform Event',
                                               OwnerId = userId,
                                               Username__c = userId);
        }
        return result;

    }  // end of translate
    /**
     * @description translate a accc_Log__e to a AcccApplicationLog__c
     *
     * @param List<accc_Log__e> list of log events
     * @return List<AcccApplicationLog__c> list of applicationLog
     */
    public static List<AcccApplicationLog__c> translate(List<accc_Log__e> listDatum) {
        List<AcccApplicationLog__c> result = null;

        if ( listDatum != null && listDatum.size() > 0 ) {
            AcccApplicationLog__c appLog;
            result = new List<AcccApplicationLog__c>();
            for (accc_Log__e datum : listDatum ) {
                appLog = accc_PlatformEventMsgTransformation.translate(datum);
                if ( appLog != null) {
                    result.add(appLog);
                }
            }
        }
        return result;

    }  // end of translate
    /**
     * @description translate a ACCC_Log_Event__e to a AcccApplicationLog__c
     *
     * @param datum ACCC_Log_Event__e
     * @return AcccApplicationLog__c
     */
    public static AcccApplicationLog__c translate(ACCC_Log_Event__e datum) {
        AcccApplicationLog__c result = null;
        Id userId = UserInfo.getUserId();

        if ( datum != null ) {
            // check the only data that is referencing a method
            // to ensure things progress. If this gets too crazy,
            // will create a separate method
            if (datum.DateTime__c == null ) {
                datum.DateTime__c = DateTime.now();
            }
            result = new AcccApplicationLog__c(LogCode__c =  datum.Action__c,
                                               Source__c = datum.External_Id__c,
                                               SourceFunction__c = datum.MessageId__c,
                                               ReferenceId__c = datum.TransactionId__c,
                                               Exception__c= datum.Exception__c,
                                               InvocationType__c= datum.Object_Name__c,
                                               IntegrationPayload__c  = datum.Payload__c,
                                               OwnerId = userId,
                                               Username__c = datum.UserId__c,
                                               Timer__c =datum.DateTime__c.getTime(),
                                               Message__c = datum.Sequence_Number__c + '-' + datum.Total_Number__c,
                                               ReferenceInfo__c=datum.Version__c
                                               );
        }
        return result;

    }     // end of translate
    /**
     * @description translate a ACCC_Log_Event__e to a AcccApplicationLog__c
     *
     * @param List<accc_LoACCC_Log_Event__eg__e> list of log events
     * @return List<AcccApplicationLog__c> list of applicationLog
     */
    public static List<AcccApplicationLog__c> translate(List<ACCC_Log_Event__e> listDatum) {
        List<AcccApplicationLog__c> result = null;

        if ( listDatum != null && listDatum.size() > 0 ) {
            AcccApplicationLog__c appLog;
            result = new List<AcccApplicationLog__c>();
            for (ACCC_Log_Event__e datum : listDatum ) {
                appLog = accc_PlatformEventMsgTransformation.translate(datum);
                if ( appLog != null) {
                    result.add(appLog);
                }
            }
        }
        return result;

    }     // end of translate

    /**
     * @description map from AcccApplicationLog__c to accc_PlatformEventDAOLog
     * Apex does not distinguish properly (the parameter types are distinct enough) as
     * there is no Covariance or Contravariant  in play here. Had to call, 'translateFromAppLog'
     * instead of 'translate'.
     *
     * @param entries collection of AcccApplicationLog__c
     * @return collection of accc_PlatformEventDAOLog
     */
    public static List<accc_PlatformEventDAOLog> translateFromAppLog(List<AcccApplicationLog__c> entries) {
        List<accc_PlatformEventDAOLog> results = new List<accc_PlatformEventDAOLog>();
        accc_PlatformEventDAOLog entry = null;
        Datetime now = Datetime.now();
        if ( entries != null && entries.size() > 0) {
            for (AcccApplicationLog__c item : entries) {
                // we create a local DAO as it does much of the calculation
                // as well as filling in whether truncated, day, month, etc.
                entry = new accc_PlatformEventDAOLog(
                    String.isBlank(item.Source__c) ?  'Unknown' : item.Source__c,
                    // String.isBlank(item.SourceFunction__c) ?  'Create' : item.SourceFunction__c  ,
                    String.isBlank(item.Message__c) ? accc_ApexConstants.EMPTY_JSON_s : item.Message__c,
                    now);
                // entry.userId = string.isBlank(item.Username__c) ? string.isBlank(item.OwnerId) ? UserInfo.getUserId() : item.OwnerId : item.Username__c;
                //entry.theException = item.Exception__c;
                results.add(entry);
            }
        }
        return results;

    }// end of translateFromAppLog

} // end of accc_PlatformEventMsgTransformation