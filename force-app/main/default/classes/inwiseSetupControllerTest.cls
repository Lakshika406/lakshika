/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :      Test code coverage for inwiseSetupController
/******************************************************************************************/
@isTest
private class inwiseSetupControllerTest {
    
    @isTest static void myUnitTest() {
        
        Settings__c objSetting = InwiseTestDataFactory.GetInwiseSetting();
        objSetting.Overlay_Help__c = true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        PageReference pageRef = Page.inwiseHome;
        Test.setCurrentPage(pageRef);
        Account__c objInwiseAccountResult=new Account__c();     
        ApexPages.StandardController sc = new ApexPages.StandardController(objInwiseAccountResult);
        InwiseSetupController objInwiseSetupController=new InwiseSetupController(sc);
        Account__c objInwiseAccountResult1 =  InwiseTestDataFactory.GetInwiseAccount(); 
        objInwiseAccountResult1.Default__c = true;
        objInwiseAccountResult1.Default_Campaign_Type__c = 'email';
        insert objInwiseAccountResult1;

        tokenSetting.Account_Id__c = objInwiseAccountResult1.Id;
        update tokenSetting;  
        
        User usr = inwiseTestDataFactory.createTestUser();
        insert usr;
        
        objInwiseSetupController.selectUserIds = usr.Id; 
        Account_SalesforceUser_Mapping__c objAccSalesforceUsr = new Account_SalesforceUser_Mapping__c();
        
        PageReference pgr=objInwiseSetupController.doInwiseSetup();
        system.assertEquals(pgr.getUrl().contains('inwisesetup'),true);
        pgr=objInwiseSetupController.doCancel();
        system.assertEquals(pgr.getUrl().contains('inwisehome'),true);      
        pgr=objInwiseSetupController.doInwiseSetup();           
        objInwiseSetupController.objInwiseSetup= InwiseTestDataFactory.GetInwiseAccount();        
        pgr=objInwiseSetupController.doSave();
        objInwiseAccountResult = [Select Id,Name,Token__c from  Account__c where Id =:objInwiseSetupController.objInwiseSetup.Id];
        system.assertEquals(objInwiseAccountResult.Name,'Test Run Account');
        pgr=objInwiseSetupController.doCancel();
        system.assertEquals(pgr.getUrl().contains('inwisehome'),true);     
        
        pgr=objInwiseSetupController.doMapping();
        system.assertEquals(pgr.getUrl().contains('inwisesync'),true);
        map<string,Mapping__c> objMapping = InwiseTestDataFactory.GetInwiseFieldMapping(objInwiseAccountResult);
        pgr=objInwiseSetupController.doMapping();
        
        pgr=objInwiseSetupController.doCancel();
        system.assertEquals(pgr.getUrl().contains('inwisehome'),true);
        
        pgr=objInwiseSetupController.doSyncfromSFtoInwise();
        system.assertEquals(pgr.getUrl().contains('inwiseschedulesync'),true);
        
        //****** Delete Sync ************* 
        Sync__c objSync = new Sync__c(name = 'contactSync',Group_Name__c = 'campaign5');
        insert objSync;
        
        contact objContact = new contact(firstname='lead',lastname='1');
        insert objContact;
        
        objSync.Contacts__c = true;
        objSync.Contacts_SOQL__c = 'SELECT ID,Name from Contact';
        
        update objSync;      
        objInwiseSetupController.toDeleteId= objSync.Id;   
        pgr=objInwiseSetupController.deleteSync();
        
        //****** Test Save Account ************//
        objInwiseSetupController.objInwiseSetup= InwiseTestDataFactory.GetInwiseAccount(); 
        
        objInwiseAccountResult = [Select Id,Name,Token__c from  Account__c where Id =:objInwiseAccountResult1.Id];
        system.assertEquals(objInwiseAccountResult.Name,'Test Run Account');
        //****** Test Save Account *************
        
        //******* Test Delete Mapping **********
        objMapping = InwiseTestDataFactory.GetInwiseFieldMapping(objInwiseAccountResult);
        insert objMapping.get('Contact');
        
        objInwiseSetupController.toDeleteId=objInwiseAccountResult.Id;
        objInwiseSetupController.deleteMapping();
        List<Mapping__c> listOfInwiseMapping = [SELECT Id from Mapping__c where Account__c=:objInwiseAccountResult.Id];
        system.assertEquals(listOfInwiseMapping.isEmpty(),true);
        //******* Test Delete Mapping **********
        
        //****** Test Delete Account ***********
        objInwiseSetupController.toDeleteId=objInwiseAccountResult.Id;
        objInwiseSetupController.deleteAccount();
        
        List<Account__c> lstAccount = [Select Id,Name,Token__c from  Account__c where Id =:objInwiseSetupController.objInwiseSetup.Id];
        system.assertEquals(lstAccount.isEmpty(),true);
        //****** Test Delete Account ***********
    }
    
    @isTest static void myUnitTest2() {
        
        Settings__c objSetting = InwiseTestDataFactory.GetInwiseSetting();
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        PageReference pageRef1 = Page.inwiseHome;
        Test.setCurrentPage(pageRef1);
        Account__c objInwiseAccountResult=  InwiseTestDataFactory.GetInwiseAccount(); 
        objInwiseAccountResult.Default__c = true;
        objInwiseAccountResult.Default_Campaign_Type__c = 'email';
        insert objInwiseAccountResult;

        tokenSetting.Account_Id__c = objInwiseAccountResult.Id;
        update tokenSetting;  
        
        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Contact';
        con.Email = 'inwise@inwisetest.com';
        con.HasOptedOutOfEmail = true;
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'inwise';
        objLead.LastName = 'Test Lead';
        objLead.email = 'inwise@inwisetest.com';
        objLead.status = 'Open - Not Contacted';        
        objLead.company = 'inwise';
        objLead.HasOptedOutOfEmail = true;
        insert objLead;
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = objInwiseAccountResult.Id;
        c.Sendid__c = 1237855;
        c.isActive = true;
        c.Campaign_Type__c = 'email';
        insert c;
        
        Campaign c2 = new Campaign();
        c2.Name = 'test campaign1';
        c2.Account__c = objInwiseAccountResult.Id;
        c2.Sendid__c = 1237855;
        c2.isActive = true;
        c2.ParentId = c.Id;
        insert c2;
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;
        insert cm;
        
        list<Landing_Sync__c> listLandingSync = new list<Landing_Sync__c>();
        Landing_Sync__c obLandingSync;
        for(integer i=0;i<=5;i++){
            obLandingSync = new Landing_Sync__c();
            obLandingSync.Landing_Page_Name__c = 'Test landing Sync';
            obLandingSync.Leads__c = true;
            obLandingSync.Landing_Page_Id__c = 5341;
            listLandingSync.add(obLandingSync);             
        }
        insert listLandingSync;
        
        List<Sync__c> syncList = new List<Sync__c>();
        for(integer i=0;i<=5;i++){
            syncList.add(new Sync__c(name = 'contactSync'+i,Group_Name__c = 'campaign5'));
        }
        insert syncList;         
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objInwiseAccountResult);
        InwiseSetupController objInwiseSetupController=new InwiseSetupController(sc);   
        PageReference pageRef = Page.inwiseSetupEdit; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(objInwiseAccountResult.Id));
        Test.setCurrentPage(pageRef);
        list<Account__c> lstAcc = [SELECT Id, Name, Password__c, Token__c, User_Name__c, Default_Campaign_Type__c, ListEmailFeedBackActionMaxId__c, ListEmailSentMessageMaxId__c FROM Account__c]; 
        objInwiseAccountResult = lstAcc.get(0);
        objInwiseSetupController.objInwiseSetup = objInwiseAccountResult;
        System.debug('==objInwiseAccountResult=='+objInwiseAccountResult);
        objInwiseSetupController.selectedAccId = objInwiseAccountResult.ID;
        System.assertEquals(objInwiseSetupController.authenticationToken,null);
        objInwiseSetupController.getAuthenticationToken();
        
        User usr = inwiseTestDataFactory.createTestUser();
        insert usr;
        objInwiseSetupController.selectUserIds = usr.Id; 
        
        Account_SalesforceUser_Mapping__c objAccSalesforceUsr1 = new Account_SalesforceUser_Mapping__c();
        objAccSalesforceUsr1.Account__c= objInwiseAccountResult.Id;
        objAccSalesforceUsr1.User__c=  UserInfo.getUserId();
        insert objAccSalesforceUsr1;
        
        objInwiseSetupController.doUpdate();
        objInwiseSetupController.doSyncfromSFtoInwiseViews();  
        objInwiseSetupController.sortResults();  
        objInwiseSetupController.NextCampaign(); 
        objInwiseSetupController.PreviousCampaign(); 
        objInwiseSetupController.sortResultsCampaign(); 
        objInwiseSetupController.getXMLBody('TestUserName', 'TestPassword'); 
        InwiseSetupController.JsonData wrap = new InwiseSetupController.JsonData();
        System.assertNotEquals(objInwiseSetupController.authenticationToken,null);
        
        System.assertEquals(objInwiseSetupController.hasNextLandingSync,false);
        objInwiseSetupController.NextLandingSync();
        System.assertEquals(objInwiseSetupController.hasNextLandingSync,true);
        System.assertEquals(objInwiseSetupController.hasPreviousLandingSync,false);       
        objInwiseSetupController.PreviousLandingSync();      
        System.assertEquals(objInwiseSetupController.hasPreviousLandingSync,true);          
        objInwiseSetupController.toDeleteId = listLandingSync[0].Id;         
        objInwiseSetupController.deleteLandingSync();
        System.assertEquals(objInwiseSetupController.listOfWrapperLandingSync.size(),5);
        objInwiseSetupController.doLandingPageSyncfromSFtoInwise(); 
        objInwiseSetupController.isHelpOnload = true;
        objInwiseSetupController.toggleshowhelp();   
        System.assertEquals(objInwiseSetupController.hasNext,false);
        objInwiseSetupController.Next();
        System.assertEquals(objInwiseSetupController.hasNext,true);
        System.assertEquals(objInwiseSetupController.hasPrevious,false);       
        objInwiseSetupController.Previous();      
        System.assertEquals(objInwiseSetupController.hasPrevious,true);  
        objInwiseSetupController.doExecuteLandingSync();
        objInwiseSetupController.doSyncoptout();
        System.assertEquals('Turn On Email Opt-in/out',objInwiseSetupController.TurnOnOffEmailOptInOptOutBtnLabel);
        objInwiseSetupController = new InwiseSetupController(sc);
        objInwiseSetupController.doSyncfromSFtoInwiseReports();
        Boolean hasNextVal = objInwiseSetupController.hasNextCampaign;
        Boolean hasPrevVal = objInwiseSetupController.hasPreviousCampaign;
    }  
    
    @isTest static void myUnitTest3() {
        
        Settings__c objSetting = InwiseTestDataFactory.GetInwiseSetting();
        objSetting.Landing_Sync_Scheduled__c = true;
        objSetting.Toggle_Email_Opt_in_Opt_out__c = true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        PageReference pageRef = Page.inwiseHome;
        Test.setCurrentPage(pageRef);
        Account__c objInwiseAccountResult=  InwiseTestDataFactory.GetInwiseAccount(); 
        objInwiseAccountResult.Default__c = true;
        objInwiseAccountResult.Default_Campaign_Type__c = 'email';
        insert objInwiseAccountResult;

        tokenSetting.Account_Id__c = objInwiseAccountResult.Id;
        update tokenSetting;  
        
        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Contact';
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'inwise';
        objLead.LastName = 'Test Lead';
        objLead.email = 'inwise@inwisetest.com';
        objLead.status = 'Open - Not Contacted';        
        objLead.company = 'inwise';
        insert objLead;
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = objInwiseAccountResult.Id;
        c.Sendid__c = 1237855;
        c.isActive = true;
        c.Campaign_Type__c = 'email';
        insert c;
        
        Campaign c2 = new Campaign();
        c2.Name = 'test campaign1';
        c2.Account__c = objInwiseAccountResult.Id;
        c2.Sendid__c = 1237855;
        c2.isActive = true;
        c2.ParentId = c.Id;
        insert c2;
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;
        insert cm;
        
        Landing_Sync__c obLandingSync;
        List<Landing_Sync__c> listLandingSync = new List<Landing_Sync__c>();
        
        for(integer i = 0; i <= 5; i++){
            obLandingSync = new Landing_Sync__c();
            obLandingSync.Landing_Page_Name__c = 'Test landing Sync';
            obLandingSync.Leads__c = true;
            obLandingSync.Landing_Page_Id__c = 5341;
            listLandingSync.add(obLandingSync);             
        }
        insert listLandingSync;      
        
        /*--------To Cover inwiseLandingSyncSchedular Coverage----------*/
        List<Landing_Sync_Mapping__c> listLandingSyncMapping = new List<Landing_Sync_Mapping__c>();
        listLandingSyncMapping.add(new Landing_Sync_Mapping__c(Landing_Sync__c = listLandingSync[0].Id, inwise_FieldId__c = 'text94', inwise_Field__c = 'NumberOfEmployees',Salesforce_Field__c ='NumberOfEmployees'));
        listLandingSyncMapping.add(new Landing_Sync_Mapping__c(Landing_Sync__c = listLandingSync[0].Id, inwise_FieldId__c = 'text95', inwise_Field__c = 'LastTransferDate',Salesforce_Field__c ='LastTransferDate'));
        listLandingSyncMapping.add(new Landing_Sync_Mapping__c(Landing_Sync__c = listLandingSync[0].Id, inwise_FieldId__c = 'text96', inwise_Field__c = 'CreatedDate',Salesforce_Field__c ='CreatedDate'));
        listLandingSyncMapping.add(new Landing_Sync_Mapping__c(Landing_Sync__c = listLandingSync[0].Id, inwise_FieldId__c = 'text97', inwise_Field__c = 'DoNotCall',Salesforce_Field__c ='DoNotCall'));
        listLandingSyncMapping.add(new Landing_Sync_Mapping__c(Landing_Sync__c = listLandingSync[0].Id, inwise_FieldId__c = 'text98', inwise_Field__c = 'Name',Salesforce_Field__c ='FirstName'));
        listLandingSyncMapping.add(new Landing_Sync_Mapping__c(Landing_Sync__c = listLandingSync[0].Id, inwise_FieldId__c = 'text99', inwise_Field__c = 'Phone',Salesforce_Field__c ='Phone'));
        listLandingSyncMapping.add(new Landing_Sync_Mapping__c(Landing_Sync__c = listLandingSync[0].Id, inwise_FieldId__c = 'text100', inwise_Field__c = 'AnnualRevenue',Salesforce_Field__c ='AnnualRevenue'));
        insert listLandingSyncMapping;
        
        String jobName = inwiseLandingSyncSchedular.getJobName();
        String strSchedule = inwiseLandingSyncSchedular.doGetNextHourChronExp();
        String jobId = System.schedule(jobName, strSchedule, new inwiseLandingSyncSchedular(listLandingSync[0].Id));
        
        inwiseLandingSyncSchedular.futureCalloutinwiseSync(listLandingSync[0].Id);  
        List<Landing_Sync__c> listOfLS = inwiseLandingSyncSchedular.getSyncRecord(listLandingSync[0].Id);
        inwiseLandingSyncSchedular.InwiseCalloutLandingSync(listOfLS);
        inwiseLandingSyncSchedular.insertErrorHistory('requestTestString','responseTestString', listLandingSync[0]);
        listLandingSync[0].Last_JobId__c = jobId;
        inwiseLandingSyncSchedular.schedulejob(listLandingSync[0], false);
        /*------------------*/
        
        List<Sync__c> syncList = new List<Sync__c>();
        for(integer i=0;i<=5;i++){
            syncList.add(new Sync__c(name = 'contactSync'+i,Group_Name__c = 'campaign5'));
        }
        insert syncList;         
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objInwiseAccountResult);
        InwiseSetupController objInwiseSetupController=new InwiseSetupController(sc);   
        list<Account__c> lstAcc = [SELECT Id, Name, Password__c, Token__c, User_Name__c, Default_Campaign_Type__c, ListEmailFeedBackActionMaxId__c, ListEmailSentMessageMaxId__c FROM Account__c]; 
        objInwiseAccountResult = lstAcc.get(0);
        objInwiseSetupController.selectedAccId = objInwiseAccountResult.ID;
        System.assertEquals(objInwiseSetupController.authenticationToken,null);
        objInwiseSetupController.getAuthenticationToken();
        System.assertNotEquals(objInwiseSetupController.authenticationToken,null);
        
        System.assertEquals(objInwiseSetupController.hasNextLandingSync,false);
        objInwiseSetupController.NextLandingSync();
        System.assertEquals(objInwiseSetupController.hasNextLandingSync,true);
        System.assertEquals(objInwiseSetupController.hasPreviousLandingSync,false);       
        objInwiseSetupController.PreviousLandingSync();      
        System.assertEquals(objInwiseSetupController.hasPreviousLandingSync,true);          
        objInwiseSetupController.toDeleteId = listLandingSync[0].Id;         
        objInwiseSetupController.deleteLandingSync();
        System.assertEquals(objInwiseSetupController.listOfWrapperLandingSync.size(),5);
        objInwiseSetupController.doLandingPageSyncfromSFtoInwise(); 
        objInwiseSetupController.isHelpOnload = true;
        objInwiseSetupController.toggleshowhelp();   
        System.assertEquals(objInwiseSetupController.hasNext,false);
        objInwiseSetupController.Next();
        System.assertEquals(objInwiseSetupController.hasNext,true);
        System.assertEquals(objInwiseSetupController.hasPrevious,false);       
        objInwiseSetupController.Previous();      
        System.assertEquals(objInwiseSetupController.hasPrevious,true);  
        objInwiseSetupController.doExecuteLandingSync();
        objInwiseSetupController.doSyncoptout();
        objInwiseSetupController.sortLandingSyncResults();
        System.assertEquals('Turn Off Email Opt-in/out',objInwiseSetupController.TurnOnOffEmailOptInOptOutBtnLabel);
    }
    
    static testmethod  void myUnitTest4() { 
        
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
        con.HasOptedOutOfEmail = true;
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'inwise';
        objLead.LastName = 'Test Lead';
        objLead.email = 'inwise@inwisetest.com';
        objLead.status = 'Open - Not Contacted';        
        objLead.company = 'inwise';
        objLead.mobilephone = '123456789';
        objLead.HasOptedOutOfEmail = true;
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
        objSync.Is_Created_By_View__c  = true;
        objSync.Account__c = act1.id;
        insert objSync; 
        
        PageReference pageRef = Page.inwiseHome;
        Test.setCurrentPage(pageRef);
        System.debug('account-->>' +act1);
        ApexPages.StandardController sc = new ApexPages.StandardController(act1);
        InwiseSetupController objInwiseSetupController=new InwiseSetupController(sc); 
        PageReference pr = objInwiseSetupController.getAuthenticationToken();
        System.assertEquals(null,pr);
        PageReference pr2 = objInwiseSetupController.doSyncoptout(); 
        System.assertEquals(null,pr2);
    }
}