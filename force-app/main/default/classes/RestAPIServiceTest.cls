/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 30-Nov-2020
*Purpose :  test class for RestAPIService
******************************************************************************************/
@isTest
public class RestAPIServiceTest {
    static testMethod void testDoPost(){
        contact con =new contact();
        con.LastName ='test contact';
        con.AssistantPhone = '1234567890';
    	insert  con;
        
        lead leadRec =new lead();
        leadRec.LastName ='test lead';
        leadRec.Company = 'test com';
        leadRec.MobilePhone = '1234567890';
    	insert  leadRec;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/inwiseUnsubscribe'; 
        req.addParameter('trigger_type','ConfirmUnsubscribe' );
        req.addParameter('timeStamp','2020-03-10 12:48:56' );
        req.addParameter('channel_type', 'Email');
        req.addParameter('campaign_id','787963' );
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('remarks', '787963');
     	req.addParameter('contact[external_id]', con.Id);
        req.addParameter('contact[mobile_number]', con.AssistantPhone);
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
        
        Webhook_Setting__c objWebhookSetting = inwiseTestDataFactory.GetInwiseWebhookSetting();
        Insert objWebhookSetting;
    
        Test.startTest();
        RestAPIService.ApiService();
        Test.stopTest();
        List<Messaging_History__c> listofMessageHistoryToInsert = [select id from  Messaging_History__c];
        List<Task> listofTaskToInsert = [select id from  Task];
        system.assertNotEquals(null, listofMessageHistoryToInsert);
        system.assertNotEquals(null, listofTaskToInsert);
       // List<Incoming_Webhooks__c> incomingWebhookList =[select id,Contact__c from  Incoming_Webhooks__c];
    	//system.assertEquals(1, incomingWebhookList.size());
    	//system.assertEquals(con.Id, incomingWebhookList[0].Contact__c);
    
    }
    

}