/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 11-21-2024
 * @last modified by  : Unni
**/
public with sharing class FlowUtility {
    public FlowUtility() {

    }
    public static Map<String, Object> populateFlowVariables(String flowVariableMapping, String responseMessage) {
        Map<String, Object> parsedData = (Map<String, Object>) JSON.deserializeUntyped(flowVariableMapping);
        Map<String,List<String>> fieldMapping = new Map<String,List<String>>();
        Map<String, Object> flowInputs = new Map<String, Object>();
        
        for (String key : parsedData.keySet()) {
            String value = (String)parsedData.get(key);
            if(String.isNotBlank(value)){
                if(value.contains('.')){
                    List<String> objField = value.split('\\.');
                    fieldMapping.put(key,objField);
                }
            }
        }
        
        Map<String, Object> responseMessageParsedData = (Map<String, Object>) JSON.deserializeUntyped(responseMessage);
        
        for (String  flowvariable : fieldMapping.keySet()) {
            List<String> resMessagePath = fieldMapping.get(flowvariable);
            System.debug('Flow Variable: ' + flowvariable);
            
            Map<String, Object> currentMap = responseMessageParsedData;
            for (Integer i = 0; i < resMessagePath.size(); i++) {
                String pathPart = resMessagePath[i];
                if (i == resMessagePath.size() - 1) {
                    flowInputs.put(flowvariable, currentMap.get(pathPart));
                    System.debug('Flow Variable Value: ' + (String)currentMap.get(pathPart));
                } else {
                    currentMap = (Map<String, Object>) currentMap.get(pathPart);
                }
            }
        }
        return flowInputs;
    }
}