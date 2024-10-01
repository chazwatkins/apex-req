@IsTest(IsParallel=true)
private class ReqResponseTest {

  @IsTest
  static void newReqResponseHasDefaultsSet() {
    Req.Response response = new Req.Response();
    System.Assert.isNotNull(response.systemResponse);
  }

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

  @IsTest
  static void withoutIntoApexJsonResponseIsDeserialized() {

    User[] testData = new User[]{
            new User(FirstName = 'Test')
    };

    String systemResponsePayload = JSON.serialize(testData);
    HttpResponse systemResponse = new HttpResponse();
    systemResponse.setHeader('Content-Type', 'application/json');
    systemResponse.setBody(systemResponsePayload);
    systemResponse.setStatusCode(200);

    Req.Request request =
            new Req.Request()
                    .setHeader('Content-Type', 'application/json')
                    .setBody(testData);


    Req.Response response =
            new Req.Response(request, systemResponse);

    System.Assert.areEqual(
            JSON.deserializeUntyped(systemResponsePayload),
            response.getBody()
    );

  }

  @IsTest
  static void withIntoApexJsonResponseIsDeserialized() {

    User[] testData = new User[]{
            new User(FirstName = 'Test')
    };

    String systemResponsePayload = JSON.serialize(testData);
    HttpResponse systemResponse = new HttpResponse();
    systemResponse.setHeader('Content-Type', 'application/json');
    systemResponse.setBody(systemResponsePayload);
    systemResponse.setStatusCode(200);

    Req.Request request =
            new Req.Request()
                    .setHeader('Content-Type', 'application/json')
                    .setIntoApex(List<User>.class)
                    .setBody(testData);


    Req.Response response =
            new Req.Response(request, systemResponse);

    System.Assert.areEqual(
            JSON.deserialize(systemResponsePayload, List<User>.class),
            response.getBody()
    );

  }

  @IsTest
  static void withIntoApexStrictJsonResponseIsDeserialized() {

    User[] testData = new User[]{
            new User(FirstName = 'Test')
    };

    String systemResponsePayload = JSON.serialize(testData);
    HttpResponse systemResponse = new HttpResponse();
    systemResponse.setHeader('Content-Type', 'application/json');
    systemResponse.setBody(systemResponsePayload);
    systemResponse.setStatusCode(200);

    Req.Request request =
            new Req.Request()
                    .setHeader('Content-Type', 'application/json')
                    .setIntoApexStrict(List<User>.class)
                    .setBody(testData);


    Req.Response response =
            new Req.Response(request, systemResponse);

    System.Assert.areEqual(
            JSON.deserializeStrict(systemResponsePayload, List<User>.class),
            response.getBody()
    );

  }

  @IsTest
  static void withIntoApexWithoutContentTypeBodyIsNotDeserialized() {

    User[] testData = new User[]{
            new User(FirstName = 'Test')
    };

    String systemResponsePayload = JSON.serialize(testData);
    HttpResponse systemResponse = new HttpResponse();
    systemResponse.setBody(systemResponsePayload);
    systemResponse.setStatusCode(200);

    Req.Request request =
            new Req.Request()
                    .setIntoApex(List<User>.class)
                    .setBody(testData);


    Req.Response response =
            new Req.Response(request, systemResponse);

    System.Assert.areEqual(
            systemResponsePayload,
            response.getBody()
    );

  }

  @IsTest
  static void setIntoApexCreatesToApexJsonTransformer() {
    Req.Response response =
            new Req.Response()
                    .setIntoApex(User.class);

    Req.IntoApexJson transformer =
            (Req.IntoApexJson) response.getIntoApex();

    System.Assert.isInstanceOfType(transformer, Req.IntoApexJson.class);
    System.Assert.areEqual(User.class, transformer.apexType);
  }

  @IsTest
  static void setIntoApexStrictCreatesToApexStrictJsonTransformer() {
    Req.Response response =
            new Req.Response()
                    .setIntoApexStrict(User.class);

    Req.IntoApex transformer = response.getIntoApex();

    System.Assert.isInstanceOfType(transformer, Req.IntoApexJsonStrict.class);
    System.Assert.areEqual(User.class, ((Req.IntoApexJsonStrict) transformer).apexType);
  }
}