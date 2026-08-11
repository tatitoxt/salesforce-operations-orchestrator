/**
 * @description Single-line Apex Trigger delegating to OperationTaskDomain framework
 */
trigger OperationTaskTrigger on Operation_Task__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new OperationTaskDomain().run();
}
