/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 11-30-2024
 * @last modified by  : Unni
**/
public with sharing class TARequestHelper {
    public TARequestHelper() {

    }

    public static TACreateJobWithDocRequest buildReqBody_withDoc(String sessionID, String processName, List<String> documentIds, List<InputVariables> inputs) {
        
       
        // Set Session Id
        TACreateJobWithDocRequest reqBody = new TACreateJobWithDocRequest();
        reqBody.sessionId = sessionID;
        // Add Process Identity
        reqBody.ProcessIdentity = new TACreateJobWithDocRequest.ProcessIdentity();
        reqBody.processIdentity.Id = null;
        reqBody.processIdentity.Name = processName;
        // Add RuntimeDocument
        reqBody.JobWithDocsInitialization = new TACreateJobWithDocRequest.JobWithDocsInitialization();

        List<TACreateJobWithDocRequest.RuntimeDocumentCollection> runtimeDocumentCollectionList = new List<TACreateJobWithDocRequest.RuntimeDocumentCollection>();

        for (ContentVersion contentVersion  : [SELECT Id, FileExtension, VersionData 
                                                FROM ContentVersion 
                                                WHERE Id in :documentIds]) {
            Blob versiondataBase64 = contentVersion.VersionData;
            String mimeType = getMimeTypeFromExtension(contentVersion.FileExtension);
            TACreateJobWithDocRequest.RuntimeDocumentCollection runtimeDocumentVar = new TACreateJobWithDocRequest.RuntimeDocumentCollection();
            runtimeDocumentVar.Base64Data = versiondataBase64;
            runtimeDocumentVar.MimeType = mimeType;
            runtimeDocumentVar.ReturnAllFields = true;
            runtimeDocumentVar.ReturnFullTextOcr = false;
            runtimeDocumentCollectionList.add(runtimeDocumentVar);
            
        }

        reqBody.JobWithDocsInitialization.RuntimeDocumentCollection = runtimeDocumentCollectionList;       
        reqBody.JobWithDocsInitialization.InputVariables = inputs;
        return reqBody;
    }


    public static TACreateJobRequest buildReqBody(String sessionID, String processName, List<InputVariables> inputs) {
        
       
        // Set Session Id
        TACreateJobRequest reqBody = new TACreateJobRequest();
        reqBody.sessionId = sessionID;
        // Add Process Identity
        reqBody.ProcessIdentity = new TACreateJobRequest.ProcessIdentity();
        reqBody.processIdentity.Id = null;
        reqBody.processIdentity.Name = processName;
        reqBody.jobinitialization = new TACreateJobRequest.JobInitialization();   
        reqBody.jobinitialization.InputVariables = inputs;
        return reqBody;
    }

    /**
    * @methodName     : getMimeTypeByExtension
    * @description:   : Converts file extension to Mime Type
    * @author         : John Hogan

    * @param          : extension (String): Name of the file extension
    
    * @return         : String: Name of the Mime Type
    */
    public static Map<String, String> mimeTypeByExtension = new Map<String, String>{ 'jpg' => 'image/jpeg', 'jpeg' => 'image/jpeg', 'png' => 'image/png', 'tiff' => 'image/tiff', 'pdf' => 'application/pdf'};

    public static String getMimeTypeFromExtension(String extension) {
        if (mimeTypeByExtension.containsKey(extension)) {
            return mimeTypeByExtension.get(extension);
        }

        return null;
    }

    public static HttpResponse makeCallout(String endPoint, String method, String body, Map<String, String> headers) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint(endPoint);
        req.setMethod(method);
        req.setTimeout(120000);

        // Add body
        if (body != null) {
            req.setHeader('Content-Type', 'application/json');
            req.setBody(body);
        }

        // Add headers
        if (headers != null) {
            for (String header : headers.keySet()) {
                req.setHeader(header, headers.get(header));
            }
        }

        HttpResponse res = h.send(req);

        if ((res.getStatusCode() < 200 || res.getStatusCode() > 299)) {
            //unsuccessful callout and no custom error handling in place
            throw new CalloutException('Endpoint : ' + endpoint + ' , Error: ' + (String) res.getBody());
        }

        return res;
    }
    public static TAResponseWrapper processResponse(HttpResponse response, KTA_Job__c job) {
        // Step 1: Parse the response using TAResponse
        TAResponse responseObj = TAResponse.parse(response);
        
        // Step 2: Populate the KTA_Job__c.Response_Json__c field
        job.Response_Json__c = response.getBody();
        job.TotalAgility_Job_Id__c = responseObj.Id;
        job.TA_Response_Status__c = response.getStatusCode() + ' ' + response.getStatus();

        // Step 3: Create and populate the TAResponseWrapper instance
        TAResponseWrapper responseWrapper = new TAResponseWrapper();
        responseWrapper.jobID = responseObj.Id;
        responseWrapper.result = responseObj.Result;
        responseWrapper.resultMessage = responseObj.ResultMessage;

        // Return the responseWrapper instance
        return responseWrapper;
    }
    
}