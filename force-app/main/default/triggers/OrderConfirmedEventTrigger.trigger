trigger OrderConfirmedEventTrigger on Order_Confirmed__e (after insert) {
    system.debug('inside trigger');
    for(Order_Confirmed__e eachNewEvent: Trigger.new ){
        //System.debug('eachNewEvent.id:' + eachNewEvent.Id);
        System.debug('eachNewEvent.Order_Id__c:' + eachNewEvent.Order_Id__c);
        System.debug('eachNewEvent.Status__c:' + eachNewEvent.Status__c);
    }
}