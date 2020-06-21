/**
 * The MIT License (MIT)
 * Copyright (c) 20-April-2016 Bill J. Anderson
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 * IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
 *
 *
 * @author Bill Anderson
 * @description Holder of the last transaction operations (TBD -- needs to accomodate other Database Results)
 * @group Common Layer
 */
public inherited sharing class accc_ApexPreviousTransactionResult implements accc_IPreviousTransactionResult {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //
    //Private Methods
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description last database result
     * @return Database.SaveResult
     */
    @TestVisible
    List<Database.SaveResult> lastResult = null;
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //
    // CTORS
    //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description ctor
     */
    public accc_ApexPreviousTransactionResult() {
        this.databaseResult(null);
    }
    /**
     * @description ctor
     *
     * @param result Database SavedResults
     */
    public accc_ApexPreviousTransactionResult(List<Database.SaveResult> result) {
        this.databaseResult(result);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //
    //Public Methods
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * databaseResult
     * @description get last database result
     * @return  SaveResult
     */
    public List<Database.SaveResult> databaseResult() {
        return this.lastResult;
    }

    /**
     * databaseResult
     * @description set last database result
     *
     * @param result SaveResult
     */
    public void databaseResult(List<Database.SaveResult> result) {
        this.lastResult = result;
    }
    /**
     * processErrors
     * @description process the errors in the result set
     *
     * @return boolean, true if errors were processed
     */
    public boolean processErrors() {
        // write to the non sf debug logger, if errors
        return this.processErrors(false);
    } // end of processErrors

    /**
     * processErrors
     * @description process the errors from the saved results. This functionality usually means
     * writing the information to the active logger ( as found in the factory). Bec/ we may
     * be writing to a loger (via the logger), indicated to the method to redirect output to SF debug log
     *
     * @param boolean, true if writing to the SF debug log
     * @return boolean, true if errors were processed
     */
    public boolean processErrors(boolean toSFDebugLogger) {
        boolean result = false;
        if ( this.lastResult != null ) {
            String last = null;
            List<Object> excps = new List<Object>();

            // iterate over the insert results
            for ( Database.SaveResult saved : this.lastResult) {

                // if successful, set the id (only the differences)
                if ( !saved.isSuccess() ) {
                    result = true;
                    if ( toSFDebugLogger ) {
                        List<Database.Error> errors = saved.getErrors();
                        String current = errors != null && errors.size() > 0 ? errors.get(0).getMessage() : null;
                        if ( current != null ) {
                            if (  last == null ||  !current.equals(last)) {
                                last = current;
                                excps.add(new accc_ApexApplicationException('Database.SaveResults :' + current));
                            }
                        }
                    } else {
                        // if we are not writing to log, break out
                        break;
                    }
                }
            } //endfor

            // log errors, if any
            if ( last != null ) {
                accc_ApexUtilities.log(excps);
            }
        }
        return result;
    }// end of processErrors

} // end of accc_ApexPreviousTransactionResult