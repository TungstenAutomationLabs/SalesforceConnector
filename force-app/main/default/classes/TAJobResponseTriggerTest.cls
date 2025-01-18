/**
 * @description       :
 * @author            : Unni
 * @group             :
 * @last modified on  : 01-18-2025
 * @last modified by  : Unni
 **/
@IsTest
private class TAJobResponseTriggerTest {
    
    @testSetup
    static void setup() {
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
    }
    
    @IsTest
    static void testJobresponseApexExecution() {
        List<Total_Agility_Process_Configurations__mdt> processConfigurations = (List<Total_Agility_Process_Configurations__mdt>)Json.deserialize('[{"tungstenconnect__Callback_Execution_Method__c":"Apex","tungstenconnect__Callback_Logi_Apex_or_Flow_name__c":"TAJobResponseTriggerTest.TACallbackProcessorTest","tungstenconnect__Flow_Variable_mapping__c":"","tungstenconnect__Total_Agility_Process_Name__c":"accountCreationProcess"}]', List<Total_Agility_Process_Configurations__mdt>.class);
        Test.startTest();
        String responseMessage = '{"Name": "Acme Corporation", "Phone": "123-456-7890", "Industry": "Technology"}';
        TAJobResponseHelper.processConfigurations = processConfigurations;

        tungstenconnect__JobResponse__e jobEvent = new tungstenconnect__JobResponse__e(
            tungstenconnect__Process_Name__c = 'accountCreationProcess',
            tungstenconnect__Response_Message__c = responseMessage,
            tungstenconnect__Response_Timestamp__c = DateTime.now()
        );

        // Publish the platform event
        Database.SaveResult publishResult = EventBus.publish(jobEvent);

        // Assert that the platform event was published successfully
        System.assert(publishResult.isSuccess(), 'Platform event was not published successfully');

        // Deliver the event to trigger subscribers
        Test.getEventBus().deliver();

        Test.stopTest();

        Account account = [SELECT Id, Name, Phone, Industry FROM Account LIMIT 1];
        System.Assert.areEqual('Acme Corporation', account.Name, 'Account not created');
        
    }
    
    public Class TACallbackProcessorTest implements TACallbackProcessor {
        public void execute(String message) {
            System.debug('message received: ' + message);
            // Implement the logic for the execute method
            Account account = (Account)Json.deserialize(message, Account.class);
            insert account;
        }
        
    }

    @IsTest
    static void testJobresponseFlowExecution() {
        List<Total_Agility_Process_Configurations__mdt> processConfigurations = (List<Total_Agility_Process_Configurations__mdt>)Json.deserialize('[{"tungstenconnect__Callback_Execution_Method__c":"Flow","tungstenconnect__Callback_Logi_Apex_or_Flow_name__c":"testFlow","tungstenconnect__Flow_Variable_mapping__c":"{\\\"Name\\\":\\\"Name\\\",\\\"Phone\\\":\\\"Phone\\\"}","tungstenconnect__Total_Agility_Process_Name__c":"accountCreationProcess"}]', List<Total_Agility_Process_Configurations__mdt>.class);
        Test.startTest();
        String responseMessage = '{"Name": "Acme Corporation", "Phone": "123-456-7890", "Industry": "Technology"}';
        TAJobResponseHelper.processConfigurations = processConfigurations;

        tungstenconnect__JobResponse__e jobEvent = new tungstenconnect__JobResponse__e(
            tungstenconnect__Process_Name__c = 'accountCreationProcess',
            tungstenconnect__Response_Message__c = responseMessage,
            tungstenconnect__Response_Timestamp__c = DateTime.now()
        );

        // Publish the platform event
        Database.SaveResult publishResult = EventBus.publish(jobEvent);

        // Assert that the platform event was published successfully
        System.assert(publishResult.isSuccess(), 'Platform event was not published successfully');

        // Deliver the event to trigger subscribers
        Test.getEventBus().deliver();

        Test.stopTest();
        KTA_Job__c job = [SELECT Id, Name, Inbound_Request_JSON__c, Inbound_Request_Flow_Inputs__c, Process_Name__c FROM KTA_Job__c LIMIT 1];
        System.Assert.areEqual('accountCreationProcess', job.Process_Name__c, 'Process name not matching');
        Map<String, Object> flowInputs = (Map<String, Object>)Json.deserializeUntyped(job.Inbound_Request_Flow_Inputs__c);
        System.Assert.areEqual('Acme Corporation', flowInputs.get('Name'), 'Name not matching');
        System.Assert.areEqual('123-456-7890', flowInputs.get('Phone'), 'Phone not matching');
        
    }

    @IsTest
    static void testFlowUtilityComplexFlowMapping() {
        List<Total_Agility_Process_Configurations__mdt> processConfigurations = (List<Total_Agility_Process_Configurations__mdt>)Json.deserialize('[{\"tungstenconnect__Callback_Execution_Method__c\":\"Flow\",\"tungstenconnect__Callback_Logi_Apex_or_Flow_name__c\":\"testFlow\",\"tungstenconnect__Flow_Variable_mapping__c\":\"{\\\"EmployeeAccount\\\":{\\\"Path\\\":\\\"EmployeeAccount\\\",\\\"SObject\\\":\\\"Account\\\",\\\"isCollection\\\":false,\\\"FieldsMapping\\\":{\\\"Name\\\":\\\"Name\\\",\\\"Phone\\\":\\\"Phone\\\"}}}\",\"tungstenconnect__Total_Agility_Process_Name__c\":\"accountCreationProcess\"}]', List<Total_Agility_Process_Configurations__mdt>.class);
        Test.startTest();
        String responseMessage = '{"EmployeeAccount":{"Name": "Acme Corporation", "Phone": "123-456-7890", "Industry": "Technology"}}';
        TAJobResponseHelper.processConfigurations = processConfigurations;

        tungstenconnect__JobResponse__e jobEvent = new tungstenconnect__JobResponse__e(
            tungstenconnect__Process_Name__c = 'accountCreationProcess',
            tungstenconnect__Response_Message__c = responseMessage,
            tungstenconnect__Response_Timestamp__c = DateTime.now()
        );

        // Publish the platform event
        Database.SaveResult publishResult = EventBus.publish(jobEvent);

        // Assert that the platform event was published successfully
        System.assert(publishResult.isSuccess(), 'Platform event was not published successfully');

        // Deliver the event to trigger subscribers
        Test.getEventBus().deliver();

        Test.stopTest();
        KTA_Job__c job = [SELECT Id, Name, Inbound_Request_JSON__c, Inbound_Request_Flow_Inputs__c, Process_Name__c FROM KTA_Job__c LIMIT 1];
        System.Assert.areEqual('accountCreationProcess', job.Process_Name__c, 'Process name not matching');
        Map<String, Object> flowInputs = (Map<String, Object>)Json.deserializeUntyped(job.Inbound_Request_Flow_Inputs__c);
        Map<String, Object> employeeAccountMap = (Map<String, Object>)flowInputs.get('EmployeeAccount');
        String employeeAccountJson = JSON.serialize(employeeAccountMap);
        Account acc = (Account)JSON.deserialize(employeeAccountJson, Account.class);
        System.Assert.areEqual('Acme Corporation', acc.Name, 'Name not matching');
        System.Assert.areEqual('123-456-7890', acc.Phone, 'Phone not matching');
        
    }

    @IsTest
    static void testFlowUtilityComplexFlowMappingCollection() {
        List<Total_Agility_Process_Configurations__mdt> processConfigurations = (List<Total_Agility_Process_Configurations__mdt>)Json.deserialize('[{\"tungstenconnect__Callback_Execution_Method__c\":\"Flow\",\"tungstenconnect__Callback_Logi_Apex_or_Flow_name__c\":\"testFlow\",\"tungstenconnect__Flow_Variable_mapping__c\":\"{\\\"EmployeeAccounts\\\":{\\\"Path\\\":\\\"EmployeeAccounts\\\",\\\"SObject\\\":\\\"Account\\\",\\\"isCollection\\\":true,\\\"FieldsMapping\\\":{\\\"Name\\\":\\\"Name\\\",\\\"Phone\\\":\\\"Phone\\\"}}}\",\"tungstenconnect__Total_Agility_Process_Name__c\":\"accountCreationProcess\"}]', List<Total_Agility_Process_Configurations__mdt>.class);
        Test.startTest();
        String responseMessage = '{"EmployeeAccounts":[{"Name": "Acme Corporation", "Phone": "123-456-7890", "Industry": "Technology"},{"Name": "Beta Corporation", "Phone": "778-456-4567", "Industry": "Technology"}]}';
        TAJobResponseHelper.processConfigurations = processConfigurations;

        tungstenconnect__JobResponse__e jobEvent = new tungstenconnect__JobResponse__e(
            tungstenconnect__Process_Name__c = 'accountCreationProcess',
            tungstenconnect__Response_Message__c = responseMessage,
            tungstenconnect__Response_Timestamp__c = DateTime.now()
        );

        // Publish the platform event
        Database.SaveResult publishResult = EventBus.publish(jobEvent);

        // Assert that the platform event was published successfully
        System.assert(publishResult.isSuccess(), 'Platform event was not published successfully');

        // Deliver the event to trigger subscribers
        Test.getEventBus().deliver();

        Test.stopTest();
        KTA_Job__c job = [SELECT Id, Name, Inbound_Request_JSON__c, Inbound_Request_Flow_Inputs__c, Process_Name__c FROM KTA_Job__c LIMIT 1];
        System.Assert.areEqual('accountCreationProcess', job.Process_Name__c, 'Process name not matching');
        Map<String, Object> flowInputs = (Map<String, Object>)Json.deserializeUntyped(job.Inbound_Request_Flow_Inputs__c);
        List<Object> employeeAccountList = (List<Object>)flowInputs.get('EmployeeAccounts');
        System.Assert.areEqual(2, employeeAccountList.size(), 'Accounts not matching');
    }
}