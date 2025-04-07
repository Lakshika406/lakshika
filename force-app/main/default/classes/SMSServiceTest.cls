/******************************************************************************************
*Created By:  NLINEAXIS
*Created On: 07 December 2021
*Purpose :   Test class of SMSServcie

Modification Log
----------------
Date                  Version     Developer                  Comments
------------------------------------------------------------------------------------
07/12/2021            1.1.0       NLINEAXIS(S. Vaishnav)     Created

/******************************************************************************************/
@isTest
private class SMSServiceTest {
    
    static testMethod void testPost(){
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c =true;
        insert objSetting;
        
        Webhook_Setting__c objInwiseSetting = inwiseTestDataFactory.GetInwiseWebhookSetting();
        insert objInwiseSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;   
        
        Account objAcc = new Account(name = 'test inwise account');
        insert objAcc;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  

        Contact con = inwiseTestDataFactory.GetInwiseContact();
        con.FirstName = 'test';
        con.accountId = objAcc.Id;
        con.MobilePhone = '1234567890';
        con.Description = 'this is test message';
        insert con;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/smsservice'; 
        req.requestBody = Blob.valueOf('{"contactid":"' + con.Id + '","smstext":"this is test sms"}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SMSService.doSendSMS();
        Test.stopTest();
        
        String conJSON = inwiseSendSMSLtngController.getcontactJSONString(String.valueOf(con.Id));
        System.assert(conJSON.contains(con.id));
    }
}