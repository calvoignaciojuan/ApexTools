public with sharing class Bicycle extends Vehicle {
  
    public Bicycle(String name) {
      super(name);
    }

    @override
    public void move(){
      system.debug('Bicycle is pedaling');
    }
}