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
 * @File Name          : accc_ApexDMLOptionsTest.cls
 * @Description        : Test Apex DML Options for CRUD
 * @Author             : Bill Anderson
 * @Group              : Common
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    1/8/2017   Bill Anderson     Initial Version
 **/

@isTest
private class accc_ApexDMLOptionsTest {

    @isTest static void defaultCtorTest() {
        // assign / act
        accc_ApexDMLOptions options = new accc_ApexDMLOptions();

        //assert
        system.assertEquals(true, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(accc_ApexDMLOptions.DMLMode.SYNC, options.theDMLMode);
        system.assertEquals(accc_ApexDMLOptions.ExecutionMode.INHERITED_MODE, options.theExecutionMode);
        
    }

    @isTest static void ctorWithDMLOptionParamTest() {
        // assign
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.OptAllOrNone=false;
        dmlOption.allowFieldTruncation=true;

        // act
        accc_ApexDMLOptions options = new accc_ApexDMLOptions(dmlOption);

        //assert
        system.assertEquals(false, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(true, options.getDmlOptions().allowFieldTruncation);
        system.assertEquals(accc_ApexDMLOptions.DMLMode.SYNC, options.theDMLMode);
        system.assertEquals(accc_ApexDMLOptions.ExecutionMode.INHERITED_MODE, options.theExecutionMode);
 
    }

    @isTest static void ctorWithDMLAndDMLOptionParamTest() {
        // assign
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.OptAllOrNone=true;
        dmlOption.allowFieldTruncation=false;

        // act
        accc_ApexDMLOptions options = new accc_ApexDMLOptions(accc_ApexDMLOptions.DMLMode.SYNC, dmlOption);

        //assert
        system.assertEquals(true, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(false, options.getDmlOptions().allowFieldTruncation);
        system.assertEquals(accc_ApexDMLOptions.ExecutionMode.INHERITED_MODE, options.theExecutionMode);

    }

    @isTest static void ctorWithExecutionModeParamTest() {
        // assign
        // act
        accc_ApexDMLOptions options = new accc_ApexDMLOptions(accc_ApexDMLOptions.ExecutionMode.SYSTEM_MODE);

        //assert
        system.assertEquals(true, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(false, options.getDmlOptions().allowFieldTruncation);
        system.assertEquals(accc_ApexDMLOptions.DMLMode.SYNC, options.theDMLMode);
        system.assertEquals(accc_ApexDMLOptions.ExecutionMode.SYSTEM_MODE, options.theExecutionMode);
    }

    @isTest static void ctorWithExecModeAndDMLAndDMLOptionParamTest() {
        // assign
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.OptAllOrNone=true;
        dmlOption.allowFieldTruncation=true;

        // act
        accc_ApexDMLOptions options = new accc_ApexDMLOptions(accc_ApexDMLOptions.ExecutionMode.USER_MODE,
                                                              accc_ApexDMLOptions.DMLMode.IMMEDIATE,
                                                              dmlOption);

        //assert
        system.assertEquals(true, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(true, options.getDmlOptions().allowFieldTruncation);
        system.assertEquals(accc_ApexDMLOptions.DMLMode.IMMEDIATE, options.theDMLMode);
        system.assertEquals(accc_ApexDMLOptions.ExecutionMode.USER_MODE, options.theExecutionMode);
       
    }

    @isTest static void ctorWithAllParamsTest() {
        // assign
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.OptAllOrNone=true;
        dmlOption.allowFieldTruncation=false;
         // act
        accc_ApexDMLOptions options = new accc_ApexDMLOptions(accc_ApexDMLOptions.ExecutionMode.USER_MODE,
                                                              accc_ApexDMLOptions.DMLMode.IMMEDIATE,
                                                              dmlOption
                                                              );

        //assert
        system.assertEquals(true, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(false, options.getDmlOptions().allowFieldTruncation);
        system.assertEquals(accc_ApexDMLOptions.DMLMode.IMMEDIATE, options.theDMLMode);
        system.assertEquals(accc_ApexDMLOptions.ExecutionMode.USER_MODE, options.theExecutionMode);
       
    }

    @isTest static void ctorWithAllUpdateCallbackParamsTest() {
        // assign
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.OptAllOrNone=true;
        dmlOption.allowFieldTruncation=false;
         // act
        accc_ApexDMLOptions options = new accc_ApexDMLOptions(accc_ApexDMLOptions.ExecutionMode.USER_MODE,
                                                              accc_ApexDMLOptions.DMLMode.IMMEDIATE,
                                                              dmlOption
                                                              );

        //assert
        system.assertEquals(true, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(false, options.getDmlOptions().allowFieldTruncation);
        system.assertEquals(accc_ApexDMLOptions.DMLMode.IMMEDIATE, options.theDMLMode);
        system.assertEquals(accc_ApexDMLOptions.ExecutionMode.USER_MODE, options.theExecutionMode);

    }

    @isTest static void setDmlOptionsTest() {
        // assign
        Database.DMLOptions results=null;
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.OptAllOrNone=false;
        dmlOption.allowFieldTruncation=false;
       
        accc_ApexDMLOptions options = new accc_ApexDMLOptions();

        //assert
        system.assertEquals(true, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(false, options.getDmlOptions().allowFieldTruncation);

        // act
        results=options.setDmlOptions(dmlOption);
        //assert
        system.assertEquals(false, options.getDmlOptions().OptAllOrNone);
        system.assertEquals(false, options.getDmlOptions().allowFieldTruncation);
        system.assertEquals(true, results.OptAllOrNone);
        system.assertEquals(false, results.allowFieldTruncation);

    }
}// end of accc_ApexDMLOptionsTest