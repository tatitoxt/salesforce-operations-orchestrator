@IsTest
private class Test_OperationRulesSelector {

    @IsTest
    static void testMetadataSelector() {
        Test.startTest();
        List<Operation_Rule__mdt> allRules = OperationRulesSelector.getAllRules();
        Operation_Rule__mdt rule = OperationRulesSelector.getRuleByDeveloperName('Data_Sync_Rule');
        Test.stopTest();

        System.assertNotEquals(null, allRules, 'Rules list should not be null');
    }
}
