/**
 * @description Schedulable Apex class executing automated operations health checks and retry triggers
 */
public inherited sharing class OperationMonitorScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        // Query pending critical tasks for automated queueable dispatch
        List<Operation_Task__c> pendingCritical = [
            SELECT Id, Status__c, Retry_Count__c
            FROM Operation_Task__c
            WHERE Priority__c = 'Critical' AND Status__c = 'Pending'
            WITH USER_MODE
            LIMIT 50
        ];

        if (!pendingCritical.isEmpty()) {
            List<Id> taskIds = new List<Id>();
            for (Operation_Task__c task : pendingCritical) {
                task.Retry_Count__c = (task.Retry_Count__c != null ? task.Retry_Count__c : 0) + 1;
                taskIds.add(task.Id);
            }
            Database.update(pendingCritical, false, AccessLevel.USER_MODE);
            System.enqueueJob(new OperationBatchExecutor(taskIds));
        }

        // Execute cleanup batch for expired logs
        Database.executeBatch(new OperationCleanupBatch(), 200);
    }
}
