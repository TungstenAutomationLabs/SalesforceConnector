/**
* @apexClassName      : KofaxKTAScore_Constants
* @date               : August 7, 2023
* @description:       : Class with Constants for the KTA Risk Score application
*                       retrieved from Custom Metadata Type 
* @author             : John Hogan, johnejhogan@gmail.com
 */
public class KofaxKTAScore_Constants {
    public static KTA_Risk_Score_Setting__mdt SETTINGS = [SELECT Id, DeveloperName, KTA_Endpoint__c, KTA_Process_Id__c, KTA_Session_Id__c, KTA_Task_Record_Type__c FROM KTA_Risk_Score_Setting__mdt WHERE Active__c = true LIMIT 1];
    public static String KOFAX_RISK_REQUEST_VERSION = SETTINGS.DeveloperName;
    public static String KOFAX_ENDPOINT = SETTINGS.KTA_Endpoint__c;
    public static String KOFAX_PROCESS_ID = SETTINGS.KTA_Process_Id__c;
    public static String KOFAX_SESSION_ID = SETTINGS.KTA_Session_Id__c;
    public static String KOFAX_RISK_TASK_RECORD_TYPE = SETTINGS.KTA_Task_Record_Type__c;
    // public static String SFDC_ORG_KEY = SETTINGS.SFDC_OrgKey__c;

    // // 2023-11-29: added Lease settings
    // public static KTA_Lease_Setting__mdt SETTINGS_LEASE = [SELECT Id, DeveloperName, KTA_Endpoint__c, KTA_Process_Id__c, KTA_Session_Id__c, SFDC_OrgKey__c FROM KTA_Lease_Setting__mdt WHERE Active__c = true LIMIT 1];
    // public static String KOFAX_RISK_REQUEST_VERSION_LEASE = SETTINGS_LEASE.DeveloperName;
    // public static String KOFAX_ENDPOINT_LEASE = SETTINGS_LEASE.KTA_Endpoint__c;
    // public static String KOFAX_PROCESS_ID_LEASE = SETTINGS_LEASE.KTA_Process_Id__c;
    // public static String KOFAX_SESSION_ID_LEASE = SETTINGS_LEASE.KTA_Session_Id__c;
    // public static String SFDC_ORG_KEY_LEASE = SETTINGS_LEASE.SFDC_OrgKey__c;

    // // 2023-12-07: added Agreement settings
    // public static KTA_Agreement_Setting__mdt SETTINGS_AGREEMENT = [SELECT Id, DeveloperName, KTA_Endpoint__c, KTA_Process_Id__c, KTA_Session_Id__c, SFDC_OrgKey__c FROM KTA_Agreement_Setting__mdt WHERE Active__c = true LIMIT 1];
    // public static String KOFAX_RISK_REQUEST_VERSION_AGREEMENT = SETTINGS_AGREEMENT.DeveloperName;
    // public static String KOFAX_ENDPOINT_AGREEMENT = SETTINGS_AGREEMENT.KTA_Endpoint__c;
    // public static String KOFAX_PROCESS_ID_AGREEMENT = SETTINGS_AGREEMENT.KTA_Process_Id__c;
    // public static String KOFAX_SESSION_ID_AGREEMENT = SETTINGS_AGREEMENT.KTA_Session_Id__c;
    // public static String SFDC_ORG_KEY_AGREEMENT = SETTINGS_AGREEMENT.SFDC_OrgKey__c;
}