public with sharing class Car extends Vehicle{

    public Car(String name) {
      super(name);
    }

    public override void move(){
      system.debug('Car is driving');
    }
}


Public class BasicClass {

  // Property declaration
  access_modifier return_type property_name {
     get {
        //Get accessor code block
     }
     set {
        //Set accessor code block
     }
  } 
}