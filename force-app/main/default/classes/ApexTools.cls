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
  

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    APIs    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //API Simple API call
    public static void makeAPICallout() {
        // Define the endpoint URL
        String endpoint = 'https://api.example.com/data';

        // Create an HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('cookie', 'notabot=true');
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

    

    //-----------------------------    SCREEN FLOW   ---------------------------------------
    
      //-------------------------    FLOW - APEX INTERFACE ( invocable method )   -----------------------------
        @InvocableMethod(label='Lead Ordering Saved-Submit')
        public static List<OutputVariables> leadOrderingFunction( List<InputVariablesLeadOrdering> inputVariables ){
          
          system.debug( ' inputVariables[0].selectedPackage ' + inputVariables[0].selectedPackage); //allways in position 0
          system.debug( ' inputVariables[0].includedServices ' + inputVariables[0].includedServices);
          
          return new List<OutputVariables>();
        }
        public class InputVariablesLeadOrdering {
          @InvocableVariable
          public string selectedPackage;
          @InvocableVariable
          public String includedServices;          
        }
      
        //if this classes are saved independently and add @auraEnabled you can create apex-define type variable in resources
        public class OutputVariables {
            @InvocableVariable
            public List<String> packages;     
            
            @InvocableVariable
            public List<String> upsells;
        }
      //-------------------------    FLOW - APEX INTERFACE ( invocable method )   -----------------------------


      //-------------------------    HACK TO VLOOKUP EQUIVALENT IN FLOW   -----------------------------

   
      // wholeDataString = ':CA:70:TX:300:TANDIL:100:CAT:10:' -> symbol Key symbol Value Symbol ...
      // variable type formula = =+MID(wordToFind,FIND(wholeDataString,wordToFind,1) + LEN(wholeDataString) + 1, FIND(":",wordToFind, FIND(":",wordToFind,FIND(wholeDataString,wordToFind,1) + 1) + 1 ) - FIND(":",wordToFind,FIND(wholeDataString,wordToFind,1) + 1) -1)
      // symbol + ':'
      @InvocableMethod(label='get string from collection')
      public static String convertTableToString_symbolKeySymbolValueSymbol( List<objectName__C> inputVariable ){
        //we have to loop through the collection and st
        string symbol = ':';
        string result = '';
        for( string eachdata : inputVariable ){
          result =  result + symbol + eachdata;
        }
        result = result + symbol;
        return result;
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
    
    
    
    
}
