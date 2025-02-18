/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 01-16-2025
 * @last modified by  : Unni
**/
@IsTest
private class TACreateJobRequestInvocableTest {
    
    @TestSetup
    static void setup() {
        // Create test data needed for the tests
        // Example: Insert required records
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;
      
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

        // Create an instance of the RequestWrapper and set its fields
        TACreateJobRequestInvocable.RequestWrapper requestWrapper = new TACreateJobRequestInvocable.RequestWrapper();
        requestWrapper.processName = 'Test Process';
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
        List<TACreateJobRequestInvocable.RequestWrapper> requests = new List<TACreateJobRequestInvocable.RequestWrapper>{requestWrapper};

        List<TAResponseWrapper> responses =  TACreateJobRequestInvocable.processRequests(requests);
        Test.stopTest();
        System.debug(responses);
        KTA_Job__c job = [SELECT Id, Name,Request_Input_Variables__c, Request_Type__c FROM KTA_Job__c WHERE Request_Type__c = 'Outbound' LIMIT 1];
        System.assertNotEquals(null, job, 'Job should have been created');
        System.assert(job.Request_Input_Variables__c.contains('Input1'));
        System.assertEquals('D6D41193CA1D11EFA852B85C5C297990', responses[0].jobID, 'Job ID should not be null');
    }
}