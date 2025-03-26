({
   doInit: function(component, event, helper) {
       helper.fetchContacts(component);
   },

   selectContact: function(component, event, helper) {

       var contactId = event.getSource().get("v.value"); //Getting the Id from the value of the button
       var contactsMap = component.get("v.contactsMap");

       var contact = contactsMap[contactId];   //getting a value from a auraMap

       component.set("v.oldFirstName", contact.FirstName);
       component.set("v.selectedContactId", contactId);
   },

   updateContact: function(component, event, helper) {
       helper.saveContact(component);
   }
});



