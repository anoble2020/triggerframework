@isTest
private class TriggerFrameworkTests {

    public class MockTriggerHandler extends TriggerHandler {}

    @isTest
    static void test_handler() {
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

    @isTest
    static void test_dispatcher() {
        Test.startTest();
        TriggerDispatcher.skipChecks = true;
        TriggerDispatcher.run(new MockTriggerHandler());
        Test.stopTest();
    }
}