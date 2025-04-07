/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 30-Nov-2020
*Purpose :  test class for RestAPIInwiseUnsubscribe
******************************************************************************************/
@isTest
public with sharing class RestAPIInwiseUnsubscribeTest {
    static testMethod void testDoPost(){
        contact con = new contact();
        con.LastName = 'test contact';
    	insert  con;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/inwiseUnsubscribe'; 
        req.addParameter('trigger_type','EmailUnsubscribed' );
        req.addParameter('timeStamp','2020-03-10 12:48:56' );
        req.addParameter('channel_type', 'Email');
        req.addParameter('campaign_id','787963' );
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('remarks', '787963');
     	req.addParameter('contact[external_id]', con.Id);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Email_Unsubscribe_Contact_Field__c='HasOptedOutOfFax';
        objSetting.Email_Unsubscribe_Lead_Field__c='HasOptedOutOfEmail';
        objSetting.Mobile_unsubscribe_lead_field__c='HasOptedOutOfFax';
        objSetting.Mobile_unsubscribe_contact_field__c='HasOptedOutOfEmail';
        objSetting.Contact_Mobile_Search_Field__c = 'MobilePhone';
        objSetting.Contact_Email_Search_Field__c = 'Email';
        objSetting.Lead_Mobile_Search_Field__c  = 'MobilePhone';
        objSetting.Lead_Email_Search_Field__c = 'Email';
        Insert objSetting;
    
        Test.startTest();
        RestAPIInwiseUnsubscribe.ApiService();
        Test.stopTest();
    	System.assertNotEquals(con.Id, objSetting.Id);
    }

    static testMethod void testDoPost1(){
        Lead leadRec =new Lead();
        leadRec.LastName ='test lead';
        leadRec.Company ='Test Company';
        leadRec.Company ='Test Company';
        leadRec.MobilePhone = '1234567890';
    	insert  leadRec;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/inwiseUnsubscribe'; 
        req.addParameter('trigger_type','EmailUnsubscribed' );
        req.addParameter('timeStamp','2020-03-10 12:48:56' );
        req.addParameter('channel_type', 'sms');
        req.addParameter('campaign_id','787963' );
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('remarks', '787963');
     	req.addParameter('contact[external_id]', leadRec.Id);
        req.addParameter('contact[mobile_number]', leadRec.MobilePhone);
        
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Email_Unsubscribe_Contact_Field__c='HasOptedOutOfFax';
        objSetting.Email_Unsubscribe_Lead_Field__c='HasOptedOutOfEmail';
        objSetting.Mobile_unsubscribe_lead_field__c='HasOptedOutOfFax';
        objSetting.Mobile_unsubscribe_contact_field__c='HasOptedOutOfEmail';
        objSetting.Contact_Mobile_Search_Field__c = 'MobilePhone';
        objSetting.Contact_Email_Search_Field__c = 'Email';
        objSetting.Lead_Mobile_Search_Field__c  = 'MobilePhone';
        objSetting.Lead_Email_Search_Field__c = 'Email';
        Insert objSetting;
    
        Test.startTest();
        RestAPIInwiseUnsubscribe.ApiService();
        System.assertNotEquals(leadRec.Id, objSetting.Id);
        Test.stopTest();
    }

    static testMethod void testDoPost2(){
        contact con =new contact();
        con.LastName ='test contact';
        con.email = 'test@gmail.com';
    	insert  con;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/inwiseUnsubscribe'; 
        req.addParameter('trigger_type','EmailUnsubscribed' );
        req.addParameter('timeStamp','2020-03-10 12:48:56' );
        req.addParameter('channel_type', 'email');
        req.addParameter('campaign_id','787963' );
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('remarks', '787963');
     	req.addParameter('contact[email]', 'test@gmail.com');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Email_Unsubscribe_Contact_Field__c='HasOptedOutOfFax';
        objSetting.Email_Unsubscribe_Lead_Field__c='HasOptedOutOfEmail';
        objSetting.Mobile_unsubscribe_lead_field__c='HasOptedOutOfFax';
        objSetting.Mobile_unsubscribe_contact_field__c='HasOptedOutOfEmail';
        objSetting.Contact_Mobile_Search_Field__c = 'MobilePhone';
        objSetting.Contact_Email_Search_Field__c = 'Email';
        objSetting.Lead_Mobile_Search_Field__c  = 'MobilePhone';
        objSetting.Lead_Email_Search_Field__c = 'Email';
        Insert objSetting;
    
        Test.startTest();
        RestAPIInwiseUnsubscribe.ApiService();
        System.assertNotEquals(con.Id, objSetting.Id);
        Test.stopTest();
    }

    static testMethod void testDoPost5(){
        contact con =new contact();
        con.LastName ='test contact';
        con.MobilePhone = '502323001';
    	insert  con;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/inwiseUnsubscribe'; 
        req.addParameter('trigger_type','EmailUnsubscribed' );
        req.addParameter('timeStamp','2020-03-10 12:48:56' );
        req.addParameter('channel_type', 'sms');
        req.addParameter('campaign_id','787963' );
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('remarks', '787963');
     	req.addParameter('contact[mobile_number]', con.MobilePhone);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Email_Unsubscribe_Contact_Field__c='HasOptedOutOfFax';
        objSetting.Email_Unsubscribe_Lead_Field__c='HasOptedOutOfEmail';
        objSetting.Mobile_unsubscribe_lead_field__c='HasOptedOutOfFax';
        objSetting.Mobile_unsubscribe_contact_field__c='HasOptedOutOfEmail';
        objSetting.Contact_Mobile_Search_Field__c = 'MobilePhone';
        objSetting.Contact_Email_Search_Field__c = 'Email';
        objSetting.Lead_Mobile_Search_Field__c  = 'MobilePhone';
        objSetting.Lead_Email_Search_Field__c = 'Email';
        Insert objSetting;
    
        Test.startTest();
        RestAPIInwiseUnsubscribe.ApiService();
        System.assertNotEquals(con.Id, objSetting.Id);
        Test.stopTest();
    }

    static testMethod void testDoPost3(){
        contact con =new contact();
        con.LastName ='test contact';
    	insert con;

        campaign cmp = new campaign(name = 'Test cmp');
        insert cmp;
        
        campaignMember cmpMem = new campaignMember(contactId = con.Id,CampaignId = cmp.Id);
        insert cmpMem;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/inwiseUnsubscribe'; 
        req.addParameter('trigger_type','EmailUnsubscribed' );
        req.addParameter('timeStamp','2020-03-10 12:48:56' );
        req.addParameter('channel_type', 'sms');
        req.addParameter('campaign_id','787963' );
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('remarks', '787963');
     	req.addParameter('contact[mobile_number]', '50-2323001');
        req.addParameter('contact[external_id]', cmpMem.Id);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Email_Unsubscribe_Contact_Field__c='HasOptedOutOfFax';
        objSetting.Email_Unsubscribe_Lead_Field__c='HasOptedOutOfEmail';
        objSetting.Mobile_unsubscribe_lead_field__c='HasOptedOutOfFax';
        objSetting.Mobile_unsubscribe_contact_field__c='HasOptedOutOfEmail';
        objSetting.Contact_Mobile_Search_Field__c = 'MobilePhone';
        objSetting.Contact_Email_Search_Field__c = 'Email';
        objSetting.Lead_Mobile_Search_Field__c  = 'MobilePhone';
        objSetting.Lead_Email_Search_Field__c = 'Email';
        Insert objSetting;
    
        Test.startTest();
        RestAPIInwiseUnsubscribe.ApiService();
        System.assertNotEquals(con.Id, objSetting.Id);
        Test.stopTest();
    }

    static testMethod void testDoPost4(){
        lead leadRec =new lead();
        leadRec.LastName ='test lead';
        leadRec.Company = 'test com';
    	insert  leadRec;

        campaign cmp = new campaign(name = 'Test cmp');
        insert cmp;

        campaignMember cmpMem = new campaignMember(leadId = leadRec.Id,CampaignId = cmp.Id);
        insert cmpMem;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/inwiseUnsubscribe'; 
        req.addParameter('trigger_type','EmailUnsubscribed' );
        req.addParameter('timeStamp','2020-03-10 12:48:56' );
        req.addParameter('channel_type', 'sms');
        req.addParameter('campaign_id','787963' );
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('remarks', '787963');
     	req.addParameter('contact[mobile_number]', '50-2323001');
        req.addParameter('contact[external_id]', cmpMem.Id);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Email_Unsubscribe_Contact_Field__c='HasOptedOutOfFax';
        objSetting.Email_Unsubscribe_Lead_Field__c='HasOptedOutOfEmail';
        objSetting.Mobile_unsubscribe_lead_field__c='HasOptedOutOfFax';
        objSetting.Mobile_unsubscribe_contact_field__c='HasOptedOutOfEmail';
        objSetting.Contact_Mobile_Search_Field__c = 'MobilePhone';
        objSetting.Contact_Email_Search_Field__c = 'Email';
        objSetting.Lead_Mobile_Search_Field__c  = 'MobilePhone';
        objSetting.Lead_Email_Search_Field__c = 'Email';
        objSetting.Track_Logs__c = true;
        Insert objSetting;
    
        Test.startTest();
        RestAPIInwiseUnsubscribe.ApiService();
        System.assertNotEquals(leadRec.Id, objSetting.Id);
        Test.stopTest();
    }

    static testMethod void testDoPost6(){
        lead leadRec =new lead();
        leadRec.LastName ='test lead';
        leadRec.Company = 'test com';
        leadRec.Email = 'test@gmail.com';
    	insert  leadRec;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/inwiseUnsubscribe'; 
        req.addParameter('trigger_type','EmailUnsubscribed' );
        req.addParameter('timeStamp','2020-03-10 12:48:56' );
        req.addParameter('channel_type', 'Email');
        req.addParameter('campaign_id','787963' );
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('remarks', '787963');
        req.addParameter('contact[email]', 'test@gmail.com');
     	req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Email_Unsubscribe_Contact_Field__c='HasOptedOutOfFax';
        objSetting.Email_Unsubscribe_Lead_Field__c='HasOptedOutOfEmail';
        objSetting.Mobile_unsubscribe_lead_field__c='HasOptedOutOfFax';
        objSetting.Mobile_unsubscribe_contact_field__c='HasOptedOutOfEmail';
        objSetting.Contact_Mobile_Search_Field__c = 'MobilePhone';
        objSetting.Contact_Email_Search_Field__c = 'Email';
        objSetting.Lead_Mobile_Search_Field__c  = 'MobilePhone';
        objSetting.Lead_Email_Search_Field__c = 'Email';
        Insert objSetting;
    
        Test.startTest();
        RestAPIInwiseUnsubscribe.ApiService();
        System.assertNotEquals(leadRec.Id, objSetting.Id);
        Test.stopTest();
    } 
    
    static testMethod void testDoPost7(){
        lead leadRec =new lead();
        leadRec.LastName ='test lead';
        leadRec.Company = 'test com';
        leadRec.MobilePhone = '1234567890';
    	insert  leadRec;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/inwiseUnsubscribe'; 
        req.addParameter('trigger_type','EmailUnsubscribed' );
        req.addParameter('timeStamp','2020-03-10 12:48:56' );
        req.addParameter('channel_type', 'SMS');
        req.addParameter('campaign_id','787963' );
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('remarks', '787963');
        req.addParameter('contact[mobile_number]', '12-34567890');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Email_Unsubscribe_Contact_Field__c='HasOptedOutOfFax';
        objSetting.Email_Unsubscribe_Lead_Field__c='HasOptedOutOfEmail';
        objSetting.Mobile_unsubscribe_lead_field__c='HasOptedOutOfFax';
        objSetting.Mobile_unsubscribe_contact_field__c='HasOptedOutOfEmail';
        objSetting.Contact_Mobile_Search_Field__c = 'MobilePhone';
        objSetting.Contact_Email_Search_Field__c = 'Email';
        objSetting.Lead_Mobile_Search_Field__c  = 'MobilePhone';
        objSetting.Lead_Email_Search_Field__c = 'Email';
        Insert objSetting;
    
        Test.startTest();
        RestAPIInwiseUnsubscribe.ApiService();
        System.assertNotEquals(leadRec.Id, objSetting.Id);
        Test.stopTest();
    }
}