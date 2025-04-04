/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 12/05/2016
*Purpose :     test class for new landing page sync controller
*Modified:   
/******************************************************************************************/
@isTest
private class inwiseScheduleLandingSyncControllerTest {

     static testmethod void inwiseScheduleLandingSyncController_AddNewRec() {
        // Implement test code
          Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
          objSetting.Track_Logs__c =true;
          insert objSetting;

          Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
          insert tokenSetting;  

          Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
          act1.Default__c = true;

          tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  

          lead objLead = new Lead(firstname='Test',lastname='Lead',company='company',phone='1234567890');
          insert objLead; 
          Test.setCurrentPage(Page.inwiseScheduleLandingSync);
          ApexPages.StandardController std = new ApexPages.StandardController(new Landing_Sync__c());
          inwiseScheduleLandingSyncController objInwiseScheduleLandingSyncController = new inwiseScheduleLandingSyncController(std);
          insert act1;
           
          objInwiseScheduleLandingSyncController = new inwiseScheduleLandingSyncController(std); 
          objInwiseScheduleLandingSyncController.getLandingPagesList();
         objInwiseScheduleLandingSyncController.getLandingPagesListOnAccChange();
         objInwiseScheduleLandingSyncController.OnLoadCheckLandingPageAndPopup();
          PageReference pr1 = objInwiseScheduleLandingSyncController.nextStep(); 
          System.assertEquals(ApexPages.getMessages().get(0).getSummary(),'Invalid CSRF token. Action cannot be performed.');     
          objInwiseScheduleLandingSyncController.objWrapperSync.objSync.Name = 'Test landing Sync';

          pr1 = objInwiseScheduleLandingSyncController.nextStep(); 
          objInwiseScheduleLandingSyncController.objWrapperSync.objSync.Landing_Page_Id__c = 5341;
          PageReference pr2 = objInwiseScheduleLandingSyncController.nextStep(); 
          PageReference pr3 = objInwiseScheduleLandingSyncController.doPrevStep(); 
          PageReference pr4 = objInwiseScheduleLandingSyncController.nextStep();
          System.assertEquals(objInwiseScheduleLandingSyncController.objWrapperSync.CONS_STEP2,objInwiseScheduleLandingSyncController.objWrapperSync.currentStep);
          PageReference pr5 = objInwiseScheduleLandingSyncController.nextStep(); 
          PageReference pr6 = objInwiseScheduleLandingSyncController.nextStep(); 
         
          // Also check assertEquals for index 3 and message Please select mapping
          System.assertEquals(ApexPages.getMessages().get(1).getSummary(),'Required field Sync Name should not be blank');        
    }

    static testmethod void inwiseScheduleLandingSyncController_EditRec() {
    
        // Implement test code
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

        lead objLead = new Lead(firstname='Test',lastname='Lead',company='company',phone='1234567890',email='testrecord@testrecord.com');
        insert objLead;
        
        Landing_Sync__c objLandingSync1 = new Landing_Sync__c();
        objLandingSync1.Name = 'Test Landing Page';
        objLandingSync1.Landing_Page_Name__c = 'Landing Page1';
        objLandingSync1.Leads__c = true;
        objLandingSync1.Landing_Page_Id__c = null;
         objLandingSync1.Form_Type__c=null;
         insert objLandingSync1;
         Test.setCurrentPage(Page.inwiseScheduleLandingSync);
       
         ApexPages.currentPage().getParameters().put('id', objLandingSync1.Id);
        ApexPages.StandardController std2 = new ApexPages.StandardController(new Landing_Sync__c());
        inwiseScheduleLandingSyncController objInwiseScheduleLandingSyncController1 = new inwiseScheduleLandingSyncController(std2);
        objInwiseScheduleLandingSyncController1.nextStep();
        
        Landing_Sync__c objLandingSync = new Landing_Sync__c();
        objLandingSync.Name = 'Test Landing Page';
        objLandingSync.Landing_Page_Name__c = 'Landing Page1';
        objLandingSync.Leads__c = true;
        objLandingSync.Landing_Page_Id__c = 5341;
        objLandingSync.Form_Type__c='Landing Page';
        insert objLandingSync;
        List<Landing_Sync_Mapping__c> listLandingSyncMapping = new List<Landing_Sync_Mapping__c>();
        listLandingSyncMapping.add(new Landing_Sync_Mapping__c(Landing_Sync__c = objLandingSync.id, inwise_Field__c = 'Name',Salesforce_Field__c ='FirstName'));
        listLandingSyncMapping.add(new Landing_Sync_Mapping__c(Landing_Sync__c = objLandingSync.id, inwise_Field__c = 'Phone',Salesforce_Field__c ='Phone'));
        insert listLandingSyncMapping;
        Test.setCurrentPage(Page.inwiseScheduleLandingSync);
        ApexPages.currentPage().getParameters().put('id', objLandingSync.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Landing_Sync__c());
        inwiseScheduleLandingSyncController objInwiseScheduleLandingSyncController = new inwiseScheduleLandingSyncController(std);
       
        objInwiseScheduleLandingSyncController.objWrapperSync.objSync.Form_Type__c='Landing Page';
        ApexPages.StandardController std1 = new ApexPages.StandardController(new Sync__c());
        inwiseScheduleSyncController objinwiseScheduleSyncController = new inwiseScheduleSyncController(std1);
        objInwiseScheduleLandingSyncController.getLandingPagesList();
         
        PageReference pr1 = objInwiseScheduleLandingSyncController.nextStep();         
        System.assertEquals(objInwiseScheduleLandingSyncController.objWrapperSync.Step2,true);
        PageReference pr2 = objInwiseScheduleLandingSyncController.doCancel();
        ApexPages.currentPage().getParameters().put('id', objLandingSync.Id);   
        PageReference pr3 = objInwiseScheduleLandingSyncController.nextStep(); 
        objInwiseScheduleLandingSyncController.objWrapperSync.listOfLandingSyncMapping[0].inwise_Field__c = 'email';
        objInwiseScheduleLandingSyncController.objWrapperSync.listOfLandingSyncMapping[0].Salesforce_Field__c = 'email';
    }
}