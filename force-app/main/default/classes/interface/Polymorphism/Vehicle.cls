public with sharing virtual class Vehicle {
  
  public string name;
  
  public Vehicle(string name) {
    name = name;
  }
  
  public virtual void move(){
    system.debug( name + ' is moving');
  }

}