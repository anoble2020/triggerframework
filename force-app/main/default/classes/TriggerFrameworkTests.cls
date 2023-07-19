@isTest
private class TriggerFrameworkTests {

    @isTest
    static void testAllContexts() {
        Map<Id,SObject> testMap = new Map<Id, SObject>();
        TriggerHandler handler = new TriggerHandler();

        Test.startTest();
        handler.beforeInsert(testMap.values());
        handler.afterInsert(testMap);
        handler.beforeUpdate(testMap, testMap);
        handler.afterUpdate(testMap, testMap);
        handler.beforeDelete(testMap);
        handler.afterDelete(testMap);
        handler.afterUndelete(testMap);
        handler.isDisabled();
        Test.stopTest();
    }
}