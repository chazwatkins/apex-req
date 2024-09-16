@IsTest
public class ReqHttpCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(request.getBody());
        response.setStatusCode(200);

        return response;
    }
}