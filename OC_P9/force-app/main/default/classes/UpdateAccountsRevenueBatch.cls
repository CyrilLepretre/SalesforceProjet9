global class UpdateAccountsRevenueBatch implements Database.Batchable<sObject> {
	global String query;

	// Constructor with initialization of the query to get Account list
	global UpdateAccountsRevenueBatch(String query) {
		this.query = query;
	}

	global Database.QueryLocator start(Database.BatchableContext info) {
		// Query passed as paramater of the constructor is used
		return Database.getQueryLocator(this.query);
	}

	global void execute(Database.BatchableContext info, List<Account> scope) {
		list<Order> listOrders =  [SELECT Id, TotalAmount, AccountId FROM Order];
		Map<Id,Decimal> totalAmountByAccountId = new Map<Id,Decimal>();
		// Intialization of totalAmountByAccountId map, were Id is the accountId
		for (Order order : listOrders) {
			if (totalAmountByAccountId.containsKey(order.AccountId)) {
				// If the AccountId key already exists in the map, just add the TotalAmount of the order
				totalAmountByAccountId.put(order.AccountId, totalAmountByAccountId.get(order.AccountId) + order.TotalAmount);
			} else {
				// Else we put a new key/value in the map
				totalAmountByAccountId.put(order.AccountId, order.TotalAmount);
			}
		}
		// Then loop in scope accounts list to update revenue based on values in the totalAmountByAccountId map
		for (Account account : scope) {
			if (totalAmountByAccountId.containsKey(account.Id)) {
				account.Chiffre_d_affaire__c = totalAmountByAccountId.get(account.Id);
			} else {
				// No order for this account, revenu update to 0
				account.Chiffre_d_affaire__c = 0.0;
			}
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext info) {
	}
}