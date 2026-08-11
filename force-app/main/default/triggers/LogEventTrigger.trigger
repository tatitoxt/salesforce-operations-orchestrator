/**
 * @description Trigger on Log_Event__e Platform Event to insert Application_Log__c records
 */
trigger LogEventTrigger on Log_Event__e (after insert) {
    List<Application_Log__c> logsToInsert = new List<Application_Log__c>();
    for (Log_Event__e evt : Trigger.new) {
        logsToInsert.add(new Application_Log__c(
            Source_Class__c = evt.Source__c,
            Log_Level__c = evt.Level__c,
            Message__c = evt.Message__c,
            Stack_Trace__c = evt.StackTrace__c
        ));
    }
    if (!logsToInsert.isEmpty()) {
        Database.insert(logsToInsert, false);
    }
}
