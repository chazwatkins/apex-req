public class Req {

    private static final IReq instance = (IReq)new ReqImpl();
    private static IReq mockInstance;

    private static IReq getInstance() {
        if(mockInstance != null) {
            return mockInstance;
        }

        return instance;
    }

    @TestVisible
    private static void setMock(IReq mock) {
        mockInstance = mock;
    }

    public static Response del(Request request) {
        return getInstance().del(request);
    }

    public static Response get(Request request) {
        return getInstance().get(request);
    }

    public static Response head(Request request) {
        return getInstance().head(request);
    }

    public static Response options(Request request) {
        return getInstance().options(request);
    }

    public static Response patch(Request request) {
        return getInstance().patch(request);
    }

    public static Response post(Request request) {
        return getInstance().post(request);
    }

    public static Response put(Request request) {
        return getInstance().put(request);
    }

    public static Response trace(Request request) {
        return getInstance().trace(request);
    }

    private class ReqImpl implements IReq {
        public Response del(Request request) {
            request.setMethod('DELETE');
            return this.run(request);
        }

        public Response get(Request request) {
            request.setMethod('GET');
            return this.run(request);
        }

        public Response head(Request request) {
            request.setMethod('HEAD');
            return this.run(request);
        }

        public Response options(Request request) {
            request.setMethod('OPTIONS');
            return this.run(request);
        }

        public Response patch(Request request) {
            request.setMethod('PATCH');
            return this.run(request);
        }

        public Response post(Request request) {
            request.setMethod('POST');
            return this.run(request);
        }

        public Response put(Request request) {
            request.setMethod('PUT');
            return this.run(request);
        }

        public Response trace(Request request) {
            request.setMethod('TRACE');
            return this.run(request);
        }

        public Response run(Request request) {
            return new Response(
                    request,
                    new Http().send(request.build())
            );
        }
    }

    @TestVisible
    private interface IReq {
        Response del(Request request);
        Response get(Request request);
        Response head(Request request);
        Response options(Request request);
        Response patch(Request request);
        Response post(Request request);
        Response put(Request request);
        Response trace(Request request);
        Response run(Request request);
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

        public Request setIntoApex(System.Type apexType) {
            this.intoApex = new IntoApexFromJson(apexType);
            return this;
        }

        public Request setIntoApexStrict(System.Type apexType) {
            this.intoApex = new IntoApexFromJson(apexType, true);
            return this;
        }

        public IntoApex getIntoApex() {
            return this.intoApex;
        }

        public Request setQueryParams(QueryParams queryParams) {
            Object toDeserialize;
            if(queryParams instanceof QueryParamsBuilder) {
                toDeserialize = ((QueryParamsBuilder)queryParams).build();
            } else {
                toDeserialize = queryParams;
            }

            Map<String, Object> untypedQueryParams =
                    (Map<String, Object>)JSON.deserializeUntyped(
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

            if(requestBody == null) {
                return;
            }

            if(requestBody instanceof String) {
                this.systemRequest.setBody((String)requestBody);
                return;
            }

            String contentType = this.getHeader('Content-Type');

            if(contentType.contains('application/json')) {
                this.systemRequest.setBody(JSON.serialize(requestBody));
                return;
            }
        }

        private void setRequestUrl() {
            String callout;
            if(String.isBlank(this.getNamedCredential())) {
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

                if(value == null) {
                    continue;
                }

                String stringValue;
                if(value instanceof Map<String, Object> || value instanceof Object[]) {
                    stringValue = JSON.serialize(value, true);
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

        public Response setIntoApex(System.Type apexType) {
            this.intoApex = new IntoApexFromJson(apexType);
            return this;
        }

        public Response setIntoApexStrict(System.Type apexType) {
            this.intoApex = new IntoApexFromJson(apexType, true);
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

        private Object maybeTransformBody(String systemResponseBody) {
            String contentType = this.getHeader('Content-Type');
            if(contentType.contains('application/json')) {
                if(this.intoApex == null) {
                    return JSON.deserializeUntyped((String)systemResponseBody);
                }

                return this.intoApex.transform(systemResponseBody);
            }

            return systemResponseBody;
        }
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

    public interface QueryParams {}

    public interface QueryParamsBuilder extends QueryParams {
        Map<String, Object> build();
    }

    @TestVisible
    private interface IntoApex {
        Object transform(Object payload);
    }

    @TestVisible
    private class IntoApexFromJson implements IntoApex {
        public System.Type apexType;
        public Boolean isStrict = false;

        public IntoApexFromJson(System.Type apexType) {
            this(apexType, false);
        }

        public IntoApexFromJson(System.Type apexType, Boolean isStrict) {
            this.apexType = apexType;
            this.isStrict = isStrict;
        }

        public Object transform(Object payload) {
            if(this.isStrict) {
                return JSON.deserializeStrict((String)payload, this.apexType);
            }

            return JSON.deserialize((String)payload, this.apexType);
        }
    }
}