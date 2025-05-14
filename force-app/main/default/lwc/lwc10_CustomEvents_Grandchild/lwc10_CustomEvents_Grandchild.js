import { LightningElement } from 'lwc';

export default class Lwc10_CustomEvents_Grandchild extends LightningElement {

    handleClickNoBubblesNoComposed() {
        const event = new CustomEvent('sayhello', {
            detail: { msg: 'Bubbles: FALSE Composed: FALSE' }
        });
       this.template.querySelector('.grandChild').dispatchEvent(event);
    }

    handleClickBubblesNoComposed() {
        const event = new CustomEvent('sayhello', {
            bubbles: true,
            composed: false,
            detail: { msg: 'Bubbles: TRUE Composed: FALSE' }
        });
         this.template.querySelector('.grandChild').dispatchEvent(event);
        //console.log('Event dispatched from GRANDCHILD');
    }

    handleClickBubblesComposed() {
        const event = new CustomEvent('sayhello', {
            bubbles: true,
            composed: true,
            detail: { msg: 'Bubbles: TRUE Composed: TRUE' }
        });
        this.dispatchEvent(event);
        //console.log('Event dispatched from GRANDCHILD');
    }

    //----------    listeners

    handleSayHello(event) {
        console.log('GRANDCHILD received event: ', event.detail.msg);
        //alert(event.detail.msg);
    }

    handleSayHelloInnerParent(event){
       console.log('GRANDCHILD(InnerGrantChilds Parent) received event: ', event.detail.msg);
    }
}