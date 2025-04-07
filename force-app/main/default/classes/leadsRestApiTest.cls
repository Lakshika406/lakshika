/******************************************************************************************
*Created By :  Shyam Vaishnav
*Created On :  14-March-2022
*Purpose    :  test class for activitiesRestApi
******************************************************************************************/
@isTest
Public class leadsRestApiTest{
    
    static testMethod void checkleadsRestApi(){
        
        Contact con = new Contact();
        con.FirstName = 'first name';
        con.LastName = 'test contact';
        con.MobilePhone = '9696969610';
        con.Email = 'testemail@gmail.com';
        insert con;
        
        Campaign camp = new Campaign(Name = 'Test', IsActive = TRUE);
        insert camp;
        
        CampaignMember member = new CampaignMember(ContactId = con.Id, Status = 'sent', CampaignId = camp.Id); 
        insert member;
        
        Landing_Sync__c sync = new Landing_Sync__c();
        sync.Leads__c = true;
        sync.Form_Type__c = null;
        sync.Landing_Page_Id__c = null;
        sync.Name = 'Test Landing Page';
        sync.Landing_Page_Name__c = 'Landing Page1';
        insert sync;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/leadsRestApi'; 
        req.addParameter('timeStamp','2020-03-10 12:48:56');
        req.addParameter('trigger_type','Test Type' );
        req.addParameter('trigger_description','Test description' );
        req.addParameter('survey_field[2]', 'Email');
        req.addParameter('survey_field[3]', '9696960101');
        req.addParameter('survey_field[5]', 'first name');
        req.addParameter('survey_field[6]', 'last name');
        req.addParameter('group_id', '787963');
        req.addParameter('ip', '84.228.153.2');
        req.addParameter('contact[id]', con.Id);
        req.addParameter('contact[email]', con.Email);
        req.addParameter('contact[mobile_number]', con.MobilePhone);
        req.addParameter('contact[external_id]', member.Id);
        req.addParameter('contact[field1]', con.FirstName);
        req.addParameter('contact[field2]', con.LastName);
        req.addParameter('syncId', 'additional_details');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        //leadsRestApi.inwiseLeadsService();
        Test.stopTest();
        
        List<Activity__c> inwiseActivityList = [Select Id,Contact__c From Activity__c];
        System.assertEquals(1, inwiseActivityList.size());
        System.assertEquals(con.Id, inwiseActivityList[0].Contact__c);
    }     
}