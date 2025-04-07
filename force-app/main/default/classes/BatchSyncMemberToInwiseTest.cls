/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Updated On:  
*Purpose :    Test Code coverage for BatchSyncMemberToInwise
/******************************************************************************************/
@isTest
private class BatchSyncMemberToInwiseTest {
    
    static testMethod void batchSyncMemberToInwiseReportsTest1() {
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = 'campaign5'; 
        objSync.Group_Id__c = 712999;
        objSync.Contacts_SOQL__c = 'SELECT Id,Name from Contact WHERE  Email !=  null';
        insert objSync;

        Contact con = new Contact();
        con.LastName = 'Test Lead';
        con.AssistantPhone ='0546414000';
        insert con;
        
        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting; 

        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;
        
        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  

        //List<Mapping__c> listOfMapping = new List<Mapping__c>();
        map<string,Mapping__c> mapping  = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        insert mapping.values();

        List<Mapping__c> listOfMapping = [SELECT Id, Name FROM Mapping__c];

        AggregateResult[] objInwiseFields = [SELECT inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:act1.Id  group by inwise_FieldId__c,inwise_Field__c];

        Sync_Master__c objSyncMaster = new Sync_Master__c();
        objSyncMaster.Group_Id__c = objSync.Group_Id__c;
        objSyncMaster.Total_Memerbs_Count__c = 30.25;
        objSyncMaster.Track_Members_When_Sync_Started__c = true;
        objSyncMaster.Sync__c = objSync.Id;
        insert objSyncMaster;

        //System.debug('==objSyncMaster=='+objSyncMaster.Group_Id__c);

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

        Lead objLead = new Lead();
        objLead.FirstName = 'inwise';
        objLead.LastName = 'Test Lead';
        objLead.Email = 'inwise@inwisetest.com';
        objLead.Status = 'Open - Not Contacted';        
        objLead.Company = 'inwise';
        insert ObjLead;

        Test.startTest();
        inwiseUtil inwiseObj = new inwiseUtil(act1);
        BatchSyncMemberToInwise obj = new BatchSyncMemberToInwise(); 
        obj.init(objSyncMaster.Id, objSync.Id, false, true, objSync.Contacts_SOQL__c, true);
        DataBase.executeBatch(obj);
        //obj.doSyncMembersWithInwise();
        obj.jsonForMobileCampaignPerRecord(ObjLead,'Lead',listOfMapping,objInwiseFields,mapping);
        obj.jsonForMobileCampaignPerRecord(con,'Contact',listOfMapping,objInwiseFields,mapping);
        System.assert(act1.Default__c == true); 
        Test.stopTest();
    }

}