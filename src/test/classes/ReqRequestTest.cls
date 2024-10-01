@IsTest(IsParallel=true)
private class ReqRequestTest {

  private static final String NAMED_CREDENTIAL = 'Foo_Service';
  private static final String BASE_URL = '/api/v1';
  private static final String ENDPOINT = '/foo';

  @IsTest
  static void setBaseUrlPrependsHttpRequestEndpoint() {
    HttpRequest systemRequest = new HttpRequest();

    Req.Request request = new Req.Request(systemRequest);

    request.setBaseUrl(BASE_URL);
    request.build();

    System.Assert.areEqual(BASE_URL, systemRequest.getEndpoint());
  }

  @IsTest
  static void setNamedCredentialPrependsHttpRequestEndpoint() {
    HttpRequest systemRequest = new HttpRequest();

    Req.Request request =
            new Req.Request(systemRequest)
                    .setNamedCredential(NAMED_CREDENTIAL);

    request.build();

    System.Assert.areEqual('callout:' + NAMED_CREDENTIAL, systemRequest.getEndpoint());
  }

  @IsTest
  static void setEndpointSetsHttpRequestEndpoint() {
    HttpRequest systemRequest = new HttpRequest();

    Req.Request request =
            new Req.Request(systemRequest)
                    .setEndpoint(ENDPOINT);

    request.build();

    System.Assert.areEqual(ENDPOINT, systemRequest.getEndpoint());
  }

  @IsTest
  static void buildConstructsHttpRequestEndpoint() {
    HttpRequest systemRequest = new HttpRequest();

    Req.Request request =
            new Req.Request(systemRequest)
                    .setNamedCredential(NAMED_CREDENTIAL)
                    .setBaseUrl(BASE_URL)
                    .setEndpoint(ENDPOINT);

    request.build();

    String expected =
            'callout:' + NAMED_CREDENTIAL + BASE_URL + ENDPOINT;

    System.Assert.areEqual(expected, systemRequest.getEndpoint());
  }

  @IsTest
  static void setGetBodyAsBlobSetsAndGetsHttpRequestBodyAsBlob() {
    HttpRequest systemRequest = new HttpRequest();

    Req.Request request =
            new Req.Request(systemRequest)
                    .setBodyAsBlob(Blob.valueOf('TEST'));

    System.Assert.areEqual(request.getBodyAsBlob(), systemRequest.getBodyAsBlob());
  }

  @IsTest
  static void setGetBodyDocumentSetsAndGetsHttpRequestBodyDocument() {
    HttpRequest systemRequest = new HttpRequest();

    final Dom.Document document = new Dom.Document();
    document.createRootElement('ROOT', 'TEST', 'PREFIX');

    Req.Request request =
            new Req.Request(systemRequest)
                    .setBodyDocument(document);

    System.Assert.areEqual(request.getBodyDocument(), systemRequest.getBodyDocument());
  }

  @IsTest
  static void setGetHeaderSetsAndGetsHttpRequestHeader() {
    HttpRequest systemRequest = new HttpRequest();

    final String HEADER_KEY = 'Content-Type';
    Req.Request request =
            new Req.Request(systemRequest)
                    .setHeader(HEADER_KEY, 'application/json');

    System.Assert.areEqual(
            request.getHeader(HEADER_KEY),
            systemRequest.getHeader(HEADER_KEY)
    );
  }

  @IsTest
  static void setGetMethodSetsAndGetsHttpRequestMethod() {
    HttpRequest systemRequest = new HttpRequest();

    Req.Request request =
            new Req.Request(systemRequest)
                    .setMethod('POST');

    System.Assert.areEqual(
            request.getMethod(),
            systemRequest.getMethod()
    );
  }

  @IsTest
  static void setGetCompressedSetsAndGetsHttpRequestCompressed() {
    HttpRequest systemRequest = new HttpRequest();

    Req.Request request =
            new Req.Request(systemRequest)
                    .setCompressed(true);

    System.Assert.areEqual(
            request.getCompressed(),
            systemRequest.getCompressed()
    );
  }

  @IsTest
  static void buildSerializesBodyWhenContentTypeIsJson() {
    User testData = new User(FirstName = 'Test');

    Req.Request request =
            new Req.Request()
                    .setHeader('Content-Type', 'application/json')
                    .setBody(testData);

    HttpRequest systemRequest = request.build();

    System.Assert.areEqual(
            JSON.serialize(testData),
            systemRequest.getBody()
    );
  }

  @IsTest
  static void setBodyWithStringDoesNotSerialize() {
    String testData = 'Test';

    Req.Request request =
            new Req.Request()
                    .setHeader('Content-Type', 'application/json')
                    .setBody(testData);

    HttpRequest systemRequest = request.build();

    System.Assert.areEqual(
            testData,
            systemRequest.getBody()
    );
  }

  private final static Map<String, Object> MOCK_QUERY_PARAMS =
          new Map<String, Object>{
                  'name' => 'test'
          };

  @IsTest
  static void setQueryParamsWithQueryParamsInterface() {
    QueryParams qp = new QueryParams();

    Req.Request request = new Req.Request().setQueryParams(qp);

    System.Assert.areEqual(MOCK_QUERY_PARAMS, request.getQueryParams());
  }

  @IsTest
  static void setQueryParamsWithQueryParamsBuilderInterface() {
    QueryParamsBuilder qp = new QueryParamsBuilder();

    Req.Request request = new Req.Request().setQueryParams(qp);

    System.Assert.areEqual(MOCK_QUERY_PARAMS, request.getQueryParams());
  }

  @IsTest
  static void setQueryParamsWithMap() {
    Req.Request request = new Req.Request().setQueryParams(MOCK_QUERY_PARAMS);

    System.Assert.areEqual(MOCK_QUERY_PARAMS, request.getQueryParams());
  }

  @IsTest
  static void buildWithQueryParamsWithoutNullValuesAppendsToRequestUrl() {
    final Map<String, Object> queryParams =
            new Map<String, Object>{
                    'name' => new String[]{
                            'awesome'
                    },
                    'test' => 'yay',
                    'fake' => null
            };

    Req.Request request =
            new Req.Request()
                    .setNamedCredential('TEST')
                    .setBaseUrl('/api/v1')
                    .setEndpoint('/foo')
                    .setQueryParams(queryParams);

    HttpRequest systemRequest = request.build();
    System.Assert.isTrue(systemRequest.getEndpoint().contains('?'));
    System.Assert.isTrue(systemRequest.getEndpoint().contains('name='));
    System.Assert.isFalse(systemRequest.getEndpoint().contains('fake='));
  }

  private class QueryParams implements Req.QueryParams {
    public String name = 'test';
  }

  private class QueryParamsBuilder implements Req.QueryParamsBuilder {
    public Map<String, Object> build() {
      return MOCK_QUERY_PARAMS;
    }
  }
}