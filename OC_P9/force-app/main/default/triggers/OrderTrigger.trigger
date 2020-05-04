trigger OrderTrigger on Order (before update, after update) {
	if (Trigger.isAfter) {
		List<Order> triggerOrders = (List<Order>) Trigger.New;
		// Business logic in OrderTriggerHandler class
		OrderTriggerHandler.updateAccountRevenuFromOrderList(Trigger.oldMap, Trigger.newMap);
	} else {
		// Check each order of the trigger and update NetAmount__c of each one before it's inserted
		for (Order newOrder : Trigger.New) {
			if (newOrder.TotalAmount != null && newOrder.ShipmentCost__c != null) {
				newOrder.NetAmount__c = newOrder.TotalAmount - newOrder.ShipmentCost__c;
			}
		}
	}
}