/**
 * @description Selector class for Operation_Task__c providing SOQL encapsulation, dynamic filtering, and Security.stripInaccessible enforcement.
 */
public inherited sharing class OperationTaskSelector {

    public static List<Operation_Task__c> selectByIds(Set<Id> recordIds) {
        if (recordIds == null || recordIds.isEmpty()) {
            return new List<Operation_Task__c>();
        }
        String query = 'SELECT Id, Name, Subject__c, Status__c, Priority__c, Category__c, Progress__c, Target_Date__c, Execution_Payload__c, Retry_Count__c, CreatedDate, LastModifiedDate FROM Operation_Task__c WHERE Id IN :recordIds';
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, Database.query(query));
        return (List<Operation_Task__c>) decision.getRecords();
    }

    public static List<Operation_Task__c> selectFilteredTasks(String searchTerm, String status, String priority, String category, Integer limitSize, Integer offsetSize) {
        String query = 'SELECT Id, Name, Subject__c, Status__c, Priority__c, Category__c, Progress__c, Target_Date__c, Execution_Payload__c, Retry_Count__c, CreatedDate, LastModifiedDate FROM Operation_Task__c WHERE Id != null';
        Map<String, Object> bindParams = new Map<String, Object>();

        if (String.isNotBlank(searchTerm)) {
            query += ' AND (Subject__c LIKE :likeSearch OR Name LIKE :likeSearch)';
            bindParams.put('likeSearch', '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%');
        }

        if (String.isNotBlank(status) && status != 'ALL') {
            query += ' AND Status__c = :status';
            bindParams.put('status', status);
        }

        if (String.isNotBlank(priority) && priority != 'ALL') {
            query += ' AND Priority__c = :priority';
            bindParams.put('priority', priority);
        }

        if (String.isNotBlank(category) && category != 'ALL') {
            query += ' AND Category__c = :category';
            bindParams.put('category', category);
        }

        query += ' ORDER BY CreatedDate DESC';

        if (limitSize != null && limitSize > 0) {
            query += ' LIMIT :limitSize';
            bindParams.put('limitSize', limitSize);
        }

        if (offsetSize != null && offsetSize >= 0) {
            query += ' OFFSET :offsetSize';
            bindParams.put('offsetSize', offsetSize);
        }

        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE,
            Database.queryWithBinds(query, bindParams, AccessLevel.USER_MODE)
        );
        return (List<Operation_Task__c>) decision.getRecords();
    }

    public static Integer countFilteredTasks(String searchTerm, String status, String priority, String category) {
        String query = 'SELECT COUNT() FROM Operation_Task__c WHERE Id != null';
        Map<String, Object> bindParams = new Map<String, Object>();

        if (String.isNotBlank(searchTerm)) {
            query += ' AND (Subject__c LIKE :likeSearch OR Name LIKE :likeSearch)';
            bindParams.put('likeSearch', '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%');
        }

        if (String.isNotBlank(status) && status != 'ALL') {
            query += ' AND Status__c = :status';
            bindParams.put('status', status);
        }

        if (String.isNotBlank(priority) && priority != 'ALL') {
            query += ' AND Priority__c = :priority';
            bindParams.put('priority', priority);
        }

        if (String.isNotBlank(category) && category != 'ALL') {
            query += ' AND Category__c = :category';
            bindParams.put('category', category);
        }

        return Database.countQueryWithBinds(query, bindParams, AccessLevel.USER_MODE);
    }
}
