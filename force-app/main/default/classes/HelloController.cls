public class HelloController {
  public List<Account> accounts { get; set; }
  public Boolean updateSuccess { get; set; }

  public HelloController() {
      // Fetch first 10 Accounts for display
      updateSuccess = false;
      accounts = [SELECT Id, Name, Industry FROM Account LIMIT 10];
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
