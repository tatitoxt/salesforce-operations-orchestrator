/**
 * @description Enterprise Service Layer managing workflow orchestrations, analytics, batch execution, and demo data seeding
 */
public inherited sharing class OrchestratorService {

    public class TaskQueryResult {
        @AuraEnabled public List<Operation_Task__c> tasks { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        @AuraEnabled public Integer pageSize { get; set; }
        @AuraEnabled public Integer pageNumber { get; set; }
    }

    public class AnalyticsSummary {
        @AuraEnabled public Integer totalTasks { get; set; }
        @AuraEnabled public Integer pendingTasks { get; set; }
        @AuraEnabled public Integer inProgressTasks { get; set; }
        @AuraEnabled public Integer completedTasks { get; set; }
        @AuraEnabled public Integer failedTasks { get; set; }
        @AuraEnabled public Integer criticalPending { get; set; }
        @AuraEnabled public Decimal completionRate { get; set; }
        @AuraEnabled public Decimal avgProgress { get; set; }
    }

    public static TaskQueryResult fetchTasks(String searchTerm, String status, String priority, String category, Integer pageSize, Integer pageNumber) {
        Integer size = (pageSize != null && pageSize > 0) ? pageSize : 10;
        Integer page = (pageNumber != null && pageNumber > 0) ? pageNumber : 1;
        Integer offset = (page - 1) * size;

        TaskQueryResult result = new TaskQueryResult();
        result.tasks = OperationTaskSelector.selectFilteredTasks(searchTerm, status, priority, category, size, offset);
        result.totalCount = OperationTaskSelector.countFilteredTasks(searchTerm, status, priority, category);
        result.pageSize = size;
        result.pageNumber = page;
        return result;
    }

    public static AnalyticsSummary getAnalytics() {
        AnalyticsSummary summary = new AnalyticsSummary();
        summary.totalTasks = 0;
        summary.pendingTasks = 0;
        summary.inProgressTasks = 0;
        summary.completedTasks = 0;
        summary.failedTasks = 0;
        summary.criticalPending = 0;
        summary.completionRate = 0;
        summary.avgProgress = 0;

        List<AggregateResult> statusAggs = [
            SELECT Status__c st, COUNT(Id) cnt, AVG(Progress__c) avgProg
            FROM Operation_Task__c
            WITH USER_MODE
            GROUP BY Status__c
        ];

        Decimal totalProgSum = 0;
        for (AggregateResult ar : statusAggs) {
            String st = (String) ar.get('st');
            Integer cnt = (Integer) ar.get('cnt');
            Decimal avgP = (Decimal) ar.get('avgProg');

            summary.totalTasks += cnt;
            if (avgP != null) {
                totalProgSum += (avgP * cnt);
            }

            if (st == 'Pending') {
                summary.pendingTasks += cnt;
            } else if (st == 'In Progress') {
                summary.inProgressTasks += cnt;
            } else if (st == 'Completed') {
                summary.completedTasks += cnt;
            } else if (st == 'Failed') {
                summary.failedTasks += cnt;
            }
        }

        List<AggregateResult> critAgg = [
            SELECT COUNT(Id) cnt
            FROM Operation_Task__c
            WHERE Priority__c = 'Critical' AND Status__c = 'Pending'
            WITH USER_MODE
        ];
        if (!critAgg.isEmpty()) {
            summary.criticalPending = (Integer) critAgg[0].get('cnt');
        }

        if (summary.totalTasks > 0) {
            summary.completionRate = ((Decimal) summary.completedTasks / (Decimal) summary.totalTasks * 100).setScale(1);
            summary.avgProgress = (totalProgSum / (Decimal) summary.totalTasks).setScale(1);
        }

        return summary;
    }

    public static Id launchBatchExecution(List<Id> taskIds) {
        if (taskIds == null || taskIds.isEmpty()) {
            return null;
        }
        return System.enqueueJob(new OperationBatchExecutor(taskIds));
    }

    public static void bulkUpdatePriority(List<Id> taskIds, String newPriority) {
        if (taskIds == null || taskIds.isEmpty() || String.isBlank(newPriority)) {
            return;
        }
        List<Operation_Task__c> tasks = [
            SELECT Id, Priority__c FROM Operation_Task__c WHERE Id IN :taskIds WITH USER_MODE
        ];
        for (Operation_Task__c t : tasks) {
            t.Priority__c = newPriority;
        }
        Database.update(tasks, AccessLevel.USER_MODE);
    }

    public static Integer seedDemoData() {
        List<Operation_Task__c> demoTasks = new List<Operation_Task__c>();
        String[] subjects = new String[]{
            'Nightly ERP Customer Data Sync',
            'Stripe Webhook Payment Gateway Listener',
            'SAP Inventory Ledger Reconciliation',
            'Automated Billing Invoicing Batch',
            'Salesforce User Access & Profile Security Audit',
            'HubSpot Marketing Lead Scoring Engine',
            'Data Warehouse Snowflake Export Pipeline',
            'Twilio SMS Notification Queue Cleanup',
            'AWS S3 Document Archive Sync',
            'Executive KPI Dashboard Real-Time Calculation'
        };
        String[] statuses = new String[]{'Pending', 'In Progress', 'Completed', 'Failed'};
        String[] priorities = new String[]{'Critical', 'High', 'Medium', 'Low'};
        String[] categories = new String[]{'Data Sync', 'Workflow Automation', 'Integration API', 'Billing Audit', 'System Maintenance'};

        for (Integer i = 0; i < 20; i++) {
            String sub = subjects[Math.mod(i, subjects.size())] + ' #' + (i + 1);
            String st = statuses[Math.mod(i, statuses.size())];
            String pr = priorities[Math.mod(i, priorities.size())];
            String cat = categories[Math.mod(i, categories.size())];
            Integer prog = st == 'Completed' ? 100 : (st == 'In Progress' ? 50 : 0);

            demoTasks.add(new Operation_Task__c(
                Subject__c = sub,
                Status__c = st,
                Priority__c = pr,
                Category__c = cat,
                Progress__c = prog,
                Target_Date__c = System.now().addDays(Math.mod(i, 5) + 1),
                Execution_Payload__c = '{"batchSize": 200, "retryStrategy": "EXPONENTIAL", "sourceSystem": "Salesforce_v60"}'
            ));
        }

        Database.SaveResult[] results = Database.insert(demoTasks, false, AccessLevel.USER_MODE);
        Integer insertedCount = 0;
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                insertedCount++;
            }
        }
        return insertedCount;
    }

    public static void deleteAllTasks() {
        List<Operation_Task__c> allTasks = [SELECT Id FROM Operation_Task__c WITH USER_MODE LIMIT 10000];
        if (!allTasks.isEmpty()) {
            Database.delete(allTasks, AccessLevel.USER_MODE);
        }
    }
}
