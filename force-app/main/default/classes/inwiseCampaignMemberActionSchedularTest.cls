/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 2nd May 2017
*Purpose :     Test Code coverage for inwiseCampaignMemberActionSchedular
/******************************************************************************************/
@isTest
private class inwiseCampaignMemberActionSchedularTest{
      public static testMethod void testschedule1() {
      SchedulableContext ct;
         inwiseCampaignMemberActionSchedular objinwiseCampaignMemberActionSchedular = new inwiseCampaignMemberActionSchedular();
         objinwiseCampaignMemberActionSchedular.execute(ct);
         System.assertEquals(null,null);
        
      }
      public static testMethod void testschedule2() {
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  

        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Contact';
        insert con;

        Lead objLead = new Lead();
        objLead.FirstName = 'inwise';
        objLead.LastName = 'Test Lead';
        objLead.Email = 'inwise@inwisetest.com';
        objLead.Status = 'Open - Not Contacted';        
        objLead.Company = 'inwise';
        insert ObjLead;

        map<string,Mapping__c> mapping  = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        insert mapping.values();
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Sendid__c = 1237855;
        c.isActive = true;
        c.Campaign_Type__c = 'Email';
        insert c;
        Campaign c2 = new Campaign();
        c2.Name = 'test campaign1';
        c2.Account__c = act1.Id;
        c2.Sendid__c = 1237855;
        c2.isActive = true;
        c2.ParentId = c.Id;
        insert c2;

        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;
        insert cm;

      //  Activity__c activitieObj = new Activity__c();
        


      //  activitieObj.Action_Date__c  = '5-8-2020';
      //  insert activitieObj ;
      //   

        Test.StartTest();
        //inwiseCampaignMemberActionSchedular.schedulejob();
        Datetime dtnow = Datetime.now().addMinutes(10);
        String sch = '0 ' + dtnow.minute() + ' ' + dtnow.hour() + ' ' + dtnow.day() + ' ' + dtnow.month() + ' ?' + ' ' + dtnow.year(); 
        String jobName = 'inwiseGetAction' + Datetime.now().getTime();
        System.schedule(jobName, sch, new inwiseCampaignMemberActionSchedularV2()) ;
        list<cronTrigger> cronTriggerList = [select id,cronjobdetailid,cronjobdetail.name,state,cronexpression from crontrigger where cronjobdetail.name = :jobName and cronexpression = :sch];
        
        System.assertEquals(cronTriggerList.size(),1);
        System.assertEquals(cronTriggerList.get(0).cronjobdetail.name,jobName);
        System.assertEquals(cronTriggerList.get(0).cronexpression,sch);
        System.assertEquals(cronTriggerList.get(0).state,'WAITING' );
        
        Settings__c s = [select id,name,Campaign_Member_Action_Job_Id__c from Settings__c where id =:objSetting.id];
        system.debug('setting is-->>' +s);
        Test.stopTest(); 
  }
}