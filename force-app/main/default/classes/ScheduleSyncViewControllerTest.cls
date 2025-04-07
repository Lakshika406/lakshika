/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Updated On:  
*Purpose :    Test Code coverage for ScheduleSyncViewController
/******************************************************************************************/
@isTest
private class ScheduleSyncViewControllerTest {
    
    static testmethod void ScheduleSyncViewControllerTestMethod(){
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c =true;
        insert objSetting;

        
        
        User user = inwiseTestDataFactory.createTestUser();
        insert user;
        //System.runAs(user) {

            Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
            insert tokenSetting;  

            Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
            act1.Default__c = true;
            insert act1;   

            tokenSetting.Account_Id__c = act1.Id;
            update tokenSetting;  
            
            Account_SalesforceUser_Mapping__c objAccoutUserMapping = inwiseTestDataFactory.createAccountSalesforceUserMapping(); 
            objAccoutUserMapping.User__c = UserInfo.getUserId();
            objAccoutUserMapping.Account__c = act1.Id;
            insert objAccoutUserMapping;
            
            map<String, Mapping__c> mappingMap = new  map<String, Mapping__c>();
            mappingMap = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
            Mapping__c mappingRec = mappingMap.get('Contact');
            insert mappingRec ;
            
            mappingRec = mappingMap.get('Lead');
            insert mappingRec ; 
            
            lead objLead = new Lead(firstname='Test',lastname='Lead',company='company');
            
            Sync__c objSync = new Sync__c();
            objSync.name = 'leadSync';
            objSync.Leads__c = true;
            objSync.Leads_SOQL__c = objLead.id;
            objSync.Is_Created_By_View__c = true;
            objSync.Contacts__c = true;
            objSync.Account__c = act1.id;
            objSync.Scheduled_Daily_At__c = '1:00 AM';
            
            Test.setCurrentPage(Page.ScheduleSyncView);
            ApexPages.StandardController std = new ApexPages.StandardController(objSync);
            std = new ApexPages.StandardController(new Sync__c());
            ScheduleSyncViewController objScheduleSyncViewController = new ScheduleSyncViewController(std);
            objScheduleSyncViewController.init();
            PageReference pr = objScheduleSyncViewController.doCancel();
            
            Test.setCurrentPage(Page.ScheduleSyncView);
            ApexPages.currentPage().getParameters().put('sid', objSync.Id);       
            objScheduleSyncViewController.nextStep(); 
            objScheduleSyncViewController.getInwiseGroups();
            objScheduleSyncViewController.objWrapperSync.objSync.Is_Created_By_View__c = true;
            objScheduleSyncViewController.objWrapperSync.objSync.Contacts__c =true;
            objScheduleSyncViewController.objWrapperSync.objSync.Name = 'Sync1';
            objScheduleSyncViewController.objWrapperSync.selectedGroup = '';
            objScheduleSyncViewController.strGroupName = 'group1';
            System.assertEquals(objScheduleSyncViewController.objWrapperSync.currentStep,'Step1');
            objScheduleSyncViewController.nextStep();
            
            objScheduleSyncViewController.selectedViewType = objScheduleSyncViewController.listOfViewType.get(1).getValue();
            objScheduleSyncViewController.nextStep();
            objScheduleSyncViewController.doLoadViews();
            objScheduleSyncViewController.objWrapperSync.objSync.Contact_View__c = objScheduleSyncViewController.listOfAvailableView.get(2).getValue();
            objScheduleSyncViewController.selectedView = objScheduleSyncViewController.listOfAvailableView.get(2).getValue();
            system.debug('selectedview is--->>' +objScheduleSyncViewController.selectedView);
            objScheduleSyncViewController.nextStep();
            objScheduleSyncViewController.doPrevStep();
            objSync.Leads__c =true;
            objScheduleSyncViewController.selectedViewType = objScheduleSyncViewController.listOfViewType.get(2).getValue();
            objScheduleSyncViewController.nextStep();
            objScheduleSyncViewController.doLoadViews();
            objsync.Lead_View__c  =  objScheduleSyncViewController.listOfAvailableView.get(1).getValue();
            objScheduleSyncViewController.selectedView = objScheduleSyncViewController.listOfAvailableView.get(1).getValue();
            
            insert objSync;
            System.debug('sync--->>' +objSync);
            objScheduleSyncViewController.nextStep();
            objScheduleSyncViewController.redirectToSyncWizard();
            
            List<ScheduleSyncViewController.WrapperResult> listWrap = new List<ScheduleSyncViewController.WrapperResult>();
            listWrap.add(new ScheduleSyncViewController.WrapperResult(objSync.Id, 'Test Sync'));
        //}
    }
    
    //when group is selected not create
    static testmethod void ScheduleSyncViewControllerTestMethod2(){
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c =true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;  

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Account_SalesforceUser_Mapping__c objAccoutUserMapping = inwiseTestDataFactory.createAccountSalesforceUserMapping(); 
        objAccoutUserMapping.User__c = UserInfo.getUserId();
        objAccoutUserMapping.Account__c = act1.Id;
        insert objAccoutUserMapping;
        
        map<string,Mapping__c> mappingMap = new  map<string,Mapping__c>();
        mappingMap= inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        Mapping__c mappingRec = mappingMap.get('Contact');
        insert mappingRec ;
        mappingRec = mappingMap.get('Lead');
        insert mappingRec ; 
        
        lead objLead = new Lead(firstname='Test',lastname='Lead',company='company');
        
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Leads__c = true;
        objSync.Leads_SOQL__c = objLead.id;
        objSync.Is_Created_By_View__c = true;
        objSync.Contacts__c = true;
        objSync.Account__c = act1.id;
        objSync.Scheduled_Daily_At__c = '1:00 AM';
        insert objSync;
        
        Test.setCurrentPage(Page.ScheduleSyncView);
        ApexPages.currentPage().getParameters().put('sid', objSync.Id);
        ApexPages.StandardController std1 = new ApexPages.StandardController(new Sync__c());
        ScheduleSyncViewController objScheduleSyncViewController1 = new ScheduleSyncViewController(std1);
        
        ApexPages.StandardController std = new ApexPages.StandardController(objSync);
        std = new ApexPages.StandardController(new Sync__c());
        ScheduleSyncViewController objScheduleSyncViewController = new ScheduleSyncViewController(std);
        objScheduleSyncViewController.init();
        PageReference pr = objScheduleSyncViewController.doCancel();
        
        Test.setCurrentPage(Page.ScheduleSyncView);
        ApexPages.currentPage().getParameters().put('sid', objSync.Id);       
        objScheduleSyncViewController.nextStep();
        System.debug('=objScheduleSyncViewController.listOfSelectOptionGroups=='+objScheduleSyncViewController.listOfSelectOptionGroups);
        
        objScheduleSyncViewController.objWrapperSync.objSync.Is_Created_By_View__c = true;
        objScheduleSyncViewController.objWrapperSync.objSync.Name = 'Sync1';
        objScheduleSyncViewController.objWrapperSync.selectedGroup = objScheduleSyncViewController.listOfSelectOptionGroups.get(1).getValue();
        objScheduleSyncViewController.objWrapperSync.currentStep = 'Step2'; 
        System.assertEquals(objScheduleSyncViewController.objWrapperSync.currentStep,'Step2');
        objScheduleSyncViewController.nextStep();
        
        objScheduleSyncViewController.selectedViewType = objScheduleSyncViewController.listOfViewType.get(1).getValue();
        objScheduleSyncViewController.nextStep();
        objScheduleSyncViewController.doLoadViews();
        
        objScheduleSyncViewController.selectedView = objScheduleSyncViewController.listOfAvailableView.get(2).getValue();
        system.debug('selectedview is--->>' +objScheduleSyncViewController.selectedView);
        objScheduleSyncViewController.nextStep();
        objScheduleSyncViewController.doPrevStep();
        objSync.Leads__c =true;
        objScheduleSyncViewController.selectedViewType = objScheduleSyncViewController.listOfViewType.get(2).getValue();
        objScheduleSyncViewController.objWrapperSync.currentStep = 'Step2'; 
        objScheduleSyncViewController.nextStep();
        System.assertEquals(objScheduleSyncViewController.objWrapperSync.currentStep,'Step2');
        objScheduleSyncViewController.doLoadViews();
        
        objScheduleSyncViewController.selectedView = objScheduleSyncViewController.listOfAvailableView.get(1).getValue();
        objScheduleSyncViewController.objWrapperSync.currentStep = 'Step2'; 
        objScheduleSyncViewController.nextStep();
        System.assertEquals(objScheduleSyncViewController.objWrapperSync.currentStep,'Step2');
        objScheduleSyncViewController.nextStep();
    }
}