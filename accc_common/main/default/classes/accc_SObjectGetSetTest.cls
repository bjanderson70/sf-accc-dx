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
 * @description  Test class for the  accc_SObjectGetSet methods
 * @group Test Layer
 */
@isTest
private class accc_SObjectGetSetTest {

    @isTest
    static void defaultCtorTest() {
        // assign/act
        accc_SObjectGetSet ctor = new accc_SObjectGetSet();
        // assert
        system.assertEquals(false, ctor.ignoreExceptionOnGetField);
        system.assertEquals(null, ctor.theException);
        system.assertEquals(null, ctor.DEFAULT_RETURN_VALUE);
        system.assertEquals(null, ctor.sObjects);
        system.assertEquals(null, ctor.domain);
        system.assertEquals(true, ctor.usesRelatedObjects);
        system.assertEquals(false, ctor.checkIncomingTypes);

    }
    @isTest
    static void ctorWithOneParamTest() {
        // assign/act
        accc_SObjectGetSet ctor = new accc_SObjectGetSet('hello');
        // assert
        system.assertEquals(false, ctor.ignoreExceptionOnGetField);
        system.assertEquals(null, ctor.theException);
        system.assertEquals('hello', ctor.DEFAULT_RETURN_VALUE);
        system.assertEquals(null, ctor.sObjects);
        system.assertEquals(null, ctor.domain);
        system.assertEquals(true, ctor.usesRelatedObjects);
        system.assertEquals(false, ctor.checkIncomingTypes);

    }
    @isTest
    static void ensureCorrectTypeTest() {
        // assign
        Boolean caughtExcp=false;
        accc_SObjectGetSet ctor = new accc_SObjectGetSet();
        ctor.checkIncomingTypes = true;
        // act
        // assert
        system.assertEquals(true, ctor.ensureCorrectType(accc_SObjectGetSet.BASE64_TYPE));
        try {
            system.assertEquals(false, ctor.ensureCorrectType('junk'));
        } catch (accc_SObjectGetSet.accc_SObjectGetSetException excp) {
            caughtExcp=true;
        }
        system.assertEquals(true, caughtExcp);


    }

    @isTest
    static void preProcessAPIFieldsTest() {
        // assign
        List<String> apiFields = new List<String> {
            'Id',
            'Account.Member'
        };
        accc_SObjectGetSet ctor = new accc_SObjectGetSet();

        // act

        // assert
        system.assertEquals(true, ctor.preProcessAPIFields(apiFields));
        system.assertEquals(false, ctor.preProcessAPIFields((List<String>)null));
        system.assertEquals(false, ctor.usesRelatedObjects);

    }

    @isTest
    static void setValueTest() {
        // assign
        Boolean caughtExcp=false;
        accc_SObjectGetSet ctor = new accc_SObjectGetSet();
        List<SObject> sample = sampleData();
        // act

        // assert
        system.assertEquals('test1', ctor.setValue(sample[0],'Name','renamed'));
        system.assertEquals('renamed', ctor.setValue(sample[0],'Name','again'));

        try {
            system.assertEquals(null, ctor.setValue(null,'Name','try'));
        } catch(accc_SObjectGetSet.accc_SObjectGetSetException excp) {
            caughtExcp=true;
        }
        system.assertEquals(true,caughtExcp);

    }
    @isTest
    static void getValueTest() {
        // assign
        Boolean caughtExcp=false;
        accc_SObjectGetSet ctor = new accc_SObjectGetSet();
        List<SObject> sample = sampleData();
        // act

        // assert
        system.assertEquals('test1', ctor.getValue(sample[0],'Name'));
        system.assertEquals(null, ctor.getValue(sample[0],''));
        system.assertEquals(null, ctor.theException);

    }
    @isTest
    static void getRelatedValueTest() {
        // assign
        Boolean caughtExcp=false;
        accc_SObjectGetSet ctor = new accc_SObjectGetSet();
        List<SObject> sample = sampleData();
        // act

        // assert
 
        system.assertEquals(null, ctor.getRelatedValue(sample[0],'Account.Name'));
        system.assertNotEquals(null, ctor.theException);
        system.assertEquals(null, ctor.getRelatedValue(sample[0],''));
        system.assertEquals(null, ctor.getRelatedValue(sample[0],'Name'));
        system.assertEquals (null,ctor.theException);

    }
    ///////////////////////////////////////////////////////////////////
    // Helpers
    ///////////////////////////////////////////////////////////////////

    static List<SObject> sampleData() {
        List<SObject> data = new List<SObject> {
            new Account(Name='test1')
        };
        return data;
    }
}// end of accc_SObjectGetSetTest
