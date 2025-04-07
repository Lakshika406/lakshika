/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 29/01/2020
*Purpose :     Conversation View test Coverage
*Modified:   
================================================================
Modified On      Modified By        Purpose  
================================================================


/******************************************************************************************/
@isTest
public class ConversationViewControllerTest {
    
    static testmethod void ConversationViewControllerTest1() {
        
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
        l.MobilePhone='0546414000';
        insert l;
        
        Messaging_History__c msg = new Messaging_History__c();
        msg.Channel_Type__c ='SMS';
        msg.Lead__c = l.Id;
        msg.Direction__c = 'Incoming';
        msg.Description__c = 'Test Description';
        msg.Read__c = true;
        msg.Message__c ='test message';
        insert msg;
        
        Messaging_History__c msg1 = new Messaging_History__c();
        msg1.Channel_Type__c ='SMS';
        msg1.Lead__c = l.Id;
        msg1.Direction__c = 'Incoming';
        msg1.Description__c = 'Test Description';
        msg1.Read__c = false;
        msg1.Message__c ='test message';
        insert msg1;
        
        Test.startTest();
        PageReference pgRef = Page.ConversationViewPage;
        pgRef.getParameters().put('id', l.Id);
        pgRef.getParameters().put('theTextInput', 'test message');
        
        Test.setCurrentPageReference (pgRef);
        ConversationViewController controller = new ConversationViewController();
        controller.recentSelected = true;
        controller.selectedRecord();
        controller.myClosePopup();
        controller.doSendSMS();
        
        List<Messaging_History__c> msgobj = [Select Id,Read__c From Messaging_History__c Where Read__c = true];
        system.assertEquals(2, msgobj.size());
        Test.stopTest();
    }
    
    static testmethod void ConversationViewControllerTest2() {
        
        Webhook_Setting__c objInwiseSetting = new Webhook_Setting__c();
        objInwiseSetting.Name = 'default';
        objInwiseSetting.Lead_Field__c ='MobilePhone';
        objInwiseSetting.Contact_Field__c ='AssistantPhone';
        objInwiseSetting.Save_To_Activity_History__c = true;
        objInwiseSetting.Save_To_Messaging_History__c = true;
        insert objInwiseSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;   

        
        
        Account objAcc = new Account(name = 'test inwise account');
        insert objAcc;

        tokenSetting.Account_Id__c = objAcc.Id;
        update tokenSetting;  
        
        Contact con = new Contact();
        con.LastName = 'Test Lead';
        con.AssistantPhone ='0546414000';
        insert con;
        
        Messaging_History__c msg = new Messaging_History__c();
        msg.Read__c = true;
        msg.Contact__c = con.Id;
        msg.Channel_Type__c = 'SMS';
        msg.Direction__c = 'Incoming';
        msg.Message__c = 'test message';
        msg.Description__c = 'Test Description';
        insert msg;
        
        Messaging_History__c msg1 = new Messaging_History__c();
        msg1.Read__c = false;
        msg1.Contact__c = con.Id;
        msg1.Channel_Type__c = 'SMS';
        msg1.Direction__c = 'Incoming';
        msg1.Message__c ='test message';
        msg1.Description__c = 'Test Description';
        insert msg1;
        
        Test.startTest();
        PageReference pgRef = Page.ConversationViewPage;
        pgRef.getParameters().put('id', con.Id);
        pgRef.getParameters().put('theTextInput', 'test message');
        
        Test.setCurrentPageReference(pgRef);
        ConversationViewController controller = new ConversationViewController();
        controller.recentSelected = true;
        controller.selectedRecord();
        controller.myClosePopup();
        controller.doSendSMS();
        
        List<Messaging_History__c> msgobj = [Select Id,Read__c From Messaging_History__c Where Read__c = true];
        system.assertEquals(2, msgobj.size());
        Test.stopTest();
    }
}