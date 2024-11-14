public class LeadOrderingAPI {
	

  public void console(){

    List<Account> accs = [select id, Name from Account order by Name DESC limit 10];
    for(Account eachAcc : accs){
      system.debug('---------');
      system.debug('Account Name: ' + eachAcc.Name);
    }

    //Parent to Child Query
    List<Account> accList = [SELECT Id, Name, (select id, name from Contacts) FROM Account where id = '001Hn00001yYERRIA4'];

    for(Account eachAcc : accList){
      system.debug('---------');
      system.debug('Account Name: ' + eachAcc.Name);
      for(Contact eachContact : eachAcc.Contacts){
        system.debug('Contact Name: ' + eachContact.Name);
      }
    }

    //SOSL
    List<List<sObject>> results = [
      Find 'United*' 
         IN ALL FIELDS
        RETURNING 
          Account (Id, Name, Phone WHERE Type = 'Customer - Direct' LIMIT 10),
          Contact (Id, Name, Title ORDER BY Name)];

    for(integer i=0; i < results.size(); i++){
      if(!results[i].isEmpty()){
        system.debug('object in index ' + i + ' has ' + results[i].size() + ' records');
      }else{
        system.debug('object in index ' + i + ' has no records');
      }
    }

  }



  static String json = '{"affiliate":"pbf_v3","type":"llc","segment":"v36","firstName":"","lastName":"","phoneNumber":"","email":"","leadUuid":"","plans":{"Starter Plan":{"price":0,"includedServices":[{"amount":0,"name":"Standard","serviceName":"standard","type":"service","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"service","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Tax Savings Consultation","serviceName":"1800_accountant","type":"offer","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"offer","choices":{"yes":"yes","no":"no"}}],"upsells":[{"amount":79,"name":"Rush","serviceName":"rush","type":"service","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"service","choices":{"yes":"yes","no":"no"}},{"amount":15,"name":"Business Website","serviceName":"static_website","type":"software","deferred":false,"interval":"monthly","priceOrFee":"price","renewal":"annual","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":30,"name":"ZB Money Pro","serviceName":"zb_money_pro","type":"service","deferred":false,"interval":"monthly","priceOrFee":"price","renewal":"annual","serviceType":"service","choices":{"no":"zbmoney-no","annually":"zbmoney-annually","monthly":"zbmoney-monthly"}},{"amount":5,"name":"ZenBusiness Banking","serviceName":"zb_banking_preferred","type":"software","deferred":false,"interval":"monthly","priceOrFee":"price","renewal":"annual","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":149,"name":"EIN and Business Documents bundle","serviceName":"ein_business_docs_bundle","type":"plan","deferred":true,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"plan","choices":{"yes":"yes","no":"no"}},{"amount":99,"name":"Business Document Templates Library","serviceName":"corporate_docs","type":"service","deferred":true,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"service","choices":{"yes":"yes","no":"no"}},{"amount":99,"name":"EIN Creation","serviceName":"ein_creation","type":"service","deferred":true,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"service","choices":{"yes":"yes","no":"no"}},{"amount":99,"name":"Operating Agreement Template","serviceName":"operating_agreement","type":"software","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":199,"amountAfterCoupon":0,"name":"Worry Free Compliance","serviceName":"worry_free_service","type":"software","deferred":true,"interval":"annual","priceOrFee":"price","renewal":"annual","serviceType":"software","coupon":{"coupon_uuid":"5bebaf6a-8484-419e-91fc-50c6058f5a83","amount":199,"external_coupon_id":"199_off_first_year","created_datetime":"2022-04-26T19:22:21.197996Z","updated_datetime":"2022-04-26T19:22:21.198014Z","type":"absolute","is_fees_discount":false,"duration":"forever","stripe_id":null},"choices":{"yes":"yes","no":"no"}},{"amount":199,"name":"Registered Agent","serviceName":"registered_agent_service","type":"service","deferred":true,"interval":"annual","priceOrFee":"price","renewal":"annual","serviceType":"service","choices":{"yes":"ra-yes","no":"ra-no"}}]},"Pro Plan":{"price":199,"includedServices":[{"amount":0,"name":"Rush","serviceName":"rush","type":"service","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"service","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Operating Agreement Template","serviceName":"operating_agreement","type":"software","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"EIN Creation","serviceName":"ein_creation","type":"service","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"service","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Tax Savings Consultation","serviceName":"1800_accountant","type":"offer","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"offer","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Worry Free Compliance","serviceName":"worry_free_service","type":"software","deferred":false,"interval":"annual","priceOrFee":"price","renewal":"annual","serviceType":"software","choices":{"yes":"yes","no":"no"}}],"upsells":[{"amount":15,"name":"Business Website","serviceName":"static_website","type":"software","deferred":false,"interval":"monthly","priceOrFee":"price","renewal":"annual","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":30,"name":"ZB Money Pro","serviceName":"zb_money_pro","type":"service","deferred":false,"interval":"monthly","priceOrFee":"price","renewal":"annual","serviceType":"service","choices":{"no":"zbmoney-no","annually":"zbmoney-annually","monthly":"zbmoney-monthly"}},{"amount":5,"name":"ZenBusiness Banking","serviceName":"zb_banking_preferred","type":"software","deferred":false,"interval":"monthly","priceOrFee":"price","renewal":"annual","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":99,"name":"Business Document Templates Library","serviceName":"corporate_docs","type":"service","deferred":true,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"service","choices":{"yes":"yes","no":"no"}},{"amount":199,"name":"Registered Agent","serviceName":"registered_agent_service","type":"service","deferred":true,"interval":"annual","priceOrFee":"price","renewal":"annual","serviceType":"service","choices":{"yes":"ra-yes","no":"ra-no"}}]},"Premium Plan":{"price":349,"includedServices":[{"amount":0,"name":"Basic Email","serviceName":"basic_email","type":"software","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Domain Name Privacy","serviceName":"domain_name_privacy","type":"software","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Domain Name Registration","serviceName":"domain_name_reg","type":"software","deferred":false,"interval":"annual","priceOrFee":"price","renewal":"annual","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Business Website","serviceName":"static_website","type":"software","deferred":false,"interval":"annual","priceOrFee":"price","renewal":"annual","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Business Document Templates Library","serviceName":"corporate_docs","type":"service","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"service","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Rush","serviceName":"rush","type":"service","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"service","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"EIN Creation","serviceName":"ein_creation","type":"service","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"service","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Operating Agreement Template","serviceName":"operating_agreement","type":"software","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Tax Savings Consultation","serviceName":"1800_accountant","type":"offer","deferred":false,"interval":"onetime","priceOrFee":"price","renewal":"never","serviceType":"offer","choices":{"yes":"yes","no":"no"}},{"amount":0,"name":"Worry Free Compliance","serviceName":"worry_free_service","type":"software","deferred":false,"interval":"annual","priceOrFee":"price","renewal":"annual","serviceType":"software","choices":{"yes":"yes","no":"no"}}],"upsells":[{"amount":30,"name":"ZB Money Pro","serviceName":"zb_money_pro","type":"service","deferred":false,"interval":"monthly","priceOrFee":"price","renewal":"annual","serviceType":"service","choices":{"no":"zbmoney-no","annually":"zbmoney-annually","monthly":"zbmoney-monthly"}},{"amount":5,"name":"ZenBusiness Banking","serviceName":"zb_banking_preferred","type":"software","deferred":false,"interval":"monthly","priceOrFee":"price","renewal":"annual","serviceType":"software","choices":{"yes":"yes","no":"no"}},{"amount":199,"name":"Registered Agent","serviceName":"registered_agent_service","type":"service","deferred":true,"interval":"annual","priceOrFee":"price","renewal":"annual","serviceType":"service","choices":{"yes":"ra-yes","no":"ra-no"}}]}}}';
      
    //JSON Response deserialize
        //Names of properties have to be exactly like keys in JSON. If keys have spaces or whatever you could use
        //json.replaceAll('"Starter Plan":', '"starterPlan":'); to change for the key as you wish.
        public class QuestionDetails{
        	public String questionType { get; set; }
            public String question { get; set; }
            public String questionKey { get; set; }
            public String description { get; set; }
            public List<String> choices { get; set; }
        }
    	
    	 public class Coupon{  //worry free compliance
            public String  coupon_uuid { get; set; }
            public integer amount { get; set; }
            public String  external_coupon_id { get; set; } 
            public String  created_datetime { get; set; }  
            public String  updated_datetime { get; set; }   
            public String  typee { get; set; }   
            public boolean is_fees_discount { get; set; }  
            public String  duration { get; set; }  
            public String  stripe_id { get; set; }   
    	}
    
        public class ChoiceOptions{
            public String yes { get; set; }
            public String no { get; set; }
            public String annually { get; set; }  //money pro
            public String monthly { get; set; }   //money pro
    	}
    
        public class ServiceDetails{
        	public Integer amount { get; set; }
            public Integer amountAfterCoupon  { get; set; } //worry free compliance
            public String  name { get; set; }
            public String  serviceName { get; set; }
            public String  typee { get; set; }
            public boolean deferred { get; set; }
            public String  interval  { get; set; }
            public String  priceOrFee  { get; set; }
            public String  renewal  { get; set; }
            public String  serviceType  { get; set; }
            public Coupon  coupon  { get; set; }          //worry free compliance
            public ChoiceOptions  choices  { get; set; }
        }
    
    	public class PlanDetails{
        	public integer price { get; set; }
            public List<ServiceDetails> includedServices { get; set; }
        	public List<ServiceDetails> upsells { get; set; }           
        }    
    
        public class PlanTypes {        
          	public PlanDetails starterPlan { get; set; }        
          	public PlanDetails proPlan { get; set; }          
          	public PlanDetails premiumPlan { get; set; }         
      	}
    
		public class JsonResponse {
            public String affiliate { get; set; }
            public String companyType { get; set; }
            public String segment { get; set; }
            public String firstName { get; set; }
            public String lastName { get; set; }
            public String phoneNumber { get; set; }
            public String email { get; set; }
            public String leadUuid { get; set; }
            public PlanTypes  plans { get; set; }
        }
    
    public static string parseJsonKeys(string json){
        //Names of properties have to be exactly like keys in JSON. If keys have spaces or whatever you could use
        //json.replaceAll('"Starter Plan":', '"starterPlan":'); to change for the key as you wish.
        String jsonStr = json.replaceAll('"Starter Plan":', '"starterPlan":');
        jsonStr = jsonStr.replaceAll('"Pro Plan":', '"proPlan":');
        jsonStr = jsonStr.replaceAll('"Premium Plan":', '"premiumPlan":');
        jsonStr = jsonStr.replaceAll('"type":', '"typee":');
        
        return jsonStr;        
    }
    
    public static void deserialize(){
        
        try{
            
            JsonResponse response = (JsonResponse) JSON.deserialize(parseJsonKeys(json), JsonResponse.class);
                      
            System.debug('affiliate: ' + response.affiliate);
            System.debug('companyType: ' + response.companyType);
            System.debug('segment: ' + response.segment);
            System.debug('firstName: ' + response.firstName);
            System.debug('lastName: ' + response.lastName);
            System.debug('phoneNumber: ' + response.phoneNumber);
            System.debug('email: ' + response.email);
            System.debug('leadUuid: ' + response.leadUuid);
            System.debug('++++++++++++++++++++++++++++++++++++   starterPlan   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++'); 
            System.debug('response.plans.starterPlan.Price: ' + response.plans.starterPlan.Price);
            System.debug('-------------------------------------------------------     included Services: -----------------------');
            for(ServiceDetails eachServiceDetail : response.plans.starterPlan.includedServices){
            	System.debug('amount: ' + eachServiceDetail.amount);
                //if(eachServiceDetail.name == 'Worry Free Compliance')
                System.debug('amountAfterCoupon: ' + eachServiceDetail.amountAfterCoupon);
                System.debug('name: ' + eachServiceDetail.name);
                System.debug('serviceName: ' + eachServiceDetail.serviceName);
                System.debug('typee: ' + eachServiceDetail.typee);
                System.debug('deferred: ' + eachServiceDetail.deferred);
                System.debug('interval: ' + eachServiceDetail.interval);
                System.debug('priceOrFee: ' + eachServiceDetail.priceOrFee);
                System.debug('renewal: ' + eachServiceDetail.renewal);
                System.debug('serviceType: ' + eachServiceDetail.serviceType);
                //if(eachServiceDetail.name == 'Worry Free Compliance')
                System.debug('coupon: ' + eachServiceDetail.coupon);
                System.debug('choices: ' + eachServiceDetail.choices);
            }
            
            System.debug('++++++++++++++++++++++++++++++++++++   proPlan   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++'); 
            System.debug('response.plans.starterPlan.Price: ' + response.plans.proPlan.Price);
            System.debug('-------------------------------------------------------     included Services: -----------------------');
            for(ServiceDetails eachServiceDetail : response.plans.proPlan.includedServices){
            	System.debug('amount: ' + eachServiceDetail.amount);
                //if(eachServiceDetail.name == 'Worry Free Compliance')
                System.debug('amountAfterCoupon: ' + eachServiceDetail.amountAfterCoupon);
                System.debug('name: ' + eachServiceDetail.name);
                System.debug('serviceName: ' + eachServiceDetail.serviceName);
                System.debug('typee: ' + eachServiceDetail.typee);
                System.debug('deferred: ' + eachServiceDetail.deferred);
                System.debug('interval: ' + eachServiceDetail.interval);
                System.debug('priceOrFee: ' + eachServiceDetail.priceOrFee);
                System.debug('renewal: ' + eachServiceDetail.renewal);
                System.debug('serviceType: ' + eachServiceDetail.serviceType);
                //if(eachServiceDetail.name == 'Worry Free Compliance')
                System.debug('coupon: ' + eachServiceDetail.coupon);
                System.debug('choices: ' + eachServiceDetail.choices);
            }
                    
            System.debug('++++++++++++++++++++++++++++++++++++   premiumPlan   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++'); 
            System.debug('response.plans.starterPlan.Price: ' + response.plans.premiumPlan.Price);
            System.debug('-------------------------------------------------------     included Services: -----------------------');
            for(ServiceDetails eachServiceDetail : response.plans.premiumPlan.includedServices){
            	System.debug('amount: ' + eachServiceDetail.amount);
                //if(eachServiceDetail.name == 'Worry Free Compliance')
                System.debug('amountAfterCoupon: ' + eachServiceDetail.amountAfterCoupon);
                System.debug('name: ' + eachServiceDetail.name);
                System.debug('serviceName: ' + eachServiceDetail.serviceName);
                System.debug('typee: ' + eachServiceDetail.typee);
                System.debug('deferred: ' + eachServiceDetail.deferred);
                System.debug('interval: ' + eachServiceDetail.interval);
                System.debug('priceOrFee: ' + eachServiceDetail.priceOrFee);
                System.debug('renewal: ' + eachServiceDetail.renewal);
                System.debug('serviceType: ' + eachServiceDetail.serviceType);
                //if(eachServiceDetail.name == 'Worry Free Compliance')
                System.debug('coupon: ' + eachServiceDetail.coupon);
                System.debug('choices: ' + eachServiceDetail.choices);
            }
            
        }catch (JSONException e) {
            // Handle the error
            System.debug(e.getMessage());
            System.debug(e);
        }
    }  
    
    public static void deserialize(string responseBody){
        
      try{
        JsonResponse response = (JsonResponse) JSON.deserialize(parseJsonKeys(responseBody), JsonResponse.class);
        //Now I can access to the JSON data like it was an object

      }catch (JSONException e) {
        // Handle the error
        System.debug(e.getMessage());
        System.debug(e);
      }
    }

    public static void makeAPICallout() {
        // Define the endpoint URL
        String endpoint = 'https://www.dev.zenbusiness.com/r2/plan-details/plans?pbfVersion=v3';

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




    //To be able to call the method from a FLOW
      @InvocableMethod(label='Get Funnel Data')
      public static List<OutputVariables> getFunnelData( List<InputVariables> inputVariables ){
          
      }
      
      public class InputVariables {
          @InvocableVariable
          public List<String> records;        
          @InvocableVariable
          public List<String> records2;
      }
      
      public class OutputVariables {
          
          @InvocableVariable
          public List<String> packages;        
          @InvocableVariable
          public List<String> includedServices;
      }
     
}