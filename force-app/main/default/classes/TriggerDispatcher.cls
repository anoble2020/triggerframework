public with sharing class TriggerDispatcher {

    /**
     * @param handler
     */
    public static void run(ITriggerHandler handler) {
        if (handler.isDisabled() || TriggerUtility.runTrigger(getName())) {
            return;
        }

        if (Trigger.isBefore) {
            runBefore(handler);
        }

        if (Trigger.isAfter) {
            runAfter(handler);
        }
    }

    /**
     * @param handler
     */
    static void runBefore(ITriggerHandler handler) {
        if (Trigger.isInsert) {
            handler.beforeInsert(trigger.new);
        }

        if (Trigger.isUpdate) {
            handler.beforeUpdate(trigger.newMap, trigger.oldMap);
        }

        if (Trigger.isDelete) {
            handler.beforeDelete(trigger.oldMap);
        }
    }

    /**
     * @param handler
     */
    static void runAfter(ITriggerHandler handler) {
        if (Trigger.isInsert) {
            handler.afterInsert(Trigger.newMap);
        }

        if (Trigger.isUpdate) {
            handler.afterUpdate(trigger.newMap, trigger.oldMap);
        }

        if (trigger.isDelete) {
            handler.afterDelete(trigger.oldMap);
        }

        if (trigger.isUndelete) {
            handler.afterUndelete(trigger.oldMap);
        }
    }

    static SObjectType getType() {
        if (Trigger.new == null) {
            return Trigger.old.getSObjectType();
        } else {
            return Trigger.new.getSObjectType();
        }
    }

    static String getName() {
        return getType().getDescribe().getName();
    }
}