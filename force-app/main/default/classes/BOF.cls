
//================= METHODS 

public void launchBatch(){
    //same call without pastCutOver
    
    Database.executebatch(new BatchFulfillmentItemAssignment(), 20);
    
}

public void AllFIs(){
  List<FulfillmentItem__c> FiList = [select id, Jurisdiction__c, Name, Owner__c, CustomerAsset__r.Jurisdiction__r.Business_Entity__r.KYC_Status__c, First_Sent_to_DE__c, Fulfillment_Assignment_Log__c,  CustomerAsset__r.BOF_Data_Collection__c, Status__c, Substatus__c, Past_Cutover_Date__c, Ready_for_Evaluation__c from FulfillmentItem__c where Jurisdiction__c = :jurId];
  system.debug('+++++++++++++++++++++++++++++>>    FIs found: ' + FiList.size() );
  for(FulfillmentItem__c fi : FiList){
      fi.Ready_for_Evaluation__c = false;
      fi.First_Sent_to_DE__c = null;
      fi.Fulfillment_Assignment_Log__c = null;  
      fi.Status__c = 'Pending';
      fi.substatus__c = '';        
  }
  update FiList;
}

public void scenario_1(){
  //Happy path Dont assign fulfillment 
  //   BOForBOFmod   &&   ( fi.Status__c != 'Pending'   ||     fi.Substatus__c == 'waiting_on_ein'   ||     !isAFormedCompany      ||      !BOFItem_hasCompletedCollectionFlow
  //   BOForBOFmod         fi.Status__c != 'Pending'         
  //       1                             0                                   0                                     0                                        1
  //       1                fi.Status__c == 'Pending'        (fi.Substatus__c != 'waiting_on_ein')       (isAFormedCompany==true)     (BOFItem_hasCompletedCollectionFlow == false)
  //       1                             0                                   0                                     1                                        0
  //       1                fi.Status__c == 'Pending'        (fi.Substatus__c != 'waiting_on_ein')       (isAFormedCompany==false)     (BOFItem_hasCompletedCollectionFlow == true)
  //       1                             0                                   1                                     0                                        0
  //       1                fi.Status__c == 'Pending'        (fi.Substatus__c == 'waiting_on_ein')       (isAFormedCompany==true)     (BOFItem_hasCompletedCollectionFlow == true)
  //       1                             1                                   0                                     0                                        0
  //       1                fi.Status__c != 'Pending'        (fi.Substatus__c != 'waiting_on_ein')       (isAFormedCompany==true)     (BOFItem_hasCompletedCollectionFlow == true)
    
 //String myLabel = Label.Testing;

  List<FulfillmentItem__c> FiList = [select id, Jurisdiction_Id__c, Name, Owner__c, CustomerAsset__r.Jurisdiction__r.Business_Entity__r.KYC_Status__c,  CustomerAsset__r.BOF_Data_Collection__c, Status__c, Substatus__c, Past_Cutover_Date__c, Ready_for_Evaluation__c from FulfillmentItem__c where CustomerAsset__r.Jurisdiction_Name__c = 'JUR BOF TESTING'];
  system.debug('+++++++++++++++++++++++++++++>>    FIs found: ' + FiList.size() );
  for(FulfillmentItem__c fi : FiList){
      fi.Ready_for_Evaluation__c = false;
      fi.First_Sent_to_DE__c = null;
      fi.Fulfillment_Assignment_Log__c = null;  
      fi.substatus__c = ''; 
      //fi.Jurisdiction__c = '';  
  }
  update FiList;
}


public void cleanOneFISubstatus(id FiId){
  List<FulfillmentItem__c> FiList = [select id, substatus__c from FulfillmentItem__c where id = :FiId];
  FulfillmentItem__c FI = FiList[0];
  FI.substatus__c = '';
  update FI;
}

public void setOrClean_BOF_FI_WaitingOnEIN(){
  List<FulfillmentItem__c> FiList = [select id, status__c, substatus__c from FulfillmentItem__c where id in ('a0zO4000001J62jIAC','a0zO4000001J70PIAS')];
  for(FulfillmentItem__c fi : FiList){
    //fi.substatus__c = 'waiting_on_ein';
    fi.substatus__c = '';
  }
  
  update FiList;
}

public Boolean isFormedCompany( List<FulfillmentItem__c> allFulfillmentItemsValues) {
  Boolean hasFormationComp = false;
  for (FulfillmentItem__c fi : allFulfillmentItemsValues) {
      if ( (fi.Name.contains('Formation') && fi.Status__c == 'Complete') || (fi.Name.contains('Registered Agent') && fi.Status__c == 'Active') || (fi.Name.contains('Change Of Registered Agent') && fi.Status__c == 'Active') ) {
          hasFormationComp = true;
      }
  }
  return hasFormationComp ? true : false;
} 


//--------------------    MAIN

List<FulfillmentItem__c> FiList = [select id, Jurisdiction_Id__c, Name, Owner__c, CustomerAsset__r.Jurisdiction__r.Business_Entity__r.KYC_Status__c,  CustomerAsset__r.BOF_Data_Collection__c, Status__c, Substatus__c, Past_Cutover_Date__c, Ready_for_Evaluation__c from FulfillmentItem__c where CustomerAsset__r.Jurisdiction_Name__c = 'JUR BOF TESTING'];
system.debug('+++++++++++++++++++++++++++++>>    FIs found: ' + FiList.size() );

//FORMED COMPANY (jurisd level)
Boolean isAFormedCompany = isFormedCompany(FiList); // FI(formation)  complete || FI(Registered Agent) active || FI(Change Of Registered Agent) active
system.debug('+++++++++++++++++++++++++++++>>    isAFormedCompany: ' + isAFormedCompany );

//DAta COllection (CustomerAsset level)
Boolean BOFItem_hasCompletedCollectionFlow;
for(FulfillmentItem__c fi : FiList){
BOFItem_hasCompletedCollectionFlow = (fi.CustomerAsset__r.BOF_Data_Collection__c == 'Form Assembly') || (fi.CustomerAsset__r.BOF_Data_Collection__c == 'UJM');   
system.debug('+++++++++++++++++++++++++++++>>    BOFItem_hasCompletedCollectionFlow: ' + BOFItem_hasCompletedCollectionFlow );
}


Boolean BOForBOFmod = fi.Name.contains('Beneficial Ownership Filing') || fi.Name.contains('Bof Modification');

//Assign when - OLD
 BOForBOFmod && fi.Status__c == 'Pending' && fi.Substatus__c != 'waiting_on_ein' && isAFormedCompany && BOFItem_hasCompletedCollectionFlow 


//Do nothing - dont assign when
if( BOForBOFmod && ( fi.Status__c != 'Pending' || fi.Substatus__c == 'waiting_on_ein' || !isAFormedCompany || !BOFItem_hasCompletedCollectionFlow ) ) {
  //DO NOT ASSIGN FI
         1                        0                                0                            0                             0   

}else{
   //go ahead and assign when
  !BOForBOFmod || ( fi.Status__c == 'Pending' && fi.Substatus__c != 'waiting_on_ein' && isAFormedCompany && BOFItem_hasCompletedCollectionFlow  )
}
