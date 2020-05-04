/**
* @author:		 CLE
* @date:		 20/04/2020
* @description:		Test OrderTrigger use cases
* #TestReady
*
*/

@isTest
private with sharing class OrderTrigger_Test {
	@testSetup
	static void init() {
		// Insert of 1 product
		Product2 product1 = new Product2(Name = 'Smartphone', Family = 'Phone');
		insert product1;
		// Insert of PricebookEntry
		PricebookEntry pbe = new PricebookEntry(
			Pricebook2Id = Test.getStandardPricebookId(),
			Product2Id = product1.Id,
			UnitPrice = 550,
			IsActive = true
		);
		Insert pbe;
		// Insert of 2 accounts
		Account accountWithoutRevenu = new Account(Name = 'Without');
		Account accountWithRevenu = new Account(Name = 'With', Revenue__c = 2000);
		insert new Account[]{accountWithoutRevenu, accountWithRevenu};
		// Insert of 2 contracts, one for each account
		Contract ctr1 = new Contract(	AccountId = accountWithoutRevenu.Id,
										ContractTerm = 4,
										StartDate = date.today(),
										Status = 'Draft');
		Contract ctr2 = new Contract(	AccountId = accountWithRevenu.Id,
										ContractTerm = 3,
										StartDate = date.today(),
										Status = 'Draft');
		insert new Contract[]{ctr1, ctr2};
		// Then activate contracts
		ctr1.Status = 'Activated';
		ctr2.Status = 'Activated';
		update ctr1;
		update ctr2;
	}

	/*
	Test with 1 order of 550€ added to an account without previously revenu
	*/
	@isTest
	static void given1orderOfPrice550_WhenInsertNewOrderToAccountWithoutRevenu_ThenUpdateAccountRevenuTo550(){
		Account ac = [SELECT Id, Revenue__c FROM Account WHERE Name = 'Without'];
		PricebookEntry pbe = [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE UnitPrice = 550];
		System.assertEquals(Null, ac.Revenue__c,'The revenu should be Null');
		Test.startTest();
		// Insert of 1 order of price 550
		Order o1 = new Order(AccountId = ac.Id, Status = 'Draft', Pricebook2Id = pbe.Pricebook2Id, EffectiveDate = date.today());
		insert o1;
		// Insert of 1 item to the order
		OrderItem oi1 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=1, UnitPrice = 550);
		insert oi1;
		o1.Status = 'Ordered';
		update o1; // Generates an update for the trigger to be launched
		Test.stopTest();
		Account acAfterUpdate = [SELECT Id, Revenue__c FROM Account WHERE Name = 'Without'];
		System.assertEquals(550, acAfterUpdate.Revenue__c,'The revenu should be 550');
	}

	/*
	Test with 1 order of 550€ added to an account with a previously revenu of 2000€ and command passed to Ordered
	*/
	@isTest
	static void given1orderOfPrice550_WhenInsertNewOrderToAccountWithRevenuOf2000_ThenUpdateAccountRevenuTo2550(){
		Account ac = [SELECT Id, Revenue__c FROM Account WHERE Name = 'With'];
		PricebookEntry pbe = [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE UnitPrice = 550];
		System.assertEquals(2000, ac.Revenue__c,'The revenu should be Null');
		Test.startTest();
		// Insert of 1 order of price 550
		Order o1 = new Order(AccountId = ac.Id, Status = 'Draft', Pricebook2Id = pbe.Pricebook2Id, EffectiveDate = date.today());
		insert o1;
		// Insert of 1 item to the order
		OrderItem oi1 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=1, UnitPrice = 550);
		insert oi1;
		o1.Status = 'Ordered';
		update o1; // Generates an update for the trigger to be launched
		Test.stopTest();
		Account acAfterUpdate = [SELECT Id, Revenue__c FROM Account WHERE Name = 'With'];
		System.assertEquals(2550, acAfterUpdate.Revenue__c,'The revenu should be 2550');
	}

	/*
	Test with 1 order of 550€ added to an account with a previously revenu of 2000€ but command not passed to 'Ordered'
	*/
	@isTest
	static void given1orderOfPrice550_WhenInsertNewOrderToAccountWithRevenuOf2000_ThenAccountRevenuStill2000(){
		Account ac = [SELECT Id, Revenue__c FROM Account WHERE Name = 'With'];
		PricebookEntry pbe = [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE UnitPrice = 550];
		System.assertEquals(2000, ac.Revenue__c,'The revenu should be Null');
		Test.startTest();
		// Insert of 1 order of price 550
		Order o1 = new Order(AccountId = ac.Id, Status = 'Draft', Pricebook2Id = pbe.Pricebook2Id, EffectiveDate = date.today());
		insert o1;
		// Insert of 1 item to the order
		OrderItem oi1 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=1, UnitPrice = 550);
		insert oi1;
		o1.Status = 'Activated';
		update o1; // Generates an update for the trigger to be launched
		Test.stopTest();
		Account acAfterUpdate = [SELECT Id, Revenue__c FROM Account WHERE Name = 'With'];
		System.assertEquals(2000, acAfterUpdate.Revenue__c,'The revenu should be 2000');
	}

	/*
	Test with 1 order of 550€ with a shipment cost of 100€ added to an account without previously revenu
	*/
	@isTest
	static void given1orderOfPrice550With100OfShipment_WhenInsertNewOrder_ThenUpdateNetAmountOfOrderTo450(){
		Account ac = [SELECT Id, Revenue__c FROM Account WHERE Name = 'Without'];
		PricebookEntry pbe = [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE UnitPrice = 550];
		Test.startTest();
		// Insert of 1 order of price 550 and Shipment cost of 100€
		Order o1 = new Order(AccountId = ac.Id, Status = 'Draft', ShipmentCost__c = 100, Pricebook2Id = pbe.Pricebook2Id, EffectiveDate = date.today());
		insert o1;
		// Insert of 1 item to the order
		OrderItem oi1 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=1, UnitPrice = 550);
		insert oi1;
		o1.Status = 'Ordered';
		update o1; // Generates an update for the trigger to be launched
		Test.stopTest();
		Account acAfterUpdate = [SELECT Id FROM Account WHERE Name = 'Without'];
		Order o1AfterUpdate = [SELECT Id, NetAmount__c FROM Order WHERE AccountId = :acAfterUpdate.Id];
		System.assertEquals(450, o1AfterUpdate.NetAmount__c,'The net amount of order should be 450');
	}

	/*
	Test with 2 orders of 550€ each added to an account without previously revenu
	*/
	@isTest
	static void given2ordersOfPrice550Each_WhenInsertNewOrderToAccountWithoutRevenu_ThenUpdateAccountRevenuTo1100(){
		Account ac = [SELECT Id, Revenue__c FROM Account WHERE Name = 'Without'];
		PricebookEntry pbe = [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE UnitPrice = 550];
		System.assertEquals(Null, ac.Revenue__c,'The revenu should be Null');
		Test.startTest();
		// Insert of 1 order of price 550
		Order o1 = new Order(AccountId = ac.Id, Status = 'Draft', Pricebook2Id = pbe.Pricebook2Id, EffectiveDate = date.today());
		Order o2 = new Order(AccountId = ac.Id, Status = 'Draft', Pricebook2Id = pbe.Pricebook2Id, EffectiveDate = date.today());
		Order[] orderList = new Order[] {o1, o2};
		insert orderList;
		// Insert of 1 item to each order
		OrderItem oi1 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=1, UnitPrice = 550);
		OrderItem oi2 = new OrderItem(OrderId = o2.Id, PricebookEntryId = pbe.Id, Quantity=1, UnitPrice = 550);
		insert new OrderItem[] {oi1, oi2};
		o1.Status = 'Ordered';
		o2.Status = 'Ordered';
		update orderList; // Generates an update for the trigger to be launched
		Test.stopTest();
		Account acAfterUpdate = [SELECT Id, Revenue__c FROM Account WHERE Name = 'Without'];
		System.assertEquals(1100, acAfterUpdate.Revenue__c,'The revenu should be 1100');
	}

}
