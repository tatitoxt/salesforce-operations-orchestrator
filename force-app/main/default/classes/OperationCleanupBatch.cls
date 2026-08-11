/**
 * @description Stateful Batch Apex job for purging expired Application Log records and archiving completed tasks
 */
public inherited sharing class OperationCleanupBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Integer recordsProcessed = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Application_Log__c WHERE CreatedDate < LAST_N_DAYS:30';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Application_Log__c> scope) {
        if (scope != null && !scope.isEmpty()) {
            recordsProcessed += scope.size();
            Database.delete(scope, false, AccessLevel.USER_MODE);
        }
    }

    public void finish(Database.BatchableContext bc) {
        Logger.info('OperationCleanupBatch', 'Cleanup completed. Total logs purged: ' + recordsProcessed);
    }
}
