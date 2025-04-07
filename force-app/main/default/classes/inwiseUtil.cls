/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Util class to contain common method
Modification Log
---------------- 
Date                  Version   Developer                  Comments
------------------------------------------------------------------------------------
04/18/2019        1.1.0       K.Goutam                  Modified:- Changed in apiurl
05/08/2019        1.1.1       K.Goutam                  Modified:- Removed last batch checked as last batch in finish for all batch classes
05/07/2021        1.1.2       NLINEAXIS(K.Goutam)       Modified:- added getAccessibleAccountIds method
06/09/2021        1.1.3       NLINEAXIS(S.V)            Modified:- Added new method createMetadataService
06/10/2021        1.1.4       NLINEAXIS(K.Goutam)       Modified:- Added new field on Is_Created_By_Report__c,Contact_Report__c,Lead_Report__c.
10/18/2021        1.1.5       NLINEAXIS(K.Goutam)       Modified:- Added CreatedDate field in doGetSyncMaster method
01/21/2021        1.1.6       NLINEAXIS(S.Vaishnav)     Modified:- Added Test.isRunningTest() in the isPersonAccountEnabled() method
08/10/2022        1.1.7       NLINEAXIS(S.Vaishnav)     Modified:- Added new method inwiseAutomation for automation from webhook
08/23/2022        1.1.8       NLINEAXIS(S.Vaishnav)     Modified:- Added new method executeLandingSync for InwiseCalloutLandingSync
09/01/2022        1.1.9       NLINEAXIS(S.Vaishnav)     Modified:- Added SMS_Sender__c field in Account__c query
10/04/2024        1.1.10       NLINEAXIS                Modified:- Added encryptToken and encryptedToken methods for Token Field 

/***********************************************************************************/

public with sharing class inwiseUtil {
    
    public Account__c objInwiseAccount{get;set;}
    public String inwiseAccountToken{get;set;}
    public Settings__c objInwiseSetting{get;set;}
    public String apiUrl{get;set;}
    static String apiURLGlobal = 'https://api.inwise.com';
    public static final String PREFIX = inwiseUtil.class.getName().substringBefore('Utils').replace('.','__');

    public Token_Setting__c objInwiseTokenSetting {get;set;}

    public List<string> Error_Messages{get;set;}
    public Map<String, String> accIdWithTokenMap ;

    public static Boolean isAccessToken = true;
    
    public inwiseUtil(){
          apiUrl = apiURLGlobal;
    }
    
    public inwiseUtil(Account__c acc){
        apiUrl = apiURLGlobal;
        List<Account__c> listOfInwiseAccount = new List<Account__c>();
        if(acc != NULL){
            if (Schema.sObjectType.Account__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Password__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.User_Name__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Default_Campaign_Type__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.ListEmailFeedBackActionMaxId__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.ListEmailSentMessageMaxId__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.SMS_Sender__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Country__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Trim_Leading_Zero__c.isAccessible()) {
                    
                listOfInwiseAccount = [SELECT Id,Name,Password__c,User_Name__c,Default_Campaign_Type__c,ListEmailFeedBackActionMaxId__c, ListEmailSentMessageMaxId__c,SMS_Sender__c,Country__c,Trim_Leading_Zero__c FROM Account__c WHERE Id = :acc.Id WITH SECURITY_ENFORCED limit 1]; 
            }

            if(!listOfInwiseAccount.isEmpty()){
                objInwiseAccount = getFirstIndexRec(listOfInwiseAccount);//listOfInwiseAccount.get(0); 
                //inwiseAccountToken = decryptToken(objInwiseAccount.Token__c);
                inwiseAccountToken = getTokenToAccId(acc.Id);
            }
        }    
        Initialize();
        getAllTokenByAcc();
    }
    
    public static Account__c getFirstIndexRec(List<Account__c> listOfInwiseAccount){
        Account__c acc;
        for(Account__c accnt : listOfInwiseAccount){
            acc = accnt;
            
        }
        return acc;
    }
    
    //**************** Public Members ********************
    public List<SelectOption> GetInwiseFields(List<Logs__c> listOfLogs){
        Error_Messages = new List<string>();
        List<SelectOption> listOfFields = new List<SelectOption>();

        Http http =  new Http();
        HttpResponse res;
        String endpoint = apiUrl + '/rest/v1/contacts/mergeFields';

        HttpRequest req = GetHTTPRequest('GET','application/json',endpoint); 
        //req.setHeader('X-Api-Key',inwiseAccountToken);
        req.setHeader('X-Api-Key',inwiseAccountToken);
        if(!Test.isRunningTest()){
            res = http.send(req);        
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contacts/mergeFields','inwiseUtil','GetInwiseFields'));        
        }else{
           res = new HttpResponse();
           res.setHeader('Content-Type', 'application/json');
           //String resBody='[{"id":4,"description":"Code","slicing":false,"type":"text"},{"id":2,"description":"Lname","slicing":false,"type":"text"},{"id":1,"description":"Fname","slicing":false,"type":"text"},{"id":3,"description":"Gender","slicing":true,"type":"text"}]';
           String resBody = '[   {     "id": 1,     "description": "first name",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 220,     "description": "xml1",     "slicing": false,     "type": "generic",     "options": null   },   {     "id": 240,     "description": "boaz xml",     "slicing": false,     "type": "generic",     "options": null   },   {     "id": 10,     "description": "מספר פקס",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 8,     "description": "טלפון נוסף",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 4,     "description": "קוד",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 21,     "description": "Birthday",     "slicing": false,     "type": "date",     "options": null   },   {     "id": 3,     "description": "SalesForce Camp Member ID",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 2,     "description": "last name",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 6,     "description": "עיר",     "slicing": false,     "type": "text",     "options": null   } ]';
           res.setBody(resBody);
           res.setStatusCode(200);
           res.setStatus('OK');
            
        }
        //System.debug('res.getStatusCode()::-->>' + res.getStatusCode());
        if(res.getStatusCode() == 200  && res.getBody() != NULL){ 
                String jsonString =  res.getBody();  //'[{"id":4,"description":"Code","slicing":false,"type":"text"},{"id":2,"description":"Lname","slicing":false,"type":"text"},{"id":1,"description":"Fname","slicing":false,"type":"text"},{"id":3,"description":"Gender","slicing":true,"type":"text"}]';
                //System.debug('fields from inwise::-->>' + jsonString);
                List<JsonToApexFieldMapping> listOfFieldMapiing = (List<JsonToApexFieldMapping>)JSON.deserialize(jsonString, List<JsonToApexFieldMapping>.class);
                // Add constant Email and Mobile no fields 
                SelectOption option = new SelectOption(String.valueOf(InwiseConstants.INWISE_FIELDID_EMAIL),'Email');
                listOfFields.add(option);
                
                option = new SelectOption(String.valueOf(InwiseConstants.INWISE_FIELDID_MOBILE),'Mobile');
                listOfFields.add(option);
                
                if(!listOfFieldMapiing.isEmpty()){
                    for(JsonToApexFieldMapping c:listOfFieldMapiing){
                        SelectOption so = new SelectOption(String.valueOf(c.id),c.description);
                        listOfFields.add(so);               
                    }
                }
        }
        return listOfFields;
    }
    
    public Boolean CheckIfCredentialExists(){
        Boolean isCredentialExists=true;
        // if(objInwiseSetting == NULL || objInwiseAccount == NULL || objInwiseAccount.Token__c == NULL){
        //        isCredentialExists = false;
        // }

        //if(objInwiseSetting == NULL || objInwiseAccount == NULL || objInwiseTokenSetting == NULL){ 
        if(objInwiseSetting == NULL || objInwiseAccount == NULL || inwiseAccountToken == NULL){
            isCredentialExists = false;
        }
        return isCredentialExists;
    }

    public static String hostUrl(String classNameStr){
        Schema.DescribeSObjectResult dsr = Landing_Sync__c.sObjectType.getDescribe();
        String namespacePrefix = dsr.getName().remove(dsr.getLocalName());
        String s = URL.getOrgDomainUrl().toExternalForm();

        if(namespacePrefix == 'inwise__'){
            s += '/services/apexrest/inwise/'+classNameStr;
        } else {
            s += '/services/apexrest/'+classNameStr;
        }
        return s;
    }

    public Boolean CheckIfMappingExists(){
        Boolean isMappingExistsForAccount=false;
        if(objInwiseAccount != NULL && objInwiseAccount.Id != NULL){
            if(Schema.sObjectType.Mapping__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible()){
                List<Mapping__c> listOfFieldMapiing = [Select Id from Mapping__c where Account__c =:objInwiseAccount.Id WITH SECURITY_ENFORCED LIMIT 1];
                if(!listOfFieldMapiing.isEmpty()){
                    isMappingExistsForAccount = true; 
                }
            }   
        }
        return isMappingExistsForAccount;
    }

    public static Set<Id> getAccessibleAccountIds(){
        Set<Id> setOfAccountIds = new Set<Id>();
        if(Schema.sObjectType.Account_SalesforceUser_Mapping__c.isAccessible() && Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.Account__c.isAccessible() &&
            Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isAccessible()){

            for(Account_SalesforceUser_Mapping__c acc : [SELECT Id, Account__c FROM Account_SalesforceUser_Mapping__c where User__c =: UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 49999]){
                setOfAccountIds.add(acc.Account__c);
            }
        }
        return setOfAccountIds;
    }
    //**************** Public Members ********************
    
    //**************** Private Members *******************
    private void Initialize(){
        Error_Messages = new List<string>();
        if(objInwiseAccount == null){
            List<Account__c> listOfInwiseAccount;
            //if(Schema.sObjectType.Account__c.isAccessible()){
            if (Schema.sObjectType.Account__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Password__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.User_Name__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Default_Campaign_Type__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.ListEmailFeedBackActionMaxId__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.ListEmailSentMessageMaxId__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.SMS_Sender__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Country__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Default__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Trim_Leading_Zero__c.isAccessible()) {

                listOfInwiseAccount = [SELECT Id,Name,Password__c,User_Name__c,Default_Campaign_Type__c,ListEmailFeedBackActionMaxId__c, ListEmailSentMessageMaxId__c,Country__c,Trim_Leading_Zero__c,SMS_Sender__c FROM Account__c WHERE Default__c = true WITH SECURITY_ENFORCED limit 1]; 
                if(!listOfInwiseAccount.isEmpty()){
                    objInwiseAccount = getFirstIndexRec(listOfInwiseAccount);//listOfInwiseAccount.get(0);
                    //inwiseAccountToken = decryptToken(objInwiseAccount.Token__c);
                    inwiseAccountToken = getTokenToAccId(objInwiseAccount.Id);
                }
            } 
        }
        objInwiseSetting = Settings__c.getAll().get('default');
        //objInwiseTokenSetting = Token_Setting__c.getAll().get('default');
    }

    public  HttpRequest GetHTTPRequest(string method, string contentType, String endpoint){
        Set<String> validMethods = new Set<String>{'GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'};
        if (!validMethods.contains(method)) {
            throw new IllegalArgumentException('Invalid HTTP method: ' + method);
        }
        if (String.isBlank(endpoint)) {
            throw new IllegalArgumentException('Invalid endpoint: ' + endpoint);
        }
        if (String.isBlank(contentType) ) {
            throw new IllegalArgumentException('Invalid content type: ' + contentType);
        }
        HttpRequest req = new HttpRequest(); 
        req.setMethod(method);
        req.setHeader('Content-Type',contentType);
        req.setEndpoint(endpoint);
        return req;
    }

    public Integer getBatchSize(){
        Integer sz = objInwiseSetting.Sync_Members_Batch_Size__c != NULL && objInwiseSetting.Sync_Members_Batch_Size__c > 0 ? Integer.valueOf(objInwiseSetting.Sync_Members_Batch_Size__c) : 100;  
        System.debug('sz::-->>>' + sz + '>>>' +objInwiseSetting );
        return sz; 
    }

    public static boolean isPersonAccountEnabled(){
        return Test.isRunningTest() ? false : Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
    }

    public static List<SelectOption> getFieldsForQueryFilter(String objectType,Set<String> setOfAcceptableTypes, boolean isformapping){
        Set<String> setOfStringExcludeFields = inwiseScheduleSyncObject.getSetOfExcludedFields(objectType);
        List<SelectOption> listOfSo = new List<SelectOption>();
        Map <String, Schema.SObjectField> fieldMap;
        SelectOption so;
        if(objectType ==InwiseConstants.SOBJECT_CONTACT){
                fieldMap = Schema.sObjectType.Contact.fields.getMap();
        }
        if(objectType ==InwiseConstants.SOBJECT_LEAD){
            fieldMap = Schema.sObjectType.Lead.fields.getMap();
        }
        if(objectType ==InwiseConstants.SOBJECT_ACCOUNT){
            if(isPersonAccountEnabled()){
                fieldMap = Schema.sObjectType.Account.fields.getMap();
            }else{
                fieldMap = Schema.sObjectType.Account.fields.getMap();
            }
        }
        Map<String, SelectOption> mapOfSelectOption = new Map<String, SelectOption>();
        if(fieldMap != null && !fieldMap.isEmpty()){
            for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult dfield = sfield.getDescribe();
                if(dfield.isFilterable() && setOfAcceptableTypes.contains(String.valueOf(dfield.getType()).toUpperCase()) && !setOfStringExcludeFields.contains(dfield.getname())){
                    if(isformapping){
                        so = new SelectOption(dfield.getname(),dfield.getLabel () + ' (' + String.valueOf(dfield.getType()).toLowerCase() +')');
                    }else{
                        so = new SelectOption(dfield.getname() + ':' + String.valueOf(dfield.getType()),dfield.getLabel () + ' (' + String.valueOf(dfield.getType()).toLowerCase() + ')');
                    }
                    //fix to avoid full name in list as this can not be set for lead
                    //fixed on 31 Dec 2018, for landing pages sync issue
                    if(objectType ==InwiseConstants.SOBJECT_LEAD && dfield.getname() == 'Name'){
                        //do not add this in list box
                    }else{
                        mapOfSelectOption.put(dfield.getLabel (),so);
                    }

                }

            }
        }

        so = new SelectOption('','--None--');
        listOfSo.add(so);
        List<String> listOfFields = new List<String>();
        listOfFields.addAll(mapOfSelectOption.keySet());
        listOfFields.sort();
        for(String s : listOfFields){
            listOfSo.add(mapOfSelectOption.get(s));
        }
        
        return listOfSo;
    }

    public static list<String> getFieldAPINamesFromFieldSet(String sObjectName, Set<String> fieldSets){
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        list<String> fields = new list<String>();

        /*describe the provided sObject */
        Schema.DescribeSObjectResult res = globalDescribe.get(sObjectName).getDescribe();
        System.debug('res::--->>>>' + res);
        /*get the fields set map  */
        if(res != null && res.isAccessible()){
            Map<String, Schema.FieldSet> fieldSetMap = res.fieldSets.getMap();
            System.debug('fieldSetMap::-->>>>' + fieldSetMap);
            /*iterate through provided fieldsets and generate query  */
            for(String fieldSetName : fieldSets){
                System.debug('fieldSetName:::-->>>>' + fieldSetName);
                Schema.FieldSet fs = fieldSetMap.get(fieldSetName);
                System.debug('fs:::::--->>>>' + fs);
                if(fs != null){
                    for( Schema.FieldSetMember fsm : fs.getFields() ) {
                        fields.add(fsm.getFieldPath().toLowercase());
                    }
                }
            }
        }
        return fields;
    }

    public void updateOverlayHelp(boolean isHelpOnload){
        Settings__c objSetting = new Settings__c(Id=objInwiseSetting.Id);
        if(Schema.sObjectType.Settings__c.fields.Overlay_Help__c.isUpdateable()){
            objSetting.Overlay_Help__c = isHelpOnload;
        }    
        if(Schema.sObjectType.Settings__c.isUpdateable()){
            update  objSetting;   
        }    
    }

    public static Sync_Master__c doGetSyncMaster(String syncMasterId){
        Sync_Master__c objSyncMaster;
        if (Schema.sObjectType.Sync_Master__c.isAccessible() &&
            Schema.sObjectType.Sync_Master__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Sync_Master__c.fields.Campaign__c.isAccessible() &&
            Schema.sObjectType.Sync_Master__c.fields.Group_Id__c.isAccessible() &&
            Schema.sObjectType.Sync_Master__c.fields.Processed_Members__c.isAccessible() &&
            Schema.sObjectType.Sync_Master__c.fields.Total_Memerbs_Count__c.isAccessible() &&
            Schema.sObjectType.Sync_Master__c.fields.Sync__c.isAccessible() &&
            Schema.sObjectType.Sync_Master__c.fields.Can_ReSync__c.isAccessible() &&
            Schema.sObjectType.Sync_Master__c.fields.Total_Memerbs_Count_RollUp__c.isAccessible()) {

            List<Sync_Master__c> listOfSyncMasters = [Select Id, CreatedDate, Campaign__c,Group_Id__c,Processed_Members__c,Total_Memerbs_Count__c,Sync__c, Can_ReSync__c,Total_Memerbs_Count_RollUp__c from Sync_Master__c where Id=:syncMasterId WITH SECURITY_ENFORCED];
            if(!listOfSyncMasters.isEmpty()){
                objSyncMaster = listOfSyncMasters.get(0);
            }
        }
        return objSyncMaster;
    }

    public static Sync__c doGetSyncRecord(String syncId){
        List<Sync__c> listOfSync = new List<Sync__c>();
        Sync__c objSync;
        //if(Schema.sObjectType.Sync__c.isAccessible()){
        if (Schema.sObjectType.Sync__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Name.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Leads_SOQL__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Group_Id__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Scheduled_Daily_At__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Contacts_SOQL__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Last_JobId__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Last_JobName__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Contacts__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Leads__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Dont_Delete_Existing_Contacts__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Contact_View__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Lead_View__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Is_Created_By_View__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Account__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Group_Name__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Is_Created_By_Report__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Contact_Report__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Lead_Report__c.isAccessible() &&
            Schema.sObjectType.Account__c.isAccessible() ) {

            listOfSync = [Select Id, Name,Leads_SOQL__c,Group_Id__c,Scheduled_Daily_At__c,Contacts_SOQL__c,Last_JobId__c, Last_JobName__c,Contacts__c,Leads__c,Dont_Delete_Existing_Contacts__c,Contact_View__c, Lead_View__c,Is_Created_By_View__c,Account__c,Account__r.Name,Group_Name__c,Is_Created_By_Report__c,Contact_Report__c,Lead_Report__c from Sync__c where Id=:syncid WITH SECURITY_ENFORCED LIMIT 1];
        }
        if(!listOfSync.isEmpty()){
            objSync = listOfSync.get(0);
        }
        return objSync;
    }

    /*@future(callout=true)
    public static void inwiseAutomation(String syncId){
		
        if(String.isNotBlank(syncId)){
            Landing_Sync__c objSync = [SELECT Id,Name,Account__c,Landing_Page_Id__c From Landing_Sync__c WHERE Id =: syncId AND Account__c != null];
            
            if(objSync != null && Schema.sObjectType.Account__c.isAccessible()){
                
                System.debug(objSync.Account__c);                    
                Account__c acc = [Select Id From Account__c where Id =: objSync.Account__c LIMIT 1];
                
                if(acc != null){
                    HttpResponse res;
                    Http http = new Http();
                    inwiseUtil util = new inwiseUtil(acc);
                    List<Logs__c> listOfLogs = new List<Logs__c>();
                    
                    HttpRequest req = util.GetHTTPRequest('POST', 'application/json', util.apiUrl + '/rest/v1/automations');
                    String reqBody = '{"version": 4.0,"automation": {"name": "' + objSync.Name + '","description": "created by Salesforce","is_active": false,"version": 4,"tags": ["salesforce"],"rules": [{"additional_settings": {"trigger_settings": {"trigger_type": "MakeContactForm","owner_id": "' + objSync.Landing_Page_Id__c + '","owner_type": "Form"}},"name": "start - rule 1 - filled form","rule_type": "StartPoint","is_active": true,"rules_after_match": ["rule2 - webhook"]},{"rule_type": "Action","name": "rule2 - webhook","is_active": true,"additional_settings": {"action_settings": {"action_type": "NotifyWebPage","webhook_uri":"' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/leadsRestApi/"}}}]}}';
                    req.setHeader('X-Api-Key', util.objInwiseAccount.Token__c);
                    req.setBody(reqBody);
                    
                    if(!Test.isRunningTest()){
                        res = http.send(req);
                        listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/automations', 'inwiseUtil', 'inwiseAutomation'));        
                    }else{
                        res = new HttpResponse();
                        res.setHeader('Content-Type', 'application/json');
                        String resBody = '{"version": 4.0,"automation": {"name": "sync name","description": "created by Salesforce","is_active": false,"version": 4,"tags": ["salesforce"],"rules": [{"additional_settings": {"trigger_settings": {"trigger_type": "MakeContactForm","owner_id": "61714","owner_type": "Form"}},"name": "start - rule 1 - filled form","rule_type": "StartPoint","is_active": true,"rules_after_match": ["rule2 - webhook"]},{"rule_type": "Action","name": "rule2 - webhook","is_active": true,"additional_settings": {"action_settings": {"action_type": "NotifyWebPage","webhook_uri":"' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/leadsRestApi/"}}}]}}';
                        res.setBody(resBody);
                        res.setStatusCode(200);
                        res.setStatus('OK');
                    }
                    
                    System.debug('res.getStatusCode()::-->>' + res.getStatusCode());
                    if(res.getStatusCode() == 200 && res.getBody() != NULL){ 
                        String jsonString = res.getBody();  //'[{"id":4,"description":"Code","slicing":false,"type":"text"},{"id":2,"description":"Lname","slicing":false,"type":"text"},{"id":1,"description":"Fname","slicing":false,"type":"text"},{"id":3,"description":"Gender","slicing":true,"type":"text"}]';
                        System.debug('Response body::-->>  ' + jsonString);
                    }
                    
                    if(util.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                        insert listOfLogs;
                    }
                }
            }
        }
    }
    
    public static void executeLandingSync(String syncId){
        List<Landing_Sync__c> listOfSync = inwiseLandingSyncSchedular.getSyncRecord(syncId);
        if(!listOfSync.isEmpty()){
            inwiseLandingSyncSchedular.InwiseCalloutLandingSync(listOfSync);
        }
    }*/
    
    public static MetadataService.MetadataPort createMetadataService(){
        System.debug('==createMetadataService=');
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        
        String sessionId = getAccessTokenFromMetadata();  
        if (sessionId != null && sessionId != '' && isAccessToken) {
            service.SessionHeader.sessionId = sessionId;
        } 
        return service;
    }

    public static String getAccessTokenFromMetadata() {

        Settings__c objInwiseSettingLocal = Settings__c.getAll().get('default');

        try {

            // Fetch the custom metadata record
            // List<Salesforce_Credential__mdt> listOfSalesforceOrgCredential = [SELECT Client_Id__c, Client_Secret__c, Username__c, Password__c, Login_URL__c FROM Salesforce_Credential__mdt
            //                                                                 WHERE DeveloperName = 'defaultSF' LIMIT 1];

            // if (listOfSalesforceOrgCredential.isEmpty()) {  
            //     isAccessToken = false;   
            //     Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord('Please create a custom metadata record with developer name "defaultSF" and save the credentials there', 'inwiseUtil', 'getAccessTokenFromMetadata');
            //     if(errorLog != null && objInwiseSettingLocal.Track_Errors__c){
            //         insert errorLog;
            //     }
            //     return 'Please create a custom metadata record with developer name "default" and save the credentials there.';
            // } 

            // // Endpoint URL for the OAuth token request
            // String tokenEndpoint = listOfSalesforceOrgCredential[0].Login_URL__c + '/services/oauth2/token';

            // Prepare the HTTP request
            HttpRequest req = new HttpRequest();
            //req.setEndpoint(tokenEndpoint);
            req.setEndpoint('callout:inwise__GetSFAccessTokenNamed?grant_type=client_credentials');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

            // Prepare the body with the required parameters
            // String requestBody = 'grant_type=password'
            //     + '&client_id=' + EncodingUtil.urlEncode(listOfSalesforceOrgCredential[0].Client_Id__c, 'UTF-8')
            //     + '&client_secret=' + EncodingUtil.urlEncode(listOfSalesforceOrgCredential[0].Client_Secret__c, 'UTF-8')
            //     + '&username=' + EncodingUtil.urlEncode(listOfSalesforceOrgCredential[0].Username__c, 'UTF-8')
            //     + '&password=' + EncodingUtil.urlEncode(listOfSalesforceOrgCredential[0].Password__c, 'UTF-8');
            // req.setBody(requestBody);

            // Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);

            // Check the response status and parse the access token
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                if (responseMap.containsKey('access_token')) {
                    return (String) responseMap.get('access_token');
                } else {
                    system.debug('Access token not found in response: ' + res.getBody());
                    return res.getBody();
                }
            } else {
                isAccessToken = false; 
                Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(res.getStatusCode() +'--'+res.getBody(), 'inwiseUtil', 'getAccessTokenFromMetadata');
                if(errorLog != null && objInwiseSettingLocal.Track_Errors__c){
                    insert errorLog;
                }
                system.debug('Failed to get access token. Status: ' + res.getStatusCode() + '. Response: ' + res.getBody());
                return res.getBody();
            }
        } catch (Exception ex) {
            isAccessToken = false; 
            System.debug('Error while getting access token: ' + ex.getMessage());
            Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'inwiseUtil', 'getAccessTokenFromMetadata');
            if(errorLog != null && objInwiseSettingLocal.Track_Errors__c){
                insert errorLog;
            }
            return ex.getMessage();
        }
    }
     
    // Encrypt the token using AES with a managed IV (initialization vector)
    // public static String encryptToken(String token) {
    //     Blob key ;
    //     Token_Setting__c objTokenSet = Token_Setting__c.getAll().get('default');
        
    //     if(objTokenSet.Encryption_Key__c != null && Schema.sObjectType.Token_Setting__c.isAccessible()){
    //         key = Blob.valueOf(objTokenSet.Encryption_Key__c);
    //     }
    //     Blob tokenBlob = Blob.valueOf(token);  // Convert the token to Blob
    //     Blob encryptedBlob = Crypto.encryptWithManagedIV('AES128', key, tokenBlob);  // Encrypt with AES128
    //     return EncodingUtil.base64Encode(encryptedBlob);  // Return the encrypted token as a Base64 string
    // }

    // Decrypt the token
    // public static String decryptToken(String encryptedToken) {
    //     try{
    //         Blob key ;
    //         Token_Setting__c objTokenSet = Token_Setting__c.getAll().get('default');
    //         if(objTokenSet.Encryption_Key__c != null && Schema.sObjectType.Token_Setting__c.isAccessible()){
    //             key = Blob.valueOf(objTokenSet.Encryption_Key__c);
    //         }
            
    //         Blob encryptedBlob = EncodingUtil.base64Decode(encryptedToken);  // Decode the Base64 string
    //         Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', key, encryptedBlob);  // Decrypt with AES128
    //         System.debug('Token decrypted successfully.');
    //         return decryptedBlob.toString();  // Convert Blob back to a string
    //     } catch(Exception ex){
    //         return null;
    //     }
    // }


    public static void createOrUpdateTokenSetting(Account__c inwiseAcc, String token) {
        try {
            // Query the custom setting to check for an existing record with the given Account Id
            List<Token_Setting__c> existingSettings = [ SELECT Id, Account_Id__c, Token__c FROM Token_Setting__c 
                                                        WHERE Account_Id__c =: inwiseAcc.Id WITH SECURITY_ENFORCED LIMIT 1];

            // If a matching record is found, update the token
            if (existingSettings.size() > 0 && Schema.sObjectType.Token_Setting__c.isCreateable() && Schema.sObjectType.Token_Setting__c.isUpdateable()) { 
                if(Schema.sObjectType.Token_Setting__c.fields.Token__c.isUpdateable() && Schema.sObjectType.Token_Setting__c.fields.Token__c.isCreateable()){
                    existingSettings[0].Token__c = token ;//encryptToken(token);
                }
                if(Schema.sObjectType.Token_Setting__c.isCreateable() && Schema.sObjectType.Token_Setting__c.isUpdateable()){
                    update existingSettings;
                }
                

                //return 'Successfully';
            } else {
                // No record found, create a new record 
                if(Schema.sObjectType.Token_Setting__c.isCreateable()){
                    Token_Setting__c newSetting = new Token_Setting__c();
                    if(Schema.sObjectType.Token_Setting__c.fields.Name.isCreateable()){
                        newSetting.Name = inwiseAcc.Name + ' - Setting';
                    }

                    if(Schema.sObjectType.Token_Setting__c.fields.Account_Id__c.isCreateable()){
                        newSetting.Account_Id__c = inwiseAcc.Id;
                    }

                    if(Schema.sObjectType.Token_Setting__c.fields.Token__c.isCreateable()){
                        newSetting.Token__c = token;//encryptToken(token);
                    }

                    if(Schema.sObjectType.Token_Setting__c.isCreateable()){
                        insert newSetting;
                    }
                    

                    //return 'Successfully';
                }
            }
            //return 'Successfully';

        } catch (Exception ex) {
            // Handle unexpected exceptions
            System.debug('Error while processing token setting: ' + ex.getMessage());
            //throw new AuraHandledException('Failed to process token setting: ' + ex.getMessage());
            //apexpages.addmessage(new apexpages.message(apexpages.severity.Error, ex.getMessage())); 
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            //return ex.getMessage();

            //createOrUpdateTokenSetting
        }
    }

    /**
     * Validates if the URL is a safe redirect target.
     * Allows only URLs within the current Salesforce domain.
    */
    public static Boolean isValidRedirectUrl(String rURL) {
        // Get the current Salesforce domain
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        //System.debug('==baseUrl='+baseUrl);

        // Check if the URL starts with the Salesforce domain
        return rURL != null && rURL.startsWith(baseUrl);
    }

    public PageReference gotoHome(){
        PageReference pr = Page.inwiseHome;
        pr.setRedirect(true);
        return pr;
    }

    // Generate a CSRF Token
    public static String generateCSRFToken() {
        // Generate a random long and encode it in Base64
        String randomLongString = String.valueOf(Crypto.getRandomLong());
        return EncodingUtil.base64Encode(Blob.valueOf(randomLongString)); // Encode as Base64
    }

    // Validate CSRF Token (Simple example, implement as per your requirements)
    public static Boolean validateCSRFToken(String clientToken) {
        // Add custom validation logic, e.g., compare with a stored token
        return clientToken != null && clientToken.length() > 0;
    }

    public static String getTokenToAccId(String accId){
        String returnToken = '';
        if(Schema.sObjectType.Token_Setting__c.isAccessible()) {
            
            List<Token_Setting__c> existingSettings = [SELECT Id, Account_Id__c, Token__c FROM Token_Setting__c WHERE Account_Id__c = : accId WITH SECURITY_ENFORCED LIMIT 1];
            if(existingSettings.size() > 0){
                // String strToken = existingSettings[0].Token__c;//decryptToken(existingSettings[0].Token__c);
                // if(strToken == null){
                //     returnToken = existingSettings[0].Token__c;
                // } else {
                //     returnToken = strToken;
                // }
                if(existingSettings[0].Token__c != null){
                    returnToken = existingSettings[0].Token__c;
                }
            }
            
        }
        return returnToken;
    }

    // public static Token_Setting__c getTokenSettingRecordToAccId(String accId){
    //     Token_Setting__c returnTokenSettingRec = new Token_Setting__c();
    //     if(Schema.sObjectType.Token_Setting__c.isAccessible()) {
            
    //         List<Token_Setting__c> existingSettings = [SELECT Id, Account_Id__c, Token__c FROM Token_Setting__c WHERE Account_Id__c = : accId WITH SECURITY_ENFORCED LIMIT 1];
    //         if(existingSettings.size() > 0){
    //             if(existingSettings[0].Token__c != null){
    //                 returnTokenSettingRec = existingSettings[0];
    //             }
    //         }
            
    //     }
    //     return returnTokenSettingRec;
    // }

    public void getAllTokenByAcc(){

        if(Schema.sObjectType.Token_Setting__c.isAccessible()) {  
            //Set<String> accIdSet = new Set<String>();
            accIdWithTokenMap = new Map<String, String>();
            List<Token_Setting__c> existingSettings = [SELECT Id, Account_Id__c, Token__c FROM Token_Setting__c WITH SECURITY_ENFORCED LIMIT 49999];
            for(Token_Setting__c tokenSetting : existingSettings){
                //if(setting.Token__c != null || setting.Token__c != ''){
                    // String strToken = decryptToken(setting.Token__c);
                    // if(strToken == null){
                    //     //returnToken = setting.Token__c;
                    //     accIdWithTokenMap.put(setting.Account_Id__c, setting.Token__c);
                    // } else {
                    //     //returnToken = strToken;
                    //     accIdWithTokenMap.put(setting.Account_Id__c, strToken);
                    // }
                // } else {
                //     accIdSet.add(setting.Account_Id__c);
                // }

                if(tokenSetting.Token__c != null){
                    accIdWithTokenMap.put(tokenSetting.Account_Id__c, tokenSetting.Token__c);
                }
            }
        }
    }


    public class JSON2ApexOauthResponse {
        public String access_token{get;set;}
        public String token_type{get;set;}
        public Integer expires_in{get;set;}
    }

    public class WrapperStatus{
        public Boolean isSuccess{get;set;}
        public String msg{get;set;}
    }
}