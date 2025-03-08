public with sharing class ProjectTaskTriggerHandler {
    public ProjectTaskTriggerHandler() {

    }

    public static void onAfterUpdate(Map<Id,Project_Task__c> oldTaskMap, Map<Id,Project_Task__c> newTaskMap){
      system.debug('----------------------------------------------    onAfterUpdate BEGIN');
       
      Map<Id,Project_Task__c> taskToProcess = getTasksThatChangeHours(oldTaskMap,newTaskMap);
      
      map<Id, Decimal> projectIdIncrementalHourChangeMap = calculateIncrementalHours(oldTaskMap, newTaskMap, taskToProcess);
      
      //update the total_hours field on the Project 
      updateTotalHoursFieldOnProject(projectIdIncrementalHourChangeMap);         
      
      system.debug('----------------------------------------------    onAfterUpdate END');
    }

    public static void onAfterInsert(Map<Id,Project_Task__c> newTaskMap){
      system.debug('----------------------------------------------    onAfterInsert BEGIN');
      
      Map<Id,Project_Task__c> taskToProcess = newTaskMap;
      
      map<Id, Decimal> projectIdIncrementalHourChangeMap = calculateIncrementalHours(null, newTaskMap, taskToProcess);
      
      //update the total_hours field on the Project 
      updateTotalHoursFieldOnProject(projectIdIncrementalHourChangeMap);      
      system.debug('----------------------------------------------    onAfterInsert END');
    }

    public static void onAfterDelete(Map<Id,Project_Task__c> oldTaskMap){
      system.debug('----------------------------------------------    onAfterDelete BEGIN');
      
      Map<Id,Project_Task__c> taskToProcess = oldTaskMap;
      
      map<Id, Decimal> projectIdIncrementalHourChangeMap = calculateIncrementalHours(oldTaskMap, null, taskToProcess);
      
      //update the total_hours field on the Project 
      updateTotalHoursFieldOnProject(projectIdIncrementalHourChangeMap);      
      system.debug('----------------------------------------------    onAfterDelete END');
    }

    public static void onAfterUndelete(Map<Id,Project_Task__c> newTaskMap){
      system.debug('----------------------------------------------    onAfterUndelete BEGIN');
      
      onAfterInsert(newTaskMap);

      system.debug('----------------------------------------------    onAfterUndelete END');
    }

    private static  Map<Id,Project_Task__c> getTasksThatChangeHours(Map<Id,Project_Task__c> oldTaskMap, Map<Id,Project_Task__c> newTaskMap){
      //first I want to know whay are the records where the field hours__c has changed
      Map<Id,Project_Task__c> updatedTasks = new  Map<Id,Project_Task__c>();
      if(newTaskMap!=null){
        for(Project_Task__c eachNewTask : newTaskMap.values()){
          if(eachNewTask.Hours__c != oldTaskMap.get(eachNewTask.id).Hours__c){
            updatedTasks.put(eachNewTask.Id, eachNewTask);
          }
        }
      }    
      return updatedTasks;
    }

    private static Map<Id , Decimal> calculateIncrementalHours(Map<Id,Project_Task__c> oldTaskMap, Map<Id,Project_Task__c> newTaskMap, Map<Id,Project_Task__c> taskToProcess){
      
      map<Id, Decimal> projectIdIncrementalHourChangeMap = new map<Id, Decimal>();        
      if(!taskToProcess.keySet().isEmpty()){       
        for(Project_Task__c eachUpdatedTask : taskToProcess.values()){ 
          Id parentProjectId = eachUpdatedTask.Project__c;            
          if(parentProjectId!=null){           
            Decimal actualValue, newIncrementalValue;
            Decimal newHourValue = newTaskMap != null ? newTaskMap.get(eachUpdatedTask.Id).Hours__c : 0;
            Decimal oldHourValue = oldTaskMap != null ? oldTaskMap.get(eachUpdatedTask.Id).Hours__c : 0;
            if(projectIdIncrementalHourChangeMap.containsKey(parentProjectId)){
              actualValue = projectIdIncrementalHourChangeMap.get(parentProjectId);
              newIncrementalValue = actualValue;
            }else{
              newIncrementalValue = 0;
            }  
            projectIdIncrementalHourChangeMap.put(parentProjectId, newIncrementalValue + newHourValue - oldHourValue);    
          }    
        }                
      }   
      return projectIdIncrementalHourChangeMap; 
    }

    private static void updateTotalHoursFieldOnProject(Map<Id,Decimal> projectIdIncrementalHourChangeMap){
      if(!projectIdIncrementalHourChangeMap.keySet().isEmpty()){
        Map<Id,Project__c> relatedProjects = new Map<Id,Project__c>([Select id, Total_Hours__c from Project__c where Id in :projectIdIncrementalHourChangeMap.keySet()]);
        if(!relatedProjects.keySet().isEmpty()){
          for( Project__c eachProject : relatedProjects.values()){
            eachProject.Total_Hours__c += projectIdIncrementalHourChangeMap.get(eachProject.Id);
            system.debug('+++++++++++++++++++++++++++++++++++++++     incremental: ' + projectIdIncrementalHourChangeMap.get(eachProject.Id));
          }
          update relatedProjects.values();
        }
      }     
    }
}