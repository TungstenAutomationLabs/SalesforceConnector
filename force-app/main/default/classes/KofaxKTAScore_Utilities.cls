/**
* @apexClassName    : KofaxKTAScore_Utilities
* @date             : August 2, 2023
* @description      : Class with Utility functions for the KTA Risk Score Application
* @author           : John Hogan, johnejhogan@gmail.com
*/
public class KofaxKTAScore_Utilities{ 
    
    public static String TEST_STATIC_RESOURCE = 'RiskResponseTest';
    
    /**
    * @methodName     : logKofaxRequestRisk
    * @description:   : Creates a File (ContentVersion) that contains the KofaxRequestRisk body JSON; used during development, may
                        be deleted in Production

    * @author         : John Hogan

    * @param          : reqBody (String): KofaxRequestRisk body JSON
    * @param          : version (String): KofaxRequestRisk version
    
    * @return         : void
    */
    public static void logKofaxRequestRisk(String reqBody, String version){
        ContentVersion cvLog = new ContentVersion();
        
        cvLog.Title = 'KofaxRequestRisk-' + version + '-' + System.Now().format();
        cvLog.PathOnClient = 'KofaxRequestRiskV2.txt';
        cvLog.VersionData = Blob.valueOf(reqBody);
        cvLog.IsMajorVersion = true;

        try {
            insert cvLog;
            // 2023-09-10, #ToDo - Remove debug in Production
            System.debug('*** Created Log File: ' + cvLog.Title);
        } catch (DmlException ex) {
            throw new RiskUtilsDMLException('Create logKofaxRequestRisk Log Entry Failed');
        }
        
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

    /**
    * @methodName     : getApplicationStatus
    * @description:   : Return Status of an Application__c record; used by kofaxRiskScoreTaskListCmp
    * @author         : John Hogan

    * @param          : appId (ID): Record Id of the Application__c record
    
    * @return         : List<Application__c>: List of Application__c records with Status__c
    */
    // @AuraEnabled
    // public static List<Application__c> getApplicationStatus(Id appId){
    //     return [SELECT Id, Status__c from Application__c where Id = :appId];
    // }

    /**
    * @methodName     : getTaskList
    * @description:   : Retreive all Application__c Task records with 'Document Request' or without 'Document Request' Type; 
    *                   used by kofaxRiskScoreTaskListCmp and kofaxRiskScoreActivityListCmp
    
    * @author         : John Hogan

    * @param          : taskRecordId (String): Record Id of the Application__c record
    
    * @return         : List<Task>: List of Task records
    */
    // @AuraEnabled(cacheable=true)
    // public static List<Task> getTaskList(String taskRecordId, Boolean docRequestTasks) {
        
    //     String TYPE_DOC_REQUEST = KofaxKTAScore_Constants.KOFAX_RISK_TASK_RECORD_TYPE;
    //     String soqDocRequest = 'SELECT Id, Subject, ActivityDate, IsClosed, Status, KTA_Risk_Score__c, Type FROM Task WHERE (WhatId = :taskRecordId AND Type = :TYPE_DOC_REQUEST) ORDER BY IsClosed ASC';

    //     if (!docRequestTasks)
    //         soqDocRequest = soqDocRequest.replace('Type = :TYPE_DOC_REQUEST', 'Type != :TYPE_DOC_REQUEST');

    //     List<Task> taskList = Database.query(soqDocRequest);
    
    //     if (taskList.size() == 0){
    //         return new List<Task>();
    //     }
        
    //     return taskList;
        
    // }
    /**
    * @methodName    : getApplicationPercentComplete
    * @description   : Determine the percentage of completed 'Document Request' Tasks; used by kofaxRiskScoreTaskListCmp
    * @author        : John Hogan

    * @param         : taskRecordId (String): Record Id of the Application__c record
    
    * @return        : Integer: Number representation of percentage of completed 'Document Request' Tasks
    */
    // @AuraEnabled(cacheable=true)
    // public static Integer getApplicationPercentComplete(String taskRecordId){
    //     Double totalTasks;
    //     Integer completedTasks = 0;
    //     Double percentComplete = 0;
    //     List<Task> taskList = getTaskList(taskRecordId, true);
    //     totalTasks = taskList.size();
    //     if(totalTasks > 0){
    //         for (Task t : taskList){
    //             if (t.IsClosed)
    //                 completedTasks++;
    //         }
    //         percentComplete = (completedTasks/totalTasks) * 100;
    //     }   
    //     return Integer.valueOf(percentComplete);
    // }
    /**
    * @Method Name    : getContentVersionData
    * @description:   : Retreive FileExtension and VersionData from ContentVersion
    * @author         : John Hogan

    * @param          : contentVersionId (String): Record Id of ContentVersion record
    
    * @return         : Object: ConvtentVersion
    */
    public static ContentVersion getContentVersionData(String cvId){
        
        List<ContentVersion> cv = [SELECT Id, FileExtension, VersionData from ContentVersion WHERE Id = :cvId LIMIT 1];
        
        if (cv.size() == 0)
            return null;
        
        return cv[0];
    }
    
    /**
     * @methodName      : makeCallout
     * @description     : Callout with no Body or Header parameters
     * 
     * @param           : endPoint (String): Callout endpoint
     * @param           : method (String): Callout method
     * 
     * @return          : HttpResponse: Callout response
     * 
     * @throws          : CalloutException if an error response is returned
     */
    public static HttpResponse makeCallout(String endPoint, String method) {
        return makeCallout(endPoint, method, null, null);
    }

    /**
     * @methodName      : makeCallout
     * @description     : Used for making callouts with no header
     * 
     * @param           : endPoint (String): Callout endpoint
     * @param           : method (String): Callout method
     * 
     * @return          : HttpResponse: Callout response
     * 
     * @throws CalloutException if an error response is returned
     */
    public static HttpResponse makeCallout(String endPoint, String method, String body) {
        return makeCallout(endPoint, method, body, null);
    }

    /**
     * @methodName      : makeCallout
     * @description     : Used to simplify making callouts
     * 
     * @param           : endPoint (String): Callout endpoint
     * @param           : method (String): Callout method
     * 
     * @return          : HttpResponse: Callout response
     * 
     * @throws CalloutException if an error response is returned
     */
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
    
    /**
     * @methodName      : processSaveResultsList
     * @description     : Simplifies extracting/displaying error messages from DML insertions
     * 
     * @param           : results (List<Database.SaveResult>): Save Results to process
     * @param           : objName (String): Salesforce Object name for inserted record
     * 
     * @throws          : CalloutException if an error response is returned
     */
    public static List<SaveResultWrapper> processSaveResults(List<Database.SaveResult> results, String objName) {
        List<SaveResultWrapper> resultWrappers = new List<SaveResultWrapper>();

        for (Database.SaveResult result : results) {
            SaveResultWrapper resultWrapper = new SaveResultWrapper(result, objName);
            resultWrappers.add(resultWrapper);
        }

        return resultWrappers;
    }

    /**
     * @methodName      : processSaveResults
     * @description     : Simplifies extracting/displaying error messages from DML insertions
     * 
     * @param           : results (List<Database.SaveResult>): Save Results to process
     * @param           : objName (String): Salesforce Object name for inserted record
     * 
     * @throws          : CalloutException if an error response is returned
     */
    public static SaveResultWrapper processSaveResults(Database.SaveResult result, String objName) {
        return new SaveResultWrapper(result, objName);
    }

    /**
     * @className       : SaveResultWrapper
     * @description     : Wrapper class for Save Result with a formatted error message
     */
    public class SaveResultWrapper {
        public String objName { get; set; }
        public String objId { get; set; }
        public Boolean success { get; set; }
        public String errorMessage { get; set; }

        public SaveResultWrapper(Database.SaveResult save, String objName) {
            this.objName = objName;
            this.objId = save.getId();
            this.success = save.isSuccess();

            this.errorMessage = '';

            if (!this.success) {
                for (Database.Error err : save.getErrors()) {
                    this.errorMessage += 'The following error has occurred: ';
                    this.errorMessage += err.getStatusCode() + ': ' + err.getMessage();
                    this.errorMessage += objName + ' fields that affected this error: ' + err.getFields() + '\n';
                }
            }
        }
    }

    /**
     * @className       : TestClassException
     * @description     : Custom Exception Class
     */
    public class TestClassException extends Exception {}

    /**
     * @className       : RiskUtilsDMLException
     * @description     : Custom Exception Class
     */
    public class RiskUtilsDMLException extends Exception {}
}