public with sharing class ParentTriggerHandler {
    
  public static void beforeInsert(List<Parent__c> newParentList){
    
    if(!newParentList.isEmpty()){
      for(Parent__c eachNewParent : newParentList){
        eachNewParent.Is_New_Record__c = false;
      }
    }    
  }
}