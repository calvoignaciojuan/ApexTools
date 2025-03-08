trigger AccountTrigger on Account (after update) {
  if(Trigger.isUpdate){
    if(Trigger.isAfter){
      AccountHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
  }
}