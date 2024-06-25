public class LeadOrderingSalesQuote {
     
    public class SubmitQuoteResponse{
        public String  resumeLink { get; set; }
    }
    
    @future(callout = true)
    public static void submitQuote( String endpoint, String body, id leadRecordId, id salesQuoteRecordId ){ 
         
        Lead leadRecord;
        Sales_Quote__c salesQuoteRecord;
        try{
            // Create an HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);      
            req.setMethod('POST');
            req.setHeader('cookie', 'notabot=true');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(body);       
            
            // Create an HTTP object to send the request
            Http http = new Http();       
            HttpResponse res;
                  
            List<Lead> leadRecordList = [select id, Lead_Ordering_Link_Status__c, Lead_Ordering_Link__c  from Lead where id = :leadRecordId ];
            if( !leadRecordList.isEmpty() ){
                leadRecord = leadRecordList[0];                       
            }
            List<Sales_Quote__c> salesQuoteRecordList = [select id, Status__c from Sales_Quote__c where id = :salesQuoteRecordId ];
            if( !salesQuoteRecordList.isEmpty() ){
                salesQuoteRecord = salesQuoteRecordList[0];                       
            }
            
            res = http.send(req); 
            // Check if the request was successful
            if (res.getStatusCode() == 200) {
                // Handle successful response
                SubmitQuoteResponse response = (SubmitQuoteResponse) JSON.deserialize( res.getBody(), SubmitQuoteResponse.class); 
                
                leadRecord.Lead_Ordering_Link__c = response.resumeLink;
                leadRecord.Lead_Ordering_Link_Status__c = 'Link successfully generated';
                salesQuoteRecord.Status__c = 'Waiting for Customer';
                update leadRecord; 
        		update salesQuoteRecord;
            } else {
                // Handle error response    
                String errorMesagge = 'API call Error - Response status code: ' + res.getStatusCode() + ' - ' + res.getStatus();       
                System.debug(errorMesagge); 
                throw new CalloutException(errorMesagge + '\n\n' + 'JSON(data used in the call): \n' + body);
            }                        
            
        }catch(exception e){
            System.debug('Error: ' + e); 
            leadRecord.Lead_Ordering_Link__c = '';
            leadRecord.Lead_Ordering_Link_Status__c = 'Error, link not generated';
            update leadRecord; 
            
            //HandleCustomException.LogException(e);
            ExceptionUtils.error( e, ExceptionUtils.EXCEPTION_TYPES.THROW_NO_EXCEPTION );
        }
       
    }
    
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   FLOW INTERFACE    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     public class InputVariablesLeadOrdering {
       
       @InvocableVariable
       public Lead leadRecord;      
       @InvocableVariable
       public Sales_Quote__c salesQuoteRecord;
       @InvocableVariable
       public Lead_Ordering_Plan_Details_Obj__c planDetailsRecord;  
        
       @InvocableVariable
       public String includedServices;
       @InvocableVariable
       public String selectedUpsells; 
       @InvocableVariable
       public Boolean submitCheckbox; 
       @InvocableVariable
       public Boolean isNewQuote;  
       
       //@InvocableVariable
       //public string selectedCounty;   
    }
	 
    public class OutputVariables {
        
        @auraEnabled @InvocableVariable
        public String statusResponse;    
        @auraEnabled @InvocableVariable
        public String resumeLink;
    }
    
    @InvocableMethod(label='Lead Ordering Saved-Submit')
    public static List<OutputVariables> leadOrderingFunction( List<InputVariablesLeadOrdering> inputVariables ){
        /*        
        system.debug( ' inputVariables[0].leadRecord ' + inputVariables[0].leadRecord);
        system.debug( ' inputVariables[0].salesQuoteRecord ' + inputVariables[0].salesQuoteRecord);
        system.debug( ' inputVariables[0].planDetailsRecord ' + inputVariables[0].planDetailsRecord);
        system.debug( ' inputVariables[0].includedServices ' + inputVariables[0].includedServices);
        system.debug( ' inputVariables[0].selectedUpsells ' + inputVariables[0].selectedUpsells);
        system.debug( ' inputVariables[0].submitCheckbox ' + inputVariables[0].submitCheckbox);
        system.debug( ' inputVariables[0].isNewQuote ' + inputVariables[0].isNewQuote);
        */
        List<OutputVariables> output = new List<OutputVariables>();
        OutputVariables outputZero = new OutputVariables();
        output.add(outputZero);
        
        try{
            
            //input Variable settings
            	Lead leadRecord = inputVariables[0].leadRecord;
                Sales_Quote__c salesQuoteRecord = inputVariables[0].salesQuoteRecord;
            	Lead_Ordering_Plan_Details_Obj__c funnelDataRecord = inputVariables[0].planDetailsRecord;
                String selectedPackage = salesQuoteRecord.Packages_Picklist__c;             
                String quoteId = inputVariables[0].salesQuoteRecord.Id;
            
                List<String> includedServices =  getCleanServiceList( inputVariables[0].includedServices );
        
                List<String> upsellServices = inputVariables[0].selectedUpsells != null ? getCleanServiceList( inputVariables[0].selectedUpsells ) : new List<String>();
            	Boolean submitQuote = inputVariables[0].submitCheckbox;    
            	Boolean isNewQuote = inputVariables[0].isNewQuote;   
         
                List<Product2> productsCodeList = [select id, ProductCode from product2 where ProductCode in ('1800_accountant','basic_email','corporate_docs','domain_name_privacy','domain_name_reg','ein_business_docs_bundle','ein_creation','operating_agreement','registered_agent_service','rush','standard','static_website','worry_free_service','zb_banking_preferred','zb_money_pro','starter_plan_v36','pro_plan_v36','premium_plan_v36')];
                if( productsCodeList.isEmpty() ){
                    throw new QueryException('No productsCodeList data available to query');
                } 
            
            //Sales Quote Line Items 
                if( !isNewQuote ){
                    //if is a draft or saved quote, delete all quoteLineItem before creating new selected Ones
                    List<Sales_Quote_Line_Item__c> lineItemstToDelete = [select id, Sales_Quote__c from Sales_Quote_Line_Item__c where Sales_Quote__c = :quoteId];
                    delete lineItemstToDelete;
                }
             
                Sales_Quote_Line_Item__c newLineItem;  
                List<Sales_Quote_Line_Item__c> newQuoteLineitemList = new List<Sales_Quote_Line_Item__c>();
                
                //Package Item   
                    string productCode = '';
                    integer packagePrice = 0;
                    switch on selectedPackage {
                        when 'Starter Plan' {		
                            productCode = 'starter_plan_v36'; }	
                        when 'Pro Plan' {	
                            productCode = 'pro_plan_v36';      }
                        when 'Premium Plan' {	
                            productCode = 'premium_plan_v36'; }                    
                    }
                
                    newLineItem = new Sales_Quote_Line_Item__c();            
                    newLineItem.Product__c = getProductId( productsCodeList, productCode ); 
                    newLineItem.Sales_Quote__c = quoteId;
                    newLineItem.Service_Price__c = getPackageServicePrice( funnelDataRecord, selectedPackage);
                   
                    newQuoteLineitemList.add(newLineItem);
                    
                //included services
                    for(String eachIncludedService : includedServices){
                        
                        newLineItem = new Sales_Quote_Line_Item__c();                        
                        newLineItem.Product__c = getProductId( productsCodeList, eachIncludedService );                     
                        newLineItem.Sales_Quote__c = quoteId;
                        newLineItem.Service_Price__c = 0;
                                               
                        newQuoteLineitemList.add(newLineItem);
                    }
                
                //upsells                   	
                    for(String eachUpsellCode : upsellServices){
                        
                        newLineItem = new Sales_Quote_Line_Item__c();                        
                        newLineItem.Product__c = getProductId( productsCodeList, eachUpsellCode ); 
                        newLineItem.Sales_Quote__c = quoteId;
                        newLineItem.Service_Price__c = getPackageServicePrice( funnelDataRecord, eachUpsellCode);                     
                        
                        newQuoteLineitemList.add(newLineItem);
                    }
        
                    if( !newQuoteLineitemList.isEmpty() ){
                        insert newQuoteLineitemList;
                    }
           
            //SUBMIT QUOTE           
            if( submitQuote ){
                
                string jsonBody = getJson( funnelDataRecord, leadRecord, salesQuoteRecord );
                salesQuoteRecord.Json__c = jsonBody;
                update salesQuoteRecord;
                
                leadRecord.Lead_Ordering_Link_Status__c = 'Waiting for link';
                update leadRecord;
              
                submitQuote(funnelDataRecord.Save_Progress_Endpoint__c, jsonBody, leadRecord.id, salesQuoteRecord.id);                             
            }
        	     	  		
        	output[0].statusResponse = 'success';
            
        }catch(exception e){
            system.debug('error: ' + e);
            output[0].statusResponse = 'error';
            //HandleCustomException.LogException(e);
            ExceptionUtils.error(e);
        }
        return output;
    }
    
    //gets a string with services separated with commas and return those services as a list
    public static List<String> getCleanServiceList( string serviceStringListRaw ){
        List<String> servicesList = new List<String>();
        List<String> servicesListRaw = serviceStringListRaw.split(';');
        if( !servicesListRaw.isEmpty() ){
            for(string eachString : servicesListRaw){
                if(eachString != ';'){
                    servicesList.add(eachString);
                }
            }
        }
        return servicesList;
    }
    
    //given a productListTableFromQuery and a productCode, returns productID
    public static string  getProductId( List<Product2> productsCodeList , string productCode){
        
        string productId = null;
        for(Product2 eachProduct : productsCodeList){
            if( eachProduct.ProductCode == productCode ){
                productId = eachProduct.id;
                break;
            }
        }
        return productId;
    }  
    
    //given a package/service codename it returns its price
    public static decimal getPackageServicePrice( Lead_Ordering_Plan_Details_Obj__c funnelData, string packageServiceName ){
     
        decimal price = 0;
        switch on packageServiceName {
            when 'Starter Plan' {		
                price = funnelData.Price_Starter_Plan__c; }	
            when 'Pro Plan' {	
                price = funnelData.Price_Pro_Plan__c; }	
            when 'Premium Plan' {	
                price = funnelData.Price_Premium_Plan__c; }	
            when '1800_accountant' {	
                price = 0; }	    
            when 'basic_email' {	
                price = 0; }	    
            when 'corporate_docs' {	
                price = funnelData.Price_Upsell_Corporate_Docs__c; }	    
            when 'domain_name_privacy' {	
                price = 0; }	    
            when 'domain_name_reg' {	
                price = 0; }	    
            when 'ein_business_docs_bundle' {	
                price = funnelData.Price_Upsell_EIN_bundle__c; }	    
            when 'ein_creation' {	
                price = funnelData.Price_Upsell_Just_EIN__c; }	    
            when 'operating_agreement' {	
                price = funnelData.Price_Upsell_Operating_Agreement__c; }	   
            when 'registered_agent_service' {	
                price = funnelData.Price_Upsell_RA_Service__c; }	    
            when 'rush' {	
                price = funnelData.Price_Upsell_Speed__c; }	    
            when 'standard' {	
                price = 0; }
            when 'static_website' {	
                price = funnelData.Price_Upsell_Static_website__c; }	
            when 'worry_free_service' {	
                price = funnelData.Price_Upsell_Worry_Free__c; }	
            when 'zb_banking_preferred' {	
                price = funnelData.Price_Upsell_ZB_Banking__c; }	
            when 'zb_money_pro' {	
                price = funnelData.Price_Upsell_ZB_Money__c; }
        }
        return price;
    }
    
    public static string getJson( Lead_Ordering_Plan_Details_Obj__c funnelData, Lead leadRecord, Sales_Quote__c salesQuoteRecord){
    
        String typee = leadRecord.entity_type__c;
        String firstName = leadRecord.FirstName;
        String lastName = leadRecord.LastName;
        //phone
        String rawPhoneNumber = leadRecord.phone;
        String nonNumericRegex = '[^0-9]';
		String cleanedPhoneNumber = rawPhoneNumber.replaceAll(nonNumericRegex, '');
        string phoneNumber = cleanedPhoneNumber;
        String email = leadRecord.Email;
        String leadUuId = leadRecord.Lead_UUID__c;
        
        //Plan prices
        String starterPlanPrice = String.valueOf( (integer)funnelData.Price_Starter_Plan__c);
        String proPlanPrice = String.valueOf( (integer)funnelData.Price_Pro_Plan__c);
        String premiumPlanPrice = String.valueOf( (integer)funnelData.Price_Premium_Plan__c);
        //upsell prices
        String EINDocsBundlePrice = String.valueOf( (integer)funnelData.Price_Upsell_EIN_bundle__c);
        String corporateDocsPrice = String.valueOf( (integer)funnelData.Price_Upsell_Corporate_Docs__c);
        String EINPrice = String.valueOf( (integer)funnelData.Price_Upsell_Just_EIN__c);
        
        String rushPrice = String.valueOf( (integer)funnelData.Price_Upsell_Speed__c);
        String staticWebsitePrice = String.valueOf( (integer)funnelData.Price_Upsell_Static_website__c);
        String moneyProPrice = String.valueOf( (integer)funnelData.Price_Upsell_ZB_Money__c);
        String bankingPreferredPrice = String.valueOf( (integer)funnelData.Price_Upsell_ZB_Banking__c);
        String operatingAgreementPrice = String.valueOf( (integer)funnelData.Price_Upsell_Operating_Agreement__c);
        String worryFreePrice = String.valueOf( (integer)funnelData.Price_Upsell_Worry_Free__c);
        String registeredAgentPrice = String.valueOf( (integer)funnelData.Price_Upsell_RA_Service__c);
        
        String plan;
        
        switch on salesQuoteRecord.Packages_Picklist__c {
            
            when 'Starter Plan'{
                
                String EIN_bundle_choice = '              \"no\": \"ein-docs-no\"';
                if( salesQuoteRecord.EIN_Business_Documents_Upsell__c ){
                    EIN_bundle_choice = '              \"yes\": \"ein-biz-yes\"';
                }else{
                    if( salesQuoteRecord.Just_Business_Documents_Upsell__c ){
                        EIN_bundle_choice = '              \"onlyDocs\": \"biz-docs-only\"';
                    }else{
                        if( salesQuoteRecord.Just_EIN_Upsell__c ){
                            EIN_bundle_choice = '              \"onlyEIN\": \"ein-only\"';
                        }
                    }
                }
                string rush_choice = salesQuoteRecord.Rush_Service_Upsell__c ? '              \"rush\": \"rush\"' : '              \"no\": \"no\"' ;
                string staticWebside_choice = salesQuoteRecord.Business_Website_Upsell__c ? '              \"yes\": \"yes\"' : '              \"no\": \"no\"' ;
                string zbMoneyPro_choice = salesQuoteRecord.ZB_Money_Pro_Upsell__c ? '              \"monthly\": \"zbmoney-monthly\"' : '              \"no\": \"zbmoney-no\"' ;
				string preferred_choice = salesQuoteRecord.ZB_Banking_Upsell__c ? '              \"yes\": \"yes\"' : '              \"no\": \"no\"' ;
             	string operatingAgreement_choice = salesQuoteRecord.Operating_Agreement_Template_Upsell__c ? '              \"yes\": \"yes\"' : '              \"no\": \"no\"' ;
             	string worryFree_choice = salesQuoteRecord.Worry_Free_Compliance_Upsell__c ? '              \"yes\": \"yes\"' : '              \"no\": \"no\"' ;
             	string registeredAgent_choice = salesQuoteRecord.Registered_Agent_Service_Upsell__c ? '              \"yes\": \"ra-yes\"' : '              \"no\": \"ra-no\"' ;   
                
                plan = 
                    '    \"starter-plan\": {\n'+
                    '      \"price\": ' + starterPlanPrice + ',\n'+
                    '      \"includedServices\": [\n'+
                    '        {\n'+
                    '          \"standard\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Standard\",\n'+
                    '            \"serviceName\": \"standard\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"1800_accountant\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Tax Savings Consultation\",\n'+
                    '            \"serviceName\": \"1800_accountant\",\n'+
                    '            \"type\": \"offer\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"offer\",\n'+
                    '            \"choices\": {\n'+
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        }\n'+
                    '      ],\n'+
                    '      \"upsells\": [\n'+
                    '        {\n'+
                    '          \"ein_business_docs_bundle\": {\n'+
                    '            \"services\": {\n'+
                    '                             \"ein_business_docs_bundle\": {\n'+
                    '                                \"amount\": ' + EINDocsBundlePrice + ',\n'+
                    '                                \"name\": \"EIN and Business Documents bundle\",\n'+
                    '                                \"serviceName\": \"ein_business_docs_bundle\",\n'+
                    '                                \"type\": \"plan\",\n'+
                    '                                \"deferred\": true,\n'+
                    '                                \"interval\": \"onetime\",\n'+
                    '                                \"priceOrFee\": \"price\",\n'+
                    '                                \"renewal\": \"never\",\n'+
                    '                                \"serviceType\": \"plan\"\n'+
                    '                            },\n'+
                    '                            \"corporate_docs\": {\n'+
                    '                                \"amount\": ' + corporateDocsPrice + ',\n'+
                    '                                \"name\": \"Business Document Templates Library\",\n'+
                    '                                \"serviceName\": \"corporate_docs\",\n'+
                    '                                \"type\": \"service\",\n'+
                    '                                \"deferred\": true,\n'+
                    '                                \"interval\": \"onetime\",\n'+
                    '                                \"priceOrFee\": \"price\",\n'+
                    '                                \"renewal\": \"never\",\n'+
                    '                                \"serviceType\": \"service\"\n'+
                    '                            },\n'+
                    '                            \"ein_creation\": {\n'+
                    '                                \"amount\": ' + EINPrice + ',\n'+
                    '                                \"name\": \"EIN Creation\",\n'+
                    '                                \"serviceName\": \"ein_creation\",\n'+
                    '                                \"type\": \"service\",\n'+
                    '                                \"deferred\": true,\n'+
                    '                                \"interval\": \"onetime\",\n'+
                    '                                \"priceOrFee\": \"price\",\n'+
                    '                                \"renewal\": \"never\",\n'+
                    '                                \"serviceType\": \"service\"\n'+
                    '                            }\n'+
                    '            },\n'+
                    '            \"choices\": {\n'+
                					EIN_bundle_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"speed\": {\n'+
                    '            \"amount\": ' + rushPrice + ',\n'+
                    '            \"name\": \"Rush\",\n'+
                    '            \"serviceName\": \"speed\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+
                   					rush_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"static_website\": {\n'+
                    '            \"amount\": ' + staticWebsitePrice + ',\n'+
                    '            \"name\": \"Business Website\",\n'+
                    '            \"serviceName\": \"static_website\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"monthly\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+
                  					staticWebside_choice +'\n'+ 
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"zb_money_pro\": {\n'+
                    '            \"amount\": ' + moneyProPrice + ',\n'+
                    '            \"name\": \"ZB Money Pro\",\n'+
                    '            \"serviceName\": \"zb_money_pro\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"monthly\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+
      								zbMoneyPro_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"zb_banking_preferred\": {\n'+
                    '            \"amount\": ' + bankingPreferredPrice + ',\n'+
                    '            \"name\": \"ZenBusiness Banking\",\n'+
                    '            \"serviceName\": \"zb_banking_preferred\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"monthly\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+
                  					preferred_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"operating_agreement\": {\n'+
                    '            \"amount\": ' + operatingAgreementPrice + ',\n'+
                    '            \"name\": \"Operating Agreement Template\",\n'+
                    '            \"serviceName\": \"operating_agreement\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+
                  					operatingAgreement_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"worry_free_service\": {\n'+
                    '            \"amount\": ' + worryFreePrice + ',\n'+
                    '            \"amountAfterCoupon\": 0,\n'+
                    '            \"name\": \"Worry Free Compliance\",\n'+
                    '            \"serviceName\": \"worry_free_service\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": true,\n'+
                    '            \"interval\": \"annual\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"coupon\": {\n'+
                    '              \"coupon_uuid\": \"5bebaf6a-8484-419e-91fc-50c6058f5a83\",\n'+
                    '              \"amount\": 199,\n'+
                    '              \"external_coupon_id\": \"199_off_first_year\",\n'+
                    '              \"created_datetime\": \"2022-04-26T19:22:21.197996Z\",\n'+
                    '              \"updated_datetime\": \"2022-04-26T19:22:21.198014Z\",\n'+
                    '              \"type\": \"absolute\",\n'+
                    '              \"is_fees_discount\": false,\n'+
                    '              \"duration\": \"forever\",\n'+
                    '              \"stripe_id\": null\n'+
                    '            },\n'+
                    '            \"choices\": {\n'+
                					worryFree_choice +'\n'+ 
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"registered_agent_service\": {\n'+
                    '            \"amount\": ' + registeredAgentPrice + ',\n'+
                    '            \"name\": \"Registered Agent\",\n'+
                    '            \"serviceName\": \"registered_agent_service\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": true,\n'+
                    '            \"interval\": \"annual\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+
                  					registeredAgent_choice +'\n'+ 
                    '            }\n'+
                    '          }\n'+
                    '        }\n'+
                    '      ]\n'+
                    '    }';
            }	
            
            when 'Pro Plan' {		
                	
                string staticWebside_choice = salesQuoteRecord.Business_Website_Upsell__c ? '              \"yes\": \"yes\"' : '              \"no\": \"no\"' ;
                string zbMoneyPro_choice = salesQuoteRecord.ZB_Money_Pro_Upsell__c ? '              \"monthly\": \"zbmoney-monthly\"' : '              \"no\": \"zbmoney-no\"' ;
            	string preferred_choice = salesQuoteRecord.ZB_Banking_Upsell__c ? '              \"yes\": \"yes\"' : '              \"no\": \"no\"' ;
                string corporateDocs_choice = salesQuoteRecord.Business_Document_Templates_Library_Upse__c ? '              \"yes\": \"yes\"' : '              \"no\": \"no\"' ;              
             	string registeredAgent_choice = salesQuoteRecord.Registered_Agent_Service_Upsell__c ? '              \"yes\": \"ra-yes\"' : '              \"no\": \"ra-no\"' ;   
                
            	 plan = 
					'    \"pro-plan\": {\n'+
                    '      \"price\": ' + proPlanPrice + ',\n'+
                    '      \"includedServices\": [\n'+
                    '        {\n'+
                    '          \"speed\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Rush\",\n'+
                    '            \"serviceName\": \"speed\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+                    
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"operating_agreement\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Operating Agreement Template\",\n'+
                    '            \"serviceName\": \"operating_agreement\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+              
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"ein_creation\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"EIN Creation\",\n'+
                    '            \"serviceName\": \"ein_creation\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+          
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"1800_accountant\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Tax Savings Consultation\",\n'+
                    '            \"serviceName\": \"1800_accountant\",\n'+
                    '            \"type\": \"offer\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"offer\",\n'+
                    '            \"choices\": {\n'+        
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"worry_free_service\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Worry Free Compliance\",\n'+
                    '            \"serviceName\": \"worry_free_service\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"annual\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+             
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        }\n'+
                    '      ],\n'+
                    '      \"upsells\": [\n'+
                    '        {\n'+
                    '          \"static_website\": {\n'+
                    '            \"amount\": ' + staticWebsitePrice + ',\n'+
                    '            \"name\": \"Business Website\",\n'+
                    '            \"serviceName\": \"static_website\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"monthly\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+
               			staticWebside_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"zb_money_pro\": {\n'+
                    '            \"amount\": ' + moneyProPrice + ',\n'+
                    '            \"name\": \"ZB Money Pro\",\n'+
                    '            \"serviceName\": \"zb_money_pro\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"monthly\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+
                  		zbMoneyPro_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"zb_banking_preferred\": {\n'+
                    '            \"amount\": ' + bankingPreferredPrice + ',\n'+
                    '            \"name\": \"ZenBusiness Banking\",\n'+
                    '            \"serviceName\": \"zb_banking_preferred\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"monthly\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+
                 		preferred_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"corporate_docs\": {\n'+
                    '            \"amount\": ' + corporateDocsPrice + ',\n'+
                    '            \"name\": \"Business Document Templates Library\",\n'+
                    '            \"serviceName\": \"corporate_docs\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": true,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+
            			corporateDocs_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"registered_agent_service\": {\n'+
                    '            \"amount\": ' + registeredAgentPrice + ',\n'+
                    '            \"name\": \"Registered Agent\",\n'+
                    '            \"serviceName\": \"registered_agent_service\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": true,\n'+
                    '            \"interval\": \"annual\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+
                 		registeredAgent_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        }\n'+
                    '      ]\n'+
                    '    }';                
            }
            
            when 'Premium Plan' {		
                
                string zbMoneyPro_choice = salesQuoteRecord.ZB_Money_Pro_Upsell__c ? '              \"monthly\": \"zbmoney-monthly\"' : '              \"no\": \"zbmoney-no\"' ;
            	string preferred_choice = salesQuoteRecord.ZB_Banking_Upsell__c ? '              \"yes\": \"yes\"' : '              \"no\": \"no\"' ;                           
             	string registeredAgent_choice = salesQuoteRecord.Registered_Agent_Service_Upsell__c ? '              \"yes\": \"ra-yes\"' : '              \"no\": \"ra-no\"' ;  
              
            	plan = 
                    '    \"premium-plan\": {\n'+
                    '      \"price\": ' + premiumPlanPrice + ',\n'+
                    '      \"includedServices\": [\n'+
                    '        {\n'+
                    '          \"basic_email\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Basic Email\",\n'+
                    '            \"serviceName\": \"basic_email\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+            
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"domain_name_privacy\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Domain Name Privacy\",\n'+
                    '            \"serviceName\": \"domain_name_privacy\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+          
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"domain_name_reg\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Domain Name Registration\",\n'+
                    '            \"serviceName\": \"domain_name_reg\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"annual\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+          
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"static_website\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Business Website\",\n'+
                    '            \"serviceName\": \"static_website\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"annual\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+           
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"corporate_docs\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Business Document Templates Library\",\n'+
                    '            \"serviceName\": \"corporate_docs\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+         
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"speed\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Rush\",\n'+
                    '            \"serviceName\": \"speed\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+         
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"ein_creation\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"EIN Creation\",\n'+
                    '            \"serviceName\": \"ein_creation\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+         
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"operating_agreement\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Operating Agreement Template\",\n'+
                    '            \"serviceName\": \"operating_agreement\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+       
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"1800_accountant\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Tax Savings Consultation\",\n'+
                    '            \"serviceName\": \"1800_accountant\",\n'+
                    '            \"type\": \"offer\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"onetime\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"never\",\n'+
                    '            \"serviceType\": \"offer\",\n'+
                    '            \"choices\": {\n'+                
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"worry_free_service\": {\n'+
                    '            \"amount\": 0,\n'+
                    '            \"name\": \"Worry Free Compliance\",\n'+
                    '            \"serviceName\": \"worry_free_service\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"annual\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+              
                    '              \"no\": \"no\"\n'+
                    '            }\n'+
                    '          }\n'+
                    '        }\n'+
                    '      ],\n'+
                    '      \"upsells\": [\n'+
                    '        {\n'+
                    '          \"zb_money_pro\": {\n'+
                    '            \"amount\": ' + moneyProPrice + ',\n'+
                    '            \"name\": \"ZB Money Pro\",\n'+
                    '            \"serviceName\": \"zb_money_pro\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"monthly\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+
               			zbMoneyPro_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"zb_banking_preferred\": {\n'+
                    '            \"amount\": ' + bankingPreferredPrice + ',\n'+
                    '            \"name\": \"ZenBusiness Banking\",\n'+
                    '            \"serviceName\": \"zb_banking_preferred\",\n'+
                    '            \"type\": \"software\",\n'+
                    '            \"deferred\": false,\n'+
                    '            \"interval\": \"monthly\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"software\",\n'+
                    '            \"choices\": {\n'+
            			preferred_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        },\n'+
                    '        {\n'+
                    '          \"registered_agent_service\": {\n'+
                    '            \"amount\": ' + registeredAgentPrice + ',\n'+
                    '            \"name\": \"Registered Agent\",\n'+
                    '            \"serviceName\": \"registered_agent_service\",\n'+
                    '            \"type\": \"service\",\n'+
                    '            \"deferred\": true,\n'+
                    '            \"interval\": \"annual\",\n'+
                    '            \"priceOrFee\": \"price\",\n'+
                    '            \"renewal\": \"annual\",\n'+
                    '            \"serviceType\": \"service\",\n'+
                    '            \"choices\": {\n'+
                        registeredAgent_choice +'\n'+
                    '            }\n'+
                    '          }\n'+
                    '        }\n'+
                    '      ]\n'+
                    '    }\n';
            }
           
        }
        
        //BUSINESS QUESTIONS        
        String businessName_Question = leadRecord.Company;
        String formationState_Question = salesQuoteRecord.Jurisdiction__c;
        String county_QuestionComplete = '';
        String county_Question;
            /*
        county_QuestionComplete =   
      	'    {'+
		'      \"type\": \"dropdown\",'+
		'      \"question\": \"Formation county\",'+
		'      \"description\": \"The county where you plan to form your business\",'+
        '      \"choices\": [\"' + county_Question + '\"],'+
		'      ],'+
		'      \"questionKey\": \"county\"'+
		'    },';
        */
        
        String howMuchExperience_Question = leadRecord.Business_Experience__c;   
        
        String employeeFirstYear;
        switch on leadRecord.Will_have_employees__c {
            
            when 'no' {
                employeeFirstYear = '        \"no\": \"no\"';
            }
            when '1-5' {
                employeeFirstYear = '        \"betweenOneAndFive\": \"1-5\"';
            }
            when '6-more' {
                employeeFirstYear = '        \"moreThanSix\": \"6-more\"';
            }
            when else {
                employeeFirstYear = '';
            }
        }
   
        String businessAddressDifFromHome = leadRecord.Will_Address_Be_Diff_from_Home__c ? '              \"yes\": \"yes\"' : '              \"no\": \"no\"' ;
        
        String howFarAlongIsBusiness;        
        switch on leadRecord.How_far_along_is_your_business__c {
            
            when 'making-money' {
                howFarAlongIsBusiness = '        \"alreadyMakingMoney\": \"making-money\"';
            }
            when 'launching-soon' {
                howFarAlongIsBusiness = '        \"launchingSoon\": \"launching-soon\"';
            }
            when 'planning-future' {
                howFarAlongIsBusiness = '        \"planningForFuture\": \"planning-future\"';
            }
            when else {
                howFarAlongIsBusiness = '';
            }
        }
        
        String businessGoal; 
        switch on leadRecord.Business_Purpose__c {
            
            when 'side-gig' {
                businessGoal = '        \"sideBusiness\": \"side-gig\"';
            }
            when 'full-time' {
                businessGoal = '        \"primaryIncome\": \"full-time\"';
            }
            when 'huge' {
                businessGoal = '        \"nextBigThing\": \"huge\"';
            }
            when else {
                businessGoal = '';
            }
        }        
        
        String kindOfBusiness = leadRecord.Business_Industry_Type__c;
	        
        String json = '{'+
            '  \"flow\": \"pbf_v3\", \n'+
            '  \"type\": \"'+ typee +'\", \n'+
            '  \"segment\": \"v36\", \n'+
            '  \"firstName\": \"'+ firstName +'\", \n'+
            '  \"lastName\": \"'+ lastName +'\", \n'+
            '  \"phoneNumber\": \"'+ phoneNumber +'\", \n'+
            '  \"email\": \"'+ email +'\",\n'+
            '  \"leadUuid\": \"'+ leadUuId +'\",\n'+
            '  \"plans\": {\n'+
                 plan + '\n'+
          	'  },\n'+
            '  \"businessQuestions\": [\n'+
            '    {\n'+
            '      \"type\": \"open_question\",\n'+
            '      \"question\": \"Preferred business name\",\n'+
            '      \"questionKey\": \"businessName\",\n'+
            '      \"choices\": [\"' + businessName_Question +'\"]\n'+
            '    },\n'+
            '    {\n'+
            '      \"type\": \"dropdown\",\n'+
            '      \"question\": \"Formation state\",\n'+
            '      \"description\": \"The state where you plan to form your business\",\n'+
            '      \"choices\": [\"' + formationState_Question + '\"],\n'+
            '      \"questionKey\": \"domesticJurisdiction\"\n'+
            '    },\n'+
            county_QuestionComplete + '\n'+
            '    {\n'+
            '      \"type\": \"choice_options\",\n'+
            '      \"question\": \"How much experience do you have running a business?\",\n'+
            '      \"choices\": {\n'+
            '        \"' + howMuchExperience_Question + '\": \"' + howMuchExperience_Question + '\"\n'+      
            '      },\n'+
            '      \"questionKey\": \"priorExperience\"\n'+
            '    },\n'+
            '    {\n'+
            '      \"type\": \"choice_options\",\n'+
            '      \"question\": \"Will your business have employees in the first year?\",\n'+
            '      \"choices\": {\n'+
            employeeFirstYear + '\n'+
            '      },\n'+
            '      \"questionKey\": \"employees\"\n'+
            '    },\n'+
            '    {\n'+
            '      \"type\": \"choice_options\",\n'+
            '      \"question\": \"Will your business address be different from your home address?\",\n'+
            '      \"choices\": {\n'+
            businessAddressDifFromHome + '\n'+          
            '      },\n'+
            '      \"questionKey\": \"hasOffice\"\n'+
            '    },\n'+  
            '    {\n'+
            '      \"type\": \"choice_options\",\n'+
            '      \"question\": \"How far along is your business?\",\n'+
            '      \"choices\": {\n'+
         	howFarAlongIsBusiness + '\n'+
            '      },\n'+
            '      \"questionKey\": \"businessStage\"\n'+
            '    },\n'+
            '    {\n'+
            '      \"type\": \"choice_options\",\n'+
            '      \"question\": \"What are your business goals?\",\n'+
            '      \"choices\": {\n'+
      		businessGoal + '\n'+
            '      },\n'+
            '      \"questionKey\": \"businessGoal\"\n'+
            '    },\n'+   
            '    {\n'+
            '      \"type\": \"dropdown\",\n'+
            '      \"question\": \"What kind of business are you forming?\",\n'+
            '      \"description\": \"The industry or sector that best describes your business activities\",\n'+
            '      \"choices\": [\"' + kindOfBusiness + '\"],\n'+
            '      \"questionKey\": \"industryType\"\n'+
            '    }\n'+
            '  ]\n'+
            '}';
            
       return json;
    }
    
  
     
}