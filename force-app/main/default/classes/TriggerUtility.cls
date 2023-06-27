public with sharing class TriggerUtility {

    private static Map<String, Boolean> sObjTriggerSettingMap = new Map<String, Boolean>();

    public static Boolean runTrigger(String objectName) {
        if(!sObjTriggerSettingMap.keySet().isEmpty() && sObjTriggerSettingMap.containsKey(objectName)){
            return sObjTriggerSettingMap.get(objectName);
        } else {
            for (Trigger_Settings__mdt settings : Trigger_Settings__mdt.getAll().values()) {
                if(settings.DeveloperName == objectName){
                    sObjTriggerSettingMap.put(objectName, settings.Is_Trigger_Deactivated__c);
                    return settings.Is_Trigger_Deactivated__c;
                }
            }
        }
        sObjTriggerSettingMap.put(objectName,false);
        return false;
    }

    public static Boolean hasFieldsChanged(Map<Id, SObject> newMap, Map<Id, SObject> oldMap, List<String> fields, Boolean isAnd) {
        for (Id sId : newMap.keySet()) {
            return isChanged(newMap, oldMap, fields, isAnd, sId);
        }
        return isAnd;
    }

    public static Boolean hasFieldsChanged(Map<Id, SObject> newMap, Map<Id, SObject> oldMap, List<String> fields) {
        return hasFieldsChanged(newMap, oldMap, fields, false);
    }

    public static List<SObject> getUpdatedRecords(Map<Id, SObject> newMap, Map<Id, SObject> oldMap, List<String> fields) {
        Map<Id, SObject> updatedMap = getUpdatedMap(newMap, oldMap, fields, false);
        if (!updatedMap.isEmpty()) {
            return updatedMap.values();
        }
        return new List<SObject>();
    }

    public static Set<Id> getUpdatedIds(Map<Id, SObject> newMap, Map<Id, SObject> oldMap, List<String> fields) {
        Map<Id, SObject> updatedMap = getUpdatedMap(newMap, oldMap, fields, false);
        if (!updatedMap.isEmpty()) {
            return updatedMap.keySet();
        }
        return new Set<Id>();
    }

    public static Map<Id, SObject> getUpdatedMap(Map<Id, SObject> newMap, Map<Id, SObject> oldMap, List<String> fields) {
        return getUpdatedMap(newMap, oldMap, fields, false);
    }

    private static Map<Id, sObject> getUpdatedMap(Map<Id, SObject> newMap, Map<Id, SObject> oldMap, List<String> fields, Boolean isAnd) {
        Map<Id, sObject> changeRecordMap = new Map<Id, SObject>();
        for (Id sId : newMap.keySet()) {
            if (isChanged(newMap, oldMap, fields, isAnd, sId)) {
                changeRecordMap.put(sId, newMap.get(sId));
            }
        }
        return changeRecordMap;
    }

    public static Boolean isChanged(Map<Id, SObject> newMap, Map<Id, SObject> oldMap, List<String> fields, Boolean isAnd, Id objectId) {
        for (String field : fields) {
            if (newMap.get(objectId).get(field) != oldMap.get(objectId).get(field)) {
                if (!isAnd) {
                    return true;
                }
            } else if (isAnd) {
                return false;
            }
        }
        return isAnd;
    }
}