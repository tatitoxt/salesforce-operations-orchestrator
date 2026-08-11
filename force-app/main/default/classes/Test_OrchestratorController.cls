@IsTest
private class Test_OrchestratorController {

    @IsTest
    static void testControllerEndpoints() {
        Test.startTest();
        Integer seedCount = OrchestratorController.seedSampleData();
        System.assertEquals(20, seedCount, 'Should seed 20 demo records');

        OrchestratorService.TaskQueryResult result = OrchestratorController.getOrchestrationTasks('', 'ALL', 'ALL', 'ALL', 10, 1);
        System.assertNotEquals(null, result, 'Task query result returned');
        System.assert(result.tasks.size() > 0, 'Tasks list should contain seeded items');

        OrchestratorService.AnalyticsSummary summary = OrchestratorController.getAnalyticsSummary();
        System.assertNotEquals(null, summary, 'Analytics summary returned');

        List<Id> taskIds = new List<Id>{ result.tasks[0].Id };
        OrchestratorController.reassignTaskPriorities(taskIds, 'Critical');
        String jobId = OrchestratorController.executeBatchOperations(taskIds);
        System.assertNotEquals(null, jobId, 'Job ID returned from queueable batch execution');

        OrchestratorController.clearAllTasks();
        Test.stopTest();

        Integer remaining = [SELECT COUNT() FROM Operation_Task__c];
        System.assertEquals(0, remaining, 'Tasks cleared successfully');
    }
}
