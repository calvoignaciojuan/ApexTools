import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import SIMPLE_MESSAGE_CHANNEL from '@salesforce/messageChannel/simpleMessageChannel__c';

export default class SubscriberComponent extends LightningElement {
    receivedMessage = '';
    subscription=null;
    @wire(MessageContext) messageContext;
    
    subscribeToMessageChannel(){
        if(!this.subscription){
            this.subscription = subscribe( this.messageContext,
                                           SIMPLE_MESSAGE_CHANNEL,
                                           (message) => this.handleMessage(message)
                                );
        }       
    }
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    handleMessage(message) {
        this.receivedMessage = message.text;
    }
    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
    }
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
}
