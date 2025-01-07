public with sharing class ExampleTriggerHandler extends TriggerHandler{

    //Implement only the trigger contexts that you care about. Cast newList to the concrete object of the trigger.
    public override void beforeInsert(List<SObject> newList){
        ExampleTriggerHelper.exampleMethod((List<SObject>) newList);
    }

    public override void afterInsert(Map<Id, SObject> newMap){
        ExampleTriggerHelper.exampleMethod((List<SObject>) newMap.values());
    }

    public override void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        //Use functions in TriggerUtility to only execute logic if a specific field was updated.
        ExampleTriggerHelper.exampleMethod((List<SObject>) TriggerUtility.getUpdatedRecords(newMap, oldMap, new List<String>{
            'Example_Field__c'
        }), (Map<Id,SObject>) oldMap);
    }
}