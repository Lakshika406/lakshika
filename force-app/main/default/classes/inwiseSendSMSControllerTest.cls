/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 20/06/2017
*Purpose :     Send SMS functionality test Coverage
*Modified:   
================================================================
Modified On      Version      Modified By        Purpose  
================================================================
05/09/2022       1.0.0        S. Vaishnav        Modified:- Code coverage

/******************************************************************************************/
@isTest
private class inwiseSendSMSControllerTest {
    
    static testmethod void inwiseSendSMSController_test1() {
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c = true;
        
        Webhook_Setting__c objInwiseSetting = inwiseTestDataFactory.GetInwiseWebhookSetting();
        insert objInwiseSetting;

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
        con.Phone = '12345678';
        con.FirstName = 'test';
        con.LastName = 'Contact';
        con.accountid = objAcc.Id;
        insert con;
        
        Test.startTest();
        PageReference pgRef = Page.inwiseSendSMS;
        Test.setCurrentPageReference(pgRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        inwiseSendSMSController objController = new inwiseSendSMSController(sc);
        objController.getLandingPagesList();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(pageMessages.size(), 1);
        System.assertEquals(pageMessages[0].getDetail(), 'Please provide required credentials to connect');
        insert objSetting;
        
        objController = new inwiseSendSMSController(sc);        
        objController.getLandingPagesList();
        System.assertEquals(objController.listOfSelectOptionPhoneNumbers.size(), 2);
        
        objController.selectedNumber = objController.listOfSelectOptionPhoneNumbers[1].getValue();
        System.assertEquals(objController.selectedNumber, con.Phone);
        
        objController.selectedContactField = objController.listOfSelectOptionFields_Contact[5].getValue(); 
        objController.selectedLandingPage = objController.listOfSelectOptionLandingPages[1].getValue();   
        System.assertEquals(objController.selectedLandingPage,'http://sf2.inwise.net/Page_02-11-2017_1');
        
        objController.messageBody = 'test message';
        objController.doSendSMS();
        objController.messageBody = null;
        objController.doSendSMS();
        objController.selectedNumber = null;
        objController.doSendSMS();
        
        String resBody = '[   {     "mobile_number": "91-1-234567890",     "status": "sent",     "reject_reason": null,     "transaction_id": "db7459f4896b458eac2fbdc68b4d9b6a",     "code": null,     "name": null   } ]';
        HttpResponse res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
        
        if(res != NULL){
            if(res.getStatusCode() == 200){ 
                String jsonString = res.getBody(); 
                List<JsonToApexSendSMS.SendSMS> listOfSendSMS = JsonToApexSendSMS.parse(jsonString);    
                System.assertEquals(listOfSendSMS[0].code, null);
                System.assertEquals(listOfSendSMS[0].mobile_number, '91-1-234567890');
                System.assertEquals(listOfSendSMS[0].name, null);
                System.assertEquals(listOfSendSMS[0].reject_reason, null);
                System.assertEquals(listOfSendSMS[0].status, 'sent');
                System.assertEquals(listOfSendSMS[0].transaction_id,'db7459f4896b458eac2fbdc68b4d9b6a');
            }
        }
        Test.stopTest();
    }
    
    @isTest static void inwiseSendSMSLtngController_test() {
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c = true;
        insert objSetting;
        
        Webhook_Setting__c objInwiseSetting = inwiseTestDataFactory.GetInwiseWebhookSetting();
        insert objInwiseSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
         insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        act1.Country__c = 'Australia';
        insert act1;   

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Account objAcc = new Account(name = 'test inwise account');
        insert objAcc;
        
        Contact con = new Contact();
        con.Phone = '12345678';
        con.FirstName = 'test';
        con.LastName = 'Contact';
        con.accountid = objAcc.id;
        insert con;
        
        Test.startTest();
        String conJSON = inwiseSendSMSLtngController.getcontactJSONString(String.valueOf(con.Id));
        System.assert(conJSON.contains(con.Id));
        
        List<inwiseSendSMSLtngController.SelectOption> landingPgList = inwiseSendSMSLtngController.getLandingPagesList();
        System.assertEquals(landingPgList.size(), 2);
        
        List<inwiseSendSMSLtngController.SelectOption> conFieldList = inwiseSendSMSLtngController.getlistOfSelectOptionFieldsContact(con.Id);
        List<inwiseSendSMSLtngController.SelectOption> phoneNumberList = inwiseSendSMSLtngController.getPhoneNumberSO(con.Id);
        System.assertEquals(phoneNumberList.size(), 1);
        System.assertEquals(phoneNumberList[0].value, '12345678');
        
        List<inwiseSendSMSLtngController.SelectOption> templateList = inwiseSendSMSLtngController.getTemplatesList();
        
        String sms = inwiseSendSMSLtngController.SendSMSAndCreateActivity('SMS sent from test class', con.Phone, con.Id);
        System.assertEquals(sms, 'SUCCESS');
        
        sms = inwiseSendSMSLtngController.SendSMSAndCreateActivity('SMS sent from test class', con.Phone, con.Id, true, true, '01463512', '');
        System.assertEquals(sms, 'SUCCESS');
        
        //Test coverage for inwiseHttpUtil class
        inwiseHttpUtil.getReverseFormattedPhone('01463512', new inwiseUtil(null));
        inwiseHttpUtil.getHttpLogRecord(new HttpRequest(), new HttpResponse(), 'testAPI', 'inwiseHttpUtil', 'getHttpLogRecord');
        inwiseHttpUtil.getJsonToApexPushExernalAppError(inwiseTestDataFactory.getDumpHttpResponse('test response', 'application/json'));
        inwiseHttpUtil.getErrorLogRecord('This is test error message', 'inwiseHttpUtil' , 'getErrorLogRecord');
        inwiseHttpUtil.WrapperStatisticsResponse statisticResponseWrapper = new inwiseHttpUtil.WrapperStatisticsResponse();
        Test.stopTest();    
    }
}