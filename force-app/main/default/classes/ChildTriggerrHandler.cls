public with sharing class ChildTriggerrHandler {

  // I will assume  that Hours field always changed 
  public static void updateTotalHoursOnParent(Map<Id,Child__c> newMap, Map<Id,Child__c> oldMap ){
    
    map<Id, decimal> totalHoursIncrementalChanges = new map<Id, decimal>();

    if(newMap != null){
      for( Child__c eachChild : newMap.values()){
        Id parentId = eachChild.Parent__c;
        if(parentId != null){
          if(totalHoursIncrementalChanges.containsKey(parentId)){
            totalHoursIncrementalChanges.put(parentId, totalHoursIncrementalChanges.get(parentId) + eachChild.Hours__c);
          }else{
            totalHoursIncrementalChanges.put(parentId, 0 + eachChild.Hours__c);
          }
        }
      }
    }

    if(oldMap != null){
      for( Child__c eachChild : oldMap.values()){
        Id parentId = eachChild.Parent__c;
        if(parentId != null){
          if(totalHoursIncrementalChanges.containsKey(parentId)){
            totalHoursIncrementalChanges.put(parentId, totalHoursIncrementalChanges.get(parentId) - eachChild.Hours__c);
          }else{
            totalHoursIncrementalChanges.put(parentId, 0 - eachChild.Hours__c);
          }
        }
      }
    }

    List<Parent__c> parentList;
    if(! totalHoursIncrementalChanges.keySet().isEmpty() ){
      parentList = [Select Id, Total_Hours_in_related_child__c from Parent__c where Id in : totalHoursIncrementalChanges.keySet()];

      for( Parent__c eachParent : parentList){
        eachParent.Total_Hours_in_related_child__c = eachParent.Total_Hours_in_related_child__c + totalHoursIncrementalChanges.get(eachParent.Id);
      }

      if(!parentList.isEmpty()){
        update parentList;
      }
    }
  }

}