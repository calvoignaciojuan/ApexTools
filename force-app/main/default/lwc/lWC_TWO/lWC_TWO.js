import { LightningElement } from 'lwc';

export default class HelloWorld extends LightningElement {
    message = 'Hello, LWC!';

    handleClick() {
        this.message = 'You clicked the button!';
    }
}
