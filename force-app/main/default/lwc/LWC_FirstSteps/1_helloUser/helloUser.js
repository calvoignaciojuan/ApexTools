import { LightningElement } from 'lwc';

export default class HelloUser extends LightningElement {

  name = 'User';

  handleChange(event) {
      this.name = event.target.value;
  }
  
}