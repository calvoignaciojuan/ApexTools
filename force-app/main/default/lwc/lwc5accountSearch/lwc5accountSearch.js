import { LightningElement } from 'lwc';

export default class Lwc5accountSearch extends LightningElement {
    accountId = '';

    handleInput(event){
        console.log('input changed');
        this.accountId = event.target.value;
    }

}