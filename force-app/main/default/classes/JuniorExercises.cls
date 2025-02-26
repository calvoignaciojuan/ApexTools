public with sharing class JuniorExercises {

//------------------------   SOQL practice
// Write a method that retrieves all Contacts with the title "Manager" and returns a list of their names.
  public List<String> contactManagerNames(){
    List<String> contactNamesResult = new List<string>();
    List<Contact> contQuery = [select id, Name from Contact where Title like '%Manager%'];
    if(!contQuery.isEmpty()){
      system.debug('there are ' + contQuery.size() + ' Contacts' );
      for(Contact con : contQuery){
        contactNamesResult.add(con.Name);
      }
    }else{


      system.debug('it is empty');
    }

    return contactNamesResult;
  }

  //system.debug(contactManagerNames());

//---------------------------- DML Operations
//  Write a method that updates the phone number of an Account given its Id.


}//