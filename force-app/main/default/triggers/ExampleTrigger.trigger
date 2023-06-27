trigger ExampleTrigger on SObject (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new ExampleTriggerHandler());
}