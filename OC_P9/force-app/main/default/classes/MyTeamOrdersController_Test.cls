/**
* @author:		 CLE
* @date:		 04/05/2020
* @description:		Test MyTeamOrders controller
* #TestReady
*
*/

@isTest
private with sharing class MyTeamOrdersController_Test {
	@testSetup
	static void init() {
		// First, insert roles that are required to create users

		UserRole salesManagerRole1 = New UserRole(Name = 'Sales Manager Test 1');
		UserRole salesManagerRole2 = New UserRole(Name = 'Sales Manager Test 2');
		insert new UserRole[]{salesManagerRole1, salesManagerRole2};
		UserRole salesRepRole1 = New UserRole(Name = 'Sales Rep Test 1', parentroleId = salesManagerRole1.Id);
		UserRole salesRepRole2 = New UserRole(Name = 'Sales Rep Test 2', parentroleId = salesManagerRole1.Id);
		UserRole salesRepRole3 = New UserRole(Name = 'Sales Rep Test 3', parentroleId = salesManagerRole2.Id);
		insert new UserRole[]{salesRepRole1, salesRepRole2, salesRepRole3};

		// Then, insert 2 users with Sales Manager role, and 3 sales rep, 2 reporting to the first sales manager, 1 to the other one
		User salesManager1 = createUser(1, 'SalesManagerOne','Sales', salesManagerRole1);
		User salesManager2 = createUser(2, 'SalesManagerTwo','Sales', salesManagerRole2);
		User salesRep1 = createUser(3, 'SalesRepOne','Sales', salesRepRole1);
		User salesRep2 = createUser(4, 'SalesRepTwo','Sales', salesRepRole2);
		User salesRep3 = createUser(5, 'SalesRepThree','Sales', salesRepRole3);
		insert new User[]{salesManager1, salesManager2, salesRep1, salesRep2, salesRep3};

		// Then insert of 2 accounts with revenu per sales rep
		System.runAs(salesRep1) {
			Account account11 = new Account(Name = 'Account One One', Revenue__c = 10);
			Account account21 = new Account(Name = 'Account Two One', Revenue__c = 20);
			insert new Account[] {account11, account21};
		}
		System.runAs(salesRep2) {
			Account account12 = new Account(Name = 'Account One One', Revenue__c = 100);
			Account account22 = new Account(Name = 'Account Two One', Revenue__c = 200);
			insert new Account[] {account12, account22};
		}
		System.runAs(salesRep3) {
			Account account13 = new Account(Name = 'Account One One', Revenue__c = 1000);
			Account account23 = new Account(Name = 'Account Two One', Revenue__c = 2000);
			insert new Account[] {account13, account23};
		}
	}

	/*
		Generic method to create a user 
		To export in a dedicated generic class if need to be used in other test classes
	*/
	private static User createUser(Integer uniqueNumber, String lastName, String profile, UserRole role){
		Profile profileObject = [SELECT Id FROM Profile WHERE Name =: profile];
		//Role roleObject = [SELECT Id FROM Role WHERE Name =: role];
		User user = New User(
			LastName = lastname,
			FirstName = 'Test',
			Alias = 'alias' + uniqueNumber,
			Email = lastname + uniqueNumber + '@test.com',
			UserName = lastname + uniqueNumber + '@test.com',
			ProfileId = profileObject.Id,
			UserRoleId  = role.Id,
			isActive = true,
			TimeZoneSidKey = 'GMT',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'UTF-8'
		);
		return user;
	}

	/*
	Test that Sales Manager 1 only see total for Accounts 11, 21, 12 and 22
	*/
	@isTest
	static void given2AccountsPerSalesRep_WhenLogedAsSalesManager1_ThenSumAmountIs330(){
		User salesManager1 = [SELECT Id FROM User WHERE LastName = 'SalesManagerOne'];
		System.runAs(salesManager1) {
			Test.startTest();
			/*PageReference testPage = Page.MyTeamOrders;
			Test.setCurrentPage(testPage);*/
			MyTeamOrdersController controller = new MyTeamOrdersController();
			Decimal totalOrders = controller.SumOders;
			System.assertEquals(330, totalOrders, 'The total of the team should be 330');
			Test.stopTest();
		}
	}

	/*
	Test that Sales Manager 2 only see total for Accounts 31 and 32
	*/
	@isTest
	static void given2AccountsPerSalesRep_WhenLogedAsSalesManager2_ThenSumAmountIs3000(){
		User salesManager2 = [SELECT Id FROM User WHERE LastName = 'SalesManagerTwo'];
		System.runAs(salesManager2) {
			Test.startTest();
			MyTeamOrdersController controller = new MyTeamOrdersController();
			Decimal totalOrders = controller.SumOders;
			System.assertEquals(3000, totalOrders, 'The total of the team should be 3000');
			Test.stopTest();
		}
	}
}
