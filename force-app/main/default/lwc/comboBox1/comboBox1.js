import { LightningElement, api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import STATE_FIELD from '@salesforce/schema/Lead.State__c';

export default class ComboBox1 extends LightningElement {

    @api recordId;
    value = "TX";
    picklistValues = [];

    //getting State Picklist Values
    @wire(getPicklistValues, { recordTypeId: '012Hn000000CEwRIAW', fieldApiName: STATE_FIELD })
    getPicklistValuesForField({ data, error }) {
      if (error) {
        // TODO: Error handling
        console.error(error);
      } else if (data) {
        this.picklistValues = [...data.values];
      }
    }
    
    handleChange(event){
      this.value = event.detail.value;
      console.log(event.detail.value);
    }

    /*
        get options() {
      return [
          { label: 'New', value: 'new' },
          { label: 'In Progress', value: 'inProgress' },
          { label: 'Finished', value: 'finished' },
          { label: 'Finished1', value: 'finished1' },
          { label: 'Finished2', value: 'finished2' },
          { label: 'Finished3', value: 'finished3' },
          { label: 'Finished4', value: 'finished4' },
          { label: 'Finished5', value: 'finished5' },
          { label: 'Finished6', value: 'finished6' },
          { label: 'Finished7', value: 'finished7' },
          { label: 'Finished8', value: 'finished8' },
          { label: 'Finished9', value: 'finished6' },
      ];
    }
      */

    
}