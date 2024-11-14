public with sharing class Cat implements AnimalBehavior{
    
  public Cat() {

  }

  public void makeSound(){
    system.debug('miauu miauu');
  }

  public void move(){
    system.debug('cat moving');
  }
}