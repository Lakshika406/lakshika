/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 05/15/2018
*Purpose :     OptInOutConfigurationController class test 
******************************************************************************************/
@isTest
private class OptInOutConfigurationControllerTest {
    static testmethod void optInOutConfigurationControllerMethod(){
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        Test.startTest();
            Test.setCurrentPage(Page.OptInOutConfiguration);
            OptInOutConfigurationController objOptInOutConfigurationController = new OptInOutConfigurationController();
            objOptInOutConfigurationController.doSave();
            List<Apexpages.Message> pageMessages = ApexPages.getMessages();
            System.assertEquals(pageMessages[0].getDetail(),'Saved Successfully');
            PageReference pr =  objOptInOutConfigurationController.doCancel();
            //System.assertEquals(pr,Page.inwiseHome);
            PageReference pr1 = objOptInOutConfigurationController.gotoHome();
            //System.assertEquals(pr1,Page.inwiseHome);
        Test.stopTest();
    }

    // if channelTye = Email
    static testmethod void optInOutConfigurationControllerMethod2(){
        Contact con = inwiseTestDataFactory.GetInwiseContact();
        con.Email = 'barr_tim@grandhotels.com';
        insert con;

        Lead l = inwiseTestDataFactory.GetInwiseLead();
        l.Status =  'Open - Not Contacted';
        l.Email = 'barr_tim@grandhotels.com';
        insert l;

        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Toggle_inwise_Opt_in_Opt_out_Email__c = true;
        objSetting.Email_Unsubscribe_Contact_Field__c = 'HasOptedOutOfEmail';
        objSetting.Contact_Email_Search_Field__c = 'Email';
        objSetting.Lead_Email_Search_Field__c = 'Email';
        objSetting.Email_Unsubscribe_Lead_Field__c = 'HasOptedOutOfEmail';
        //objSetting.Toggle_inwise_Opt_in_Opt_out_Mobile__c = true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  



        Test.startTest();
            Test.setCurrentPage(Page.OptInOutConfiguration);
            OptInOutConfigurationController objOptInOutConfigurationController = new OptInOutConfigurationController();
            objOptInOutConfigurationController.doSave();
            List<Apexpages.Message> pageMessages = ApexPages.getMessages();
            System.assertEquals(pageMessages[0].getDetail(),'Saved Successfully');
            PageReference pr =  objOptInOutConfigurationController.doCancel();
            //System.assertEquals(pr,Page.inwiseHome);
            PageReference pr1 = objOptInOutConfigurationController.gotoHome();
            //System.assertEquals(pr1,Page.inwiseHome);
            PageReference pr2 = objOptInOutConfigurationController.doExecuteEmailUnsubscribe();
        Test.stopTest();
    }

    // if channelTye = sms
    static testmethod void optInOutConfigurationControllerMethod3(){
        Contact con = inwiseTestDataFactory.GetInwiseContact();
        con.MobilePhone = '78555554444';
        insert con;

        Lead l = inwiseTestDataFactory.GetInwiseLead();
        l.Status =  'Open - Not Contacted';
        l.MobilePhone = 'barr_tim@grandhotels.com';
        insert l;
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        //objSetting.Toggle_inwise_Opt_in_Opt_out_Email__c = true;
        objSetting.Toggle_inwise_Opt_in_Opt_out_Mobile__c = true;
        objSetting.Mobile_unsubscribe_contact_field__c = 'DoNotCall';
        //objSetting.Contact_Email_Search_Field__c = 'SearchEmail';
        objSetting.Mobile_unsubscribe_lead_field__c = 'DoNotCall';
        objSetting.Contact_Mobile_Search_Field__c='MobilePhone';
        objSetting.Lead_Mobile_Search_Field__c='MobilePhone';
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  

        Test.startTest();
            Test.setCurrentPage(Page.OptInOutConfiguration);
            OptInOutConfigurationController objOptInOutConfigurationController = new OptInOutConfigurationController();
            objOptInOutConfigurationController.doSave();
            List<Apexpages.Message> pageMessages = ApexPages.getMessages();
            System.assertEquals(pageMessages[0].getDetail(),'Saved Successfully');
            PageReference pr =  objOptInOutConfigurationController.doCancel();
            //System.assertEquals(pr,Page.inwiseHome);
            PageReference pr1 = objOptInOutConfigurationController.gotoHome();
            //System.assertEquals(pr1,Page.inwiseHome);
            PageReference pr2 = objOptInOutConfigurationController.doExecuteMobileUnsubscribe();
        Test.stopTest();
    }
	
}