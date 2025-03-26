({
   fetchAccounts: function(component) {
       var action = component.get("c.getAccounts");
       
       action.setCallback(this, function(response) {
           if (response.getState() === "SUCCESS") {
               component.set("v.accounts", response.getReturnValue());
           } else {
               console.error("Error fetching accounts:", response.getError());
           }
       });

       $A.enqueueAction(action);
   },

   saveAccount: function(component) {
      var action = component.get("c.createAccountApex");
      var accountName = component.get("v.newAccountName");

      action.setParams({ accountName: accountName });

      console.log('⚡ Before setting callback');
      console.log('📡 Calling Apex createAccount with parameter:', accountName);

      action.setCallback(this, $A.getCallback(function(response) {
          console.log('⚡ Inside callback');

          var state = response.getState();
          console.log('⚡ Response State:', state);

          if (state === "SUCCESS") {
               console.log('✅ Success action');

               var newAccount = response.getReturnValue();
               console.log("🔍 Raw Apex Response:", newAccount);

               if (newAccount && newAccount.Id) {
                   var existingAccounts = component.get("v.accounts") || [];
                   var updatedAccounts = [...existingAccounts, newAccount];

                   component.set("v.accounts", updatedAccounts);
                   component.set("v.newAccountName", "");              
               } else {
                   console.error("❌ Apex returned invalid data. Likely `null` or an empty object:", newAccount);
               }
          } else {
              console.error("❌ Error creating account:", response.getError());
          }
      }));

      console.log('⚡ Before enqueueing action');
      $A.enqueueAction(action);
      console.log('⚡ After enqueueing action');
   }
})
