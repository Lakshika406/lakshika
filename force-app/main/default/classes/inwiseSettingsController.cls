/******************************************************************************************
*Created By:  Kapil Goutam
*Created On:  14 Nov 2017
*Purpose :    Controller class which basically build url for logs, sync master  custom setting
* * -----------------------------------------------------
* Modified On       Modified By     Purpose
* 09/14/2019        Kapil Goutam    Added version code
* 05/29/2019        Kapil Goutam    Added new methods for clear incoming wehbooks and redirection list view
* 03/24/2021        Kapil Goutam    Added new 4 button for error logs in 'Logs and Custom Settings' selection
* 14/06/2021        Kapil Goutam    Modified:- Added code to add remote site setting to check if this piece of code generating issue while installation.
* 14/02/2022        NLineAxis       Added new methods for clear Landing Sync(doClearLandingSync function)
* 10/03/2022        Shyam Vaishnav  Setting page improvements
/******************************************************************************************/
public with sharing class inwiseSettingsController {

    public inwiseUtil objInwiseUtil                     {get;set;}
    public Boolean isAdvancedFeaturesBtnDisabled        {get;set;}
    public inwiseLtngConstants objinwiseLtngConstants   {get;set;}
    
    public Settings__c objInwiseSetting;
    
    public inwiseSettingsController(ApexPages.StandardController controller){
        Settings__c objInwiseSetting = Settings__c.getAll().get('default');
        isAdvancedFeaturesBtnDisabled = objInwiseSetting != NULL ? objInwiseSetting.Activate_Advanced_Features__c : false;
        objInwiseUtil = new InwiseUtil(null); 
        objinwiseLtngConstants = new inwiseLtngConstants();
    }

    public String turnOnOffCampaignSyncBtnLabel{get{
        if(objInwiseUtil != NULL &&  String.isEmpty(objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Job_Id__c)){
            return 'Turn On Campaign Sync';
        }
        return 'Turn Off Campaign Sync';
    }}

    public PageReference turnOnOffCampaignSync(){

        PageReference pr;
        if(objInwiseUtil != NULL && objInwiseUtil.objInwiseSetting != NULL){
            if(String.isEmpty(objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Job_Id__c)){//means there is no job scheduled yet
                String cronjobid = inwiseCampaignMemberActionSchedularV2.schedulejob(null);
                Settings__c objInwiseSetting = new Settings__c(Id = objInwiseUtil.objInwiseSetting.Id);
                if(Schema.sObjectType.Settings__c.fields.Campaign_Member_Action_Job_Id__c.isUpdateable()){
                    objInwiseSetting.Campaign_Member_Action_Job_Id__c = cronjobid;
                }
                if(Schema.sObjectType.Settings__c.isUpdateable()){
                    update objInwiseSetting;
                }
            }
            else{
                if(!String.isEmpty(objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Job_Id__c)){
                    try{
                        System.abortJob(objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Job_Id__c);
                    }catch(Exception ex){
                        System.debug('abort failed::-->>>' + ex.getMessage());
                    }
                    Settings__c objInwiseSetting = new Settings__c(Id=objInwiseUtil.objInwiseSetting.Id);
                    if(Schema.sObjectType.Settings__c.fields.Campaign_Member_Action_Job_Id__c.isUpdateable()){
                        objInwiseSetting.Campaign_Member_Action_Job_Id__c = NULL;
                    }
                    if(Schema.sObjectType.Settings__c.isUpdateable()){
                        update objInwiseSetting;
                    }                 
                }
            }
        }
        return pr;
    }

    public String currentPackageVersion{get{
        String packageversion = '';
        Schema.DescribeSObjectResult dsr = Landing_Sync__c.sObjectType.getDescribe();
        System.debug('==dsr=='+dsr);
        String namespacePrefix = dsr.getName().remove(dsr.getLocalName());
        System.debug('==namespacePrefix=='+namespacePrefix);
        if(namespacePrefix == 'inwise__'){
            if(UserInfo.isCurrentUserLicensed('inwise__')){
                packageversion = 'Version '+ String.valueOf(System.requestVersion());
                if(System.requestVersion().patch() != null){
                    packageversion += '.' + String.valueOf(System.requestVersion().patch());
                }
            }
        }
        System.debug('==packageversion=='+packageversion);
        return packageversion;
    }}

    public PageReference doInboundSMSConfiguration(){
        PageReference pr = Page.InboundSMSConfiguration;
        pr.setRedirect(true);
        return pr;
    }

    public String turnOnOffLandingSyncBtnLabel{get{
        if(objInwiseUtil != NULL && objInwiseUtil.objInwiseSetting.Landing_Sync_Scheduled__c){
            return 'Turn On Landing Sync';
        }
        return 'Turn Off Landing Sync';
    }}

    public PageReference turnOnOffLandingSync(){

        PageReference pr;
        Landing_Sync__c objLandingSync;
        List<Landing_Sync__c> listOfLandingSyncToUpdate = new List<Landing_Sync__c>();
        String soqlString = '';
        if(Schema.sObjectType.Landing_Sync__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Name__c.isAccessible() &&
            Schema.sObjectType.Landing_Sync__c.fields.Record_Index__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Id__c.isAccessible() &&
            Schema.sObjectType.Landing_Sync__c.fields.Last_Run__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Last_Run_By__c.isAccessible() &&
            Schema.sObjectType.Landing_Sync__c.fields.Leads__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Scheduled_Daily_At__c.isAccessible() && 
            Schema.sObjectType.Landing_Sync__c.fields.Last_JobId__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Last_JobName__c.isAccessible()){

            soqlString = 'SELECT Landing_Page_Name__c,Record_Index__c, Landing_Page_Id__c, Last_Run__c, Last_Run_By__c, Leads__c, Scheduled_Daily_At__c, Name,Last_JobId__c,Last_JobName__c FROM Landing_Sync__c';

        }

        List<inwiseSetupController.WrapperLandingSync> listOfWrapperLandingSync = new List<inwiseSetupController.WrapperLandingSync>();
        List<Landing_Sync__c> listOfLandingSync = Database.query(soqlString);
        
        if(!listOfLandingSync.isEmpty()){
            for(Landing_Sync__c ls:listOfLandingSync){
                inwiseSetupController.WrapperLandingSync objWrapperLandingSync = new inwiseSetupController.WrapperLandingSync(ls);
                listOfWrapperLandingSync.add(objWrapperLandingSync);
            }
        }
        if(objInwiseUtil != NULL && objInwiseUtil.objInwiseSetting != NULL){
            Boolean isToggleSettingMethodCalled = false;         
            if(objInwiseUtil.objInwiseSetting.Landing_Sync_Scheduled__c){//already on means terminate all the jobs & update this to false                
                for(inwiseSetupController.WrapperLandingSync  wsync: listOfWrapperLandingSync){
                    if(String.isNotBlank(wsync.objLandingSync.Last_JobId__c)){
                        try{                       
                            System.abortJob(wsync.objLandingSync.Last_JobId__c);
                        }catch(Exception ex){
                            System.debug('abort failed::-->>>' + ex.getMessage());
                            //issue fix - 27 Feb 2018, toggle setting field in case of job already deleted from scheduled job
                            toggleSettingLandingSync();
                            isToggleSettingMethodCalled = true;
                        }
                    }
                    objLandingSync = new Landing_Sync__c(Id = wsync.objLandingSync.Id);
                    if(Schema.sObjectType.Landing_Sync__c.fields.Last_JobName__c.isUpdateable()){
                        objLandingSync.Last_JobName__c = NULL;
                    }
                    if(Schema.sObjectType.Landing_Sync__c.fields.Last_JobId__c.isUpdateable()){
                        objLandingSync.Last_JobId__c = NULL;
                    }
                    if(Schema.sObjectType.Landing_Sync__c.isUpdateable()){
                        listOfLandingSyncToUpdate.add(objLandingSync);
                    }
                }
            }
            else{//means on all jobs for next hour
                if(!listOfWrapperLandingSync.isEmpty()){
                    for(inwiseSetupController.WrapperLandingSync  wsync: listOfWrapperLandingSync){
                        objLandingSync = new Landing_Sync__c(Id=wsync.objLandingSync.Id);
                        listOfLandingSyncToUpdate.add(inwiseLandingSyncSchedular.schedulejob(objLandingSync, true));
                    }
                }
            }

            if(!listOfLandingSyncToUpdate.isEmpty()){
                if(Schema.sObjectType.Landing_Sync__c.isUpdateable()){
                    update listOfLandingSyncToUpdate;
                }
                if(!isToggleSettingMethodCalled){
                    toggleSettingLandingSync();
                }
            }
        }
        return pr;
    }

    public void toggleSettingLandingSync(){
        if(Schema.sObjectType.Settings__c.isAccessible()){
            Boolean isTrue = false;
            Settings__c objInwiseSettingDB = Settings__c.getAll().get('default');
            Settings__c objInwiseSetting = new Settings__c(Id = objInwiseSettingDB.Id);           
            if(Schema.sObjectType.Settings__c.fields.Landing_Sync_Scheduled__c.isAccessible()){
                isTrue = objInwiseSettingDB.Landing_Sync_Scheduled__c == true ? false : true;
            }
            if(Schema.sObjectType.Settings__c.fields.Landing_Sync_Scheduled__c.isUpdateable()){               
                objInwiseSetting.Landing_Sync_Scheduled__c = isTrue;
            }
            if(Schema.sObjectType.Settings__c.isUpdateable()){
                update objInwiseSetting;
            }
        }
    }

    public PageReference redirectToListView( String sObjectName ){
        String url;
        PageReference pr;
        String sObjectNameWithPrefix = 'inwise__' + sObjectName;
        List<ListView> listOfListViews = new List<ListView>();
        if(Schema.sObjectType.ListView.isAccessible() && Schema.sObjectType.ListView.fields.Name.isAccessible() &&
            Schema.sObjectType.ListView.fields.sobjectType.isAccessible()){

            listOfListViews = [Select Id,Name,sobjectType from ListView where (sobjectType =:sObjectName OR sobjectType =:sObjectNameWithPrefix) and Name = 'All'];

        }
        if(objinwiseLtngConstants.isLightning){
            if(!listOfListViews.isEmpty()){
                url = '/one/one.app?source=aloha#/sObject/' + listOfListViews.get(0).sobjecttype + '/list?filterName=' + listOfListViews.get(0).Id;
            }
        }else{
            if(!listOfListViews.isEmpty()){
                Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(listOfListViews.get(0).sobjectType);
                url =  '/' + sObjType.getDescribe().getKeyPrefix() + '/l';
            }    
        }
        
        if(!String.isEmpty(url)){
            pr = new PageReference(url);
            pr.setRedirect(true);  
        }
        return pr;
    }

    public PageReference doReturnLogsUrl(){
        return redirectToListView('Logs__c');
    }

    public PageReference doReturnSyncMasterUrl(){
        return redirectToListView('Sync_Master__c');
    }

    public PageReference doReturnLandingSyncHistoryUrl(){
        return redirectToListView('Landing_Sync_History__c');
    }

    public PageReference doReturnIncomingWebhooksUrl(){
        return redirectToListView('Incoming_Webhooks__c');
    }

    public PageReference doReturnErrorLogsUrl(){
        return redirectToListView('Error_Logs__c');
    }
    
    public PageReference doReturnCustomSettingUrl(){

        String url;
        PageReference pr;
        
        List<Settings__c> listOfCustomSetting = [Select Id,Name  from Settings__c where Name = 'default'];
        if(objinwiseLtngConstants.isLightning){
            //javascript code is executing in this case.
        }else{
            if(!listOfCustomSetting.isEmpty()){
                url =  '/' + listOfCustomSetting.get(0).Id;
            }    
        }
        if(!String.isEmpty(url)){
            pr = new PageReference(url);
            pr.setRedirect(true);  
        }
        return pr;
    }

    public PageReference doClearErrorLogs(){
        inwiseGlobalAction.doClearErrorLogs();
        ApexPages.addMessage(new apexpages.message(ApexPages.Severity.INFO, 'Logs has been deleted'));
        return null;
    }

    public PageReference doClearLogs(){
        inwiseGlobalAction.doClearLogs();
        ApexPages.addMessage(new apexpages.message(ApexPages.Severity.INFO, 'Logs has been deleted'));
        return null;
    }

    public PageReference doClearIncomingWebhooks(){
        inwiseGlobalAction.doClearIncomingWebhooks();
        ApexPages.addMessage(new apexpages.message(ApexPages.Severity.INFO, 'Incoming Webhooks has been deleted'));
        return null;
    }
    
    public PageReference doClearLandingSync(){
        inwiseGlobalAction.doClearLandingSync();
        ApexPages.addMessage(new apexpages.message(ApexPages.Severity.INFO, 'Landing Sync has been deleted'));
        return null;
    }

    public PageReference doSendLogtoinwiseSupport(){
        String msg = inwiseGlobalAction.doSendLogsToSupport();
        ApexPages.addMessage(new apexpages.message(ApexPages.Severity.INFO, msg));
        return null;
    }

    public PageReference doSendErrorLogtoinwiseSupport(){
        String msg = inwiseGlobalAction.doSendErrorLogsToSupport(); 
        ApexPages.addMessage(new apexpages.message(ApexPages.Severity.INFO, msg));
        return null;
    }
    
    public String turnOnOffTrackLogBtnLabel{get{
        Settings__c objInwiseSetting = Settings__c.getAll().get('default');
        if(objInwiseSetting != NULL &&  objInwiseSetting.Track_Logs__c){           
            return 'Turn On Track Log';
        }       
        return 'Turn Off Track Log';
    }}
    
    public void turnOnOffTrackLog(){
        Boolean b = inwiseGlobalAction.doTurnOnOffTrackLog();
    }
    
    public String turnOnOffErrorLogBtnLabel{get{
        Settings__c objInwiseSetting = Settings__c.getAll().get('default');
        if(objInwiseSetting != NULL &&  objInwiseSetting.Track_Errors__c){           
            return 'Tracking is enabled for error';
        }        
        return 'Tracking is disabled for error';
    }}

    public PageReference turnOnOffTrackError(){
        Boolean b = inwiseGlobalAction.doTurnOnOffTrackError();        
        return null;
    }
    
    public String turnOnOffTrackActivityBtnLabel{get{
        Settings__c objInwiseSetting = Settings__c.getAll().get('default');       
        if(objInwiseSetting != NULL &&  objInwiseSetting.Track_inwise_Activities__c){
            return 'Turn On Inwise Activity';
        }       
        return 'Turn Off Inwise Activity';
    }}

    public PageReference turnOnOffTrackActivities(){
        Boolean b = inwiseGlobalAction.doTurnOnOffTrackActivities();       
        return null;
    }

    public void doCheckAndCreateRemoteSite(){ 
        System.debug('==doCheckAndCreateRemoteSite=');

        Boolean isError = false;
        Boolean isRemoteSiteExist = false;
        objInwiseSetting = Settings__c.getAll().get('default');
        MetadataService.ListMetadataQuery remoteSites = new MetadataService.ListMetadataQuery();
        List<MetadataService.ListMetadataQuery> listMetadataQueryList = new List<MetadataService.ListMetadataQuery>();
        
        remoteSites.type_x = 'RemoteSiteSetting';
        listMetadataQueryList.add(remoteSites);
        System.debug('Metadata Query: ' + listMetadataQueryList);
        
        try{
            MetadataService.MetadataPort service = inwiseUtil.createMetadataService();
            System.debug('==doCheckAndCreateRemoteSite=service='+service);
            List<MetadataService.FileProperties> filePropertiesList = new List<MetadataService.FileProperties>();
            if(service != null && service.SessionHeader != null && service.SessionHeader.sessionId != null){
                filePropertiesList = service.listMetadata(listMetadataQueryList, inwiseConstants.METADATA_API_VERSION);
            }
            //List<MetadataService.FileProperties> filePropertiesList = service.listMetadata(listMetadataQueryList, inwiseConstants.METADATA_API_VERSION);
            System.debug('==doCheckAndCreateRemoteSite=filePropertiesList='+filePropertiesList);
            
            if(filePropertiesList != null && filePropertiesList.size() > 0){
                for(MetadataService.FileProperties fileProperties : filePropertiesList){
                    if(fileProperties.fullName == inwiseConstants.ORG_REST_API){
                        isRemoteSiteExist = true;
                        isAdvancedFeaturesBtnDisabled = inwiseGlobalAction.checkAndCreateRemoteSite();
                        break;
                    }
                }
            } else { 
                isError = true;
            }
        }
        catch(Exception exp){
            isError = true;
            Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(exp.getMessage(), 'inwiseSettingsController', 'doCheckAndCreateRemoteSite');
            if(errorLog != null && objInwiseSetting.Track_Errors__c){
                insert errorLog;
            }
        }

        if(isRemoteSiteExist){
            Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(inwiseConstants.ADVANCED_FEATURES_ALREADY, 'inwiseSettingsController', 'doCheckAndCreateRemoteSite');
            if(errorLog != null && objInwiseSetting.Track_Errors__c){ 
                insert errorLog;
            }
            ApexPages.addMessage(new apexpages.message(ApexPages.Severity.ERROR, inwiseConstants.ADVANCED_FEATURES_ERROR));
        }
        else if(isError){
            ApexPages.addMessage(new apexpages.message(ApexPages.Severity.ERROR, inwiseConstants.ADVANCED_FEATURES_ERROR));
        }

        if((!isError && !isRemoteSiteExist) || Test.isrunningTest()){
            doCreateRemoteSite();
        }
    }
    
     private void doCreateRemoteSite(){

        System.debug('==doCreateRemoteSite=');
        
        List<MetadataService.Metadata> metadataList = new List<MetadataService.Metadata>();
        MetadataService.RemoteSiteSetting remoteSiteDetails = new MetadataService.RemoteSiteSetting();
        remoteSiteDetails.isActive = true;
        remoteSiteDetails.disableProtocolSecurity = false;
        remoteSiteDetails.fullName = inwiseConstants.ORG_REST_API;
        remoteSiteDetails.url = inwiseConstants.ORGANIZATION_BASE_URL;
        metadataList.add(remoteSiteDetails);
        
        try{
            Boolean isSucessfull = false;
            MetadataService.MetadataPort service = inwiseUtil.createMetadataService();
            List<MetadataService.UpsertResult> results = new List<MetadataService.UpsertResult>();
            if(service != null && service.SessionHeader != null && service.SessionHeader.sessionId != null){
                results = service.upsertMetadata(metadataList);
            }
            //List<MetadataService.UpsertResult> results = service.upsertMetadata(metadataList);
            
            if(results != null && results.size() > 0){
                MetadataService.UpsertResult result = results[0];
                if(result.success){
                    isSucessfull = true;
                    isAdvancedFeaturesBtnDisabled = inwiseGlobalAction.checkAndCreateRemoteSite();
                    ApexPages.addMessage(new apexpages.message(ApexPages.Severity.CONFIRM, inwiseConstants.ADVANCED_FEATURES_ACTIVATED));
                }
                else{
                    if(result.errors != null && result.errors.size() > 0){
                        Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(result.errors[0].message, 'inwiseSettingsController', 'doCreateRemoteSite');
                        if(errorLog != null && objInwiseSetting.Track_Errors__c){
                            insert errorLog;
                        } 
                        ApexPages.addMessage(new apexpages.message(ApexPages.Severity.ERROR, inwiseConstants.ADVANCED_FEATURES_ERROR));
                    }
                }
            }
        }
        catch(Exception exp){
            Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(exp.getMessage(), 'inwiseSettingsController', 'doCreateRemoteSite');
            if(errorLog != null && objInwiseSetting.Track_Errors__c){
                insert errorLog;
            }
            ApexPages.addMessage(new apexpages.message(ApexPages.Severity.ERROR, inwiseConstants.ADVANCED_FEATURES_ERROR));
        }
    }
}