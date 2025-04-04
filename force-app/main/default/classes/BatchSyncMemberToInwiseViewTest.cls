/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Updated On:  
*Purpose :    Test Code coverage for BatchSyncMemberToInwiseView
/******************************************************************************************/
@isTest
private class BatchSyncMemberToInwiseViewTest {

    static testMethod void batchSyncMemberToInwiseReportsTest1() {

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;  

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  

        Lead objLead = new Lead();
        objLead.FirstName = 'inwise';
        objLead.LastName = 'Test Lead';
        objLead.Email = 'inwise@inwisetest.com';
        objLead.Status = 'Open - Not Contacted';        
        objLead.Company = 'inwise';
        insert ObjLead;

        //List<Mapping__c> listOfMapping = new List<Mapping__c>();
        map<string,Mapping__c> mapping  = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        insert mapping.values();

        List<Mapping__c> listOfMapping = [SELECT Id, Name FROM Mapping__c];
        AggregateResult[] objInwiseFields = [SELECT inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:act1.Id  group by inwise_FieldId__c,inwise_Field__c];

        Contact con = new Contact();
        con.LastName = 'Test Lead';
        con.AssistantPhone ='0546414000';
        insert con;

        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = 'campaign5';
        objSync.Contact_Report__c = 'unfiled$public/New_Test_Contact_Report_ubH';  
        //objSync.Contact_View__c = '00B580000049cx9EAA'; 
        objSync.Account__c = act1.Id;
        insert objSync;
        //System.debug('==objSync=='+objSync.Group_Id__c);

        Sync_Master__c objSyncMaster = new Sync_Master__c();
        objSyncMaster.Group_Id__c = objSync.Group_Id__c;
        objSyncMaster.Total_Memerbs_Count__c = 30.25;
        objSyncMaster.Track_Members_When_Sync_Started__c = true;
        objSyncMaster.Sync__c = objSync.Id;
        insert objSyncMaster;

        List<Sync_Members__c> listOfSyncMembers = new List<Sync_Members__c>(); 

        Sync_Members__c syncmember1 = new Sync_Members__c();
        syncmember1.Sync_Master__c = objSyncMaster.id;
        syncmember1.Type__c = 'Contact';
        //insert syncmember1;
        listOfSyncMembers.add(syncmember1);

        Sync_Members__c syncmember2 = new Sync_Members__c();
        syncmember2.Sync_Master__c = objSyncMaster.id;
        syncmember2.Type__c = 'Lead';
        //insert syncmember1;
        listOfSyncMembers.add(syncmember2);

        insert listOfSyncMembers;

        // Report rp = new Report();
        // rp.DeveloperName  = 'New_Test_Contact_Report_ubH';
        // insert rp;
        String jsonInput = '{"email":"are02@gmail.com","LastName":"ABCD","FirstName":"ACFPY","Suffix":"","Title":"Engineer","Psw":"","PhoneCode":"","Phone":"100-000-000"}';
        //Test.startTest();

        //Database.BatchableContext BC = new Database.BatchableContext();

        BatchSyncMemberToInwiseView obj = new BatchSyncMemberToInwiseView(); 
        obj.init(objSyncMaster.Id, objSync.Id, false, true, objSync.Contact_View__c, true);
        DataBase.executeBatch(obj);
        //obj.execute();
        obj.jsonForMobileCampaignPerRecord(ObjLead,'Lead',listOfMapping,objInwiseFields,mapping);
        obj.jsonForMobileCampaignPerRecord(con,'Contact',listOfMapping,objInwiseFields,mapping);
        System.assert(act1.Default__c == true); 
        //Test.stopTest();
    } 
}