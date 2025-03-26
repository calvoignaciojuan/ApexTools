public with sharing class ContactControllerLwc4 {
    public ContactControllerLwc4() {

    }
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        return [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 5];
    }
    
    
}