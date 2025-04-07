/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 19/11/2020
*Purpose :     Send SMS functionality test Coverage of SendSMSAccountController
*Modified:   
================================================================
Modified On      Version     Modified By           		Purpose
================================================================
05/10/2021       1.1.0       NLINEAXIS(K.Goutam)   		Added person account check in test code as Util doen't return field in case of person account enabled & test case failed on packaging org
01/21/2022		 1.1.1		 NLINEAXIS(S. Vaishnav)		Removed inwiseUtil.isPersonAccountEnabled() check

/******************************************************************************************/
@isTest
public with sharing class SendSMSAccountControllerTest {
    
    static testmethod void sendSMSAccountController_Test1() {
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c = true;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
       
        Webhook_Setting__c objInwiseSetting = inwiseTestDataFactory.GetInwiseWebhookSetting();
        insert objInwiseSetting;
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1; 

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Account acc = new Account();
        acc.Name = 'Test Code';
        acc.Phone = '1234567890';
        Insert acc;

        test.startTest();
        PageReference pgRef = Page.SendSMSAccount;
        Test.setCurrentPageReference (pgRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SendSMSAccountController objController = new SendSMSAccountController(sc);
        
        objController.getLandingPagesList();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(pageMessages.size(),1);
        System.assertEquals(pageMessages[0].getDetail(), 'Please provide required credentials to connect');
        
        insert objSetting;
        objController = new SendSMSAccountController(sc);        
        objController.getLandingPagesList();
        
        System.assertEquals(objController.listOfSelectOptionPhoneNumbers.size(), 2);
        objController.doSendSMS();
        objController.selectedNumber = objController.listOfSelectOptionPhoneNumbers[1].getValue();
        System.assertEquals(objController.selectedNumber, acc.Phone);

        objController.doSendSMS();
        objController.messageBody = 'Test Message';
        objController.selectedLandingPage = objController.listOfSelectOptionLandingPages[1].getValue();

        System.assertEquals(objController.selectedLandingPage, 'http://sf2.inwise.net/Page_02-11-2017_1');
        objController.doSendSMS();
        objController.insertLogs();
        test.stopTest();
    }
    
    @isTest static void sendSMSAccountltngController_test() {
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c =true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Webhook_Setting__c objInwiseSetting = inwiseTestDataFactory.GetInwiseWebhookSetting();
        insert objInwiseSetting;
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Account objAcc = new Account(name = 'test inwise account', Phone = '12345678');
        insert objAcc;
        
        test.startTest();
        String accJSON = SendSMSAccountLtngController.getaccountJSONString(String.valueOf(objAcc.Id));
        System.assert(accJSON.contains(objAcc.Id));
        
        List<SendSMSAccountLtngController.SelectOption> landingPgList = SendSMSAccountLtngController.getLandingPagesList();
        System.assertEquals(landingPgList.size(), 2);
        
        List<SendSMSAccountLtngController.SelectOption> accFieldList = SendSMSAccountLtngController.getlistOfSelectOptionFieldsAccount(objAcc.Id);
        List<SendSMSAccountLtngController.SelectOption> phoneNumberList = SendSMSAccountLtngController.getPhoneNumberSO(objAcc.Id);
        System.assertEquals(phoneNumberList.size(), 1);
        System.assertEquals(phoneNumberList[0].value, '12345678');
        
        SendSMSAccountLtngController.getTemplatesList();
        String sms = SendSMSAccountLtngController.SendSMSAndCreateActivity('SMS sent from test class', objAcc.Phone, objAcc.id);
        System.assertEquals(sms, 'SUCCESS');
        test.stopTest();
    }
}