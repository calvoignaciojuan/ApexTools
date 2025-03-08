//Write a batch class that updates all Opportunities with a CloseDate older than one year, setting their status to "Closed Lost".
public with sharing class OppBatch implements database.Batchable<sObject> {
    
  public Database.QueryLocator start(Database.BatchableContext bc) {
    // collect the batches of records or objects to be passed to execute       
   //OPCION 2 puede ser directamente la query sin ser texto
     return Database.getQueryLocator([select id, Name, CloseDate from Opportunity]);
 }

 public void execute(Database.BatchableContext bc, list<Opportunity> allRecords){

  List<Opportunity> oppToProcess = new List<Opportunity>();

  if(!allRecords.isEmpty()){
    for(Opportunity eachOpp : allRecords){
      Integer daysOverDue = Date.today().daysBetween(eachOpp.CloseDate)*(-1);
      //system.debug('Opp: ' + eachOpp.name + ' is ' + daysOverDue + ' daysOverDue' );
      if(daysOverDue > 365){
        oppToProcess.add(eachOpp);
      }
    }
    if(!oppToProcess.isEmpty()){
      for(Opportunity eachOpp: oppToProcess){
        eachOpp.StageName = 'Closed Lost';  
      }
      update oppToProcess;
    }
  }      
 }

 public void finish(Database.BatchableContext bc){        
     
 }

}

//
//database.executebatch(new OppBatch(), 200);