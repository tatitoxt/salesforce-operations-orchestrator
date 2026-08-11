/**
 * @description Standardized HttpCalloutMock implementation for testing REST callouts
 */
@IsTest
public class HttpCalloutMockEngine implements HttpCalloutMock {

    private Integer code;
    private String status;
    private String body;
    private Map<String, String> headers;

    public HttpCalloutMockEngine(Integer statusCode, String statusText, String responseBody, Map<String, String> responseHeaders) {
        this.code = statusCode;
        this.status = statusText;
        this.body = responseBody;
        this.headers = responseHeaders != null ? responseHeaders : new Map<String, String>();
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        res.setBody(this.body);
        for (String key : this.headers.keySet()) {
            res.setHeader(key, this.headers.get(key));
        }
        return res;
    }
}
