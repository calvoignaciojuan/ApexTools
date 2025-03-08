public with sharing class tech {
  
// 1_
// There is a custom object called Project__c and it has many Task__c related to it, in Task__c object there is a field called Hours__c and in the Project__c object there is a field called Total_Hours__c. 
// Write a trigger that when a Task is inserted, updated or deleted, automatically update Total_Hours__c field on the Project parent Object.
// Tip:  procesamiento en base de datos, forma de calcular cosas
 
 trigger TaskTrigger on Task__c(after insert){
    if(Trigger.isAfter){
      if(Trigger.isInsert){
        TaskTriggerHandler.afterInsert(Trigger.new);
      }
    }
 }

 public class TaskTriggerHandler{
    public static void afterInsert(List<Task__c> newTaskList){
      Set<Id> projectsIdSet = new Set<Id>();
      if(!newTaskList.isEmpty()){
        for(Task__c eachTask : newTaskList){
          projectsIdSet.add(eachTask.Project__c);
        }        
      }
      if(!projectsIdSet.isEmpty()){
        Map<Id,Project__c> projectsToUpdateMap = Map<Id,Project__c>([select id, Total_Hours__c from Project__c where Id in :projectsIdSet]);
        if(!projectsToUpdateMap.values().isEmpty()){
          for(Task__c eachTask : newTaskList){
            projectsToUpdateMap.get(eachTask.Project__c).Total_Hours__c = projectsToUpdateMap.get(eachTask.Project__c).Total_Hours__c + eachTask.Hours__c;
          }
          update projectsToUpdateMap.values();
        }
      }
    }
 }


   //BEST solution

   trigger TaskTrigger on Task__c (after insert, after update, after delete, after undelete) {
    Map<Id, Double> projectHourChanges = new Map<Id, Double>();

    // Calculate changes for Insert, Update, and Undelete
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Task__c task : Trigger.new) {
            if (task.Project__c != null) {
                Double currentHours = projectHourChanges.containsKey(task.Project__c) ? projectHourChanges.get(task.Project__c) : 0.0;
                projectHourChanges.put(task.Project__c, currentHours + (task.Hours__c != null ? task.Hours__c : 0.0));
            }
        }
    }

    // Calculate changes for Update and Delete (Subtract old values)
    if (Trigger.isUpdate || Trigger.isDelete) {
        for (Task__c task : Trigger.old) {
            if (task.Project__c != null) {
                Double currentHours = projectHourChanges.containsKey(task.Project__c) ? projectHourChanges.get(task.Project__c) : 0.0;
                projectHourChanges.put(task.Project__c, currentHours - (task.Hours__c != null ? task.Hours__c : 0.0));
            }
        }
    }

    if (!projectHourChanges.isEmpty()) {
        // Fetch current Total_Hours__c for affected projects
        Map<Id, Project__c> projectsToUpdate = new Map<Id, Project__c>(
            [SELECT Id, Total_Hours__c FROM Project__c WHERE Id IN :projectHourChanges.keySet()]
        );

        List<Project__c> updates = new List<Project__c>();

        for (Id projectId : projectHourChanges.keySet()) {
            if (projectsToUpdate.containsKey(projectId)) {
                Project__c project = projectsToUpdate.get(projectId);
                project.Total_Hours__c = (project.Total_Hours__c != null ? project.Total_Hours__c : 0) + projectHourChanges.get(projectId);
                updates.add(project);
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }
}
 
 //2_
 // ----- Code Snippet Notes -----
 // MyCustomObject__c custom object definition:
 //    Recalculate__c Checkbox
 //    Value1__c Numeric
 //    Value2__c Numeric
 //    Totals__c Numeric
 
 <apex:page controller="MyPageController">
   <apex:form>
       <apex:commandButton value="Recalculate" action="{!recalculateTotals}" />
   </apex:form>
 </apex:page>
 
 public class MyPageController {
     public static void recalculateTotals() {
         List<MyCustomObject__c> myCustomObjects = [SELECT Id, Totals__c, Recalculate__c, Value1__c FROM MyCustomObject__c];
         for (MyCustomObject__c obj : myCustomObjects ) {
             if (obj.Recalculate__c) {
                 obj.Recalculate__c = false;
                 obj.Totals__c = obj.Value1__c + obj.Value2__c;
                 update obj;
             }
         }
     }
 }	
 




}