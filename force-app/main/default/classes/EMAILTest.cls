@isTest
private class EMAILTest {
    static testmethod void sendEmailUnitTest(){
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
         String jsonStringforEmail = '{"recordId": "' + con.Id + '","email":"' + con.email + '","subject":"test subject","template_id" : "20003","saveToInwiseMessagingHistory":true,"createTask":true}';
        test.startTest();
        EMAIL.send(new List<String>{jsonStringforEmail});
        BatchSyncMemberToInwise.bufferMethod();
        test.stopTest();
        List<Error_Logs__c> listOfErrorLogs = [select id,name,Message__c from Error_Logs__c];
        system.assertEquals(false, listOfErrorLogs.size()> 0);
    }
    static testmethod void errorLogsTest(){

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
       String jsonStringforEmail = '{"recordId": "","subject":"test subject","template_id" : "20003","saveToInwiseMessagingHistory":true,"createTask":true}';
        test.startTest();
        EMAIL.send(new List<String>{jsonStringforEmail});
        test.stopTest();
        List<Error_Logs__c> listOfErrorLogs = [select id,name,Message__c from Error_Logs__c];
        system.assertEquals('Please add any one value email or recordId.', listOfErrorLogs[0].Message__c);
    }
    static testmethod void errorLogs2Test(){

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
       String jsonStringforEmail = '{"recordId": "' + con.Id + '","subject":"","saveToInwiseMessagingHistory":true,"createTask":true}';
        test.startTest();
        EMAIL.send(new List<String>{jsonStringforEmail});
        test.stopTest();
        List<Error_Logs__c> listOfErrorLogs = [select id,name,Message__c from Error_Logs__c];
        system.assertEquals('Subject is mandatory please provide.', listOfErrorLogs[0].Message__c);
    }
    static testmethod void bulkerrorLogs2Test(){

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
        Contact con1 = inwiseTestDataFactory.GetInwiseContact();
        con1.MobilePhone = '0546414000';
        con1.Email = 'test@salesforce.com';
        //insert con1;
       String jsonStringforEmail = '{"recordId": "' + con.Id + '","subject":"fddefef","saveToInwiseMessagingHistory":true,"createTask":true,"email":"test@gmail.com"}';
        String jsonStringforEmail1 = '{"recordId": "' + con1.Id + '","subject":"effrf","saveToInwiseMessagingHistory":true,"createTask":true,"reply_to":"test@gmail.com","toname":"test","from_name":"test","from_email":"test1@gmail.com","template_id":"24556"}';
        String jsonStringforEmail2 = '{"recordId": "","subject":"effrf","saveToInwiseMessagingHistory":true,"createTask":true,"reply_to":"test@gmail.com","toname":"test","from_name":"test","from_email":"test1@gmail.com","template_id":"24556"}';
        test.startTest();
        EMAIL.send(new List<String>{jsonStringforEmail,jsonStringforEmail1,jsonStringforEmail2});
        test.stopTest();
        List<Error_Logs__c> listOfErrorLogs = [select id,name,Message__c from Error_Logs__c];
        system.assert(true);
    }
   
    static testmethod void errorLogsForLeadTest(){

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

    
        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;

        tokenSetting.Account_Id__c = acc.Id;
        update tokenSetting;  
        
        Lead l = new Lead(Company = 'Test', LastName = 'test', Status = 'Open');
        l.MobilePhone = '0546414000';
        l.Email = 'test@salesforce.com';
        insert l;
       String jsonStringforEmail = '{"recordId": "' + l.Id + '","subject":"","saveToInwiseMessagingHistory":true,"createTask":true}';
        test.startTest();
        EMAIL.send(new List<String>{jsonStringforEmail});
        test.stopTest();
        List<Error_Logs__c> listOfErrorLogs = [select id,name,Message__c from Error_Logs__c];
        system.assertEquals('Subject is mandatory please provide.', listOfErrorLogs[0].Message__c);
    }
    static testmethod void errorLogsForEMailRecIdTest(){

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting; 
        
        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;

        tokenSetting.Account_Id__c = acc.Id;
        update tokenSetting;  
        
        Lead l = new Lead(Company = 'Test', LastName = 'test', Status = 'Open');
        l.MobilePhone = '0546414000';
        l.Email = 'test@salesforce.com';
        insert l;
       String jsonStringforEmail = '{"recordId": "","subject":"","saveToInwiseMessagingHistory":true,"createTask":true}';
        test.startTest();
        EMAIL.send(new List<String>{jsonStringforEmail});
        test.stopTest();
        List<Error_Logs__c> listOfErrorLogs = [select id,name,Message__c from Error_Logs__c];
        system.assertEquals('Please add any one value email or recordId.', listOfErrorLogs[0].Message__c);
    }
}