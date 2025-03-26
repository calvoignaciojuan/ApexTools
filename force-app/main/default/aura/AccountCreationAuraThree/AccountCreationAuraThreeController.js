({
   doInit: function(component, event, helper) {
       helper.fetchAccounts(component);
   },

   createAccountController: function(component, event, helper) {
       helper.saveAccount(component);
   }
})
