/**
* @apexClassName      : KofaxKTAScore_Helper
* @date               : August 2, 2023
* @description:       : Helper class for KofaxKTAScore_Invocable
* @author             : John Hogan, johnejhogan@gmail.com
*/
global with sharing class KofaxKTAScore_Helper {

    public static KofaxResponseRisk kofaxResRisk;
    public static String kofaxResRiskResult;
    public static String kofaxResRiskResultId;
    public static String kofaxResRiskResultMessage;
    public static String kofaxResRiskResultJSON;
    public static String jsonRequestBody;
    public static String rqContentVersionId;
    public static String rqDocumentType;
    public static String rqEntityId;
    public static String rqJobName;

    public static String getResult() {
        return kofaxResRiskResult;
    }

    /**
    * @methodName     : submit
    * @description:   : Build HTTP request body with Request parameters and perform HTTP callout 
    * @author         : John Hogan

    * @param          : contentVersionIds (String): ContentVersion Ids to the documents being submitted
    * @param          : documentType (String): Type of document being submitted (e.g. 'Bank Statement')
    * @param          : entityId (String): Id of the record to which the ContentVersion is associated; Kofax API will update this record
    * @param          : jobId (String): Id of the process to run in Kofax
    * @param          : jobName (String): Type of Job being run

    * @return         : HttpResponse: Response from Kofax
     */
    public static HttpResponse submit(String contentVersionId, String documentType, String entityId, String jobId, String jobName) {

        rqContentVersionId = contentVersionId;
        rqDocumentType = documentType;
        rqEntityId = entityId;
        rqJobName = jobName;
        String endpoint = KofaxKTAScore_Constants.KOFAX_ENDPOINT;
        
        // Version Check #ToDo: Remove when Version if established 
        if(KofaxKTAScore_Constants.KOFAX_RISK_REQUEST_VERSION == 'Default')
            buildReqBody(rqContentVersionId, rqDocumentType, rqEntityId, rqJobName);
        else
            buildReqBodyV2(rqContentVersionId, rqDocumentType, rqEntityId, rqJobName);
        
        Map<String,String> headerMap = new Map<String,String>();
        String contentLength = String.valueOf(jsonRequestBody.length());
        headerMap.put('Content-Length', contentLength);
        
        return KofaxKTAScore_Utilities.makeCallout(endPoint, 'POST', jsonRequestBody, headerMap);
        
    }
    /**
    * @methodMame     : buildReqBody
    * @description:   : Build HTTP request body with Request parameters
    * @author         : John Hogan

    * @param          : contentVersionId (String): ContentVersion Id to the documents being submitted
    * @param          : documentType (String): Type of document being submitted (e.g. 'Bank Statement')
    * @param          : entityId (String): Id of the record to which the ContentVersion is associated; Kofax API will update this record
    * @param          : processId (String): Id of the process to run in Kofax

    * @return         : void
    */
    public static void buildReqBody(String contentVersionId, String documentType, String entityId, String processId) {
        
        ContentVersion contentVersion = KofaxKTAScore_Utilities.getContentVersionData(contentVersionId);
        Blob versiondataBase64 = contentVersion.VersionData;
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('sessionId', KofaxKTAScore_Constants.KOFAX_SESSION_ID);
        gen.writeFieldName('processIdentity');
        gen.writeStartObject();
        gen.writeStringField('Id', processId);
        gen.writeEndObject();
        gen.writeFieldName('jobInitialization');
            gen.writeStartObject();
                gen.writeFieldName('InputVariables');
                gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeStringField('Id', 'ContentVersion');
                    gen.writeStringField('Value', contentVersionId);
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('Id', 'DocumentType');
                    gen.writeStringField('Value', documentType);
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('Id', 'EntityId');
                    gen.writeStringField('Value', entityId);
                    gen.writeEndObject();
                    gen.writeStartObject();
                    gen.writeStringField('Id', 'DocumentBase64');
                    gen.writeBlobField('Value', versiondataBase64);
                    gen.writeEndObject();
                gen.writeEndArray();
        gen.writeEndObject();
        
        jsonRequestBody = gen.getAsString();

    }
    /**
    * @methodName     : buildReqBodyV2
    * @description:   : Build HTTP request body with Request parameters; Version 2 of Request version, uses KofaxRequestRiskV2.cls
    * @author         : John Hogan

    * @param          : contentVersionId (String): ContentVersion Id to the documents being submitted
    * @param          : documentType (String): Type of document being submitted (e.g. 'Bank Statement')
    * @param          : entityId (String): Id of the record to which the ContentVersion is associated; Kofax API will update this record
    * @param          : processId (String): Id of the process to run in Kofax

    * @return         : void
    */
    public static void buildReqBodyV2(String contentVersionId, String documentType, String entityId, String processId) {
        
        ContentVersion contentVersion = KofaxKTAScore_Utilities.getContentVersionData(contentVersionId);
        Blob versiondataBase64 = contentVersion.VersionData;

        String mimeType = KofaxKTAScore_Utilities.getMimeTypeFromExtension(contentVersion.FileExtension);
        // Set Session Id
        KofaxRequestRiskV2 reqBody = new KofaxRequestRiskV2();
        reqBody.sessionId = KofaxKTAScore_Constants.KOFAX_SESSION_ID;
        // Add Process Identity
        reqBody.ProcessIdentity = new KofaxRequestRiskV2.ProcessIdentity();
        reqBody.processIdentity.Id = processId;
        // Add RuntimeDocument
        reqBody.JobWithDocsInitialization = new KofaxRequestRiskV2.JobWithDocsInitialization();
        KofaxRequestRiskV2.RuntimeDocumentCollection runtimeDocumentVar = new KofaxRequestRiskV2.RuntimeDocumentCollection();
        runtimeDocumentVar.Base64Data = versiondataBase64;
        runtimeDocumentVar.MimeType = mimeType;
        runtimeDocumentVar.ReturnAllFields = true;
        runtimeDocumentVar.ReturnFullTextOcr= false;
        
        reqBody.JobWithDocsInitialization.RuntimeDocumentCollection = new List<KofaxRequestRiskV2.RuntimeDocumentCollection>{ runtimeDocumentVar };
        // Add Input Variables
        KofaxRequestRiskV2.InputVariables contentVersionVar = new KofaxRequestRiskV2.InputVariables();
        contentVersionVar.Id = 'ContentVersion';
        contentVersionVar.Value = contentVersionId;
        KofaxRequestRiskV2.InputVariables documentTypeVar = new KofaxRequestRiskV2.InputVariables();
        documentTypeVar.Id = 'DocumentType';
        documentTypeVar.Value = documentType;
        KofaxRequestRiskV2.InputVariables entityIdVar = new KofaxRequestRiskV2.InputVariables();
        entityIdVar.Id = 'EntityId';
        entityIdVar.Value = entityId;
        reqBody.JobWithDocsInitialization.InputVariables = new List<KofaxRequestRiskV2.InputVariables>{ contentVersionVar, documentTypeVar, entityIdVar };

        jsonRequestBody = JSON.serialize(reqBody);

    }

    /**
    * @methodName    : processKofaxResponseRisk
    * @description:   : Parse HTTP calllout response and create KTA Job
    * @author         : John Hogan

    * @param          : resBody (String): Kofax HTTP callout response body; KofaxResponseRisk
    
    * @return         : String: Display formatted list of Save Errors
    */
    public static KofaxResponseRisk processKofaxResponseRisk(String resBody) {
        
        List<KofaxKTAScore_Utilities.SaveResultWrapper> results = new List<KofaxKTAScore_Utilities.SaveResultWrapper>();
        
        kofaxResRisk = KofaxResponseRisk.parse(resBody);
        kofaxResRiskResultId = kofaxResRisk.d.Id;
        kofaxResRiskResult = kofaxResRisk.d.Result;
        kofaxResRiskResultMessage = kofaxResRisk.d.ResultMessage;
        kofaxResRiskResultJSON = kofaxResRisk.d.ResultJSON;

        // Create KTA Job record
        results.add(KofaxKTAScore_Utilities.processSaveResults(addKtaJobRisk(), 'KTA Job'));

        String jobSummaryResults = createJobSummary(results);

        return kofaxResRisk;
    }
    /**
    * @methodName     : createJobSummary
    * @description:   : Extract any errors that may have occured during insertion
    * @author         : John Hogan

    * @param          : results (List<KofaxKTAScore_Utilities.SaveResultWrapper>): Save Results to parse

    * @return         : String: Display formatted list of Save Errors
     */
    public static String createJobSummary(List<KofaxKTAScore_Utilities.SaveResultWrapper> results) {
        
        Boolean success = true;
        String summary = 'Kofax Job Summary: ';

        for (KofaxKTAScore_Utilities.SaveResultWrapper result : results) {
            if (!result.success) {
                success = false;
                summary += result.errorMessage;
            }
        }

        if (success) {
            summary += 'Job completed with no errors!';
        }

        return summary;
    }
    /**
    * @Method Name    : addKtaJobRisk
    * @description:   : Add KTA Job record based on Kofax Response
    * @author         : John Hogan

    * @param          : results (List<KofaxKTAScore_Utilities.SaveResultWrapper>): Save Results to parse

    * @return         : Database.SaveResult: Result from inserting the new record
    */
    public static Database.SaveResult addKtaJobRisk() {
        String requestVersion = KofaxKTAScore_Constants.KOFAX_RISK_REQUEST_VERSION;

        KTA_Job__c jobToInsert = new KTA_Job__c(
            Response_Json__c = kofaxResRisk.d.ResultJSON,
            Kofax_Id__c = kofaxResRisk.d.Id,
            Type__c	= 'Risk Score',
            Returned_Variables__c = 'Task Id: ' + rqEntityId  + '\n'  + kofaxResRisk.d.Result + '\n' + kofaxResRisk.d.ResultMessage + '\n' + 'Request Version: ' + requestVersion
        );
        
        return Database.insert(jobToInsert, false);
    }
}