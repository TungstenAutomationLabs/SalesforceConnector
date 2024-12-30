/**
 * @description       :
 * @author            : Unni
 * @group             :
 * @last modified on  : 12-31-2024
 * @last modified by  : Unni
 **/
global with sharing class TACreateJobWithDocRequestInvocable {
    @InvocableMethod (callout=true label='Invoke TotalAgility Process with Documents' description='Invokes a TotalAgility Process which requires documents')
    global static List<TAResponseWrapper> processRequests(List<RequestWrapper> requests) {
        List<TAResponseWrapper> responseList = new List<TAResponseWrapper>();
        List<KTA_Job__c> jobs = new List<KTA_Job__c>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        
        // Retrieve custom settings
        TotalAgility_System_Configurations__c config = TotalAgility_System_Configurations__c.getInstance();
        String sessionId = config.Session_ID__c;
        String endpointURL = config.Total_Agility_End_point_URL__c + '/createjobwithdocuments';
        
        for (RequestWrapper request : requests) {
            TAResponseWrapper responseWrapper ;            
            KTA_Job__c job = new KTA_Job__c();
            
            try {
                // Process each request
                job.Request_Type__c ='Outbound';
                job.Process_Name__c = request.processName;
                job.Document_Id__c = String.join(request.documentIds, ',');
                job.Request_Input_Variables__c = String.valueOf(request.inputs);
                
                System.debug('Processing request: ' + request.processName);
                System.debug('Document Id: ' + request.documentIds);
                System.debug('Input Variables: ' + request.inputs);
                
                // Build request body
                TACreateJobWithDocRequest taDocRequestbody = TARequestHelper.buildReqBody_withDoc(sessionId, request.processName, request.documentIds, request.inputs);
                String jsonRequestBody = JSON.serialize(taDocRequestbody);
                if(jsonRequestBody.length() > 131072){
                    
                    // // Regular expression to match the key "RuntimeDocumentCollection" and its value
                    // String regExp = '"RuntimeDocumentCollection"\\s*:\\s*\\[.*?\\](,?)';
                    // // Replace with an empty string or a comma (if necessary for cleanup)
                    // String replacement = '"RuntimeDocumentCollection":"String Too Long to store...."'; // Preserve trailing comma if it exists

                    // // Replace the first occurrence of the matching key-value pair
                    // String modifiedJsonString = jsonRequestBody.replaceFirst(regExp, replacement);
                   

                    // // Clean up any leftover commas (optional)
                    // job.Request_Json_body__c = modifiedJsonString.replace(',}', '}').replace(',]', ']');
                    TACreateJobWithDocRequest jobrequest = (TACreateJobWithDocRequest)JSON.deserialize(jsonRequestBody, TACreateJobWithDocRequest.class);
                    jobrequest.JobWithDocsInitialization.RuntimeDocumentCollection = null;
                    job.Request_Json_body__c = JSON.serialize(jobrequest);

                }
                else {
                    job.Request_Json_body__c = jsonRequestBody;
                }

                // Save JSON request body as a file attachment
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = request.processName + '_RequestBody.json';
                contentVersion.PathOnClient = request.processName + '_RequestBody.json';
                contentVersion.VersionData = Blob.valueOf(jsonRequestBody);
                contentVersion.IsMajorVersion = true;
                contentVersions.add(contentVersion);
                
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
            // Relate ContentVersion records to jobs
        if (!contentVersions.isEmpty()) {
            insert contentVersions;
            List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
            for (ContentVersion contentVersion : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions]) {
                ContentDocumentLink link = new ContentDocumentLink();
                link.ContentDocumentId = contentVersion.ContentDocumentId;
                link.LinkedEntityId = jobs[0].Id;
                link.ShareType = 'V';
                link.Visibility = 'AllUsers';
                documentLinks.add(link);
            }
            insert documentLinks;
        }

        }
        
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