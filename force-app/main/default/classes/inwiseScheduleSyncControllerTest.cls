/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     test class for inwiseScheduleSyncController
/******************************************************************************************/
@isTest
private class inwiseScheduleSyncControllerTest {
   static testMethod void inwiseScheduleSyncControllerTest1(){

        List<Logs__c> listOfLog = new List<Logs__c>();
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
            
        User usr = inwiseTestDataFactory.createTestUser();
        insert usr;
        
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
        Test.setCurrentPage(Page.inwiseschedulesync);
        ApexPages.StandardController std = new ApexPages.StandardController(new Sync__c());
        inwiseScheduleSyncController objinwiseScheduleSyncController = new inwiseScheduleSyncController(std);

        insert objLead; 
        Contact objContact = new Contact(firstname='Test Contact',lastname='1',email='inwisetestcontact@inwise.com',birthdate=System.Today()-30);
        insert objContact;         

        Sync__c objSync = inwiseTestDataFactory.createTestSync(); 
        objSync.Leads_SOQL__c = objLead.id;
        objSync.Group_Name__c = 'campaign5';
        insert objSync;
        
        List<Sync_Filter__c> listOfSyncFilter = new List<Sync_Filter__c>();
        Sync_Filter__c objSyncFilterNew = inwiseTestDataFactory.createTestSyncFilter(objSync);
        insert objSyncFilterNew;
        listOfSyncFilter.add(objSyncFilterNew);
         
        inwiseScheduleSyncObject.WrapperFilter testWrap = new inwiseScheduleSyncObject.WrapperFilter('Sync_Filter__c'); 
        testWrap.objSyncFilter = objSyncFilterNew;
        List<inwiseScheduleSyncObject.WrapperFilter> listOfTestWrap = new List<inwiseScheduleSyncObject.WrapperFilter>();
        listOfTestWrap.add(testWrap);

        Test.setCurrentPage(Page.inwiseschedulesync);
        ApexPages.currentPage().getParameters().put('id', objSync.Id);

        std = new ApexPages.StandardController(new Sync__c());
        objinwiseScheduleSyncController = new inwiseScheduleSyncController(std);
        objinwiseScheduleSyncController.init();
       
        objinwiseScheduleSyncController.doCreateGroup(objSync.Group_Name__c, listOfLog); 
        objinwiseScheduleSyncController.doDeletePreviousFilters(listOfSyncFilter); 
        objinwiseScheduleSyncController.getNewSyncFilter(objSyncFilterNew);
        PageReference pr = objinwiseScheduleSyncController.doCancel();
        Test.setCurrentPage(Page.inwiseschedulesync);
        ApexPages.currentPage().getParameters().put('id', objSync.Id);       
        objinwiseScheduleSyncController.nextStep();
        System.assertNotEquals(objinwiseScheduleSyncController.typeVsOperatorString,NULL);     
        objinwiseScheduleSyncController.objWrapperSync.selectedGroup = objinwiseScheduleSyncController.listOfSelectOptionGroups.get(1).getValue();
      
       objinwiseScheduleSyncController.strGroupName = 'group 11';
       objinwiseScheduleSyncController.objWrapperSync.selectedGroup ='';
      
       objinwiseScheduleSyncController.objWrapperSync.objSync.Is_Created_By_View__c=true;
       objinwiseScheduleSyncController.objWrapperSync.objSync.Is_Created_By_Report__c=true;
       
        System.assertEquals(objinwiseScheduleSyncController.objWrapperSync.currentStep,'Step1');
        System.assertEquals(objinwiseScheduleSyncController.objWrapperSync.Step1,true);

        objinwiseScheduleSyncController.nextStep();
        System.assertEquals(objinwiseScheduleSyncController.objWrapperSync.currentStep,'Step2');

        System.assertEquals(objinwiseScheduleSyncController.objWrapperSync.Step2,true);
        objinwiseScheduleSyncController.nextStep();

        objinwiseScheduleSyncController.objWrapperSync.objSync.Leads__c = true;
        objinwiseScheduleSyncController.objWrapperSync.objSync.Contacts__c = true;
        System.assert(objinwiseScheduleSyncController.objSyncLead.listOfSelectOptionFields_Lead.Size()>1,'lead fields could not be fetched');
        System.assert(objinwiseScheduleSyncController.objSyncContact.listOfSelectOptionFields_Contact.Size()>1,'Contact fields could not be fetched');
         
        objinwiseScheduleSyncController.objSyncLead.listOfSyncFilters.get(0).objSyncFilter.Field_Api_Name__c = 'Name:STRING';
        objinwiseScheduleSyncController.objSyncLead.doAddRow();
        objinwiseScheduleSyncController.objSyncLead.listOfSyncFilters.get(0).objSyncFilter.Operator__c = 'Equals';
        objinwiseScheduleSyncController.objSyncLead.doAddRow();
        objinwiseScheduleSyncController.objSyncLead.listOfSyncFilters.get(0).objSyncFilter.Value__c = 'Test Lead';
        objinwiseScheduleSyncController.objSyncLead.doAddRow();
        objinwiseScheduleSyncController.objSyncLead.listOfSyncFilters.get(0).objSyncFilter.Field_Api_Name__c = 'Name:STRING';
        objinwiseScheduleSyncController.objSyncLead.listOfSyncFilters.get(0).objSyncFilter.Operator__c = 'not equal to';
        objinwiseScheduleSyncController.objSyncLead.listOfSyncFilters.get(0).objSyncFilter.Value__c = 'Test Lead2';

        objinwiseScheduleSyncController.objSyncLead.doAddRow();       
        objinwiseScheduleSyncController.objSyncLead.toDeleteRow = 1;
        objinwiseScheduleSyncController.objSyncLead.doDeleteRow();

        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Field_Api_Name__c = 'Name:STRING';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Operator__c = 'Contains';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Value__c = 'Test Contact';    
        objinwiseScheduleSyncController.objSyncContact.doAddRow();  
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(1).objSyncFilter.Field_Api_Name__c = 'email:STRING';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(1).objSyncFilter.Operator__c = 'equals';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(1).objSyncFilter.Value__c = 'inwisetestcontact@inwise.com';           
        objinwiseScheduleSyncController.objSyncContact.doAddRow();  
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(2).objSyncFilter.Field_Api_Name__c = 'email:STRING';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(2).objSyncFilter.Operator__c = 'not equal to';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(2).objSyncFilter.Value__c = 'inwisetestcontact1@inwise.com'; 
        objinwiseScheduleSyncController.objSyncContact.doAddRow();  
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(3).objSyncFilter.Field_Api_Name__c = 'email:STRING';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(3).objSyncFilter.Operator__c = 'starts with';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(3).objSyncFilter.Value__c = 'inwisetestcontact'; 
        objinwiseScheduleSyncController.objSyncContact.doAddRow();  
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(4).objSyncFilter.Field_Api_Name__c = 'Birthdate:Date';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(4).objSyncFilter.Operator__c = 'less than';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(4).objSyncFilter.Value__c = '11/18/2016';   
        objinwiseScheduleSyncController.objSyncContact.doAddRow();  
       objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(5).objSyncFilter.Field_Api_Name__c = 'Birthdate:Date';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(5).objSyncFilter.Operator__c = 'less or equal';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(5).objSyncFilter.Value__c = '11/18/2016';               
        objinwiseScheduleSyncController.objSyncContact.doAddRow();  
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(6).objSyncFilter.Field_Api_Name__c = 'Birthdate:Date';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(6).objSyncFilter.Operator__c = 'equals';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(6).objSyncFilter.Value__c = ''; 
        objinwiseScheduleSyncController.objSyncContact.doAddRow();  
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(7).objSyncFilter.Field_Api_Name__c = 'Birthdate:Date';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(7).objSyncFilter.Operator__c = 'greater than';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(7).objSyncFilter.Value__c = '10/18/2016';    
        objinwiseScheduleSyncController.objSyncContact.doAddRow();  
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(8).objSyncFilter.Field_Api_Name__c = 'Birthdate:Date';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(8).objSyncFilter.Operator__c = 'greater or equal';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(8).objSyncFilter.Value__c = '10/18/2016';    
        objinwiseScheduleSyncController.objSyncContact.doAddRow();
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(9).objSyncFilter.Field_Api_Name__c = 'Name:STRING';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(9).objSyncFilter.Operator__c = 'does not contain';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(9).objSyncFilter.Value__c = 'Test Contact2';    
        objinwiseScheduleSyncController.objSyncContact.doAddRow();
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(10).objSyncFilter.Field_Api_Name__c = 'createdDate:DATETIME';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(10).objSyncFilter.Operator__c = 'not equal to';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(10).objSyncFilter.Value__c = ''; 
        objinwiseScheduleSyncController.objSyncContact.doAddRow();
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(11).objSyncFilter.Field_Api_Name__c = 'Industry:Picklist';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(11).objSyncFilter.Operator__c = 'starts with';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(11).objSyncFilter.Value__c = 'Agriculture';
        objinwiseScheduleSyncController.objSyncContact.doAddRow();
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(12).objSyncFilter.Field_Api_Name__c = 'Location__c:MULTIPICKLIST';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(12).objSyncFilter.Operator__c = 'equals';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(12).objSyncFilter.Value__c = 'India,UK';
       objinwiseScheduleSyncController.objSyncContact.doAddRow();
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(13).objSyncFilter.Field_Api_Name__c = 'Industry:Picklist';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(13).objSyncFilter.Operator__c = 'contains';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(13).objSyncFilter.Value__c = 'Agriculture';
       objinwiseScheduleSyncController.objSyncContact.doAddRow();
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(14).objSyncFilter.Field_Api_Name__c = 'Industry:Picklist';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(14).objSyncFilter.Operator__c = 'does not contain';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(14).objSyncFilter.Value__c = 'Agriculture';
         objinwiseScheduleSyncController.objSyncContact.doAddRow();
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(15).objSyncFilter.Field_Api_Name__c = 'Location__c:MULTIPICKLIST';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(15).objSyncFilter.Operator__c = 'contains';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(15).objSyncFilter.Value__c = 'India,UK';
        objinwiseScheduleSyncController.objSyncContact.doAddRow();
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(16).objSyncFilter.Field_Api_Name__c = 'Location__c:MULTIPICKLIST';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(16).objSyncFilter.Operator__c = 'does not contain';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(16).objSyncFilter.Value__c = 'India,UK';
       objinwiseScheduleSyncController.objSyncContact.doAddRow();
        

        PageReference pr2 = objinwiseScheduleSyncController.nextStep();

        objinwiseScheduleSyncController.doPrevStep();
        objinwiseScheduleSyncController.nextStep();
        objinwiseScheduleSyncController.nextStep();

        Test.setCurrentPage(Page.inwiseschedulesync);
        ApexPages.currentPage().getParameters().put('id', objSync.Id);

        std = new ApexPages.StandardController(new Sync__c());
        objinwiseScheduleSyncController = new inwiseScheduleSyncController(std);
        objinwiseScheduleSyncController.nextStep();
        objinwiseScheduleSyncController.nextStep();
        objinwiseScheduleSyncController.nextStep();

        Test.setCurrentPage(Page.inwiseschedulesync);
        ApexPages.currentPage().getParameters().put('id', objSync.Id);

        std = new ApexPages.StandardController(new Sync__c());
        objinwiseScheduleSyncController = new inwiseScheduleSyncController(std);
        objinwiseScheduleSyncController.nextStep();
         objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Field_Api_Name__c = 'createdDate:DATETIME';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Operator__c = 'Greater Than';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Value__c = '';         
        objinwiseScheduleSyncController.nextStep();
         objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Field_Api_Name__c = 'createdDate:DATETIME';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Operator__c = 'Greater Than';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Value__c = '2017/12-12';
        PageReference pr1 =  objinwiseScheduleSyncController.nextStep();   
         objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Field_Api_Name__c = 'Birthdate:Date';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Operator__c = 'Greater Than';
        objinwiseScheduleSyncController.objSyncContact.listOfSyncFilters.get(0).objSyncFilter.Value__c = '2017-12-12';  
        objinwiseScheduleSyncController.nextStep();  
        objinwiseScheduleSyncController.doSaveFilters(listOfTestWrap, 'Sync_Filter__c');
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(msgList.size(),7) ;    
        System.assertEquals(msgList[5].getSummary().contains('24 hours format'),true);         
   }
}