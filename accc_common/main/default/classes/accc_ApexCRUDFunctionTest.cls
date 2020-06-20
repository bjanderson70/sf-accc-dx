/**
 * Copyright (c) 2017-2020, Bill Anderson.  All rights reserved.
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
 * @File Name          : accc_ApexCRUDFunctionTest.cls
 * @Description        : Test Apex CRUD Function
 * @Author             : Bill Anderson
 * @Group              : Test Layer
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    5/16/2020   Bill Anderson     Initial Version
 **/
@TestVisible
@isTest
private class accc_ApexCRUDFunctionTest {

    @TestVisible
    static final String READ_ONLY = 'ro';
    @TestVisible
    static final String SADMIN = 'sa';
    @TestVisible
    static final String PLATFORM_USER = 'sp';
    @TestVisible
    static final Map<String,String> usersTypes = new Map<String,String> {
        READ_ONLY =>'Read Only',
        SADMIN => 'System Administrator',
        PLATFORM_USER => 'Standard Platform User'
    };
    // default values in object
     @TestVisible
    static final Set<String> DEFAULT_SETTINGS = new Set<String> {
        'Debug',
        'Info'
    };

    @isTest
    static void testWithSyncAsyncWriterReadOnly(){
        // assign
        List<AcccApplicationLog__c> logs = accc_ApexCRUDFunctionTest.createTestLogs();
        accc_SObjectBaseWriter writer = new accc_SyncAsyncWriter(logs);
        // we have to set writer's crud bec/ by DEFAULT it uses inherited mode
        Boolean readOnly=false;
        User usr=accc_ApexCRUDFunctionTest.setTestUser(READ_ONLY,false,false,false);

        // readonly
        System.runAs(usr) {
            // act
            Test.startTest();
            writer.execute();
            List<AcccApplicationLog__c> rlogs = [select id from AcccApplicationLog__c];
            Test.stopTest();
            system.assertEquals(readOnly,rlogs.size() == logs.size());

        }
    }
    @isTest
    static void testWithSyncAsyncWriterAdmin(){
        // assign
        List<AcccApplicationLog__c> logs = accc_ApexCRUDFunctionTest.createTestLogs();
        accc_SObjectBaseWriter writer = new accc_SyncAsyncWriter(logs);
        // we have to set writer's crud bec/ by DEFAULT it uses inherited mode
 
        Boolean admin=true;
        User usr= accc_ApexCRUDFunctionTest.setTestUser(SADMIN,true,true,true);
        // admin
        System.runAs (usr) {
            // act
            Test.startTest();
            writer.execute();
            List<AcccApplicationLog__c> rlogs = [select id from AcccApplicationLog__c];
            Test.stopTest();
            system.assertEquals(admin,rlogs.size() == logs.size());
        }
    }
    @isTest
    static void testWithSyncAsyncWriterPlatformUser(){
        // assign
        List<AcccApplicationLog__c> logs = accc_ApexCRUDFunctionTest.createTestLogs();
        accc_SObjectBaseWriter writer = new accc_SyncAsyncWriter(logs);
        Boolean puser=false;
        User usr = accc_ApexCRUDFunctionTest.setTestUser(PLATFORM_USER,false,false,false);
        // platform User
        System.runAs(usr) {
            // act
            Test.startTest();
            writer.execute();
            List<AcccApplicationLog__c> rlogs = [select id from AcccApplicationLog__c];
            Test.stopTest();
            system.assertEquals(puser,rlogs.size() == logs.size());
        }

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
            logs.add(accc_ApexCRUDFunctionTest.createALog(item));
        }
        return logs;
    }     // end of createTestLogs
    /**
     * createTestLogs
     * @description create test records
     * @return collection of records
     */
    @TestVisible
    static AcccApplicationLog__c createALog(String name) {
        return new AcccApplicationLog__c(DebugLevel__c=name);
    }   // end of createTestLog
    /**
     * createBigObjectTestLogs
     * @description create test for bg objects records (immediate)
     * @return collection of big object records
     */
    @TestVisible
    static List<accc_Org_Events__b> createBigObjectTestLogs() {
        final List<accc_Org_Events__b> logs = new List<accc_Org_Events__b>();
        DateTime dte = DateTime.now();
        for (String item: DEFAULT_SETTINGS) {
            logs.add (new accc_Org_Events__b ( Event_Name__c = item,
                                               Event_Date__c = dte,
                                               Event_Date_Day__c = dte.day(),
                                               Event_Date_Month__c = dte.month(),
                                               Event_Date_Year__c = dte.year(),
                                               Event_Json__c = '{}',
                                               Event_Truncated__c = 0,
                                               Number_Of_Events__c = 1));
        }
        return logs;
    }   // end of createBigObjectTestLogs
    /**
     *  user
     */
    @TestVisible
    private static User setTestUser(String userNameKey,
                                    Boolean create,
                                    Boolean edit,
                                    Boolean remove){
        String name=usersTypes.get(userNameKey);
        Profile prof = [SELECT Id FROM Profile WHERE Name=:name];

        User newUser = new User(Alias = userNameKey,
                                Email='standarduser@mytest.com',
                                EmailEncodingKey='UTF-8',
                                LastName='myLastName',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                ProfileId = prof.Id,
                                TimeZoneSidKey='America/Los_Angeles',
                                UserName=userNameKey+'@mytest.com');

        insert newUser;

        accc_ApexCRUDFunctionTest.setObjectPermission(newUser,
                                                      'AcccApplicationLog__c',
                                                      create,
                                                      edit,
                                                      remove);
        accc_ApexCRUDFunctionTest.setObjectPermission(newUser,
                                                      'accc_Org_Events__b',
                                                      create,
                                                      edit,
                                                      remove);

        return newUser;
    }   // end of setTestUser

    /**
     * setObjectPermission set permissions
     */
    @TestVisible
    private static void setObjectPermission(User usr,
                                            String objectType,
                                            Boolean create,
                                            Boolean edit,
                                            Boolean remove){

        PermissionSet ps = new PermissionSet(Name = 'TestIt'+ DateTime.now().millisecond(),
                                             Label = 'Test It ' + DateTime.now().millisecond() + objectType+ ' LogTest');
        insert ps;

        ObjectPermissions oPerm = null;
        if ( objectType == 'accc_Org_Events__b') {
            oPerm=new ObjectPermissions(ParentId = ps.Id,
                                        PermissionsRead = true,
                                        PermissionsCreate = create,
                                        PermissionsDelete = remove,
                                        SObjectType = objectType);
        } else {
            oPerm=new ObjectPermissions(ParentId = ps.Id,
                                        PermissionsRead = true,
                                        PermissionsCreate = create,
                                        PermissionsEdit = edit,
                                        PermissionsDelete = remove,
                                        SObjectType = objectType);
        }

        insert oPerm;

        PermissionSetAssignment assignment = new PermissionSetAssignment(AssigneeId = usr.Id,
                                                                         PermissionSetId = ps.Id);
        insert assignment;
    }
}// end of accc_ApexCRUDFunctionTest
