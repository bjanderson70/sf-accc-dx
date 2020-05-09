/**
 * Copyright (c) 2019-2020, Bill Anderson.  All rights reserved.
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
 * @File Name          : accc_ApexJSONObjectParser.cls
 * @Description        : Base class for Apex Object JSON Parser
 * @Author             : Bill Anderson
 * @Group              : Common
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    2/8/2020   Bill Anderson     Initial Version
 **/
public virtual class accc_ApexJSONObjectParser {
    @TestVisible
    static Boolean CAUSE_EXCEPTION = false;
    /**
     * parse
     * @description parse a list of (SAME type) objects into JSON
     * @param  theObjects the List of Objects
     * @return JSON String
     */
    public virtual string parse(List<Object> theObjects) {
        String results=accc_ApexConstants.EMPTY_JSON_s;
        // if valid data
        if ( theObjects != null ) {
            try {
                // for testing
                if ( CAUSE_EXCEPTION
                     && accc_ApexConstants.UNIT_TEST_RUNNING ) {
                    throw new accc_ApexApplicationException();
                }
                results=System.JSON.serialize(theObjects);
            } catch (Exception excp) {
                accc_ApexUtilities.log(excp);
            }
        }
        return results;
    }// end of parse
     /**
      * parse
      * @description parse an object into JSON
      * @param  theObject the Object (not a collection)
      * @return JSON String
      */
    public virtual string parse(Object theObject){
        String results=accc_ApexConstants.EMPTY_JSON_s;
        // if valid data
        if ( theObject != null ) {
            try {
                // for testing
                if ( CAUSE_EXCEPTION
                     && accc_ApexConstants.UNIT_TEST_RUNNING ) {
                    throw new accc_ApexApplicationException();
                }
                results=System.JSON.serialize(theObject);
            } catch (Exception excp) {
                accc_ApexUtilities.log(excp);
            }
        }
        return results;
    }
    /**
     * parse
     * @description parse JSON string into Object
     * @param  json json of a collection of objects
     * @return      return collection of objects
     */
    public virtual List<Object> parse(String json,Type theType) {
        List<Object> results=null;
        // if valid data
        if ( string.isNotBlank(json)
             && theType != null ) {
            try {
                // for testing
                if ( CAUSE_EXCEPTION
                     && accc_ApexConstants.UNIT_TEST_RUNNING ) {
                    throw new accc_ApexApplicationException();
                }
                results=(List<Object>)System.JSON.deserialize(json, theType);
            } catch (Exception excp) {
                accc_ApexUtilities.log(excp);
            }
        }
        return results;
    }// end of parse
}// end of accc_ApexJSONObjectParser