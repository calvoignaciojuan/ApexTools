public with sharing class CustomAccountControllerSortingVF {
    
  public String selectedOption { get; set; } 

   public CustomAccountControllerSortingVF(){
      selectedOption = 'Name';
   }

  // default field used for sorting the records
  public List<Account> getAccounts() {
      List<Account> accounts = Database.query('SELECT Id,Name, BillingState, BillingCountry ' + ' FROM Account WHERE BillingCountry != \'\' ORDER BY ' + selectedOption + ' LIMIT 10');
      return accounts;
  }
 
  public PageReference save() { 
    
    return null; 
  } 


}