trigger ParentTriggerHandler on Parent__c (before insert) {

  TriggerExecutionTracker.executionCount ++;

  system.debug('ParentTriggerHandler is been executed for ' + TriggerExecutionTracker.executionCount + ' time/s');

  if(Trigger.isBefore){
    if(Trigger.isInsert){
      ParentTriggerHandler.beforeInsert(Trigger.new);
    }
  }
}