trigger OrderTrigger on Order (before update, after update) {
	if (Trigger.isAfter) {
		Map<Id, Decimal> accountsIdWithAmmountToAdd = new Map<Id, Decimal>();
		Set<Id> accountsId = new Set<Id>();
		for (Order currentOrder : Trigger.New) {
			if (accountsIdWithAmmountToAdd.containsKey(currentOrder.AccountId)) {
				// There is already an order for this account, just add the amount of the order to the Decimal on Map
				Decimal previousAmount = accountsIdWithAmmountToAdd.get(currentOrder.AccountId);
				accountsIdWithAmmountToAdd.put(currentOrder.AccountId, previousAmount + currentOrder.TotalAmount);
			} else {
				// There is no previous order for this account, just add a new Key/Value to the Map
				accountsIdWithAmmountToAdd.put(currentOrder.AccountId, currentOrder.TotalAmount);
				accountsId.add(currentOrder.AccountId);
			}
		}
		// Update accounts using trigger handler
		OrderTriggerHandler.updateAccountRevenu(accountsId, accountsIdWithAmmountToAdd);
	} else {
		// Check each order of the trigger and update NetAmount__c of each one before it's inserted
		for (Order newOrder : Trigger.New) {
			if (newOrder.TotalAmount != null && newOrder.ShipmentCost__c != null) {
				newOrder.NetAmount__c = newOrder.TotalAmount - newOrder.ShipmentCost__c;
			}
		}
	}
}