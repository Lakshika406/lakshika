/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     code coverage campaign trigger
/******************************************************************************************/
@isTest 
private class inwiseCampaignTriggerTest {
	//Code Commented for Professional Edition Installation fix 13 Feb 2017
	static testMethod void inwiseCampaignTriggerTest1() {
		List<Campaign> campObjectList = new List<Campaign>();
          Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
          insert tokenSetting;  

		Account__c act = inwiseTestDataFactory.GetInwiseAccount();      
        	insert act;

          tokenSetting.Account_Id__c = act.Id;
          update tokenSetting;  

      	Campaign c = new Campaign();
          c.Name = 'test campaign';
          c.Account__c = act.Id;
          c.Sendid__c = 1237855;
          c.isActive = true;
          c.Campaign_Type__c = 'email';
          insert c;

          Campaign c2 = new Campaign();
          c2.Name = 'test campaign1';
          c2.Account__c = act.Id;
          c2.Sendid__c = 1237855;
          c2.isActive = true;
          c2.ParentId = c.Id;
          c2.Campaign_Type__c = 'email';
          insert c2;

  
		List<Campaign> listOfCampaign = [Select Id,Account__c,Campaign_Type__c from Campaign where Id=:c2.Id];
		System.assertEquals(listOfCampaign.get(0).Campaign_Type__c,'Email');
		System.assertEquals(listOfCampaign.get(0).Account__c,act.Id);
		
	}

	static testMethod void inwiseCampaignTriggerTest2() {
		List<Campaign> campObjectList = new List<Campaign>();

          Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
          insert tokenSetting;  

		
		Account__c act = inwiseTestDataFactory.GetInwiseAccount();
		act.Default__c = true;      
        	insert act;

          

        	Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
		//act.Default__c = true;      
        	insert act1;

          tokenSetting.Account_Id__c = act1.Id;
          update tokenSetting;  

      	 Campaign c = new Campaign();
          c.Name = 'test campaign';
          //c.Account__c = act.Id;
          c.Sendid__c = 1237855;
          c.isActive = true;
          //c.Campaign_Type__c = 'email';
          insert c;

          Campaign c2 = new Campaign();
          c2.Name = 'test campaign1';
          //c2.Account__c = act.Id;
          c2.Sendid__c = 1237855;
          c2.isActive = true;
          c2.ParentId = c.Id;
          //c2.Campaign_Type__c = 'email';
          insert c2;
  
		List<Campaign> listOfCampaign = [Select Id,Account__c,Campaign_Type__c from Campaign where Id=:c2.Id];
		System.debug('listofaccount-->' +listOfCampaign);
		System.assertEquals(act.id,listOfCampaign.get(0).Account__c);
		
	}
    
}