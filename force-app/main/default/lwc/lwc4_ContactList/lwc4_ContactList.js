import { LightningElement, wire } from 'lwc';
import getContacts from '@salesforce/apex/ContactControllerLwc4.getContacts';

export default class Lwc4_ContactList extends LightningElement {
    @wire(getContacts) contacts;
}