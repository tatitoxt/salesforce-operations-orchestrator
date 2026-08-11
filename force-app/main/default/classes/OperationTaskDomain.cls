/**
 * @description Domain layer for Operation_Task__c handling business rules, status validations, and default calculations
 */
public inherited sharing class OperationTaskDomain extends TriggerHandler {

    private List<Operation_Task__c> newTaskList;
    private Map<Id, Operation_Task__c> oldTaskMap;

    public OperationTaskDomain() {
        this.newTaskList = (List<Operation_Task__c>) Trigger.new;
        this.oldTaskMap = (Map<Id, Operation_Task__c>) Trigger.oldMap;
    }

    protected override void beforeInsert() {
        applyDefaultTargetDates(this.newTaskList);
        validateProgressAndStatus(this.newTaskList, null);
    }

    protected override void beforeUpdate() {
        validateProgressAndStatus(this.newTaskList, this.oldTaskMap);
        applyStatusStateRules(this.newTaskList, this.oldTaskMap);
    }

    private static void applyDefaultTargetDates(List<Operation_Task__c> tasks) {
        for (Operation_Task__c task : tasks) {
            if (task.Target_Date__c == null) {
                if (task.Priority__c == 'Critical') {
                    task.Target_Date__c = System.now().addDays(1);
                } else if (task.Priority__c == 'High') {
                    task.Target_Date__c = System.now().addDays(3);
                } else {
                    task.Target_Date__c = System.now().addDays(7);
                }
            }
        }
    }

    private static void validateProgressAndStatus(List<Operation_Task__c> tasks, Map<Id, Operation_Task__c> oldMap) {
        for (Operation_Task__c task : tasks) {
            if (task.Progress__c != null) {
                if (task.Progress__c < 0) {
                    task.Progress__c = 0;
                } else if (task.Progress__c > 100) {
                    task.Progress__c = 100;
                }
            }
            if (task.Progress__c == 100 && task.Status__c != 'Completed') {
                task.Status__c = 'Completed';
            }
        }
    }

    private static void applyStatusStateRules(List<Operation_Task__c> tasks, Map<Id, Operation_Task__c> oldMap) {
        for (Operation_Task__c task : tasks) {
            Operation_Task__c oldTask = oldMap.get(task.Id);
            if (oldTask != null && oldTask.Status__c == 'Completed' && task.Status__c == 'Pending' && task.Progress__c == 100) {
                task.Progress__c = 0;
            }
        }
    }
}
