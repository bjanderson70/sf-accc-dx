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
 * @author Bill anderson
 * @description
 *
 * @File Name          : accc_ApexSObjectTypesUtils.cls
 * @Description        : common utilities for sobject types
 * @Author             : Bill Anderson
 * @Group              : Miscellaneous
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    2/25/2019   Bill Anderson     Initial Version
 **/
global abstract class accc_ApexSObjectTypesUtils {

    /**
     * createSObjectAndCopy
     * @description This utility is for creating a specific sobject Type and copying the
     * data over. It is common practice for 'upsert' usage due to type restrictions
     * @param  theObjects theObjects description
     * @return  specific sobject collection type
     */
    global static List<SObject> createSObjectAndCopy(List<SObject> theObjects){
        List<SObject> specificSObject = accc_ApexSObjectTypesUtils.createSObjectType(theObjects);
        // valid data
        if (specificSObject != null ) {
            // have to copy, cannot just assign (by reference)
            specificSObject.addAll(theObjects);
        }
        return specificSObject;
    }// end of createSObjectAndCopy
     /**
      * createSObjectAndCopy
      * @description This utility is for creating a specific sobject Type and (shallow) copying the
      * data. It is common practice for 'upsert' usage due to type restrictions
      * @param  theObjects theObjects description
      * @return  specific sobject collection type
      */
    global static SObject createSObjectAndCopy(SObject theObject){
        SObject specificSObject = accc_ApexSObjectTypesUtils.createSObjectType(theObject);
        // valid data
        if (specificSObject != null ) {
            // shallow copy
            specificSObject= theObject.clone(true, false, false, false);
        }
        return specificSObject;
    } // end of createSObjectAndCopy

    /**
     * createSObjectType
     * @description This utility is for creating a specific sobject Types.
     * It is common practice for 'upsert' usage due to type restrictions
     * @param  theObjects the collection SObject
     * @return  specific collection of sobject  types
     */
    global static List<SObject> createSObjectType(List<SObject> theObjects){
        List<SObject> specificSObject = theObjects;
        String name=accc_ApexUtilities.getSobjectName(theObjects);
        if ( string.isNotBlank(name)) {
            specificSObject = ( List<SObject>)Type.ForName('List<' + name + '>').newInstance();
        }
        return specificSObject;
    } // end of createSObjectType
    /**
     * createSObjectType
     * @description This utility is for creating a specific sobject Type.
     * It is common practice for 'upsert' usage due to type restrictions
     * @param  theObject the SObject
     * @return  specific sobject  type
     */
    global static SObject createSObjectType(SObject theObject){
        SObject specificSObject = theObject;
        String name=accc_ApexUtilities.getSobjectName(theObject);
        if ( string.isNotBlank(name)) {
            specificSObject = ( SObject)Type.ForName(name).newInstance();
        }
        return specificSObject;
    }  // end of createSObjectType

}// end of accc_ApexSObjectTypesUtils