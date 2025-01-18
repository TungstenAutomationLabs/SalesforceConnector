/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 01-18-2025
 * @last modified by  : Unni
**/
@isTest
public class TotalAgilityMockCallout implements HttpCalloutMock {

    public String responseBody {get; set;}
    public String responseStatus {get; set;}
    public Integer responseStatusCode {get; set;}

    public TotalAgilityMockCallout(String responseBody, String responseStatus, Integer responseStatusCode){
        this.responseBody = responseBody;
        this.responseStatus = responseStatus;
        this.responseStatusCode = responseStatusCode;
    }
    public TotalAgilityMockCallout(){
        this.responseBody = '{"d":{"__type":"JobIdentity:http://www.kofax.com/agility/services/sdk","Id":"D6D41193CA1D11EFA852B85C5C297990"}}';
        this.responseStatus = 'OK';
        this.responseStatusCode = 200;
    }

    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.responseBody);
        res.setStatus(this.responseStatus);
        res.setStatusCode(this.responseStatusCode);
        return res;
    }
}