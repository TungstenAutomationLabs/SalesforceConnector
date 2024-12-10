/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 12-09-2024
 * @last modified by  : Unni
**/
public with sharing class FlowUtility {
    public FlowUtility() {

    }
    public static Map<String, Object> populateFlowVariables(String flowVariableMapping, String responseMessage) {
        Map<String, Object> parsedMapping = (Map<String, Object>) JSON.deserializeUntyped(flowVariableMapping);
        Map<String, Object> responseMessageParsedData = (Map<String, Object>) JSON.deserializeUntyped(responseMessage);
        Map<String, Object> flowInputs = new Map<String, Object>();
    
        for (String key : parsedMapping.keySet()) {
            Object mappingValue = parsedMapping.get(key);
    
            if (mappingValue instanceof String) {
                // Simple field mapping
                List<String> pathParts = ((String) mappingValue).split('\\.');
                Object value = getValueFromPath(responseMessageParsedData, pathParts);
                flowInputs.put(key, value);
    
            } else if (mappingValue instanceof Map<String, Object>) {
                // Complex mapping for arrays
                Map<String, Object> complexMapping = (Map<String, Object>) mappingValue;
                String path = (String) complexMapping.get('Path');
                String sObjectType = (String) complexMapping.get('SObject');
                Map<String, Object> rawFieldsMapping = (Map<String, Object>) complexMapping.get('FieldsMapping');
                Map<String, String> fieldsMapping = new Map<String, String>();
                for (String fieldKey : rawFieldsMapping.keySet()) {
                    fieldsMapping.put(fieldKey, (String) rawFieldsMapping.get(fieldKey));
                }
    
                List<Object> arrayData = (List<Object>) getValueFromPath(responseMessageParsedData, path.split('\\.'));
                List<SObject> sObjectCollection = new List<SObject>();
    
                for (Object arrayItem : arrayData) {
                    Map<String, Object> arrayItemMap = (Map<String, Object>) arrayItem;
                    SObject sObj = (SObject) Type.forName(sObjectType).newInstance();
    
                    for (String sField : fieldsMapping.keySet()) {
                        String jsonField = fieldsMapping.get(sField);
                        sObj.put(sField, arrayItemMap.get(jsonField));
                    }
                    sObjectCollection.add(sObj);
                }
                flowInputs.put(key, sObjectCollection);
            }
        }
    for (String key : flowInputs.keySet()) {
        System.debug('Key: ' + key + ', Value: ' + flowInputs.get(key));
    }
    
        return flowInputs;
    }
    
    // Helper method to traverse a JSON path
    private static Object getValueFromPath(Map<String, Object> data, List<String> pathParts) {
        Object current = data;
        for (String part : pathParts) {
            if (current instanceof Map<String, Object>) {
                current = ((Map<String, Object>) current).get(part);
            } else {
                return null; // Path not found
            }
        }
        return current;
    }
    
}