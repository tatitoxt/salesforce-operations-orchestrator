/**
 * @description Selector class for querying Operation_Rule__mdt Custom Metadata Types
 */
public inherited sharing class OperationRulesSelector {

    public static List<Operation_Rule__mdt> getAllRules() {
        return [
            SELECT DeveloperName, MasterLabel, Max_Retries__c, Escalation_Email__c, Auto_Retry__c, SLA_Hours__c
            FROM Operation_Rule__mdt
            WITH USER_MODE
        ];
    }

    public static Operation_Rule__mdt getRuleByDeveloperName(String devName) {
        if (String.isBlank(devName)) {
            return null;
        }
        List<Operation_Rule__mdt> rules = [
            SELECT DeveloperName, MasterLabel, Max_Retries__c, Escalation_Email__c, Auto_Retry__c, SLA_Hours__c
            FROM Operation_Rule__mdt
            WHERE DeveloperName = :devName
            WITH USER_MODE
            LIMIT 1
        ];
        return rules.isEmpty() ? null : rules[0];
    }
}
