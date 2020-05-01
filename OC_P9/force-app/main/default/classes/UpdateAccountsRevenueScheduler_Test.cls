/**
* @author:		 CLE
* @date:		 01/05/2020
* @description:		Test AccountRevenueScheduler use cases
* #TestReady
*
*/

@isTest
private with sharing class UpdateAccountsRevenueScheduler_Test {
	@testSetup
	static void init() {
		// Insert of 1 product
		Product2 product1 = new Product2(Name = 'Smartphone', Family = 'Phone');
		insert product1;
		// Insert of PricebookEntry
		PricebookEntry pbe = new PricebookEntry(
			Pricebook2Id = Test.getStandardPricebookId(),
			Product2Id = product1.Id,
			UnitPrice = 12,
			IsActive = true
		);
		Insert pbe;
		// Insert of 2 accounts
		Account accountWith1order = new Account(Name = 'WithOne');
		Account accountWith100orders = new Account(Name = 'WithOneHundred');
		insert new Account[]{accountWith1order, accountWith100orders};

		// Insert of 1 contract, one for each account
		Contract ctr1 = new Contract(	AccountId = accountWith1order.Id,
										ContractTerm = 4,
										StartDate = date.today(),
										Status = 'Draft');
		Contract ctr2 = new Contract(	AccountId = accountWith100orders.Id,
										ContractTerm = 3,
										StartDate = date.today(),
										Status = 'Draft');
		insert new Contract[]{ctr1, ctr2};
		// Then activate contracts
		ctr1.Status = 'Activated';
		ctr2.Status = 'Activated';
		update ctr1;
		update ctr2;

		// Insert of 1 order of price 12 to accountWith1order
		Order o1 = new Order(AccountId = accountWith1order.Id, Status = 'Draft', Pricebook2Id = pbe.Pricebook2Id, EffectiveDate = date.today());
		insert o1;
		// Insert of 1 item to the order
		OrderItem oi1 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=1, UnitPrice = 12);
		insert oi1;
		o1.Status = 'Activated';
		update(o1);

		// Insert of 100 orders of price 12 to accountWith100orders
		Order[] orderList = new Order[]{};
		for (Integer i=0; i<100; i++) {
			Order orderForList = new Order(AccountId = accountWith100orders.Id, Status = 'Draft', Pricebook2Id = pbe.Pricebook2Id, EffectiveDate = date.today());
			orderList.add(orderForList);
		}
		insert orderList;

		// Insert of orderItems
		OrderItem[] orderItemList = new OrderItem[]{};
		for (Order orderIteration : orderList) {
			orderItem orderItemForList = new OrderItem(OrderId = orderIteration.Id, PricebookEntryId = pbe.Id, Quantity=1, UnitPrice = 12);
			orderItemList.add(orderItemForList);
			// update status of order, update will be done out of the for loop
			orderIteration.Status = 'Activated';
		}
		insert orderItemList;
		update(orderList);
	}

	/*
	Test with 1 order of 12€
	*/
	@isTest
	static void given1orderOfPrice12_WhenUpdateAccountsByBatch_ThenUpdateAccountRevenuTo12(){
		Test.startTest();
		UpdateAccountsRevenueScheduler updateScheduler = new UpdateAccountsRevenueScheduler();
		String scheduleString = '0 0 23 * * ?';
		system.schedule('Test Account Revenue Scheduler', scheduleString, updateScheduler);
		Account acAfterUpdate = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Name = 'WithOne'];
		System.assertEquals(12, acAfterUpdate.Chiffre_d_affaire__c,'The revenu should be 12');
		Test.stopTest();
	}

	/*
	Test with 100 orders of 12€
	*/
	@isTest
	static void given100orderOfPrice12_WhenUpdateAccountsByBatch_ThenUpdateAccountRevenuTo1200(){
		Test.startTest();
		UpdateAccountsRevenueScheduler updateScheduler = new UpdateAccountsRevenueScheduler();
		String scheduleString = '0 0 23 * * ?';
		system.schedule('Test Account Revenue Scheduler', scheduleString, updateScheduler);
		Account acAfterUpdate = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Name = 'WithOneHundred'];
		System.assertEquals(1200, acAfterUpdate.Chiffre_d_affaire__c,'The revenu should be 1200');
		Test.stopTest();
	}
}
