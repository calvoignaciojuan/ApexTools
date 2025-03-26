import { LightningElement, wire } from 'lwc';
import getContacts from '@salesforce/apex/ContactControllerApex.getContactsListApex';

export default class MyContacts extends LightningElement {
    contacts = [];
    error;
    isLoading = true;

    @wire(getContacts)
    wiredContacts({ data, error }) {
        this.isLoading = false;
        console.log('data: ', data);
        if (data) {
            this.contacts = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contacts = [];
        }
    }
}
