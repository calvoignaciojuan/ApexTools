public with sharing class ContactControllerApex {

    @AuraEnabled
    public static Map<Id,Contact> getContactsApex() {

        return new Map<Id, Contact>([SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 5]);
    }

   @AuraEnabled(cacheable=true)
   public static Map<Id,Contact> getContactsMapApex() {

       return new Map<Id, Contact>([SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 5]);
   }

   @AuraEnabled(cacheable=true)
   public static List<Contact> getContactsListApex() {

        return [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 5];
    }


   @AuraEnabled
   public static Contact updateContactApex(String contactId, String newFirstName) {

       Contact c = [SELECT Id, FirstName FROM Contact WHERE Id = :contactId LIMIT 1];
       c.FirstName = newFirstName;
       update c;
       return c;
   }
}


