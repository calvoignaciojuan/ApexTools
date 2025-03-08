public with sharing class ChildTriggerHandler {
  
    public static void refreshParentHours(List<Child__c> oldChildList, List<Child__c> newChildList ){      
      system.debug('-----------------------------------------    refreshParentHours   BEGIN');
      Map<Id, Double> parentId_incrementalHoursMap = new Map<Id, Double>();

      //if there is oldChild updated I need to substract them from the incremental        
      if( oldChildList != null ){      
        system.debug('----------   there is old child: ' + oldChildList.size());  
        for(Child__c eachOldChild : oldChildList){
          Id parentId = eachOldChild.Parent__c;
          if( parentId != null ){   
            Double actualHours; 
            if(parentId_incrementalHoursMap.containsKey(parentId)){
              actualHours = parentId_incrementalHoursMap.get(parentId);
            }else{
              actualHours = 0;               
            }
            parentId_incrementalHoursMap.put(parentId, actualHours - eachOldChild.Hours__c);
          }
        }
      }

      //if the is newChild I need to add them from the incremental
      if( newChildList != null){     
        system.debug('----------   there is new child: ' + newChildList.size());    
        for(Child__c eachNewChild : newChildList){
          Id parentId = eachNewChild.Parent__c;
          if( parentId != null ){
            Double actualHours; 
            if(parentId_incrementalHoursMap.containsKey(parentId)){
              actualHours = parentId_incrementalHoursMap.get(parentId);
            }else{
              actualHours = 0;               
            }
            parentId_incrementalHoursMap.put(parentId, actualHours + eachNewChild.Hours__c);
          }
        }
      }
      
      //query the parents of the childList to update their total hour field
      if( !parentId_incrementalHoursMap.keySet().isEmpty() ){
        system.debug('----------   querying parents to update them'); 
        Map<Id, Parent__c> parentListToUpdate = new Map<Id, Parent__c>([Select Id, Total_Hours_in_related_child__c  from Parent__c where Id in : parentId_incrementalHoursMap.keySet()]);
        
        for(Parent__c eachParentToUpdate : parentListToUpdate.values()){
          eachParentToUpdate.Total_Hours_in_related_child__c  += parentId_incrementalHoursMap.get(eachParentToUpdate.Id);
        }       
        if( !parentListToUpdate.isEmpty() ){
          system.debug('-----------------------------------------    updating parent');
          update parentListToUpdate.values();
        }
      }
      system.debug('-----------------------------------------    refreshParentHours   END');
    }

}