public with sharing class OrderTriggerHandler {
	public static void updateAccountRevenu(Set<Id> accountsId, Map<Id, Decimal> ammounts) {
		List<Account> accountsToUpdate = [SELECT Id, Revenue__c FROM Account WHERE Id IN :accountsId];
		for (Account currentAccount : accountsToUpdate) {
			if (currentAccount.Revenue__c != null) {
				currentAccount.Revenue__c += ammounts.get(currentAccount.Id);
			} else {
				currentAccount.Revenue__c = ammounts.get(currentAccount.Id);
			}
			
		}
		update(accountsToUpdate);
	}

	public static void updateAccountRevenuFromOrderList(List<Order> orders) {
		Map<Id, Decimal> accountsIdWithAmmountToAdd = new Map<Id, Decimal>();
		Set<Id> accountsId = new Set<Id>();
		for (Order currentOrder : orders) {
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
		// Update accounts
		updateAccountRevenu(accountsId, accountsIdWithAmmountToAdd);
	}
}
