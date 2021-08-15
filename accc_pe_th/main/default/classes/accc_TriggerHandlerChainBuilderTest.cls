/**
 * Copyright (c) 2016-2021, Bill anderson.  All rights reserved.
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
 * @author Bill anderson
 *
 * @description Test the trigger handler  builder class.
 * Tests depend on custom metadata being set properly !!
 * Domains, Account and Contact, each have one Test class defined in the
 * custom metadata. DO NOT DELETE them; otherwise, these tests will FAIL
 *
 * The test classes :
 *  Contact ---> accc_TestTriggerHandlerForContactTest
 *  Account ---> accc_TestTriggerHandlerForAccountTest, accc_TestTriggerHandlerForAccountTwoTest
 *
 * @group Test Layer
 */
@isTest
private class accc_TriggerHandlerChainBuilderTest {


    ////////////////////////////////////////////////////////////////////////////////
    // Data Members
    ////////////////////////////////////////////////////////////////////////////////
    // expected trigger handler order
    static final Map<integer, Type> METHOD_ORDER_EXPECTED = new Map<integer, Type> {
        1=> accc_TestTriggerHandlerForAccount.class,
        2=> accc_TestTriggerHandlerForAccountTwo.class
    };

    ////////////////////////////////////////////////////////////////////////////////
    // Unit Tests
    ////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testctorWithDomain() {
        // assign
        final String domainName = '*no_event_domain_junk';
        // act
        accc_TriggerHandlerChainBuilder ctor = new accc_TriggerHandlerChainBuilder(domainName);
        // assert
        System.assertEquals(true, ctor != null);
        System.assertEquals(domainName, ctor.domainName);
        System.assertEquals(accc_ApexConstants.PRODUCTION_CATEGORY.toLowerCase(), ctor.triggerEnvironment.toLowerCase() );
        System.assertEquals(false, ctor.validDomainName == null);
        System.assertEquals(true, ctor.theElements == null);
    }
    @isTest
    static void testctorWithDomainAndEnv() {
        // assign
        final String domainName = '*no_event_domain_junk';
        // act
        accc_TriggerHandlerChainBuilder ctor = new accc_TriggerHandlerChainBuilder(domainName, accc_ApexConstants.DEBUG_CATEGORY);
        // assert
        System.assertEquals(true, ctor != null);
        System.assertEquals(domainName, ctor.domainName);
        System.assertEquals(accc_ApexConstants.DEBUG_CATEGORY.toLowerCase(), ctor.triggerEnvironment.toLowerCase() );
        System.assertEquals(false, ctor.validDomainName);
        System.assertEquals(true, ctor.theElements == null);
    }
    @isTest
    static void testctorWithValidDomain() {
        // assign
        final String domainName = 'Account';
        // act
        accc_TriggerHandlerChainBuilder ctor = new accc_TriggerHandlerChainBuilder(domainName,
                                                                                   accc_ApexConstants.TEST_CATEGORY);
        // assert
        System.assertEquals(true, ctor != null);
        System.assertEquals(domainName, ctor.domainName);
        System.assertEquals(accc_ApexConstants.TEST_CATEGORY.toLowerCase(), ctor.triggerEnvironment.toLowerCase() );
        System.assertEquals(true, ctor.validDomainName);
        // Note, this ASSUMES the TEST metadata is LEFT INTACT (It SHOULD)
        System.assertEquals(true, ctor.theElements != null);

    }

    @isTest
    static void testctorWithValidDomainAndEnv() {
        // assign
        final String domainName = 'Account';
        // act
        accc_TriggerHandlerChainBuilder ctor = new accc_TriggerHandlerChainBuilder(domainName, accc_ApexConstants.DEBUG_CATEGORY);
        // assert
        System.assertEquals(true, ctor != null);
        System.assertEquals(domainName, ctor.domainName);
        System.assertEquals(accc_ApexConstants.DEBUG_CATEGORY.toLowerCase(), ctor.triggerEnvironment.toLowerCase() );
        System.assertEquals(true, ctor.validDomainName);
        System.assertEquals(false, ctor.domainActive);
        System.assertEquals(true, ctor.theElements == null);
    }// end of testctorWithValidDomainAndEnv

    @isTest
    static void testfindbyEnvironmentAndDomainIsNull() {
        // assign
        final String domainName = null;
        // act
        accc_TriggerHandlerChainBuilder ctor = new accc_TriggerHandlerChainBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);
        // assert
        System.assertEquals(true, ctor != null);
        System.assertEquals(true, string.isBlank(ctor.domainName));
        System.assertEquals(accc_ApexConstants.TEST_CATEGORY.toLowerCase(), ctor.triggerEnvironment.toLowerCase() );
        System.assertEquals(false, ctor.validDomainName);
        System.assertEquals(false, ctor.domainActive);
        // gets all elements for that environment ( but no domain specific)
        System.assertEquals(true, ctor.theElements != null);

    }// end of testfindbyEnvironmentAndDomainIsNull

    @isTest
    static void testbuildTriggerEventHandlerChain() {
        // assign
        final String domainName = 'Contact';
        // act
        accc_TriggerHandlerChainBuilder ctor = new accc_TriggerHandlerChainBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);
        accc_IHandlerChain chain = ctor.buildTriggerEventHandlerChain(ctor.theElements, domainName);
        // assert
        System.assertEquals(true, chain != null);
        System.assertEquals(true, ctor.theElements != null);
        System.assertEquals(true, chain.getHandler() != null);

    }

    @isTest
    static void buildTriggerEventHandlerChainCheckOrderTest() {
        // assign
        final String domainName = 'Contact';
        // act
        final accc_TriggerHandlerChainBuilder ctor = new accc_TriggerHandlerChainBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);
        final List<accc_TriggerHandlerMetaDataModel.THDataModelInformation> items=accc_TriggerHandlerChainBuilderTest.handlerElements(domainName);
        accc_IHandlerChain chain = ctor.buildTriggerEventHandlerChain(items, domainName);

        // assert
        for (accc_TriggerHandlerMetaDataModel.THDataModelInformation item : items  ) {
            // get our current handler
            final accc_ITriggerHandler handler = (accc_ITriggerHandler) chain.getHandler();
            final String className =  handler.toString().split(':')[0].trim().toLowerCase(),
                         expectName = METHOD_ORDER_EXPECTED.get(item.order).getName().toLowerCase();
            // assert
            system.assertEquals(expectName,className );
            chain = chain.getNext();
        }
    }// end of buildTriggerEventHandlerChainCheckOrderTest

    @isTest
    static void testbuild() {
        // assign --
        // we are expecting at least 1 account in the CMDT. This DOES NOT
        // include DUPLICATES as we remove them
        final String domainName = 'Account';
        accc_TriggerHandlerChainBuilder ctor = new accc_TriggerHandlerChainBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);

        // act
        accc_IHandlerChain triggerHandlers = ctor.build();

        // assert
        System.assertEquals(true, triggerHandlers != null);
        System.assertEquals(2, ctor.theElements.size());
        System.assertEquals(true, triggerHandlers.getHandler() != null);
        System.assertEquals(true, triggerHandlers.getNext().getHandler() != null);
        System.assertEquals(true, triggerHandlers.getNext() != null);
        // NOTE: there are 2 accounts handlers; thus, getNext() == 1, getNext().getNext() == 2
        System.assertEquals(true, triggerHandlers.getNext().getNext() == null);


    }// end of testbuild

    @isTest
    static void testbuildWithContactTest() {
        // assign
        final String domainName = 'Contact';
        accc_TriggerHandlerChainBuilder ctor = new accc_TriggerHandlerChainBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);

        // act
        accc_IHandlerChain triggerHandlers = ctor.build();

        // assert
        System.assertEquals(true, triggerHandlers != null);
        System.assertEquals(true, triggerHandlers.getHandler() != null);


    }// end of testbuildWithContactTest

    @isTest
    static void testtriggerEnvironment() {
        // assign
        final String domainName = 'Account';
        // act
        accc_TriggerHandlerChainBuilder ctor = new accc_TriggerHandlerChainBuilder(domainName, accc_ApexConstants.DEBUG_CATEGORY);
        // assert
        System.assertEquals(accc_ApexConstants.DEBUG_CATEGORY.toLowerCase(), ctor.triggerEnvironment.toLowerCase() );
        // set bogus ... should default to test
        ctor = new accc_TriggerHandlerChainBuilder(domainName, 'junk');
        // assert
        System.assertEquals(accc_ApexConstants.TEST_CATEGORY.toLowerCase(), ctor.triggerEnvironment.toLowerCase() );
        // set bogus ... should default to test
        ctor = new accc_TriggerHandlerChainBuilder(domainName, '');
        // assert
        System.assertEquals(accc_ApexConstants.TEST_CATEGORY.toLowerCase(), ctor.triggerEnvironment.toLowerCase() );
        // set bogus ... should default to test
        ctor = new accc_TriggerHandlerChainBuilder(domainName, null);
        // assert
        System.assertEquals(accc_ApexConstants.TEST_CATEGORY.toLowerCase(), ctor.triggerEnvironment.toLowerCase() );
        // set valid name w/ spaces ... should default to debug
        ctor = new accc_TriggerHandlerChainBuilder(domainName, 'DEBUG    ');
        // assert
        System.assertEquals(accc_ApexConstants.DEBUG_CATEGORY.toLowerCase(), ctor.triggerEnvironment.toLowerCase() );

    } // end of testtriggerEnvironment

    @isTest
    static void testBadBuild() {
        // assign
        boolean gotException = false;
        final String domainName = 'Account';
        try {
            accc_TriggerHandlerChainBuilder ctor = new accc_TriggerHandlerChainBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);

            // make a bad domain
            ctor.m_validDomainName = false;

            // act
            accc_IHandlerChain triggerHandlers = ctor.build();
        } catch (Exception excp) {
            gotException = true;
        }

        // assert
        System.assertEquals(true, gotException);


    }// end of testBadBuild

    //////////////////////////////////////////////////////////
    // Helpers
    //////////////////////////////////////////////////////////

    /**
     * @description handlerElements description
     * @param  domain String SObject Name
     * @param  size   count to create
     * @return colleciton of accc_TriggerHandlerMetaDataModel.THDataModelInformation
     */
    static List<accc_TriggerHandlerMetaDataModel.THDataModelInformation> handlerElements(String domain) {
        // known classes
        List<String> validClasses  = new List<String> {
            'accc_TestTriggerHandlerForAccount',
            'accc_TestTriggerHandlerForAccountTwo'
        };
        integer next=0,
                size=validClasses.size();
        List<accc_TriggerHandlerMetaDataModel.THDataModelInformation> items = new List<accc_TriggerHandlerMetaDataModel.THDataModelInformation>();
        for (integer inx=0; inx < size; inx++) {
            accc_TriggerHandlerMetaDataModel.THDataModelInformation item=new accc_TriggerHandlerMetaDataModel.THDataModelInformation();
            item.environment=accc_ApexConstants.TEST_CATEGORY;
            item.domain=domain;
            item.clazz=validClasses[next++];
            item.isActive=true;
            item.continueIfException=true;
            item.performanceMetrics=true;
            item.order=inx+1;
            items.add( item);

            if ( next > 1 ) {
                next=0;
            }
        }
        return items;

    }// end of handlerElements

} // end of accc_TriggerHandlerChainBuilderTest