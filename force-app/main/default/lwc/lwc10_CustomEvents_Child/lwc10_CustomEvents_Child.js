import { LightningElement } from 'lwc';

export default class Lwc10_CustomEvents_Child extends LightningElement {

    handleSayHello(event) {
        console.log('CHILD received event: ', event.detail.msg);
        //alert('CHILD received event: ' + event.detail.msg);
    }

}