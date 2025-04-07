/*
*Created By: Kapil Goutam
*Created On: Oct 21, 2018
*Purpose : class coped from inwiseScheduleSyncController & will provide view based sync creation
================================================================
Modified On Version Modified By Purpose
================================================================
12/04/2021 1.1.0 NLINEAXIS(Kapil Goutam) Modified:- Show account list on page from 'Account_SalesforceUser_Mapping__c' according to user
05/06/2021 1.2.0 NLINEAXIS(S. V.) Modified:- Used try catch block to fix order by name issue (encrypted field)
05/06/2021 1.3.0 NLINEAXIS(S. V.) Modified:- Removed try catch block where we used to fix order by name issue (encrypted field)
07/06/2021 1.4.0 NLINEAXIS(S. V.) Modified:- Added new method checkFieldIsEncrypted to check encrypted field and fix the order by name issue (encrypted field)
09/06/2021 1.5.0 NLINEAXIS(S. V.) Modified:- API version and Organization base url getting from the inwiseConstants class
06/28/2021 1.6.0 NLINEAXIS(Kapil Goutam)     Modified:- Added system admin should be able to see all options (Show all account picklist value for system admin)
06/20/2024 1.7.0 NLINEAXIS(Kapil Goutam)     Modified:- Added changes for security check (added method encodeForHTML)
*/
public with sharing class ScheduleSyncViewController {
    
    public inwiseScheduleSyncController.WrapperSync objWrapperSync{get;set;} 
    InwiseUtil objInwiseUtil{get;set;}
    public List<SelectOption> listOfSelectOptionGroups{get;set;}
    public List<SelectOption> listOfSelectOptionAccounts{get;set;}
    public Map<String,String> mapOfGroup{get;set;}//id is a string here not sure about the length
    public inwiseLtngConstants objinwiseLtngConstants{get;set;}
    public String strGroupName{get;set;}
    public Map<Id,Account__c> mapOfAccounts{get;set;}
    public List<SelectOption> listOfViewType{get;set;}
    public String selectedViewType{get;set;}
    public List<SelectOption> listOfAvailableView{get;set;}
    public String selectedView{get;set;}
    public ApexPages.StandardSetController objStdSetControllerContact{get;set;}
    public ApexPages.StandardSetController objStdSetControllerLead{get;set;}
    public List<WrapperResult> listOfWrapperResult{get;set;}
    public Decimal iTotalCount{get;set;}
    public Boolean isGroupCallout = false;
    public String groupReq;
    public String groupRes;
    
    public String MSG_SYNC_CHECKBOX{get{
        return inwiseConstants.MSG_SYNC_CHECKBOX;
    }}
    public boolean notAnyDefaultAcc;
    public Boolean isAdminUser ;
    public String userProfileName ;
    
    public ScheduleSyncViewController(ApexPages.StandardController stdConntroller) {
        
        if(ApexPages.currentPage().getParameters().get('sid') != NULL){
            objWrapperSync = new inwiseScheduleSyncController.WrapperSync(ApexPages.currentPage().getParameters().get('sid'));
        }else{
            objWrapperSync = new inwiseScheduleSyncController.WrapperSync();
        }
        
        objinwiseLtngConstants = new inwiseLtngConstants();
        listOfSelectOptionGroups = new List<SelectOption>();
        listOfSelectOptionAccounts = new List<SelectOption>();
        isAdminUser = true;
        mapOfGroup = new Map<String,String>();
        objWrapperSync.Step1 = true;
        objWrapperSync.currentStep = objWrapperSync.CONS_STEP1;
        objWrapperSync.Step2 = objWrapperSync.Step3 = false;
        objWrapperSync.isCanProceed = true;
        notAnyDefaultAcc = true;
        
        if (Schema.sObjectType.Account__c.isAccessible() &&
            Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
            Schema.sObjectType.Account__c.fields.Default__c.isAccessible() &&
            Schema.sObjectType.Account__c.fields.Token__c.isAccessible()) {

            mapOfAccounts = new Map<Id,Account__c>([Select Id,Name,Default__c, Token__c from Account__c LIMIT 1000]);
        }
        
        if (Schema.sObjectType.Profile.isAccessible() &&
            Schema.sObjectType.Profile.fields.Name.isAccessible()) {

            userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
        }
        List<String> listOfFinalUserProfileName = new List<String>(); 
        for(Setting__mdt customMetadataObj : [SELECT Id, MasterLabel, DeveloperName, Setting_Value__c FROM Setting__mdt WHERE MasterLabel = 'System Admin Profile' LIMIT 10000]) {
            System.debug('==customMetadataObj=='+customMetadataObj);
            listOfFinalUserProfileName.add(customMetadataObj.Setting_Value__c); 
        }
        isAdminUser = listOfFinalUserProfileName.contains(userProfileName); 
        if(isAdminUser) {
            if (Schema.sObjectType.Account__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Name.isAccessible()) {

                for(Account__c acc : [SELECT Id, Name FROM Account__c ORDER BY Name ASC LIMIT 49999]){
                    listOfSelectOptionAccounts.add(new SelectOption(acc.Id,acc.Name));
                }
            }
            if(objWrapperSync.selectedAccount == NULL){
                if (Schema.sObjectType.Account__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Default__c.isAccessible()) {

                    List<Account__c> listOfAccLocal = [SELECT Id, Name, Default__c FROM Account__c WHERE Default__c = true LIMIT 1];
                    if(listOfAccLocal.size() > 0){
                        objWrapperSync.selectedAccount = listOfAccLocal[0].Id;
                        notAnyDefaultAcc = false;
                    } 
                }
            }
        }else {
            if (Schema.sObjectType.Account_SalesforceUser_Mapping__c.isAccessible() &&
                Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.Account__c.isAccessible() &&
                Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isAccessible() &&
                Schema.sObjectType.Account__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Default__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Token__c.isAccessible()) {

                List<Account_SalesforceUser_Mapping__c> listofAccountUsers = [SELECT Id, Account__c, User__c,Account__r.name,Account__r.Default__c,Account__r.Token__c FROM Account_SalesforceUser_Mapping__c where User__c =: UserInfo.getUserId() ] ;
                if(!listofAccountUsers.isEmpty()){
                    for(Account_SalesforceUser_Mapping__c a:listofAccountUsers){
                        listOfSelectOptionAccounts.add(new SelectOption(a.Account__c,a.Account__r.name));
                        if(a.Account__r.Default__c && objWrapperSync.selectedAccount == NULL){
                            objWrapperSync.selectedAccount = a.Account__c;
                            notAnyDefaultAcc = false;
                        }
                    }
                    if(notAnyDefaultAcc && objWrapperSync.selectedAccount == NULL) {
                        objWrapperSync.selectedAccount = listofAccountUsers[0].Account__c;
                    }
                }
            }
        }
        
        listOfViewType = new List<SelectOption>();
        listOfViewType.add(new SelectOption('','--None--'));
        listOfViewType.add(new SelectOption(inwiseConstants.SOBJECT_CONTACT,inwiseConstants.SOBJECT_CONTACT));
        listOfViewType.add(new SelectOption(inwiseConstants.SOBJECT_LEAD,inwiseConstants.SOBJECT_LEAD));
        listOfAvailableView = new List<SelectOption>();
        listOfAvailableView.add(new SelectOption('','--Select View--'));

        if(Schema.sObjectType.Contact.isAccessible() ){
            String query = 'SELECT Name FROM Contact LIMIT 1';
            objStdSetControllerContact = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        }

        if(Schema.sObjectType.Lead.isAccessible() ){
            String query = 'SELECT Name FROM Lead LIMIT 1';
            objStdSetControllerLead = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        }
        listOfWrapperResult = new List<WrapperResult>();
        //this should be after intialize standard controller
        System.debug('objWrapperSync.objSync.Is_Created_By_View__c::-->>>' + objWrapperSync.objSync.Is_Created_By_View__c);
        if(objWrapperSync.objSync.Is_Created_By_View__c){
            if(objWrapperSync.objSync.Contacts__c && objWrapperSync.objSync.Contact_View__c != NULL){
                selectedViewType = InwiseConstants.SOBJECT_CONTACT;
                doLoadViews();
                selectedView = objWrapperSync.objSync.Contact_View__c;
                System.debug('selectedView67::-->>>' + selectedView);
            }else if(objWrapperSync.objSync.Leads__c && objWrapperSync.objSync.Lead_View__c != NULL){
                selectedViewType = InwiseConstants.SOBJECT_LEAD;
                doLoadViews();
                selectedView = objWrapperSync.objSync.Lead_View__c;
                System.debug('selectedView72::-->>>' + selectedView);
            }
        }
    }
    
    public void init(){
        if(objWrapperSync.selectedAccount != NULL){
            getInwiseGroups();
        } 
    }
    
    public void doLoadViews(){
        
        listOfAvailableView = new List<SelectOption>();
        
        String query = '';
        System.debug('selectedViewType::-->>>' + selectedViewType);
        System.debug('objStdSetControllerContact::-->>>' + objStdSetControllerLead.getListViewOptions());
        if(selectedViewType == inwiseConstants.SOBJECT_CONTACT){
            listOfAvailableView.add(new SelectOption('','--Select Contact View--'));
            listOfAvailableView.addAll(objStdSetControllerContact.getListViewOptions());
        }else if(selectedViewType == inwiseConstants.SOBJECT_LEAD){
            listOfAvailableView.add(new SelectOption('','--Select Lead View--'));
            listOfAvailableView.addAll(objStdSetControllerLead.getListViewOptions());
        }else {
            listOfAvailableView.add(new SelectOption('','--Select View--'));
        }
        System.debug('listOfAvailableView::-->>>' + listOfAvailableView);
        
    }
    
    public Integer doCreateGroup(String groupname,List<Logs__c> listOfLogs){
        
        Http http = new Http();
        HttpResponse res;
        integer grpId = 0;
        boolean isSuccess = false;
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contactsGroups/externalAppGeneric?group_name='+ EncodingUtil.urlEncode(groupname,'utf-8'); 
        HttpRequest req = objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint); 
        req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken); 
        req.setBody('');//set blank body
        
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups/externalAppGeneric','ScheduleSyncViewController','doCreateGroup'));
            }else{
                String resBody = '{"group_id": "642084"}'; 
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'text/xml');
            }
            if(!String.isEmpty(res.getBody())){
                if(res.getStatusCode() == 200){
                    SendToInwiseController.JSON2ApexGroupId objJSON2ApexGroupId = (SendToInwiseController.JSON2ApexGroupId)JSON.deserialize(res.getBody(), SendToInwiseController.JSON2ApexGroupId.class); 
                    grpId = Integer.valueOf(objJSON2ApexGroupId.group_id);
                }else{
                    String msg = res.getBody().replace('"','');
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error,msg)); 
                }
            }
        }catch(Exception ex){
            //ErrorMsg = 'Exception! -' + ex.getMessage(); 
        } 
        return grpId;
    }
    
    public PageReference nextStep(){
        PageReference pr;
        List<Logs__c> listOfLogs = new List<Logs__c>();
        System.debug('strGroupName::-->>>' + strGroupName + '>objWrapperSync.selectedGroup>>' + objWrapperSync.selectedGroup);
        if(String.isEmpty(objWrapperSync.selectedGroup) && String.isEmpty(strGroupName)){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error, InwiseConstants.MSG_SELECT_OR_CREATE_GROUP)); 
            return pr;
        }
        if(selectedViewType == NULL || selectedView == NULL){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,inwiseConstants.MSG_SELECT_VIEW)); 
            return pr; 
        }
        objWrapperSync.selectedGroupName = mapOfGroup.get(objWrapperSync.selectedGroup);
        System.debug('objWrapperSync.currentStep::-->>' + objWrapperSync.currentStep);
        System.debug('objWrapperSyncselectedGroup-->>' +objWrapperSync.selectedGroup + '--->>' +strGroupName + '\\\\\\\\\\' + objWrapperSync.objSync.Name);
        if(objWrapperSync.currentStep == objWrapperSync.CONS_STEP1){ 
            if(!String.ISBLANK(objWrapperSync.objSync.Name)){
                if(String.isEmpty(objWrapperSync.selectedGroup) && !String.isEmpty(strGroupName)){
                    Integer grpid = doCreateGroup(strGroupName,listOfLogs);
                    System.debug('grpid::-->>' + grpid);
                    if(grpid != 0){
                        objWrapperSync.selectedGroup = String.valueOf(grpid);
                        objWrapperSync.selectedGroupName = strGroupName;
                        init();//to reload groups in list box
                        if(isGroupCallout){
                            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(groupReq, groupRes,'/rest/v1/contactsGroups','ScheduleSyncViewController','getInwiseGroups'));
                        }
                        if(!mapOfGroup.isEmpty()){
                            objWrapperSync.isCanProceed = true;
                        }
                        
                    }else{
                        
                        return null;
                    }
                } 
                
                listOfWrapperResult = new List<WrapperResult>();
                iTotalCount = 0;
                Set<Id> allSelectedIds = new Set<Id>();
                ApexPages.StandardSetController objStdSetController;
                
                if(selectedViewType == inwiseConstants.SOBJECT_CONTACT){
                    List<String> errorLi = checkFieldIsEncrypted(inwiseConstants.SOBJECT_CONTACT, selectedView);
                    if(errorLi[0] == 'true'){
                        apexpages.addmessage(new apexpages.message(apexpages.severity.Error, Label.Encrypted_Field_Error));
                        Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(Label.Encrypted_Field_Error, 'ScheduleSyncViewController', 'nextStep');
                        if(errorLog != null){
                            insert errorLog;
                        }
                        return pr;
                    }
                    else{
                        if(String.isBlank(errorLi[1])){
                            objStdSetControllerContact.setFilterId(selectedView);
                            objStdSetController = objStdSetControllerContact;
                        }
                        else{
                            apexpages.addmessage(new apexpages.message(apexpages.severity.Error, errorLi[1]));
                            return pr;
                        }
                    }
                }
                else if(selectedViewType == inwiseConstants.SOBJECT_LEAD){
                    List<String> errorLi = checkFieldIsEncrypted(inwiseConstants.SOBJECT_LEAD, selectedView);
                    if(errorLi[0] == 'true'){
                        apexpages.addmessage(new apexpages.message(apexpages.severity.Error, Label.Encrypted_Field_Error));
                        Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(Label.Encrypted_Field_Error, 'ScheduleSyncViewController', 'nextStep');
                        if(errorLog != null){
                            insert errorLog;
                        }
                        return pr;
                    }
                    else{
                        if(String.isBlank(errorLi[1])){
                            objStdSetControllerLead.setFilterId(selectedView);
                            objStdSetController = objStdSetControllerLead;
                        }
                        else{
                            apexpages.addmessage(new apexpages.message(apexpages.severity.Error, errorLi[1]));
                            return pr;
                        }
                    }
                }

                if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                    insert listOfLogs;
                }
                
                objWrapperSync.currentStep = objWrapperSync.CONS_STEP2;
                objWrapperSync.Step2 = true;
                objWrapperSync.Step1 = false;
                
                objStdSetController.first();
                objStdSetController.setPageSize(1000);
                iTotalCount = objStdSetController.getResultSize();
                boolean hasNext = iTotalCount > 0 ? true : false;
                System.debug('objStdSetController size::-->>' + iTotalCount);
                while(hasNext){
                    allSelectedIds.addAll(new Map<Id, sObject>(objStdSetController.getRecords()).keySet());
                    hasNext = objStdSetController.getHasNext();
                    objStdSetController.next();
                }
                System.debug('allSelectedIds::-->>>' + allSelectedIds);
                if(!allSelectedIds.isEmpty()){
                    if(selectedViewType == inwiseConstants.SOBJECT_CONTACT){
                        if (Schema.sObjectType.Contact.isAccessible() &&
                            Schema.sObjectType.Contact.fields.Id.isAccessible() &&
                            Schema.sObjectType.Contact.fields.Name.isAccessible()) {

                            List<Contact> listOfContact = [Select Id,Name from Contact where Id IN:allSelectedIds LIMIT 10];
                            if(!listOfContact.isEmpty()){
                                for(Contact c: listOfContact){
                                    listOfWrapperResult.add(new WrapperResult(c.Id, c.Name));
                                }
                            }
                        }
                    }else if(selectedViewType == inwiseConstants.SOBJECT_LEAD){

                        if (Schema.sObjectType.Lead.isAccessible() &&
                            Schema.sObjectType.Lead.fields.Id.isAccessible() &&
                            Schema.sObjectType.Lead.fields.Name.isAccessible()) {
                                
                            List<Lead> listOfLead = [Select Id,Name from Lead where Id IN:allSelectedIds LIMIT 10];
                            if(!listOfLead.isEmpty()){
                                for(Lead l: listOfLead){
                                    listOfWrapperResult.add(new WrapperResult(l.Id, l.Name));
                                }
                            }
                        }
                    }
                }
                
            }else {
                apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Required field Sync Name should not be Blank'))); 
                return pr; 
            }
        }else if(objWrapperSync.currentStep == objWrapperSync.CONS_STEP2){
            if(selectedViewType == NULL || selectedView == NULL){
                apexpages.addmessage(new apexpages.message(apexpages.severity.Error,inwiseConstants.MSG_SELECT_VIEW)); 
                return pr; 
            }
            if(Schema.sObjectType.Sync__c.fields.Group_Name__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Group_Name__c.isUpdateable()){
                objWrapperSync.objSync.Group_Name__c = objWrapperSync.selectedGroupName;
            }
            if(Schema.sObjectType.Sync__c.fields.Account__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Account__c.isUpdateable()){
                objWrapperSync.objSync.Account__c = objWrapperSync.selectedAccount;
            }
            if(Schema.sObjectType.Sync__c.fields.Group_Id__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Group_Id__c.isUpdateable()){
                objWrapperSync.objSync.Group_Id__c = Integer.valueOf(objWrapperSync.selectedGroup);
            }
            if(Schema.sObjectType.Sync__c.fields.Is_Created_By_View__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Is_Created_By_View__c.isUpdateable()){
                objWrapperSync.objSync.Is_Created_By_View__c = true;
            }
            if(selectedViewType == inwiseConstants.SOBJECT_CONTACT){
                if(Schema.sObjectType.Sync__c.fields.Contact_View__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Contact_View__c.isUpdateable()){
                    objWrapperSync.objSync.Contact_View__c = selectedView;
                }
                if(Schema.sObjectType.Sync__c.fields.Contacts__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Contacts__c.isUpdateable()){
                    objWrapperSync.objSync.Contacts__c = true;
                }
            }else if(selectedViewType == inwiseConstants.SOBJECT_LEAD){
                if(Schema.sObjectType.Sync__c.fields.Lead_View__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Lead_View__c.isUpdateable()){
                    objWrapperSync.objSync.Lead_View__c = selectedView;
                }
                if(Schema.sObjectType.Sync__c.fields.Leads__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Leads__c.isUpdateable()){
                    objWrapperSync.objSync.Leads__c = true;
                }
            }
            if(Schema.sObjectType.Sync__c.isUpdateable() && Schema.sObjectType.Sync__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Group_Name__c.isUpdateable()){
                upsert objWrapperSync.objSync;
            }
            
            pr = Page.inwiseHome;
            pr.setRedirect(true);
            
        }
        return pr;
    }
    
    public List<String> checkFieldIsEncrypted(String objectAPIName, String selectedListViewId){
        System.debug('==checkFieldIsEncrypted=');
        
        String errorMessage = '';
        String isEncrypted = 'false';
        //String isAccessTokenStr = 'true';
        
        if(String.isNotBlank(objectAPIName) && String.isNotBlank(selectedListViewId)){
            
            String orgAccessTokenStr = inwiseUtil.getAccessTokenFromMetadata();
            //System.debug('==orgAccessTokenStr='+orgAccessTokenStr);
            //System.debug('==inwiseUtil.isAccessToken='+inwiseUtil.isAccessToken);

            if(inwiseUtil.isAccessToken){

                String endPoinURL = inwiseConstants.ORGANIZATION_BASE_URL + '/services/data/v';
                //String endPoinURL =  '/services/data/v';
                endPoinURL += inwiseConstants.METADATA_API_VERSION + '/sobjects/' + objectAPIName + '/listviews/' + selectedListViewId + '/describe';
                
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint(endPoinURL);
                //req.setEndpoint('callout:MetadataServiceNamedCredForProduction' + endPoinURL); // Use Named Credential
                req.setHeader('Authorization', 'Bearer ' + orgAccessTokenStr);
                
                Http http = new Http();
                HTTPResponse response;
                
                try{
                    if(!Test.isRunningTest()){
                        response = http.send(req);
                    }else{
                        String resBody = '{"columns": [{"fieldNameOrPath": ".Name"}]}'; 
                        response = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/JSON');
                    }
                    
                    if(response.getStatusCode() == 200 && response.getBody() != null) {
                        Map<String, Object> tokenResponseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                        
                        if(tokenResponseMap.size() > 0 && tokenResponseMap.containsKey('columns')){
                            List<object> columnList = (List<object>)tokenResponseMap.get('columns');
                            
                            if(columnList.size() > 0){
                                Map<String, Object> objMap = (Map<String, Object>)columnList[0];
                                
                                if(objMap.size() > 0 && objMap.containsKey('fieldNameOrPath') && String.isNotBlank(objMap.get('fieldNameOrPath')+'')){
                                    
                                    String fieldName = objMap.get('fieldNameOrPath')+'';
                                    if(fieldName.endsWith('.Name')){
                                        if(fieldName.endsWith('__r.Name')){
                                            fieldName = fieldName.replace('__r.Name', '__c');
                                        }
                                        else{
                                            fieldName = fieldName.replace('.Name', 'Id');
                                        }
                                    }
                                    
                                    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap();
                                    if(fieldMap.size() > 0 && fieldMap.containsKey(fieldName) && fieldMap.get(fieldName) != null){
                                        
                                        Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
                                        if(fieldResult != null && fieldResult.isEncrypted()){
                                            isEncrypted = fieldResult.isEncrypted()+'';
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else{
                        errorMessage = response.getBody();
                    } 
                }
                catch(Exception exp){
                    errorMessage = exp.getMessage();
                }
            } else {
                errorMessage = 'Please check the Salesforce Named Credential - Get SF Access Token Named.';
                // Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord('Please check the "Salesforce Credential" metadata for the "defaultSF" record.', 'ScheduleSyncViewController', 'checkFieldIsEncrypted');
                // if(errorLog != null){
                //     insert errorLog;
                // }
            }
        }
        
        if(String.isNotBlank(errorMessage)){
            Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(errorMessage, 'ScheduleSyncViewController', 'checkFieldIsEncrypted');
            if(errorLog != null){
                insert errorLog;
            }
        }
        
        return new List<String>{isEncrypted, errorMessage};
    }
    
    public void getInwiseGroups(){
        System.debug('==objWrapperSync.selectedAccount=='+objWrapperSync.selectedAccount);
        List<Logs__c> listOfLogs = new List<Logs__c>();
        listOfSelectOptionGroups = new List<SelectOption>();
        listOfSelectOptionGroups.add(new SelectOption('','--None--'));
        mapOfGroup = new Map<String,String>();
        if(objWrapperSync.selectedAccount != NULL){
            objInwiseUtil = new InwiseUtil(new Account__c(Id=objWrapperSync.selectedAccount));
        }
        if(!objInwiseUtil.CheckIfCredentialExists()){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,InwiseConstants.INWISE_CREDENTIAL_MISSING)); 
            return;
        } 
        if(!objInwiseUtil.CheckIfMappingExists()){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,InwiseConstants.INWISE_ACCOUNT_MAPPING_MISSING)); 
            System.debug('listOfSelectOptionGroups::-->>>' + listOfSelectOptionGroups.size() + '>>>' + listOfSelectOptionGroups);
            return;
        }
        Http http = new Http();
        HttpResponse res;
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contactsGroups?create_date_from=2010-01-01&group_type=generic_push&order_by=id%20desc'; 
        HttpRequest req = objInwiseUtil.GetHTTPRequest('GET','application/json',endpoint); 
        if(objWrapperSync.selectedAccount != NULL && mapOfAccounts != NULL && mapOfAccounts.get(objWrapperSync.selectedAccount) != NULL){
            //req.setHeader('X-Api-Key',inwiseUtil.decryptToken(mapOfAccounts.get(objWrapperSync.selectedAccount).Token__c)); 
            String tokenFromSetting = inwiseUtil.getTokenToAccId(mapOfAccounts.get(objWrapperSync.selectedAccount).Id);
            req.setHeader('X-Api-Key',tokenFromSetting);
        }
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                isGroupCallout = true;
                groupReq = String.valueOf(req);
                String maxLengthMsg = '...data truncated for column';       
                if(req.getBody()  != NULL){
                    groupReq += '\n---------------------------------------------------------------------------------\n';
                    groupReq += req.getBody();
                    if(groupReq.length() > 131072){
                        groupReq = groupReq.subString(0,131000);
                        groupReq += maxLengthMsg;
                    }
                }
                groupRes = String.valueOf(res);
                if(res.getBody()  != NULL){
                    groupRes += '\n---------------------------------------------------------------------------------\n';
                    groupRes += res.getBody();
                    if(groupRes.length() > 131072){
                        groupRes = groupRes.subString(0,131000);
                        groupRes += maxLengthMsg;
                    }
                }
               // listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups','ScheduleSyncViewController','getInwiseGroups'));
            }else{
                String resBody = ' [ { "id": "653415", "name": "boaz20171020-9", "create_date": "2017-10-22", "group_type": "generic_push", "target_type": "group" }, { "id": "653414", "name": "boaz20171020-8", "create_date": "2017-10-22", "group_type": "generic_push", "target_type": "group" }, { "id": "653346", "name": "Campaign11Oct-32", "create_date": "2017-10-22", "group_type": "generic_push", "target_type": "group" }, { "id": "653345", "name": "Campaign11Oct-31", "create_date": "2017-10-22", "group_type": "generic_push", "target_type": "group" }, { "id": "653344", "name": "Campaign11Oct-30", "create_date": "2017-10-22", "group_type": "generic_push", "target_type": "group" }, { "id": "653343", "name": "Campaign11Oct-29", "create_date": "2017-10-22", "group_type": "generic_push", "target_type": "group" }, { "id": "653342", "name": "boaz20171020-7", "create_date": "2017-10-22", "group_type": "generic_push", "target_type": "group" }, { "id": "653341", "name": "boaz20171020-6", "create_date": "2017-10-22", "group_type": "generic_push", "target_type": "group" }, { "id": "653338", "name": "boaz20171020-5", "create_date": "2017-10-22", "group_type": "generic_push", "target_type": "group" }, { "id": "653337", "name": "boaz20171020-4", "create_date": "2017-10-21", "group_type": "generic_push", "target_type": "group" }, { "id": "653336", "name": "boaz20171020-3", "create_date": "2017-10-21", "group_type": "generic_push", "target_type": "group" }, { "id": "653335", "name": "Campaign11Oct-28", "create_date": "2017-10-21", "group_type": "generic_push", "target_type": "group" }, { "id": "653249", "name": "boaz20171020-2", "create_date": "2017-10-20", "group_type": "generic_push", "target_type": "group" }, { "id": "653229", "name": "boaz20171020", "create_date": "2017-10-20", "group_type": "generic_push", "target_type": "group" }, { "id": "652451", "name": "Campaign11Oct-27", "create_date": "2017-10-16", "group_type": "generic_push", "target_type": "group" }, { "id": "652423", "name": "Campaign11Oct-26", "create_date": "2017-10-16", "group_type": "generic_push", "target_type": "group" }, { "id": "652414", "name": "Campaign11Oct-25", "create_date": "2017-10-16", "group_type": "generic_push", "target_type": "group" }, { "id": "652409", "name": "Campaign11Oct-24", "create_date": "2017-10-16", "group_type": "generic_push", "target_type": "group" }, { "id": "652407", "name": "Campaign11Oct-23", "create_date": "2017-10-16", "group_type": "generic_push", "target_type": "group" }, { "id": "652401", "name": "Campaign11Oct-22", "create_date": "2017-10-16", "group_type": "generic_push", "target_type": "group" }, { "id": "652400", "name": "Campaign11Oct-21", "create_date": "2017-10-16", "group_type": "generic_push", "target_type": "group" }, { "id": "652074", "name": "ManyMembers29", "create_date": "2017-10-13", "group_type": "generic_push", "target_type": "group" }, { "id": "652073", "name": "boaz test 9", "create_date": "2017-10-13", "group_type": "generic_push", "target_type": "group" }, { "id": "652048", "name": "boaz test 8", "create_date": "2017-10-13", "group_type": "generic_push", "target_type": "group" }, { "id": "652047", "name": "boaz test 7", "create_date": "2017-10-13", "group_type": "generic_push", "target_type": "group" }, { "id": "652046", "name": "Campaign11Oct-20", "create_date": "2017-10-13", "group_type": "generic_push", "target_type": "group" }, { "id": "652045", "name": "boaz test 6", "create_date": "2017-10-13", "group_type": "generic_push", "target_type": "group" }, { "id": "652044", "name": "boaz test 5", "create_date": "2017-10-13", "group_type": "generic_push", "target_type": "group" }, { "id": "652043", "name": "ManyMembers28", "create_date": "2017-10-13", "group_type": "generic_push", "target_type": "group" }, { "id": "652018", "name": "boaz test 4", "create_date": "2017-10-12", "group_type": "generic_push", "target_type": "group" }, { "id": "652011", "name": "ManyMembers27", "create_date": "2017-10-12", "group_type": "generic_push", "target_type": "group" }, { "id": "652010", "name": "Campaign11Oct-19", "create_date": "2017-10-12", "group_type": "generic_push", "target_type": "group" }, { "id": "652009", "name": "ManyMembers25", "create_date": "2017-10-12", "group_type": "generic_push", "target_type": "group" }, { "id": "652008", "name": "ManyMembers24", "create_date": "2017-10-12", "group_type": "generic_push", "target_type": "group" }, { "id": "652007", "name": "ManyMembers23", "create_date": "2017-10-12", "group_type": "generic_push", "target_type": "group" }, { "id": "652006", "name": "Campaign11Oct-18", "create_date": "2017-10-12", "group_type": "generic_push", "target_type": "group" }, { "id": "652005", "name": "Campaign11Oct-17", "create_date": "2017-10-12", "group_type": "generic_push", "target_type": "group" }, { "id": "652004", "name": "Campaign11Oct-16", "create_date": "2017-10-12", "group_type": "generic_push", "target_type": "group" }, { "id": "651960", "name": "Campaign11Oct-15", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651954", "name": "Campaign11Oct-13", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651949", "name": "Campaign11Oct-12", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651941", "name": "Campaign11Oct-11", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651928", "name": "Campaign11Oct-10", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651927", "name": "Campaign11Oct-8", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651926", "name": "Campaign11Oct-7", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651920", "name": "Campaign11Oct-6", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651919", "name": "Campaign11Oct-4", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651918", "name": "Campaign11Oct-3", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651914", "name": "Campaign11Oct-2", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651913", "name": "Campaign11Oct-1", "create_date": "2017-10-11", "group_type": "generic_push", "target_type": "group" }, { "id": "651870", "name": "boaz test 3", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651854", "name": "ManyMembers22", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651853", "name": "ManyMembers21", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651852", "name": "ManyMembers20", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651849", "name": "ManyMembers19", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651848", "name": "ManyMembers18", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651847", "name": "ManyMembers17", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651846", "name": "ManyMembers16", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651844", "name": "ManyMembers15", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651833", "name": "ManyMembers14", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651832", "name": "ManyMembers13", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651831", "name": "ManyMembers12", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651830", "name": "ManyMembers11", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651829", "name": "ManyMembers10", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651824", "name": "ManyMembers9", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651822", "name": "ManyMembers8", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651820", "name": "ManyMembers7", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651819", "name": "ManyMembers6", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651818", "name": "ManyMembers5", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651817", "name": "ManyMembers4", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "651773", "name": "ManyMembers3", "create_date": "2017-10-10", "group_type": "generic_push", "target_type": "group" }, { "id": "646274", "name": "test campaign29Aug32", "create_date": "2017-08-29", "group_type": "generic_push", "target_type": "group" }, { "id": "646271", "name": "test campaign29Aug2", "create_date": "2017-08-29", "group_type": "generic_push", "target_type": "group" }, { "id": "646270", "name": "test campaign29Aug", "create_date": "2017-08-29", "group_type": "generic_push", "target_type": "group" }, { "id": "646264", "name": "test campaign29Aug3", "create_date": "2017-08-29", "group_type": "generic_push", "target_type": "group" }, { "id": "642838", "name": "test campaign03Aug3", "create_date": "2017-08-03", "group_type": "generic_push", "target_type": "group" }, { "id": "642821", "name": "test campaign03Aug2", "create_date": "2017-08-02", "group_type": "generic_push", "target_type": "group" }, { "id": "642820", "name": "test campaign03Aug1", "create_date": "2017-08-02", "group_type": "generic_push", "target_type": "group" }, { "id": "642819", "name": "test campaign03Aug", "create_date": "2017-08-02", "group_type": "generic_push", "target_type": "group" }, { "id": "642100", "name": "test campaign 28th July", "create_date": "2017-07-28", "group_type": "generic_push", "target_type": "group" }, { "id": "642089", "name": "test 43 newtest", "create_date": "2017-07-28", "group_type": "generic_push", "target_type": "group" }, { "id": "642084", "name": "test 43 new", "create_date": "2017-07-28", "group_type": "generic_push", "target_type": "group" }, { "id": "642080", "name": "Campaign28July11.14AM", "create_date": "2017-07-28", "group_type": "generic_push", "target_type": "group" }, { "id": "642075", "name": "Campaign28July11.05AM", "create_date": "2017-07-28", "group_type": "generic_push", "target_type": "group" }, { "id": "642073", "name": "Campaign28July10.46AM", "create_date": "2017-07-28", "group_type": "generic_push", "target_type": "group" }, { "id": "642071", "name": "Campaign28July10.28AM", "create_date": "2017-07-28", "group_type": "generic_push", "target_type": "group" }, { "id": "641996", "name": "boaz20170727", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641961", "name": "Campaign27 July04.50PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641959", "name": "Campaign27 July04.43PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641952", "name": "Campaign27 July02.28PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641947", "name": "Campaign27 July02.20PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641946", "name": "Campaign27 July02.15PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641933", "name": "Campaign27 July02.10PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641910", "name": "Campaign27 July10.52PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641909", "name": "Campaign27 July10.50PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641908", "name": "Campaign27 July10.40PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641899", "name": "Campaign27 July10.39PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641898", "name": "Campaign27 July10.35PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641892", "name": "Campaign27 July10.33PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" }, { "id": "641891", "name": "Campaign27 July10.30PM", "create_date": "2017-07-27", "group_type": "generic_push", "target_type": "group" } ]';
                    res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res != NULL){
                if(res.getStatusCode() == 200){ 
                    System.debug('res372::-->>' + res.getBody());
                    List<inwiseScheduleSyncController.JSON2ApexGroupList> listOfGroupList = (List<inwiseScheduleSyncController.JSON2ApexGroupList>) System.JSON.deserialize(res.getBody(), List<inwiseScheduleSyncController.JSON2ApexGroupList>.class);
                    if(!listOfGroupList.isEmpty()){
                        for(inwiseScheduleSyncController.JSON2ApexGroupList l:listOfGroupList){
                            listOfSelectOptionGroups.add(new SelectOption(l.id,l.name));
                            mapOfGroup.put(l.id,l.name);
                        }
                    }
                }else{
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error, res.getBody())); 
                    return;
                } 
            }
            
        }catch(Exception ex){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,ex.getMessage())); 
        }
         
    }
    
    public PageReference doPrevStep(){
        PageReference pr;
        objWrapperSync.currentStep = objWrapperSync.CONS_STEP1;
        objWrapperSync.Step2 = false;
        objWrapperSync.Step1 = true;
        return pr;
    }

    public PageReference doCancel(){
        PageReference pr;
       	String retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        if(retUrl != NULL && inwiseUtil.isValidRedirectUrl(retUrl)){
            pr = new PageReference(retUrl);
            pr.setRedirect(true);
        }else{
            return gotoHome();
        }
        return pr;
    }

    public PageReference gotoHome(){
        PageReference pr = Page.inwiseHome;
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference redirectToSyncWizard(){
        PageReference pr = Page.inwiseScheduleSync;
        pr.getParameters().put('retUrl', Page.inwiseHome.getUrl());
        pr.setRedirect(true);
        return pr;
    }
    
    public class WrapperResult{
        public String recordid{get;set;}
        public String recordname {get;set;}
        
        public WrapperResult(String recordid, String recordname){
            this.recordid = recordid;
            this.recordname =  ScheduleSyncViewController.encodeForHTML(recordname);
        }
    }
    
    public static string encodeForHTML(String input) {
        if (input == null) {
            return null;
        }
        return input.replace('&', '&amp;')
            .replace('<', '&lt;')
            .replace('>', '&gt;')
            .replace('"', '&quot;')
            .replace('"', '&#x27;')
            .replace('/', '&#x2F;');
    }
    
   
}