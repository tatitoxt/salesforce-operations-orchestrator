@IsTest
private class Test_OperationCleanupBatch {

    @IsTest
    static void testBatchAndScheduler() {
        Application_Log__c log = new Application_Log__c(
            Source_Class__c = 'TestClass',
            Log_Level__c = 'INFO',
            Message__c = 'Test log entry'
        );
        insert log;

        Operation_Task__c critTask = new Operation_Task__c(
            Subject__c = 'Critical Scheduled Task',
            Priority__c = 'Critical',
            Status__c = 'Pending'
        );
        insert critTask;

        Test.startTest();
        OperationMonitorScheduler scheduler = new OperationMonitorScheduler();
        scheduler.execute(null);
        Test.stopTest();

        Operation_Task__c updated = [SELECT Retry_Count__c FROM Operation_Task__c WHERE Id = :critTask.Id];
        System.assertEquals(1, updated.Retry_Count__c, 'Retry count should increment on critical pending tasks');
    }
}
