/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 12-13-2024
 * @last modified by  : Unni
**/
public with sharing class FlowUtility {
    public static Map<String, Object> populateFlowVariables(String flowVariableMapping, String responseMessage) {

        Map<String, Object> parsedMapping = (Map<String, Object>) JSON.deserializeUntyped(flowVariableMapping);
        Map<String, Object> responseMessageParsedData = (Map<String, Object>) JSON.deserializeUntyped(responseMessage);
        Map<String, Object> flowInputs = new Map<String, Object>();
    
        for (String key : parsedMapping.keySet()) {
            Object mappingValue = parsedMapping.get(key);
    
            if (mappingValue instanceof Map<String, Object>) {
                // Complex mapping for SObjects or collections
                Map<String, Object> complexMapping = (Map<String, Object>) mappingValue;
                String path = (String) complexMapping.get('Path');
                String sObjectType = (String) complexMapping.get('SObject');
                Boolean isCollection = (Boolean) complexMapping.get('isCollection');
                Map<String, Object> rawFieldsMapping = (Map<String, Object>) complexMapping.get('FieldsMapping');
                Map<String, String> fieldsMapping = new Map<String, String>();
                for (String fieldKey : rawFieldsMapping.keySet()) {
                    fieldsMapping.put(fieldKey, (String) rawFieldsMapping.get(fieldKey));
                }
                
                Object data = getValueFromPath(responseMessageParsedData, path.split('\\.'));
    
                if (isCollection) {
                    // Process array into SObject collection
                    if (data instanceof List<Object>) {
                        List<Object> arrayData = (List<Object>) data;
                        List<SObject> sObjectCollection = new List<SObject>();
    
                        for (Object arrayItem : arrayData) {
                            Map<String, Object> arrayItemMap = (Map<String, Object>) arrayItem;
                            SObject sObj = createSObjectFromMap(sObjectType, fieldsMapping, arrayItemMap);
                            sObjectCollection.add(sObj);
                        }
                        flowInputs.put(key, sObjectCollection);
                    }
                } else {
                    // Process single SObject
                    if (data instanceof Map<String, Object>) {
                        Map<String, Object> objectData = (Map<String, Object>) data;
                        SObject sObj = createSObjectFromMap(sObjectType, fieldsMapping, objectData);
                        flowInputs.put(key, sObj);
                    }
                }
            }
            else if (mappingValue instanceof String) {
                // Simple field mapping
                List<String> pathParts = ((String) mappingValue).split('\\.');
                Object value = getValueFromPath(responseMessageParsedData, pathParts);
                flowInputs.put(key, value);
    
            }
        }

        // Print the key and value of flowInputs
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
    
    // Helper method to create an SObject from a mapping and data
    private static SObject createSObjectFromMap(String sObjectType, Map<String, String> fieldsMapping, Map<String, Object> data) {
        SObject sObj = (SObject) Type.forName(sObjectType).newInstance();
        for (String sField : fieldsMapping.keySet()) {
            String jsonField = fieldsMapping.get(sField);
            sObj.put(sField, data.get(jsonField));
        }
        return sObj;
    }
    
    
}