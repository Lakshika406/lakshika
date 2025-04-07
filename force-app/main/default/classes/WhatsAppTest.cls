@isTest 
public class WhatsAppTest { 
      @testSetup static void setup() {

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;

        tokenSetting.Account_Id__c = acc.Id;
        update tokenSetting;  
        
        Contact con = inwiseTestDataFactory.GetInwiseContact();
        //con.MobilePhone = '050-2323494';
        con.Email = 'test@salesforce.com';
        insert con;
              
    }
	static testmethod void sendWhatsAppUnitTest(){
        Account__c acc = [Select Id From Account__c LIMIT 1];        
        Contact con = [Select Id ,Email,MobilePhone From Contact LIMIT 1];
        
        String jsonString = '{"recordId": "' +con.Id+'","content": "Hello Support ","template_id": "20003","saveToInwiseMessagingHistory":true,"createTask":true ,"tags":"","media_url": "","async": true,"template_fields_mapping":"  "}';
        test.startTest();
        WhatsApp.send(new List<String>{jsonString});
        
        test.stopTest();
        List<Error_Logs__c> listOfErrorLogs = [select id,name from Error_Logs__c];
        system.assertEquals(true, listOfErrorLogs.size()> 0);
        
       
    }
    static testmethod void sendWithoutNumberTest(){
        Account__c acc = [Select Id From Account__c LIMIT 1];        
        Contact con = [Select Id ,Email,MobilePhone From Contact LIMIT 1];
        
        String smsText = 'This is test message';
        //String jsonString = '{"recordId": "' +con.Id+'","content": "Hello Support ","template_id": "20003",saveToInwiseMessagingHistory":true,"createTask":true ,"tags":"","media_url": "","async": true,"template_fields_mapping":"  "}';
        String jsonString = '{' +
            '"recordId": "' + con.Id + '",' +
            '"content": "",' +
            '"template_id": "23663",' +
            '"mobileNumber": "",' +
            '"saveToInwiseMessagingHistory": true,' +
            '"createTask": true,' +
            '"tags": "[SF1,SF3]",' +
            '"inwiseAccount": "",' +
            '"media_url": "",' +
            '"async": true,' +
            '"template_fields_mapping": [' +
                '{"key": 1, "value": "#field1#"},' +
                '{"key": 2, "value": "#field2#"}' +
            ']' +
        '}';
        test.startTest();
        WhatsApp.send(new List<String>{jsonString});
        
       
        test.stopTest();
        List<Error_Logs__c> listOfErrorLogs = [select id,name from Error_Logs__c];
        system.assertEquals(true, listOfErrorLogs.size()> 0);
        
       
    }
     static testmethod void sendWhatsAppForAccTest(){

        //Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        //insert tokenSetting;  

        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;

        //tokenSetting.Account_Id__c = acc.Id;
        //update tokenSetting;  

         String smsText = 'This is test message';
        for(Integer index = 1; index <= 50; index++){
            smsText += 'This is test message.';
        }
        Account acnt = new Account (Name ='test acccount');
        acnt.Phone = '0546414000';
        insert acnt;
        //String jsonString = '{"recordId": "' +acnt.Id+'","content": "Hello Support ","template_id": "20003","saveToInwiseMessagingHistory":true,"createTask":true ,"tags":"","media_url": "","async": true,"template_fields_mapping":"  "}';
    
        String jsonString = '{' +
            '"recordId": "' + acnt.Id + '",' +
            '"content": "",' +
            '"template_id": "23663",' +
            '"mobileNumber": "' + acnt.Phone + '",' +
            '"saveToInwiseMessagingHistory": true,' +
            '"createTask": true,' +
            '"tags": "[SF1,SF3]",' +
            '"inwiseAccount": "",' +
            '"media_url": "",' +
            '"async": true,' +
            '"template_fields_mapping": [' +
                '{"key": 1, "value": "#field1#"},' +
                '{"key": 2, "value": "#field2#"}' +
            ']' +
        '}';
        test.startTest();
        WhatsApp.send(new List<String>{jsonString});
        test.stopTest();
         
        List<Error_Logs__c> listOfErrorLogs = [select id,name from Error_Logs__c];
        system.assertEquals(false, listOfErrorLogs.size()> 0);
    }
     static testmethod void sendWhatsAppLeadTest(){

        //Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        //insert tokenSetting;  

        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;

        //tokenSetting.Account_Id__c = acc.Id;
        //update tokenSetting;  

         String smsText = 'This is test message';
        for(Integer index = 1; index <= 50; index++){
            smsText += 'This is test message.';
        }
        Lead l = new Lead(Company = 'Test', LastName = 'test', Status = 'Open');
        l.MobilePhone = '0546414000';
        l.Email = 'test@salesforce.com';
        insert l;
        //String jsonString = '{"recordId": "' +l.Id+'","content": "Hello Support ","template_id": "20003","saveToInwiseMessagingHistory":true,"createTask":true ,"tags":"","media_url": "","async": true,"template_fields_mapping":"  "}';
        String jsonString = '{' +
            '"recordId": "' + l.Id + '",' +
            '"content": "",' +
            '"template_id": "23663",' +
            '"mobileNumber": "' + l.MobilePhone + '",' +
            '"saveToInwiseMessagingHistory": true,' +
            '"createTask": true,' +
            '"tags": "[SF1,SF3]",' +
            '"inwiseAccount": "",' +
            '"media_url": "",' +
            '"async": true,' +
            '"template_fields_mapping": [' +
                '{"key": 1, "value": "#field1#"},' +
                '{"key": 2, "value": "#field2#"}' +
            ']' +
        '}';
        test.startTest();
        WhatsApp.send(new List<String>{jsonString});
        test.stopTest();
         
        List<Error_Logs__c> listOfErrorLogs = [select id,name from Error_Logs__c];
        system.assertEquals(false, listOfErrorLogs.size()> 0);
    }
    static testmethod void sendWhatsAppbulkTest(){

        //Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        //insert tokenSetting;  

        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;

        //tokenSetting.Account_Id__c = acc.Id;
        //update tokenSetting;  

         String smsText = 'This is test message';
        for(Integer index = 1; index <= 50; index++){
            smsText += 'This is test message.';
        }
        Lead l = new Lead(Company = 'Test', LastName = 'test', Status = 'Open');
        l.MobilePhone = '0546414000';
        l.Email = 'test@salesforce.com';
        insert l;
        Lead l1 = new Lead(Company = 'Test1', LastName = 'test1', Status = 'Open');
        l1.MobilePhone = '0546414000';
        l1.Email = 'test@salesforce.com';
        //insert l1;
        String jsonString = '{"recordId": "' +l.Id+'","content": "Hello Support ","template_id": "20003","saveToInwiseMessagingHistory":true,"createTask":true ,"tags":"","media_url": "","async": true,"template_fields_mapping":"  "}';
        String jsonString1 = '{"recordId": "' +l1.Id+'","content": "Hello Support ","template_id": "20003","saveToInwiseMessagingHistory":true,"createTask":true ,"tags":"","media_url": "","async": true,"template_fields_mapping":"  "}';
        test.startTest();
        WhatsApp.send(new List<String>{jsonString,jsonString1});
        test.stopTest();
         
        List<Error_Logs__c> listOfErrorLogs = [select id,name from Error_Logs__c];
        system.assertEquals(false, listOfErrorLogs.size()> 0);
    }
}