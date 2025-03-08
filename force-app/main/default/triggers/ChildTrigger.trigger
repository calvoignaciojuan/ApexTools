trigger ChildTrigger on Child__c (after insert, after update, after delete, after undelete) {
  
  if(Trigger.isAfter){
    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUndelete){      
      ChildTriggerHandler.refreshParentHours(Trigger.old, Trigger.new);
    }  
  }
}