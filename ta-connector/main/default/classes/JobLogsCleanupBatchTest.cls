/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 01-18-2025
 * @last modified by  : Unni
**/
@isTest
public class JobLogsCleanupBatchTest {

    // Create test data using @testSetup
    @testSetup
    static void setupTestData() {
            // Create an org-level instance of the custom setting
            TotalAgility_System_Configurations__c orgLevelSetting = 
            new TotalAgility_System_Configurations__c(
                // Set field values
                Log_Cleanup_Cutoff_Days__c = -1,
                Log_Job_inbound_and_outbound_Requests__c = true,
                Session_ID__c = 'TestSession12345',
                Total_Agility_End_point_URL__c = 'https://example.com/endpoint'
            );
             // Insert the custom setting
    insert orgLevelSetting;

        List<KTA_Job__c> jobs = new List<KTA_Job__c>();

        for (Integer i = 0; i < 10; i++) {
            KTA_Job__c job = new KTA_Job__c();
            job.Process_Name__c = 'Process_' + i;
            job.Request_Type__c = 'Outbound';
            job.TA_Response_Status__c = 'Completed';
            job.TotalAgility_Job_Id__c = 'Job_' + i;
            jobs.add(job);
        }

        insert jobs;
    }

    // Test the execution of the batch class
    @isTest
    static void testBatchExecution() {
        // Query the test data
        List<KTA_Job__c> initialJobs = [SELECT Id FROM KTA_Job__c];
        System.assertEquals(10, initialJobs.size(), 'Initial test data should have 10 records.');
        // Execute the batch class
        Test.startTest();
        JobLogsCleanupBatch batchInstance = new JobLogsCleanupBatch();
        Database.executeBatch(batchInstance);
        
        Test.stopTest();

        // Verify the results (example: checking if jobs are deleted or updated based on logic in the batch)
        List<KTA_Job__c> remainingJobs = [SELECT Id FROM KTA_Job__c];
        System.assertEquals(0, remainingJobs.size(), 'All jobs should be removed as per the batch logic.');
    }

    @isTest
    static void testScheduledBatchExecution() {
        // Query the test data
        List<KTA_Job__c> initialJobs = [SELECT Id FROM KTA_Job__c];
        System.assertEquals(10, initialJobs.size(), 'Initial test data should have 10 records.');
        // Schedule the batch class
        String cronExpression = '0 0 1 * * ?'; // Run at 1 AM
        
        // Execute the batch class
        Test.startTest();
        String jobId = System.schedule('Test Scheduled Cleanup', cronExpression, new JobLogsCleanupBatch());        
        Test.stopTest();

        System.assert(!String.isBlank(jobId));
    }
}
