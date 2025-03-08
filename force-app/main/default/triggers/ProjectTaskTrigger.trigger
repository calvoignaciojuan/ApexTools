trigger ProjectTaskTrigger on Project_Task__c (after insert, after update, after delete, after undelete) {

if(Trigger.isAfter){
  if(Trigger.isUpdate){
    ProjectTaskTriggerHandler.onAfterUpdate(Trigger.oldMap,Trigger.newMap);
  }
  if(Trigger.isInsert){
    ProjectTaskTriggerHandler.onAfterInsert(Trigger.newMap);
  }
  if(Trigger.isDelete){
    ProjectTaskTriggerHandler.onAfterDelete(Trigger.oldMap);
  }
  if(Trigger.isUndelete){
    ProjectTaskTriggerHandler.onAfterUndelete(Trigger.newMap);
  }
}
}