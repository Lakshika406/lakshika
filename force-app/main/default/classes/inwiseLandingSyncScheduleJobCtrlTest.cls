/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 02/02/2017
*Purpose :     test class for inwiseLandingSyncScheduleJobController
*Modified:   
/******************************************************************************************/
@isTest
private class inwiseLandingSyncScheduleJobCtrlTest {
     static testmethod void inwiseLandingSyncScheduleJobController_test1() {
        // Implement test code
          Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
          insert objSetting;

          Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
          insert tokenSetting;  

          Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
          act1.Default__c = true;
          insert act1;  
          
          tokenSetting.Account_Id__c = act1.Id;
          update tokenSetting;  
        
          lead objLead = new Lead(lastname='inwise Landing Sync',company='company',status='Open - Not Contacted');
          insert objLead; 
          Test.setCurrentPage(Page.inwiseLandingSyncScheduleJob);
          
          Landing_Sync__c objLandingSync = new Landing_Sync__c();
          objLandingSync.Name = 'Test Landing Sync';
          objLandingSync.Leads__c = true;
          objLandingSync.Landing_Page_Id__c=null;
          //objLandingSync.Landing_Page_Name__c = 'Landing Page1';
          insert objLandingSync;
          ApexPages.currentPage().getParameters().put('retUrl','/apex/inwisehome');
          ApexPages.currentPage().getParameters().put('id',objLandingSync.Id);

          // Test execution start

          test.startTest();
    

          inwiseLandingSyncScheduleJobController obj  = new inwiseLandingSyncScheduleJobController();
          String s =  inwiseLandingSyncScheduleJobController.getCronExpression('12:00 AM');
          System.assertEquals(s,'0 0 0 1/1 * ? *');
          String s1 = inwiseLandingSyncScheduleJobController.getCronExpressionTemp('12:00 AM');
          system.assertNotEquals(s1,'0 11 14 2 12 ? 2017');

          /*******************************************************************************************************************************************************************************
          Page is NOT in use because individual schedule functionality do not work now for LANDING SYNC ------As per input by Boaz - 17 Aug 2017 ---
          ********************************************************************************************************************************************************************************
          pageReference  url1 = obj.gotoHome();
          pageReference  url2 = new pageReference('/apex/inwisehome');
          System.assertEquals(url1.getUrl(),url2.getUrl());             
          obj.doSchedule();
          obj.objSync.Scheduled_Daily_At__c = '12:00 AM';
           obj.doSchedule();
         // obj2.doScheduleNow();
          obj.objSync.Scheduled_Daily_At__c = '12:00 PM';
          obj.doSchedule();
          obj.objSync.Scheduled_Daily_At__c = '10:00 AM';
          obj.doSchedule();
          obj.objSync.Scheduled_Daily_At__c = '10:00 PM';
          obj.objSync.Landing_page_Id__c = 5341;
          obj.doSchedule();
          List<Landing_Sync_Mapping__c> objMappingList = new List<Landing_Sync_Mapping__c>();
          objMappingList.add(new Landing_Sync_Mapping__c(inwise_Field__c = 'Name', inwise_FieldId__c = 'inwise Landing Sync', Landing_Sync__c = obj.objSync.Id , Salesforce_Field__c='LastName'));
          insert objMappingList ;
          obj.doSchedule();
            List<Apexpages.Message> pageMessages = ApexPages.getMessages();
           System.assertEquals(pageMessages[0].getDetail(),'Please select time to schedule a Sync.');   
           System.assertEquals(pageMessages[1].getDetail(),'Scheduled, Please go to home page to see the progress.');       
          // test execution ends
          ****/
          test.stopTest();
    }
     static testmethod void inwiseLandingSyncScheduleJobController_test3(){
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;     

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
      
        lead objLead = new Lead(lastname='inwise Landing Sync',company='company',status='Open - Not Contacted');
        insert objLead; 
        Test.setCurrentPage(Page.inwiseLandingSyncScheduleJob);
        
        Landing_Sync__c objLandingSync = new Landing_Sync__c();
        objLandingSync.Name = 'Test Landing Sync';
        objLandingSync.Leads__c = true;
        objLandingSync.Landing_Page_Id__c=null;
        //objLandingSync.Landing_Page_Name__c = 'Landing Page1';
        insert objLandingSync;
        ApexPages.currentPage().getParameters().put('retUrl','/apex/inwisehome');
        ApexPages.currentPage().getParameters().put('id',objLandingSync.Id);

        // Test execution start

        test.startTest();
       String s =  inwiseLandingSyncScheduleJobController.getCronExpression('12:00 PM');
       System.assertEquals(s,'0 0 12 1/1 * ? *');
        test.stopTest();

     }
   /*******************************************************************************************************************************************************************************
    Page is NOT in use because individual schedule functionality do not work now for LANDING SYNC ------As per input by Boaz - 17 Aug 2017 ---
    ********************************************************************************************************************************************************************************
     static testmethod void inwiseLandingSyncScheduleJobController_test2() {
        // Implement test code
          Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
          insert objSetting;

          lead objLead = new Lead(lastname='inwise Landing Sync',company='company',status='Open - Not Contacted');
          insert objLead; 
          Test.setCurrentPage(Page.inwiseLandingSyncScheduleJob);
          
          Landing_Sync__c objLandingSync = new Landing_Sync__c();
          objLandingSync.Name = 'Test Landing Sync';
          objLandingSync.Leads__c = true;
          objLandingSync.Landing_Page_Id__c=null;
          //objLandingSync.Landing_Page_Name__c = 'Landing Page1';
          insert objLandingSync;
          ApexPages.currentPage().getParameters().put('retUrl','/apex/inwisehome');
          ApexPages.currentPage().getParameters().put('id',objLandingSync.Id);

          // Test execution start

          test.startTest();
          inwiseLandingSyncScheduleJobController obj = new inwiseLandingSyncScheduleJobController();
          obj = new inwiseLandingSyncScheduleJobController();
           obj.doScheduleNow();
           List<Apexpages.Message> pageMessages = ApexPages.getMessages();
           System.assertEquals(pageMessages[0].getDetail(),'Start executing now, please go to home page to see the progress.');
          // test execution ends
          test.stopTest();
    }    
    ************/
}