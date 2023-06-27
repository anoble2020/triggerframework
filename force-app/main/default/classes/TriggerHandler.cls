public abstract class TriggerHandler implements ITriggerHandler {
    public virtual void beforeInsert(List<sObject> newList) {
    }
    public virtual void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
    }
    public virtual void afterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
    }
    public virtual void beforeDelete(Map<Id, sObject> oldMap) {
    }
    public virtual void afterInsert(Map<Id, sObject> newMap) {
    }
    public virtual void afterDelete(Map<Id, sObject> oldMap) {
    }
    public virtual void afterUndelete(Map<Id, sObject> newMap) {
    }
    public virtual Boolean isDisabled(){
        return false;
    }
}