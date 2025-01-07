public with sharing class TriggerDispatcher {

    @TestVisible static Boolean skipChecks;

    /**
     * @param ITriggerHandler handler
    **/
    public static void run(ITriggerHandler handler) {
        if (handler == null || handler.isDisabled() || TriggerUtility.runTrigger(getName())) {
            return;
        }

        if (skipChecks || Trigger.isBefore) {
            runBefore(handler);
        }

        if (skipChecks || Trigger.isAfter) {
            runAfter(handler);
        }
    }

    /**
     * @param ITriggerHandler handler
    **/
    static void runBefore(ITriggerHandler handler) {
        if (skipChecks || Trigger.isInsert) {
            handler.beforeInsert(Trigger.new);
        }

        if (skipChecks || Trigger.isUpdate) {
            handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }

        if (skipChecks || Trigger.isDelete) {
            handler.beforeDelete(Trigger.oldMap);
        }
    }

    /**
     * @param ITriggerHandler handler
    **/
    static void runAfter(ITriggerHandler handler) {

        if (skipChecks || Trigger.isInsert) {
            handler.afterInsert(Trigger.newMap);
        }

        if (skipChecks || Trigger.isUpdate) {
            handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }

        if (skipChecks || Trigger.isDelete) {
            handler.afterDelete(Trigger.oldMap);
        }

        if (skipChecks || Trigger.isUndelete) {
            handler.afterUndelete(Trigger.oldMap);
        }
    }

    static SObjectType getType() {
        if(skipChecks){
            return Account.SObjectType;
        }
        else if (Trigger.new == null) {
            return Trigger.old.getSObjectType();
        } else {
            return Trigger.new.getSObjectType();
        }
    }

    static String getName() {
        return getType().getDescribe().getName();
    }
}