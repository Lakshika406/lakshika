/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 12/02/2016
*Purpose :     New page landing page sync controller class
*Modified:   
================================================================
Modified On   Version   Modified By                Purpose
================================================================
05/10/2019    1.1.0  NLINEAXIS(Kapil Goutam)     Modified:- issue fixed when we hit next previous mitiple time it create multiple records for mapping.
12/12/2019    1.1.1  NLINEAXIS(Kapil Goutam)     Modified:- changed api for popups from formActivity to formProperties, it does not includes create_date_from parameter
15/03/2021    1.1.2  NLINEAXIS(Kapil Goutam)     Modified:- Added option to choose an account in sync leads from inwise
31/03/2021    1.1.3  NLINEAXIS(Kapil Goutam)     Modified:- Added functionality when choose account show 'select form' according the account
06/28/2021    1.1.4  NLINEAXIS(Kapil Goutam)     Modified:- Added system admin should be able to see all options (Show all account picklist value for system admin)
/******************************************************************************************/
public with sharing class inwiseScheduleLandingSyncController {
    
    public WrapperSync objWrapperSync{get;set;}
    InwiseUtil objInwiseUtil{get;set;}
    public List<SelectOption> listOfSelectOptionLandingPages{get;set;}
    public Map<String,String> mapOfLandingPageFields{get;set;}//id is a string here not sure about the length
    public List<SelectOption> listOfSelectOptionFields_Lead {get;set;}
    public inwiseLtngConstants objinwiseLtngConstants{get;set;}
    public string isLandingPage{get;set;}
    public Boolean isLandingDisabled{get;set;}
    public Boolean isPopupDisabled{get;set;}
    public List<SelectOption> listOfSelectOptionAccounts{get;set;}
    public List<Account_SalesforceUser_Mapping__c> listofAccountUsers {get;set;} 
    public String csrfToken { get; set; }
    public Boolean notAnyDefaultAcc;
    public Boolean isAdminUser ;
    public String userProfileName ;
    
    public inwiseScheduleLandingSyncController(ApexPages.StandardController stdConntroller) {

        objinwiseLtngConstants = new inwiseLtngConstants();
        csrfToken = inwiseUtil.generateCSRFToken(); // Generate a unique token
       
        if(ApexPages.currentPage().getParameters().get('Id') != NULL){
            objWrapperSync = new WrapperSync(ApexPages.currentPage().getParameters().get('Id'));
            isLandingPage = objWrapperSync.objSync.Form_Type__c;
            
            if(isLandingPage=='Landing Page'){
                isPopupDisabled=true;
            }else{
                isLandingDisabled=true;
            }
        }else{
            objWrapperSync = new WrapperSync();
            isLandingPage = 'Landing Page';
        }
        isAdminUser = true;
        if(Schema.sObjectType.profile.isAccessible() && Schema.sObjectType.profile.fields.Name.isAccessible()){
            userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
        }
        List<String> listOfFinalUserProfileName = new List<String>(); 
        for(Setting__mdt customMetadataObj : [SELECT Id, MasterLabel, DeveloperName, Setting_Value__c FROM Setting__mdt WHERE MasterLabel = 'System Admin Profile' LIMIT 10000]) {
            
            listOfFinalUserProfileName.add(customMetadataObj.Setting_Value__c); 
        }
        isAdminUser = listOfFinalUserProfileName.contains(userProfileName);  
        listOfSelectOptionLandingPages = new List<SelectOption>();
        mapOfLandingPageFields = new Map<String,String>();
        objWrapperSync.Step1 = true;
        objWrapperSync.currentStep = objWrapperSync.CONS_STEP1;
        objWrapperSync.Step2  = false;
        objWrapperSync.isCanProceed = true;
        notAnyDefaultAcc = true;
        listOfSelectOptionFields_Lead = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_LEAD,inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL,true);
        listOfSelectOptionAccounts = new List<SelectOption>();
        listofAccountUsers = new List<Account_SalesforceUser_Mapping__c>();
        if(isAdminUser) {
            if(Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Name.isAccessible()){
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
            if(Schema.sObjectType.Account_SalesforceUser_Mapping__c.isAccessible() && Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.Account__c.isAccessible() &&
               Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isAccessible() && Schema.sObjectType.Account__c.isAccessible() &&
               Schema.sObjectType.Account__c.fields.Name.isAccessible() && Schema.sObjectType.Account__c.fields.Default__c.isAccessible()){

                listofAccountUsers = [SELECT Id, Account__c, User__c,Account__r.name,Account__r.Default__c FROM Account_SalesforceUser_Mapping__c where User__c =: UserInfo.getUserId()
                                  ORDER BY Account__r.name ASC] ;
            }

            if(!listofAccountUsers.isEmpty()){
                for(Account_SalesforceUser_Mapping__c a : listofAccountUsers){
                    listOfSelectOptionAccounts.add(new SelectOption(a.Account__c,a.Account__r.name));
                    if(a.Account__r.Default__c && objWrapperSync.selectedAccount == NULL){
                        objWrapperSync.selectedAccount = a.Account__c;
                        notAnyDefaultAcc = false ;
                    } 
                }
                if(notAnyDefaultAcc) {
                    objWrapperSync.selectedAccount = listofAccountUsers[0].Account__c;
                }
            }
        }
    }

    public List<Landing_Sync_Mapping__c> getLandingPageFields(Decimal selectedPageId,List<Logs__c> listOfLogs){

        List<Landing_Sync_Mapping__c> listOfLandingSyncMapping = new List<Landing_Sync_Mapping__c>();
        Landing_Sync_Mapping__c objLandingSyncMapping;
        Account__c acc;
        if(Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Name.isAccessible() && Schema.sObjectType.Account__c.fields.Default__c.isAccessible()){

            if(objWrapperSync.selectedAccount !=null ){
                acc = [Select Id,Name,Default__c from Account__c where id=: objWrapperSync.selectedAccount LIMIT 1];
            }
        }
        string api='';
        if(isLandingPage =='Landing Page'){
            api='/rest/v1/pages/landingPage/formProperties?pages_ids=';
        }else{
            api='/rest/v1/pages/popups/formProperties?pages_ids=';
        }
        
        objInwiseUtil = new InwiseUtil(acc);
        Http http =  new Http();
        String endpoint = objInwiseUtil.apiUrl +api + selectedPageId;
        HttpRequest req = objInwiseUtil.GetHTTPRequest('GET','application/json',endpoint); 
        req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken); 
        HttpResponse res;
        
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                
                if(isLandingPage =='Landing Page'){
                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/pages/landingPage/formProperties','inwiseScheduleLandingSyncController','getLandingPageFields'));
                    
                }else{
                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/pages/popups/formProperties','inwiseScheduleLandingSyncController','getLandingPageFields'));
                }
            }else{
                String resBody = '[{"record_index":296340,"action_date":"2016-11-29 09:25:00","contact_id":null,"campaign_id":null,"channel_type":null,"ip":null,"confirmation_date":null,"confirmation_ip":null,"survey_values":{"text98":"972544444444","text99":"lklkl","text100":"kkml@sdfg.com"},"fields_mappings":{"text100":"Email","text99":"Name","text98":"Phone","text-1001":"Send"}},{"record_index":296833,"action_date":"2016-12-04 08:57:00","contact_id":null,"campaign_id":null,"channel_type":null,"ip":null,"confirmation_date":null,"confirmation_ip":null,"survey_values":{"text98":"03-4343434","text99":"NAME MY NAME","text100":"EMAIL@EMAIL.COM"},"fields_mappings":{"text100":"Email","text99":"Name","text98":"Phone","text-1001":"Send"}}]';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }

            if(res != NULL){
                if(res.getStatusCode() == 200){ 
                    String jsonString = res.getBody(); //'[{"action_date":"2016-11-29 09:25:00","contact_id":null,"campaign_id":null,"channel_type":null,"ip":null,"confirmation_date":null,"confirmation_ip":null,"survey_values":{"text98":"972544444444","text99":"lklkl","text100":"kkml@sdfg.com"},"fields_mappings":{"text100":"Email","text99":"Name","text98":"Phone","text-1001":"Send"}}]';
                    List<WrapperFormProperties> listOfWrapperFormProperties = WrapperFormProperties.parse(jsonString);
                    if(listOfWrapperFormProperties != null && !listOfWrapperFormProperties.isEmpty()){
                        WrapperFormProperties objWrapperFormProperties = listOfWrapperFormProperties.get(0);
                        if(objWrapperFormProperties.fields != null && !objWrapperFormProperties.fields.isEmpty()){
                            for(WrapperFormProperties.fields f:objWrapperFormProperties.fields){
                                objLandingSyncMapping = new Landing_Sync_Mapping__c();
                                objLandingSyncMapping.inwise_FieldId__c = 'text' + String.valueOf(f.id);
                                objLandingSyncMapping.inwise_Field__c = f.label;
                                listOfLandingSyncMapping.add(objLandingSyncMapping);
                            }
                            objLandingSyncMapping= new Landing_Sync_Mapping__c();
                            objLandingSyncMapping.inwise_Field__c = inwiseConstants.INWISE_FIELD_PAGENAME;
                            objLandingSyncMapping.inwise_FieldId__c = 'text' +  String.valueOf(inwiseConstants.INWISE_FIELDID_PAGENAME);
                            listOfLandingSyncMapping.add(objLandingSyncMapping);
                        }
                    }
                }
            }
        }catch(Exception ex){
            system.debug('catch>>>>>>'+ex.getMessage());
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,ex.getMessage()));      
        }       
        return listOfLandingSyncMapping;
    }

    public void OnLoadCheckLandingPageAndPopup(){

        String csrfTokenValue = ApexPages.currentPage().getParameters().get('csrfToken');

        // Validate the CSRF token
        if (csrfTokenValue == null || !inwiseUtil.validateCSRFToken(csrfTokenValue)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid CSRF token. Action cannot be performed.'));
            return;
        }
        
        getLandingPagesList(true);
    }

    public void getLandingPagesList(){
        getLandingPagesList(false);
    }

    public void getLandingPagesList(boolean isOnLoad){
        List<Logs__c> listOfLogs = new List<Logs__c>();
        objInwiseUtil = new InwiseUtil(new Account__c(Id=objWrapperSync.selectedAccount));
        
        if(!objInwiseUtil.CheckIfCredentialExists()){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,InwiseConstants.INWISE_CREDENTIAL_MISSING));      
            return;
        } 
        try{ 
            mapOfLandingPageFields = inwiseHttpUtil.InwiseCalloutLandingPagesList(objInwiseUtil,listOfLogs,true,isLandingPage);
            if(isOnload){
                if(mapOfLandingPageFields.isEmpty()){
                    mapOfLandingPageFields = inwiseHttpUtil.InwiseCalloutLandingPagesList(objInwiseUtil,listOfLogs,true, 'popups');
                    isLandingPage = 'Popup';
                }
            }
            listOfSelectOptionLandingPages =new  List<SelectOption>();
            listOfSelectOptionLandingPages.add(new SelectOption('','--None--'));
            if(!mapOfLandingPageFields.isEmpty()){
                
                for(String k:mapOfLandingPageFields.keySet()){
                    listOfSelectOptionLandingPages.add(new SelectOption(k,mapOfLandingPageFields.get(k)));            
                }
            }
        }catch(Exception ex){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,ex.getMessage()));      
        }
        if(!mapOfLandingPageFields.isEmpty()){
            objWrapperSync.isCanProceed = true;
        }
        
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            if(Logs__c.SObjectType.getDescribe().isCreateable()){
                insert listOfLogs;
            } 
        }      
    }

    public void getLandingPagesListOnAccChange(){

        List<Logs__c> listOfLogs = new List<Logs__c>();
        objInwiseUtil = new InwiseUtil(new Account__c(Id=objWrapperSync.selectedAccount));
        if(!objInwiseUtil.CheckIfCredentialExists()){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,InwiseConstants.INWISE_CREDENTIAL_MISSING));      
            return;
        } 
        try{
            if(isLandingPage ==null) {
                isLandingPage = 'Landing Page';
            } 
            mapOfLandingPageFields = inwiseHttpUtil.InwiseCalloutLandingPagesList(objInwiseUtil,listOfLogs,true,isLandingPage);
            if(isLandingPage == 'Popup'){
                if(mapOfLandingPageFields.isEmpty()){
                    mapOfLandingPageFields = inwiseHttpUtil.InwiseCalloutLandingPagesList(objInwiseUtil,listOfLogs,true, 'popups');
                    isLandingPage = 'Popup';
                }
            }
            listOfSelectOptionLandingPages =new  List<SelectOption>();
            listOfSelectOptionLandingPages.add(new SelectOption('','--None--'));
            if(!mapOfLandingPageFields.isEmpty()){
                
                for(String k:mapOfLandingPageFields.keySet()){
                    listOfSelectOptionLandingPages.add(new SelectOption(k,mapOfLandingPageFields.get(k)));            
                }
            }
        }catch(Exception ex){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,ex.getMessage()));      
        }
        if(!mapOfLandingPageFields.isEmpty()){
            objWrapperSync.isCanProceed = true;
        }

        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            if(Logs__c.SObjectType.getDescribe().isCreateable()){
                insert listOfLogs;
            } 
        }      
    }
    
    public PageReference doPrevStep(){
        PageReference pr;
        objWrapperSync.currentStep = objWrapperSync.CONS_STEP1;
        objWrapperSync.Step2 = false;
        objWrapperSync.Step1 = true;
        objWrapperSync.listOfLandingSyncMapping.clear();
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

    public PageReference nextStep(){
        
        List<Logs__c> listOfLogs = new List<Logs__c>();
        PageReference pr;
        if(Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Id__c.isAccessible()){
            if(isLandingPage == null){
                isLandingPage = 'Landing Page';
            }
            if(String.ISBLANK(objWrapperSync.objSync.Name)){
                apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Required field Sync Name should not be blank'));      
                return pr;
            }else if(listOfSelectOptionLandingPages.size() <= 1){
                apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Selected account does not have any form.Please select another account'));      
                return pr;
            }          
            
            
            if( objWrapperSync.objSync.Landing_Page_Id__c == NULL || String.ISBLANK(objWrapperSync.objSync.Name )){
                if(isLandingPage =='Landing Page'){
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please select landing page'));      
                }else{
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please select popup '));      
                    
                } 
                return pr;
            }
        }  
        if(Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Name__c.isCreateable() && Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Name__c.isUpdateable() && Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Id__c.isAccessible()){
            objWrapperSync.objSync.Landing_Page_Name__c = mapOfLandingPageFields.get(String.valueOf(objWrapperSync.objSync.Landing_Page_Id__c));
        } 
        if(Schema.sObjectType.Landing_Sync__c.fields.Account__c.isCreateable() && Schema.sObjectType.Landing_Sync__c.fields.Account__c.isUpdateable() && Schema.sObjectType.Landing_Sync__c.fields.Account__c.isAccessible()){
            objWrapperSync.objSync.Account__c =  objWrapperSync.selectedAccount;
        } 
        if(Schema.sObjectType.Landing_Sync__c.fields.Form_Type__c.isCreateable() && Schema.sObjectType.Landing_Sync__c.fields.Form_Type__c.isUpdateable() && Schema.sObjectType.Landing_Sync__c.fields.Form_Type__c.isAccessible()){
            objWrapperSync.objSync.Form_Type__c = isLandingPage;
        }
        
        if(objWrapperSync.currentStep == objWrapperSync.CONS_STEP1){
            if(objWrapperSync.objSync.Landing_Page_Id__c == NULL){
                if(isLandingPage =='Landing Page'){
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Please select landing page')));      
                }else{
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Please select Popup')));      
                    
                }
                return pr;
            }
            if(ApexPages.currentPage().getParameters().get('Id') != NULL){

                List<Landing_Sync_Mapping__c> listOfLandingSyncMappingT = new List<Landing_Sync_Mapping__c>();
                if(Schema.sObjectType.Landing_Sync_Mapping__c.isAccessible() && Schema.sObjectType.Landing_Sync_Mapping__c.fields.Name.isAccessible() &&
                   Schema.sObjectType.Landing_Sync_Mapping__c.fields.inwise_Field__c.isAccessible() && Schema.sObjectType.Landing_Sync_Mapping__c.fields.inwise_FieldId__c.isAccessible() &&
                   Schema.sObjectType.Landing_Sync_Mapping__c.fields.Salesforce_Field__c.isAccessible() && Schema.sObjectType.Landing_Sync_Mapping__c.fields.Landing_Sync__c.isAccessible() ){

                    listOfLandingSyncMappingT = [Select Id,Name, inwise_Field__c, inwise_FieldId__c, Salesforce_Field__c,Landing_Sync__c from Landing_Sync_Mapping__c where Landing_Sync__c =:ApexPages.currentPage().getParameters().get('Id') WITH SECURITY_ENFORCED]; 
                }
                
                if(!listOfLandingSyncMappingT.isEmpty()){
                    objWrapperSync.listOfLandingSyncMapping.addAll(listOfLandingSyncMappingT);
                }
            }else{
                objWrapperSync.listOfLandingSyncMapping = getLandingPageFields(objWrapperSync.objSync.Landing_Page_Id__c,listOfLogs); 
                if(!objWrapperSync.listOfLandingSyncMapping.isEmpty()){
                    doDefaultMapping(objWrapperSync.listOfLandingSyncMapping);     
                }
            }
            
            objWrapperSync.currentStep = objWrapperSync.CONS_STEP2;
            objWrapperSync.Step2 = true;
            objWrapperSync.Step1 = false;
        }
        else if(objWrapperSync.currentStep == objWrapperSync.CONS_STEP2){
            boolean isMappingNotFound = true;   
            for(Landing_Sync_Mapping__c m:objWrapperSync.listOfLandingSyncMapping){
                if(m.Salesforce_Field__c != NULL){
                    isMappingNotFound = false;
                    break;
                }
            }
            if(isMappingNotFound){
                apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Please select Mapping')));      
                return pr;
            }
            if(Schema.sObjectType.Landing_Sync__c.isUpdateable() && Schema.sObjectType.Landing_Sync__c.isCreateable()){
                upsert objWrapperSync.objSync;
            }    
            Landing_Sync_Mapping__c objLandingSyncMappingT;
            if(!objWrapperSync.listOfLandingSyncMapping.isEmpty()){
                doDeletePreviousMapping(objWrapperSync.objSync.Id);
                
                List<Landing_Sync_Mapping__c> listOfMappingToInsert = new List<Landing_Sync_Mapping__c>();
                for(Landing_Sync_Mapping__c s:objWrapperSync.listOfLandingSyncMapping){
                    if(Schema.sObjectType.Landing_Sync_Mapping__c.isCreateable()){
                        objLandingSyncMappingT = new Landing_Sync_Mapping__c();
                        if(Schema.sObjectType.Landing_Sync_Mapping__c.fields.inwise_Field__c.isCreateable()){
                            objLandingSyncMappingT.inwise_Field__c =  s.inwise_Field__c;
                        }   
                        if(Schema.sObjectType.Landing_Sync_Mapping__c.fields.inwise_FieldId__c.isCreateable()){
                            objLandingSyncMappingT.inwise_FieldId__c =  s.inwise_FieldId__c;
                        }    
                        if(Schema.sObjectType.Landing_Sync_Mapping__c.fields.Landing_Sync__c.isCreateable()){
                            objLandingSyncMappingT.Landing_Sync__c =  objWrapperSync.objSync.Id;
                        }   
                        if(Schema.sObjectType.Landing_Sync_Mapping__c.fields.Salesforce_Field__c.isCreateable()){
                            objLandingSyncMappingT.Salesforce_Field__c =  s.Salesforce_Field__c;
                        }    
                        listOfMappingToInsert.add(objLandingSyncMappingT);
                    }     
                }
                if(Schema.sObjectType.Landing_Sync_Mapping__c.isCreateable()){
                    insert listOfMappingToInsert;
                }   
            }
            pr = Page.inwiseHome;
            pr.setRedirect(true);
        }
       
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        }         
        return pr;
    }

    public void doDefaultMapping(List<Landing_Sync_Mapping__c> listOfLandingSyncMapping){
        
        for(Landing_Sync_Mapping__c m: listOfLandingSyncMapping){
            if(m.inwise_Field__c.tolowercase() == 'name' || m.inwise_Field__c.tolowercase() == 'first name' || m.inwise_Field__c == 'שם'){
                m.Salesforce_Field__c = 'FirstName';
            }else if(m.inwise_Field__c.tolowercase() == 'last name' || m.inwise_Field__c == 'שם משפחה'){
                m.Salesforce_Field__c = 'LastName';
            }else if(m.inwise_Field__c.tolowercase() == 'email' || m.inwise_Field__c== 'מייל'){
                m.Salesforce_Field__c = 'Email';
            }else if(m.inwise_Field__c.tolowercase() == 'phone' || m.inwise_Field__c == 'טלפון'){
                m.Salesforce_Field__c = 'Phone';
            }else if(m.inwise_Field__c.tolowercase() == 'mobile' || m.inwise_Field__c == 'נייד'){
                m.Salesforce_Field__c = 'MobilePhone';
            }else if(m.inwise_Field__c.tolowercase() == 'city' || m.inwise_Field__c== 'עיר'){
                m.Salesforce_Field__c = 'City';
            }else if(m.inwise_Field__c.tolowercase() == 'company' || m.inwise_Field__c== 'שם חברה'){
                m.Salesforce_Field__c = 'Company';
            }  
        }
    }

    public void doDeletePreviousMapping(Id syncId){
        Set<Id> setOfSyncId = new Set<Id>();
        List<Landing_Sync_Mapping__c> listOfMappings = new List<Landing_Sync_Mapping__c>();
        if(syncId != NULL){
            if(Schema.sObjectType.Landing_Sync_Mapping__c.isAccessible() && Schema.sObjectType.Landing_Sync_Mapping__c.fields.Landing_Sync__c.isAccessible() ){

                listOfMappings = [Select Id from Landing_Sync_Mapping__c where Landing_Sync__c =:syncId];   
            }  
            if(!listOfMappings.isEmpty()){
                if(Landing_Sync_Mapping__c.sObjectType.getDescribe().isDeletable()){
                    delete listOfMappings;   
                }
            }
        }
    }

    public with sharing class WrapperSync{

        public Landing_Sync__c objSync {get;set;}
         public String selectedAccount{get;set;} 
         public String selectedAccountName{get;set;}
        
        public boolean Step1{get;set;}
        public boolean Step2{get;set;}
        public String currentStep {get;set;}
        public boolean isCanProceed {get;set;}
        public List<Landing_Sync_Mapping__c> listOfLandingSyncMapping {get;set;}
        
        public String CONS_STEP1{get{
            return 'Step1';
        }}
        
        public String CONS_STEP2{get{
            return 'Step2';
        }}
        
        public WrapperSync(){
            objSync = new Landing_Sync__c();
            objSync.Leads__c = true;
            listOfLandingSyncMapping = new List<Landing_Sync_Mapping__c>();
        }
        public WrapperSync(Id sid){
            List<Landing_Sync__c> listOfSync = new List<Landing_Sync__c>();
            if(Schema.sObjectType.Landing_Sync__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Name__c.isAccessible() &&
                Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Id__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Last_Run__c.isAccessible() &&
                Schema.sObjectType.Landing_Sync__c.fields.Last_Run_By__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Leads__c.isAccessible() &&
                Schema.sObjectType.Landing_Sync__c.fields.Scheduled_Daily_At__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Form_Type__c.isAccessible() &&
                Schema.sObjectType.Landing_Sync__c.fields.Account__c.isAccessible() && Schema.sObjectType.Account__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Name.isAccessible()){

                listOfSync = [SELECT Landing_Page_Name__c, Landing_Page_Id__c, Last_Run__c, Last_Run_By__c, Leads__c, Scheduled_Daily_At__c, Name,Form_Type__c,Account__c,Account__r.name FROM Landing_Sync__c where Id=:sid WITH SECURITY_ENFORCED];
            }
            if(!listOfSync.isEmpty()){
                objSync = listOfSync.get(0);
                selectedAccount = listOfSync.get(0).Account__c;
                selectedAccountName =  listOfSync.get(0).Account__c != NULL ?  listOfSync.get(0).Account__r.Name : '';
            }
            listOfLandingSyncMapping = new List<Landing_Sync_Mapping__c>();
        }
    }
}