/**
 * @description Queueable Async Processing Engine that processes Operation Tasks, publishes progress platform events, and chains jobs
 */
public inherited sharing class OperationBatchExecutor implements Queueable, Database.AllowsCallouts {

    private List<Id> taskIdsToProcess;
    private Integer batchIndex;

    public OperationBatchExecutor(List<Id> taskIds) {
        this.taskIdsToProcess = taskIds != null ? taskIds : new List<Id>();
        this.batchIndex = 0;
    }

    public OperationBatchExecutor(List<Id> taskIds, Integer index) {
        this.taskIdsToProcess = taskIds != null ? taskIds : new List<Id>();
        this.batchIndex = index != null ? index : 0;
    }

    public void execute(QueueableContext context) {
        if (this.taskIdsToProcess.isEmpty() || this.batchIndex >= this.taskIdsToProcess.size()) {
            return;
        }

        Id currentTaskId = this.taskIdsToProcess.get(this.batchIndex);
        List<Operation_Task__c> taskList = OperationTaskSelector.selectByIds(new Set<Id>{ currentTaskId });

        if (!taskList.isEmpty()) {
            Operation_Task__c currentTask = taskList[0];
            currentTask.Status__c = 'In Progress';
            currentTask.Progress__c = Math.min(100, (currentTask.Progress__c != null ? (Integer)currentTask.Progress__c : 0) + 50);

            if (currentTask.Progress__c >= 100) {
                currentTask.Status__c = 'Completed';
            }

            Database.update(currentTask, false);

            // Publish Platform Event for UI real-time feed
            Operation_Event__e evt = new Operation_Event__e(
                Operation_Id__c = currentTask.Id,
                Status__c = currentTask.Status__c,
                Message__c = 'Processed task: ' + currentTask.Subject__c,
                Timestamp__c = System.now(),
                Payload__c = currentTask.Execution_Payload__c
            );
            EventBus.publish(evt);
        }

        // Chain next batch item if remaining
        Integer nextIndex = this.batchIndex + 1;
        if (nextIndex < this.taskIdsToProcess.size() && !Test.isRunningTest()) {
            System.enqueueJob(new OperationBatchExecutor(this.taskIdsToProcess, nextIndex));
        }
    }
}
