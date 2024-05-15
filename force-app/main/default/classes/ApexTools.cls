public class ApexTools {
	
    //MAP
    public static Map<id, List<sObject>> getMap_ParentId_ChildrenList(List<sObject> childrenList, string lookUpToparent_FieldNameInChild ){
        
        Map<id, List<sObject>> map_ParentId_ChildrenList = new Map<id, List<sObject>>();
        if( !childrenList.isEmpty() ){
                       
            for(sObject eachChildRecord : childrenList){                    
                id parentId = (id)eachChildRecord.get(lookUpToparent_FieldNameInChild);
                if(parentId != null){
                    if(map_ParentId_ChildrenList.keySet().contains(parentId)){    
                        List<sObject> ChildrenListAux = map_ParentId_ChildrenList.get(parentId);
                        ChildrenListAux.add(eachChildRecord);
                        map_ParentId_ChildrenList.put(parentId, ChildrenListAux);
                    }else{                                            
                        map_ParentId_ChildrenList.put(parentId, new List<sObject>{eachChildRecord});
                    }
                }else{
                    system.debug('child without parent ');
                }
        	}            
    	}
        return map_ParentId_ChildrenList;
    }
    
    //MAP
    public static void showMap_ParentId_ChildrenList( Map<id, List<sObject>> map_ParentId_ChildrenList, String childFieldNameToShow){
        
        for(id eachParentId : map_ParentId_ChildrenList.keySet()){
            system.debug('++++    Parent id: ' + eachParentId);         
            integer childNumber = 0;
            for(sObject eachChildRecord : map_ParentId_ChildrenList.get(eachParentId)){
                childNumber++;
                system.debug('=========    ' + childNumber + ': ' + childFieldNameToShow + ': ' + eachChildRecord.get(childFieldNameToShow));
            }
        }
    }
    
    //DATABASE
    public static void databaseUpdate(List<sObject> dataToUpdate){
        
        Database.SaveResult[] saveResults = Database.update(dataToUpdate, false);
        //List<sObject> errors = new List<sObject>();
        for(Database.SaveResult saveResult : saveResults) {
            if(!saveResult.isSuccess()) {
               
                String errorNoticeDescription = '';
                for(Database.Error error : saveResult.getErrors()) {
                    errorNoticeDescription = 'Status Code: ' + error.getStatusCode() + ' - Error Message: ' + error.getMessage() + ' - Error Field: ' + error.getFields() + '\r\n';                  
                    system.debug('------------------------    Update Error - ' + errorNoticeDescription);
                }
                /*
                errorNotice.Automation_Log__c = errorNoticeDescription.removeEnd('\r\n');
                 Fulfillment_Notice__c errorNotice = new Fulfillment_Notice__c(
                    Subject__c = 'Errors - Converting Single AR Reminder FN to Multiple',
                    To_Address__c = 'convertedsinglestateerrors+' + state.toLowerCase() + '@zbautomation.com',
                    Agency__c = agencyId
                );
                errorNotices.add(errors);
				*/
            }
        }
    }
  
    //API
    public static void makeAPICallout() {
            // Define the endpoint URL
            String endpoint = 'https://api.example.com/data';
    
            // Create an HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
    
            // Create an HTTP object to send the request
            Http http = new Http();
            
            // Send the request and capture the response
            HttpResponse res = http.send(req);
    
            // Check if the request was successful
            if (res.getStatusCode() == 200) {
                // Handle successful response
                System.debug('API Response: ' + res.getBody());
            } else {
                // Handle error response
                System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getStatus());
            }
        }
    
    /* GET RECORDS TO EVALUATE (OLD != NEW)
     
	 Map<ID, FulfillmentItem__c> FIToEvaluate = new Map<ID, FulfillmentItem__c>();
            if( !oldRecordMap.isEmpty() ){
                //update
                //did status or substatus change?                
                for(Id eachFIid : newRecordMap.keySet() ){
                    boolean statusChanged = oldRecordMap.get(eachFIid).status__c != newRecordMap.get(eachFIid).status__c;
                    boolean subStatusChanged = oldRecordMap.get(eachFIid).subStatus__c != newRecordMap.get(eachFIid).subStatus__c;
                    
                    //Status or substatus changed
                    if(statusChanged || subStatusChanged ){                   
                       FIToEvaluate.put(eachFIid, newRecordMap.get(eachFIid));
                    }
                }
            }

        

     */
    
    
    
    /*
    Database.SaveResult[] saveResults = Database.insert(reminderNotices, false);
    
    List<Fulfillment_Notice__c> errorNotices = new List<Fulfillment_Notice__c>();
    for(Database.SaveResult saveResult : saveResults) {
        if(!saveResult.isSuccess()) {
            Fulfillment_Notice__c errorNotice = new Fulfillment_Notice__c(
                Subject__c = 'Errors - Converting Single AR Reminder FN to Multiple',
                To_Address__c = 'convertedsinglestateerrors+' + state.toLowerCase() + '@zbautomation.com',
                Agency__c = agencyId
            );
            
            String errorNoticeDescription = '';
            for(Database.Error error : saveResult.getErrors()) {
                errorNoticeDescription += error.getStatusCode() + ': ' + error.getMessage() + '\r\n';
                errorNoticeDescription += error.getFields() + '\r\n';
            }
            errorNotice.Automation_Log__c = errorNoticeDescription.removeEnd('\r\n');
            errorNotices.add(errorNotice);
        }
    }
    
    Database.insert(errorNotices); 
    */
}

/*
  
    map<id, FulfillmentItem__c> FisMap = new  map<id, FulfillmentItem__c>([select id, CustomerAsset__c, status__c, subStatus__c  from FulfillmentItem__c where CustomerAsset__c in : customerAssetsToEvaluate.keyset()]);
    system.debug('+++++++++++++++++++++++++++++++++++    FisMap.size(): ' + FisMap.keyset().size());
    if( !FisMap.keyset().isEmpty() ){
    //  Ca_id    FIsList
    map<id, List<FulfillmentItem__c>> CaId_FIList = new map<id, List<FulfillmentItem__c>>();
        
    for(FulfillmentItem__c eachFI : FisMap.values()){                    
        id CaId = eachFI.CustomerAsset__c;                    
        if(CaId_FIList.keySet().contains(CaId)){    
            List<FulfillmentItem__c> FIList = CaId_FIList.get(CaId);
            FIList.add(eachFI);
            CaId_FIList.put(CaId, FIList);
        }else{                                            
            CaId_FIList.put(CaId, new List<FulfillmentItem__c>{eachFI});
        }
    }
 
 */