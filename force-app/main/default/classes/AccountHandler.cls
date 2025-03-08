public with sharing class AccountHandler {
    public AccountHandler() {
    }

    public static void afterUpdate(Map<Id,Account> oldAccMap,Map<Id,Account> newAccMap ){
      List<Id> updatedAccountsIds = new List<Id>();

      //firt I check if the field that changed was billing City, if so, I saved the record
      for(Account eachAccount: newAccMap.values()){
        Id newAccId = eachAccount.Id;
        String newBillingCityValue = eachAccount.BillingCity;
        String oldBillingCityValue = oldAccMap.get(newAccId).BillingCity;

        if(newBillingCityValue != oldBillingCityValue){
          updatedAccountsIds.add(newAccId);
        }
      }
      system.debug('------------- >> Accounts that changed ' + updatedAccountsIds.size());

      List<Contact> contactsToUpdate = [select id, MailingCity, accountId from contact where accountId in :updatedAccountsIds ];
      if(!contactsToUpdate.isEmpty()){
        for(Contact eachContact : contactsToUpdate){
          Id relatedAccId = eachContact.AccountId;
          eachContact.MailingCity = newAccMap.get(relatedAccId).BillingCity;
        }
        try{
          update contactsToUpdate;
        }catch(exception e){
          system.debug('there was an error with contacts update');
        }
      }
    }

}