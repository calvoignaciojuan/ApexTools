public with sharing class AccountControllerAuraThree {
   @AuraEnabled
   public static List<Account> getAccounts() {
       return [SELECT Id, Name FROM Account LIMIT 5];
   }

   @AuraEnabled
   public static Account createAccountApex(String accountName) {
    System.debug('------------------------------------- Creating Account');

    if (String.isEmpty(accountName)) {
        throw new AuraHandledException('Account Name cannot be empty.');
    }

    Account newAcc = new Account(Name = accountName);
    try {
        insert newAcc;

        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :newAcc.Id LIMIT 1];
        if (!accounts.isEmpty()) {
            System.debug('✅ Inserted Account: ' + accounts[0]);
            return accounts[0];
        }
    } catch (Exception e) {
        System.debug('❌ Insert Failed: ' + e.getMessage());
    }

    System.debug('⚠️ Returning Empty Account to Avoid Null');
    return new Account(); // ✅ Prevents returning `null`
}



}