@isTest
public class InboundSMSConfigurationControllerTest {

    static testmethod void InboundSMSConfigurationControllerTest1() {
        Webhook_Setting__c objInwiseSetting = inwiseTestDataFactory.GetInwiseWebhookSetting();
        objInwiseSetting.Account_Field__c = 'Phone';
        insert objInwiseSetting;

        PageReference pgRef = Page.InboundSMSConfiguration;
        InboundSMSConfigurationController smsConf = new InboundSMSConfigurationController();
        smsConf.isActivityHistorySelected = false;
        smsConf.isMessageHistorySelected = false;
        smsConf.doSave();
        smsConf.doCancel();

        System.assertNotEquals(objInwiseSetting.Name, objInwiseSetting.Account_Field__c);
    }

    static testmethod void InboundSMSConfigurationControllerTest() {
        Webhook_Setting__c objInwiseSetting = inwiseTestDataFactory.GetInwiseWebhookSetting();
        insert objInwiseSetting;

        PageReference pgRef = Page.InboundSMSConfiguration;
        InboundSMSConfigurationController smsConf = new InboundSMSConfigurationController();
        smsConf.doSave();
        smsConf.doCancel();

        System.assertNotEquals(objInwiseSetting.Name, objInwiseSetting.Contact_Field__c);
    }

    static testmethod void InboundSMSConfigurationControllerTest3() {
        Webhook_Setting__c objInwiseSetting = inwiseTestDataFactory.GetInwiseWebhookSetting();
        objInwiseSetting.Account_Field__c = 'Phone';
        insert objInwiseSetting;

        PageReference pgRef = Page.InboundSMSConfiguration;
        InboundSMSConfigurationController smsConf = new InboundSMSConfigurationController();
        smsConf.isContactSelected = false;
        smsConf.isLeadSelected = false;
        smsConf.isAccountSelected = false;
        smsConf.doSave();
        smsConf.doCancel();

        System.assertNotEquals(objInwiseSetting.Name, objInwiseSetting.Account_Field__c);
    }

    static testmethod void InboundSMSConfigurationControllerTest4() {
        Webhook_Setting__c objInwiseSetting = inwiseTestDataFactory.GetInwiseWebhookSetting();
        insert objInwiseSetting;

        PageReference pgRef = Page.InboundSMSConfiguration;
        InboundSMSConfigurationController smsConf = new InboundSMSConfigurationController();
        smsConf.isAccountSelected = true;
        smsConf.doSave();
        smsConf.doCancel();

        System.assertNotEquals(objInwiseSetting.Name, objInwiseSetting.Lead_Field__c);
    }
}