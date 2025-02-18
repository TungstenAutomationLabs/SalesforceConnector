/**
 * @description       :
 * @author            : Unni
 * @group             :
 * @last modified on  : 02-18-2025
 * @last modified by  : Unni
 **/
public without sharing class TAJobResponseHelper {
    @testVisible static List<Total_Agility_Process_Configurations__mdt> processConfigurations{
        get{
            if(processConfigurations == NULL){
                processConfigurations = [SELECT Callback_Execution_Method__c,
            Callback_Logi_Apex_or_Flow_name__c,
            Callback_Logic_Namespace__c,
            Total_Agility_Process_Name__c,
            Flow_Variable_mapping__c
     FROM Total_Agility_Process_Configurations__mdt 
     WITH SYSTEM_MODE];
            }
            return processConfigurations;
        }
        set;
    }
    
    public static void processJobResponse(List<JobResponse__e> responses){
        // Collect all process names from the events
        Set<String> processNames = new Set<String>();
        for (JobResponse__e event : responses) {
            processNames.add(event.Process_Name__c);
            
        }
        System.debug('processNames'+ processNames );
        // Check if logging is enabled in custom settings
        TotalAgility_System_Configurations__c systemConfig = TotalAgility_System_Configurations__c.getInstance();
        Boolean isLoggingEnabled = (systemConfig != null) && systemConfig.Log_Job_inbound_and_outbound_Requests__c;
        
        // Query the custom metadata records based on Process Names
        Map<String, Total_Agility_Process_Configurations__mdt> configMap = new Map<String, Total_Agility_Process_Configurations__mdt>();
        for (Total_Agility_Process_Configurations__mdt config : TAJobResponseHelper.processConfigurations) {
            if(processNames.contains(config.Total_Agility_Process_Name__c)){
                configMap.put(config.Total_Agility_Process_Name__c, config);
            }
        }
        
        List<KTA_Job__c> ktaJobs = new List<KTA_Job__c>();
        // Iterate over all platform events
        for (JobResponse__e event : responses) {
            KTA_Job__c ktaJob = new KTA_Job__c(
                Inbound_Request_JSON__c = event.Response_Message__c,
            Process_Name__c = event.Process_Name__c,
            Request_Type__c ='Inbound'
                );
            try {
                // Get the configuration for the current event
                Total_Agility_Process_Configurations__mdt config = configMap.get(event.Process_Name__c);
                if (config == null) {
                    ktaJob.Exception__c = 'No configuration found for process name: ' + event.Process_Name__c;
                    continue;
                }
                
                // Check the Callback Execution Method
                String executionMethod = config.Callback_Execution_Method__c;
                String logicName = config.Callback_Logi_Apex_or_Flow_name__c;
                String logicNamespace = config.Callback_Logic_Namespace__c;                
                if (executionMethod == 'Apex') {
                    // Dynamically invoke the Apex class
                    Type callbackClassType = Type.forName(logicName);
                    if (callbackClassType != null) {
                        Object callbackInstance = callbackClassType.newInstance();
                        if (callbackInstance instanceof TACallbackProcessor) {
                            ((TACallbackProcessor) callbackInstance).execute(event.Response_Message__c);
                        } else {
                            ktaJob.Exception__c = 'Class does not implement TACallbackProcessor interface: ' + logicName;
                        }
                    } else {
                        ktaJob.Exception__c = 'Class not found: ' + logicName;
                    }
                } else if (executionMethod == 'Flow') {
                    // Call the Flow using Flow.Interview
                    Map<String, Object> flowInputs = new Map<String, Object>();
                    if(String.isNotBlank(config.Flow_Variable_mapping__c)){
                        flowInputs = FlowUtility.populateFlowVariables(config.Flow_Variable_mapping__c,event.Response_Message__c);
                    } else {
                        flowInputs.put('ResponseMessage', event.Response_Message__c);
                    }
                    if(!flowInputs.isEmpty()){
                        ktajob.Inbound_Request_Flow_Inputs__c = JSON.serialize(flowInputs);
                    }
                    if(!Test.isRunningTest()){
                        if(String.isNotBlank(logicNamespace)){
                            Flow.Interview flow = Flow.Interview.createInterview(logicNamespace, logicName, flowInputs);
                            flow.start();
                        }
                        else {
                            Flow.Interview flow = Flow.Interview.createInterview(logicName, flowInputs);
                            flow.start();
                        }
                        
                    }
                    
                } else {
                    ktaJob.Exception__c = 'Unknown execution method: ' + executionMethod;
                }
            } catch (Exception ex) {
                ktaJob.Exception__c = ex.getMessage();
            }
            ktaJobs.add(ktaJob);
        }
        if (!ktaJobs.isEmpty() && isLoggingEnabled) {
            Database.insert(ktaJobs, true, AccessLevel.SYSTEM_MODE);
        }
        
    }
}