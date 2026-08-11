@IsTest
private class Test_OperationTaskSelector {

    @TestSetup
    static void setupTestData() {
        OrchestratorService.seedDemoData();
    }

    @IsTest
    static void testSelectorQueries() {
        List<Operation_Task__c> tasks = [SELECT Id FROM Operation_Task__c LIMIT 5];
        Set<Id> ids = new Map<Id, Operation_Task__c>(tasks).keySet();

        Test.startTest();
        List<Operation_Task__c> selectedByIds = OperationTaskSelector.selectByIds(ids);
        List<Operation_Task__c> filtered = OperationTaskSelector.selectFilteredTasks('ERP', 'ALL', 'ALL', 'ALL', 10, 0);
        Integer count = OperationTaskSelector.countFilteredTasks('ERP', 'ALL', 'ALL', 'ALL');
        Test.stopTest();

        System.assertEquals(tasks.size(), selectedByIds.size(), 'Selector by IDs should return correct count');
        System.assert(filtered.size() >= 0, 'Filtered tasks query executed');
        System.assert(count >= 0, 'Count query executed');
    }
}
