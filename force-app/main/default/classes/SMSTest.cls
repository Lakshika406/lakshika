@istest
private class SMSTest {
    
    static testmethod void sendSMSUnitTest(){
        
        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;

        tokenSetting.Account_Id__c = acc.Id;
        update tokenSetting;  
        
        Contact con = inwiseTestDataFactory.GetInwiseContact();
        con.MobilePhone = '0546414000';
        insert con;
        
        String smsText = 'This is test message';
        String jsonString = '{"recordId": "' + con.Id + '","mobileNumber":"' + con.MobilePhone + '","smsText":"' + smsText + '","saveToInwiseMessagingHistory":true,"createTask":true}';
        
        test.startTest();
        SMS.send(new List<String>{jsonString});
        
        for(Integer index = 1; index <= 50; index++){
            smsText += 'This is test message.';
        }
        
        jsonString = '{"recordId": "' + con.Id + '","mobileNumber":"' + con.MobilePhone + '","smsText":"' + smsText + '","saveToInwiseMessagingHistory":true,"createTask":true}';
        SMS.send(new List<String>{jsonString});
        test.stopTest();
        
        System.assertNotEquals(acc.Id, con.Id);
    }
    static testmethod void bulksendSMSUnitTest(){

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;
        
        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;

        tokenSetting.Account_Id__c = acc.Id;
        update tokenSetting;
        
        Contact con = inwiseTestDataFactory.GetInwiseContact();
        con.MobilePhone = '0546414000';
        insert con;
        Contact con1 = inwiseTestDataFactory.GetInwiseContact();
        con1.MobilePhone = '0546414000';
        insert con1;
        
        String smsText = 'This is test message';
        String jsonString = '{"recordId": "' + con.Id + '","mobileNumber":"' + con.MobilePhone + '","smsText":"' + smsText + '","saveToInwiseMessagingHistory":true,"createTask":true}';
        String jsonString1 = '{"recordId": "' + con1.Id + '","mobileNumber":"' + con.MobilePhone + '","smsText":"' + smsText + '","saveToInwiseMessagingHistory":true,"createTask":true}';
        
        test.startTest();
        SMS.send(new List<String>{jsonString,jsonString1});
        
        for(Integer index = 1; index <= 50; index++){
            smsText += 'This is test message.';
        }
        
        jsonString = '{"recordId": "' + con.Id + '","mobileNumber":"' + con.MobilePhone + '","smsText":"' + smsText + '","saveToInwiseMessagingHistory":true,"createTask":true}';
        SMS.send(new List<String>{jsonString,jsonString1});
        test.stopTest();
        
        System.assertNotEquals(acc.Id, con.Id);
    }
    
    static testmethod void sendSMSForRecordId(){

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;
        
        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;

        tokenSetting.Account_Id__c = acc.Id;
        update tokenSetting;

         String smsText = 'This is test message';
        for(Integer index = 1; index <= 50; index++){
            smsText += 'This is test message.';
        }
        Contact con = inwiseTestDataFactory.GetInwiseContact();
        con.MobilePhone = '0546414000';
        insert con;
        String jsonString = '{"recordId": "' + con.Id + '","smsText":"' + smsText + '","saveToInwiseMessagingHistory":true,"createTask":true}';
        test.startTest();
        SMS.send(new List<String>{jsonString});
        test.stopTest();
        List<Error_Logs__c> listOfErrorLogs = [select id,name,Message__c from Error_Logs__c];
        system.assertEquals(false, listOfErrorLogs.size()> 0);
    }
     static testmethod void sendSMSLead(){

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;

        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;

        tokenSetting.Account_Id__c = acc.Id;
        update tokenSetting;

         String smsText = 'This is test message';
        for(Integer index = 1; index <= 50; index++){
            smsText += 'This is test message.';
        }
        Lead l = new Lead(Company = 'Test', LastName = 'test', Status = 'Open');
        l.MobilePhone = '0546414000';
        l.Email = 'test@salesforce.com';
        insert l;
        String jsonString = '{"recordId": "' + l.Id + '","smsText":"' + smsText + '","saveToInwiseMessagingHistory":true,"createTask":true}';
        test.startTest();
        SMS.send(new List<String>{jsonString});
        test.stopTest();
        List<Error_Logs__c> listOfErrorLogs = [select id,name,Message__c from Error_Logs__c];
        system.assertEquals(false, listOfErrorLogs.size()> 0);
    }
}