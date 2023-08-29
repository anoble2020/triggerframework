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
      
      // Assert for different scenarios
      System.assertEquals(true, TriggerUtility.hasFieldsChanged(newMap, oldMap, new List<String>{'Name'}));
      
      System.assertEquals(false, TriggerUtility.hasFieldsChanged(newMap, oldMap, new List<String>{'Industry'}));
    }

    @isTest
    static void testGetUpdatedRecords() {
      // Create test data
      Account acc1 = new Account(Name='TestAccount1');
      Account acc2 = new Account(Name='TestAccount2');
      insert new List<Account>{acc1, acc2};
    
      Map<Id, Account> newMap = new Map<Id, Account>();
      newMap.put(acc1.Id, new Account(Id=acc1.Id, Name='New Name 1'));
      newMap.put(acc2.Id, new Account(Id=acc2.Id, Name='New Name 2'));
    
      Map<Id, Account> oldMap = new Map<Id, Account>();
      oldMap.put(acc1.Id, acc1);
      oldMap.put(acc2.Id, acc2);
    
      // Call method and assert result
      List<Account> updatedList = TriggerUtility.getUpdatedRecords(newMap, oldMap, new List<String>{'Name'});
      System.assertEquals(2, updatedList.size());
    }
    
    // Test getUpdatedIds method
    @isTest 
    static void testGetUpdatedIds() {
      // Create test data
      Account acc1 = new Account(Name='TestAccount1');
      Account acc2 = new Account(Name='TestAccount2');
      insert new List<Account>{acc1, acc2};
    
      Map<Id, Account> newMap = new Map<Id, Account>();
      newMap.put(acc1.Id, new Account(Id=acc1.Id, Name='New Name 1'));
      newMap.put(acc2.Id, new Account(Id=acc2.Id, Name='New Name 2'));
    
      Map<Id, Account> oldMap = new Map<Id, Account>();
      oldMap.put(acc1.Id, acc1);
      oldMap.put(acc2.Id, acc2);
      
      // Call method and assert result
      Set<Id> updatedIds = TriggerUtility.getUpdatedIds(newMap, oldMap, new List<String>{'Name'});
      System.assertEquals(2, updatedIds.size());  
    }
}