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
 * @File Name          : accc_ApexDMLOptions.cls
 * @Description        : Apex DML Options for CRUD
 * @Author             : Bill Anderson
 * @Group              : Common
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    1/8/2017   Bill Anderson     Initial Version
 **/
global with sharing class accc_ApexDMLOptions {


    ///////////////////////////////////////////////////////////////////////////////////
    // Data Members
    ///////////////////////////////////////////////////////////////////////////////////


    /**
     * DML Mode allows one to call the appropriate DML. By
     * default it is synchronous. However, there is immediate
     * bec/ of constraints of communities, Big Objects, etc.
     */
    global enum DMLMode {
        SYNC,
        IMMEDIATE
    }
    /**
     * Run in System,User Mode, Inherited
     */
    global enum ExecutionMode {
        USER_MODE,
        SYSTEM_MODE,
        INHERITED_MODE
    }
    /**
     * Dml Action
     */
    global enum DMLAction {
        UPDATEABLE ,
        INSERTABLE ,
        UPSERTABLE,
        DELETABLE ,
        READABLE,
        ALL
    } 
    /**
     * Our Database DMLOptions
     */
    @TestVisible
    private Database.DMLOptions mOptions=null;
    ///////////////////////////////////////////////////////////////////////////////////
    // Ctors
    ///////////////////////////////////////////////////////////////////////////////////


    /**
     * accc_ApexDMLOptions
     * @description default ctor, runs in userinherited mode
     */
    global accc_ApexDMLOptions() {
        this(ExecutionMode.INHERITED_MODE,DMLMode.SYNC,null);
    }// end of accc_ApexDMLOptions
    /**
     * accc_ApexDMLOptions
     * @description ctor setting dmloptions
     */
    global accc_ApexDMLOptions(Database.DMLOptions dmlOption) {
        this(ExecutionMode.INHERITED_MODE,DMLMode.SYNC,dmlOption);
    }// end of accc_ApexDMLOptions
     /**
      * accc_ApexDMLOptions
      * @description ctor setting dml-mode and dmloptions
      * @param DMLMode ( sync, async ...)
      * @param DMLOptions all or none ...
      */
    global accc_ApexDMLOptions(DMLMode mode,Database.DMLOptions dmlOption) {
        this(ExecutionMode.INHERITED_MODE,mode,dmlOption);
    }// end of accc_ApexDMLOptions
    /**
     * accc_ApexDMLOptions
     * @description ctor setting dmloptions
     * @param ExecutionMode user/system mode
     */
    global accc_ApexDMLOptions(ExecutionMode umode) {
        this(umode,DMLMode.SYNC,null);
    } // end of accc_ApexDMLOptions
    /**
     * accc_ApexDMLOptions
     * @description ctor setting dml-mode and dmloptions
     * @param ExecutionMode user/system mode
     * @param DMLMode ( sync, async ...)
     * @param DMLOptions all or none ...
     */
    global accc_ApexDMLOptions(ExecutionMode umode,DMLMode mode,Database.DMLOptions dmlOption) {
        Database.DMLOptions incoming = dmlOption;
        // need options
        if ( dmlOption == null ) {
            incoming = new Database.DMLOptions();
            incoming.OptAllOrNone = true;
            incoming.AllowFieldTruncation=false;
        }
        this.theDMLMode = mode;
        this.theExecutionMode = umode;
        this.mOptions = incoming;
    } // end of accc_ApexDMLOptions

    ///////////////////////////////////////////////////////////////////////////////////
    // Public Properties
    ///////////////////////////////////////////////////////////////////////////////////

    /**
     * Getter/Setter of Execution Mode
     */
    global ExecutionMode theExecutionMode {
        get;
        set;
    }// end of theExecutionMode
    /**
     * Getter/Setter of DML Mode
     */
    global DMLMode theDMLMode {
        get;
        set;
    }// end of theDMLMode
    ///////////////////////////////////////////////////////////////////////////////////
    // Public Methods
    ///////////////////////////////////////////////////////////////////////////////////

    /**
     * getDmlOptions
     * @description getter of DMLOptions
     * @return  DMLOptions
     */
    global Database.DMLOptions getDmlOptions() {
        return this.mOptions;
    }// end of getDmlOptions
    /**
     * setDmlOptions
     * @description set the DML options, returning the previous setting
     * @param  options DmlOptions
     * @return previous DmlOptions
     */
    global Database.DMLOptions setDmlOptions(Database.DMLOptions options){
        Database.DMLOptions last = this.mOptions;
        if ( options != null) {
            this.mOptions = options;
        }
        return last;
    }// end of setDmlOptions
}// end of accc_ApexDMLOptions