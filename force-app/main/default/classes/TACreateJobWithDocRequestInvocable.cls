/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 11-29-2024
 * @last modified by  : Unni
**/
global with sharing class TACreateJobWithDocRequestInvocable {
    @InvocableMethod (callout=true label='Invoke TotalAgility Process with Documents' description='Invokes a TotalAgility Process which requires documents')
    global  static List <TAResponseWrapper> processRequests(List<RequestWrapper> requests) {
        List<TAResponseWrapper> responseList = new List<TAResponseWrapper>();
        List<KTA_Job__c> jobs = new List<KTA_Job__c>();
        for (RequestWrapper request : requests) {
            // Retrieve custom settings
            TotalAgility_System_Configurations__c config = TotalAgility_System_Configurations__c.getInstance();

            // Get the session ID from custom settings
            String sessionId = config.Session_ID__c;
            String endpointURL = config.Total_Agility_End_point_URL__c +'createjobwithdocuments';
            // Process each request here
            KTA_Job__c job = new KTA_Job__c();
            job.Process_Name__c = request.processName;
            job.Document_Id__c = String.join(request.documentIds, ',');
            job.Request_Input_Variables__c = String.valueOf(request.inputs);
            System.debug('Processing request: ' + request.processName);
            System.debug('Document Id: ' + request.documentIds);
            System.debug('Input Variables: ' + request.inputs);
            TACreateJobWithDocRequest taDocRequestbody = TARequestHelper.buildReqBody_withDoc(sessionId, request.processName, request.documentIds, request.inputs);
            Map<String,String> headerMap = new Map<String,String>();
            String jsonRequestBody = JSON.serialize(taDocRequestbody);
            String contentLength = String.valueOf(jsonRequestBody.length());
            headerMap.put('Content-Length', contentLength);
            HttpResponse response = TARequestHelper.makeCallout(endpointURL, 'POST', jsonRequestBody, headerMap);
            
            TAResponseWrapper responseWrapper = TARequestHelper.processResponse(response, job);
            responseList.add(responseWrapper);
            jobs.add(job);



        }
        insert jobs;
        return responseList;
    }

   
    global  class RequestWrapper {
        @InvocableVariable(label='Process Name' description='TotalAgility process name to be invoked' required=true)
        global  String processName;

        @InvocableVariable (label='Document Ids' description='Document Ids to be passed to the process')
        global  List<String> documentIds;

        @InvocableVariable (label='Input Variables' description='Input variables to be passed to the process')
        global  List<InputVariables> inputs;
        
        
    }
}