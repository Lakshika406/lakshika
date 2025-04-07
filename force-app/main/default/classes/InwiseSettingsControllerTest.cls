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
}