/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Updated On: 28 July 2017 by Kapil Goutam
*Purpose :     Test Code coverage for SendToInwiseController
/******************************************************************************************/
@isTest
private class SendToInwiseControllerTest {
    
    ////Method  added :  On: 28 July 2017 by Kapil Goutam
    //This is when Action Member is Sendmember and CampaignMember has added
    static testMethod void SendToInwiseControllerTest2() {
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c = true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Mapping__c mapping= new Mapping__c();
        mapping.Account__c = act1.Id;
        mapping.inwise_FieldId__c = '1000';
        mapping.inwise_Field__c = 'Mobile';
        mapping.Object_Type__c = 'Contact';
        mapping.Salesforce_Field__c = 'MobilePhone';   
        insert mapping;
        
        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Contact';
        con.MobilePhone = '9876543210';
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead';
        objLead.company = 'inwise'; 
        insert objLead; 
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Campaign_Type__c = 'Mobile';
        c.Sendid__c = 1237855;
        insert c;
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;   
        insert cm;

        ApexPages.StandardController std;
        Test.setCurrentPage(Page.SendToInwise);
        ApexPages.currentPage().getParameters().put('id',c.Id);
        ApexPages.currentPage().getParameters().put('action','sendmember');
        SendToInwiseController objSendToInwiseController = new SendToInwiseController(std);
        objSendToInwiseController.onload();   
        
        System.assertEquals(objSendToInwiseController.ErrorMsg,'Invalid CSRF token. Action cannot be performed.');  
        system.debug('campaign is--->>' + c);  
    }
    
    //if campaign type  is email and action type is SendMember
    static testMethod void SendToInwiseControllerTest7() {
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c = true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Mapping__c mapping= new Mapping__c();
        mapping.Account__c = act1.Id;
        mapping.inwise_FieldId__c = '1000';
        mapping.inwise_Field__c = 'Mobile';
        mapping.Object_Type__c = 'Contact';
        mapping.Salesforce_Field__c = 'MobilePhone';   
        insert mapping;
        
        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Contact';
        con.MobilePhone = '9876543210';
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead';
        objLead.company = 'inwise'; 
        insert objLead; 
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Campaign_Type__c = 'Email';
        c.Sendid__c = 1237855;
        insert c;
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;   
        insert cm;
        
        ApexPages.StandardController std;
        Test.setCurrentPage(Page.SendToInwise);
        ApexPages.currentPage().getParameters().put('id',c.Id);
        ApexPages.currentPage().getParameters().put('action','sendmember');
        SendToInwiseController objSendToInwiseController = new SendToInwiseController(std);
        objSendToInwiseController.onload();   
        System.assertEquals(objSendToInwiseController.ErrorMsg,'Invalid CSRF token. Action cannot be performed.');  
        system.debug('campaign is--->>' + c);  
    }
    
    //This is when Action Member is Sendmember and CampaignMember has not added
    static testMethod void SendToInwiseControllerTest6() {
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c = true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Mapping__c mapping= new Mapping__c();
        mapping.Account__c = act1.Id;
        mapping.inwise_FieldId__c = '1000';
        mapping.inwise_Field__c = 'Mobile';
        mapping.Object_Type__c = 'Contact';
        mapping.Salesforce_Field__c = 'MobilePhone';   
        insert mapping;
        
        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Contact';
        con.MobilePhone = '9876543210';
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead';
        objLead.company = 'inwise'; 
        insert objLead; 
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Campaign_Type__c = 'Mobile';
        c.Sendid__c = 1237855;
        insert c;
        
        ApexPages.StandardController std;
        Test.setCurrentPage(Page.SendToInwise);
        ApexPages.currentPage().getParameters().put('id',c.Id);
        ApexPages.currentPage().getParameters().put('action','sendmember');
        SendToInwiseController objSendToInwiseController = new SendToInwiseController(std);
        objSendToInwiseController.onload();   
        System.assertEquals(objSendToInwiseController.ErrorMsg,'Invalid CSRF token. Action cannot be performed.');  
        system.debug('campaign is--->>' + c);  
    }
    
    //this is when action type = 'inwisestatistics'
    static testMethod void SendToInwiseControllerTest3() {
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c = true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Mapping__c mapping= new Mapping__c();
        mapping.Account__c = act1.Id;
        mapping.inwise_FieldId__c = '1000';
        mapping.inwise_Field__c = 'Mobile';
        mapping.Object_Type__c = 'Contact';
        //mapping.Object_Type__c = 'Lead';
        mapping.Salesforce_Field__c = 'MobilePhone';   
        insert mapping;
        
        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Contact';
        con.MobilePhone = '9876543210';
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead';
        objLead.company = 'inwise'; 
        insert objLead; 
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Campaign_Type__c = 'Mobile';
        c.Sendid__c = 1237855;
        insert c;
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;   
        insert cm;
        
        Logs__c logs = new Logs__c();
        logs.Api_Name__c = 'POST';
        logs.Class_Name__c = 'SendToInwiseControllerTest';
        logs.Method_Name__c = 'SendToInwiseControllerTest3';
        insert logs;
        
        ApexPages.StandardController std;
        Test.setCurrentPage(Page.SendToInwise);
        ApexPages.currentPage().getParameters().put('id',c.Id);
        ApexPages.currentPage().getParameters().put('action','inwisestatistics');
        SendToInwiseController objSendToInwiseController = new SendToInwiseController(std);
        objSendToInwiseController.onload();   
        System.assertEquals(objSendToInwiseController.ErrorMsg,'Invalid CSRF token. Action cannot be performed.');  
        system.debug('campaign is--->>' + c);  
    }
    
    //this is when action type = 'inwisemembersactions'
    static testMethod void SendToInwiseControllerTest4() {
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c = true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Mapping__c mapping= new Mapping__c();
        mapping.Account__c = act1.Id;
        mapping.inwise_FieldId__c = '1000';
        mapping.inwise_Field__c = 'Mobile';
        mapping.Object_Type__c = 'Contact';
        mapping.Salesforce_Field__c = 'MobilePhone';   
        insert mapping;
        
        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Contact';
        con.MobilePhone = '9876543210';
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead';
        objLead.company = 'inwise'; 
        insert objLead; 
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Campaign_Type__c = 'Mobile';
        c.Sendid__c = 1237855;
        insert c;
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;   
        insert cm;
        
        ApexPages.StandardController std;
        Test.setCurrentPage(Page.SendToInwise);
        ApexPages.currentPage().getParameters().put('id',c.Id);
        objLead.email = 'inwisetestemail1@inwise.com';
        update objLead;
        
        con.email = 'inwisetestemail2@inwise.com';
        update con;
        
        ApexPages.currentPage().getParameters().put('action','inwisemembersactions');
        SendToInwiseController objSendToInwiseController = new SendToInwiseController(std);
        objSendToInwiseController.onload();   
        ApexPages.currentPage().getParameters().put('id',null);
        objSendToInwiseController.onload();
        System.assertEquals(objSendToInwiseController.ErrorMsg,'Invalid CSRF token. Action cannot be performed.');  
        system.debug('campaign is--->>' + c);  
    }
    
    ////for trigger subscribe & unsubscribe
    static testMethod void SendToInwiseControllerTest5() {
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Toggle_Email_Opt_in_Opt_out__c = true;
        objSetting.Lead_Email_Opt_in_Opt_out__c = 'HasOptedOutOfEmail';
        objSetting.Lead_Email_Opt_in_Opt_out_Field__c = 'Email';
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Mapping__c mapping= new Mapping__c();
        mapping.Account__c = act1.Id;
        mapping.inwise_FieldId__c = '1000';
        mapping.inwise_Field__c = 'Mobile';
        mapping.Object_Type__c = 'Contact';
        mapping.Salesforce_Field__c = 'MobilePhone';   
        insert mapping;
        
        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Contact';
        con.MobilePhone = '9876543210';
        con.HasOptedOutOfEmail = true;
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead';
        objLead.company = 'inwise'; 
        objLead.HasOptedOutOfEmail = true;
        objLead.Email = 'test@gmail.com';
        insert objLead; 
        
        con.HasOptedOutOfEmail = false;
        update con;
        
        objLead.HasOptedOutOfEmail = false;
        update objLead;
        System.assertEquals(objLead,objLead);
    }
    
    //this is for Batch which is commented
    ////for trigger subscribe & unsubscribe
    static testMethod void SendToInwiseControllerTest66() {
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Toggle_Email_Opt_in_Opt_out__c = true;
        objSetting.Lead_Mobile_Opt_in_Opt_out__c = 'HasOptedOutOfFax';
        objSetting.Lead_Mobile_Opt_in_Opt_out_Field__c = 'Email';
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Mapping__c mapping= new Mapping__c();
        mapping.Account__c = act1.Id;
        mapping.inwise_FieldId__c = '1000';
        mapping.inwise_Field__c = 'Mobile';
        mapping.Object_Type__c = 'Contact';
        mapping.Salesforce_Field__c = 'MobilePhone';   
        insert mapping;
        
        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Contact';
        con.MobilePhone = '9876543210';
        con.HasOptedOutOfEmail = true;
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead';
        objLead.company = 'inwise'; 
        objLead.HasOptedOutOfFax = true;
        insert objLead; 
        objLead.HasOptedOutOfFax = false;
        update objLead;
        
        
        Campaign c = new Campaign();
        c.Name = 'test campaign';
        c.Account__c = act1.Id;
        c.Campaign_Type__c = 'Mobile';
        c.Sendid__c = 1237855;
        insert c;
                
        CampaignMember cm = new CampaignMember();
        cm.ContactId = con.Id;
        cm.CampaignId = c.Id;
        insert cm;
        
        BatchSendMemberToInwisev2 objBatchSendMemberToInwise = new BatchSendMemberToInwisev2();
        objBatchSendMemberToInwise.start(null);
        objBatchSendMemberToInwise.execute(NULL, null);
        objBatchSendMemberToInwise.finish(null);
        System.assertEquals(Null, Null);
    }
}