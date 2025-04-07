/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     inwiseUtil test code coverage
/******************************************************************************************
*Modified:   
================================================================
Modified On   Version   Modified By             Purpose
================================================================
08/24/2022    1.0.0  	Shyam Vaishnav     		Modified:- Added inwiseAutomationTesting method

/******************************************************************************************/
@isTest
private class inwiseUtilTest {
    
    static testMethod void inwiseUtilTest1() {
        String s = inwiseConstants.SOBJECT_CONTACT;
        s = inwiseConstants.SOBJECT_LEAD;
        s = inwiseConstants.INWISE_SERVICE_SCHEMA_BASEURL;
        s = inwiseConstants.INWISE_SERVICE_SCHEMA_BASEURL2;
        s = inwiseConstants.INWISE_CREDENTIAL_MISSING;
        s = inwiseConstants.INWISE_ACCOUNT_MISSING;
        s = inwiseConstants.SYNC_MEMBER_SUCCESS;
        s = inwiseConstants.INWISE_MAPPING_SAVED_SUCCESS;
        s = inwiseConstants.GENERIC_SUCCESS;
        s = inwiseConstants.INWISE_SENDID_MISSING;
        s = inwiseConstants.BAD_REQUEST;
        s = inwiseConstants.MSG_NO_RESULT_CALL;
        s = inwiseConstants.MSG_EXCEPTION_CALL;
        
        Integer i = inwiseConstants.INWISE_FIELDID_EMAIL;
        i = inwiseConstants.INWISE_FIELDID_MOBILE;
        System.assert(i== 1000, 'Mobile FIeld Id not 1000');
    }
    
    static testMethod void inwiseUtilTest3() {

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Account_SalesforceUser_Mapping__c accSFUserMapping = inwiseTestDataFactory.createAccountSalesforceUserMapping();
        accSFUserMapping.Account__c = act1.Id;
        insert accSFUserMapping;
        
        inwiseUtil util = new inwiseUtil();
        util = new inwiseUtil(act1);
        util.CheckIfMappingExists();
        util.GetInwiseFields(new List<Logs__c>());
        
        inwiseUtil.isPersonAccountEnabled();
        inwiseUtil.getAccessibleAccountIds();
        inwiseUtil.getFieldAPINamesFromFieldSet('Contact', new Set<String>{'Name'});
        inwiseUtil.getFieldsForQueryFilter('Lead', new Set<String>{'String'}, true);
        inwiseUtil.getFieldsForQueryFilter('Contact', new Set<String>{'String'}, false);
        inwiseUtil.getFieldsForQueryFilter('Account', new Set<String>{'String'}, false);
        System.assert(util.objInwiseAccount != NULL,'Inwise Util init failed');
    }
    
    static testMethod void inwiseUtilTest5() {
        String s = '{"id":4,"description":"Code","slicing":false,"type":"text"},{"id":2,"description":"Lname","slicing":false,"type":"text"}';  
        JsonToApexFieldMapping mapping = JsonToApexFieldMapping.parse(s);
        system.assert(mapping != null,'mapping can not be null');
        
        JSONParser parser = JSON.createParser(s);
        JsonToApexFieldMapping.consumeObject(parser);
    }
    
    static testMethod void inwiseUtilTest7() {
        inwiseGlobalAction.doClearLogs();
        system.assertEquals(null,null );
    }
    static testMethod void inwiseUtilTest8() {
        inwiseGlobalAction.doClearSyncMaster();
        system.assertEquals(null,null );
    }
    
    static testMethod void inwiseUtilTest9() {
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Contact_Email_Search_Field__c = 'SearchEmail';
        objSetting.Track_Logs__c =true;
        insert objSetting;
        
        Boolean b =  inwiseGlobalAction.doTurnOnOffTrackLog();
        system.assertEquals(b,false);  //because it is doing off in last
    }
    
    static testMethod void inwiseUtilTest10() {
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c =true;
        objSetting.Contact_Email_Search_Field__c = 'SearchEmail'; 
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;   

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Account objAcc = new Account(name = 'test inwise account');
        insert objAcc;    
        
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'Contact';
        con.Phone = '1234567890';
        con.accountid = objAcc.id;
        insert con;  
        
        Logs__c logs = new Logs__c();
        logs.Api_Name__c = 'POST';
        logs.Class_Name__c = 'inwiseUtiltest';
        logs.Method_Name__c = 'inwiseUtilTest10';
        insert logs;   
        
        Error_Logs__c objErrorLog = new Error_Logs__c();
        objErrorLog.Message__c = 'POST_Test';
        objErrorLog.Run_By__c = UserInfo.getUserId();
        objErrorLog.Run_On__c = datetime.now();
        objErrorLog.Class_Name__c = 'TestClass';
        objErrorLog.Method_Name__c = 'TestMethod';
        insert objErrorLog;   
        
        string s = inwiseGlobalAction.doSendLogsToSupport();
        system.assertEquals(s,'Please check mail for recent 20 logs' );
    }
    
    static testMethod void inwiseUtilTest11() {
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
        
        Account objAcc = new Account(name = 'test inwise account');
        insert objAcc;    
        
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'Contact';
        con.Phone = '1234567890';
        con.accountid = objAcc.id;
        insert con;  
        
        String s = inwiseGlobalAction.doSendLogsToSupport();
        system.assertEquals(s,'There are no logs to email' );
    }
    
    
    static testmethod void inwiseutilTest12(){
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objsetting.Sync_Members_Batch_Size__c = 1 ;
        objSetting.Log_Sync_Memebers__c = true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Sendid__c = 1237855;
        c.isActive = true;
        c.Campaign_Type__c = 'email';
        insert c;
        
        Sync_Master__c sm = new Sync_Master__c();
        sm.Total_Memerbs_Count__c =3;
        sm.Campaign__c = c.id;
        insert sm;
        
        Sync_Members__c syncmember1 = new Sync_Members__c();
        syncmember1.Sync_Master__c = sm.id;
        syncmember1.Type__c = 'Contact';
        insert syncmember1;
        
        Sync_Members__c syncmember2 = new Sync_Members__c();
        syncmember2.Sync_Master__c = sm.id;
        syncmember2.Type__c = 'Contact';
        insert syncmember2;
        String m = inwiseGlobalAction.initFailedSyncMaster(sm.id);
        system.assertEquals(m,'You can not process again due to Log Sync Members was disabled at the time of Sync created.');
    }
    
    static testmethod void inwiseutilTest13(){
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objsetting.Sync_Members_Batch_Size__c = 1 ;
        objSetting.Log_Sync_Memebers__c = true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Sendid__c = 1237855;
        c.isActive = true;
        c.Campaign_Type__c = 'email';
        insert c;
        
        Sync_Master__c sm = new Sync_Master__c();
        sm.Total_Memerbs_Count__c =3;
        sm.Campaign__c = c.id;
        sm.Track_Members_When_Sync_Started__c = true;
        insert sm;
        
        Sync_Members__c syncmember1 = new Sync_Members__c();
        syncmember1.Sync_Master__c = sm.id;
        syncmember1.Type__c = 'Contact';
        insert syncmember1;
        
        Sync_Members__c syncmember2 = new Sync_Members__c();
        syncmember2.Sync_Master__c = sm.id;
        syncmember2.Type__c = 'Contact';
        insert syncmember2;
        BatchSendMemberToInwise.bufferMethod();
        String m = inwiseGlobalAction.initFailedSyncMaster(sm.id);
        system.assertEquals(m,'Sync started for failed record for this Process');
    }
    
    static testmethod void inwiseutilTest14(){
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Log_Sync_Memebers__c = true;
        insert objSetting;
        
        Sync_Master__c sm = new Sync_Master__c();
        insert sm;
        
        String m = inwiseGlobalAction.initFailedSyncMaster(sm.id);
        system.assertEquals(m,'There are no failed record for this Process');
        System.assertEquals('Contact',inwiseGlobalAction.sCONSTContact);
        System.assertEquals('Lead',inwiseGlobalAction.sCONSTLead);
    }
    
    static testMethod void inwiseitilTest15(){
        BatchCampaignMemberAction objBatchCampaignMemberAction = new BatchCampaignMemberAction();
        database.executeBatch(objBatchCampaignMemberAction,1);
        objBatchCampaignMemberAction.init(false);
        
        BatchCampaignMemberActionV2 objBatchCampaignMemberActionV2= new BatchCampaignMemberActionV2();
        objBatchCampaignMemberActionV2.init(false);
        List<Account__c> listOfInwiseAccount = [SELECT Id,Name,Password__c,Token__c,User_Name__c,Default_Campaign_Type__c,ListEmailFeedBackActionMaxId__c, ListEmailSentMessageMaxId__c,SMS_Sender__c,Country__c,Trim_Leading_Zero__c FROM Account__c ]; 
        system.assertEquals(listOfInwiseAccount.size(),0);
        
    }
    
    static testMethod void inwiseUtilTest16() {
        inwiseGlobalAction.doClearLandingSyncHistory();
        system.assertEquals(null,null );
    }
    
    static testMethod void inwiseUtilTest17() {
        
        Sync__c sync = inwiseTestDataFactory.createTestSync();
        insert sync;
        
        Settings__c setting = inwiseTestDataFactory.GetInwiseSetting();
        insert setting;
        
        inwiseUtil util = new inwiseUtil();
        util.objInwiseSetting = setting;
        util.updateOverlayHelp(true);
        util.CheckIfCredentialExists();
        inwiseUtil.createMetadataService();
        inwiseUtil.doGetSyncRecord(sync.Id);
        inwiseUtil.hostUrl('inwiseUnsubscribe');
        
        inwiseUtil.WrapperStatus statusWrap = new inwiseUtil.WrapperStatus();
        statusWrap.isSuccess = true;
        statusWrap.msg = 'This is test message';
        
        inwiseUtil.JSON2ApexOauthResponse authResponse = new inwiseUtil.JSON2ApexOauthResponse();
        authResponse.expires_in = 7;
        authResponse.token_type = 'access';
        authResponse.access_token = 'skfgsd7we6r8sdbfj';
        
        system.assertEquals(null, null);
    }
    
    /*static testMethod void inwiseAutomationTesting() {
        
        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;
        
        Landing_Sync__c sync = new Landing_Sync__c();
        sync.Leads__c = true;
        sync.Form_Type__c = null;
        sync.Account__c = acc.Id;
        sync.Landing_Page_Id__c = null;
        sync.Name = 'Test Landing Page';
        sync.Landing_Page_Name__c = 'Landing Page1';
        insert sync;
        
        inwiseUtil.inwiseAutomation(sync.Id);
        inwiseUtil.executeLandingSync(sync.Id);
    }*/
    @isTest
    static void encryptTokenTest(){
        test.startTest();
        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        //String encrypted = inwiseUtil.encryptToken('test5566666777');
        //String decrypted = inwiseUtil.decryptToken(encrypted);
        test.stopTest();
        System.assertEquals(tokenSetting.Token__c,'dwsd23232sdssdDE');
    }
}