global with sharing class UpdateAccountsRevenueScheduler implements Schedulable {

	global void execute(SchedulableContext sc) {
		// Query updated to return only accounts having orders
		String query = 'SELECT Id, Revenue__c FROM Account WHERE Id IN (SELECT AccountId FROM Order)';
		UpdateAccountsRevenueBatch batch = new UpdateAccountsRevenueBatch(query);
		Database.executeBatch(batch);
	}
}
