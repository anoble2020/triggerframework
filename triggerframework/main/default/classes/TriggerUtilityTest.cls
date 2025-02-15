@IsTest
public with sharing class TriggerUtilityTest {

  @isTest
  static void testHasFieldsChanged() {
    Account acc1 = new Account(Name='TestAccount1');
    Account acc2 = new Account(Name='TestAccount2');
    insert new List<Account>{acc1, acc2};
  
    // Create new and old maps with test data
    Map<Id, Account> newMap = new Map<Id, Account>{
        acc1.Id => new Account(Id=acc1.Id,Name='New Name')
    };
  
    Map<Id, Account> oldMap = new Map<Id, Account>{
        acc1.Id => new Account(Id=acc1.Id,Name='Old Name')
    };
  
    System.assertEquals(true, TriggerUtility.hasFieldsChanged(newMap, oldMap, new List<String>{'Name'}));
    System.assertEquals(false, TriggerUtility.hasFieldsChanged(newMap, oldMap, new List<String>{'Industry'}));
  }

  @isTest
  static void testGetUpdatedRecords() {
    Account acc1 = new Account(Name='TestAccount1');
    Account acc2 = new Account(Name='TestAccount2');
    insert new List<Account>{acc1, acc2};
  
    Map<Id, Account> newMap = new Map<Id, Account>();
    newMap.put(acc1.Id, new Account(Id=acc1.Id, Name='New Name 1'));
    newMap.put(acc2.Id, new Account(Id=acc2.Id, Name='New Name 2'));
  
    Map<Id, Account> oldMap = new Map<Id, Account>();
    oldMap.put(acc1.Id, acc1);
    oldMap.put(acc2.Id, acc2);
  
    List<Account> updatedList = TriggerUtility.getUpdatedRecords(newMap, oldMap, new List<String>{'Name'});
    System.assertEquals(2, updatedList.size());
  }
  
  @isTest 
  static void testGetUpdatedIds() {
    Account acc1 = new Account(Name='TestAccount1');
    Account acc2 = new Account(Name='TestAccount2');
    insert new List<Account>{acc1, acc2};
  
    Map<Id, Account> newMap = new Map<Id, Account>();
    newMap.put(acc1.Id, new Account(Id=acc1.Id, Name='New Name 1'));
    newMap.put(acc2.Id, new Account(Id=acc2.Id, Name='New Name 2'));
  
    Map<Id, Account> oldMap = new Map<Id, Account>();
    oldMap.put(acc1.Id, acc1);
    oldMap.put(acc2.Id, acc2);
    
    Set<Id> updatedIds = TriggerUtility.getUpdatedIds(newMap, oldMap, new List<String>{'Name'});
    System.assertEquals(2, updatedIds.size());  
  }

  @isTest
  static void testGetUpdatedMapOverload() {
      Account acc1 = new Account(Name='TestAccount1');
      insert acc1;
      
      Map<Id, Account> newMap = new Map<Id, Account>{
          acc1.Id => new Account(Id=acc1.Id, Name='New Name', Industry='Technology')
      };
      Map<Id, Account> oldMap = new Map<Id, Account>{
          acc1.Id => new Account(Id=acc1.Id, Name='Old Name', Industry='Banking')
      };
      
      Map<Id, SObject> result = TriggerUtility.getUpdatedMap(newMap, oldMap, new List<String>{'Name'});
      System.assertEquals(1, result.size(), 'Should return one updated record');
  }

  @isTest
  static void testEmptyScenarios() {
      // Test empty maps
      Map<Id, SObject> emptyMap = new Map<Id, SObject>();
      List<String> fields = new List<String>{'Name'};
      
      // Should return empty list
      List<SObject> emptyList = TriggerUtility.getUpdatedRecords(emptyMap, emptyMap, fields);
      System.assertEquals(0, emptyList.size(), 'Should return empty list');
      
      // Should return empty set
      Set<Id> emptySet = TriggerUtility.getUpdatedIds(emptyMap, emptyMap, fields);
      System.assertEquals(0, emptySet.size(), 'Should return empty set');
      
      // Should return false
      System.assertEquals(false, TriggerUtility.hasFieldsChanged(emptyMap, emptyMap, fields), 'Should return false for empty maps');
  }

  @isTest
  static void testFieldChangesWithAndLogic() {
      Account acc1 = new Account(Name='TestAccount1', Industry='Tech');
      insert acc1;
      
      Map<Id, Account> newMap = new Map<Id, Account>{
          acc1.Id => new Account(Id=acc1.Id, Name='New Name', Industry='Banking')
      };
      Map<Id, Account> oldMap = new Map<Id, Account>{
          acc1.Id => new Account(Id=acc1.Id, Name='Old Name', Industry='Tech')
      };
      
      Boolean result = TriggerUtility.hasFieldsChanged(
          newMap, 
          oldMap, 
          new List<String>{'Name', 'Industry'}, 
          true
      );
      System.assertEquals(true, result, 'Both fields changed, should return true with AND logic');
      
      newMap.get(acc1.Id).Industry = 'Tech';
      result = TriggerUtility.hasFieldsChanged(
          newMap, 
          oldMap, 
          new List<String>{'Name', 'Industry'}, 
          true
      );
      System.assertEquals(false, result, 'Only one field changed, should return false with AND logic');
  }

  @isTest
  static void testMethodBypassFunctionality() {
      List<Account> accounts = new List<Account>{
          new Account(Name = 'Test1'),
          new Account(Name = 'Test2')
      };
      
      System.assertEquals(true, TriggerUtility.runMethod(accounts), 
          'Should return true for non-empty list without bypassed methods');
      
      System.assertEquals(false, TriggerUtility.runMethod(new List<Account>()), 
          'Should return false for empty list');

      String methodName = 'TriggerUtilityTest.testMethodBypassFunctionality';
      
      TriggerUtility.bypassMethod(methodName);
      System.assertEquals(false, TriggerUtility.runMethod(accounts), 
          'Should return false for bypassed method');
          
      TriggerUtility.unbypassMethod(methodName);
      System.assertEquals(true, TriggerUtility.runMethod(accounts), 
          'Should return true after removing bypass');
          
      TriggerUtility.bypassMethod(methodName);
      TriggerUtility.resetBypassedMethods();
      System.assertEquals(true, TriggerUtility.runMethod(accounts), 
          'Should return true after resetting bypassed methods');
  }
}