@IsTest
private class ReqTest {
    @IsTest
    static void del() {

        Test.setMock(HttpCalloutMock.class, new ReqHttpCalloutMock());

        Req.Request request =
                new Req.Request()
                .setHeader('Content-Type', 'application/json')
                .setIntoApex(List<User>.class)
                .setBody(new User[]{new User(FirstName='Test')});

        Req.Response response = Req.del(request);
        User[] returnedUsers = (User[])response.getBody();
        System.Assert.areEqual('Test', returnedUsers[0].FirstName);
    }

    @IsTest
    static void get() {

        Test.setMock(HttpCalloutMock.class, new ReqHttpCalloutMock());

        Req.Request request =
                new Req.Request()
                        .setHeader('Content-Type', 'application/json')
                        .setIntoApex(List<User>.class)
                        .setBody(new User[]{new User(FirstName='Test')});

        Req.Response response = Req.get(request);
        User[] returnedUsers = (User[])response.getBody();
        System.Assert.areEqual('Test', returnedUsers[0].FirstName);
    }

    @IsTest
    static void head() {

        Test.setMock(HttpCalloutMock.class, new ReqHttpCalloutMock());

        Req.Request request =
                new Req.Request()
                        .setHeader('Content-Type', 'application/json')
                        .setIntoApex(List<User>.class)
                        .setBody(new User[]{new User(FirstName='Test')});

        Req.Response response = Req.head(request);
        User[] returnedUsers = (User[])response.getBody();
        System.Assert.areEqual('Test', returnedUsers[0].FirstName);
    }

    @IsTest
    static void options() {

        Test.setMock(HttpCalloutMock.class, new ReqHttpCalloutMock());

        Req.Request request =
                new Req.Request()
                        .setHeader('Content-Type', 'application/json')
                        .setIntoApex(List<User>.class)
                        .setBody(new User[]{new User(FirstName='Test')});

        Req.Response response = Req.options(request);
        User[] returnedUsers = (User[])response.getBody();
        System.Assert.areEqual('Test', returnedUsers[0].FirstName);
    }

    @IsTest
    static void patch() {

        Test.setMock(HttpCalloutMock.class, new ReqHttpCalloutMock());

        Req.Request request =
                new Req.Request()
                        .setHeader('Content-Type', 'application/json')
                        .setIntoApex(List<User>.class)
                        .setBody(new User[]{new User(FirstName='Test')});

        Req.Response response = Req.patch(request);
        User[] returnedUsers = (User[])response.getBody();
        System.Assert.areEqual('Test', returnedUsers[0].FirstName);
    }

    @IsTest
    static void post() {

        Test.setMock(HttpCalloutMock.class, new ReqHttpCalloutMock());

        Req.Request request =
                new Req.Request()
                        .setHeader('Content-Type', 'application/json')
                        .setIntoApex(List<User>.class)
                        .setBody(new User[]{new User(FirstName='Test')});

        Req.Response response = Req.post(request);
        User[] returnedUsers = (User[])response.getBody();
        System.Assert.areEqual('Test', returnedUsers[0].FirstName);
    }

    @IsTest
    static void put() {

        Test.setMock(HttpCalloutMock.class, new ReqHttpCalloutMock());

        Req.Request request =
                new Req.Request()
                        .setHeader('Content-Type', 'application/json')
                        .setIntoApex(List<User>.class)
                        .setBody(new User[]{new User(FirstName='Test')});

        Req.Response response = Req.put(request);
        User[] returnedUsers = (User[])response.getBody();
        System.Assert.areEqual('Test', returnedUsers[0].FirstName);
    }

    @IsTest
    static void trace() {

        Test.setMock(HttpCalloutMock.class, new ReqHttpCalloutMock());

        Req.Request request =
                new Req.Request()
                        .setHeader('Content-Type', 'application/json')
                        .setIntoApex(List<User>.class)
                        .setBody(new User[]{new User(FirstName='Test')});

        Req.Response response = Req.trace(request);
        User[] returnedUsers = (User[])response.getBody();
        System.Assert.areEqual('Test', returnedUsers[0].FirstName);
    }
}