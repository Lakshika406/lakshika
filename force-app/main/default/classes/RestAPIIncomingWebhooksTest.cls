/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 04-April-2020
*Purpose :  test class for RestAPIIncomingWebhooks
******************************************************************************************/
@isTest
Public class RestAPIIncomingWebhooksTest{

    static testMethod void testDoPost(){

        contact con = new contact();
        con.LastName = 'test contact';
        insert  con;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/IncomingWebhooks'; 
        req.addParameter('triggerType','clicked on link' );
        req.addParameter('timeStamp','2020-03-10 12:48:56' );
        req.addParameter('channelType', 'Email');
        req.addParameter('campaign_id','787963' );
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('remarks', '787963');
        req.addParameter('contact[external_id]', con.Id);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        RestAPIIncomingWebhooks.ApiService();
        Test.stopTest();

        List<Incoming_Webhooks__c> incomingWebhookList = [Select Id,Contact__c From Incoming_Webhooks__c];
        System.assertEquals(1, incomingWebhookList.size());
        System.assertEquals(con.Id, incomingWebhookList[0].Contact__c);
    }

    static testMethod void testDoPost1(){

        contact con = new contact();
        con.LastName ='test contact';
        insert  con;

        Campaign camp = new Campaign(Name = 'Test', IsActive = TRUE);
        insert camp;

        CampaignMember member = new CampaignMember(ContactId = con.Id, Status = 'sent', CampaignId = camp.Id); 
        insert member; 
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/IncomingWebhooks'; 
        req.addParameter('triggerType','clicked on link' );
        req.addParameter('timeStamp','2020-03-10 12:48:56' );
        req.addParameter('channelType', 'Email');
        req.addParameter('campaign_id','787963' );
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('remarks', '787963');
        req.addParameter('contact[external_id]', member.Id);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        RestAPIIncomingWebhooks.ApiService();
        Test.stopTest();

        List<Incoming_Webhooks__c> incomingWebhookList = [Select Id,Contact__c From Incoming_Webhooks__c];
        System.assertEquals(1, incomingWebhookList.size());
        System.assertEquals(con.Id, incomingWebhookList[0].Contact__c);
    }     
}