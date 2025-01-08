# trigger framework

A lightweight Salesforce Apex trigger framework

[![codecov](https://codecov.io/github/anoble2020/triggerframework/graph/badge.svg?token=KRRXNJ9FM4)](https://codecov.io/github/anoble2020/triggerframework)
[![Salesforce CI](https://github.com/anoble2020/triggerframework/actions/workflows/build.yml/badge.svg)](https://github.com/anoble2020/triggerframework/actions/workflows/build.yml)

## Installation

Deploy this unlocked package directly using one of these methods:

1. **Package installer**:

[![Install Unlocked Package in a Sandbox](./images/button_install-in-sandbox-org.png)](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t6g000008StvuAAC)  [![Install Unlocked Package in Production](./images/button_install-in-production-org.png)](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t6g000008StvuAAC)

2. **sfdx CLI**:

   ```bash
   sf package install --package triggerframework@LATEST
   ```

## Background

Apex triggers are a powerful tool that can do great things when used correctly, but cause a lot of headache when used incorrectly. Triggers without structure can be messy. They can interfere with one another and cause huge performance and debugging problems. [[1]](#references)


## Benefits of trigger frameworks



* Improved separation of concerns - Logic is separated from execution, allowing developers to focus on writing trigger business logic without worrying about framework code.
* Increased modularity - Triggers are broken down into discrete, reusable components that can be easily maintained and updated independently.
* Facilitates extensibility - It's easy to add new trigger handlers to introduce new trigger functionality without disturbing existing logic.
* Promotes declarative programming - Developers configure trigger execution declaratively instead of imperatively coding triggering logic.
* Enforces best practices - Frameworks can enforce handling of bulkification, recursion prevention, testing, etc.
* Improved readability - Frameworks standardize how trigger code is organized and structured.
* Allows easier debugging - By funneling execution through a single dispatcher, debugging is simplified.
* Provides consistency - All triggers follow the same patterns across the org for easier long-term maintenance.
* Enables metadata-driven configuration - Trigger state can be configured through custom metadata types.

In summary, trigger frameworks not only make building robust trigger solutions easier, they enforce critical best practices that support long-term org health and trigger maintenance at scale.


## 


## Architecture Diagram


![framework](https://github.com/anoble2020/triggerframework/assets/80295790/f7868d48-ab34-49f1-8034-13f6ab030804)



## 


## Components


### Trigger

Triggers **must** **never contain any logic**, and in this framework should only contain one line of code (running the concrete handler).


#### Example


```apex
trigger ExampleTrigger on SObject (before insert, before update, before delete, after insert, after update, after delete, after undelete){
   TriggerDispatcher.run(new ExampleTriggerHandler());
}
```



### TriggerDispatcher

Defines the trigger dispatching architecture. Invokes the appropriate methods on the handler (ITriggerHandler) depending on the trigger context. Ensures all trigger contexts only execute once.


#### Example


```apex
public with sharing class TriggerDispatcher {

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
```



### ITriggerHandler

Defines the interface for trigger handlers. Ensures processing of all possible trigger contexts, even if there is no code executed in a particular context.


#### Example


```apex
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
```



### TriggerHandler

Virtual base class from which you can inherit methods from in all of your concrete trigger handlers. Included methods are context-specific and are automatically called when a trigger is executed.


#### Example


```apex
public virtual class TriggerHandler implements ITriggerHandler {
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
```



### Concrete Handlers

Implemented on each object for which you create a Trigger. Concrete handlers should still ideally contain **no logic**. Includes logic to disable the trigger based on a boolean flag (which is evaluated in TriggerDispatcher).


#### Example


```apex
public with sharing class ExampleTriggerHandler extends TriggerHandler {

   public static boolean disableTrigger = false;

   public override Boolean isDisabled() {
      return disableTrigger;
   }

   public override void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
      ExampleUtility.sendEmail((List<SObject>);           
   }
...
}
```



### TriggerUtility

Use of the TriggerUtility is optional, though it is recommended to improve performance, readability, and to control trigger flow.


#### Methods



* **runTrigger**: Checks Trigger_Settings__mdt custom metadata records to determine if a trigger is disabled or not. This gets checked in row 11 of _TriggerDispatcher_
* **hasFieldsChanged**: Accepts a map of new and old objects (equivalent to Trigger.newMap and Trigger.oldMap), as well as a list of Strings of API field names for which to check for changes. Returns true if values in referenced field list have changed
* **getUpdatedRecords**: Similar signature and functionality as _hasFieldsChanged_, but returns a list of SObjects for which field values (from the list of fields) have changed
* **getUpdatedMap**: Identical to _getUpdatedRecords_, except return value is Map&lt;Id, SObject>


### Helper and Utility Classes

Classes where all of your logic and processing should live. Typically you would only have a helper class, but if you have a large amount of related functionality that is shared across objects you may wish to abstract it to a utility class which can be called from the helper or handler classes. See _ExampleTriggerHandler_ in the
[Concrete Handlers](#concrete-handlers) example above for how these classes can be called from a handler.


## 

### Bypassing Methods

The framework provides functionality to temporarily bypass specific trigger methods during execution. This is useful for preventing recursive trigger execution or skipping certain logic in specific scenarios.

#### Available Methods

- **bypassMethod(String methodName)**: Prevents a specific method from executing
- **unbypassMethod(String methodName)**: Removes the bypass for a specific method
- **resetBypassedMethods()**: Clears all method bypasses
- **runMethod(List<SObject> records)**: Checks if a method should run based on bypass status

#### Example Usage

```apex
public class AccountTriggerHelper {
    public static void updateContacts(List<Account> accounts) {
        // Check if method should run
        if (!TriggerUtility.runMethod(accounts)) { return; }
        
        // Method logic here
    }
}

// To bypass the method from another class:
TriggerUtility.bypassMethod('AccountTriggerHelper.updateContacts');

// To remove the bypass:
TriggerUtility.unbypassMethod('AccountTriggerHelper.updateContacts');

// To clear all bypassed methods:
TriggerUtility.resetBypassedMethods();
```

The bypass functionality uses the full method name (ClassName.methodName) to identify which methods to skip. The framework automatically detects the calling method name through stack trace analysis, so you don't need to manually specify it in the `runMethod()` check.


## Implementation Guide



1. Ensure ITriggerHandler, TriggerDispatcher, and TriggerHandler classes are deployed to your org (in that order).
2. Create an instance handler class which extends TriggerHandler. Have a look at the ExampleTriggerHandler class in /examples for a working example.
3. Add logic for the methods you require. For example, if you want some beforeInsert logic, add it to the beforeInsert method in your instance handler class.
4. Create a trigger for your object which fires on events (before/after insert, before/after update, before/after delete, etc.)
5. Call the static TriggerDispatcher.run() method from your trigger. Pass it a new instance of your instance handler class as an argument.
6. Lastly, create a Trigger_Settings__mdt custom metadata record with a MasterLabel matching the object API name (set Is_Trigger_Deactivated__c to **true** to disable). To elaborate on why the MasterLabel is used, it is because the DeveloperName cannot end in "__c", which will be the suffix for any custom object. The MasterLabel field does not have the same constraint.


## 


## References

[1] - [Apex Hours - Trigger Framework in Salesforce](https://www.apexhours.com/trigger-framework-in-salesforce/#:~:text=Why%20Trigger%20Framework&text=Ensures%20triggers%20are%20consistently%20handled,for%20simple%20Triggers%20and%20handlers.&text=Allow%20you%20to%20enforce%20different,mid%20process.)

