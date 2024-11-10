/**
* @apexClassName      : KofaxKTAScore_Invocable 
* @date               : August 2, 2023
* @description:       : Execution class with Invocable Methods used in Flows to Submit Doc to Kofax
* @author             : John Hogan, johnejhogan@gmail.com
*/
global class KofaxKTAScore_Invocable {

    public static String PROCESS_ID_RISK = KofaxKTAScore_Constants.KOFAX_PROCESS_ID;

    /**
    * @methodName     : execute
    * @description:   : Top level Invocable method to Submit Documents to Kofax from Flows
    * @author         : John Hogan

    * @param          : requestList (List<Requests>): Bulkified Input Parameters

    * @return         : List<Results>: Bulkified Output Parameters

    * @throws:        : KTA_Invocable_Exception if an error occurs making/processing the callout
    */
    // 2023-10-31 Added "callout=true", removed "iconName='resource:kofax:icon'"
    @InvocableMethod(callout=true label='Submit Documents to KTA Risk Scoring' description='Upload a document to the KTA Risk Scoring Process')
    // 2023-10-31 Made execute method global
    global static List <Results> execute (List<Requests> requestList) {
        try{
            Requests request = requestList[0];
            
            HttpResponse res = KofaxKTAScore_Helper.submit(request.contentVersionIds[0], request.taskSubject, request.taskId, KofaxKTAScore_Invocable.PROCESS_ID_RISK, KofaxKTAScore_Invocable.PROCESS_ID_RISK);
            
            KofaxResponseRisk Result = KofaxKTAScore_Helper.processKofaxResponseRisk(res.getBody());
            
            // Log Request 2023-09-08 #ToDo: Remove In Production
            KofaxKTAScore_Utilities.logKofaxRequestRisk(KofaxKTAScore_Helper.jsonRequestBody, 'V2');

            Results resultToReturn = new Results();
            resultToReturn.result = Result.d.Result;
            resultToReturn.message = Result.d.ResultMessage;
            
            List<Results> resultWrapper = new List<Results>();
            resultWrapper.add(resultToReturn);
            
            return resultWrapper;

        } catch (Exception e) {
            String errorMessage = 'KTA Invocable Exception: ' + e.getMessage() + '; Stack: ' + e.getStackTraceString();
            throw new KTA_Invocable_Exception(errorMessage);
        }
    }

     /**
      * @className      : Requests
      * @description:   : Wrapper class for Invocable method Input Parameters
     */
    global class Requests {
        
        @InvocableVariable(label='Document to Score' description='Document(s) to upload to the Kofax Process' required=true)
        global List<String> contentVersionIds;
        
        @InvocableVariable(label='Task associated with Document' description='Id of the Task whose document is being uploaded to Kofax' required=true)
        global String taskId;

        @InvocableVariable(label='Type of Document' description='Subject of the Task whose document is being uploaded to Kofax' required=true)
        global String taskSubject;
    }
     /*
     * @className       : Results
     * @description     : Wrapper class for Invocable method Output parameters
     */
    global class Results {
        @InvocableVariable(label='Job Message' description='Results from Kofax callout')
        global String message;

        @InvocableVariable(label='Kofax Risk Score Result' description='Success or Failure')
        global String result;
    }

    global class KTA_Invocable_Exception extends Exception {
    }
}