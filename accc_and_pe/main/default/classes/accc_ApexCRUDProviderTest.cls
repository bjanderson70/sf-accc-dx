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
 * @File Name          : accc_ApexCRUDProviderTest.cls
 * @Description        : Test Apex CRUD Provider
 * @Author             : Bill Anderson
 * @Group              : Test Layer
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    5/16/2020   Bill Anderson     Initial Version
 **/

@isTest
private class accc_ApexCRUDProviderTest {
    // default values in object
    static final Set<String> DEFAULT_SETTINGS = new Set<String> {
        'Debug','Info'
    };

    @isTest
    static void ctorTest() {
        // assign /act
        accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();
        accc_ApexDMLOptions options = provider.getDmlOptions();
        //assert
        system.assertEquals(true, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(accc_ApexDMLOptions.DMLMode.SYNC, options.theDMLMode);
        system.assertEquals(accc_ApexDMLOptions.ExecutionMode.INHERITED_MODE, options.theExecutionMode);

    }
    @isTest
    static void ctorWithEexcutionModeTest() {
        // assign /act
        accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(accc_ApexDMLOptions.ExecutionMode.USER_MODE);
        accc_ApexDMLOptions options = provider.getDmlOptions();
        //assert
        system.assertEquals(true, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(accc_ApexDMLOptions.DMLMode.SYNC, options.theDMLMode);
        system.assertEquals(accc_ApexDMLOptions.ExecutionMode.USER_MODE, options.theExecutionMode);

    }
    @isTest
    static void ctorWithDMLOptionTest() {
        // assign

        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.OptAllOrNone=false;
        dmlOption.allowFieldTruncation=true;
        accc_ApexDMLOptions options = new accc_ApexDMLOptions(dmlOption);
        // act
        accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(options);

        options = provider.getDmlOptions();
        //assert
        system.assertEquals(false, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(true, options.getDmlOptions().allowFieldTruncation);
        system.assertEquals(accc_ApexDMLOptions.DMLMode.SYNC, options.theDMLMode);
        system.assertEquals(accc_ApexDMLOptions.ExecutionMode.INHERITED_MODE, options.theExecutionMode);


    }
    @isTest
    static void setDMLOptionTest() {

        // assign
        Database.DMLOptions results=null;
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.OptAllOrNone=false;
        dmlOption.allowFieldTruncation=false;

        accc_ApexDMLOptions options = new accc_ApexDMLOptions(dmlOption),
                            result=null;
        accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();
        // act
        result = provider.setDmlOptions(options);
        //assert
        system.assertEquals(true, result.getDmlOptions().OptAllOrNone);
        system.assertEquals(false, result.getDmlOptions().allowFieldTruncation);
        // new settings
        system.assertEquals(false, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(false, options.getDmlOptions().allowFieldTruncation);
        system.assertEquals(accc_ApexDMLOptions.DMLMode.SYNC, options.theDMLMode);
        system.assertEquals(accc_ApexDMLOptions.ExecutionMode.INHERITED_MODE, options.theExecutionMode);

    }
    @isTest
    static void getAccesibleTest() {

        // assign
        Set<System.AccessType> access = new  Set<System.AccessType> {
            System.AccessType.CREATABLE,
            System.AccessType.READABLE,
            System.AccessType.UPDATABLE,
            System.AccessType.UPSERTABLE
        };
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.OptAllOrNone=true;
        dmlOption.allowFieldTruncation=false;

        accc_ApexDMLOptions options = new accc_ApexDMLOptions(dmlOption);
        accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(options);
        final List<AcccApplicationLog__c> logs = createTestLogs();
        final integer size = logs.size();

        // we are in system mode
        for (System.AccessType acc : access ) {
            // act
            List<AcccApplicationLog__c> result = (List<AcccApplicationLog__c>)provider.getAccessibleRecords(logs, acc);
            //assert
            system.assertEquals(size, result.size());
            for (AcccApplicationLog__c item: result ) {
                system.assertEquals(true, DEFAULT_SETTINGS.contains(item.DebugLevel__c ));
            }
        }
        // act
        List<AcccApplicationLog__c> resultForDelete = (List<AcccApplicationLog__c>)provider.getAccessibleRecords(logs);
        //assert
        system.assertEquals(size, resultForDelete.size());
        for (AcccApplicationLog__c item: resultForDelete ) {
            system.assertEquals(true, DEFAULT_SETTINGS.contains(item.DebugLevel__c ));
        }

        // insert our records to updated
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert logs;
        }
        // allowed to create
        User ruser = setTestUser(false,false,false);
        List<AcccApplicationLog__c> result=null;
        System.runAs(ruser) {
            Boolean noAccess = false;
            // we are in system mode
            for (System.AccessType acc : access ) {
                noAccess = acc==System.AccessType.READABLE ? true : false;
                result=null;
                // act
                try {
                    result = (List<AcccApplicationLog__c>)provider.getAccessibleRecords(logs, acc);
                } catch ( Exception excp) {
                    noAccess=true;
                }
                //assert
                if ( acc!=System.AccessType.READABLE) {
                    system.assertEquals(null, result);
                } else {
                    system.assertEquals(true, result!=null);
                }
                system.assertEquals(true, noAccess);

            }
            noAccess = false;
            try {
                // act
                resultForDelete = (List<AcccApplicationLog__c>)provider.getAccessibleRecords(logs);
            } catch (Exception excp) {
                noAccess=true;
            }
            //assert
            system.assertEquals(true, noAccess);

        }
    }
    @isTest
    static void determineDMLAllowedTest() {
        // allowed to create, edit
        User ruser = setTestUser(true,true,false);
        System.runAs(ruser) {
            final List<AcccApplicationLog__c> logs = createTestLogs();
            final integer size = logs.size();
            // this test inherited mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();

            // act
            Boolean result=provider.determineDMLAllowed(logs,
                                                        accc_ApexDMLOptions.DMLAction.INSERTABLE);
            // assert
            system.assertEquals(true, result);
            //act
            result=provider.determineDMLAllowed(logs,
                                                accc_ApexDMLOptions.DMLAction.UPDATEABLE);
            // assert
            system.assertEquals(true, result);
            //act
            result=provider.determineDMLAllowed(logs,
                                                accc_ApexDMLOptions.DMLAction.READABLE);
            // assert
            system.assertEquals(true, result);
            //act
            result=provider.determineDMLAllowed(logs,
                                                accc_ApexDMLOptions.DMLAction.UPSERTABLE);
            // assert
            system.assertEquals(true, result);
            // act
            result=provider.determineDMLAllowed(logs,
                                                accc_ApexDMLOptions.DMLAction.DELETABLE);
            // assert
            system.assertEquals(false, result);
            // act
            result=provider.determineDMLAllowed(logs,
                                                accc_ApexDMLOptions.DMLAction.ALL);
            // assert
            system.assertEquals(false, result);
        }
    }
    @isTest
    static void determineDMLAllowedWithNoAccessTest() {
        // not allowed to create, edit, create
        User ruser = setTestUser(false,false,false);
        System.runAs(ruser) {
            final List<AcccApplicationLog__c> logs = createTestLogs();
            final integer size = logs.size();
            // this test inherited mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();

            // act
            Boolean result=provider.determineDMLAllowed(logs,
                                                        accc_ApexDMLOptions.DMLAction.INSERTABLE);
            // assert
            system.assertEquals(false, result);
            //act
            result=provider.determineDMLAllowed(logs,
                                                accc_ApexDMLOptions.DMLAction.READABLE);
            // assert
            system.assertEquals(true, result);
            //act
            result=provider.determineDMLAllowed(logs,
                                                accc_ApexDMLOptions.DMLAction.UPDATEABLE);
            // assert
            system.assertEquals(false, result);
            //act
            result=provider.determineDMLAllowed(logs,
                                                accc_ApexDMLOptions.DMLAction.UPSERTABLE);
            // assert
            system.assertEquals(false, result);
            // act
            result=provider.determineDMLAllowed(logs,
                                                accc_ApexDMLOptions.DMLAction.DELETABLE);
            // assert
            system.assertEquals(false, result);
            // act
            result=provider.determineDMLAllowed(logs,
                                                accc_ApexDMLOptions.DMLAction.ALL);
            // assert
            system.assertEquals(false, result);
        }
    }
    @isTest
    static void badArgumentsTest() {
        // assign

        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.OptAllOrNone=false;
        dmlOption.allowFieldTruncation=true;
        accc_ApexDMLOptions options = new accc_ApexDMLOptions(dmlOption);
        accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(options);
        // act
        accc_GenericDbResultHandler result=provider.insertDb(null);
        // assert
        system.assertEquals (0, result.dbErrors.size());
        // act
        result=provider.updateDb(null);
        // assert
        system.assertEquals (0, result.dbErrors.size());
        // act
        result=provider.upsertDb(null);
        // assert
        system.assertEquals (0, result.dbErrors.size());
        // act
        result=provider.deleteDb(null);
        // assert
        system.assertEquals (0, result.dbErrors.size());

    }

    //++++++++++++++++++++
    // Insert ( Immediate) --
    //++++++++++++++++++++
    @isTest
    static void insertImmediateDataWithCreateUserTest() {
        // allowed to create
        User ruser = setTestUser(true,false,false);
        System.runAs(ruser) {
            final List<accc_Org_Events__b> logs = accc_ApexCRUDProviderTest.createBigObjectTestLogs();
            final integer size = logs.size();
            accc_ApexDMLOptions options = new accc_ApexDMLOptions();
            options.theDMLMode= accc_ApexDMLOptions.DMLMode.IMMEDIATE;
            options.theExecutionMode= accc_ApexDMLOptions.ExecutionMode.USER_MODE;
            // this test user mode (with sharing)
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(options);

            Test.startTest();
            // act
            accc_GenericDbResultHandler result=provider.insertDb(logs);
            Test.stopTest();
            // assert insert
            system.assertEquals(false, result.hasErrors());

        }
    }
    //++++++++++++++++++++
    // Insert (With Sharing) -- User Mode
    //++++++++++++++++++++
    @isTest
    static void insertDataWithCreateUserTest() {
        // allowed to create, update
        User ruser = setTestUser(true,true,false);
        System.runAs(ruser) {
            final List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();
            final integer size = logs.size();
            // this test user mode (with sharing)
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(accc_ApexDMLOptions.ExecutionMode.USER_MODE);

            Test.startTest();
            // act
            accc_GenericDbResultHandler result=provider.insertDb(logs);
            // ensure logs present
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert insert
            system.assertEquals(false, result.hasErrors());
            system.assertEquals(size, foundLogs.size());
            for (AcccApplicationLog__c item: foundLogs ) {
                system.assertEquals(true, DEFAULT_SETTINGS.contains(item.DebugLevel__c ));
            }

        }
    }

    @isTest
    static void insertDataWithNoCreateUserTest() {
        // not allowed to create, update
        User ruser = setTestUser(false,false,false);
        Boolean hasException=false;
        System.runAs(ruser) {
            final List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();
            final integer size = logs.size();
            // this test user mode (with sharing)
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(accc_ApexDMLOptions.ExecutionMode.USER_MODE);

            Test.startTest();
            // act
            try {
                accc_GenericDbResultHandler result=provider.insertDb(logs);
            } catch ( System.NoAccessException excp) {
                hasException=true;
            }
            // get logs
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert insert
            system.assertEquals(true, hasException);
            system.assertEquals(0, foundLogs.size());

        }
    }
    //++++++++++++++++++++
    // Insert (Inherited)
    //++++++++++++++++++++
    @isTest
    static void insertDataWithCreateInheritedTest() {
        // allowed to create
        User ruser = setTestUser(true,true,false);
        System.runAs(ruser) {
            final List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();
            final integer size = logs.size();
            // this test inherited mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();
            Test.startTest();
            // act
            accc_GenericDbResultHandler result=provider.insertDb(logs);
            // ensure logs present
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert insert
            system.assertEquals(false, result.hasErrors());
            system.assertEquals(size, foundLogs.size());
            for (AcccApplicationLog__c item: foundLogs ) {
                system.assertEquals(true, DEFAULT_SETTINGS.contains(item.DebugLevel__c ));
            }
        }
    }

    @isTest
    static void insertDataWithNoCreateInheritedTest() {
        // not allowed to create
        User ruser = setTestUser(false,true,false);
        System.runAs(ruser) {
            final List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();
            Boolean hasException =false;
            // this test inherited mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();
            Test.startTest();
            // act
            try {
                accc_GenericDbResultHandler result=provider.insertDb(logs);
            } catch ( System.NoAccessException excp) {
                hasException=true;
            }
            // get logs
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert insert
            system.assertEquals(true, hasException);
            system.assertEquals(0, foundLogs.size());
        }
    }
    //++++++++++++++++++++
    // Update ( Immediate) --
    //++++++++++++++++++++
    @isTest
    static void updateImmediateDataWithCreateUserTest() {
        // allowed to create
        User ruser = setTestUser(true,false,false);
        Boolean noAccess=false;
        System.runAs(ruser) {
            final List<accc_Org_Events__b> logs = accc_ApexCRUDProviderTest.createBigObjectTestLogs();
            final integer size = logs.size();
            accc_ApexDMLOptions options = new accc_ApexDMLOptions();
            options.theDMLMode= accc_ApexDMLOptions.DMLMode.IMMEDIATE;
            options.theExecutionMode= accc_ApexDMLOptions.ExecutionMode.USER_MODE;
            // this test user mode (with sharing)
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(options);

            Test.startTest();
            // act
            try {
                // user has no update access
                accc_GenericDbResultHandler result=provider.updateDb(logs);
            } catch (Exception excp ) {
                noAccess=true;
            }
            Test.stopTest();
            // assert insert
            system.assertEquals(true,noAccess);

        }
    }
    //++++++++++++++++++++
    // Update ( Immediate) --
    //++++++++++++++++++++
    @isTest
    static void updateImmediateDataWithCreateSystemTest() {
        // allowed to create
        User ruser = setTestUser(true,false,false);

        System.runAs(ruser) {
            final List<accc_Org_Events__b> logs = accc_ApexCRUDProviderTest.createBigObjectTestLogs();
            final integer size = logs.size();
            accc_ApexDMLOptions options = new accc_ApexDMLOptions();
            options.theDMLMode= accc_ApexDMLOptions.DMLMode.IMMEDIATE;
            options.theExecutionMode= accc_ApexDMLOptions.ExecutionMode.SYSTEM_MODE;
            // this test user mode (without sharing)
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(options);

            Test.startTest();
            // act
            // system has  update access
            accc_GenericDbResultHandler result=provider.updateDb(logs);
            Test.stopTest();
            // assert update
            system.assertEquals(false,result.hasErrors());

        }
    }
    //++++++++++++++++++++
    // Update (Inherited)
    //++++++++++++++++++++
    @isTest
    static void updateDataWithCreateInheritedTest() {
        List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();

        // insert our records to updated
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert logs;
        }
        // user has edit mode
        User ruser = setTestUser(false,true,false);

        System.runAs(ruser) {
            final Set<String> expectedStrings = new Set<String> {
                'Error','Warn'
            };
            final integer size = logs.size();
            Test.startTest();
            // this test inherited mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();
            logs = [select Id,DebugLevel__c from AcccApplicationLog__c];
            logs[0].DebugLevel__c ='Error';
            logs[1].DebugLevel__c ='Warn';
            // act
            accc_GenericDbResultHandler result=provider.updateDb(logs);
            // ensure logs present
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert insert
            system.assertEquals(false, result.hasErrors());
            system.assertEquals(size, foundLogs.size());
            for (AcccApplicationLog__c item: foundLogs ) {
                system.assertEquals(true, expectedStrings.contains(item.DebugLevel__c));
            }
        }
    }

    @isTest
    static void updateDataWithNoCreateInheritedTest() {
        List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();

        // insert our records to updated
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert logs;
        }
        // user not allowed to update
        User ruser = setTestUser(true,false,false);
        System.runAs(ruser) {

            Boolean hasException =false;
            // this test inherited mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();
            Test.startTest();
            // act
            try {
                accc_GenericDbResultHandler result=provider.updateDb(logs);
            } catch ( System.NoAccessException excp) {
                hasException=true;
            }
            // get logs
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert insert
            system.assertEquals(true, hasException);
            // previous inserts should be present
            system.assertEquals(2, foundLogs.size());
        }
    }

    //++++++++++++++++++++
    // Upsert (Inherited)
    //++++++++++++++++++++
    @isTest
    static void upsertDataWithCreateInheritedTest() {
        List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();

        // insert our records to updated
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert logs;
        }
        // user has edit mode
        User ruser = setTestUser(true,true,false);

        System.runAs(ruser) {
            Set<String> expectedStrings = DEFAULT_SETTINGS;
            expectedStrings.add('Error');
            expectedStrings.add('Warn');

            final integer size = logs.size();
            // this test inherited mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();
            Test.startTest();
            // act
            accc_GenericDbResultHandler result=provider.upsertDb (new List<SObject> {
                createALog('Error'),
                createALog('Warn')
            });
            // ensure logs present
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert insert
            system.assertEquals(false, result.hasErrors());
            system.assertEquals(size+2, foundLogs.size());
            for (AcccApplicationLog__c item: foundLogs ) {
                system.assertEquals(true, expectedStrings.contains(item.DebugLevel__c));
            }
        }
    }

    @isTest
    static void upsertDataWithNoCreateInheritedTest() {
        List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();

        // insert our records to updated
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert logs;
        }
        // user not allowed to update
        User ruser = setTestUser(true,false,false);
        System.runAs(ruser) {

            Boolean hasException =false;
            // this test inherited mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();
            Test.startTest();
            // act
            try {
                accc_GenericDbResultHandler result=provider.upsertDb(logs);
            } catch ( System.NoAccessException excp) {
                hasException=true;
            }
            // get logs
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert insert
            system.assertEquals(true, hasException);
            // previous inserts should be present
            system.assertEquals(2, foundLogs.size());
        }
    }
    //++++++++++++++++++++
    // Delete (Inherited)
    //++++++++++++++++++++
    @isTest
    static void deleteDataWithCreateInheritedTest() {
        List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();

        // user can delete
        User ruser = setTestUser(true,true,true);

        System.runAs(ruser) {
            Test.startTest();
            insert logs;
            // this test inherited mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();
            // act
            accc_GenericDbResultHandler result=provider.deleteDb (logs);
            // ensure logs present
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert insert
            system.assertEquals(false, result.hasErrors());
            system.assertEquals(0, foundLogs.size());
        }
    }

    @isTest
    static void deleteDataWithNoCreateInheritedTest() {
        List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();

        // insert our records to delete
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert logs;
        }
        // user not allowed to delete mode
        User ruser = setTestUser(true,true,false);
        System.runAs(ruser) {

            Boolean hasException =false;
            Test.startTest();
            // this test inherited mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider();
            // act
            try {
                accc_GenericDbResultHandler result=provider.deleteDb(logs);
            } catch ( Exception excp) {
                hasException=true;
            }
            // get logs
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert delete
            system.assertEquals(true, hasException);
            // previous inserts should be present
            system.assertEquals(logs.size(), foundLogs.size());
        }
    }
    //++++++++++++++++++++
    // Delete ( Immediate) --
    //++++++++++++++++++++
    @isTest
    static void deleteImmediateDataWithCreateUserAndSystemTest() {
        User ruser = setTestUser(true,true,false);
        System.runAs(ruser) {
            Boolean noAccess=false;
            final List<accc_Org_Events__b> logs = accc_ApexCRUDProviderTest.createBigObjectTestLogs();
            final integer size = logs.size();
            accc_ApexDMLOptions options = new accc_ApexDMLOptions();
            options.theDMLMode= accc_ApexDMLOptions.DMLMode.IMMEDIATE;
            options.theExecutionMode= accc_ApexDMLOptions.ExecutionMode.USER_MODE;
            // this test user mode (with sharing)
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(options);

            Test.startTest();
            try {
                // act
                accc_GenericDbResultHandler result=provider.deleteDb(logs);
            } catch (Exception excp) {
                noAccess=true;
            }
            Test.stopTest();
            // assert insert
            system.assertEquals(true, noAccess);
            /*
             * Switch to Syatem Mode
             */
            options = new accc_ApexDMLOptions();
            options.theDMLMode= accc_ApexDMLOptions.DMLMode.IMMEDIATE;
            options.theExecutionMode= accc_ApexDMLOptions.ExecutionMode.SYSTEM_MODE;
            // this test user mode (without sharing)
            provider = new accc_ApexCRUDProvider(options);
            accc_GenericDbResultHandler result=provider.deleteDb(logs);
            // assert delete
            system.assertEquals(false, result.hasErrors());

        }
    }

    //++++++++++++++++++++
    // Delete (System Mode)
    //++++++++++++++++++++
    @isTest
    static void deleteDataWithCreateSystemTest() {
        List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();

        // user has remove rights (but using system mode)
        User ruser = setTestUser(true,true,true);

        System.runAs(ruser) {
            Test.startTest();
            insert logs;
            // this test System mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(accc_ApexDMLOptions.ExecutionMode.SYSTEM_MODE);
            // act
            accc_GenericDbResultHandler result=provider.deleteDb (logs);
            // ensure logs present
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert
            system.assertEquals(false, result.hasErrors());
            system.assertEquals(0, foundLogs.size());
        }
    }

    @isTest
    static void deleteDataWithNoCreateSystemTest() {
        List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();
        // user has rights and allowed to delete mode [role heirarchy]
        User ruser = setTestUser(true,true,true);
        System.runAs(ruser) {

            Boolean hasException =false;
            Test.startTest();
            insert logs;
            // this test System mode; however, the role heirarchy comes into play
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(accc_ApexDMLOptions.ExecutionMode.SYSTEM_MODE);
            // act
            try {
                accc_GenericDbResultHandler result=provider.deleteDb(logs);
            } catch ( Exception excp) {
                hasException=true;
            }
            // get logs
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert delete
            system.assertEquals(false, hasException);
            // previous inserts should be present
            system.assertEquals(0, foundLogs.size());
        }
    }
    //++++++++++++++++++++
    // Upsert (System Mode)
    //++++++++++++++++++++
    @isTest
    static void upsertDataWithCreateSystemTest() {
        List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();

        // insert our records to updated
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert logs;
        }
        // user (no permissions)
        User ruser = setTestUser(false,false,false);

        System.runAs(ruser) {
            Set<String> expectedStrings = DEFAULT_SETTINGS;
            expectedStrings.add('Error');

            final integer size = logs.size();
            // this test System mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(accc_ApexDMLOptions.ExecutionMode.SYSTEM_MODE);
            Test.startTest();
            // act
            accc_GenericDbResultHandler result=provider.upsertDb (new List<SObject> {createALog('Error')});
            // ensure logs present
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert insert
            system.assertEquals(false, result.hasErrors());
            system.assertEquals(size+1, foundLogs.size());
            for (AcccApplicationLog__c item: foundLogs ) {
                system.assertEquals(true, expectedStrings.contains(item.DebugLevel__c));
            }
        }
    }

    @isTest
    static void upsertDataWithNoCreateSystemTest() {
        List<AcccApplicationLog__c> logs = accc_ApexCRUDProviderTest.createTestLogs();

        // insert our records to updated
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert logs;
        }
        // user (no permisions - except read)
        User ruser = setTestUser(false,false,false);
        System.runAs(ruser) {

            Boolean hasException =true;
            // this test System mode
            accc_IApexCRUDProvider provider = new accc_ApexCRUDProvider(accc_ApexDMLOptions.ExecutionMode.SYSTEM_MODE);
            Test.startTest();
            // act
            try {
                accc_GenericDbResultHandler result=provider.upsertDb(logs);
            } catch ( System.NoAccessException excp) {
                hasException=false;
            }
            // get logs
            List<AcccApplicationLog__c> foundLogs = [select DebugLevel__c from AcccApplicationLog__c];
            Test.stopTest();
            // assert insert
            system.assertEquals(true, hasException);
            // previous inserts should be present
            system.assertEquals(2, foundLogs.size());
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
            logs.add(accc_ApexCRUDProviderTest.createALog(item));
        }
        return logs;
    }  // end of createTestLogs
    /**
     * createTestLogs
     * @description create test records
     * @return collection of records
     */
    @TestVisible
    static AcccApplicationLog__c createALog(String name) {
        return new AcccApplicationLog__c(DebugLevel__c=name);
    }// end of createTestLog
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
    }// end of createBigObjectTestLogs
    /**
     * readonly user
     */
    @TestVisible
    private static User setTestUser(Boolean create, Boolean edit, Boolean remove){
        Profile prof = [SELECT Id FROM Profile WHERE Name='Read Only'];

        User newUser = new User(Alias = 'readonly',
                                Email='standarduser@mytest.com',
                                EmailEncodingKey='UTF-8',
                                LastName='TestingReadOnly',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                ProfileId = prof.Id,
                                TimeZoneSidKey='America/Los_Angeles',
                                UserName='readonly@mytest.com');

        insert newUser;

        accc_ApexCRUDProviderTest.setObjectPermission(newUser,
                                                      'AcccApplicationLog__c',
                                                      create,
                                                      edit,
                                                      remove);
        accc_ApexCRUDProviderTest.setObjectPermission(newUser,
                                                      'accc_Org_Events__b',
                                                      create,
                                                      edit,
                                                      remove);

        return newUser;
    }// end of setTestUser

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
                                             Label = 'Test It ' + objectType+ ' LogTest');
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
}// end of accc_ApexCRUDProviderTest