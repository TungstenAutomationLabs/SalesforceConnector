/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 11-21-2024
 * @last modified by  : Unni
**/
trigger TAJobResponseTrigger on JobResponse__e (after insert) {
    // Collect all process names from the events
    Set<String> processNames = new Set<String>();
    for (JobResponse__e event : Trigger.new) {
        processNames.add(event.Process_Name__c);
    }

    // Validate CRUD permissions
    if (!Schema.sObjectType.Total_Agility_Process_Configurations__mdt.isAccessible()) {
        System.debug('No access to Total_Agility_Process_Configurations__mdt');
        return;
    }

    // Query the custom metadata records based on Process Names
    Map<String, Total_Agility_Process_Configurations__mdt> configMap = new Map<String, Total_Agility_Process_Configurations__mdt>();
    for (Total_Agility_Process_Configurations__mdt config : [
        SELECT Callback_Execution_Method__c,
               Callback_Logi_Apex_or_Flow_name__c,
               Total_Agility_Process_Name__c,
               Flow_Variable_mapping__c
        FROM Total_Agility_Process_Configurations__mdt
        WHERE Total_Agility_Process_Name__c IN :processNames
    ]) {
        configMap.put(config.Total_Agility_Process_Name__c, config);
    }

    // Iterate over all platform events
    for (JobResponse__e event : Trigger.new) {
        try {
            // Get the configuration for the current event
            Total_Agility_Process_Configurations__mdt config = configMap.get(event.Process_Name__c);
            if (config == null) {
                System.debug('No configuration found for process name: ' + event.Process_Name__c);
                continue;
            }

            // Check the Callback Execution Method
            String executionMethod = config.Callback_Execution_Method__c;
            String logicName = config.Callback_Logi_Apex_or_Flow_name__c;

            if (executionMethod == 'Apex') {
                // Dynamically invoke the Apex class
                Type callbackClassType = Type.forName(logicName);
                if (callbackClassType != null) {
                    Object callbackInstance = callbackClassType.newInstance();
                    if (callbackInstance instanceof TACallbackProcessor) {
                        ((TACallbackProcessor) callbackInstance).execute(event.Response_Message__c);
                    } else {
                        System.debug('Class does not implement TACallbackProcessor interface: ' + logicName);
                    }
                } else {
                    System.debug('Class not found: ' + logicName);
                }
            } else if (executionMethod == 'Flow') {
                // Call the Flow using Flow.Interview
                Map<String, Object> flowInputs = new Map<String, Object>();
                if(String.isNotBlank(config.Flow_Variable_mapping__c)){
                    flowInputs = FlowUtility.populateFlowVariables(config.Flow_Variable_mapping__c,event.Response_Message__c);
                } else {
                flowInputs.put('ResponseMessage', event.Response_Message__c);
                }
                Flow.Interview flow = Flow.Interview.createInterview(logicName, flowInputs);
                flow.start();
            } else {
                System.debug('Unknown execution method: ' + executionMethod);
            }
        } catch (Exception ex) {
            System.debug('Error processing JobResponse: ' + ex.getMessage());
        }
    }
}
