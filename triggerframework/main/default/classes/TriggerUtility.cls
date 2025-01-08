public with sharing class TriggerUtility {

    @TestVisible private static List<String> bypassedMethods = new List<String>();
    @TestVisible private static Map<String, Boolean> sObjTriggerSettingMap = new Map<String, Boolean>();

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

    public static MethodDetails getMethodDetails() {
        try { throw new DmlException(); }
        catch (DmlException e)
        {
            List<String> stackTrace = e.getStackTraceString().split('\n');
            String base = stackTrace[2].substringAfter('.').substringBefore(':');

            MethodDetails md = new MethodDetails();
            md.className = base.substringBefore('.');
            md.methodName = base.substringAfter('.');
            md.fullName = base;
            md.stackTrace = e.getStackTraceString();
            return md;
        }
    }

    public static Boolean runMethod(List<SObject> records){
        if(records.isEmpty()){
            return false;
        }

        if(bypassedMethods.contains(getMethodDetails().fullName)){
            return false;
        }

        return true;
    }

    public static void bypassMethod(String methodName){
        System.debug('[triggerframework] Bypassing method: ' + methodName);
        bypassedMethods.add(methodName);
    }

    public static void unbypassMethod(String methodName){
        if(bypassedMethods.contains(methodName)){
            bypassedMethods.remove(bypassedMethods.indexOf(methodName));
        }
    }

    public static void resetBypassedMethods(){
        bypassedMethods.clear();
    }

    public class MethodDetails {
        public String className;
        public String methodName;
        public String fullName;
        public String stackTrace;
    }
}