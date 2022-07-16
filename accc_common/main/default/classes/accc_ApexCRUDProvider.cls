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
 *
 * @File Name          : accc_ApexCRUDProvider.cls
 * @Description        : Concrete Apex CRUD Provider
 * @Author             : Bill Anderson
 * @Group              : Common
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    1/8/2017   Bill Anderson     Initial Version
 **/
global inherited sharing class accc_ApexCRUDProvider implements accc_IApexCRUDProvider {

    ///////////////////////////////////////////////////////////////////////////////////
    // Data Members
    ///////////////////////////////////////////////////////////////////////////////////
    @TestVisible
    accc_ApexDMLOptions mOptions = null;
    @TestVisible
    static apexAccessFactory theFactory = new apexAccessFactory();
    @TestVisible
    static Boolean forTestingConditions = false;
    /**
     * Our exception
     */
    global class accc_ApexCRUDException extends Exception {}
    ///////////////////////////////////////////////////////////////////////////////////
    // Public Ctors
    ///////////////////////////////////////////////////////////////////////////////////
    /**
     * accc_ApexCRUDProvider
     * @description default ctor
     */
    global accc_ApexCRUDProvider(){
        this((accc_ApexDMLOptions)null);
    } // end of ctor
    /**
     * accc_ApexCRUDProvider
     * @description ctor with dml options
     * @param  options accc_ApexDMLOptions
     */
    global accc_ApexCRUDProvider(accc_ApexDMLOptions options){
        this.theDMLOptions = options != null ? options : new accc_ApexDMLOptions();
    }// end of ctor
     /**
      * accc_ApexCRUDProvider
      * @description ctor with Execution Mode
      * @param  emode ExecutionMode
      */
    global accc_ApexCRUDProvider(accc_ApexDMLOptions.ExecutionMode emode){
        this.theDMLOptions = new accc_ApexDMLOptions(emode);
    } // end of ctor
    ///////////////////////////////////////////////////////////////////////////////////
    // Public Methods
    ///////////////////////////////////////////////////////////////////////////////////
    /**
     * getDmlOptions
     * @description getter of DMLOptions
     * @return  DMLOptions
     */
    global virtual accc_ApexDMLOptions getDmlOptions() {
        return this.theDMLOptions;
    }
    /**
     * setDmlOptions
     * @description set the DML options, returning the previous setting
     * @param  options DmlOptions
     * @return previous DmlOptions
     */
    global virtual accc_ApexDMLOptions setDmlOptions(accc_ApexDMLOptions options){
        accc_ApexDMLOptions last = this.theDMLOptions;
        if ( options != null ) {
            this.theDMLOptions=options;
        }
        return last;
    }// end of setDmlOptions

    /**
     * insertDb
     * @description insert objects into sink
     * @param  theObjects the List of Objects
     * @param accc_ApexDMLOptions
     * @return result handler
     */
    global virtual accc_GenericDbResultHandler insertDb(List<SObject> theObjects){
        accc_GenericDbResultHandler result=null;
        // valid data
        if ( theObjects == null ) {
            result= new accc_GenericDbResultHandler((List<Database.SaveResult>)null);
        } else {
            result=  this.getProvider().insertDb(theObjects);
        }
        return result;
    }

    /**
     * updateDb
     * @description update objects into sink
     * @param  theObjects the List of Objects
     * @return result handler
     */
    global virtual accc_GenericDbResultHandler updateDb(List<SObject> theObjects)
    {
        accc_GenericDbResultHandler result=null;
        // valid data
        if ( theObjects == null ) {
            result= new accc_GenericDbResultHandler((List<Database.SaveResult>)null);
        } else {
            result=  this.getProvider().updateDb(theObjects);
        }
        return result;
    }// end of updateDb
    /**
     * upsertDb
     * @description upsert objects into sink
     * @param  theObjects the List of Objects

     * @return result handler
     */
    global virtual accc_GenericDbResultHandler upsertDb(List<SObject> theObjects){
        accc_GenericDbResultHandler result=null;
        // valid data
        if ( theObjects == null ) {
            result= new accc_GenericDbResultHandler((List<Database.UpsertResult>)null);
        } else {
            result= this.getProvider().upsertDb(theObjects);
        }
        return result;
    }// end of upsertDb

    /**
     * deleteDb
     * @description delete objects in sink
     * @param  theObjects the List of Objects
     * @return result handler
     */
    global virtual accc_GenericDbResultHandler deleteDb(List<SObject> theObjects){
        accc_GenericDbResultHandler result=null;
        // valid data
        if ( theObjects == null ) {
            result= new accc_GenericDbResultHandler((List<Database.DeleteResult>)null);
        } else {
            accc_IApexCRUDProvider provider= this.getProvider();
            result= provider.deleteDb(theObjects);
        }
        return result;
    }// end of deleteDb

    ///////////////////////////////////////////////////////////////////////////////////
    // Public Properties
    ///////////////////////////////////////////////////////////////////////////////////
    /**
     * Our local Apex DML options
     */
    global accc_ApexDMLOptions theDMLOptions {
        get { return this.mOptions;}
        set { this.mOptions=value;}
    }// end of theDMLOptions


    ///////////////////////////////////////////////////////////////////////////////////
    // Public Methods
    ///////////////////////////////////////////////////////////////////////////////////
    /**
     * getAccessibleRecords
     * @description in user  or inherited mode we need to get the proper records. This method CAN throw an Insufficient Exception
     * as it performs a StripInAccessible for NON System Mode!
     * @param  theObjects theObjects
     * @param AccessType access type
     * @return acceptable records
     */
    global List<SObject> getAccessibleRecords(List<SObject> theObjects,
                                              System.AccessType aType){
        List<SObject> results=null;
        // valid data
        if ( theObjects != null ) {
            results= this.getProvider().getAccessibleRecords(theObjects,aType);
        }
        return results;
    }// end of getAccessibleRecords
    /**
     * getAccessibleRecords
     * @description get accessible record based on mode for delete ONLY
     * @param  theObjects the Object collection
     * @param accc_ApexDMLOptions dml and various options
     * @return accesible records based on access and mode
     */
    global List<SObject> getAccessibleRecords(List<SObject> theObjects){
        List<SObject> results=null;
        // valid data
        if ( theObjects != null ) {
            results= this.getProvider().getAccessibleRecords(theObjects);
        }
        return results;
    }// end of getAccessibleRecords

    /**
     * determineDMLAllowed
     * @description determine the DML action is allowed on SObjects
     * @param  theObjects the collection of SObjects
     * @param  dmlAction  the DML Action (insert, upsert,update, delete)
     * @return  true, if action is possible
     */
    global Boolean determineDMLAllowed(List<SObject> theObjects,accc_ApexDMLOptions.DMLAction dmlAction) {
        Boolean results=true;
        // valid data
        if ( theObjects != null ) {
            results= this.getProvider().determineDMLAllowed(theObjects,dmlAction);
        }
        return results;

    }// end of determineDMLAllowed
    ///////////////////////////////////////////////////////////////////////////////////
    // Private
    ///////////////////////////////////////////////////////////////////////////////////

    /**
     * getProvider
     * @description Get the CRUD Provider
     * @return   return accc_IApexCRUDProvider
     */
    @TestVisible
    private accc_IApexCRUDProvider getProvider() {
        accc_IApexCRUDProvider provider=  accc_ApexCRUDProvider.theFactory.create(this.getDmlOptions().theExecutionMode);
        provider.setDmlOptions(this.theDMLOptions);
        return provider;
    }// end of getProvider

    /************************************************************************************
     *
     * Our Internal Providers ( allowing one to swith execution modes)
     *************************************************************************************
     */

    /**
     * User Mode
     */
    @TestVisible
    private with sharing class apexWithSharing extends accc_ApexCRUDBaseProvider {}
    /**
     * System Mode
     */
    @TestVisible
    private without sharing class apexWithoutSharing extends accc_ApexCRUDBaseProvider {}
    /**
     * Caller's Mode
     */
    @TestVisible
    private inherited sharing class apexInheritSharing extends accc_ApexCRUDBaseProvider {}

    /**
     * Our Base CRUD Provider
     */
    @TestVisible
    private virtual class accc_ApexCRUDBaseProvider implements accc_IApexCRUDProvider {

        ///////////////////////////////////////////////////////////////////////////////////
        // Data Members
        ///////////////////////////////////////////////////////////////////////////////////
        @TestVisible
        accc_ApexDMLOptions mOptions = null;

        ///////////////////////////////////////////////////////////////////////////////////
        // Public Ctors
        ///////////////////////////////////////////////////////////////////////////////////
        /**
         * accc_ApexCRUDProvider
         * @description default ctor
         */
        public accc_ApexCRUDBaseProvider(){
            this(null);
        }     // end of ctor
        /**
         * accc_ApexCRUDProvider
         * @description ctor with dml options
         * @param  options accc_ApexDMLOptions
         */
        public accc_ApexCRUDBaseProvider(accc_ApexDMLOptions options){
            this.theDMLOptions = options != null ? options : new accc_ApexDMLOptions();
        }// end of ctor
        ///////////////////////////////////////////////////////////////////////////////////
        // Public Methods
        ///////////////////////////////////////////////////////////////////////////////////
        /**
         * getDmlOptions
         * @description getter of DMLOptions
         * @return  DMLOptions
         */
        public virtual accc_ApexDMLOptions getDmlOptions() {
            return this.theDMLOptions;
        }// end of getDmlOptions
        /**
         * setDmlOptions
         * @description set the DML options, returning the previous setting
         * @param  options DmlOptions
         * @return previous DmlOptions
         */
        public virtual accc_ApexDMLOptions setDmlOptions(accc_ApexDMLOptions options){
            accc_ApexDMLOptions last = options;
            if ( options != null ) {
                this.theDMLOptions=options;
            }
            return last;
        }// end of setDmlOptions

        /**
         * insertDb
         * @description insert objects into sink
         * @param  theObjects the List of Objects
         * @param accc_ApexDMLOptions
         * @return result handler
         */
        public virtual accc_GenericDbResultHandler insertDb(List<SObject> theObjects){
            List<Database.SaveResult> results=null;

            try {
                accc_ApexDMLOptions options = this.getDmlOptions();
                // can we insert
                List<SObject> sanitizedRecords=this.getAccessibleRecords(theObjects,System.AccessType.CREATABLE);
                if ( options.theDMLMode == accc_ApexDMLOptions.DMLMode.IMMEDIATE ) {
                    // this is awful; but not going to mock as one still does not execute the insert
                    if ( accc_ApexConstants.UNIT_TEST_RUNNING
                         && accc_ApexCRUDProvider.forTestingConditions == true) {
                        results=accc_ApexCRUDProvider.getTestResultsForInsertUpdateImmediate();
                    } else {
                        results=Database.insertImmediate(sanitizedRecords);
                    }
                } else {
                    results=Database.insert(sanitizedRecords,options.getDmlOptions());
                }

            } catch (Exception excp) {
                results = new  List<Database.SaveResult> {
                    // create SaveResult exception
                    (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"'+
                                                          excp.getMessage() +
                                                          '","statusCode":"' +
                                                          System.StatusCode.INSUFFICIENT_ACCESS_OR_READONLY +
                                                          '"}]}',
                                                          Database.SaveResult.class)
                };
            }
            return new accc_GenericDbResultHandler(results);
        }// end of insertDb
        /**
         * updateDb
         * @description update objects into sink
         * @param  theObjects the List of Objects
         * @return result handler
         */
        public virtual accc_GenericDbResultHandler updateDb(List<SObject> theObjects){
            List<Database.SaveResult> results=null;

            try {
                accc_ApexDMLOptions options = this.getDmlOptions();
                // can we update
                List<SObject> sanitizedRecords=this.getAccessibleRecords(theObjects,System.AccessType.UPDATABLE);
                if ( options.theDMLMode == accc_ApexDMLOptions.DMLMode.IMMEDIATE ) {
                    // this is awful; but not going to mock as one still does not execute the update
                    if ( accc_ApexConstants.UNIT_TEST_RUNNING
                         && accc_ApexCRUDProvider.forTestingConditions == true) {
                        results=accc_ApexCRUDProvider.getTestResultsForInsertUpdateImmediate();
                    } else {
                        results=Database.updateImmediate(theObjects);
                    }
                } else {
                    results=Database.update(theObjects,options.getDmlOptions());
                }

            } catch (Exception excp) {
                results = new  List<Database.SaveResult> {
                    // create SaveResult exception
                    (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"'+
                                                          excp.getMessage() +
                                                          '","statusCode":"' +
                                                          System.StatusCode.INSUFFICIENT_ACCESS_OR_READONLY +
                                                          '"}]}',
                                                          Database.SaveResult.class)
                };
            }
            return new accc_GenericDbResultHandler(results);
        }// end of updateDb

        /**
         * upsertDb
         * @description upsert objects into sink
         * @param  theObjects the List of Objects
         * @param accc_ApexDMLOptions
         * @return result handler
         */
        public virtual accc_GenericDbResultHandler upsertDb(List<SObject> theObjects){
            List<Database.UpsertResult> results=null;
            // handle upserts
            // SObjects not allowed [vote] https ://success.salesforce.com/ideaView?id=08730000000aNhVAAU
            accc_ApexDMLOptions options = this.getDmlOptions();
            try {
                // can we upsert
                List<SObject> sanitizedRecords=this.getAccessibleRecords(theObjects,System.AccessType.UPSERTABLE);
                // Note -- no check for Sync/Async/Immediate ; only sync
                // have to copy, cannot just assign (by reference)
                List<SObject> specificSObject = accc_ApexSObjectTypesUtils.createSObjectAndCopy(sanitizedRecords);
                // upsert
                results=Database.upsert(specificSObject,options.getDmlOptions().OptAllOrNone);

            } catch (Exception excp) {
                // default to a status code of insufficient access. Cannot guarantee there is a status code.
                results = new  List<Database.UpsertResult> {
                    // create UpsertResult exception
                    (Database.UpsertResult)JSON.deserialize('{"success":false,"errors":[{"message":"'+
                                                            excp.getMessage() +
                                                            '","statusCode":"' +
                                                            System.StatusCode.INSUFFICIENT_ACCESS_OR_READONLY +
                                                            '"}]}',
                                                            Database.UpsertResult.class)
                };
            }

            return new accc_GenericDbResultHandler(results);
        }    // end of upsertDb

        /**
         * deleteDb
         * @description delete objects in sink
         * @param  theObjects the List of Objects
         * @param accc_ApexDMLOptions
         * @return result handler
         */
        public virtual accc_GenericDbResultHandler deleteDb(List<SObject> theObjects){
            List<Database.DeleteResult> results=null;

            try {
                accc_ApexDMLOptions options = this.getDmlOptions();
                // could be null , check
                if ( theObjects != null ) {
                    // see if we can delete records ( checking the record if not system mode)
                    List<SObject> sanitizedRecords=this.getAccessibleRecords(theObjects);
                    if ( options.theDMLMode == accc_ApexDMLOptions.DMLMode.IMMEDIATE ) {
                        // this is awful; but not going to mock as one still does not execute the delete
                        if ( accc_ApexConstants.UNIT_TEST_RUNNING
                             && accc_ApexCRUDProvider.forTestingConditions == true ) {
                            results=accc_ApexCRUDProvider.getTestResultsForDeleteImmediate();
                        } else {
                            results=Database.deleteImmediate(sanitizedRecords);
                        }
                    } else {
                        results=Database.delete(sanitizedRecords,options.getDmlOptions().OptAllOrNone);
                    }
                }

            } catch (Exception excp) {
                results = new  List<Database.DeleteResult> {
                    // create DeleteResult exception
                    (Database.DeleteResult)JSON.deserialize('{"success":false,"errors":[{"message":"'+
                                                            excp.getMessage() +
                                                            '","statusCode":"' +
                                                            excp.getDmlType(0) +
                                                            '"}]}',
                                                            Database.DeleteResult.class)
                };
            }
            return new accc_GenericDbResultHandler(results);
        }    // end of deleteDb

        /**
         * Our local options
         */
        public accc_ApexDMLOptions theDMLOptions {
            get { return this.mOptions;}
            set { this.mOptions=value;}
        }

        /**
         * getAccessibleRecords
         * @description in user  or inherited mode we need to get the proper records
         * @param  theObjects theObjects
         * @param AccessType access type
         * @return acceptable records
         */
        public List<SObject> getAccessibleRecords(List<SObject> theObjects,
                                                  System.AccessType aType){
            List<SObject> results = theObjects;
            accc_ApexDMLOptions options = this.getDmlOptions();

            // if we are not in system mode, then strip out fields (can throw an exception)
            if ( options.theExecutionMode != accc_ApexDMLOptions.ExecutionMode.SYSTEM_MODE) {
                SObjectAccessDecision securityDecision = Security.stripInaccessible(
                    aType,
                    theObjects);
		// FIX [ISSUE-002] when in USER-SYSTEM mode - 
		// "addError" (does not work bec/ of copy) or "insert" ( does not return the id within the list)
		theObjects.clear();
                // get accessible records
                theObjects.addAll( securityDecision.getRecords());
            }
            return results;

        }// end of getAccessibleRecords
        /**
         * getAccessibleRecords
         * @description get accessible record based on mode for delete ONLY (can throw exception NoAccessException)
         * @param  theObjects the Object collection
         * @return accesible records based on access and mode
         */
        public List<SObject> getAccessibleRecords(List<SObject> theObjects){
            List<SObject> results = theObjects;
            accc_ApexDMLOptions options = this.getDmlOptions();
            // if we are not in system mode, then check if deleteable
            if ( options.theExecutionMode != accc_ApexDMLOptions.ExecutionMode.SYSTEM_MODE) {
                integer size = theObjects.size();
                Boolean canDelete = true;
                // look at the records and determine deletion
                for ( integer inx=0; inx< size; inx++) {
                    // if we cannot delete, set flag and break out
                    if ( !theObjects[inx].getSObjectType().getDescribe().isDeletable() ) {
                        canDelete = false;
                        break;
                    }
                }
                // if cannot delete, throw an exception
                if ( canDelete == false ) {
                    throw new System.NoAccessException();
                }
            }
            return results;
        }// end of getAccessibleRecords

        /**
         * determineDMLAllowed
         * @description determine the DML action is allowed on SObjects
         * @param  theObjects the collection of SObjects
         * @param  dmlAction  the DML Action (insert, upsert,update, delete)
         * @return  true, if action is possible
         */
        public Boolean determineDMLAllowed(List<SObject> theObjects,
                                           accc_ApexDMLOptions.DMLAction dmlAction) {
            // only need to compare once, set the booleans
            Boolean canInsert = dmlAction == accc_ApexDMLOptions.DMLAction.INSERTABLE,
                    canDelete = dmlAction == accc_ApexDMLOptions.DMLAction.DELETABLE,
                    canUpdate = dmlAction == accc_ApexDMLOptions.DMLAction.UPDATEABLE,
                    canUpsert = dmlAction == accc_ApexDMLOptions.DMLAction.UPSERTABLE,
                    canRead =dmlAction == accc_ApexDMLOptions.DMLAction.READABLE,
                    result=true;
            // counters and size
            integer index=0,
                    size = theObjects.size();
            // allocate outside ( apex does not optimize)
            DescribeSObjectResult theDescribeObject =null;
            // determine additional actions
            if ( dmlAction == accc_ApexDMLOptions.DMLAction.ALL) {
                // no need to check read as the others imply it
                canInsert = canDelete = canUpdate = true;
            } else if ( canUpsert ) {
                canInsert =  canUpdate  = true;
            }
            /**
             * iterate over the list, validating access
             */
            while ( result==true && index < size ) {
                theDescribeObject = theObjects[index].getSObjectType().getDescribe();

                // can read
                if (canRead && !theDescribeObject.isAccessible() ) {
                    result= false;
                    break;
                }
                // can insert
                if (canInsert && !theDescribeObject.isCreateable() ) {
                    result= false;
                    break;
                }
                // can update
                if (canUpdate && !theDescribeObject.isUpdateable()) {
                    result= false;
                    break;
                }
                // can delete
                if (canDelete && !theDescribeObject.isDeletable()) {
                    result= false;
                }
                index++;
            }
            return result;
        }// end of determineDMLAllowed

    }// end of accc_ApexCRUDBaseProvider

    /****************************************************************************************
     *
     * apexAccessFactory
     * @description Factory to create appropriate class when needed.
     ***************************************************************************************/
    global class apexAccessFactory {
        // hold our known providers
        @TestVisible
        Map<accc_ApexDMLOptions.ExecutionMode,accc_IApexCRUDProvider> mKnowns = new Map<accc_ApexDMLOptions.ExecutionMode,accc_IApexCRUDProvider>();

        /*
         * create
         * @description create dml provider based on execution mode
         * @param accc_ApexDMLOptions.ExecutionMode smode
         */
        public accc_IApexCRUDProvider create(accc_ApexDMLOptions.ExecutionMode smode ) {
            // we map based on  execution mode
            accc_IApexCRUDProvider access = this.findProviderByMode(smode);
            // did we find an access class
            if ( access == null ) {

                if ( smode == accc_ApexDMLOptions.ExecutionMode.SYSTEM_MODE ) {
                    // system mode
                    access = new  apexWithoutSharing ();
                } else if ( smode == accc_ApexDMLOptions.ExecutionMode.USER_MODE ) {
                    // user mode
                    access = new apexWithSharing();
                } else {
                    // caller's mode
                    access = new apexInheritSharing();
                }
                // remember it for later
                this.mKnowns.put(smode,access);
            }

            return access;
        }// end of create
        /*
         * findProviderByMode
         * @description find provider by mode
         */
        public accc_IApexCRUDProvider findProviderByMode(accc_ApexDMLOptions.ExecutionMode smode) {
            return this.mKnowns.get(smode);
        }// end of findProviderByMode;

    }// end of AccessControlFactory

    /**
     * @description used for testing  results (immediate)
     *
     * @return   List<Database.DeleteResult> Db Results
     */
    @TestVisible
    private static List<Database.DeleteResult> getTestResultsForDeleteImmediate() {
        List<Database.DeleteResult> results = null;
        if ( accc_ApexConstants.UNIT_TEST_RUNNING ) {
            // SIMULATING RESULTS
            results =  new  List<Database.DeleteResult> {
                (Database.DeleteResult)JSON.deserialize('{"id":"000000000000000AAA","success":true,"errors":[]}', Database.DeleteResult.class),
                (Database.DeleteResult)JSON.deserialize('{"id":"000000000000000BAA","success":true,"errors":[]}', Database.DeleteResult.class),
                (Database.DeleteResult)JSON.deserialize('{"id":"000000000000000CAA","success":true,"errors":[]}', Database.DeleteResult.class)

            };
        }
        return results;

    }// end of getTestResultsForDeleteImmediate
    /**
     * @description used for testing  results (immediate)
     *
     * @return   List<Database.DeleteResult> Db Results
     */
    @TestVisible
    private static List<Database.SaveResult> getTestResultsForInsertUpdateImmediate() {
        List<Database.SaveResult> results = null;
        if ( accc_ApexConstants.UNIT_TEST_RUNNING ) {
            // SIMULATING RESULTS
            results =  new  List<Database.SaveResult> {
                (Database.SaveResult)JSON.deserialize('{"id":"000000000000000AAA","success":true,"errors":[]}', Database.SaveResult.class),
                (Database.SaveResult)JSON.deserialize('{"id":"000000000000000BAA","success":true,"errors":[]}', Database.SaveResult.class),
                (Database.SaveResult)JSON.deserialize('{"id":"000000000000000CAA","success":true,"errors":[]}', Database.SaveResult.class)

            };
        }
        return results;

    }// end of getTestResultsForInsertUpdateImmediate

}// end of accc_ApexCRUDProvider
