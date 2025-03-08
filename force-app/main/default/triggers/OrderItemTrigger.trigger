trigger OrderItemTrigger on Order_Item__c (after insert, after update, before update) {
  if(Trigger.isBefore){
    if(Trigger.isUpdate){
       //before Update
      OrderItemTriggerHandler.beforeUpdate(Trigger.new);
    }
  }
  if(Trigger.isAfter){
    if(Trigger.isInsert){
      OrderItemTriggerHandler.afterInsert(Trigger.new);
    }
    if(Trigger.isUpdate){
      OrderItemTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
  }
}