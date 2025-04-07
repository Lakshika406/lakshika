/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 1 Nov 2017
*Purpose :     Test Code coverage for inwiseSchedularNew 
/******************************************************************************************/
@isTest(SeeAllData=true)
private class inwiseSchedularNewTest {

    static testMethod void inwiseScheduleJobControllerTest1() { 
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = '594806';
        objSync.Leads__c = true;
        objSync.Contacts__c = true;
        objSync.Leads_SOQL__c = 'SELECT MobilePhone from Lead WHERE  IsConverted = false AND  MobilePhone !=  null';
        objSync.Contacts_SOQL__c = 'SELECT email from Contact WHERE Email !=  null'; 
        insert objSync;
        inwiseSchedularNew objinwiseSchedularnew = new inwiseSchedularNew(objSync.Id);
        objinwiseSchedularnew.execute(null) ;
        System.assertEquals(objSync,objSync);
    } 

    //this class is called for inwiseschedular class that is commented
    static testmethod void inwiseScheduleJobControllerTest2(){

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
                
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = '594806';
        objSync.Leads__c = true;
        objSync.Contacts__c = true;
        objSync.Leads_SOQL__c = 'SELECT MobilePhone from Lead WHERE  IsConverted = false AND  MobilePhone !=  null';
        objSync.Contacts_SOQL__c = 'SELECT email from Contact WHERE Email !=  null'; 
        insert objSync;

        inwiseSchedular objinwiseSchedular = new inwiseSchedular(objSync.id);
        objinwiseSchedular.execute(null);
        System.assertEquals(objSync,objSync);
    }

    static testMethod void inwiseScheduleJobControllerTest3() {

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

        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;
        insert cm;

        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = '594806';
        objSync.Leads__c = true;
        objSync.Contacts__c = true;
        objsync.Is_Created_By_View__c = true;
        objSync.Leads_SOQL__c = 'SELECT MobilePhone from Lead WHERE  IsConverted = false AND  MobilePhone !=  null';
        objsync.Dont_Delete_Existing_Contacts__c = false;
        objSync.Contacts_SOQL__c = 'SELECT email from Contact WHERE Email !=  null'; 
        
        Test.startTest();
        inwiseSchedularNew objinwiseSchedular = new inwiseSchedularNew(objSync.Id);
        objinwiseSchedular.execute(null) ;
        System.assertEquals(objSync,objSync);
        Test.stopTest();
    }
    
    static testMethod void inwiseScheduleJobControllerTest4() {

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

        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;
        insert cm;
        
        String reportName = 'Test_Contacts_Accounts_Report_oAi';
        List<Organization> orgLi = [SELECT Id, Name, Division, OrganizationType, IsSandbox FROM Organization Where Name = 'inwise LTD'];
        if(!orgLi.isEmpty()){
            reportName = 'Contact_and_Account_Report';
        }
       
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = '594806';
        objSync.Leads__c = true;
        objSync.Contacts__c = true;
        objSync.Is_Created_By_Report__c = true;
        objSync.Leads_SOQL__c = 'SELECT MobilePhone from Lead WHERE  IsConverted = false AND  MobilePhone !=  null';
        objsync.Dont_Delete_Existing_Contacts__c = false;
        objSync.Contacts_SOQL__c = 'SELECT email from Contact WHERE Email !=  null'; 
        objSync.Contact_Report__c = reportName;
        
        Test.setCurrentPage(Page.ScheduleSyncView);
        ApexPages.StandardController std = new ApexPages.StandardController(objSync);
        std = new ApexPages.StandardController(new Sync__c());
        ScheduleSyncViewController objScheduleSyncViewController = new ScheduleSyncViewController(std);
        objScheduleSyncViewController.selectedViewType = objScheduleSyncViewController.listOfViewType.get(2).getValue();
        objScheduleSyncViewController.nextStep();
        objScheduleSyncViewController.doLoadViews();
        objsync.Lead_View__c  =  objScheduleSyncViewController.listOfAvailableView.get(1).getValue();
        insert objSync; 

        System.debug('sync is-->' +objsync);
        ApexPages.StandardController std1;
        Test.setCurrentPage(Page.SendToInwise);
        ApexPages.currentPage().getParameters().put('id',c.Id);
        ApexPages.currentPage().getParameters().put('action','sendmember');
        SendToInwiseController objSendToInwiseController = new SendToInwiseController(std1);
        objSendToInwiseController.onload();   
        
        Test.startTest();
        inwiseSchedularNew.insertSyncHistory('Missing mapping information to execute batch', null, objSync);
        inwiseSchedularNew objinwiseSchedular = new inwiseSchedularNew(objSync.Id);
        objinwiseSchedular.execute(null) ;
        System.assertEquals(objSync, objSync);
        
        reportName = 'Test_Lead_Re1';
        if(!orgLi.isEmpty()){
            reportName = 'Test_Lead_Report';
        }
        
        objSync.Contacts__c = false;
        objSync.Lead_Report__c = reportName;
        update objSync;
        
        objinwiseSchedular = new inwiseSchedularNew(objSync.Id);
        objinwiseSchedular.execute(null) ;
        System.assertEquals(objSync, objSync);
        Test.stopTest();
    }

    static testMethod void inwiseScheduleJobControllerTest5() {

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

        Map<string,Mapping__c> mapping  = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        insert mapping.values();

        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Sendid__c = 1237855;
        c.isActive = true;
        c.Campaign_Type__c = 'email';
        insert c;

        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;
        insert cm;

        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = '594806';
        objSync.Leads__c = true;
        objSync.Contacts__c = true;
        objsync.Is_Created_By_View__c = false;
        objsync.Dont_Delete_Existing_Contacts__c = false;
        objSync.Contacts_SOQL__c = 'SELECT email from Contact WHERE Email !=  null'; 
        objSync.Leads_SOQL__c = 'SELECT MobilePhone from Lead WHERE  IsConverted = false AND  MobilePhone !=  null';
        insert objSync; 

        System.debug('sync is-->' +objsync);
        ApexPages.StandardController std1;
        Test.setCurrentPage(Page.SendToInwise);
        ApexPages.currentPage().getParameters().put('id',c.Id);
        ApexPages.currentPage().getParameters().put('action','sendmember');
        SendToInwiseController objSendToInwiseController = new SendToInwiseController(std1);
        objSendToInwiseController.onload();   
        
        Test.startTest();
        inwiseSchedularNew objinwiseSchedular = new inwiseSchedularNew(objSync.Id);
        System.assertNotEquals(objSync.Id, cm.Id);
        Test.stopTest();
    }

    @IsTest
    static  void inwiseScheduleJobControllerTestTemp() {

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

        Map<string,Mapping__c> mapping  = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        insert mapping.values();

        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Sendid__c = 1237855;
        c.isActive = true;
        c.Campaign_Type__c = 'email';
        insert c;

        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;
        insert cm;
        
        List<ListView> listOfLeadView = [select id,Name from ListView where sObjectType = 'Lead' and Name = 'All Open Leads'];
        System.debug('list of lead view----' + listOfLeadView);

        List<ListView> listOfContactView = [select id,Name from ListView where sObjectType = 'Contact' and Name='All Contacts'];
        System.debug('list of Contact view----' + listOfContactView);
        
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = '594806';
        objSync.Leads__c = true;
        objSync.Contacts__c = true;
        objsync.Is_Created_By_View__c = true;
        objsync.Contact_View__c =   listOfContactView.get(0).id;
        objSync.Leads_SOQL__c = 'SELECT MobilePhone from Lead WHERE  IsConverted = false AND  MobilePhone !=  null';
        objsync.Dont_Delete_Existing_Contacts__c = false;
        objSync.Contacts_SOQL__c = 'SELECT email from Contact WHERE Email !=  null'; 
        objsync.Lead_View__c = listOfLeadView.get(0).id;
        objsync.Account__c = act1.Id;
        
        insert objsync;

        List<Contact> listOfcon = [select id,Name from Contact where id = : con.Id limit 100];

        System.debug('sync is-->' +objsync);
        ApexPages.StandardController std1;
        Test.setCurrentPage(Page.SendToInwise);
        ApexPages.currentPage().getParameters().put('id',c.Id);
        ApexPages.currentPage().getParameters().put('action','sendmember');
        SendToInwiseController objSendToInwiseController = new SendToInwiseController(std1);
        objSendToInwiseController.onload();   
        
        Test.setCurrentPage(Page.inwiseScheduleJob);
        ApexPages.StandardSetController newOne = new ApexPages.StandardSetController(listOfcon);
        newOne.setSelected(listOfcon);
        System.debug('new one is-->>' + newOne);
        ApexPages.CurrentPage().getParameters().put('Id',objSync.Id);
        inwiseScheduleJobController objinwiseScheduleJobController = new inwiseScheduleJobController();
        objinwiseScheduleJobController.doSchedule();
        
        inwiseSchedularNew objinwiseSchedular = new inwiseSchedularNew(objSync.Id);
        objinwiseSchedular.execute(null) ;
        System.assertEquals(objSync, objSync);
    }

    @IsTest
    static  void inwiseScheduleJobControllerTestTemp11() {

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

        Map<string,Mapping__c> mapping  = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        insert mapping.values();

        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Sendid__c = 1237855;
        c.isActive = true;
        c.Campaign_Type__c = 'email';
        insert c;

        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;
        insert cm;
        
        List<ListView> listOfLeadView = [select id,Name from ListView where sObjectType = 'Lead' and Name = 'All Open Leads'];
        System.debug('list of lead view----' + listOfLeadView);

        List<ListView> listOfContactView = [select id,Name from ListView where sObjectType = 'Contact' and Name='All Contacts'];
        System.debug('list of Contact view----' + listOfContactView);
        
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = '594806';
        objSync.Leads__c = true;
        objSync.Contacts__c = true;
        objsync.Is_Created_By_View__c = true;
        objsync.Contact_View__c =   listOfContactView.get(0).id;
        objSync.Leads_SOQL__c = 'SELECT MobilePhone from Lead WHERE  IsConverted = false AND  MobilePhone !=  null';
        objsync.Dont_Delete_Existing_Contacts__c = false;
        objSync.Contacts_SOQL__c = 'SELECT email from Contact WHERE Email !=  null'; 
        objsync.Lead_View__c = listOfLeadView.get(0).id;
        objsync.Account__c = act1.Id;
        
        insert objsync;

        List<Contact> listOfcon = [select id,Name from Contact where id = : con.Id limit 100];

        //Sync__c objSync = [SELECT id,name,Leads__c,Contacts__c,Group_Name__c,Leads_SOQL__c,Contacts_SOQL__c,Last_JobId__c FROM Sync__c limit 1];
        Test.setCurrentPage(Page.inwiseScheduleJob);
        ApexPages.CurrentPage().getParameters().put('Id',objSync.Id);
        inwiseScheduleJobController objinwiseScheduleJobController = new inwiseScheduleJobController();
        objinwiseScheduleJobController.doScheduleNow();
        objinwiseScheduleJobController.schedulejob('inwiseScheduleJobController Test', DateTime.now().addDays(2));
        System.assertNotEquals(objSync.Id, '');

    }


    @IsTest
    static  void inwiseScheduleJobControllerTestTemp22() {

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

        Map<string,Mapping__c> mapping  = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        insert mapping.values();

        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Sendid__c = 1237855;
        c.isActive = true;
        c.Campaign_Type__c = 'email';
        insert c;

        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;
        insert cm;
        
        List<ListView> listOfLeadView = [select id,Name from ListView where sObjectType = 'Lead' and Name = 'All Open Leads'];
        System.debug('list of lead view----' + listOfLeadView);

        List<ListView> listOfContactView = [select id,Name from ListView where sObjectType = 'Contact' and Name='All Contacts'];
        System.debug('list of Contact view----' + listOfContactView);
        
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = '594806';
        objSync.Leads__c = true;
        //objSync.Contacts__c = true;
        objsync.Is_Created_By_View__c = true;
        objsync.Contact_View__c =   listOfContactView.get(0).id;
        objSync.Leads_SOQL__c = 'SELECT MobilePhone from Lead WHERE  IsConverted = false AND  MobilePhone !=  null';
        objsync.Dont_Delete_Existing_Contacts__c = false;
        objSync.Contacts_SOQL__c = 'SELECT email from Contact WHERE Email !=  null'; 
        objsync.Lead_View__c = listOfLeadView.get(0).id;
        objsync.Account__c = act1.Id;
        
        insert objsync;

        List<Contact> listOfcon = [select id,Name from Contact where id = : con.Id limit 100];

        //Sync__c objSync = [SELECT id,name,Leads__c,Contacts__c,Group_Name__c,Leads_SOQL__c,Contacts_SOQL__c,Last_JobId__c FROM Sync__c limit 1];
        Test.setCurrentPage(Page.inwiseScheduleJob);
        ApexPages.CurrentPage().getParameters().put('Id',objSync.Id);
        inwiseScheduleJobController objinwiseScheduleJobController = new inwiseScheduleJobController();
        objinwiseScheduleJobController.doScheduleNow();
        objinwiseScheduleJobController.schedulejob('inwiseScheduleJobController Test', DateTime.now().addDays(2));
        System.assertNotEquals(objSync.Id, '');

       
    }

    @IsTest
    static  void inwiseScheduleJobControllerTestTemp33() {

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

        Map<string,Mapping__c> mapping  = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        insert mapping.values();

        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Sendid__c = 1237855;
        c.isActive = true;
        c.Campaign_Type__c = 'email';
        insert c;

        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;
        insert cm;
        
        List<ListView> listOfLeadView = [select id,Name from ListView where sObjectType = 'Lead' and Name = 'All Open Leads'];
        System.debug('list of lead view----' + listOfLeadView);

        List<ListView> listOfContactView = [select id,Name from ListView where sObjectType = 'Contact' and Name='All Contacts'];
        System.debug('list of Contact view----' + listOfContactView);

        String reportName = 'Test_Contacts_Accounts_Report_oAi';
        List<Organization> orgLi = [SELECT Id, Name, Division, OrganizationType, IsSandbox FROM Organization Where Name = 'inwise LTD'];
        if(!orgLi.isEmpty()){
            reportName = 'Contact_and_Account_Report';
        }
        
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = '594806';
        //objSync.Leads__c = true;
        objSync.Contacts__c = true;
        objsync.Is_Created_By_Report__c = true;
        objsync.Contact_View__c =   listOfContactView.get(0).id;
        objSync.Leads_SOQL__c = 'SELECT MobilePhone from Lead WHERE  IsConverted = false AND  MobilePhone !=  null';
        objsync.Dont_Delete_Existing_Contacts__c = false;
        objSync.Contacts_SOQL__c = 'SELECT email from Contact WHERE Email !=  null'; 
        objsync.Lead_View__c = listOfLeadView.get(0).id;
        objsync.Account__c = act1.Id;
        objsync.Contact_Report__c = reportName;
        
        insert objsync;

        List<Contact> listOfcon = [select id,Name from Contact where id = : con.Id limit 100];

        //Sync__c objSync = [SELECT id,name,Leads__c,Contacts__c,Group_Name__c,Leads_SOQL__c,Contacts_SOQL__c,Last_JobId__c FROM Sync__c limit 1];
        Test.setCurrentPage(Page.inwiseScheduleJob);
        ApexPages.CurrentPage().getParameters().put('Id',objSync.Id);
        inwiseScheduleJobController objinwiseScheduleJobController = new inwiseScheduleJobController();
        objinwiseScheduleJobController.doScheduleNow();
        objinwiseScheduleJobController.schedulejob('inwiseScheduleJobController Test', DateTime.now().addDays(2));
        System.assertNotEquals(objSync.Id, '');

       
    }
}