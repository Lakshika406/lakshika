/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Test Class sample data creation
/******************************************************************************************/
public with sharing class inwiseTestDataFactory {
    
    public static Account__c GetInwiseAccount() {
        Account__c objInwiseAccountResult=new Account__c();
        objInwiseAccountResult.Name='Test Run Account';
        objInwiseAccountResult.Token__c = 'dwsd23232sdssdDE'; //inwiseUtil.encryptToken('dwsd23232sdssdDE');
        objInwiseAccountResult.User_Name__c='Test Run User';
        objInwiseAccountResult.Password__c='Testrun';
        return objInwiseAccountResult;
    }

    public static Token_Setting__c GetInwiseTokenSetting() {
        Token_Setting__c objInwiseSetting = new Token_Setting__c();
        objInwiseSetting.Name = 'default';
        //objInwiseSetting.Encryption_Key__c = '1234567890123456';
        //objInwiseSetting.Account_Id__c = '112232434335';
        objInwiseSetting.Token__c = 'dwsd23232sdssdDE';
        return objInwiseSetting;
    }
    
    public static Settings__c GetInwiseSetting() {
        Settings__c objInwiseSetting = new Settings__c();
        objInwiseSetting.Name = 'default';
        objInwiseSetting.API_Url__c = 'https://api.inwise.com/inwisewebservices.asmx';
        return objInwiseSetting;
    }
    
    public static Webhook_Setting__c GetInwiseWebhookSetting() {
        Webhook_Setting__c objInwiseSetting = new Webhook_Setting__c();
        objInwiseSetting.Name = 'default';
        objInwiseSetting.Contact_Field__c ='AssistantPhone';
        objInwiseSetting.Lead_Field__c ='MobilePhone';
        objInwiseSetting.Save_To_Activity_History__c =true;
        objInwiseSetting.Save_To_Messaging_History__c =true;
        return objInwiseSetting;
    }
    
    public static Contact GetInwiseContact() {
        Contact con = new Contact();
        con.Lastname = 'Test Contact';
        return con;
    }  
    
    public static Activity__c getInwiseActivity() {
        Activity__c act = new Activity__c();
        return act;
    } 
    
    public static Lead GetInwiseLead() {
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Company = 'inwise';
        return l;
    }
    
    public static map<string,Mapping__c> GetInwiseFieldMapping(Account__c acc){
        Map<String, Mapping__c> objMapping = new Map<String, Mapping__c>();
        //contact info
        Mapping__c mapping= new Mapping__c();
        mapping.Account__c = acc.Id;
        mapping.inwise_FieldId__c = '0';
        mapping.inwise_Field__c = 'Email';
        mapping.Object_Type__c = 'Contact';
        mapping.Salesforce_Field__c = 'Email';
        objMapping.put('Contact', mapping);
        
        //Lead info
        mapping= new Mapping__c();
        mapping.Account__c = acc.Id;
        mapping.inwise_FieldId__c = '1000';
        mapping.inwise_Field__c = 'Mobile';
        mapping.Object_Type__c = 'Lead';
        mapping.Salesforce_Field__c = 'MobilePhone';
        objMapping.put('Lead',mapping);
        
        mapping = new Mapping__c();
        mapping.Account__c = acc.Id;
        mapping.inwise_FieldId__c = '11';
        objMapping.put('Lead2',mapping);
        
        return objMapping;
    }
    
    public static CampaignMember getInwiseCampaignMember(Campaign campaignObj, Contact contactObj){
        CampaignMember cm = new CampaignMember();
        cm.ContactId = contactObj.Id;
        cm.CampaignId = campaignObj.Id;
        return cm;
    }
    
    public static HttpResponse getDumpHttpResponse(String resBody,String contentType){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', contentType);
        res.setBody(resBody);
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
    
    public static Mapping__c createMapping(Id actId,String fieldValue,String sfdcField, String sfdcObjType){
        Mapping__c mapping= new Mapping__c();
        mapping.Account__c = actId;
        mapping.inwise_FieldId__c = '0';
        mapping.inwise_Field__c = fieldValue;
        mapping.Object_Type__c = sfdcObjType;
        mapping.Salesforce_Field__c = sfdcField;
        return mapping;
    }
    public static Account_SalesforceUser_Mapping__c createAccountSalesforceUserMapping() {
        Account_SalesforceUser_Mapping__c objAccoutUserMapping = new Account_SalesforceUser_Mapping__c();
        return objAccoutUserMapping; 
    }
    
    public static Sync_Filter__c createTestSyncFilter(Sync__c objSync) {
        Sync_Filter__c objSyncFilterNew = new Sync_Filter__c();
        objSyncFilterNew.Field_Api_Name__c = 'Name:STRING';
        objSyncFilterNew.Field_Label__c = 'objSyncFilter.Field_Label__c';
        objSyncFilterNew.Field_Type__c = 'objSyncFilter.Field_Type__c';
        objSyncFilterNew.Operator__c = 'Equals';
        objSyncFilterNew.Sync__c = objSync.Id;
        objSyncFilterNew.Value__c = 'objSyncFilter.Value__c';
        objSyncFilterNew.sObject_Name__c = 'objSyncFilter.sObject_Name__c';
        
        return objSyncFilterNew;
    }
    
    public static Sync__c createTestSync() { 
        Sync__c objSync = new Sync__c();  
        objSync.name = 'leadSync';
        objSync.Group_Name__c = 'campaign5';
        objSync.Leads__c = true;
        objSync.Contacts__c = true;
        objSync.Scheduled_Daily_At__c = '1:00 AM';
        return objSync;
    }
    
    public static Campaign getInwiseCampaing(Account__c inwiseObj) {
        Campaign objInwiseCampaignResult = new Campaign();
        if(Schema.sObjectType.Campaign.fields.Name.isAccessible() && (Schema.sObjectType.Campaign.fields.Name.isCreateable() || Schema.sObjectType.Campaign.fields.Name.isUpdateable())){
            objInwiseCampaignResult.Name = 'Test_Campaign_' + Date.today().day();
        }
        if(Schema.sObjectType.Campaign.fields.ParentId.isAccessible() && (Schema.sObjectType.Campaign.fields.ParentId.isCreateable() || Schema.sObjectType.Campaign.fields.ParentId.isUpdateable())){
            objInwiseCampaignResult.ParentId = null;
        }
        if(Schema.sObjectType.Campaign.fields.Account__c.isAccessible() && (Schema.sObjectType.Campaign.fields.Account__c.isCreateable() || Schema.sObjectType.Campaign.fields.Account__c.isUpdateable())){
            objInwiseCampaignResult.Account__c = inwiseObj.id;
        }
        return objInwiseCampaignResult;     
    }  
    
    public static User createTestUser() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(firstname = 'fName',
                              lastName = 'Testing',
                              email = String.escapeSingleQuotes(uniqueName) + '@test' + String.escapeSingleQuotes(orgId) + '.org',
                              Username = String.escapeSingleQuotes(uniqueName) + '@test' + String.escapeSingleQuotes(orgId) + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = p.Id);
        return tuser;
        
    }
    
    public static Report_Lookup_Mapping__c getInwiseReportLookupMapping(Account__c inwiseOb, Sync__c syncObj, String objType) {
        Report_Lookup_Mapping__c objInwiseReportLookupMapping = new Report_Lookup_Mapping__c();
        objInwiseReportLookupMapping.Account__c = inwiseOb.Id;
        objInwiseReportLookupMapping.Inwise_Field__c='First Name';
        objInwiseReportLookupMapping.Inwise_FieldId__c = '01';
        objInwiseReportLookupMapping.Object_Type__c = objType; 
        objInwiseReportLookupMapping.Salesforce_Field__c = 'FirstName';
        objInwiseReportLookupMapping.Sync__c = syncObj.Id;
        return objInwiseReportLookupMapping;     
    }  
}