/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ChildTriggerTest {

    @TestSetup
    static void makeData(){
      
      system.debug('---------------------------------------------------------    Test Setup    ------------------------------------------------- BEGIN');
      Parent__c par1 = new Parent__c();
      par1.Name = 'par1';
      insert par1;
      
      List<Child__c> childList = new List<Child__c>();

      Child__c child1 = new Child__c();
      child1.Name = 'child1';
      child1.Hours__c = 10;
      child1.Parent__c = par1.Id;
      childList.add(child1);

      Child__c child2 = new Child__c();
      child2.Name = 'child2';
      child2.Hours__c = 10;
      child2.Parent__c = par1.Id;
      childList.add(child2); 

      Child__c child4 = new Child__c();
      child4.Name = 'child4';
      child4.Hours__c = 10;
      child4.Parent__c = par1.Id;
      childList.add(child4); 

      insert childList;

      delete child4;

      system.debug('---------------------------------------------------------    Test Setup    ------------------------------------------------- END');
    }

    @isTest
    static void childInsertionTest() {
      system.debug('---------------------------------------------------------    childInsertionTest    ------------------------------------------------- BEGIN');
      // a third child is inserted
      List<Parent__c> parentList = [select Id, Total_Hours_in_related_child__c  from Parent__c where Name = 'par1'];
      Child__c child3 = new Child__c();
      child3.Name = 'Child3';
      child3.Hours__c = 10;
      child3.Parent__c = parentList[0].Id;      

      Test.startTest();
      insert child3;
      Test.stopTest();
      
      //verify the insertion
      parentList = [select Id, Total_Hours_in_related_child__c  from Parent__c where Name = 'par1'];
      System.assertEquals( 30 , parentList[0].Total_Hours_in_related_child__c, 'total ahours in the parent should be 30');
      system.debug('---------------------------------------------------------    childInsertionTest    ------------------------------------------------- END');
    }

    @isTest
    static void childUpdateTest() {

      system.debug('---------------------------------------------------------    childUpdateTest    ------------------------------------------------- BEGIN');
      List<Child__c> childrenToUpdate = new List<Child__c>();
      List<Child__c> childList = [select id, Hours__c from child__c where name = 'child1'];
      Child__c child1 = childList[0];
      child1.Hours__c = 5;
      childrenToUpdate.add(child1);
      
      childList = [select id, Hours__c from child__c where name = 'child2'];
      Child__c child2 = childList[0];
      child2.Hours__c = 5;
      childrenToUpdate.add(child2);

      Test.startTest();
      update childrenToUpdate;     
      Test.stopTest();

      List<Parent__c> parentList = [select Id, Total_Hours_in_related_child__c  from Parent__c where Name = 'par1'];
      System.assertEquals( 10 , parentList[0].Total_Hours_in_related_child__c, 'total hours in the parent should be 10');
      system.debug('---------------------------------------------------------    childUpdateTest    ------------------------------------------------- END');
    }

    @isTest
    static void childDeletionTest(){

      system.debug('---------------------------------------------------------    childDeletionTest    ------------------------------------------------- BEGIN');
      List<Child__c> childList = [select id, Hours__c from child__c where name = 'child1'];

      Test.startTest();
      delete childList[0];  // this should substract 10 from the parent
      Test.stopTest();

      List<Parent__c> parentList = [select Id, Total_Hours_in_related_child__c  from Parent__c where Name = 'par1'];
      System.assertEquals( 10 , parentList[0].Total_Hours_in_related_child__c, 'total hours in the parent should be 10');
      system.debug('---------------------------------------------------------    childDeletionTest    ------------------------------------------------- END');
    }

    @isTest
    static void childUndeletedTest(){

      system.debug('---------------------------------------------------------    childUndeletedTest    ------------------------------------------------- BEGIN');
      List<Child__c> childList = [select id, Hours__c from child__c where name = 'child4' ALL ROWS];

      Test.startTest();
      undelete childList[0];
      Test.stopTest();

      List<Parent__c> parentList = [select Id, Total_Hours_in_related_child__c  from Parent__c where Name = 'par1'];
      System.assertEquals( 30 , parentList[0].Total_Hours_in_related_child__c, 'total hours in the parent should be 30');
      system.debug('---------------------------------------------------------    childUndeletedTest    ------------------------------------------------- END');
    }
}