# triggerframework

## Background

Apex triggers are a powerful tool that can do great things when used correctly, but cause a lot of headache when used incorrectly. Triggers without structure can be messy. They can interfere with one another and cause huge performance and debugging problems. 

<p id="gdcalert1" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: undefined internal link (link text: "[1]"). Did you generate a TOC with blue links? </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert2">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>

[[1]](#heading=h.6nv93jn11jkl)


## Benefits of trigger frameworks



* Removing trigger logic from the trigger makes unit testing and maintenance much easier.
* Standardizing triggers means all of your triggers work in a consistent way.
* A single trigger per object gives full control over order of execution.
* Prevention of trigger recursion.
* It makes it easy for large teams of developers to work across an org with lots of triggers.


## 


## Architecture Diagram



<p id="gdcalert2" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image1.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert3">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image1.png "image_tooltip")



## 


## Components


### Trigger

Triggers **must** **never contain any logic**, and in this framework should only contain one line of code (running the instance handler).


#### Example


```
trigger WorkOrderTrigger on WorkOrder(before insert, before update, before delete, after insert, after update, after delete, after undelete){
   TriggerDispatcher.Run(new WorkOrderTriggerHandler());
}
```



### TriggerDispatcher

Defines the trigger dispatching architecture. Invokes the appropriate methods on the handler (ITriggerHandler) depending on the trigger context.


#### Example


```
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


```
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

Abstract base class from which you can inherit methods from in all of your instance trigger handlers. Included methods are context-specific and are automatically called when a trigger is executed.


#### Example


```
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
```



### Instance Handlers (ex. ExampleTriggerHandler)

Implemented on each object for which you create a Trigger. Instance handlers should still contain **no logic**. Includes logic to disable the trigger based on a boolean flag (which gets checked in TriggerDispatcher).


#### Example


```
public with sharing class ExampleTriggerHandler extends TriggerHandler {
   public static boolean disableTrigger = false;
   public override Boolean isDisabled() {
      return disableTrigger;
   }

   public override void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
      ExampleUtility.sendEmail((List<WorkOrder>);           
   }
...
}
```



### TriggerUtility

Use of the TriggerUtility is optional, though it is recommended to improve performance, readability, and to control trigger disabling.


#### Methods



* **runTrigger**: Checks Trigger_Settings__mdt custom metadata records to determine if a trigger is disabled or not. This gets checked in row 11 of _TriggerDispatcher_
* **hasFieldsChanged**: Accepts a map of new and old objects (equivalent to Trigger.newMap and Trigger.oldMap), as well as a list of Strings of API field names for which to check for changes. Returns true if values in referenced field list have changed
* **getUpdatedRecords**: Similar signature and functionality as _hasFieldsChanged_, but returns a list of SObjects for which field values (from the list of fields) have changed
* **getUpdatedMap**: Identical to _getUpdatedRecords_, except return value is Map&lt;Id, SObject>


### Helper and Utility Classes

Classes where all of your logic and processing should live. Typically you would only have a helper class, but if you have a large amount of related functionality you may wish to abstract it to a utility class which can be called from the helper or handler classes. See _WorkOrderTriggerHandler_ in the 

<p id="gdcalert3" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: undefined internal link (link text: "Instance Handlers"). Did you generate a TOC with blue links? </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert4">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>

[Instance Handlers](#heading=h.p1swrgo554hb) example above for how these classes can be called from a handler.


## 


## Implementation Guide



1. Ensure ITriggerHandler, TriggerDispatcher, and TriggerHandler classes are deployed to your org (in that order).
2. Create an instance handler class (such as OpportunityTriggerHandler), which extends TriggerHandler. Have a look at the WorkOrderTriggerHandler class above for a working example.
3. Add logic for the methods you require. For example, if you want some beforeInsert logic, add it to the beforeInsert method in your instance handler class.
4. Create a trigger for your object which fires on all events (before/after insert, before/after update, before/after delete, etc.)
5. Call the static TriggerDispatcher.Run method from your trigger. Pass it a new instance of your instance handler class as an argument.
6. Lastly, create a Trigger_Settings__mdt custom metadata record with a MasterLabel matching the object API name, which also has the ‘Enabled’ field set to **true ** 

<p id="gdcalert4" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: undefined internal link (link text: "[2]"). Did you generate a TOC with blue links? </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert5">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>

[[2]](#heading=h.6nv93jn11jkl)


## 


## References

[1] - [Apex Hours - Trigger Framework in Salesforce](https://www.apexhours.com/trigger-framework-in-salesforce/#:~:text=Why%20Trigger%20Framework&text=Ensures%20triggers%20are%20consistently%20handled,for%20simple%20Triggers%20and%20handlers.&text=Allow%20you%20to%20enforce%20different,mid%20process.)

[2] - [Lightweight Trigger Framework](https://github.com/ChrisAldridge/Lightweight-Trigger-Framework)

