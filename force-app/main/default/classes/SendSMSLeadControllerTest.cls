/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 23/02/2018
*Purpose :     Send SMS Lead functionality test Coverage
*Modified:   
================================================================
Modified On      Version      Modified By        Purpose  
================================================================
05/09/2022       1.0.0        S. Vaishnav        Modified: Code coverage improved

/******************************************************************************************/
@isTest
private class SendSMSLeadControllerTest {
    static testmethod void SendSMSLeadControllerTest1() {
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c = true;
        //  insert objSetting;
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
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Company = 'inwise';
        l.Status =  'Open - Not Contacted';
        insert l;
        
        
        
        test.startTest();
        PageReference pgRef = Page.SendSMSLead;
        Test.setCurrentPageReference (pgRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        SendSMSLeadController objController = new SendSMSLeadController(sc);
        objController.getLandingPagesList();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(pageMessages.size(),1);
        System.assertEquals(pageMessages[0].getDetail(),'Please provide required credentials to connect');
        insert objSetting;
        objController = new SendSMSLeadController(sc);        
        objController.getLandingPagesList();
        System.assertEquals(objController.listOfSelectOptionPhoneNumbers.size(),1);
        objController.selectedNumber = objController.listOfSelectOptionPhoneNumbers[0].getValue();
        List<SelectOption> listofselectoptionNumber =  objController.listOfSelectOptionPhoneNumbers;
        System.debug('listofselectoptionNumber-->>' +listofselectoptionNumber);
        System.assertEquals(objController.selectedNumber,listofselectoptionNumber.get(0).getValue());
        objController.selectedLeadField = objController.listOfSelectOptionFields_Lead[0].getValue(); 
        List<SelectOption> listofselectoption =  objController.listOfSelectOptionFields_Lead;
        System.debug('listpfselectoptions-->>' +listofselectoption);
        System.assertEquals(objController.selectedLeadField,listofselectoption.get(0).getValue());
        objController.selectedLandingPage = objController.listOfSelectOptionLandingPages[1].getValue();   
        //System.assertEquals(objController.selectedLandingPage,'http://sf2.inwise.net/Page_02-11-2017_1');
         objController.messageBody='test body';   
        objController.doSendSMS();
        objController.messageBody=null; 
        
        objController.doSendSMS();
        objController.selectedNumber=null;
        objController.doSendSMS();
        
        String resBody = '[   {     "mobile_number": "91-1-234567890",     "status": "sent",     "reject_reason": null,     "transaction_id": "db7459f4896b458eac2fbdc68b4d9b6a",     "code": null,     "name": null   } ]';
        HttpResponse res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
        if(res != NULL){
            if(res.getStatusCode() == 200){ 
                String jsonString = res.getBody(); 
                List<JsonToApexSendSMS.SendSMS> listOfSendSMS = JsonToApexSendSMS.parse(jsonString);  
                System.assertEquals(listOfSendSMS[0].code,null);
                System.assertEquals(listOfSendSMS[0].mobile_number,'91-1-234567890');
                System.assertEquals(listOfSendSMS[0].name,null);
                System.assertEquals(listOfSendSMS[0].reject_reason,null);
                System.assertEquals(listOfSendSMS[0].status,'sent');
                System.assertEquals(listOfSendSMS[0].transaction_id,'db7459f4896b458eac2fbdc68b4d9b6a');
            }
        }
        test.stopTest();
    }
    
    static testmethod void SendSMSLeadLtngController_Test(){
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

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Account objAcc = new Account(name = 'test inwise account');
        insert objAcc;
        
        Lead l = new Lead();
        l.LastName = 'test lead';
        l.Status = 'Open - Not Contacted';
        l.Company = 'inwise';
        l.Phone = '55946164';
        insert l;
        
        test.startTest();
        String leadJSON = SendSMSLeadLtngController.getLeadJSONString(String.valueOf(l.Id));
        System.assert(leadJSON.contains(l.id));
        List<SendSMSLeadLtngController.SelectOption> landingPgList = SendSMSLeadLtngController.getLandingPagesList();
        System.assertEquals(landingPgList.size(),2);
        List<SendSMSLeadLtngController.SelectOption> leadFieldList = SendSMSLeadLtngController.getlistOfSelectOptionFieldsLead(l.Id);
        //System.debug('conFieldList::-->>>' + conFieldList);
        //System.assertEquals(conFieldList.size(),9); Commented this assert because failing on package org because of IsPersonAccount field
        List<SendSMSLeadLtngController.SelectOption> phoneNumberList = SendSMSLeadLtngController.getPhoneNumberSOLead(l.Id);
        System.assertEquals(phoneNumberList.size(),1);
        System.assertEquals(phoneNumberList[0].value,'55946164');
        String sms = SendSMSLeadLtngController.SendSMSAndCreateActivity('SMS sent from test class', l.Phone, l.id);
        System.assertEquals(sms,'SUCCESS');
        test.stopTest(); 
    }
}