public class AccountMassUpdater {
    public ApexPages.StandardSetController accounts { get; set; }

    public AccountMassUpdater(ApexPages.StandardController stdController) {
        // Get the set controller from the Visualforce page (recordSetVar="accounts")
        this.accounts = (ApexPages.StandardSetController)stdController;
        this.accounts.setPageSize(10);
    }

    public PageReference updateSelected() {
        List<Account> selected = (List<Account>)accounts.getSelected();
        Account prototype = (Account)accounts.getRecord(); // changes to apply

        for (Account acc : selected) {
            acc.Industry = prototype.Industry;
        }

        update selected;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Updated ' + selected.size() + ' accounts.'));
        return null;
    }
}
