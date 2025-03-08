public class AccountManagerController {
  public List<Account> accounts { get; set; }
  public Boolean updateSuccess { get; set; }

  public AccountManagerController() {
      // Fetch first 10 Accounts for display
      accounts = [SELECT Id, Name, Industry FROM Account LIMIT 10];
      updateSuccess= false;
  }

  public void saveAccounts() {
      try {
          update accounts;  // Bulk update the modified accounts
          updateSuccess = true;
      } catch (DmlException e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating accounts: ' + e.getMessage()));
          updateSuccess = false;
      }
  }
}
