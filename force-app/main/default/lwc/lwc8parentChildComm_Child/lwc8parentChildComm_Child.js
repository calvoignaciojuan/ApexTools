import { LightningElement, api } from 'lwc';

export default class ChildComponent extends LightningElement {
    @api name;

    handleInput(event) {
        const updatedName = event.target.value;

        // Send new name to parent using custom event
        this.dispatchEvent(new CustomEvent('namechange', {
            detail: updatedName
        }));
    }
}
