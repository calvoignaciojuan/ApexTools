({
   fetchContacts: function(component) {
      var action = component.get("c.getContactsApex"); //Connection with Apex
    
      action.setCallback(this, function(response) {         
          var state = response.getState();    
  
          if (state === "SUCCESS") {
              var contactsMap = response.getReturnValue();             
              component.set("v.contactsMap", contactsMap);
  
              // Convert Map values into a List for iteration
              var contactsList = Object.values(contactsMap);           
              component.set("v.contactsList", contactsList);
          } else {
              console.error("❌ Error fetching contacts:", response.getError());
          }
      });  
      $A.enqueueAction(action);      
   },
   saveContact: function(component) {
       var action = component.get("c.updateContactApex");
       var contactId = component.get("v.selectedContactId");
       var newFirstName = component.get("v.newFirstName");
       action.setParams({ contactId: contactId, newFirstName: newFirstName });
       action.setCallback(this, function(response) {
           if (response.getState() === "SUCCESS") {   
               component.set("v.newFirstName",""); // Clean input text         
               this.fetchContacts(component); // Refresh list
           } else {
               console.error("❌ Error updating contact:", response.getError());
           }
       });
       $A.enqueueAction(action);
   }
});


