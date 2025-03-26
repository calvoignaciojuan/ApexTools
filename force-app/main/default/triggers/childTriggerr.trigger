// There is a custom object called Project__c and it has many Task__c related to it, in Task__c object there is a field called Hours__c 
// and in the Project__c object there is a field called Total_Hours__c
// write a trigger that when a Task is inserted, updated or deleted, automatically update the Total_Hours__c field in Project__c parent Object.


//Child -> parent

trigger childTriggerr on child__c (after insert, after update, after delete) {
  if(Trigger.isAfter){
    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete){
      ChildTriggerrHandler.updateTotalHoursOnParent(Trigger.newMap, Trigger.oldMap);
    }
  }

}