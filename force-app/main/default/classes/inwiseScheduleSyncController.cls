/*
*Created By:  Kapil Goutam
*Created On: Oct 18, 2016
*Purpose :     class will contains methods related to sync steps
adding autocomplete - http://jqueryui.com/autocomplete/#multiple
*Modified:   
================================================================
Modified On   Version   Modified By                Purpose
================================================================
22/03/2021    1.1.0  NLINEAXIS(Kapil Goutam)     Modified:- Added ownerid filter for Inwise Account.
06/28/2021    1.1.1  NLINEAXIS(Kapil Goutam)     Modified:- Added system admin should be able to see all options (Show all account picklist value for system admin)
10/04/2024    1.1.2  NLINEAXIS(Seema Kanwar)     Modified:- Added decryptToken Method
/******************************************************************************************/
public with sharing class inwiseScheduleSyncController {
    
    public WrapperSync objWrapperSync{get;set;}
    InwiseUtil objInwiseUtil{get;set;}
    public List<SelectOption> listOfSelectOptionGroups{get;set;}
    public List<SelectOption> listOfSelectOptionAccounts{get;set;}
    public Map<String,String> mapOfGroup{get;set;}//id is a string here not sure about the length
    public String selectedSyncObject{get;set;}
    public inwiseScheduleSyncObject objSyncLead{get;set;}
    public inwiseScheduleSyncObject objSyncContact{get;set;}
    public List<SelectOption> listOfSOOperator{get;set;}
    public inwiseLtngConstants objinwiseLtngConstants{get;set;}
    public String strGroupName{get;set;}
    public Map<Id,Account__c> mapOfAccounts{get;set;}
    public  List<Account_SalesforceUser_Mapping__c> ListofAccountUsers {get;set;} 
    
    public Boolean isAdminUser ;
    public String userProfileName ;
    
    public String MSG_SYNC_CHECKBOX{get{
        return inwiseConstants.MSG_SYNC_CHECKBOX;
    }}
    
    public String typeVsOperatorString{get{
        String s = '{' +
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_STRING         + '": "Equals,Not Equal To,Contains,Does Not Contain,Starts With",' + 
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_PICKLIST       + '": "Equals,Not Equal To,Contains,Does Not Contain,Starts With",' + 
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_TEXTAREA     + '": "Equals,Not Equal To,Contains,Does Not Contain,Starts With",' + 
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_EMAIL            + '": "Equals,Not Equal To,Contains,Does Not Contain,Starts With",' + 
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_URL               + '": "Equals,Not Equal To,Contains,Does Not Contain,Starts With",' + 
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_PHONE               + '": "Equals,Not Equal To,Contains,Does Not Contain,Starts With",' + 
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_MULTIPICKLIST   + '": "Equals,Not Equal To,Contains,Does Not Contain",' + 
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_BOOLEAN  +  '": "Equals,Not Equal To",' +
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_DOUBLE    + '": "Equals,Not Equal To,Less Than,Less or Equal,Greater Than,Greater or Equal",' +
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_CURRENCY    + '": "Equals,Not Equal To,Less Than,Less or Equal,Greater Than,Greater or Equal",' +
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_INTEGER    + '": "Equals,Not Equal To,Less Than,Less or Equal,Greater Than,Greater or Equal",' +
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_DATE    + '": "Equals,Not Equal To,Less Than,Less or Equal,Greater Than,Greater or Equal",' +
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_DATETIME    + '": "Equals,Not Equal To,Less Than,Less or Equal,Greater Than,Greater or Equal",' +
            '"' + inwiseScheduleSyncObject.FIELD_TYPE_PERCENT    + '": "Equals,Not Equal To,Less Than,Less or Equal,Greater Than,Greater or Equal"' +
            '}';
        
        return s;
    }}
    
    public inwiseScheduleSyncController(ApexPages.StandardController stdConntroller) {
        if(ApexPages.currentPage().getParameters().get('Id') != NULL){
            objWrapperSync = new WrapperSync(ApexPages.currentPage().getParameters().get('Id'));
        }else{
            objWrapperSync = new WrapperSync();
        }
        
        isAdminUser = true;
        objinwiseLtngConstants = new inwiseLtngConstants();
        listOfSelectOptionGroups = new List<SelectOption>();
        listOfSelectOptionAccounts = new List<SelectOption>();
        ListofAccountUsers = new List<Account_SalesforceUser_Mapping__c>();
        mapOfGroup = new Map<String,String>();
        objWrapperSync.Step1 = true;
        objWrapperSync.currentStep = objWrapperSync.CONS_STEP1;
        objWrapperSync.Step2 = objWrapperSync.Step3 = false;
        objWrapperSync.isCanProceed = true;
        objSyncLead = new inwiseScheduleSyncObject(InwiseConstants.SOBJECT_LEAD,objWrapperSync.objSync);
        objSyncContact = new inwiseScheduleSyncObject(InwiseConstants.SOBJECT_CONTACT,objWrapperSync.objSync);
        listOfSOOperator = new List<SelectOption>();
        listOfSOOperator.add(new SelectOption('','None'));
        Schema.DescribeFieldResult fieldResult = Sync_Filter__c.Operator__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            listOfSOOperator.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        
        if(Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Name.isAccessible() && Schema.sObjectType.Account__c.fields.Default__c.isAccessible()){
            mapOfAccounts = new Map<Id,Account__c>([Select Id,Name,Default__c from Account__c  WITH SECURITY_ENFORCED LIMIT 1000]);
        }
        
        if(Schema.sObjectType.profile.isAccessible() && Schema.sObjectType.profile.fields.Name.isAccessible()){
            userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
        }

        List<String> listOfFinalUserProfileName = new List<String>(); 
        for(Setting__mdt customMetadataObj : [SELECT Id, MasterLabel, DeveloperName, Setting_Value__c FROM Setting__mdt WHERE MasterLabel = 'System Admin Profile' LIMIT 10000]) {
            listOfFinalUserProfileName.add(customMetadataObj.Setting_Value__c); 
        }
        isAdminUser = listOfFinalUserProfileName.contains(userProfileName); 
        if(isAdminUser) {
            if(Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Name.isAccessible() ){

                for(Account__c acc : [SELECT Id, Name FROM Account__c ORDER BY Name ASC LIMIT 49999]){
                    listOfSelectOptionAccounts.add(new SelectOption(acc.Id,acc.Name));
                }
            }
            if(objWrapperSync.selectedAccount == NULL){
                if(Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Name.isAccessible() && Schema.sObjectType.Account__c.fields.Default__c.isAccessible()){

                    List<Account__c> listOfAccLocal = [SELECT Id, Name, Default__c FROM Account__c WHERE Default__c = true LIMIT 1];
                    if(listOfAccLocal.size() > 0){
                        objWrapperSync.selectedAccount = listOfAccLocal[0].Id;
                    } 
                }
            }
        }else {
            List<Account_SalesforceUser_Mapping__c> ListofAccountUsers = new List<Account_SalesforceUser_Mapping__c>();
            if(Schema.sObjectType.Account_SalesforceUser_Mapping__c.isAccessible() && Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.Account__c.isAccessible() &&
               Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isAccessible() && Schema.sObjectType.Account__c.isAccessible() &&
               Schema.sObjectType.Account__c.fields.Name.isAccessible() && Schema.sObjectType.Account__c.fields.Default__c.isAccessible()){

                ListofAccountUsers = [SELECT Id, Account__c, User__c,Account__r.name,Account__r.Default__c FROM Account_SalesforceUser_Mapping__c where User__c =: UserInfo.getUserId() ] ;
            }

            if(!ListofAccountUsers.isEmpty()){
                
                for(Account_SalesforceUser_Mapping__c a:ListofAccountUsers){
                    listOfSelectOptionAccounts.add(new SelectOption(a.Account__c,a.Account__r.name));
                    if(objWrapperSync.selectedAccount == NULL){
                        objWrapperSync.selectedAccount = a.Account__r.Default__c ? a.Account__c : a.Account__c;
                    }
                }
            }
        }
    }
    
    public PageReference init(){
        PageReference pr;
        
        //check if the type of sync is view than send it to another page  
        if(objWrapperSync.objSync.Is_Created_By_View__c){
            pr = Page.ScheduleSyncView;
            pr.getParameters().put('sid', objWrapperSync.objSync.Id);
            pr.getParameters().put('retUrl',Page.inwiseHome.getUrl());
            pr.setRedirect(true);
        }
        if(objWrapperSync.objSync.Is_Created_By_Report__c){
            pr = Page.schedulesyncreport;
            pr.getParameters().put('sid', objWrapperSync.objSync.Id);
            pr.getParameters().put('retUrl',Page.inwiseHome.getUrl());
            pr.setRedirect(true);
        }
        if(pr == NULL && objWrapperSync.selectedAccount != NULL){
            getInwiseGroups();
        }   
        return pr;
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
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups/externalAppGeneric','inwiseScheduleSyncController','doCreateGroup'));
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
            //ErrorMsg = 'Exception Occurred!'; 
        }   
        return grpId;
    }
    
    public PageReference nextStep(){
        PageReference pr;
        List<Logs__c> listOfLogs = new List<Logs__c>();
        if(String.isEmpty(objWrapperSync.selectedAccount) & listOfSelectOptionAccounts != Null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,InwiseConstants.MSG_SELECT_OR_CREATE_ACCOUNT));
            return pr;
        }
        // listOfSelectOptionAccounts.add(new SelectOption(strGroupName,strGroupName));
        if(String.isEmpty(objWrapperSync.selectedGroup) && String.isEmpty(strGroupName)){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error, InwiseConstants.MSG_SELECT_OR_CREATE_GROUP));      
            return pr;
        }
        objWrapperSync.selectedGroupName = mapOfGroup.get(objWrapperSync.selectedGroup);
        //strGroupName = objWrapperSync.selectedGroupName;
        // system.debug(' strGroupName 2 is ' + strGroupName);
        if(objWrapperSync.currentStep == objWrapperSync.CONS_STEP1){ 
            if(!String.ISBLANK(objWrapperSync.objSync.Name)){
                if(String.isEmpty(objWrapperSync.selectedGroup) && !String.isEmpty(strGroupName)){
                    Integer grpid = doCreateGroup(strGroupName,listOfLogs);
                    if(grpid != 0){
                        objWrapperSync.selectedGroup = String.valueOf(grpid);
                        objWrapperSync.selectedGroupName = strGroupName;
                        init();//to reload groups in list box
                        if(!mapOfGroup.isEmpty()){
                            objWrapperSync.isCanProceed = true;
                        }
                        System.debug('size list of logs::-->>' + listOfLogs.size());
                        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                            insert listOfLogs;
                        }
                    }else{
                        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                            insert listOfLogs;
                        }
                        return null;
                    }
                }  
                objWrapperSync.currentStep = objWrapperSync.CONS_STEP2;
                objWrapperSync.Step2 = true;
                objWrapperSync.Step1 = false;
            } else {
                apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Required field Sync Name should not be Blank')));      
                return pr;                      
            }
            
        }else if(objWrapperSync.currentStep == objWrapperSync.CONS_STEP2){
            if(objWrapperSync.objSync.Leads__c == false && objWrapperSync.objSync.Contacts__c == false){
                apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Please select at least one object type')));      
                return pr;
            }
            
            if(objWrapperSync.objSync.Leads__c){
                if(!inwiseScheduleSyncObject.validateFieldVsValues(objSyncLead.listOfSyncFilters,InwiseConstants.SOBJECT_LEAD)){
                    return pr; 
                }
                
                objSyncLead.sSOQL = objSyncLead.buildSOQL(objSyncLead.listOfSyncFilters, InwiseConstants.SOBJECT_LEAD);
                if(!objSyncLead.validateSOQL(objSyncLead.sSOQL)){
                    return pr;
                }
            }
            if(objWrapperSync.objSync.Contacts__c){
                if(!inwiseScheduleSyncObject.validateFieldVsValues(objSyncContact.listOfSyncFilters,InwiseConstants.SOBJECT_CONTACT)){
                    return pr; 
                }
                
                objSyncContact.sSOQL = objSyncContact.buildSOQL(objSyncContact.listOfSyncFilters, InwiseConstants.SOBJECT_CONTACT);
                if(!objSyncContact.validateSOQL(objSyncContact.sSOQL)){
                    return pr;
                }
                
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
            if(Schema.sObjectType.Sync__c.fields.Leads_SOQL__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Leads_SOQL__c.isUpdateable()){
                if(objWrapperSync.objSync.Leads__c){
                    objWrapperSync.objSync.Leads_SOQL__c = objSyncLead.sSOQL;
                }else{
                    objWrapperSync.objSync.Leads_SOQL__c = NULL;
                }      
            }
            if(Schema.sObjectType.Sync__c.fields.Contacts_SOQL__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Contacts_SOQL__c.isUpdateable()){
                if(objWrapperSync.objSync.Contacts__c){
                    objWrapperSync.objSync.Contacts_SOQL__c = objSyncContact.sSOQL;
                }else{
                    objWrapperSync.objSync.Contacts_SOQL__c = NULL;
                }
            }
            if(Schema.sObjectType.Sync__c.isUpdateable() && Schema.sObjectType.Sync__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Group_Name__c.isUpdateable()){
                upsert objWrapperSync.objSync;
            }
            List<Sync_Filter__c> listOfSyncFiltersToInsert = new List<Sync_Filter__c>();
            List<Sync_Filter__c> listOfSyncFiltersToInsertLead = new List<Sync_Filter__c>();
            List<Sync_Filter__c> listOfSyncFiltersToInsertContact = new List<Sync_Filter__c>();
            
            if(objWrapperSync.objSync.Leads__c){
                listOfSyncFiltersToInsertLead =  doSaveFilters(objSyncLead.listOfSyncFilters,InwiseConstants.SOBJECT_LEAD);
            } 
            if(objWrapperSync.objSync.Contacts__c){
                listOfSyncFiltersToInsertContact =  doSaveFilters(objSyncContact.listOfSyncFilters,InwiseConstants.SOBJECT_CONTACT);
            }
            
            if(!listOfSyncFiltersToInsertLead.isEmpty()){
                listOfSyncFiltersToInsert.addAll(listOfSyncFiltersToInsertLead);
            }
            if(!listOfSyncFiltersToInsertContact.isEmpty()){
                listOfSyncFiltersToInsert.addAll(listOfSyncFiltersToInsertContact);
            }
            
            if(!listOfSyncFiltersToInsert.isEmpty()){
                doDeletePreviousFilters(listOfSyncFiltersToInsert);
                if(Schema.sObjectType.Sync_Filter__c.isCreateable()){
                    insert listOfSyncFiltersToInsert;
                }   
            }
            pr = Page.inwiseQuery;
            pr.getParameters().put('Id',objWrapperSync.objSync.Id);
            pr.setRedirect(true);
        }
        return pr;
    } 
    
    public void doDeletePreviousFilters(List<Sync_Filter__c> listOfSyncFiltersToInsert){
        Set<Id> setOfSyncId = new Set<Id>();
        if(!listOfSyncFiltersToInsert.isEmpty()){
            for(Sync_Filter__c sf:listOfSyncFiltersToInsert){
                setOfSyncId.add(sf.Sync__c);
            }
            if(!setOfSyncId.isEmpty()){
                if(Schema.sObjectType.Sync_Filter__c.isAccessible() && Schema.sObjectType.Sync_Filter__c.fields.Sync__c.isAccessible()){
                    List<Sync_Filter__c> listOfFilters = [Select Id from Sync_Filter__c where Sync__c IN:setOfSyncId];     
                    if(!listOfFilters.isEmpty()){
                        if(Sync_Filter__c.sObjectType.getDescribe().isDeletable()){
                            delete listOfFilters;   
                        }   
                    }
                }    
            }                    
        }
    }
    
    public List<Sync_Filter__c> doSaveFilters(List<inwiseScheduleSyncObject.WrapperFilter> listOfWrapperFilter, String sobjectapiname){
        List<Sync_Filter__c> listOfSyncFiltersToInsert = new List<Sync_Filter__c>();
        if(!listOfWrapperFilter.isEmpty()){
            for(inwiseScheduleSyncObject.WrapperFilter wf: listOfWrapperFilter){                        
                if(wf.objSyncFilter.Field_Api_Name__c != NULL && wf.objSyncFilter.Operator__c != NULL){
                    List<String> listOfFieldVsType = wf.objSyncFilter.Field_Api_Name__c.split(':');
                    if(!listOfFieldVsType.isEmpty() && listOfFieldVsType.size() == 2){
                        if(Schema.sObjectType.Sync_Filter__c.fields.Field_Api_Name__c.isCreateable()){
                            wf.objSyncFilter.Field_Api_Name__c = listOfFieldVsType.get(0);
                        }
                        if(Schema.sObjectType.Sync_Filter__c.fields.Field_Type__c.isCreateable()){
                            wf.objSyncFilter.Field_Type__c = listOfFieldVsType.get(1);
                        }
                        if(Schema.sObjectType.Sync_Filter__c.fields.sObject_Name__c.isCreateable()){
                            wf.objSyncFilter.sObject_Name__c = sobjectapiname;
                        }
                        if(Schema.sObjectType.Sync_Filter__c.fields.Sync__c.isCreateable()){
                            if(wf.objSyncFilter.Sync__c == NULL){
                                wf.objSyncFilter.Sync__c = objWrapperSync.objSync.Id;  
                            }
                        }
                        
                        listOfSyncFiltersToInsert.add(getNewSyncFilter(wf.objSyncFilter));
                    }     
                }          
            }
        }
        return listOfSyncFiltersToInsert;
    }
    
    public Sync_Filter__c getNewSyncFilter(Sync_Filter__c objSyncFilter){
        Sync_Filter__c objSyncFilterNew = new Sync_Filter__c();
        if(Schema.sObjectType.Sync_Filter__c.fields.Field_Api_Name__c.isCreateable()){
            objSyncFilterNew.Field_Api_Name__c = objSyncFilter.Field_Api_Name__c;
        }   
        if(Schema.sObjectType.Sync_Filter__c.fields.Field_Label__c.isCreateable()){
            objSyncFilterNew.Field_Label__c = objSyncFilter.Field_Label__c;
        }
        if(Schema.sObjectType.Sync_Filter__c.fields.Field_Type__c.isCreateable()){
            objSyncFilterNew.Field_Type__c = objSyncFilter.Field_Type__c;
        }
        if(Schema.sObjectType.Sync_Filter__c.fields.Operator__c.isCreateable()){
            objSyncFilterNew.Operator__c = objSyncFilter.Operator__c;
        }
        if(Schema.sObjectType.Sync_Filter__c.fields.Sync__c.isCreateable()){
            objSyncFilterNew.Sync__c = objSyncFilter.Sync__c;
        }
        if(Schema.sObjectType.Sync_Filter__c.fields.Value__c.isCreateable()){
            objSyncFilterNew.Value__c = objSyncFilter.Value__c; 
        }
        if(Schema.sObjectType.Sync_Filter__c.fields.sObject_Name__c.isCreateable()){
            objSyncFilterNew.sObject_Name__c = objSyncFilter.sObject_Name__c;
        }
        
        return objSyncFilterNew;
    }
    
    public PageReference showSyncSection(){
        return null;
    }
    
    public void getInwiseGroups(){
        
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
            return;
        }
        Http http = new Http();
        HttpResponse res;
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contactsGroups?create_date_from=2010-01-01&group_type=generic_push&order_by=id%20desc'; 
        HttpRequest req = objInwiseUtil.GetHTTPRequest('GET','application/json',endpoint); 
        if(objWrapperSync.selectedAccount != NULL && mapOfAccounts != NULL && mapOfAccounts.get(objWrapperSync.selectedAccount) != NULL ){
            //req.setHeader('X-Api-Key',inwiseUtil.decryptToken(mapOfAccounts.get(objWrapperSync.selectedAccount).Token__c));  
            String tokenFromSetting = inwiseUtil.getTokenToAccId(mapOfAccounts.get(objWrapperSync.selectedAccount).Id);
            req.setHeader('X-Api-Key',tokenFromSetting);  
        }
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups','inwiseScheduleSyncController','getInwiseGroups'));
            }else{
                String resBody = ' [   {     "id": "653415",     "name": "boaz20171020-9",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653414",     "name": "boaz20171020-8",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653346",     "name": "Campaign11Oct-32",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653345",     "name": "Campaign11Oct-31",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653344",     "name": "Campaign11Oct-30",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653343",     "name": "Campaign11Oct-29",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653342",     "name": "boaz20171020-7",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653341",     "name": "boaz20171020-6",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653338",     "name": "boaz20171020-5",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653337",     "name": "boaz20171020-4",     "create_date": "2017-10-21",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653336",     "name": "boaz20171020-3",     "create_date": "2017-10-21",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653335",     "name": "Campaign11Oct-28",     "create_date": "2017-10-21",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653249",     "name": "boaz20171020-2",     "create_date": "2017-10-20",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653229",     "name": "boaz20171020",     "create_date": "2017-10-20",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652451",     "name": "Campaign11Oct-27",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652423",     "name": "Campaign11Oct-26",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652414",     "name": "Campaign11Oct-25",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652409",     "name": "Campaign11Oct-24",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652407",     "name": "Campaign11Oct-23",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652401",     "name": "Campaign11Oct-22",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652400",     "name": "Campaign11Oct-21",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652074",     "name": "ManyMembers29",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652073",     "name": "boaz test 9",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652048",     "name": "boaz test 8",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652047",     "name": "boaz test 7",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652046",     "name": "Campaign11Oct-20",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652045",     "name": "boaz test 6",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652044",     "name": "boaz test 5",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652043",     "name": "ManyMembers28",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652018",     "name": "boaz test 4",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652011",     "name": "ManyMembers27",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652010",     "name": "Campaign11Oct-19",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652009",     "name": "ManyMembers25",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652008",     "name": "ManyMembers24",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652007",     "name": "ManyMembers23",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652006",     "name": "Campaign11Oct-18",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652005",     "name": "Campaign11Oct-17",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652004",     "name": "Campaign11Oct-16",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651960",     "name": "Campaign11Oct-15",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651954",     "name": "Campaign11Oct-13",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651949",     "name": "Campaign11Oct-12",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651941",     "name": "Campaign11Oct-11",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651928",     "name": "Campaign11Oct-10",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651927",     "name": "Campaign11Oct-8",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651926",     "name": "Campaign11Oct-7",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651920",     "name": "Campaign11Oct-6",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651919",     "name": "Campaign11Oct-4",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651918",     "name": "Campaign11Oct-3",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651914",     "name": "Campaign11Oct-2",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651913",     "name": "Campaign11Oct-1",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651870",     "name": "boaz test 3",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651854",     "name": "ManyMembers22",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651853",     "name": "ManyMembers21",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651852",     "name": "ManyMembers20",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651849",     "name": "ManyMembers19",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651848",     "name": "ManyMembers18",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651847",     "name": "ManyMembers17",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651846",     "name": "ManyMembers16",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651844",     "name": "ManyMembers15",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651833",     "name": "ManyMembers14",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651832",     "name": "ManyMembers13",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651831",     "name": "ManyMembers12",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651830",     "name": "ManyMembers11",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651829",     "name": "ManyMembers10",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651824",     "name": "ManyMembers9",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651822",     "name": "ManyMembers8",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651820",     "name": "ManyMembers7",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651819",     "name": "ManyMembers6",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651818",     "name": "ManyMembers5",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651817",     "name": "ManyMembers4",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651773",     "name": "ManyMembers3",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "646274",     "name": "test campaign29Aug32",     "create_date": "2017-08-29",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "646271",     "name": "test campaign29Aug2",     "create_date": "2017-08-29",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "646270",     "name": "test campaign29Aug",     "create_date": "2017-08-29",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "646264",     "name": "test campaign29Aug3",     "create_date": "2017-08-29",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642838",     "name": "test campaign03Aug3",     "create_date": "2017-08-03",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642821",     "name": "test campaign03Aug2",     "create_date": "2017-08-02",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642820",     "name": "test campaign03Aug1",     "create_date": "2017-08-02",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642819",     "name": "test campaign03Aug",     "create_date": "2017-08-02",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642100",     "name": "test campaign 28th July",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642089",     "name": "test 43 newtest",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642084",     "name": "test 43 new",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642080",     "name": "Campaign28July11.14AM",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642075",     "name": "Campaign28July11.05AM",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642073",     "name": "Campaign28July10.46AM",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642071",     "name": "Campaign28July10.28AM",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641996",     "name": "boaz20170727",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641961",     "name": "Campaign27 July04.50PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641959",     "name": "Campaign27 July04.43PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641952",     "name": "Campaign27 July02.28PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641947",     "name": "Campaign27 July02.20PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641946",     "name": "Campaign27 July02.15PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641933",     "name": "Campaign27 July02.10PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641910",     "name": "Campaign27 July10.52PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641909",     "name": "Campaign27 July10.50PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641908",     "name": "Campaign27 July10.40PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641899",     "name": "Campaign27 July10.39PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641898",     "name": "Campaign27 July10.35PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641892",     "name": "Campaign27 July10.33PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641891",     "name": "Campaign27 July10.30PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   } ]';
                    res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res != NULL){
                if(res.getStatusCode() == 200){
                    List<JSON2ApexGroupList> listOfGroupList = (List<JSON2ApexGroupList>) System.JSON.deserialize(res.getBody(), List<JSON2ApexGroupList>.class);
                    if(!listOfGroupList.isEmpty()){
                        for(JSON2ApexGroupList l:listOfGroupList){
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
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
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
    
    public string getXMLReuestForList(String tablename, String sessionId){
        String maxidString = '';
        String soapBody = '<?xml version="1.0" encoding="utf-8"?>';
        soapBody += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        soapBody += '<soap:Header>';
        soapBody += '<SessionIdHeader xmlns="http://www.inwise.com/webservices/v2">';
        soapBody += '<SessionId>'+ sessionId+'</SessionId>';
        soapBody += '<EndSession>false</EndSession>';
        soapBody += '</SessionIdHeader>';
        soapBody += '</soap:Header>';
        
        soapBody += '<soap:Body>';
        soapBody += '<List xmlns="http://www.inwise.com/webservices/v2">';
        soapBody += '<query>';
        soapBody +='<Sql>SELECT Name ,Id  FROM ContactsGroup</Sql>';
        soapBody += '</query>';
        soapBody += '</List>';    
        soapBody += '</soap:Body>';
        soapBody += '</soap:Envelope>';
        return soapBody;
    }
    
    public class WrapperSync{
        
        public Sync__c objSync {get;set;}
        public String selectedGroup{get;set;}
        public String selectedGroupName{get;set;}
        public String selectedAccount{get;set;}
        public String selectedAccountName{get;set;}
        public boolean Step1{get;set;}
        public boolean Step2{get;set;}
        public boolean Step3{get;set;}
        public String currentStep {get;set;}
        public boolean isCanProceed {get;set;}
        
        public String CONS_STEP1{get{
            return 'Step1';
        }}
        
        public String CONS_STEP2{get{
            return 'Step2';
        }}
        
        public String CONS_STEP3{get{
            return 'Step3';
        }}
        
        public WrapperSync(){
            objSync = new Sync__c();
        }
        public WrapperSync(Id sid){
            if(Schema.sObjectType.Sync__c.isAccessible()){
                objSync = InwiseUtil.doGetSyncRecord(sid);
                if(objSync != NULL){
                    selectedGroup = String.valueOf(objSync.Group_Id__c);
                    selectedGroupName = objSync.Group_Name__c;
                    selectedAccount = String.valueOf(objSync.Account__c);
                    selectedAccountName = objSync.Account__c != NULL ? objSync.Account__r.Name : '';
                }
            }
        }
    }
    
    public class JSON2ApexGroupList {
        public String id{get;set;}
        public String name{get;set;}
        public String create_date{get;set;}
        public String group_type{get;set;}
        public String target_type{get;set;}
    }
}