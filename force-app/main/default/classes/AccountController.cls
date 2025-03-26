public with sharing class AccountController {
    public AccountController() {

    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name, Industry FROM Account LIMIT 10];
    }  
   
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByAccountId(Id accountId) {
        system.debug('getContactsByAccountId called - >>    accountId: ' + accountId);
        if (String.isBlank(accountId)) 
            return new List<Contact>();
        return [SELECT Id, FirstName, LastName, Email FROM Contact WHERE AccountId = :accountId LIMIT 10];
    }       

}