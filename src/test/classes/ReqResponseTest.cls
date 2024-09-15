@IsTest
private class ReqResponseTest {
    @IsTest
    static void setGetStatusHttpResponseStatus() {
        HttpResponse systemResponse = new HttpResponse();

        final String STATUS = 'OK';
        Req.Response response =
                new Req.Response(systemResponse)
                .setStatus(STATUS);

        System.Assert.areEqual(response.getStatus(), systemResponse.getStatus());
    }

    @IsTest
    static void setGetStatusCodeHttpResponseStatusCode() {
        HttpResponse systemResponse = new HttpResponse();

        final Integer STATUS_CODE = 200;
        Req.Response response =
                new Req.Response(systemResponse)
                        .setStatusCode(STATUS_CODE);

        System.Assert.areEqual(response.getStatusCode(), systemResponse.getStatusCode());
    }

    @IsTest
    static void setGetBodySetsAndGetsHttpResponseBody() {
        HttpResponse systemResponse = new HttpResponse();

        Req.Response response =
                new Req.Response(systemResponse)
                        .setBody('TEST');

        System.Assert.areEqual(response.getBody(), systemResponse.getBody());
    }

    @IsTest
    static void setGetBodyAsBlobSetsAndGetsHttpResponseBodyAsBlob() {
        HttpResponse systemResponse = new HttpResponse();

        Req.Response response =
                new Req.Response(systemResponse)
                        .setBodyAsBlob(Blob.valueOf('TEST'));

        System.Assert.areEqual(response.getBodyAsBlob(), systemResponse.getBodyAsBlob());
    }

    @IsTest
    static void setGetHeaderSetsAndGetsHttpResponseHeader() {
        HttpResponse systemResponse = new HttpResponse();

        final String HEADER_KEY = 'Content-Type';
        Req.Response response =
                new Req.Response(systemResponse)
                        .setHeader(HEADER_KEY, 'application/json');

        System.Assert.areEqual(
                response.getHeader(HEADER_KEY),
                systemResponse.getHeader(HEADER_KEY)
        );
    }

    @IsTest
    static void getHeaderKeysGetsHttpResponseHeader() {
        HttpResponse systemResponse = new HttpResponse();

        final String HEADER_KEY = 'Content-Type';
        Req.Response response =
                new Req.Response(systemResponse)
                        .setHeader(HEADER_KEY, 'application/json');

        System.Assert.areEqual(
                response.getHeaderKeys(),
                systemResponse.getHeaderKeys()
        );
    }

    @IsTest
    static void getXmlStreamReaderGetsHttpResponseXmlStreamReader() {
        HttpResponse systemResponse = new HttpResponse();

        final Dom.Document document = new Dom.Document();
        document.createRootElement('ROOT', 'TEST', 'PREFIX');

        Req.Response response =
                new Req.Response(systemResponse)
                        .setBody(document.toXmlString());

        System.Assert.areEqual(
                response.getXmlStreamReader().getNamespace(),
                systemResponse.getXmlStreamReader().getNamespace()
        );
    }
}