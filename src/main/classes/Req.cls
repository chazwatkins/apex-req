public abstract class Req {

    public static Response del(Request request) {
        request.setMethod('DELETE');
        return Req.run(request);
    }

    public static Response get(Request request) {
        request.setMethod('GET');
        return Req.run(request);
    }

    public static Response head(Request request) {
        request.setMethod('HEAD');
        return Req.run(request);
    }

    public static Response options(Request request) {
        request.setMethod('OPTIONS');
        return Req.run(request);
    }

    public static Response patch(Request request) {
        request.setMethod('PATCH');
        return Req.run(request);
    }

    public static Response post(Request request) {
        request.setMethod('POST');
        return Req.run(request);
    }

    public static Response put(Request request) {
        request.setMethod('PUT');
        return Req.run(request);
    }

    public static Response trace(Request request) {
        request.setMethod('TRACE');
        return Req.run(request);
    }

    public static Response run(Request request) {
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

        public Request setNamedCredential(String namedCredential) {
            this.namedCredential = namedCredential;
            return this;
        }

        public Request setIntoApex(System.Type apexType) {
            this.intoApex = new IntoApexFromJson(apexType);
            return this;
        }

        public Request setIntoApexStrict(System.Type apexType) {
            this.intoApex = new IntoApexFromJson(apexType, true);
            return this;
        }

        private Request setIntoApex(Dataweave.Script dwScript) {
            this.intoApex = new IntoApexFromDataweave(dwScript);
            return this;
        }

        public IntoApex getIntoApex() {
            return this.intoApex;
        }

        public Request setQueryParams(IQueryParams queryParams) {
            Object toUntype;
            if(queryParams instanceof IQueryParamsBuilder) {
                toUntype = ((IQueryParamsBuilder)queryParams).build();
            } else {
                toUntype = queryParams;
            }

            Map<String, Object> untypedQueryParams =
                    (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(toUntype, true));

            return this.setQueryParams(untypedQueryParams);
        }

        public Request setQueryParams(Map<String, Object> queryParams) {
            this.queryParams = queryParams;
            return this;
        }

        public Map<String, Object> getQueryParams() {
            return this.queryParams;
        }

        public String getBody() {
            return this.systemRequest.getBody();
        }

        public Request setBody(String body) {
            this.systemRequest.setBody(body);
            return this;
        }

        public Request setBodyAsJson(Object body) {
            this.systemRequest.setBody(JSON.serialize(body));
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
            this.systemRequest.setEndpoint(this.buildRequestUrl());
            return this.systemRequest;
        }

        private String buildRequestUrl() {
            String callout;
            if(String.isBlank(this.namedCredential)) {
                callout = '';
            } else {
                callout = 'callout:' + this.namedCredential;
            }

            return String.format(
                    '{0}{1}{2}{3}',
                    new String[]{
                            callout,
                            this.baseUrl,
                            this.endpoint,
                            this.getQueryParamsEncoded()
                    });
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
        private HttpResponse systemResponse = new HttpResponse();
        private IntoApex intoApex;

        public Response() {
        }

        @TestVisible
        private Response(HttpResponse response) {
            this.systemResponse = response;
        }

        @TestVisible
        private Response(Request request, HttpResponse response) {
            this.intoApex = request.getIntoApex();
            this.systemResponse = response;
        }

        public Response setIntoApex(System.Type apexType) {
            this.intoApex = new IntoApexFromJson(apexType);
            return this;
        }

        public Response setIntoApexStrict(System.Type apexType) {
            this.intoApex = new IntoApexFromJson(apexType, true);
            return this;
        }

        private Response setIntoApex(Dataweave.Script dwScript) {
            this.intoApex = new IntoApexFromDataweave(dwScript);
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

        public String getBody() {
            return this.systemResponse.getBody();
        }

        private Object getBodyFromJson() {
            if (this.intoApex == null) {
                return this.getBodyFromJsonUntyped();
            }

            IntoApexFromJson intoConfig = (IntoApexFromJson)this.intoApex;

            if(intoConfig.isStrict) {
                return JSON.deserializeStrict(this.systemResponse.getBody(), intoConfig.apexType);
            }

            return JSON.deserialize(this.systemResponse.getBody(), intoConfig.apexType);
        }

        private Object getBodyFromJsonUntyped() {
            return JSON.deserializeUntyped(this.systemResponse.getBody());
        }

        public Response setBody(String body) {
            this.systemResponse.setBody(body);
            return this;
        }

        private Response setBodyAsJson(Object body) {
            this.systemResponse.setBody(JSON.serialize(body));
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
    }

    private interface ApexHttpRequest {
        String getBody();
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
        String getBody() ;
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
        Request setNamedCredential(String namedCredential);
        Request setIntoApex(System.Type apexType);
        Request setIntoApexStrict(System.Type apexType);
        IntoApex getIntoApex();
        Request setQueryParams(IQueryParams queryParams);
        Request setQueryParams(Map<String, Object> queryParams);
        Map<String, Object> getQueryParams();
    }

    private interface IResponse extends ApexHttpResponse {
        Response setIntoApex(System.Type apexType);
        Response setIntoApexStrict(System.Type apexType);
        IntoApex getIntoApex();
    }

    public interface IQueryParams {}

    public interface IQueryParamsBuilder extends IQueryParams {
        Map<String, Object> build();
    }

    private interface IntoApexTransform {
        Object transform(Object payload);
    }

    private abstract class IntoApex implements IntoApexTransform { }

    private class IntoApexFromJson extends IntoApex {
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
            return payload;
        }
    }

    private class IntoApexFromDataweave extends IntoApex {
        public DataWeave.Script script;

        public IntoApexFromDataweave(Dataweave.Script script) {
            this.script = script;
        }

        public Object transform(Object payload) {
            DataWeave.Result result = this.script.execute((Map<String, Object>)payload);
            return result.getValue();
        }
    }
}