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
 * @File Name          : accc_IApexCRUDProvider.cls
 * @Description        : Apex CRUD Provider Contract
 * @Author             : Bill Anderson
 * @Group              : Common
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    1/8/2017   Bill Anderson     Initial Version
 **/
public interface accc_IApexCRUDProvider {

    /**
     * getDmlOptions
     * @description getter of DMLOptions
     * @return  DMLOptions
     */
    accc_ApexDMLOptions getDmlOptions();
    /**
     * setDmlOptions
     * @description set the DML options, returning the previous setting
     * @param  options DmlOptions
     * @return previous DmlOptions
     */
    accc_ApexDMLOptions setDmlOptions(accc_ApexDMLOptions options);
    /**
     * insertDb
     * @description insert objects into sink
     * @param  theObjects the List of Objects
     * @return result handler
     */
    accc_GenericDbResultHandler insertDb(List<SObject> theObjects);
    /**
     * updateDb
     * @description update objects into sink
     * @param  theObjects the List of Objects
     * @return result handler
     */
    accc_GenericDbResultHandler updateDb(List<SObject> theObjects);
    /**
     * upsertDb
     * @description update/insert objects into sink
     * @param  theObjects the List of Objects
     * @return result handler
     */
    accc_GenericDbResultHandler upsertDb(List<SObject> theObjects);
    /**
     * deleteDb
     * @description delete objects in sink
     * @param  theObjects the List of Objects
     * @return result handler
     */
    accc_GenericDbResultHandler deleteDb(List<SObject> theObjects);

    /**
     * getAccessibleRecords
     * @description get accessible record based on mode for delete ONLY
     * @param  theObjects the Object collection
     * @param accc_ApexDMLOptions dml and various options
     * @return accesible records based on access and mode
     */
    List<SObject> getAccessibleRecords(List<SObject> theObjects);
    /**
     * getAccessibleRecords
     * @description get accessible record based on mode
     * @param  theObjects the Object collection
     * @param System.AccessType ( create, upsert, etc.)
     * @return accesible records based on access and mode
     */
    List<SObject> getAccessibleRecords(List<SObject> theObjects,System.AccessType aType);
    /**
     * determineDMLAllowed
     * @description determine the DML action is allowed on SObjects (can insert, update, delete ...)
     * @param  theObjects the collection of SObjects
     * @param  dmlAction  the DML Action (insert, upsert,update, delete)
     * @return  true, if action is possible
     */
    Boolean determineDMLAllowed(List<SObject> theObjects,accc_ApexDMLOptions.DMLAction dmlAction);
} // end of accc_IApexJSONObjectParser