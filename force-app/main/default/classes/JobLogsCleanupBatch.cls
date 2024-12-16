/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 12-15-2024
 * @last modified by  : Unni
**/
public class JobLogsCleanupBatch implements Database.Batchable<SObject>, Schedulable {
    private Integer cutoffDays;

    public JobLogsCleanupBatch() {
        // Load the cutoff days from custom settings
        TotalAgility_System_Configurations__c config = TotalAgility_System_Configurations__c.getOrgDefaults();
        this.cutoffDays = (config != null) && (config.Log_Cleanup_Cutoff_Days__c != null)
            ? config.Log_Cleanup_Cutoff_Days__c.intValue()
            : 30; // Default to 30 days if not configured
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        // Calculate the dynamic cutoff date
        Date cutoffDate = Date.today().addDays(-cutoffDays);

        // Query logs older than the cutoff date
        return Database.getQueryLocator([
            SELECT Id 
            FROM KTA_Job__c 
            WHERE CreatedDate < :cutoffDate
        ]);
    }

    public void execute(Database.BatchableContext context, List<KTA_Job__c> logs) {
        // Delete logs in chunks
        try {
            delete logs;
        } catch (DmlException ex) {
            System.debug('Error deleting logs: ' + ex.getMessage());
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Log cleanup for KTA_Job__c completed successfully.');
    }

    public void execute(SchedulableContext context) {
        // Schedule method to trigger batch job
        Database.executeBatch(new JobLogsCleanupBatch(), 200); // Default batch size 200
    }
}
