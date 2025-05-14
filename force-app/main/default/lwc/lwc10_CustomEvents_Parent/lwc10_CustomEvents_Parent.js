import { LightningElement } from 'lwc';

export default class Lwc10_CustomEvents_Parent extends LightningElement {

    handleSayHello(event) {
        console.log('PARENT received event: ', event.detail.msg);
        //alert('PARENT received event: ' + event.detail.msg);
    }
}