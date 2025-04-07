/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Updated On:  
*Purpose :    Test Code coverage for BatchSyncMemberToInwiseReports
/******************************************************************************************/
@isTest
private class BatchSyncMemberToInwiseReportsTest {

    static testMethod void batchSyncMemberToInwiseReportsTest1() {
        
        String reportName = 'ContactReport';
        List<Organization> orgLi = [SELECT Id, Name, Division, OrganizationType, IsSandbox FROM Organization Where Name = 'inwise LTD'];
        if(!orgLi.isEmpty()){
            reportName = 'Contact_and_Account_Report';
        }
        
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Contacts__c = true;
        objSync.Group_Name__c = 'campaign5';
        objSync.Contact_Report__c = reportName;
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

        Report_Lookup_Mapping__c reportLookupObj = inwiseTestDataFactory.getInwiseReportLookupMapping(act1,objSync,'Contact');
        insert reportLookupObj;
        System.debug('=reportLookupObj='+reportLookupObj);

        List<Report_Lookup_Mapping__c> listOfInwiseReportMapping1 = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c,Sync__c, Salesforce_Field__c FROM Report_Lookup_Mapping__c where Account__c=:act1.Id 
        AND Sync__c =: objSync.Id];
        System.debug('==listOfInwiseReportMapping1=='+listOfInwiseReportMapping1);
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
        BatchSyncMemberToInwiseReports obj = new BatchSyncMemberToInwiseReports(); 
        obj.init(objSyncMaster.Id, objSync.Id, false, true, objSync.Contact_Report__c, true);
        DataBase.executeBatch(obj);
        obj.jsonForMobileCampaignPerRecord(ObjLead,'Lead',listOfMapping,objInwiseFields,mapping);
        Test.stopTest();

        System.assertNotEquals(objSyncMaster.Id, ObjLead.Id);
        System.assertEquals(objSyncMaster.Id,objSyncMaster.Id);
        System.assert(objSyncMaster.Group_Id__c == objSync.Group_Id__c);
    }

    static testMethod void batchSyncMemberToInwiseReportsTest2() {

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
        
        String reportName = 'ContactReport';
        List<Organization> orgLi = [SELECT Id, Name, Division, OrganizationType, IsSandbox FROM Organization Where Name = 'inwise LTD'];
        if(!orgLi.isEmpty()){
            reportName = 'Contact_and_Account_Report';
        }
        
        map<string,Mapping__c> mapping  = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        insert mapping.values();
        List<Mapping__c> listOfMapping = [SELECT Id, Name FROM Mapping__c];
        // listOfMapping.add(mapping.values());
        AggregateResult[] objInwiseFields = [SELECT inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:act1.Id  group by inwise_FieldId__c,inwise_Field__c];
        Sync__c objSync = new Sync__c();
        objSync.name = 'leadSync';
        objSync.Group_Name__c = 'campaign5';
        objSync.Contact_Report__c = 'unfiled$public/' + reportName;
        objSync.Lead_Report__c = 'unfiled$public/' + reportName;
        insert objSync;

        Report_Lookup_Mapping__c reportLookupObj = inwiseTestDataFactory.getInwiseReportLookupMapping(act1,objSync,'Contact');
        System.debug('=reportLookupObj='+reportLookupObj);
        Sync_Master__c objSyncMaster = new Sync_Master__c();
        objSyncMaster.Group_Id__c = objSync.Group_Id__c;
        objSyncMaster.Total_Memerbs_Count__c = 30.25;
        objSyncMaster.Track_Members_When_Sync_Started__c = true;
        objSyncMaster.Sync__c = objSync.Id;
        insert objSyncMaster;

        List<Sync_Members__c> listOfSyncMembers = new List<Sync_Members__c>(); 

        Sync_Members__c syncmember2 = new Sync_Members__c();
        syncmember2.Sync_Master__c = objSyncMaster.id;
        syncmember2.Type__c = 'Lead';
        listOfSyncMembers.add(syncmember2);

        insert listOfSyncMembers;

        Test.startTest(); 
        BatchSyncMemberToInwiseReports obj = new BatchSyncMemberToInwiseReports(); 
        obj.init(objSyncMaster.Id, objSync.Id, false, true, objSync.Lead_Report__c, true);
        DataBase.executeBatch(obj);
		obj.jsonForMobileCampaignPerRecord(con,'Contact',listOfMapping,objInwiseFields,mapping);
        Test.stopTest();

        System.assertNotEquals(objSyncMaster.Id, objSync.Id);
        System.assert(objSyncMaster.Group_Id__c == objSync.Group_Id__c); 
    }
}