/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Controller class is having code to insert the new Account__c object
Modification Log
----------------
Date                  Version   Developer                  Comments
------------------------------------------------------------------------------------
04/18/2019        1.0.1       K.Goutam                 Add error message for blok size
03/24/2021        1.0.1       K.Goutam                 Add choose multiple user for account
04/05/2021        1.0.1       K.Goutam                 Add logic for edit multiple user [Jira IFS-30]
04/13/2021        1.0.1       K.Goutam                 Add logic show edit button only admin user [IFS-30]
05/07/2021        1.1.2       NLINEAXIS(K.Goutam)      Modified:- filter "Sync leads from inwise forms" & "Sync contacts and leads to inwise" with access filter
06/10/2021        1.1.3       NLINEAXIS(K.Goutam)      Modified:- added new doSyncfromSFtoInwiseReports method.
10/11/2021        1.1.4       NLINEAXIS(S.Vaishnav)    Modified:- added Account_SalesforceUser_Mapping__c.isDeletable()
/***********************************************************************************/

public with sharing class inwiseSetupController {

    public Account__c objInwiseSetup {get;set;} 
    public String toDeleteId {get;set;}

    public String executeSyncId {get;set;}
    public List<Account__c> listOfInwiseSetup {get;set;} 
    public String selectedSyncType {get;set;}
    public List<SelectOption> listOfSyncType {get;set;}
    public List<WrapperSync> listOfWrapperSync{get;set;}
    public List<WrapperLandingSync> listOfWrapperLandingSync{get;set;}
    public List<Campaign> listOfCampaign{get;set;}
    private Integer pageSize = Settings__c.getAll().get('default') != NULL && Settings__c.getAll().get('default').Page_Size__c != NULL? Integer.valueOf(Settings__c.getAll().get('default').Page_Size__c) : 5 ;
    public WrapperPaging objWrapperPaging{get;set;}
    public WrapperPaging objWrapperPagingLandingSync{get;set;}
    public WrapperPaging objWrapperPagingCampaign{get;set;}
    public Boolean isEligibleToProceed {get;set;}
    public inwiseLtngConstants objinwiseLtngConstants{get;set;}
    public String authenticationToken {get;set;}
    public String selectedAccId{get;set;}
    public inwiseUtil objInwiseUtil {get;set;}
    public Boolean isHelpOnload {get;set;}
    public String selectUserIds{get;set;}
    public List<User> listOfUser{get;set;}
    public List<User> listOfSelectedUser{get;set;}
    public List<String> listOfAccMap{get;set;}
    public Boolean isAdminUser {get;set;}

    public List<Account_SalesforceUser_Mapping__c> listOfAccSalesforceUser;
    public String userProfileName ;

    static Set<Id> setOfAccountIds {get{
        return inwiseUtil.getAccessibleAccountIds();
    }}
    public String TurnOnOffEmailOptInOptOutBtnLabel{get{
        if(objInwiseUtil != NULL &&  objInwiseUtil.objInwiseSetting.Toggle_Email_Opt_in_Opt_out__c == true){
            return 'Turn Off Email Opt-in/out';
        }
        return 'Turn On Email Opt-in/out';      
    }}

    public inwiseSetupController(ApexPages.StandardController controller){

        objinwiseLtngConstants = new inwiseLtngConstants();
        Settings__c custumsetRecord;
        objInwiseSetup = new Account__c(); 
        listOfSyncType = new List<SelectOption>();
        listOfSyncType.add(new SelectOption('Contact','Contact'));
        listOfSyncType.add(new SelectOption('Lead','Lead'));
        objWrapperPaging = new WrapperPaging(0,0,'Name',true);
        objWrapperPagingLandingSync = new WrapperPaging(0,0,'Name',true);
        objWrapperPagingCampaign = new WrapperPaging(0,0,'LastModifiedDate',false);
        isEligibleToProceed = false;
        objInwiseUtil = new InwiseUtil(null);
        selectUserIds = '';
        listOfAccSalesforceUser = new List<Account_SalesforceUser_Mapping__c>();
        listOfUser = new List<User>();
        listOfSelectedUser = new List<User>();
        listOfAccMap = new List<String>();
        isAdminUser = true;
        fetchUserRecord(); 
        
        if(Schema.sObjectType.profile.isAccessible() && Schema.sObjectType.profile.fields.Name.isAccessible() ){
            userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
        }
        String currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        //System.debug('==userProfileName=='+userProfileName);
        if(currentRecordId != null){
            fetchInwiseAccountRecord(currentRecordId);
            fetchSelectUser(currentRecordId);
        }
            
        if(objInwiseUtil.CheckIfCredentialExists() && objInwiseUtil.CheckIfMappingExists()){
            isEligibleToProceed = true; 
        } 

        List<String> listOfFinalUserProfileName = new List<String>(); 
        for(Setting__mdt customMetadataObj : [SELECT Id, MasterLabel, DeveloperName, Setting_Value__c FROM Setting__mdt WHERE MasterLabel = 'System Admin Profile' LIMIT 10000]) {
            listOfFinalUserProfileName.add(customMetadataObj.Setting_Value__c); 
        }
        isAdminUser = listOfFinalUserProfileName.contains(userProfileName);  
        refreshSync(objWrapperPaging);
        refreshLandingSync(objWrapperPagingLandingSync);
        refreshCampaignList(objWrapperPagingCampaign);
        refresh();
        
        List<Settings__c> listOfSettings = [Select id,Sync_Members_Batch_Size__c from Settings__c LIMIT 1];
        if(listOfSettings != null && !listOfSettings.isEmpty()){
            custumsetRecord =listOfSettings.get(0);
            if(custumsetRecord.Sync_Members_Batch_Size__c>200){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info ,'Block size in custom setting is more than 200.it should be between 3 to 200.'));
            }
            if(custumsetRecord.Sync_Members_Batch_Size__c<3 ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info ,'Block size in custom setting is Less than 3.it should be between 3 to 200.'));
            }
        }
    } 

    private void fetchUserRecord() {
    	// TODO prepare query string for complex serarches & prevent injections
        if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Name.isAccessible()) {
            listOfUser = [SELECT Id, Name FROM User LIMIT 49999]; 
        }  
    } 

    private void fetchSelectUser(String currentInwiseAccRecordId) {
    	// TODO prepare query string for complex serarches & prevent injections
        if(Schema.sObjectType.Account_SalesforceUser_Mapping__c.isAccessible() && Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.Account__c.isAccessible() &&
           Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isAccessible()) {

            for(Account_SalesforceUser_Mapping__c accMapObj : [SELECT Id, Account__c, User__c FROM Account_SalesforceUser_Mapping__c WHERE Account__c =: currentInwiseAccRecordId LIMIT 49999]){
                listOfAccMap.add(accMapObj.User__c);
            }
        }
        if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Name.isAccessible() ){
            listOfSelectedUser = [SELECT Id, Name FROM User WHERE Id =: listOfAccMap LIMIT 49999];
        }  
    } 

    private void fetchInwiseAccountRecord(String currentInwiseAccRecordId) {
    	// TODO prepare query string for complex serarches & prevent injections
        if(Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
          Schema.sObjectType.Account__c.fields.Token__c.isAccessible() && Schema.sObjectType.Account__c.fields.Default__c.isAccessible() &&
          Schema.sObjectType.Account__c.fields.Default_Campaign_Type__c.isAccessible() && Schema.sObjectType.Account__c.fields.SMS_Sender__c.isAccessible() &&
          Schema.sObjectType.Account__c.fields.Country__c.isAccessible() && Schema.sObjectType.Account__c.fields.Trim_Leading_Zero__c.isAccessible() ) {

            objInwiseSetup = [SELECT Id, Name, Token__c, Default__c, Default_Campaign_Type__c, SMS_Sender__c, Country__c, Trim_Leading_Zero__c FROM Account__c WHERE Id =: currentInwiseAccRecordId WITH SECURITY_ENFORCED LIMIT 1]; 
            
            if(Schema.sObjectType.Token_Setting__c.isAccessible() ) {
                List<Token_Setting__c> existingSettings = [ SELECT Id, Account_Id__c, Token__c FROM Token_Setting__c WHERE Account_Id__c = : currentInwiseAccRecordId WITH SECURITY_ENFORCED LIMIT 1];
                if(existingSettings.size() > 0){
                    // String strToken = inwiseUtil.decryptToken(existingSettings[0].Token__c);
                    // if(strToken == null){
                    //     objInwiseSetup.Token__c = existingSettings[0].Token__c;
                    // } else {
                    //     objInwiseSetup.Token__c = strToken;
                    // }
                    if(existingSettings[0].Token__c != null){
                        objInwiseSetup.Token__c = existingSettings[0].Token__c;
                    }
                    //objInwiseSetup.Token__c = inwiseUtil.decryptToken(existingSettings[0].Token__c);
                }
            }
        }  
    } 
    
    public  PageReference  getAuthenticationToken(){
        List<Logs__c> listOfLogs = new List<Logs__c>();
        Account__c objAccount;
        Token_Setting__c objTokenSetting;
        String tokenFromSetting ;
        if(!String.isEmpty(selectedAccId)){
            //List<Account__c> listOfAccount = [select User_Name__c, Password__c from Account__c where id = : selectedAccId]; 
            List<Token_Setting__c> existingSettings = [ SELECT Id, Account_Id__c, Token__c FROM Token_Setting__c 
                                                        WHERE Account_Id__c = : selectedAccId WITH SECURITY_ENFORCED LIMIT 1];
            // if(!listOfAccount.isEmpty()){
            //     objAccount = listOfAccount.get(0);
            // } 

            if(!existingSettings.isEmpty()){
                objTokenSetting = existingSettings.get(0);
                // String deToken = inwiseUtil.decryptToken(objTokenSetting.Token__c);
                // if(deToken == null ){
                //     tokenFromSetting = objTokenSetting.Token__c;
                // } else {
                //     tokenFromSetting = deToken;
                // }

                if(objTokenSetting.Token__c != null){
                    tokenFromSetting = objTokenSetting.Token__c;
                }

            } 

            HttpResponse res;
            String endpoint = objInwiseUtil.apiUrl + '/rest/v1/accounts/getToken'; 
            HttpRequest req = objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint); 
            req.setHeader('X-Api-Key',tokenFromSetting);      
            req.setBody('');
            Http http = new Http();  
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/accounts/getToken','inwiseSetupController','getAuthenticationToken'));                       
            }else{
                String resBody = '"r-c4e5463d46b342cea62f4594aaf438f6"';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res.getStatusCode() == 200 && res.getBody() != NULL){
                System.debug('Token successfully fetched.');
                authenticationToken = res.getBody();
                authenticationToken = authenticationToken.replace('r-', 'm-');
                authenticationToken = authenticationToken.replace('"', '');   
            }else {
                String resBody = res.getBody();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,resBody));         
            }
        }
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        }        
        return null;
    }
   
    public PageReference deleteSync(){
        if(toDeleteId != NULL && toDeleteId != ''){
            if(Sync__c.sObjectType.getDescribe().isDeletable()){    
                Sync__c t = new Sync__c(Id=toDeleteId);
                delete t;
            }   
        } 
        refreshSync(objWrapperPaging);
        
        return null;
    }

    public PageReference deleteLandingSync(){
        if(toDeleteId != NULL && toDeleteId != ''){
            if(Landing_Sync__c.sObjectType.getDescribe().isDeletable()){    
                Landing_Sync__c t = new Landing_Sync__c(Id=toDeleteId);
                delete t;
            }   
        } 
        refreshLandingSync(objWrapperPagingLandingSync);
        
        return null;
    }

    public void refreshSync(WrapperPaging objWrapperPaging){
        String soqlString = '';
        if(Schema.sObjectType.Sync__c.isAccessible() && Schema.sObjectType.Sync__c.fields.Name.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Campaign_Members__c.isAccessible() && Schema.sObjectType.Sync__c.fields.Campaign_Members_SOQL__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Contacts__c.isAccessible() && Schema.sObjectType.Sync__c.fields.Contacts_SOQL__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Group_Id__c.isAccessible() && Schema.sObjectType.Sync__c.fields.Group_Name__c.isAccessible() && 
            Schema.sObjectType.Sync__c.fields.Last_Run__c.isAccessible() && Schema.sObjectType.Sync__c.fields.Last_Run_By__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Leads__c.isAccessible() && Schema.sObjectType.Sync__c.fields.Leads_SOQL__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Scheduled_Daily_At__c.isAccessible() && Schema.sObjectType.Sync__c.fields.Last_JobName__c.isAccessible() &&
            Schema.sObjectType.Sync__c.fields.Account__c.isAccessible() && Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Name.isAccessible()){

            soqlString = 'SELECT Id,Name,Campaign_Members__c, Campaign_Members_SOQL__c, Contacts__c, Contacts_SOQL__c, Group_Id__c, Group_Name__c, Last_Run__c, Last_Run_By__c, Leads__c, Leads_SOQL__c,Scheduled_Daily_At__c,Last_JobName__c,Account__c, Account__r.Name FROM Sync__c ';
        }
        if(isAdminUser){
            soqlString += ' Order By ';
        }else{
            soqlString += ' where Account__c IN:setOfAccountIds Order By ';
        }
        soqlString += String.escapeSingleQuotes(objWrapperPaging.sortColumn) +  (objWrapperPaging.isAscSort ? ' asc NULLS LAST' : ' desc NULLS LAST');
        String countQuery =  'SELECT count() FROM Sync__c ';
        if(!isAdminUser){
            countQuery += ' where Account__c IN:setOfAccountIds';
        }
        soqlString +=  ' LIMIT ' + pageSize + ' OFFSET ' + objWrapperPaging.offset;
        listOfWrapperSync = new List<WrapperSync>();
        Set<String> setOfJobNames = new Set<String>();
        WrapperSync objWrapperSync;
        List<Sync__c> listOfSync = Database.query(soqlString);
        if(listOfSync == NULL){
            listOfSync = new List<Sync__c>();
        }else{
            objWrapperPaging.totalCount = Database.countQuery(countQuery);
        }
        for(Sync__c ls:listOfSync){
            if(ls.Last_JobName__c != NULL){
                setOfJobNames.add(ls.Last_JobName__c);    
            }
        }
        Map<String,CronTrigger> mapOfJobStatus = getJobStatusMap(setOfJobNames);
        for(Sync__c ls:listOfSync){
            objWrapperSync = new WrapperSync(ls);
            if(!mapOfJobStatus.isEmpty() && mapOfJobStatus.get(ls.Last_JobName__c) != NULL){
                    objWrapperSync.jobStatus = mapOfJobStatus.get(ls.Last_JobName__c).state;
                    objWrapperSync.jobStartTime = mapOfJobStatus.get(ls.Last_JobName__c).NextFireTime;
            }
            listOfWrapperSync.add(objWrapperSync);       
        }
        objWrapperPaging.paginationString = (objWrapperPaging.offset + 1) + '-' + (objWrapperPaging.offset + pageSize > objWrapperPaging.totalCount ? objWrapperPaging.totalCount : objWrapperPaging.offset + pageSize) + ' Of ' + objWrapperPaging.totalCount;
    }

    public void refreshCampaignList(WrapperPaging objWrapperPagingCampaign){
        
        String soqlString = '';
        if (Schema.sObjectType.Campaign.isAccessible() 
            && Schema.sObjectType.Campaign.fields.Id.isAccessible() 
            && Schema.sObjectType.Campaign.fields.Name.isAccessible() 
            && Schema.sObjectType.Campaign.fields.Campaign_Type__c.isAccessible()
            && Schema.sObjectType.Campaign.fields.Sendid__c.isAccessible()
            && Schema.sObjectType.Campaign.fields.Sent__c.isAccessible()
            && Schema.sObjectType.Campaign.fields.Opened__c.isAccessible()
            && Schema.sObjectType.Campaign.fields.Opens_Unique__c.isAccessible()
            && Schema.sObjectType.Campaign.fields.Clicked__c.isAccessible()
            && Schema.sObjectType.Campaign.fields.Clicks_Unique__c.isAccessible()
            && Schema.sObjectType.Campaign.fields.Bounced__c.isAccessible()) {

            soqlString = ' SELECT Id,Name,Campaign_Type__c, Sendid__c, Sent__c,Opened__c, Opens_Unique__c, Clicked__c, Clicks_Unique__c,Bounced__c,LastModifiedDate FROM Campaign where Sendid__c != null Order BY ';
        
            soqlString += String.escapeSingleQuotes(objWrapperPagingCampaign.sortColumn) +  (objWrapperPagingCampaign.isAscSort ? ' asc NULLS LAST' : ' desc NULLS LAST');
        }
        String countQuery =  'SELECT count() FROM Campaign where Sendid__c != NULL';

        soqlString +=  ' LIMIT ' + pageSize + ' OFFSET ' + objWrapperPagingCampaign.offset;
        // listOfCampaign = new List<Campaign>();
        WrapperLandingSync objWrapperLandingSync;
        Set<String> setOfJobNames = new Set<String>();
        System.debug('soqlString::---->>>' + soqlString);
        listOfCampaign = Database.query(soqlString);
        System.debug('listOfCampaign::-->>>>' + listOfCampaign.size());

        if(listOfCampaign == NULL){
            listOfCampaign = new List<Campaign>();
        }else{
            objWrapperPagingCampaign.totalCount = Database.countQuery(countQuery);
        }
        
        objWrapperPagingCampaign.paginationString = (objWrapperPagingCampaign.offset + 1) + '-' + (objWrapperPagingCampaign.offset + pageSize > objWrapperPagingCampaign.totalCount ? objWrapperPagingCampaign.totalCount : objWrapperPagingCampaign.offset + pageSize) + ' Of ' + objWrapperPagingCampaign.totalCount;
    }

    public void refreshLandingSync(WrapperPaging objWrapperPagingLandingSync){
        String soqlString = '';
        String countQuery = '';
        if (Schema.sObjectType.Landing_Sync__c.isAccessible() 
            && Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Name__c.isAccessible()
            && Schema.sObjectType.Landing_Sync__c.fields.Record_Index__c.isAccessible()
            && Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Id__c.isAccessible()
            && Schema.sObjectType.Landing_Sync__c.fields.Last_Run__c.isAccessible()
            && Schema.sObjectType.Landing_Sync__c.fields.Last_Run_By__c.isAccessible()
            && Schema.sObjectType.Landing_Sync__c.fields.Leads__c.isAccessible()
            && Schema.sObjectType.Landing_Sync__c.fields.Scheduled_Daily_At__c.isAccessible()
            && Schema.sObjectType.Landing_Sync__c.fields.Name.isAccessible()
            && Schema.sObjectType.Landing_Sync__c.fields.Last_JobId__c.isAccessible()
            && Schema.sObjectType.Landing_Sync__c.fields.Last_JobName__c.isAccessible()) {

            soqlString = 'SELECT Landing_Page_Name__c,Record_Index__c, Landing_Page_Id__c, Last_Run__c, Last_Run_By__c, Leads__c, Scheduled_Daily_At__c, Name,Last_JobId__c,Last_JobName__c FROM Landing_Sync__c ';
            if(isAdminUser){
                soqlString += ' Order By ';
            }else{
                soqlString += 'where Account__c IN:setOfAccountIds Order By ';
            }
            soqlString += String.escapeSingleQuotes(objWrapperPagingLandingSync.sortColumn) +  (objWrapperPagingLandingSync.isAscSort ? ' asc NULLS LAST' : ' desc NULLS LAST');
            countQuery =  'SELECT count() FROM Landing_Sync__c ';
            if(!isAdminUser){
                countQuery += ' where Account__c IN:setOfAccountIds';
            }
            soqlString +=  ' LIMIT ' + pageSize + ' OFFSET ' + objWrapperPagingLandingSync.offset;
        }
        listOfWrapperLandingSync = new List<WrapperLandingSync>();
        WrapperLandingSync objWrapperLandingSync;
        Set<String> setOfJobNames = new Set<String>();
        List<Landing_Sync__c> listOfLandingSync = Database.query(soqlString);
        if(listOfLandingSync == NULL){
            listOfLandingSync = new List<Landing_Sync__c>();
        }else{
            objWrapperPagingLandingSync.totalCount = Database.countQuery(countQuery);
        }
        for(Landing_Sync__c ls:listOfLandingSync){
            if(ls.Last_JobName__c != NULL){
                setOfJobNames.add(ls.Last_JobName__c);    
            }
        }
        Map<String,CronTrigger> mapOfJobStatus = getJobStatusMap(setOfJobNames);
        for(Landing_Sync__c ls:listOfLandingSync){
            objWrapperLandingSync = new WrapperLandingSync(ls);
            if(!mapOfJobStatus.isEmpty() && mapOfJobStatus.get(ls.Last_JobName__c) != NULL){
                    objWrapperLandingSync.jobStatus = mapOfJobStatus.get(ls.Last_JobName__c).state;
                    objWrapperLandingSync.jobStartTime = mapOfJobStatus.get(ls.Last_JobName__c).NextFireTime;
            }
            listOfWrapperLandingSync.add(objWrapperLandingSync);  
        }
        objWrapperPagingLandingSync.paginationString = (objWrapperPagingLandingSync.offset + 1) + '-' + (objWrapperPagingLandingSync.offset + pageSize > objWrapperPagingLandingSync.totalCount ? objWrapperPagingLandingSync.totalCount : objWrapperPagingLandingSync.offset + pageSize) + ' Of ' + objWrapperPagingLandingSync.totalCount;
    }
    
    public Map<String,CronTrigger> getJobStatusMap(Set<String> setOfjobNames){
        Map<String,CronTrigger> mapOfJobStatus = new Map<String,CronTrigger>();
        List<CronTrigger> listOfCronTrigger = [select id, state,StartTime ,NextFireTime, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name IN:setOfjobNames and CronJobDetail.JobType = '7'];
        if(!listOfCronTrigger.isEmpty()){
            for(CronTrigger ct:listOfCronTrigger){
                mapOfJobStatus.put(ct.CronJobDetail.Name,ct);
            }
        }
        return mapOfJobStatus;
    }
  
    public void refresh(){//@todo - check limit, added as per the scanner code review
        if(Schema.sObjectType.Account__c.isAccessible()){
            //System.debug('UserInfo.getUserId()::-->>' + UserInfo.getUserId());
            if(isAdminUser){
                // Check object and field-level access
                if (Schema.sObjectType.Account__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.User_Name__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Token__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Password__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Default__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Default_Campaign_Type__c.isAccessible() &&
                    Schema.sObjectType.Mapping__c.isAccessible() &&
                    Schema.sObjectType.Mapping__c.fields.Id.isAccessible()) {

                    listOfInwiseSetup = [Select Id, Name,User_Name__c, Token__c,Password__c, Default__c,Default_Campaign_Type__c,(SELECT Id FROM Mapping__r) from Account__c WITH SECURITY_ENFORCED LIMIT 1000];

                }
            }else{
                if (Schema.sObjectType.Account__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.User_Name__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Token__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Password__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Default__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Default_Campaign_Type__c.isAccessible() &&
                    Schema.sObjectType.Mapping__c.isAccessible() &&
                    Schema.sObjectType.Mapping__c.fields.Id.isAccessible()) {

                    listOfInwiseSetup = [Select Id, Name,User_Name__c, Token__c,Password__c, Default__c,Default_Campaign_Type__c,(SELECT Id FROM Mapping__r) from Account__c WHERE Id IN : setOfAccountIds WITH SECURITY_ENFORCED LIMIT 1000];

                }
            }
        }
    }

    public PageReference doInwiseSetup(){
        PageReference pr = Page.inwiseSetup;
        pr.getParameters().put('retUrl', Page.inwiseHome.getUrl());
        pr.setRedirect(true);
        return pr;
    }

    public PageReference doSyncoptout(){
        PageReference pr;
        InwiseUtil objInwiseUtil2;
        System.debug('selectedAccId::-->>' + selectedAccId);
        if(selectedAccId != NULL){
            objInwiseUtil2 = new InwiseUtil(new Account__c(Id=selectedAccId));
            if(objInwiseUtil2 != NULL && objInwiseUtil2.objInwiseSetting != NULL){
                Integer batchSize = objInwiseUtil.getBatchSize();
                BatchSyncOptOutLead objBatchSyncOptOutLead = new BatchSyncOptOutLead();
                objBatchSyncOptOutLead.init(objInwiseUtil2);
                Database.executeBatch(objBatchSyncOptOutLead,batchSize);

                BatchSyncOptOutContact objBatchSyncOptOutContact = new BatchSyncOptOutContact();
                objBatchSyncOptOutContact.init(objInwiseUtil2);
                Database.executeBatch(objBatchSyncOptOutContact,batchSize);
                apexpages.addmessage(new apexpages.message(apexpages.severity.INFO, 'Job has been started!'));
            }
        }
        
        return pr; 
    } 

    public PageReference doExecuteLandingSync(){
        List<Landing_Sync__c> listOfSync = inwiseLandingSyncSchedular.getSyncRecord(executeSyncId);
        if(!listOfSync.isEmpty()){
                inwiseLandingSyncSchedular.InwiseCalloutLandingSync(listOfSync);
                refreshLandingSync(objWrapperPagingLandingSync);
        }
        return null;
    }

    public PageReference doMapping(){
        PageReference pr = Page.inwiseSync;
        pr.setRedirect(true);
        return pr;
    }

    public PageReference doSave(){   
        PageReference pr;
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        Boolean ifAnyErrorNotInsertMap = true;
        List<Logs__c> listOfLogs = new List<Logs__c>();
        List<String> listOfSelectUserId = new List<String>();
        
        if(listOfInwiseSetup.size()<=0 ){
            if(Schema.sObjectType.Account__c.fields.Default__c.isCreateable()){
                   objInwiseSetup.Default__c = true;     
            }
            
        }
        if(Schema.sObjectType.Account__c.isCreateable()){
            if(String.ISBLANK(objInwiseSetup.Name) || String.ISBLANK(objInwiseSetup.Token__c)){
                ifAnyErrorNotInsertMap = false;
                apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Required fields (Account Name / Token) should not be blank'));    
                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord('Required fields (Account Name / Token) should not be blank', 'inwiseSetupController','doSave'));
                //return pr;
            } else {
                
                String authToken = objInwiseSetup.Token__c;
                authToken = authToken.replace('-', '');
                Boolean isValidTolen = validateToken(authToken,listOfLogs);
                if(!isValidTolen){
                    ifAnyErrorNotInsertMap = false;
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Your inwise token (key) is not valid'));  
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord('Your inwise token (key) is not valid', 'inwiseSetupController','doSave'));         
                    //return pr;
                } else {
                    if(Schema.sObjectType.Account__c.fields.Token__c.isCreateable()){
                        objInwiseSetup.Token__c = '';
                    }    
                    insert objInwiseSetup; 
                    
                    if(objInwiseSetup != null){
                        inwiseUtil.createOrUpdateTokenSetting(objInwiseSetup, authToken);
                    }
                        
                    pr = Page.inwiseHome;
                    pr.setRedirect(true);
                }                        
            }         
        }   
        if(Schema.sObjectType.Account_SalesforceUser_Mapping__c.isCreateable() && ifAnyErrorNotInsertMap){ 
            System.debug('selectUserIds::-->>' + selectUserIds);
            if(String.isNotBlank(selectUserIds) && String.isNotEmpty(selectUserIds)){
                listOfSelectUserId = selectUserIds.split(',');
            }
            for(String lsu : listOfSelectUserId) {
                Account_SalesforceUser_Mapping__c accSalesforceUseObj = new Account_SalesforceUser_Mapping__c();
                if(Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.Account__c.isCreateable()){
                    accSalesforceUseObj.Account__c = objInwiseSetup.Id;
                }
                if(Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isCreateable()){
                    accSalesforceUseObj.User__c = lsu;
                }
                listOfAccSalesforceUser.add(accSalesforceUseObj);
            }
            if(listOfAccSalesforceUser.size() > 0){
                insert listOfAccSalesforceUser;
            }
        } 
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                insert listOfLogs;
                //return doCancel();
        }  
        System.debug('listOfErrorLogs=='+listOfErrorLogs);
        if(objInwiseUtil.objInwiseSetting.Track_Errors__c &&  !listOfErrorLogs.isEmpty()){  
            insert listOfErrorLogs; 
        }      
        return pr;
    }

    public PageReference doUpdate(){   
        //System.debug('selectUserIds::-@@@->>' + selectUserIds);
        Savepoint sp;
        PageReference pr;
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        Boolean ifChangeInUser = false;
        List<Logs__c> listOfLogs = new List<Logs__c>();
        List<Account__c> listOfAccUpdate = new List<Account__c>();
        if(Schema.sObjectType.Account__c.isUpdateable()){  
            try{
                String authToken = objInwiseSetup.Token__c;
                authToken = authToken.replace('-', '');
                boolean isValidTolen = validateToken(authToken,listOfLogs);
                System.debug('isValidTolen::-@@@->>' + isValidTolen);
                if(!isValidTolen){ 
                    //ifAnyErrorNotInsertMap = false;
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Your inwise token (key) is not valid'));   
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord('Your inwise token (key) is not valid', 'inwiseSetupController','doUpdate'));   
                    if(objInwiseUtil.objInwiseSetting.Track_Errors__c &&  !listOfErrorLogs.isEmpty()){  
                        insert listOfErrorLogs; 
                    }      
                    return pr;
                } 
                objInwiseSetup.Token__c = '';
                sp = Database.setSavepoint();
                update objInwiseSetup;

                if(objInwiseSetup != null){
                    inwiseUtil.createOrUpdateTokenSetting(objInwiseSetup, authToken);
                }

            }catch(Exception e){
                System.debug('isValidTolen:111:-@@@->>' +e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not update account record. Error: ' + e));
                Database.rollback(sp);
                return pr;
            }
        }
          
        //System.debug('selectUserIds::-->>' + selectUserIds); 
        //System.debug('objInwiseSetup.Id::-->>' + objInwiseSetup.Id);
        Map<String,String> mapOfSelectUserId = new Map<String,String>();
        Set<String> setOfSelectUserId = new Set<String>();
        Set<String> setOfSelectUserId2 = new Set<String>();
        Set<String> setOfAlreadStoreUser = new Set<String>();
        List<String> setOfSelectUserId11 = new List<String>();
        List<Account_SalesforceUser_Mapping__c> listOfAccMapForUpdate = new List<Account_SalesforceUser_Mapping__c>();
        Map<Id,Account_SalesforceUser_Mapping__c> mapOfAccMapForUpdate = new Map<Id,Account_SalesforceUser_Mapping__c>();
        Map<Id,Account_SalesforceUser_Mapping__c> mapOfAccMapForFinalUpdate = new Map<Id,Account_SalesforceUser_Mapping__c>();
        List<Account_SalesforceUser_Mapping__c> listOfAccMapForInsert = new List<Account_SalesforceUser_Mapping__c>();
        List<Account_SalesforceUser_Mapping__c> listOfAccMap = new List<Account_SalesforceUser_Mapping__c>();
        Set<String> listOfAccMapForDelete = new Set<String>();
        List<String> listOfSelectUserId = new List<String>();
        if(String.isNotBlank(selectUserIds) && String.isNotEmpty(selectUserIds)){
            listOfSelectUserId = selectUserIds.split(',');
            setOfSelectUserId.addAll(listOfSelectUserId);
            setOfSelectUserId2.addAll(listOfSelectUserId);
        }
        
        if(listOfSelectUserId.size() > 0){
            for (String str : listOfSelectUserId) {
                mapOfSelectUserId.put(str,str);
            }
        }
        // Check object and field-level access
        if (Schema.sObjectType.Account_SalesforceUser_Mapping__c.isAccessible() &&
            Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.Account__c.isAccessible() &&
            Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isAccessible()) {

            listOfAccMap = [SELECT Id, Account__c, User__c FROM Account_SalesforceUser_Mapping__c WHERE Account__c =: objInwiseSetup.Id LIMIT 49999];
        }
        for (Account_SalesforceUser_Mapping__c str : listOfAccMap) {
            setOfAlreadStoreUser.add(str.User__c);
        }
        if(String.isNotBlank(selectUserIds) && String.isNotEmpty(selectUserIds)){
            setOfSelectUserId2.removeAll(setOfAlreadStoreUser);
            for(Account_SalesforceUser_Mapping__c accMapObj : listOfAccMap) {
                Account_SalesforceUser_Mapping__c accObj = new Account_SalesforceUser_Mapping__c();
                if(listOfSelectUserId.size() > listOfAccMap.size()) {
                    //Add
                    if(mapOfSelectUserId.containsKey(accMapObj.User__c)){
                        setOfSelectUserId.remove(accMapObj.User__c);
                    }else if(!mapOfSelectUserId.containsKey(accMapObj.User__c)){
                        listOfAccMapForDelete.add(accMapObj.User__c);
                    } 
                }else if (listOfSelectUserId.size() < listOfAccMap.size()){
                    //delete
                    if(!mapOfSelectUserId.containsKey(accMapObj.User__c)){
                        listOfAccMapForDelete.add(accMapObj.User__c);
                    } else if(mapOfSelectUserId.containsKey(accMapObj.User__c)){
                        setOfSelectUserId.remove(accMapObj.User__c);
                    }
                }else if (listOfSelectUserId.size() == listOfAccMap.size()){
                    if(!mapOfSelectUserId.containsKey(accMapObj.User__c)){
                        listOfAccMapForUpdate.add(accMapObj);
                        listOfAccMapForDelete.add(accMapObj.User__c); 
                        ifChangeInUser = true;
                    } 
                    setOfSelectUserId.clear();
                }
            }
            if(setOfSelectUserId.size() > 0 && Schema.sObjectType.Account_SalesforceUser_Mapping__c.isCreateable() ) {
                for(String ssu : setOfSelectUserId){
                    Account_SalesforceUser_Mapping__c accSalesforceUseObj = new Account_SalesforceUser_Mapping__c();
                    if(Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.Account__c.isCreateable()){
                        accSalesforceUseObj.Account__c = objInwiseSetup.Id;
                    }
                    if(Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isCreateable()){
                        accSalesforceUseObj.User__c = ssu;
                    }
                    listOfAccMapForInsert.add(accSalesforceUseObj);
                }
            }

            if(listOfSelectUserId.size() == listOfAccMap.size() && ifChangeInUser && Schema.sObjectType.Account_SalesforceUser_Mapping__c.isUpdateable()) {
                setOfSelectUserId11.addAll(setOfSelectUserId2); 
                for(integer newUserL=0; newUserL < setOfSelectUserId11.size(); newUserL++){
                    if(Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isUpdateable() && Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isAccessible()){
                        listOfAccMapForUpdate[newUserL].User__c = setOfSelectUserId11[newUserL];
                    }
                }
            }
        }else{
            listOfAccMapForDelete.addAll(setOfAlreadStoreUser);
        }

        System.debug('listOfAccMap::-->>' + listOfAccMap); 
        System.debug('listOfAccMapForUpdate::-->>' + listOfAccMapForUpdate);  
        System.debug('listOfAccMapForInsert::-->>' + listOfAccMapForInsert);  
        System.debug('listOfAccMapForDelete::-->>' + listOfAccMapForDelete);

        if(listOfAccMapForUpdate.size() > 0 && Account_SalesforceUser_Mapping__c.sObjectType.getDescribe().isUpdateable()){
            try{
                update listOfAccMapForUpdate;
            }catch(dmlexception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not update account record. Error: ' + e));
                Database.rollback(sp);
                return pr;
            }
        }
        if(listOfAccMapForInsert.size() > 0 && Account_SalesforceUser_Mapping__c.sObjectType.getDescribe().isCreateable()){ 
            try{
                insert listOfAccMapForInsert;
            }catch(dmlexception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not insert record. Error: ' + e));
                Database.rollback(sp);
                return pr;
                
            }
        }
        if(listOfAccMapForDelete.size() > 0 && Account_SalesforceUser_Mapping__c.sObjectType.getDescribe().isDeletable()){ 
            try{
                if(Schema.sObjectType.Account_SalesforceUser_Mapping__c.isAccessible() && Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isAccessible() &&
                    Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.Account__c.isAccessible()){

                    List<Account_SalesforceUser_Mapping__c> listOfUserMapping = [SELECT Id FROM Account_SalesforceUser_Mapping__c WHERE User__c =: listOfAccMapForDelete AND Account__c =: objInwiseSetup.Id LIMIT 10000];
                
                    if(!listOfUserMapping.isEmpty()){
                        delete listOfUserMapping;
                    }
                }
            }catch(dmlexception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not delete account record. Error: ' + e));
                Database.rollback(sp);
                return pr;
            }
        }  

        pr = Page.inwiseHome;
        pr.setRedirect(true);   
        return pr;
    }
    
    public PageReference doCancel(){
        PageReference pr = Page.inwiseHome;
        pr.setRedirect(true);        
        return pr;
    }
    
    public PageReference doSyncfromSFtoInwise(){
        PageReference pr;
        pr = Page.inwiseScheduleSync;
        pr.getParameters().put('retUrl',Page.inwiseHome.getUrl());
        pr.setRedirect(true);
        return pr;
    }

    public PageReference doSyncfromSFtoInwiseViews(){
        PageReference pr;
        pr = Page.ScheduleSyncView;
        pr.getParameters().put('retUrl',Page.inwiseHome.getUrl());
        pr.setRedirect(true);
        return pr;
    }

    public PageReference doSyncfromSFtoInwiseReports(){
        PageReference pr;
        pr = Page.ScheduleSyncReport;
        pr.getParameters().put('retUrl',Page.inwiseHome.getUrl());
        pr.setRedirect(true);
        return pr;
    }

    public PageReference doLandingPageSyncfromSFtoInwise(){
        PageReference pr;
        pr = Page.inwiseScheduleLandingSync;
        pr.getParameters().put('retUrl',Page.inwiseHome.getUrl());
        pr.setRedirect(true);
        return pr;
    }

    public PageReference deleteMapping(){
        PageReference pr;
        List<Mapping__c> listOfInwiseMapping;
        if(Schema.sObjectType.Mapping__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible()){
            listOfInwiseMapping = [SELECT Id from Mapping__c where Account__c=:toDeleteId];
        }
        if(!listOfInwiseMapping.isEmpty()){
            if(Mapping__c.sObjectType.getDescribe().isDeletable()){
                delete listOfInwiseMapping;
            }    
            pr = Page.inwiseHome;
            pr.setRedirect(true);
        }
        return pr;
    }

    public PageReference deleteAccount(){
        if(toDeleteId != NULL && toDeleteId != ''){
            if(Account__c.sObjectType.getDescribe().isDeletable()){    
                Account__c s = new Account__c(Id=toDeleteId);
                delete s;
            }    
            refresh();
        }
        return null;
    }

    public PageReference toggleshowhelp(){
        objInwiseUtil.updateOverlayHelp(isHelpOnload);
        PageReference pr = Page.inwiseHome;
        pr.setRedirect(true);    
        return pr;
    }

    public void Next(){
        objWrapperPaging.offset = objWrapperPaging.offset + pageSize;
        refreshSync(objWrapperPaging);   
    }

    public void Previous(){
        objWrapperPaging.offset = objWrapperPaging.offset - pageSize;
        refreshSync(objWrapperPaging);  
    }

    public Boolean hasNext{
        get{
            if((objWrapperPaging.offset + pageSize) >= objWrapperPaging.totalCount)
                return true;
            else
                return false;
        }
        set;
    }

    public Boolean hasPrevious{
        get{
        if(objWrapperPaging.offset == 0)
            return true;
        else
            return false;
        }
        set;
    }

    public void sortResults(){
        refreshSync(objWrapperPaging);
    }

    public void NextLandingSync(){
        objWrapperPagingLandingSync.offset = objWrapperPagingLandingSync.offset + pageSize;
        refreshLandingSync(objWrapperPagingLandingSync);   
    }

    public void PreviousLandingSync(){
        objWrapperPagingLandingSync.offset = objWrapperPagingLandingSync.offset - pageSize;
        refreshLandingSync(objWrapperPagingLandingSync);   
    }

    public Boolean hasNextLandingSync{
        get{
            if((objWrapperPagingLandingSync.offset + pageSize) >= objWrapperPagingLandingSync.totalCount)
                return true;
            else
                return false;
        }
        set;
    }

    public Boolean hasPreviousLandingSync{
        get{
        if(objWrapperPagingLandingSync.offset == 0)
            return true;
        else
            return false;
        }
        set;
    }

    public void sortLandingSyncResults(){
        refreshLandingSync(objWrapperPagingLandingSync);
    }

    public void NextCampaign(){
        objWrapperPagingCampaign.offset = objWrapperPagingCampaign.offset + pageSize;
        refreshCampaignList(objWrapperPagingCampaign);
    }

    public void PreviousCampaign(){
        objWrapperPagingCampaign.offset = objWrapperPagingCampaign.offset - pageSize;
        refreshCampaignList(objWrapperPagingCampaign);
    }

    public Boolean hasNextCampaign{
        get{
            if((objWrapperPagingCampaign.offset + pageSize) >= objWrapperPagingCampaign.totalCount)
                return true;
            else
                return false;
        }
        set;
    }

    public Boolean hasPreviousCampaign{
        get{
            if(objWrapperPagingCampaign.offset == 0)
                return true;
            else
                return false;
        }
        set;
    }

    public void sortResultsCampaign(){
        refreshCampaignList(objWrapperPagingCampaign);
    }

    public boolean  validateToken(String authToken,List<Logs__c> listOfLogs){
        boolean tokenValidated = false;
        HttpResponse res;
        String resBody;
        Http http = new Http();
        String contentType ='application/json';
        String endpoint = objInwiseUtil.apiUrl+ '/rest/v1/contacts/mergeFields';
        HttpRequest req = objInwiseUtil.GetHTTPRequest('GET',contentType,endpoint); 
        req.setHeader('X-Api-Key',authToken);     
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contacts/mergeFields','inwiseSetupController','validateToken'));
            }else{
                 resBody = '[{"id": 1,"description": "Fname","slicing": false,"type": "text","options": null},{"id": 4,"description": "Code","slicing": false,"type": "text","options": null},{"id": 3,"description": "Gender","slicing": true,"type":"text","options":["male","female"]},{"id": 2,"description": "Lname","slicing": false,"type": "text","options": null}]';
                 res = inwiseTestDataFactory.getDumpHttpResponse(resBody, contentType);
            }
            if(res.getStatusCode()==200 && res.getBody() != null){
                resBody=res.getBody();
                list<JsonData> listJsonData = (list<JsonData>)System.JSON.deserialize(resBody, list<JsonData>.class);
                if(listJsonData.size()>0){
                    tokenValidated = true;
                }
            }
        } catch(Exception e){
            System.debug('Exception during token validation '+e.getMessage());
        }
        return tokenValidated;

    }
    
    public String getXMLBody(String usernm, String password){
        String body ='';
        body += '<?xml version="1.0" encoding="utf-8"?>';
        body += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
            body += '<soap:Body>';
                body += '<Logon xmlns="http://www.inwise.com/webservices/v2">';
                    body += '<userName>'+usernm+'</userName>';
                    body += '<password>'+password+'</password>';
                body += '</Logon>';
            body += '</soap:Body>';
        body += '</soap:Envelope>';
        return body;
    }

    public class WrapperPaging{
        public String sortColumn {get;set;}
        public boolean isAscSort {get;set;}
        private integer totalCount{get;set;}
        private integer offset {get;set;}
        //private integer pageSize{get;set;}
        public String paginationString{get;set;}

        public WrapperPaging(integer totalCount, integer offset, String sortColumn, boolean isAscSort){
            this.totalCount = totalCount;
            this.offset = offset;
            this.sortColumn = sortColumn;
            this.isAscSort = isAscSort;
            this.paginationString = '';
            //pageSize = 4;
        }
    } 

    public class WrapperLandingSync{
        public Landing_Sync__c objLandingSync {get;set;}
        public String jobStatus {get;set;}
        public Datetime jobStartTime{get;set;}
        public boolean isNeedToShowClock {get{
            boolean isNeedToShowClock = false;
            if(jobStartTime != NULL ){
                    DateTime before5Mins = jobStartTime.addMinutes(-10);
                    Datetime actualJobTime =  jobStartTime.addMinutes(2);//margin time added 2 minute
                    Datetime currentTime = Datetime.now();
                if(currentTime >= before5Mins && currentTime <= actualJobTime && jobStatus != 'DELETED'){
                        isNeedToShowClock = true;
                }
            } 
            return isNeedToShowClock;
        }}
        public WrapperLandingSync(Landing_Sync__c objSync){
            if(objSync != NULL){
                this.objLandingSync = objSync;
            }else{
                this.objLandingSync = new Landing_Sync__c();
            }
            this.jobStatus = '';
            //isNeedToShowClock = false;     
        }
    }

    public class WrapperSync{
        public Sync__c objSync {get;set;}
        public String jobStatus {get;set;}
        public Datetime jobStartTime{get;set;}
        public boolean isNeedToShowClock {get{
            boolean isNeedToShowClock = false;
            if(jobStartTime != NULL ){
                    DateTime before5Mins = jobStartTime.addMinutes(-10);
                    Datetime actualJobTime =  jobStartTime.addMinutes(2);//margin time added 2 minute
                    Datetime currentTime = Datetime.now();
                if(currentTime >= before5Mins && currentTime <= actualJobTime && jobStatus != 'DELETED'){
                        isNeedToShowClock = true;
                }
            } 
            return isNeedToShowClock;
        }}
        public WrapperSync(Sync__c objSync){
                if(objSync != NULL){
                    this.objSync = objSync;
                }else{
                    this.objSync = new Sync__c();
                }
                this.jobStatus = '';
                //isNeedToShowClock = false;      
        }
    }

    public class JsonData{
        public integer Id{get;set;}
        public String description{get;set;}
        public boolean slicing{get;set;}
        public String type{get;set;}
        public list<options> optionList{get;set;}
    }

    public class options{
        public String options{get;set;}
    }
}