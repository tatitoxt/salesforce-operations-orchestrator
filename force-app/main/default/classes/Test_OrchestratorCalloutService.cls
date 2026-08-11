@IsTest
private class Test_OrchestratorCalloutService {

    @IsTest
    static void testCalloutSuccess() {
        HttpCalloutMockEngine mock = new HttpCalloutMockEngine(200, 'OK', '{"status":"success"}', null);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        OrchestratorCalloutService.CalloutResult res = OrchestratorCalloutService.sendOperationPayload('https://api.enterprise.com/webhook', '{"data":"test"}');
        Test.stopTest();

        System.assertEquals(true, res.isSuccess, 'Callout should succeed with mock 200');
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
    }

    @IsTest
    static void testCalloutError() {
        HttpCalloutMockEngine mock = new HttpCalloutMockEngine(500, 'Internal Server Error', '{"error":"failed"}', null);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        OrchestratorCalloutService.CalloutResult res = OrchestratorCalloutService.sendOperationPayload('https://api.enterprise.com/webhook', '{}');
        Test.stopTest();

        System.assertEquals(false, res.isSuccess, 'Callout should report failure on 500');
    }
}
