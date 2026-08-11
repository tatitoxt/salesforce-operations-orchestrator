@IsTest
private class Test_OperationTaskDomain {

    @IsTest
    static void testDomainDefaultsAndValidations() {
        Operation_Task__c critTask = new Operation_Task__c(
            Subject__c = 'Critical Test',
            Priority__c = 'Critical',
            Status__c = 'Pending'
        );
        insert critTask;

        Operation_Task__c fetched = [SELECT Target_Date__c, Progress__c FROM Operation_Task__c WHERE Id = :critTask.Id];
        System.assertNotEquals(null, fetched.Target_Date__c, 'Default target date should be assigned for Critical priority');

        critTask.Progress__c = 150;
        update critTask;

        fetched = [SELECT Progress__c, Status__c FROM Operation_Task__c WHERE Id = :critTask.Id];
        System.assertEquals(100, fetched.Progress__c, 'Progress should be capped at 100');
        System.assertEquals('Completed', fetched.Status__c, 'Status should auto-update to Completed when progress reaches 100');

        // Test TriggerHandler bypass
        TriggerHandler.bypass('OperationTaskDomain');
        System.assertEquals(true, TriggerHandler.isBypassed('OperationTaskDomain'), 'Handler should be bypassed');
        TriggerHandler.clearAllBypasses();
        System.assertEquals(false, TriggerHandler.isBypassed('OperationTaskDomain'), 'Bypasses should be cleared');
    }
}
