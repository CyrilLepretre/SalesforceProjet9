public with sharing class OrderTriggerHandler {
	public static void updateAccountRevenu(Set<Id> accountsId, Map<Id, Decimal> ammounts) {
		List<Account> accountsToUpdate = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountsId];
		for (Account currentAccount : accountsToUpdate) {
			if (currentAccount.Chiffre_d_affaire__c != null) {
				currentAccount.Chiffre_d_affaire__c += ammounts.get(currentAccount.Id);
			} else {
				currentAccount.Chiffre_d_affaire__c = ammounts.get(currentAccount.Id);
			}
			
		}
		update(accountsToUpdate);
	}
}
