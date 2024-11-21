public class Req {

  public static Response del(Request request) {
    request.setMethod('DELETE');
    return run(request);
  }

  public static Response get(Request request) {
    request.setMethod('GET');
    return run(request);
  }

  public static Response head(Request request) {
    request.setMethod('HEAD');
    return run(request);
  }

  public static Response options(Request request) {
    request.setMethod('OPTIONS');
    return run(request);
  }

  public static Response patch(Request request) {
    request.setMethod('PATCH');
    return run(request);
  }

  public static Response post(Request request) {
    request.setMethod('POST');
    return run(request);
  }

  public static Response put(Request request) {
    request.setMethod('PUT');
    return run(request);
  }

  public static Response trace(Request request) {
    request.setMethod('TRACE');
    return run(request);
  }

  private static Response run(Request request) {
    return new Response(
            request,
            new Http().send(request.build())
    );
  }


  private static final Integer DEFAULT_TIMEOUT = 30000;

  public class Request implements IRequest {
    private String namedCredential = '';
    private String baseUrl = '';
    private String endpoint = '';
    private Map<String, Object> queryParams;
    private final HttpRequest systemRequest;
    private IntoApex intoApex;
    private Object body;

    public Request() {
      this.systemRequest = new HttpRequest();
      this.systemRequest.setTimeout(DEFAULT_TIMEOUT);
    }

    @TestVisible
    private Request(HttpRequest request) {
      this.systemRequest = request;
    }

    public Request setBaseUrl(String baseUrl) {
      this.baseUrl = baseUrl;
      return this;
    }

    public String getBaseUrl() {
      return this.baseUrl;
    }

    public Request setNamedCredential(String namedCredential) {
      this.namedCredential = namedCredential;
      return this;
    }

    public String getNamedCredential() {
      return this.namedCredential;
    }

    public Request setIntoApex(IntoApex intoApex) {
      this.intoApex = intoApex;
      return this;
    }

    public Request setIntoApex(System.Type apexType) {
      this.intoApex = new IntoApexJson(apexType);
      return this;
    }

    public Request setIntoApexStrict(IntoApex intoApexStrict) {
      this.intoApex = intoApexStrict;
      return this;
    }

    public Request setIntoApexStrict(System.Type apexType) {
      this.intoApex = new IntoApexJsonStrict(apexType);
      return this;
    }

    public IntoApex getIntoApex() {
      return this.intoApex;
    }

    public Request setQueryParams(QueryParams queryParams) {
      Object toDeserialize;
      if (queryParams instanceof QueryParamsBuilder) {
        toDeserialize = ((QueryParamsBuilder) queryParams).build();
      } else {
        toDeserialize = queryParams;
      }

      Map<String, Object> untypedQueryParams =
              (Map<String, Object>) JSON.deserializeUntyped(
                      JSON.serialize(toDeserialize, true)
              );

      return this.setQueryParams(untypedQueryParams);
    }

    public Request setQueryParams(Map<String, Object> queryParams) {
      this.queryParams = queryParams;
      return this;
    }

    public Map<String, Object> getQueryParams() {
      return this.queryParams;
    }

    public Object getBody() {
      return this.body;
    }

    public Request setBody(String body) {
      this.body = body;
      return this;
    }

    public Request setBody(Object body) {
      this.body = body;
      return this;
    }

    public Blob getBodyAsBlob() {
      return this.systemRequest.getBodyAsBlob();
    }

    public Request setBodyAsBlob(Blob body) {
      this.systemRequest.setBodyAsBlob(body);
      return this;
    }

    public Request setBodyDocument(Dom.Document document) {
      this.systemRequest.setBodyDocument(document);
      return this;
    }

    public Dom.Document getBodyDocument() {
      return this.systemRequest.getBodyDocument();
    }

    public String getHeader(String key) {
      return this.systemRequest.getHeader(key);
    }

    public Request setHeader(String key, String value) {
      this.systemRequest.setHeader(key, value);
      return this;
    }

    public String getEndpoint() {
      return this.endpoint;
    }

    public Request setEndpoint(String endpoint) {
      this.endpoint = endpoint;
      return this;
    }

    public Request setMethod(String method) {
      this.systemRequest.setMethod(method);
      return this;
    }

    public String getMethod() {
      return this.systemRequest.getMethod();
    }

    public Boolean getCompressed() {
      return this.systemRequest.getCompressed();
    }

    public Request setCompressed(Boolean flag) {
      this.systemRequest.setCompressed(flag);
      return this;
    }

    public Request setClientCertification(String clientCert, String password) {
      this.systemRequest.setClientCertificate(clientCert, password);
      return this;
    }

    public Request setClientCertification(String certDevName) {
      this.systemRequest.setClientCertificateName(certDevName);
      return this;
    }

    public Request setTimeout(Integer timeout) {
      this.systemRequest.setTimeout(timeout);
      return this;
    }

    @TestVisible
    private HttpRequest build() {
      this.setRequestUrl();
      this.maybeTransformBody();

      return this.systemRequest;
    }

    private void maybeTransformBody() {
      Object requestBody = this.getBody();

      if (requestBody == null) {
        return;
      }

      if (requestBody instanceof String) {
        this.systemRequest.setBody((String) requestBody);
        return;
      }

      String contentType = this.getHeader('Content-Type');

      if (contentType.contains('application/json')) {
        this.systemRequest.setBody(JSON.serialize(requestBody));
        return;
      }
    }

    private void setRequestUrl() {
      String callout;
      if (String.isBlank(this.getNamedCredential())) {
        callout = '';
      } else {
        callout = 'callout:' + this.getNamedCredential();
      }

      this.systemRequest.setEndpoint(
              String.format(
                      '{0}{1}{2}{3}',
                      new String[]{
                              callout,
                              this.getBaseUrl(),
                              this.getEndpoint(),
                              this.getQueryParamsEncoded()
                      })
      );
    }

    private String getQueryParamsEncoded() {
      if (this.queryParams == null) {
        return '';
      }

      String[] queryParamsPayload = new List<String>();
      for (String key : this.queryParams.keySet()) {
        Object value = this.queryParams.get(key);

        if (value == null) {
          continue;
        }

        String stringValue;
        if (value instanceof Map<String, Object> || value instanceof Object[]) {
	        stringValue = JSON.serialize(value, true);
	        stringValue = EncodingUtil.urlEncode(stringValue, 'UTF-8');
        } else {
          stringValue = String.valueOf(value);
        }

        queryParamsPayload.add(key + '=' + stringValue);
      }

      return '?' + String.join(queryParamsPayload, '&');

    }

  }

  public class Response implements IResponse {
    @TestVisible
    private HttpResponse systemResponse = new HttpResponse();
    private IntoApex intoApex;
    private Object body;

    public Response() {
    }

    @TestVisible
    private Response(HttpResponse response) {
      this(null, response);
    }

    @TestVisible
    private Response(Request request, HttpResponse response) {
      this.intoApex = request?.getIntoApex();
      this.systemResponse = response;
      this.body = this.maybeTransformBody(this.systemResponse.getBody());
    }

    public Response setIntoApex(IntoApex intoApex) {
      this.intoApex = intoApex;
      return this;
    }

    public Response setIntoApex(System.Type apexType) {
      this.intoApex = new IntoApexJson(apexType);
      return this;
    }

    public Response setIntoApexStrict(IntoApex intoApexStrict) {
      this.intoApex = intoApexStrict;
      return this;
    }

    public Response setIntoApexStrict(System.Type apexType) {
      this.intoApex = new IntoApexJsonStrict(apexType);
      return this;
    }

    public IntoApex getIntoApex() {
      return this.intoApex;
    }

    public Integer getStatusCode() {
      return this.systemResponse.getStatusCode();
    }

    public Response setStatusCode(Integer statusCode) {
      this.systemResponse.setStatusCode(statusCode);
      return this;
    }

    public String getStatus() {
      return this.systemResponse.getStatus();
    }

    public Response setStatus(String status) {
      this.systemResponse.setStatus(status);
      return this;
    }

    public String getStatusType() {
      return getStatusCodeType(this.getStatusCode()).name();
    }

    public Boolean isStatusSuccessful() {
      return getStatusCodeType(
              this.getStatusCode()
      ) == HttpStatusCodeType.SUCCESSFUL;
    }

    public Boolean isStatusRedirection() {
      return getStatusCodeType(
              this.getStatusCode()
      ) == HttpStatusCodeType.REDIRECTION;
    }

    public Boolean isStatusInformational() {
      return getStatusCodeType(
              this.getStatusCode()
      ) == HttpStatusCodeType.INFORMATIONAL;
    }

    public Boolean isStatusClientError() {
      return getStatusCodeType(
              this.getStatusCode()
      ) == HttpStatusCodeType.CLIENT_ERROR;
    }

    public Boolean isStatusServerError() {
      return getStatusCodeType(
              this.getStatusCode()
      ) == HttpStatusCodeType.SERVER_ERROR;
    }

    public Boolean isStatusError() {
      HttpStatusCodeType statusCodeType =
              getStatusCodeType(this.getStatusCode());

      return statusCodeType.name().contains('ERROR');
    }

    public Object getBody() {
      return this.body;
    }

    public Response setBody(String body) {
      this.body = body;
      this.systemResponse.setBody(body);
      return this;
    }

    public Response setBody(Object body) {
      this.body = body;
      return this;
    }

    public Blob getBodyAsBlob() {
      return this.systemResponse.getBodyAsBlob();
    }

    public Response setBodyAsBlob(Blob body) {
      this.systemResponse.setBodyAsBlob(body);
      return this;
    }

    public Dom.Document getBodyDocument() {
      return this.systemResponse.getBodyDocument();
    }

    public String getHeader(String key) {
      return this.systemResponse.getHeader(key);
    }

    public Response setHeader(String key, String value) {
      this.systemResponse.setHeader(key, value);
      return this;
    }

    public String[] getHeaderKeys() {
      return this.systemResponse.getHeaderKeys();
    }

    public XmlStreamReader getXmlStreamReader() {
      return this.systemResponse.getXmlStreamReader();
    }

    private Object maybeTransformBody(Object systemResponseBody) {
      String contentType = this.getHeader('Content-Type');

      if (systemResponseBody instanceof Blob) {
        systemResponseBody = systemResponseBody.toString();
      }

      if (contentType != null && contentType.contains('application/json')) {
        return this.maybeTransformBodyJson((String) systemResponseBody);
      }

      return systemResponseBody;
    }

    private Object maybeTransformBodyJson(String systemResponseBody) {

      /* TODO: Update Req to deal with JSON.deserialize errors.
          This happens on 400 responses when the response body
          is a different shape from the expected response.
          Only deserialize for 200 responses
          For all other responses, return Req.Error with
          the body deserialized untyped if a body exists.
          Maybe provide an option to give an on Error type
          to deserialize into.
          intoApexOnError(Req.Error) or intoApexOnError(Req.STATUS_CODE, Req.Error)?
       */
      if (!this.isStatusSuccessful()) {
        return JSON.deserializeUntyped(systemResponseBody);
      }

      if (this.intoApex == null) {
        return JSON.deserializeUntyped(systemResponseBody);
      }

      try {
        return this.intoApex.transform(systemResponseBody);
      } catch (Exception e) {
        return JSON.deserializeUntyped(systemResponseBody);
      }
    }
  }

  private static HttpStatusCodeType getStatusCodeType(Integer statusCode) {

    HttpStatusCodeType statusCodeType;
    if (statusCode >= 100 && statusCode <= 199) {
      statusCodeType = HttpStatusCodeType.INFORMATIONAL;
    }

    if (statusCode >= 200 && statusCode <= 299) {
      statusCodeType = HttpStatusCodeType.SUCCESSFUL;
    }

    if (statusCode >= 300 && statusCode <= 399) {
      statusCodeType = HttpStatusCodeType.REDIRECTION;
    }

    if (statusCode >= 400 && statusCode <= 499) {
      statusCodeType = HttpStatusCodeType.CLIENT_ERROR;
    }

    if (statusCode >= 500 && statusCode <= 599) {
      statusCodeType = HttpStatusCodeType.SERVER_ERROR;
    }

    return statusCodeType;
  }

  private enum HttpStatusCodeType {
    INFORMATIONAL,
    SUCCESSFUL,
    REDIRECTION,
    CLIENT_ERROR,
    SERVER_ERROR
  }

  private interface ApexHttpRequest {
    Request setBody(String body);
    Blob getBodyAsBlob();
    Request setBodyAsBlob(Blob body);
    Request setBodyDocument(Dom.Document document);
    Dom.Document getBodyDocument();
    String getHeader(String key);
    Request setHeader(String key, String value);
    String getEndpoint();
    Request setEndpoint(String endpoint);
    Request setMethod(String method);
    String getMethod();
    Boolean getCompressed();
    Request setCompressed(Boolean flag);
    Request setClientCertification(String clientCert, String password);
    Request setClientCertification(String certDevName);
    Request setTimeout(Integer timeout);
  }

  private interface ApexHttpResponse {
    Integer getStatusCode();
    Response setStatusCode(Integer statusCode);
    String getStatus();
    Response setStatus(String status);
    Response setBody(String body);
    Blob getBodyAsBlob();
    Response setBodyAsBlob(Blob body);
    Dom.Document getBodyDocument();
    String getHeader(String key);
    Response setHeader(String key, String value);
    String[] getHeaderKeys();
    XmlStreamReader getXmlStreamReader();
  }

  private interface IRequest extends ApexHttpRequest {
    Object getBody();
    Request setNamedCredential(String namedCredential);
    Request setIntoApex(System.Type apexType);
    Request setIntoApexStrict(System.Type apexType);
    IntoApex getIntoApex();
    Request setQueryParams(QueryParams queryParams);
    Request setQueryParams(Map<String, Object> queryParams);
    Map<String, Object> getQueryParams();
  }

  private interface IResponse extends ApexHttpResponse {
    Object getBody();
    Response setIntoApex(System.Type apexType);
    Response setIntoApexStrict(System.Type apexType);
    IntoApex getIntoApex();
  }

  public interface QueryParams {
  }

  public interface QueryParamsBuilder extends QueryParams {
    Map<String, Object> build();
  }

  @TestVisible
  private interface IntoApex {
    Object transform(Object payload);
  }

  @TestVisible
  private class IntoApexJsonStrict implements IntoApex {
    public System.Type apexType;

    public IntoApexJsonStrict(System.Type apexType) {
      this.apexType = apexType;
    }

    public Object transform(Object payload) {
      return JSON.deserializeStrict((String) payload, this.apexType);
    }
  }

  @TestVisible
  private class IntoApexJson implements IntoApex {
    public System.Type apexType;

    public IntoApexJson(System.Type apexType) {
      this.apexType = apexType;
    }

    public Object transform(Object payload) {
      return JSON.deserialize((String) payload, this.apexType);
    }
  }
}