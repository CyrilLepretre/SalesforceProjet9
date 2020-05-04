public with sharing class MyTeamOrdersController {
	public decimal SumOders{
		get{
			AggregateResult groupedResults = [SELECT SUM(Revenue__c) total FROM Account];
			return (decimal)groupedResults.get('total');
		}
		set;
	}
}