/******************************************************************************************
*Created By :  Shyam Vaishnav
*Created On :  14-March-2022
*Purpose    :  test class for activitiesRestApi
************************************************* *****************************************/
@isTest
Public class ActivitiesRestApiTest{
    
    static testMethod void checkActivitiesRestApi(){

        Contact con = new Contact();
        con.LastName = 'test contact';
        con.Email = 'testemail@gmail.com';
        insert con;

        Campaign camp = new Campaign(Name = 'Test', IsActive = TRUE);
        insert camp;

        CampaignMember member = new CampaignMember(ContactId = con.Id, Status = 'sent', CampaignId = camp.Id); 
        insert member;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/activitiesRestApi'; 
        req.addParameter('timeStamp','2020-03-10 12:48:56');
        req.addParameter('trigger_type','Test Type' );
        req.addParameter('channel_type', 'Email');
        req.addParameter('campaign_id', camp.Id);
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('contact[id]', con.Id);
        req.addParameter('contact[email]', con.Email);
        req.addParameter('contact[external_id]', member.Id);
        req.addParameter('additional_details', 'additional_details');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        activitiesRestApi.inwiseActivitiesService();
        Test.stopTest();

        List<Activity__c> inwiseActivityList = [Select Id,Contact__c From Activity__c];
        System.assertEquals(1, inwiseActivityList.size());
        System.assertEquals(con.Id, inwiseActivityList[0].Contact__c);
    }     
}
