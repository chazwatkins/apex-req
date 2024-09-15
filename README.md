# Req
An improved http client experience for Salesforce Apex

Inspired by [Elixir's Req HTTP Client](https://hexdocs.pm/req)
___
🚧 WORK IN PROGRESS 🚧

Do not use in production.  Development is ongoing.
___
Req wraps the standard HttpRequest and HttpResponse objects with `Req.Request` and
`Req.Response`.  Both expose all of the methods of their system counterparts.  This means
Req can easily be swapped in wherever HttpRequest or HttpResponse is used.

_** The only exception is `HttpRequest.setMethod` and `HttpRequest.getMethod`
as the http method is set when using Req http methods._

All HTTP methods supported by `HttpRequest` are available using `Req.<httpMethod>`
static methods that take `Req.Request` and return `Req.Response`.

- Req.del
- Req.get
- Req.head
- Req.options
- Req.patch
- Req.post
- Req.put
___

🛣️ Roadmap

If you have any ideas for additional features, feel free to open an issue.

## Goals
- [x] Wrap HttpRequest and HttpResponse
- [x] Add `Req.<httpMethod>` static methods
- [x] Add named credentials
- [x] Add base url
- [x] Add ability to set json to apex config on `Req.Request` for `Req.Response`
    - Add config for `JSON.deserialize`
    - Add config for `JSON.deserializeStrict`
- [x] Add `Req.Response.getBodyFromJson`
    - Uses `JSON.deserializeUntyped` when no json to apex config is set
    - Uses `JSON.deserialize` when json to apex config is set
    - Uses `JSON.deserializeStrict` when json to apex config is set as strict
- [x] Add `Req.Request.setQueryParams`
    - Allow `Map<String, Object>`
    - Provide interface for using Apex Types for query params
    - Provide interface for using Apex Types for query params that have Apex reserved tokens.
    i.e. sort, delete, insert, etc.
- [ ] Add ability to mock `Req.<httpMethod>` calls.
  - Maybe just use HttpCalloutMock?
- [ ] Write tests

## Stretch Goals

- [ ] Add retry with backoff mechanism
___
## Examples

```apex
public class FooBarService {
    public static Foo[] getFoos(String[] names) {
        Req.Request request =
                new Req.Request()
                        .setNamedCredential('MY_NAMED_CREDENTIAL')
                        .setBaseUrl('/api/v1')
                        .setHeader('Accept', 'application/json')
                        .setEndpoint('/foos')
                        .setIntoApex(List<Foo>.class)
                        .setQueryParams(
                                new Map<String, Object>{
                                        'filter' => names
                                }
                        );

        Req.Response response = Req.get(request);

        if (response.getStatusCode != 200) {
            // do something
        }

        // Deserializes into List<Foo>.class specified by the Req.Request
        return (Foo[]) response.getBodyFromJson();
    }

    public static CreateBarsResponse createBars(Map<String, Object> payload) {
        Req.Request request =
                new Req.Request()
                        .setNamedCredential('MY_NAMED_CREDENTIAL')
                        .setBaseUrl('/api/v1')
                        .setHeader('Accept', 'application/json')
                        .setHeader('Content-Type', 'application/json')
                        .setEndpoint('/bars')
                        .setIntoApexStrict(CreateBarsResponse.class)
                        .setBodyAsJson(payload);

        Req.Response response = Req.post(request);

        if (response.getStatusCode != 201) {
            // do something
        }

        // Deserializes into CreateBarsResponse.class specified by the Req.Request
        return (CreateBarsResponse) response.getBodyFromJson();
    }
}
```
___
## Req.Request

### Constructors

- `Req.Request()`
- `Req.Request(HttpRequest request)`

### New Methods

#### void setNamedCredential(String namedCredential)
- Prepends the endpoint with `callout:{namedCredential}`

#### void setBaseUrl(String baseUrl)
- Prepends the endpoint with baseUrl.
- Useful when doing multiple requests using the same `Req.Request` instance.  Just update the endpoint for each 
  request and the baseUrl will be included.
- When used with `setNamedCredential`, the endpoint format is
  `{namedCredential} + {baseUrl} + {endpoint}`

#### String getBaseUrl()

#### void setBodyAsJson(Object body)
- JSON serializes the body

#### void setJsonToApex(System.Type apexType)

#### void setJsonToApexStrict(System.Type apexType)
- Both methods specify an Apex Type `Req.Response.getBodyFromJson()` will deserialize into.

#### Req.JsonToApexConfig getJsonToApex()

#### Object getBodyFromJson()
- Returns the deserialized JSON according to the apex type set.
- When `Request.setJsonToApex` was set, uses `JSON.deserialize`
- When `Request.setJsonToApexStrict` was set, uses `JSON.deserializeStrict`.
- If neither were set, uses `JSON.deserializeUntyped`.

#### Map<String, Object> getQueryParams()
#### void setQueryParams(Map<String, Object> queryParams)
#### void setQueryParams(Req.IQueryParams queryParams)
- Allows your to create a class that represents an API's query
  params.
- Query param values are automatically set to UTF-8 URL encoded strings.

### Query Params

Req will URL encode all query param values and append them to the endpoint.

You can provide query params in three ways.

1. Build your own `Map<String, Object>`.
    ```apex
    Map<String, Object> myQueryParams = new Map<String, Object>{
            'pagination' => new Map<String, Integer>{'page' => 1, 'pageSize' => 10},
            'sort' => new Map<String, String>{'fieldName' => 'desc'}
    };
    
    new Req.Request().setQueryParams(myQueryParams);
    ```

2. Create a class using the `Req.IQueryParams` interface where all the class property names match the query
   param keys and value types.

    ```apex
    public class QueryParams implements Req.IQueryParams {
        public Map<String, Integer> pagination;
    }
    
    QueryParams queryParams = new QueryParams();
    queryParams.pagination = new Map<String, Integer>{'page' => 1, 'pageSize' => 10};
    
    new Req.Request().setQueryParams(queryParams);
    ```

3. Create a class using the `Req.IQueryParamsBuilder` interface that requires a `Map<String, Object> build()`
   method.  Use this in scenarios where a query param has a name reserved in Apex and you need to rename
   the property before it's sent. For example: sort, insert, delete

    ```apex
    public class QueryParams implements Req.IQueryParamsBuilder {
        // sort and delete are reserved Apex tokens
        public Map<String, String> sortOrder;
        public Boolean del;
        
        public Map<String, Object> build() {
            return new Map<String, Object>{
                    'sort' => this.sortOrder,
                    'delete' => this.del
            };
        }
    }
    
    QueryParams queryParams = new QueryParams();
    queryParams.sortOrder = new Map<String, String>{'fieldName' => 'desc'};
    queryParams.del = true;
    
    new Req.Request().setQueryParams(queryParams);
    ```
___ 
## Req.Response

### Constructors

- `Req.Response()`
- `Req.Response(HttpResponse response)`


### New methods

#### void setJsonToApex(System.Type apexType)
- Specifies the Apex Type `Req.Response.getBodyFromJson()` will deserialize into.
- `Req.Response.getBodyFromJson()` will use `JSON.deserialize`

#### void setJsonToApexStrict(System.Type apexType)
- Specifies the Apex Type `Req.Response.getBodyFromJson()` will deserialize into.
- `Req.Response.getBodyFromJson()` will use `JSON.deserializeStrict`
- When not used, `Req.Response.getBodyFromJson()` will use `JSON.deserializeUntyped`

#### Req.JsonToApexConfig getJsonToApex()

#### void setBodyAsJson(Object body)
- JSON serializes the body

#### Object getBodyFromJson()
- Returns the deserialized JSON according to the apex type set in `Req.Request` or `Req.Response`
- When `Request.setJsonToApex` or `Response.setJsonToApex` were set, uses `JSON.deserialize`
- When `Request.setJsonToApexStrict` or `Response.setJsonToApexStrict` were set,
uses `JSON.deserializeStrict`.
- If neither were set, uses `JSON.deserializeUntyped`.
