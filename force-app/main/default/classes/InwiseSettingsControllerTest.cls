/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :  Test class for inwiseSettingController
* * -----------------------------------------------------
* Modified On       Modified By     Purpose
* 05/29/2019        Kapil Goutam    code coverage
/******************************************************************************************/

@isTest
public class InwiseSettingsControllerTest {
    
    @isTest 
    static void settingsTest() {

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Settings__c s = new Settings__c();
        s.name = 'default';
        s.Landing_Sync_Scheduled__c = true;
        insert s;
        
        Error_Logs__c objErrorLog = new Error_Logs__c();
        objErrorLog.Message__c = 'POST_Test';
        objErrorLog.Run_On__c = datetime.now();
        objErrorLog.Class_Name__c = 'TestClass';
        objErrorLog.Method_Name__c = 'TestMethod';
        objErrorLog.Run_By__c = UserInfo.getUserId();
        insert objErrorLog; 
        
        Landing_Sync__c landingSync = new Landing_Sync__c();
        landingSync.Name = 'hello test';
        landingSync.Record_Index__c = 23;
        landingSync.Last_JobId__c = 'hhw';
        landingSync.Landing_Page_Id__c = 22;
        landingSync.Last_JobName__c = 'test 2';
        landingSync.Landing_Page_Name__c = 'test landing';
        insert landingSync;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.inwiseSettings);
        inwiseSettingsController controller = new inwiseSettingsController(new ApexPages.StandardController(act1));
        controller.doReturnCustomSettingUrl();
        Pagereference pagref1 = controller.redirectToListView('Logs__c');
        Pagereference pageref2 = controller.doReturnLogsUrl();
        System.assertEquals(pagref1.geturl(), pageref2.geturl());
        
        Pagereference pagref11 = controller.redirectToListView('Sync_Master__c');
        Pagereference pageref3 = controller.doReturnSyncMasterUrl();
        System.assertEquals(pagref11.geturl(), pageref3.geturl());
        
        System.debug(controller.currentPackageVersion);
        System.debug(controller.turnOnOffTrackLogBtnLabel);
        System.debug(controller.turnOnOffErrorLogBtnLabel);
        System.debug(controller.turnOnOffLandingSyncBtnLabel);
        System.debug(controller.turnOnOffCampaignSyncBtnLabel);
        System.debug(controller.turnOnOffTrackActivityBtnLabel);
        
        Pagereference pagref4 = controller.redirectToListView('Landing_Sync_History__c');
        Pagereference pageref5 = controller.doReturnLandingSyncHistoryUrl();
        System.assertEquals(pagref4.geturl(), pageref5.geturl());
        
        Pagereference pagref6 = controller.redirectToListView('Incoming_Webhooks__c');
        Pagereference pageref7 = controller.doReturnIncomingWebhooksUrl();
        System.assertEquals(pagref6.geturl(), pageref7.geturl());
        
        controller.doClearLogs();
        controller.doClearIncomingWebhooks();
        controller.doSendLogtoinwiseSupport(); 
        controller.doSendErrorLogtoinwiseSupport();
        controller.turnOnOffCampaignSync();
        controller.objInwiseUtil = new InwiseUtil(null);
        controller.turnOnOffCampaignSync();
        controller.doInboundSMSConfiguration();
        controller.toggleSettingLandingSync();
        controller.turnOnOffLandingSync();
        controller.turnOnOffLandingSync();
        controller.objinwiseLtngConstants.isLightning = true;
        controller.doReturnLogsUrl();
        controller.doCheckAndCreateRemoteSite();
        controller.doClearErrorLogs();
        controller.doReturnErrorLogsUrl();
        controller.doClearLandingSync();
        controller.turnOnOffTrackLog(); 
        controller.turnOnOffTrackError();
        controller.turnOnOffTrackActivities();

       
        Test.stopTest();
    }

    @isTest 
    static void settingsTestForGlobalAction() {

        Settings__c s = new Settings__c();
        s.name = 'default';
        s.Landing_Sync_Scheduled__c = true;
        s.Track_Logs__c = true;
        s.Activate_Advanced_Features__c = false;
        insert s;

        Logs__c logs = new Logs__c();
        logs.Api_Name__c = 'POST';
        logs.Class_Name__c = 'inwiseUtiltest';
        logs.Method_Name__c = 'inwiseUtilTest10';
        insert logs;   


        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        
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

        // Validate sCONSTContact
        String expectedContactValue = inwiseConstants.SOBJECT_CONTACT;

        // Validate sCONSTLead
        String expectedLeadValue = inwiseConstants.SOBJECT_LEAD;

         // Create an instance of the class
         inwiseGlobalAction actionInstance = new inwiseGlobalAction();
        
         // Set and retrieve the resultMessage property
         actionInstance.resultMessage = 'Test message';


             
        // Test the default constructor
        inwiseGlobalAction actionWithDefaultConstructor = new inwiseGlobalAction();

        Test.startTest();

        inwiseGlobalAction.remoteClearLogs(); 
        inwiseGlobalAction.doClearAll(true);
        inwiseGlobalAction.remoteClearSyncMaster(); 

        inwiseGlobalAction.doClearSyncMaster();
        inwiseGlobalAction.doClearLandingSyncHistory();
        inwiseGlobalAction.doClearPreviousLogs();
        inwiseGlobalAction.remoteTurnOnOffTrackLog(); 
        inwiseGlobalAction.checkAndCreateRemoteSite();
        inwiseGlobalAction.remoteSendLogsToSupport();
        inwiseGlobalAction.initFailedSyncMaster(sm.Id);
        inwiseGlobalAction.remoteinitFailedSyncMaster(sm.Id); 

        inwiseGlobalAction.doSendLogsToSupport();  
        inwiseGlobalAction.getSelectedPicklistOptions('Name', 'Contact');

        Test.stopTest();
    }
}