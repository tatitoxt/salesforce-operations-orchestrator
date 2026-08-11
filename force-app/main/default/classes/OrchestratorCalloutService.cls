/**
 * @description Outbound REST Callout Service for dispatching workflow execution payloads to external APIs
 */
public inherited sharing class OrchestratorCalloutService {

    public class CalloutResult {
        @AuraEnabled public Integer statusCode { get; set; }
        @AuraEnabled public String responseBody { get; set; }
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
    }

    public static CalloutResult sendOperationPayload(String endpointUrl, String payloadJson) {
        CalloutResult result = new CalloutResult();
        result.isSuccess = false;

        if (String.isBlank(endpointUrl)) {
            result.errorMessage = 'Endpoint URL cannot be empty';
            return result;
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000);
        req.setBody(String.isNotBlank(payloadJson) ? payloadJson : '{}');

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            result.statusCode = res.getStatusCode();
            result.responseBody = res.getBody();
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                result.isSuccess = true;
            } else {
                result.errorMessage = 'HTTP Error: ' + res.getStatusCode() + ' ' + res.getStatus();
            }
        } catch (Exception ex) {
            result.errorMessage = ex.getMessage();
            Logger.error('OrchestratorCalloutService.sendOperationPayload', ex.getMessage(), ex);
        }

        return result;
    }
}
