import { LightningElement, api, wire } from 'lwc';
import getContactsByAccountId from '@salesforce/apex/AccountControllerApex.getContactsByAccountId';

export default class AccountContacts extends LightningElement {
    @api accountId = '';
    contacts;
    error;

    @wire(getContactsByAccountId, { accountId: '$accountId' }) 
    contacts({data,error}){
        console.log('accountId: ', this.accountId);
        console.log('data: ', data);
        console.log('error: ', error);
        if (data) {
            this.contacts = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    };
}
