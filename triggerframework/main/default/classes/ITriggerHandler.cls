public interface ITriggerHandler {

    void beforeInsert(List<SObject> newItems);

    void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);

    void beforeDelete(Map<Id, SObject> oldMap);

    void afterInsert(Map<Id, SObject> newMap);

    void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);

    void afterDelete(Map<Id, SObject> oldMap);

    void afterUndelete(Map<Id, SObject> oldMap);

    boolean isDisabled();

}