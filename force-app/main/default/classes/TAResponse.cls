/**
 * @description       :
 * @author            : Unni
 * @group             :
 * @last modified on  : 01-18-2025
 * @last modified by  : Unni
 **/
global with sharing class TAResponse {
    
    global String Id { get; set; }
    global String Result { get; set; }
    global String ResultMessage { get; set; }
    global String ResultJSON { get; set; }
    
    global static TAResponse parse(HttpResponse res) {
        TAResponse response = new TAResponse();
        if (res.getStatusCode() == 200) {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (m.containsKey('d')) {
                Map<String, Object> respValuesMap = (Map<String, Object>) m.get('d');
                if (respValuesMap.containsKey('Id')) {
                    response.Id = (String) respValuesMap.get('Id');
                    response.Result = 'SUCCESS';
                    response.ResultMessage = 'Success response from TotalAgility. ' + '\n' + res.getStatus();
                }
            } else {
                response.Id = 'n/a';
                response.Result = 'FAILURE';
                response.ResultMessage = 'Unexpected response from TotalAgility. ' + '\n' + res.getStatus();
            }
        } else {
            response.Id = 'n/a';
            response.Result = 'FAILURE';
            response.ResultMessage = 'Failure response from TotalAgility. ' + '\n' + res.getStatus();
            
        }
        
        
        
        response.ResultJSON = res.getBody();
        return response;
    }
}