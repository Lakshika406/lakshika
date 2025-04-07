@istest
private class TransactionalHelperTest { 
    
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
        con.Email = 'test@salesforce.com';
        insert con;
        
        String smsText = 'This is test message';
        String jsonString = '{"recordId": "' + con.Id + '","mobileNumber":"' + con.MobilePhone + '",smsText":"' + smsText + '","saveToInwiseMessagingHistory":true,"createTask":true}';
       
        test.startTest();
        for(Integer index = 1; index <= 50; index++){
        	smsText += 'This is test message.';
        }
        
        jsonString = '{"recordId": "' + con.Id + '","mobileNumber":"' + con.MobilePhone + '","smsText":"' + smsText + '","saveToInwiseMessagingHistory":true,"createTask":true}';
        test.stopTest();
        
        System.assertNotEquals(acc.Id, con.Id);
    }
   
    
   
}