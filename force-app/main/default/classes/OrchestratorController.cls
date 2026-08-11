/**
 * @description Aura Controller for LWC UI components exposing wire & imperative endpoints with exception handling and logging
 */
public inherited sharing class OrchestratorController {

    @AuraEnabled(cacheable=true)
    public static OrchestratorService.TaskQueryResult getOrchestrationTasks(String searchTerm, String status, String priority, String category, Integer pageSize, Integer pageNumber) {
        try {
            return OrchestratorService.fetchTasks(searchTerm, status, priority, category, pageSize, pageNumber);
        } catch (Exception ex) {
            Logger.error('OrchestratorController.getOrchestrationTasks', ex.getMessage(), ex);
            throw new AuraHandledException('Failed to retrieve orchestration tasks: ' + ex.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static OrchestratorService.AnalyticsSummary getAnalyticsSummary() {
        try {
            return OrchestratorService.getAnalytics();
        } catch (Exception ex) {
            Logger.error('OrchestratorController.getAnalyticsSummary', ex.getMessage(), ex);
            throw new AuraHandledException('Failed to retrieve analytics summary: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static String executeBatchOperations(List<Id> taskIds) {
        try {
            Id jobId = OrchestratorService.launchBatchExecution(taskIds);
            return String.valueOf(jobId);
        } catch (Exception ex) {
            Logger.error('OrchestratorController.executeBatchOperations', ex.getMessage(), ex);
            throw new AuraHandledException('Batch execution request failed: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static void reassignTaskPriorities(List<Id> taskIds, String newPriority) {
        try {
            OrchestratorService.bulkUpdatePriority(taskIds, newPriority);
        } catch (Exception ex) {
            Logger.error('OrchestratorController.reassignTaskPriorities', ex.getMessage(), ex);
            throw new AuraHandledException('Priority update failed: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static Integer seedSampleData() {
        try {
            return OrchestratorService.seedDemoData();
        } catch (Exception ex) {
            Logger.error('OrchestratorController.seedSampleData', ex.getMessage(), ex);
            throw new AuraHandledException('Sample data generation failed: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static void clearAllTasks() {
        try {
            OrchestratorService.deleteAllTasks();
        } catch (Exception ex) {
            Logger.error('OrchestratorController.clearAllTasks', ex.getMessage(), ex);
            throw new AuraHandledException('Failed to clear tasks: ' + ex.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Operation_Rule__mdt> getOperationRules() {
        try {
            return OperationRulesSelector.getAllRules();
        } catch (Exception ex) {
            Logger.error('OrchestratorController.getOperationRules', ex.getMessage(), ex);
            throw new AuraHandledException('Failed to retrieve operation rules: ' + ex.getMessage());
        }
    }
}
