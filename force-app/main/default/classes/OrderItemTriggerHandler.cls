public with sharing class OrderItemTriggerHandler {

    public static void afterInsert(List<Order_Item__C> newOrderItemList) {

      Set<Id> ParentOrdersOfItemInserted_Set = new Set<Id>();
      if(!newOrderItemList.isEmpty()){
        for(Order_Item__C eachOrderItem : newOrderItemList){
          ParentOrdersOfItemInserted_Set.add(eachOrderItem.order__c);
        }
      }
      if(!ParentOrdersOfItemInserted_Set.isEmpty()){
        Map<Id,Order__C> parentOrdersList = new Map<Id,Order__C>([Select id, Total_Amount__c from Order__c where id in :ParentOrdersOfItemInserted_Set]);
        if(!parentOrdersList.isEmpty()){
          for(Order_Item__C eachOrderItem :newOrderItemList){
            decimal quantity = eachOrderItem.quantity__c;
            decimal amount = eachOrderItem.Amount__c;
            decimal actualOrderAmount = parentOrdersList.get(eachOrderItem.order__c).Total_Amount__c;
            
            parentOrdersList.get(eachOrderItem.order__c).Total_Amount__c = actualOrderAmount + amount*quantity;
          }
        }
        update parentOrdersList.values();
      }
    }
    
    public static void beforeUpdate(List<Order_Item__C> newOrderItemList){
       if(!newOrderItemList.isEmpty()){
        for(Order_Item__C eachOrderItem : newOrderItemList){
          if(eachOrderItem.quantity__c < 0){
            eachOrderItem.addError('Quantity cannot be negative');
          }
        }
      }
    }

    public static void afterUpdate(Map<Id,Order_Item__C> newOrderItemList, Map<id,Order_Item__C> oldOrderItemList){
      
      List<Order_Item__C> orderItemAmountChangedList = new List<Order_Item__C>();

      if(!newOrderItemList.isEmpty()){
        for(Order_Item__C eachNewOrderItem : newOrderItemList.values()){
          decimal oldAmount = oldOrderItemList.get(eachNewOrderItem.id).Amount__c;
          decimal newAmount = eachNewOrderItem.Amount__c;
          if(newAmount != oldAmount){
            orderItemAmountChangedList.add(eachNewOrderItem);
          }
        }
        if(!orderItemAmountChangedList.isEmpty()){
          Set<Id> ParentOrdersOfItemUpdated_Set = new Set<Id>();         
          for(Order_Item__C eachOrderItem : orderItemAmountChangedList){
            ParentOrdersOfItemUpdated_Set.add(eachOrderItem.order__c);
          }
          if(!ParentOrdersOfItemUpdated_Set.isEmpty()){
            Map<Id,Order__C> parentOrdersList = new Map<Id,Order__C>([Select id, Total_Amount__c from Order__c where id in :ParentOrdersOfItemUpdated_Set]);
            if(!parentOrdersList.isEmpty()){
              for(Order_Item__C eachOrderItem :newOrderItemList.values()){
                decimal newQuantity = eachOrderItem.quantity__c;
                decimal newAmount = eachOrderItem.Amount__c;
                decimal oldQuantity = oldOrderItemList.get(eachOrderItem.id).quantity__c;
                decimal oldAmount = oldOrderItemList.get(eachOrderItem.id).Amount__c;
                decimal actualOrderAmount = parentOrdersList.get(eachOrderItem.order__c).Total_Amount__c;
                
                parentOrdersList.get(eachOrderItem.order__c).Total_Amount__c = actualOrderAmount - oldAmount*oldQuantity + newAmount*newQuantity;
              }
            }
            update parentOrdersList.values();
          }
        }        
      }      
    }
}
