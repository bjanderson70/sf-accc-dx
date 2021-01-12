/**
 * Copyright (c) 2016-2020, Bill Anderson  All rights reserved.
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
 * @File Name          : accc_SObjectGetSet.cls
 * @Description        : Encapsulates some base functionality setting/getting values to/from SObject.
 *                       May need to revist to determine if we can improve performance.
 * @Author             : Bill Anderson
 * @Group              : Metadata
 * @Last Modified On   : 01-11-2021
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/8/2019  Bill Anderson     Initial Version
 **/

public virtual class accc_SObjectGetSet {

    ////////////////////////////////////////////////////////////////////////////////
    /// Data Members
    ////////////////////////////////////////////////////////////////////////////////
    public static final String TEST_EXCEPTION_MSG = 'Test getValue';
    // null result for json field
    public static final String JSON_NULL_RESULT = 'null';
    // field separator
    public static final String FIELD_SEPARATOR = '.';
    // invalid type
    public static final String NOT_RECOGNIZED_TYPE = 'Not a recognized type';
    // invalid sobject or api
    public static final String NOT_RECOGNIZED_SOBJECT_OR_ITEM  ='SOBject: item or apiName is null';

    // supported types (make ALL Lowercase -- in a Set)
    public static final String STRING_TYPE = 'string',
                               ANYTYPE_TYPE = 'anytype',
                               TEXT_TYPE = 'text',
                               BOOL_TYPE = 'boolean',
                               INT_TYPE = 'integer',
                               LONG_TYPE = 'long',
                               COMBOBOX_TYPE = 'combobox',
                               BASE64_TYPE = 'base64',
                               DOUBLE_TYPE = 'double',
                               DECIMAL_TYPE = 'decimal',
                               DATE_TYPE = 'date',
                               DATETIME_TYPE = 'datetime',
                               ADDRESS_TYPE = 'address',
                               CURRENCY_TYPE = 'currency',
                               EMAIL_TYPE = 'email',
                               PHONE_TYPE = 'phone',
                               ENCRYPTED_TYPE = 'encryptedstring',
                               PERCENT_TYPE = 'percent',
                               REFERENCE_TYPE = 'reference',
                               TEXTAREA_TYPE = 'textarea',
                               TIME_TYPE = 'time',
                               URL_TYPE = 'url',
                               PICKLIST_TYPE = 'picklist',
                               MULTI_PICKLIST_TYPE = 'multipicklist',
                               DATA_CATEGORY_REF_TYPE = 'datacategorygroupreference',
                               ID_TYPE = 'id';

    // null result for json field
    public static final String DEFAULT_TYPE = STRING_TYPE;
    /**
     * Allowable type that can extract from the SOBject
     */
    public static final Set<String> ALLOWABLE_TYPES = new Set<String> {
        STRING_TYPE,
        ANYTYPE_TYPE,
        TEXT_TYPE,
        BOOL_TYPE,
        INT_TYPE,
        LONG_TYPE,
        COMBOBOX_TYPE,
        BASE64_TYPE,
        DOUBLE_TYPE,
        DECIMAL_TYPE,
        DATE_TYPE,
        DATETIME_TYPE,
        ADDRESS_TYPE,
        CURRENCY_TYPE,
        EMAIL_TYPE,
        PHONE_TYPE,
        ENCRYPTED_TYPE,
        PERCENT_TYPE,
        REFERENCE_TYPE,
        TEXTAREA_TYPE,
        TIME_TYPE,
        URL_TYPE,
        PICKLIST_TYPE,
        MULTI_PICKLIST_TYPE,
        DATA_CATEGORY_REF_TYPE,
        ID_TYPE
    };
    /*
     * our exception
     */
    public class accc_SObjectGetSetException extends Exception {}


    ////////////////////////////////////////////////////////////////////////////////
    // Private Members
    ////////////////////////////////////////////////////////////////////////////////

    @TestVisible
    static Boolean CAUSE_TEST_EXCEPTION_WRITE_VALUE = false,  CAUSE_TEST_EXCEPTION_GET = false;
    @TestVisible
    static final Boolean IN_TEST_MODE =Test.isRunningTest();

    @TestVisible
    Object DEFAULT_RETURN_VALUE = null;


    ////////////////////////////////////////////////////////////////////////////////
    /// Ctors
    ////////////////////////////////////////////////////////////////////////////////


    /*
     * default ctor, set up the getter/setter of values SOBject
     */
    public accc_SObjectGetSet() {
        this(null);
    }// end of ctor

    /*
     *  ctor, set up the getter/setter of values SOBject
     */
    public accc_SObjectGetSet(String defaultReturn) {
        this.ignoreExceptionOnGetField = false;
        this.theException = null;
        this.DEFAULT_RETURN_VALUE = defaultReturn;
        this.sObjects = null;
        this.domain = null;
        this.usesRelatedObjects = true;
        this.checkIncomingTypes=false;

    } // end of ctor

    ////////////////////////////////////////////////////////////////////////////////
    /// Public Properties
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * Getter/Setter of the domain
     */
    @TestVisible
    public String domain {
        get;
        protected set;
    }// end of domain

    /**
     * Getter/Setter isgnore exceptions on get on SObject
     */
    public boolean ignoreExceptionOnGetField {
        get;
        set;
    }// end of ignoreExceptionOnGetField
    /**
     * Getter/Setter check incoming types in getValue
     */
    public boolean checkIncomingTypes {
        get;
        set;
    }// end of checkIncomingTypes

    /**
     * Getter/Setter uses related fields ( ie. Campaign.Name , Account.Name, etc.)
     *
     */
    @TestVisible
    public boolean usesRelatedObjects {
        get;
        protected set;
    }// end of usesRelatedObjects

    /**
     * Getter/Setter for the collection of sobjects
     */
    @TestVisible
    public Exception theException {
        get;
        protected set;
    }// end of theException

    ////////////////////////////////////////////////////////////////////////////////
    /// Protected Properties
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * Getter/Setter for the collection of sobjects
     */
    @TestVisible
    protected List<Sobject> sObjects {
        get;
        set;
    }// end of SObjects

    ////////////////////////////////////////////////////////////////////////////////
    /// Public Static Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * ensureCorrectType
     * @description ensure the correct type; throw if invalid
     * @param incoming type
     *
     **/
    public boolean ensureCorrectType(String incoming){
        // any work
        if (  this.checkIncomingTypes ) {
            // valid string
            Boolean isValid= String.isNotEmpty(incoming);
            // if valid string, check allowable types
            if ( isValid ) {
                String lcIncoming = incoming.toLowerCase();
                isValid= ALLOWABLE_TYPES.contains(lcIncoming);
            }
            // if not valid, throw
            if ( isValid == false ) {
                throw new accc_SObjectGetSetException(NOT_RECOGNIZED_TYPE);
            }

        }
        return true;

    }// end of ensureCorrectType
    ////////////////////////////////////////////////////////////////////////////////
    /// Public Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description we pre-process the fields that are incoming. Why?
     * We are looking for speed-ups when dealing with related object names. For example
     * 'Campaign.Name' from a CampaignMember SOQL. The class has to check to see if there
     * is a special case (the above) and then first grab the Campaign reference and then
     * look up the field. This can cost precious CPU time when dealing with BULK data.
     * So, we check all possible fields and if we don't need to deal with related objects
     * we can skip the check; as such, one less operation, and sw can process
     * MUCH MORE DATA (BULK) !!!
     * @param fields list of api-names
     * @return Boolean true, if has to pre-process
     **/
    public Boolean preProcessAPIFields(List<String> fields){
        Boolean isRelated = false;
        // fields ?
        if ( fields != null  ) {
            for ( String field: fields ) {
                // special api
                if ( field.contains(FIELD_SEPARATOR)) {
                    isRelated = true;
                    // done
                    break;
                }
            }
        }
        this.usesRelatedObjects=isRelated;
        return this.usesRelatedObjects;
    }// end of preProcessAPIFields


    /**
     * @description we pre-process the fields that are incoming. Why?
     * We are looking for speed-upds when dealing with related object names. For example
     * 'Campaign.Name' from a CampaignMember SOQL. The class has to check to see if there
     * is a special case (the above) and then first grab the Campaign reference and then
     * look up the field. This can cost precious CPU time when dealing with BULK data.
     * So, we check all possible fields and if we don't need to deal with related objects
     * We can process MUCH MORE DATA (BULK) !!!
     * @param fields list of SObjectFields
     * @return Boolean
     **/
    public Boolean preProcessAPIFields(List<Schema.SObjectField>  fields){
        Boolean isRelated = false;
        // fields ?
        if ( fields != null) {

            String result;
            for ( Schema.SObjectField field: fields ) {
                result = field.getDescribe().getRelationshipName();
                // special api
                if ( string.isNotBlank(result) ) {
                    isRelated = true;
                    // done
                    break;
                }
            }
        }
        this.usesRelatedObjects=isRelated;
        return isRelated;

    }// end of preProcessAPIFields

    /**
     * @description get the value (based on API) from the SObject
     * @param item the SObject
     * @param apiName sobject api name
     * @return Object previous value from sobject
     **/
    public Object setValue(SObject item,String apiName, Object value){
        Object result=null;
        if ( item == null || string.isBlank(apiName) ) {
            throw new accc_SObjectGetSetException(NOT_RECOGNIZED_SOBJECT_OR_ITEM);
        }
        return item.put(apiName,value);
    }// end of setValue

    /**
     * @description get the value (based on API) from the SObject
     * @param item the SObject
     * @param field sobject field
     * @return Object previous value from sobject
     **/
    public Object setValue(SObject item, Schema.SObjectField field, Object value) {
        Object result=null;
        // reset th exception before getting value
        this.theException =null;
        if ( item == null || field==null ) {
            throw new accc_SObjectGetSetException(NOT_RECOGNIZED_SOBJECT_OR_ITEM);
        }
        return item.put(field,value);
    }// end of setValue

    /**
     * @description get the value (based on API) from the SObject
     * @param item the SObject
     * @param apiName sobject api name
     * @return Object value from sobject
     **/
    public Object getValue(SObject item,String apiName){
        return this.getValue(item, apiName,DEFAULT_TYPE);
    }// end of getValue


    /**
     * @description get the value (based on API) from the SObject
     * @param item the SObject
     * @param apiName SObjectField
     * @return Object value from sobject
     **/
    public Object getValue(SObject item,Schema.SObjectField apiName){
        if ( item == null|| apiName == null  ) {
            return this.DEFAULT_RETURN_VALUE;
        }
        return this.getValue(item,
                             apiName.getDescribe().getName(),
                             apiName.getDescribe().gettype().name());
    }// end of getValue

    /*
     * @param item sobject
     * @param apiName api name
     * @param itemType value type
     *
     * @return Object
     */
    public Object getValue(SObject item, String apiName, String itemType){

        if ( item == null || String.isBlank(apiName) ) {
            return this.DEFAULT_RETURN_VALUE;
        }

        Object data =null;
        // reset the exception before getting value
        this.theException =null;
        // check the type if ok;otherwise, throw an exception on the 'itemType'
        // This just ensures complete correctness; whereby an incoming (ETL) wants to ensure data value correctness
        // otherwise, this acts as a NO-OP
        this.ensureCorrectType(itemType);

        // catch exceptions and decide what to do
        try {

            //+++++++++++++++++++++++++++++++++++++++++++++
            //+ FOR TESTING PURPOSE
            //+++++++++++++++++++++++++++++++++++++++++++++
            if ( CAUSE_TEST_EXCEPTION_GET && IN_TEST_MODE ) {
                throw new accc_SObjectGetSetException(TEST_EXCEPTION_MSG);
            }

            /*
             * This is a speed-up bec/ string.contains &  a loop eats
             * precious CPU. Thus, if the user pre-processes all the known apis
             * we can AVOID this call and save CPU. For Bulk performance, any little bit MATTERS!
             */

            // is it a sobject reference ( i.e. Campaign.Name)
            if ( this.usesRelatedObjects ) {
                data = this.getRelatedValue(item,apiName);
            }
            // if not a sobject, check by field
            if ( data == null) {
                data= (Object)item.get(apiName);
            }

        } catch (Exception excp) {
            this.handleException(excp);
        }
        return data == null ? this.DEFAULT_RETURN_VALUE : data;
    } // end of getValue

    /*
     * @description is this a sobject (ie. Campaign.Name, Account.Name, etc. ). Will not make
     * recursive as this eats up heap and cpu. Already expensive call eats CPUs
     * @param item sobject
     * @param apiName api name
     *
     * @return Object
     */
    public Object getRelatedValue(SObject item, String apiName) {
        List<String> names = null;
        integer size=0;
        SObject myObject=null;
        Object result=null;

        // NOTE: Speed-UP : If you know there are NO related objects, this call can be avoid

        // here we check for SObjects ( related object, dot notation)
        if ( apiName != null && apiName.contains(FIELD_SEPARATOR)) {
            SObject last=item;
            // will always returns non-null value
            names = accc_ApexUtilities.splitStringOnExpression(apiName,'\\.');
            size = names.size();

            try {
                integer index=0,
                        len = size;
                // traverse the related object (i.e. Account.Name, Campaign.Name, etc.)
                do {
                    // get the sobject reference ('Account.Name', last part now be 'Account', and we are pointing to 'Name' of Account SObject )
                    if ( index == len ) {
                        // down to the actual value
                        result = (Object)last.get(names[index]);
                        break;
                    } else {
                        // get the sobject reference ('Account.Name', first part will grab 'Account' )
                        myObject = (SObject)last.getSObject(names[index]);
                    }
                    // next sobject, if any
                    if ( myObject != null ) {
                        last = myObject;
                    }

                } while (++index <= len--);
            } catch (Exception excp) {
                this.handleException(excp);
            }
        }

        return result;
    }// end of getRelatedValue


    ////////////////////////////////////////////////////////////////////////////////
    /// Protected Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * injectIntoJSON
     * @description get the sobject by name and write out json; this
     * assumes you know the proper TYPE when setting it in the JSON metadata.
     * If you are UNSURE, set the 'Type' to 'Unknown' and it will render as a String
     *
     * @param json generator
     * @param item sobject
     * @param apiName api name
     * @param itemType value type
     * @return void
     **/
    @TestVisible
    protected virtual void injectIntoJSON(Object jsGen,SObject item,String name, String apiName, String itemType){


    }// end of injectIntoJSON


    ////////////////////////////////////////////////////////////////////////////////
    /// Private Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * handleException
     * @description what to do with the exception
     * @param  excp the exception
     */
    @TestVisible
    private void handleException(Exception excp) {
        if ( false== this.ignoreExceptionOnGetField ) {
            this.theException = excp;
            accc_ApexUtilities.log(excp);
        }
    }// end of handleException

}// end of accc_SObjectGetSet