import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import SIMPLE_MESSAGE_CHANNEL from '@salesforce/messageChannel/simpleMessageChannel__c';

export default class PublisherComponent extends LightningElement {
    message = '';

    @wire(MessageContext) messageContext;

    handleChange(event) {
        this.message = event.target.value;
    }

    handleSend() {
        const payload = { text: this.message };
        publish(this.messageContext, SIMPLE_MESSAGE_CHANNEL, payload);
    }
}


