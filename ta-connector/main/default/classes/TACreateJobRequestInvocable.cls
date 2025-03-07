/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 01-14-2025
 * @last modified by  : Unni
**/
global with sharing class TACreateJobRequestInvocable {
    @InvocableMethod (callout=true label='Invoke TotalAgility Process' description='Invokes a TotalAgility Process')
    global static List<TAResponseWrapper> processRequests(List<RequestWrapper> requests) {
        List<TAResponseWrapper> responseList = new List<TAResponseWrapper>();
        List<KTA_Job__c> jobs = new List<KTA_Job__c>();
        
        // Retrieve custom settings
        TotalAgility_System_Configurations__c config = TotalAgility_System_Configurations__c.getInstance();
        String sessionId = config.Session_ID__c;
        String endpointURL = config.Total_Agility_End_point_URL__c + '/CreateJob';
        
        for (RequestWrapper request : requests) {
            TAResponseWrapper responseWrapper ;            
            KTA_Job__c job = new KTA_Job__c();
            try {
                // Process each request
                job.Request_Type__c ='Outbound';
                job.Process_Name__c = request.processName;
                job.Request_Input_Variables__c = String.valueOf(request.inputs);
                
                System.debug('Processing request: ' + request.processName);
                System.debug('Input Variables: ' + request.inputs);
                
                // Build request body
                TACreateJobRequest taRequestbody = TARequestHelper.buildReqBody(sessionId, request.processName,request.inputs);
                String jsonRequestBody = JSON.serialize(taRequestbody);
                job.Request_Json_body__c = jsonRequestBody;
                // Set headers
                Map<String, String> headerMap = new Map<String, String>();
                headerMap.put('Content-Length', String.valueOf(jsonRequestBody.length()));
                
                // Make callout
                HttpResponse response = TARequestHelper.makeCallout(endpointURL, 'POST', jsonRequestBody, headerMap);
                
                // Process response
                responseWrapper = TARequestHelper.processResponse(response, job);
                
            } catch (Exception e) {
                // Handle exceptions and log errors
                
                System.debug('Error processing request: ' + e.getMessage());
                
                 responseWrapper = new TAResponseWrapper();
                 responseWrapper.jobID = 'n/a';
                 responseWrapper.Result = 'FAILURE';
                 responseWrapper.ResultMessage = 'Exception : '  + e.getMessage();
            }
           responseList.add(responseWrapper);
           jobs.add(job);
        }
        
        TotalAgility_System_Configurations__c systemConfig = TotalAgility_System_Configurations__c.getInstance();
        Boolean isLoggingEnabled = (systemConfig != null) && systemConfig.Log_Job_inbound_and_outbound_Requests__c;        
        // Insert jobs
        if (!jobs.isEmpty() && isLoggingEnabled) {
            insert jobs;
        }
        
        return responseList;
    }
    
    global  class RequestWrapper {
        @InvocableVariable(label='Process Name' description='TotalAgility process name to be invoked' required=true)
        global  String processName;
        
        @InvocableVariable (label='Input Variables' description='Input variables to be passed to the process')
        global  List<InputVariables> inputs;
        
        
    }
}