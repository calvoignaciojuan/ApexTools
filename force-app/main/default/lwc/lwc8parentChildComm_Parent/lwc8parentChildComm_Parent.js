import { LightningElement } from 'lwc';

export default class ParentComponent extends LightningElement {
    fullName = 'Ada Lovelace';

    handleNameChange(event) {
        this.fullName = event.detail; // receives updated name from child
    }
}
