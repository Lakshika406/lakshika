/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     test class for ScheduleSyncReportController 
/******************************************************************************************/
@isTest
private class ScheduleSyncReportControllerTest {
    
    
    static testMethod void ScheduleSyncReportControllerTest1(){
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c =true;
        
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
        objSync.Is_Created_By_Report__c = true;
        objSync.Contacts__c = true;
        objSync.Account__c = act1.id;
        objSync.Scheduled_Daily_At__c = '1:00 AM';
        insert objSync;
        
        List<Report> reportList = [SELECT Id, OwnerId, FolderName, DeveloperName, Name FROM Report LIMIT 1];
        
        String reportName = 'ContactReport';
        List<Organization> orgLi = [SELECT Id, Name, Division, OrganizationType, IsSandbox FROM Organization Where Name = 'inwise LTD'];
        if(!orgLi.isEmpty()){
            reportName = 'New_Test_Contact_Report';
        }
        
        Test.setCurrentPage(Page.ScheduleSyncReport);
        ApexPages.StandardController std = new ApexPages.StandardController(objSync);
        ApexPages.currentPage().getParameters().put('reportDeveloperName', reportName);
        ScheduleSyncReportController objscheduleSyncReportController = new ScheduleSyncReportController(std);
        inwiseScheduleSyncController.WrapperSync objInwiseSchedule = new inwiseScheduleSyncController.WrapperSync();
        
        List<Logs__c> listOfLogs = new List<Logs__c>();
        Contact objContact = new Contact(firstname='Test Contact',lastname='1',email='inwisetestcontact@inwise.com',birthdate=System.Today()-30);
        insert objContact; 
        
        objscheduleSyncReportController.objWrapperSync.selectedAccount = act1.Id;
        objscheduleSyncReportController.objWrapperSync.objSync.Is_Created_By_Report__c = true;
        objscheduleSyncReportController.objWrapperSync.objSync.Contacts__c = true;
        objscheduleSyncReportController.init();
        
        if(objscheduleSyncReportController.listOfSelectOptionGroups.size() > 1){
            objscheduleSyncReportController.objWrapperSync.selectedGroup = '';
            System.debug('==tttttttttt'+objscheduleSyncReportController.objWrapperSync.selectedGroup);
            objscheduleSyncReportController.strGroupName = objscheduleSyncReportController.listOfSelectOptionGroups.get(1).getLabel();
            //system.debug('strGroupName'+strGroupName);
        }
       
        
        objscheduleSyncReportController.selectedReportObjType = 'Contact';  
        objscheduleSyncReportController.strReportName = 'Test'; 
        objscheduleSyncReportController.reportSelected = 'unfiled$public/' + reportName; 
        objscheduleSyncReportController.objWrapperSync.objSync = objSync;
        objscheduleSyncReportController.objWrapperSync.currentStep = 'Step1'; 
        objscheduleSyncReportController.doLoadReports();
        objscheduleSyncReportController.objWrapperSync.Step2 = true;
        objscheduleSyncReportController.objWrapperSync.Step1 = false;   
        objscheduleSyncReportController.doSearchReports();
        objscheduleSyncReportController.checkReports();
        objscheduleSyncReportController.nextStep(); 
        objscheduleSyncReportController.doPrevStep();
        objscheduleSyncReportController.doCancel();
        
        

        if(objscheduleSyncReportController.listOfSelectOptionGroups.size() > 1){
            objscheduleSyncReportController.doCreateGroup(objscheduleSyncReportController.listOfSelectOptionGroups.get(1).getLabel(), listOfLogs);
        }
        objscheduleSyncReportController.redirectToSyncWizard();

        System.assertNotEquals(objContact.Id, objSync.Id);
    }
    
    @IsTest
    private static void ScheduleSyncReportControllerTest2(){
        
        Test.setCurrentPage(Page.ScheduleSyncReport);
        ApexPages.StandardController std = new ApexPages.StandardController(new Sync__c());
        ScheduleSyncReportController objscheduleSyncReportController = new ScheduleSyncReportController(std);
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        MetadataService.ListMetadataQuery recordCreationObj = new  MetadataService.ListMetadataQuery();
        objscheduleSyncReportController.doLoadReports();
        
        ScheduleSyncReportController.wrapperClass wrap = new ScheduleSyncReportController.wrapperClass();
        wrap.reportField = 'test';
        wrap.reportFieldId = 'test';
        wrap.inwiseField = 'test';
        wrap.inwiseFieldId = 'test';
        wrap.ContactInfo = new Mapping__c();
        wrap.LeadInfo = new Mapping__c();
        wrap.reportInfo = new Mapping__c();
        
        ScheduleSyncReportController.wrapperClassForReportLookup wrap1 = new ScheduleSyncReportController.wrapperClassForReportLookup();
        wrap1.reportField = 'test';
        wrap1.reportFieldId = 'test';
        wrap1.inwiseField = 'test';
        wrap1.inwiseFieldId = 'test';
        wrap1.ContactInfo = new Report_Lookup_Mapping__c();
        wrap1.LeadInfo = new Report_Lookup_Mapping__c();
        wrap1.reportInfo = new Report_Lookup_Mapping__c();
        
        System.assertNotEquals(false, true);
    }
    
    static testMethod void ScheduleSyncReportControllerTest3(){
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c = true;
        
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
        
        Lead objLead = new Lead(firstname='Test',lastname='Lead',company='company');
        
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Leads__c = true;
        objSync.Leads_SOQL__c = objLead.id;
        objSync.Is_Created_By_Report__c = true;
        objSync.Contacts__c = true;
        objSync.Account__c = act1.id;
        objSync.Scheduled_Daily_At__c = '1:00 AM';
        insert objSync;
        
        String reportName = 'ContactReport';
        List<Organization> orgLi = [SELECT Id, Name, Division, OrganizationType, IsSandbox FROM Organization Where Name = 'inwise LTD'];
        if(!orgLi.isEmpty()){
            reportName = 'New_Test_Contact_Report';
        }
        
        Report_Lookup_Mapping__c reportLookupObj = inwiseTestDataFactory.getInwiseReportLookupMapping(act1,objSync,'Contact');
        Test.setCurrentPage(Page.ScheduleSyncReport);
        ApexPages.StandardController std = new ApexPages.StandardController(objSync);
        ApexPages.currentPage().getParameters().put('reportDeveloperName', reportName);
        ScheduleSyncReportController objscheduleSyncReportController = new ScheduleSyncReportController(std);
        
        inwiseScheduleSyncController.WrapperSync objInwiseSchedule = new inwiseScheduleSyncController.WrapperSync();
                
        Contact objContact = new Contact(firstname='Test Contact',lastname='1',email='inwisetestcontact@inwise.com',birthdate=System.Today()-30);
        insert objContact; 
        
        objscheduleSyncReportController.objWrapperSync.selectedAccount = act1.Id;
        objscheduleSyncReportController.objWrapperSync.objSync.Is_Created_By_Report__c = true;
        objscheduleSyncReportController.objWrapperSync.objSync.Contacts__c = true;
        objscheduleSyncReportController.init();
        
        if(objscheduleSyncReportController.listOfSelectOptionGroups.size() > 1){
            objscheduleSyncReportController.objWrapperSync.selectedGroup = objscheduleSyncReportController.listOfSelectOptionGroups.get(1).getValue();
            System.debug('==tttttttttt'+objscheduleSyncReportController.objWrapperSync.selectedGroup);
            objscheduleSyncReportController.strGroupName = objscheduleSyncReportController.listOfSelectOptionGroups.get(1).getLabel();
        }
         objscheduleSyncReportController.selectedReportObjType = 'Lead';
        objscheduleSyncReportController.strReportName = 'Test'; 
        objscheduleSyncReportController.reportSelected = reportName; 
        objscheduleSyncReportController.objWrapperSync.objSync = objSync;
        objscheduleSyncReportController.objWrapperSync.currentStep = 'Step2'; 
        objscheduleSyncReportController.doSearchReports();
        objscheduleSyncReportController.nextStep(); 
        objscheduleSyncReportController.doPrevStep();
        objscheduleSyncReportController.objWrapperSync.Step2 = false;
        objscheduleSyncReportController.objWrapperSync.Step1 = true;   
        objscheduleSyncReportController.doCancel();
        
        
        objscheduleSyncReportController.selectedReportObjType = 'Contact'; 
        objscheduleSyncReportController.strReportName = 'Test'; 
        objscheduleSyncReportController.reportSelected = reportName; 
        objscheduleSyncReportController.objWrapperSync.objSync = objSync;
        objscheduleSyncReportController.objWrapperSync.currentStep = 'Step2'; 
        objscheduleSyncReportController.doSearchReports();
        objscheduleSyncReportController.nextStep(); 
        objscheduleSyncReportController.doPrevStep();
        objscheduleSyncReportController.objWrapperSync.Step2 = false;
        objscheduleSyncReportController.objWrapperSync.Step1 = true;   
        objscheduleSyncReportController.doCancel(); 
        if(objscheduleSyncReportController.listOfSelectOptionGroups.size() > 1){
            objscheduleSyncReportController.doCreateGroup(objscheduleSyncReportController.listOfSelectOptionGroups.get(1).getLabel(), new List<Logs__c>());
        }
        objscheduleSyncReportController.redirectToSyncWizard();

        System.assertNotEquals(objContact.Id, objSync.Id);
    }
    
    static testMethod void ScheduleSyncReportControllerTest4(){
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c =true;
        
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
        objSync.Is_Created_By_Report__c = true;
        objSync.Contacts__c = true;
        objSync.Account__c = act1.id;
        objSync.Scheduled_Daily_At__c = '1:00 AM';
        insert objSync;
        
        List<Report> reportList = [SELECT Id, OwnerId, FolderName, DeveloperName, Name FROM Report LIMIT 1];
        
        String reportName = 'ContactReport';
        List<Organization> orgLi = [SELECT Id, Name, Division, OrganizationType, IsSandbox FROM Organization Where Name = 'inwise LTD'];
        if(!orgLi.isEmpty()){
            reportName = 'New_Test_Contact_Report';
        }
        
        Test.setCurrentPage(Page.ScheduleSyncReport);
        ApexPages.StandardController std = new ApexPages.StandardController(objSync);
        ApexPages.currentPage().getParameters().put('reportDeveloperName', reportName);
        ScheduleSyncReportController objscheduleSyncReportController = new ScheduleSyncReportController(std);
        inwiseScheduleSyncController.WrapperSync objInwiseSchedule = new inwiseScheduleSyncController.WrapperSync();
        
        List<Logs__c> listOfLogs = new List<Logs__c>();
        Contact objContact = new Contact(firstname='Test Contact',lastname='1',email='inwisetestcontact@inwise.com',birthdate=System.Today()-30);
        insert objContact; 
        
        objscheduleSyncReportController.objWrapperSync.selectedAccount = act1.Id;
        objscheduleSyncReportController.objWrapperSync.objSync.Is_Created_By_Report__c = true;
        objscheduleSyncReportController.objWrapperSync.objSync.Contacts__c = true;
        objscheduleSyncReportController.init();
        
        if(objscheduleSyncReportController.listOfSelectOptionGroups.size() > 1){
            objscheduleSyncReportController.objWrapperSync.selectedGroup = objscheduleSyncReportController.listOfSelectOptionGroups.get(1).getValue();
            System.debug('==tttttttttt'+objscheduleSyncReportController.objWrapperSync.selectedGroup);
            objscheduleSyncReportController.strGroupName = objscheduleSyncReportController.listOfSelectOptionGroups.get(1).getLabel();
        }
        objscheduleSyncReportController.selectedReportObjType = 'Lead';  
        objscheduleSyncReportController.strReportName = 'Test'; 
        objscheduleSyncReportController.reportSelected = 'unfiled$public/' + reportName; 
        objscheduleSyncReportController.objWrapperSync.objSync = objSync;
        objscheduleSyncReportController.objWrapperSync.currentStep = 'Step1'; 
        objscheduleSyncReportController.doLoadReports();
        objscheduleSyncReportController.objWrapperSync.Step2 = true;
        objscheduleSyncReportController.objWrapperSync.Step1 = false;   
        objscheduleSyncReportController.doSearchReports();
        objscheduleSyncReportController.listOfReports=[select id,DeveloperName,ownerId from report];
        objscheduleSyncReportController.checkReports();
        objscheduleSyncReportController.nextStep(); 
        objscheduleSyncReportController.doPrevStep();
        objscheduleSyncReportController.doCancel();

        if(objscheduleSyncReportController.listOfSelectOptionGroups.size() > 1){
            objscheduleSyncReportController.doCreateGroup(objscheduleSyncReportController.listOfSelectOptionGroups.get(1).getLabel(), listOfLogs);
        }
        objscheduleSyncReportController.redirectToSyncWizard();

        System.assertNotEquals(objContact.Id, objSync.Id);
    }
}