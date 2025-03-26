import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getContactMap from '@salesforce/apex/ContactControllerApex.getContactsMapApex';
import updateContact from '@salesforce/apex/ContactControllerApex.updateContactApex';

export default class Lwc7ContactListSearchAndUpdate extends LightningElement {

    contactMap = new Map();
    contactList = [];
    contactListOptions = [];
    error = [];
    isLoading = true;
    selectedContactName = ''; 
    newFirstName = ''; 
    selectedOptionId = '';
    wiredContactResult;
  
    @wire(getContactMap) 
     wiredGetContactList(result){
        this.wiredContactResult = result; 
        const { data, error } = result;
        if(data){
            this.isLoading = false;
            this.contactMap = data;
            this.contactList = Object.values(data);
            this.contactListOptions = this.contactList.map( function(eachContact){
                const first = eachContact.FirstName || '';
                const last = eachContact.LastName || '';
                const label = `${first} ${last}`.trim();
                return ({ label: label, value: eachContact.Id });
            });
        }else if (error) {
            this.error = error;
        }
     }

    handleChangeOnRadioGroup(event) {
        this.selectedOptionId = event.detail.value;
        console.log('Option selected with value: ' + this.selectedOptionId);

        const contact = this.contactMap[this.selectedOptionId];
        if (contact) {
            const first = contact.FirstName || '';
            const last = contact.LastName || '';
            this.selectedContactName = `${first} ${last}`.trim();
        } else {
            this.selectedContactName = 'name undefined';
        }  
        console.log('exit handleChangeOnRadioGroup');      
    }

    handleInputChanged(event){
        this.newFirstName = event.target.value;
    }

    handleClickUpdate(){
        console.log('Button was clicked!');
        //alert(`Hello, ${this.newFirstName || 'stranger'}!`);

        updateContact({ 
            contactId: this.selectedOptionId, 
            newFirstName: this.newFirstName 
        })
        .then(() => {
            console.log('Contact updated!');
            this.newFirstName = '';  
            return refreshApex(this.wiredContactResult);      
        })
        .catch(error => {
            console.error('Error updating contact:', error);
        });
    }

    connectedCallback(){
        console.log('========================       connectedCallback   ');
    }
    renderedCallback(){
        console.log('========================       renderedCallback   ');
    }
}

