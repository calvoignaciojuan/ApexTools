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
private class ProjectTaskTriggerTest {

    @TestSetup
    static void makeData(){
      // I create 1 parent
      Project__c project = new Project__c();
      project.Name = 'Project 1';
      insert project;

      // and 2 children
      List<Project_Task__c> pTaskList = new List<Project_Task__c>();
      Project_Task__c pTask1 = new Project_Task__c();
      pTask1.Name = 'Task1';
      pTask1.Hours__c = 10;
      pTask1.Project__c = project.id;
      pTaskList.add(pTask1);

      Project_Task__c pTask2 = new Project_Task__c();
      pTask2.Name = 'Task2';
      pTask2.Hours__c = 10;
      pTask2.Project__c = project.id;
      pTaskList.add(pTask2);

      insert pTaskList;
    }

    @isTest
    static void taskInsertionTest() {
      
      List<Project__c> pTaskList = [Select Id from Project__c where Name = 'Project 1'];
      Id parentId = pTaskList[0].Id;
      // I will insert third child
      Project_Task__c pTask3 = new Project_Task__c();
      pTask3.Name = 'Task3';
      pTask3.Hours__c = 10;
      pTask3.Project__c = parentId;

      Test.startTest();
      insert pTask3;
      Test.stopTest();

      pTaskList = [Select Id, Total_Hours__c from Project__c where Name = 'Project 1'];
      Decimal projectTotalHours = pTaskList[0].Total_Hours__c;

      pTaskList = [Select Id, Name, (Select id, Name from Project_Tasks__r) from Project__c where Name = 'Project 1'];
      for(Project__c p : pTaskList){
        system.debug('----------------------------    Project: ' + p.Name );
        for(Project_Task__c pT : p.Project_Tasks__r){
          system.debug('------------    Task: ' + pT.Name );
        }
      }
      System.assertEquals(30, projectTotalHours, 'the Total Hours should be 30');
    }

    @isTest
    static void taskUpdateTest(){

      //will query for task 2 and update the hours from 10 to 5
      List<Project_Task__c> pTaskList = [Select id, Hours__c from Project_Task__c where Name = 'Task 2'];
      pTaskList[0].Hours__c = 5;

      Test.startTest();
      update pTaskList;
      Test.stopTest();

      List<Project__c> projectList = [Select Id, Total_Hours__c from Project__c where Name = 'Project 1'];
      
      system.assertEquals(25, projectList[0].Total_Hours__c, 'Total Hours on the project should be 25');
    }

    @isTest
    static void taskDeletionTest(){
      //I will delete task 3
      List<Project_Task__c> pTaskList = [Select id, Hours__c from Project_Task__c where Name = 'Task 3'];

      Test.startTest();
      delete pTaskList[0];
      Test.stopTest();

      List<Project__c> projectList = [Select Id, Total_Hours__c from Project__c where Name = 'Project 1'];
      
      system.assertEquals(20, projectList[0].Total_Hours__c, 'Total Hours on the project should be 25');

    }

    @isTest  
    static void taskUndeletionTest(){
      List<Project_Task__c> taskList = [Select Id from Project_Task__c where Name = 'Task2'];
      delete taskList[0];

      List<Project__c> projectList = [Select Id, Total_Hours__c from Project__c where Name = 'Project 1'];      
      system.debug('after deletion of task 2, total Hours on parent: ' + projectList[0].Total_Hours__c); 

      Test.startTest();
      undelete taskList[0];
      Test.stopTest();

      projectList = [Select Id, Total_Hours__c from Project__c where Name = 'Project 1'];      
      system.debug('after undeletion of task 2, total Hours on parent: ' + projectList[0].Total_Hours__c); 

      system.assertEquals(20, projectList[0].Total_Hours__c, 'total hours should be 20 on the parent');

    }

  }