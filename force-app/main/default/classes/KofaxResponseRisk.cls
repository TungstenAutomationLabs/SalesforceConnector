/**
* @apexClassName      : KofaxResponseRisk
* @date               : August 2, 2023
* @description:       : For use wth Risk Scoring functionality; fields with names that are not valid in Apex
* @author             : John Hogan, johnejhogan@gmail.com
*/
global with sharing class KofaxResponseRisk {

    /**
    @methodName     : KofaxResponseRisk
    @description:   : KofaxResponseRisk constructor
    @author         : John Hogan

    @param          : parser (JSONParser): for JSON parsing
    */
    global KofaxResponseRisk(String respJSON) {
        d = new d(respJSON);
    }

    global class d {
        global String x_type { get; set; }
        global String Id { get; set; }
        global String Result { get; set; }
        global String ResultMessage { get; set; }
        global String ResultJSON { get; set; }

        global d(String rJSON){

            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(rJSON);
            if(m.containsKey('d')){
                Object d = m.get('d');
                Map<String, Object> respValuesMap = (Map<String, Object>)m.get('d');
                if(respValuesMap.containsKey('Id')){
                    Id = respValuesMap.get('Id').toString();
                    x_type = respValuesMap.get('__type').toString();
                    Result = 'SUCCESS';
                    ResultMessage = 'Success response from Kofax Risk Score Call';
                }
            } else {
                Id = 'n/a';
                Result = 'FAILURE';
                ResultMessage = 'Failure response from Kofax Risk Score Call. ' + '\n' + rJSON;
            }

            ResultJSON = rJSON;
        }
    }

    global d d { get; set; }

    /**
    @methodName     : parse
    @description:   : Deserialize JSON formatted string into a KofaxResponseRisk object
    @author         : John Hogan

    @param          : json (String): JSON formatted string to deserialize
    
    @return         : KofaxResponseRisk: deserialize from JSON response value
    ************************************************************************************
    */
    
    global static KofaxResponseRisk parse(String respJSON) {
        
        return new KofaxResponseRisk(respJSON);
        
    }
}