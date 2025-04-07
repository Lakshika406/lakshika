/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 14 Nov 2016
*Purpose :     Test Code coverage for inwiseScheduleJobController
/******************************************************************************************/
@isTest
private class inwiseScheduleJobControllerTest {
    
    static testMethod void inwiseScheduleJobControllerTest2() {
        
        Sync__c objSync = [SELECT id,name,Leads__c,Contacts__c,Group_Name__c,Leads_SOQL__c,Contacts_SOQL__c,Last_JobId__c FROM Sync__c limit 1];
        Test.setCurrentPage(Page.inwiseScheduleJob);
        ApexPages.CurrentPage().getParameters().put('Id',objSync.Id);
        inwiseScheduleJobController objinwiseScheduleJobController = new inwiseScheduleJobController();
        objinwiseScheduleJobController.doScheduleNow();
        objinwiseScheduleJobController.schedulejob('inwiseScheduleJobController Test', DateTime.now().addDays(2));
        System.assertNotEquals(objSync.Id, '');
    }
    /*--------To Cover inwiseScheduleJobController Coverage----------*/
    static testMethod void inwiseScheduleJobControllerTest31(){
        
        Sync__c objSync = [SELECT id,name,Leads__c,Contacts__c,Group_Name__c,Leads_SOQL__c,Contacts_SOQL__c,Scheduled_Daily_At__c,Last_JobId__c,Lead_View__c FROM Sync__c where Contacts__c != true];
        system.debug('objSync1 '+objSync);
        
         Test.setCurrentPage(Page.inwiseScheduleJob);
        ApexPages.CurrentPage().getParameters().put('Id',objSync.Id);
        inwiseScheduleJobController objinwiseScheduleJobController = new inwiseScheduleJobController();
        objinwiseScheduleJobController.objSync.Scheduled_Daily_At__c = '12:00 AM';
        objinwiseScheduleJobController.doSchedule();
        
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(),'Scheduled, Please go to home page to see the progress.');
        objinwiseScheduleJobController.gotoHome();
        
    }

    static testMethod void inwiseScheduleJobControllerTest3() {
    
        Sync__c objSync = [SELECT id,name,Leads__c,Contacts__c,Group_Name__c,Leads_SOQL__c,Contacts_SOQL__c,Scheduled_Daily_At__c,Last_JobId__c FROM Sync__c limit 1];
        System.debug('syncing value-->>' + objSync);
        Test.setCurrentPage(Page.inwiseScheduleJob);
        ApexPages.CurrentPage().getParameters().put('Id',objSync.Id);
        inwiseScheduleJobController objinwiseScheduleJobController = new inwiseScheduleJobController();
        objinwiseScheduleJobController.objSync.Scheduled_Daily_At__c = '12:00 AM';
        objinwiseScheduleJobController.doSchedule();
        
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(),'Scheduled, Please go to home page to see the progress.');
        objinwiseScheduleJobController.gotoHome();
        
        Test.setCurrentPage(Page.inwiseScheduleJob);
        ApexPages.CurrentPage().getParameters().put('Id',objSync.Id);
        objinwiseScheduleJobController = new inwiseScheduleJobController();
        objinwiseScheduleJobController.objSync.Scheduled_Daily_At__c = null;
        objinwiseScheduleJobController.doSchedule();

        List<Apexpages.Message> pageMessages = ApexPages.getMessages();
        System.debug('messages-->>' +pageMessages);
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(),'Please select Scheduled Daily At');
    }
    
    @testSetup static void setup() {
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
        con.email = 'inwise@inwisetest.com';
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'inwise';
        objLead.LastName = 'Test Lead';
        objLead.email = 'inwise@inwisetest.com';
        objLead.status = 'Open - Not Contacted';        
        objLead.company = 'inwise';
        objLead.mobilephone = '123456789';
        insert objLead;
        
        map<string,Mapping__c> mapping  = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        insert mapping.values();
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Sendid__c = 1237855;
        c.isActive = true;
        c.Campaign_Type__c = 'email';
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
        
        System.debug('cm>>>'+cm);         
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = '594806';
        objSync.Leads__c = true;
        objSync.Contacts__c = true;
        
        objSync.Last_JobId__c='';
        objSync.Is_Created_By_View__c  = true;
        objSync.Account__c = act1.id;
        
        Test.setCurrentPage(Page.ScheduleSyncView);
        ApexPages.StandardController std = new ApexPages.StandardController(objSync);
        std = new ApexPages.StandardController(new Sync__c());
        ScheduleSyncViewController objScheduleSyncViewController = new ScheduleSyncViewController(std);
        objScheduleSyncViewController.selectedViewType = objScheduleSyncViewController.listOfViewType.get(1).getValue();
        objScheduleSyncViewController.nextStep();
        objScheduleSyncViewController.doLoadViews();
        objsync.Contact_View__c = objScheduleSyncViewController.listOfAvailableView.get(2).getValue();
        objScheduleSyncViewController.nextStep();
        objScheduleSyncViewController.doPrevStep();
        objScheduleSyncViewController.selectedViewType = objScheduleSyncViewController.listOfViewType.get(2).getValue();
        objScheduleSyncViewController.nextStep();
        objScheduleSyncViewController.doLoadViews();
        objsync.Lead_View__c  =  objScheduleSyncViewController.listOfAvailableView.get(1).getValue();
        insert objSync;  
        
        /*--------To Cover inwiseScheduleJobController Coverage----------*/
        Sync__c objSync1 = new Sync__c();
        objSync1.name = 'leadSync';
        objSync1.Group_Name__c = '594806';
        objSync1.Leads__c = true;
         objSync1.Contacts__c = false;
        objSync1.Is_Created_By_View__c  = true;
        objSync1.Leads__c=true;
        objSync1.Account__c = act1.id;
        Test.setCurrentPage(Page.ScheduleSyncView);
        ApexPages.StandardController std1 = new ApexPages.StandardController(objSync1);
        std1 = new ApexPages.StandardController(new Sync__c());
        ScheduleSyncViewController objScheduleSyncViewController1 = new ScheduleSyncViewController(std1);
        objScheduleSyncViewController1.selectedViewType = objScheduleSyncViewController1.listOfViewType.get(1).getValue();
        objScheduleSyncViewController1.nextStep();
        objScheduleSyncViewController1.doLoadViews();
        objsync1.Lead_View__c = null;
        objScheduleSyncViewController1.nextStep();
        objScheduleSyncViewController1.doPrevStep();
        objScheduleSyncViewController1.selectedViewType = objScheduleSyncViewController1.listOfViewType.get(2).getValue();
        objScheduleSyncViewController1.nextStep();
        objScheduleSyncViewController1.doLoadViews();
        objsync1.Lead_View__c  =  objScheduleSyncViewController1.listOfAvailableView.get(1).getValue();
        insert objSync1;
        
        Sync_Filter__c objSyncFltr1 = new Sync_Filter__c();
        objSyncFltr1.Field_Api_Name__c = 'MobilePhone';
        objSyncFltr1.Field_Type__c = 'PHONE';
        objSyncFltr1.Sync__c = objSync.id;
        objSyncFltr1.Operator__c = 'Not Equal To';
        objSyncFltr1.sObject_Name__c = 'Lead';
        insert objSyncFltr1;
        
        Sync_Filter__c objSyncFltr2 = new Sync_Filter__c();
        objSyncFltr2.Field_Api_Name__c = 'Email';
        objSyncFltr2.Field_Type__c = 'EMAIL';
        objSyncFltr2.Sync__c = objSync.id;
        objSyncFltr2.Operator__c = 'Not Equal To';
        objSyncFltr2.sObject_Name__c = 'Contact';
        insert objSyncFltr2;
        
        System.assertEquals(objSync,objSync);
        System.debug('updated value is-->>' +objSync);
    }              
}