/*
 * Test class for TACreateJobWithDocRequestInvocable
 */
@IsTest
private class TACreateJobWithDocRequestInvocableTest {

    @TestSetup
    static void setup() {
        // Create test data needed for the tests
        // Example: Insert required records
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;
        // Create test data for ContentVersion document
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert contentVersion;

            // Create an org-level instance of the custom setting
        TotalAgility_System_Configurations__c orgLevelSetting = 
        new TotalAgility_System_Configurations__c(
            // Set field values
            Log_Cleanup_Cutoff_Days__c = 30,
            Log_Job_inbound_and_outbound_Requests__c = true,
            Session_ID__c = 'TestSession12345',
            Total_Agility_End_point_URL__c = 'https://example.com/endpoint'
        );

    // Insert the custom setting
    insert orgLevelSetting;

        // Add any other records required for the tests
    }

    @IsTest
    static void testSuccessResponse() {
        
        

        // Query for the document ID created in the test setup method
        ContentVersion contentVersion = [SELECT Id, FileExtension, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document' LIMIT 1];
        System.assertEquals('pdf', contentVersion.FileExtension);

        // Create an instance of the RequestWrapper and set its fields
        TACreateJobWithDocRequestInvocable.RequestWrapper requestWrapper = new TACreateJobWithDocRequestInvocable.RequestWrapper();
        requestWrapper.processName = 'Test Process';
        requestWrapper.documentIds = new List<String>{contentVersion.Id};
        requestWrapper.inputs = new List<InputVariables>();
        InputVariables input1 = new InputVariables();
        input1.Id = 'Input1';
        input1.Value = 'Value1';

        InputVariables input2 = new InputVariables();
        input2.Id = 'Input2';
        input2.Value = 'Value2';

        requestWrapper.inputs.add(input1);
        requestWrapper.inputs.add(input2);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TotalAgilityMockCallout());
        List<TACreateJobWithDocRequestInvocable.RequestWrapper> requests = new List<TACreateJobWithDocRequestInvocable.RequestWrapper>{requestWrapper};

        List<TAResponseWrapper> responses =  TACreateJobWithDocRequestInvocable.processRequests(requests);
        Test.stopTest();
        KTA_Job__c job = [SELECT Id,Document_Id__c, Name,Request_Input_Variables__c, Request_Type__c FROM KTA_Job__c WHERE Request_Type__c = 'Outbound' LIMIT 1];
        System.assertNotEquals(null, job, 'Job should have been created');
        System.assert(job.Request_Input_Variables__c.contains('Input1'));
        System.assert(job.Document_Id__c.contains(contentVersion.Id));
        System.assertEquals('D6D41193CA1D11EFA852B85C5C297990', responses[0].jobID, 'Job ID should not be null');

    }
    @IsTest
    static void testFailureResponse() {
        
        

        // Query for the document ID created in the test setup method
        ContentVersion contentVersion = [SELECT Id, FileExtension, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document' LIMIT 1];
        System.assertEquals('pdf', contentVersion.FileExtension);

        // Create an instance of the RequestWrapper and set its fields
        TACreateJobWithDocRequestInvocable.RequestWrapper requestWrapper = new TACreateJobWithDocRequestInvocable.RequestWrapper();
        requestWrapper.processName = 'Test Process';
        requestWrapper.documentIds = new List<String>{contentVersion.Id};
        requestWrapper.inputs = new List<InputVariables>();
        InputVariables input1 = new InputVariables();
        input1.Id = 'Input1';
        input1.Value = 'Value1';

        InputVariables input2 = new InputVariables();
        input2.Id = 'Input2';
        input2.Value = 'Value2';

        requestWrapper.inputs.add(input1);
        requestWrapper.inputs.add(input2);
        Test.startTest();
        TotalAgilityMockCallout mockObj = new TotalAgilityMockCallout();
        mockObj.responseBody = '{"error":"Invalid request"}';
        mockObj.responseStatus = 'Bad Request';
        mockObj.responseStatusCode = 400;

        Test.setMock(HttpCalloutMock.class, mockObj);
        List<TACreateJobWithDocRequestInvocable.RequestWrapper> requests = new List<TACreateJobWithDocRequestInvocable.RequestWrapper>{requestWrapper};

        List<TAResponseWrapper> responses =  TACreateJobWithDocRequestInvocable.processRequests(requests);
        Test.stopTest();
        KTA_Job__c job = [SELECT Id,Document_Id__c, Name,Request_Input_Variables__c, Request_Type__c, TA_Response_Status__c FROM KTA_Job__c WHERE Request_Type__c = 'Outbound' LIMIT 1];
        System.debug(job.TA_Response_Status__c);
        System.Assert(job.TA_Response_Status__c.contains('Bad Request'));        
        System.Assert(responses[0].resultMessage.contains('Failure response from TotalAgility'), 'Expecting Failure response');

    }
    @IsTest
    static void testUnexpectedResponse() {
        
        

        // Query for the document ID created in the test setup method
        ContentVersion contentVersion = [SELECT Id, FileExtension, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document' LIMIT 1];
        System.assertEquals('pdf', contentVersion.FileExtension);

        // Create an instance of the RequestWrapper and set its fields
        TACreateJobWithDocRequestInvocable.RequestWrapper requestWrapper = new TACreateJobWithDocRequestInvocable.RequestWrapper();
        requestWrapper.processName = 'Test Process';
        requestWrapper.documentIds = new List<String>{contentVersion.Id};
        requestWrapper.inputs = new List<InputVariables>();
        InputVariables input1 = new InputVariables();
        input1.Id = 'Input1';
        input1.Value = 'Value1';

        InputVariables input2 = new InputVariables();
        input2.Id = 'Input2';
        input2.Value = 'Value2';

        requestWrapper.inputs.add(input1);
        requestWrapper.inputs.add(input2);
        Test.startTest();
        TotalAgilityMockCallout mockObj = new TotalAgilityMockCallout();
        mockObj.responseBody = '{"error":"Invalid request"}';
        mockObj.responseStatus = 'Bad response';
        mockObj.responseStatusCode = 200;

        Test.setMock(HttpCalloutMock.class, mockObj);
        List<TACreateJobWithDocRequestInvocable.RequestWrapper> requests = new List<TACreateJobWithDocRequestInvocable.RequestWrapper>{requestWrapper};

        List<TAResponseWrapper> responses =  TACreateJobWithDocRequestInvocable.processRequests(requests);
        Test.stopTest();
        KTA_Job__c job = [SELECT Id,Document_Id__c, Name,Request_Input_Variables__c, Request_Type__c, TA_Response_Status__c FROM KTA_Job__c WHERE Request_Type__c = 'Outbound' LIMIT 1];
        System.debug(job.TA_Response_Status__c);
        System.Assert(job.TA_Response_Status__c.contains('Bad response'));        
        System.Assert(responses[0].resultMessage.contains('Unexpected response from TotalAgility'), 'Expecting Unexpected response');

    }
}
