@IsTest
private class Test_OperationBatchExecutor {

    @IsTest
    static void testQueueableExecution() {
        Operation_Task__c task = new Operation_Task__c(
            Subject__c = 'Async Queueable Test',
            Status__c = 'Pending',
            Progress__c = 0
        );
        insert task;

        Test.startTest();
        System.enqueueJob(new OperationBatchExecutor(new List<Id>{ task.Id }));
        Test.stopTest();

        Operation_Task__c updated = [SELECT Status__c, Progress__c FROM Operation_Task__c WHERE Id = :task.Id];
        System.assertEquals('In Progress', updated.Status__c, 'Task should be moved to In Progress');
        System.assertEquals(50, updated.Progress__c, 'Progress should increase by 50');
    }
}
