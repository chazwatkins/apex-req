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

    private static Response run(Request request) {
        return new Response(request, new Http().send(request.build()));
    }

    public interface IQueryParams {}

    public interface IQueryParamsBuilder extends IQueryParams {
        Map<String, Object> build();
    }

    public class JsonToApexConfig {
        public System.Type apexType;
        public Boolean isStrict = false;
    }

    private static final Integer DEFAULT_TIMEOUT = 30000;

    public class Request {
        private String namedCredential = '';
        private String baseUrl = '';
        private String endpoint = '';
        private Map<String, Object> queryParams;
        private final HttpRequest systemRequest;
        private JsonToApexConfig jsonToApexConfig;

        public Request() {
            this.systemRequest = new HttpRequest();
            this.systemRequest.setTimeout(DEFAULT_TIMEOUT);
        }

        public Request(HttpRequest request) {
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

        public Request setJsonToApex(System.Type apexType) {
            if(this.jsonToApexConfig == null) {
                this.jsonToApexConfig = new JsonToApexConfig();
            }
            this.jsonToApexConfig.apexType = apexType;
            return this;
        }

        public Request setJsonToApexStrict(System.Type apexType) {
            if(this.jsonToApexConfig == null) {
                this.jsonToApexConfig = new JsonToApexConfig();
            }

            this.jsonToApexConfig.apexType = apexType;
            this.jsonToApexConfig.isStrict = true;
            return this;
        }

        public JsonToApexConfig getJsonToApex() {
            return this.jsonToApexConfig;
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

        public void getHeader(String key) {
            this.systemRequest.getHeader(key);
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

        private void setMethod(String method) {
            this.systemRequest.setMethod(method);
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

        private HttpRequest build() {
            this.systemRequest.setEndpoint(this.getRequestUrl());
            return this.systemRequest;
        }

        private String getRequestUrl() {
            return String.format(
                    '{0}{1}{2}{3}',
                    new String[]{
                            'callout:' + this.namedCredential,
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

    public class Response {
        private HttpResponse systemResponse = new HttpResponse();
        private JsonToApexConfig jsonToApexConfig;

        public Response() {
        }

        public Response(HttpResponse response) {
            this.systemResponse = response;
        }

        private Response(Request request, HttpResponse response) {
            this.jsonToApexConfig = request.getJsonToApex();
            this.systemResponse = response;
        }

        public Response setJsonToApex(System.Type apexType) {
            if(this.jsonToApexConfig == null) {
                this.jsonToApexConfig = new JsonToApexConfig();
            }
            this.jsonToApexConfig.apexType = apexType;
            return this;
        }

        public Response setJsonToApexStrict(System.Type apexType) {
            if(this.jsonToApexConfig == null) {
                this.jsonToApexConfig = new JsonToApexConfig();
            }

            this.jsonToApexConfig.apexType = apexType;
            this.jsonToApexConfig.isStrict = true;
            return this;
        }

        public JsonToApexConfig getJsonToApex() {
            return this.jsonToApexConfig;
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

        public Object getBodyFromJson() {
            if (this.jsonToApexConfig == null) {
                return this.getBodyFromJsonUntyped();
            }

            if(this.jsonToApexConfig.isStrict) {
                return JSON.deserializeStrict(this.systemResponse.getBody(), this.jsonToApexConfig.apexType);
            }

            return JSON.deserialize(this.systemResponse.getBody(), this.jsonToApexConfig.apexType);
        }

        public Object getBodyFromJsonUntyped() {
            return JSON.deserializeUntyped(this.systemResponse.getBody());
        }

        public Response setBody(String body) {
            this.systemResponse.setBody(body);
            return this;
        }

        public Response setBodyAsJson(Object body) {
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

        public void getHeader(String key) {
            this.systemResponse.getHeader(key);
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
}