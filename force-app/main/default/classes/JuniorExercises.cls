public with sharing class JuniorExercises {

//Basic APEX

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
  system.debug(contactManagerNames());

//---------------------------- DML Operations
//  Write a method that updates the phone number of an Account given its Id.
  public void updateAccountPhone(Id accId, String phoneNumber){
    List<Account> accList = [Select id, Phone from Account where id = : accId];
    if(!accList.isEmpty()){
      accList[0].Phone = phoneNumber;
      try{
        update accList;
        System.debug('Account ' + accId + ' phone number has changed to ' + phoneNumber);
      }catch(exception e){
        system.debug('An error was occurred during update');
      }
    }
  }
  updateAccountPhone('001Hn000027ZeauIAC', '1122392925');

//----------------  Object-Oriented Programming in Apex
//Inheritance and Polymorphism
// Create a base class Vehicle with properties speed and fuelType.
// Create subclasses Car and Motorcycle that extend Vehicle and override a method move().
  public virtual Class Vehicle  {
    public integer speed;
    public String fuelType;

    Vehicle(integer speed, String fuelType) {
      this.speed = speed;
      this.fuelType = fuelType;
    }

    public virtual void move(){
      system.debug('the vehicle is moving');
    }
  }

  public class Car extends Vehicle{

    Car(integer speed, String fuelType){
      super(speed,fuelType);
    }

    public override void move(){
      system.debug('the car is moving');
    }

  }

  public class MotorCycle extends Vehicle{

    MotorCycle(integer speed, String fuelType){
      super(speed, fuelType);
    }

    public override void move(){
      system.debug('the Motorcycle is moving');
    }

  }

  void testingClasses(Vehicle veh){
    veh.move();
  }

  Car ca = new Car(100,'diesel');
  MotorCycle mot = new MotorCycle(100,'diesel');

  testingClasses(ca);
  testingClasses(mot);
  
// Encapsulation
// Implement a class BankAccount with private fields balance and accountNumber.
// Provide public methods to deposit, withdraw, and get the balance.
  public class BankAccount {
    private integer accountNumber;
    private integer balance;

    BankAccount(){
      this.accountNumber = 1;
      this.balance = 0;
    }

    public void deposit(integer moneyToDeposit){
      this.balance = this.balance + moneyToDeposit;
    }
    public void withdraw(integer moneyToWithdraw){
      this.balance = this.balance - moneyToWithdraw;
    }
    public integer getTheBalance(){
      return this.balance;
    }
  }

  BankAccount bankAcc = new BankAccount();
  bankAcc.deposit(100);
  bankAcc.withdraw(50);
  system.AssertEquals(50,bankAcc.getTheBalance(),'assertEquals Failed');
  system.debug('execution succeded');

  // Before Insert Trigger
  // Write a trigger on the Contact object that prevents inserting a Contact if no title is provided.
  trigger ContactTrigger on Contact (before insert){
    if(Trigger.isBefore){
      if(Trigger.isInsert){
        //before Insert
        for(Contact eachContact: Trigger.new){
          if(String.isBlank(eachContact.title)){
            eachContact.addError('A Contact cannot be created without a title');
          }
        }
      }
    }
  }


  // After Update Trigger
  // Write a trigger on the Account object that updates all related Contacts' MailingCity when the Account's BillingCity is changed.
  Trigger AccountTrigger on Account(after update){
    if(Trigger.isUpdate){
      if(Trigger.isAfter){
        AccountHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
      }
    }
  }

  public class AccountHandler{

    public static void afterUpdate(Map<Id,Account> oldAccMap,Map<Id,Account> newAccMap ){
      List<Id> updatedAccountsIds = new List<Id>();

      //firt I check if the field that changed was billing City, if so, I saved the record
      for(Account eachAccount: newAccMap.values()){
        Id newAccId = eachAccount.Id;
        String newBillingCityValue = eachAccount.BillingCity;
        String oldBillingCityValue = newAccMap.get(newAccId).BillingCity;

        if(newBillingCityValue != oldBillingCityValue){
          updatedAccountsIds.add(newAccId);
        }
      }

      List<Contacts> contactsToUpdate = [select id, MailingCity, accountId from contact where accountId in :updatedAccountsIds ];
      if(!contactsToUpdate.isEmpty()){
        for(Contact eachContact : contactsToUpdate){
          Id relatedAccId = eachContact.AccountId;
          eachContact.MailingCity = newAccMap.get(relatedAccId).BillingCity;
        }
        try{
          update contactsToUpdate;
        }catch(exception e){
          system.debug('there was an error with contacts update');
        }
      }
    }
  }
  //Relationships 
  //I have a Order object and an Order Item Object, each Order can have many Order items related to it
  List<Order__C> OrderList = [select id, name, (select id, Name from Order_Items__r) from Order__c];
  for(Order__C eachOrderList : OrderList){
      system.debug('------------ Order name: ' + eachOrderList.Name);
      if(!eachOrderList.Order_Items__r.isEmpty()){
          for(Order_Item__c eachOrderItem : eachOrderList.Order_Items__r){
              system.debug('-- Order Item name: ' + eachOrderItem.Name);
          }
      }
  }






  List<Account> accList = [SELECT Id FROM Account];
  system.debug(accList.size());









































}

