public with sharing class Dog implements AnimalBehavior {
    public Dog() {

    }

    public void makeSound(){
      system.debug('buff buff');
    }
    
    public void move(){
      system.debug('dog moving');
    }
    
    
}