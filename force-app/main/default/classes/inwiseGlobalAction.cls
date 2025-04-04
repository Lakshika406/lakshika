/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 18 July 2017 
*Purpose :     all web services
* * -----------------------------------------------------
* Modified On       Modified By     Purpose
* 05/29/2019        Kapil Goutam    Added method for  delete all the Incoming Webhooks when clicked on list button
* 11/25/2020        Kapil Goutam    commented clearall method logic as this was creating issue for some client
* 03/24/2021        Kapil Goutam    Created error log record [IFS-37 Jira]
* 14/06/2021        Kapil Goutam    Modified:- Added new method checkAndCreateRemoteSite().
* 11/02/2021        S. Vaishnav     Modified:- added isUpdateable()
* 11/03/2021        S. Vaishnav     Modified:- added new method getDefaultSettings()
* 14/02/2022        NlineAxis       Modified:-added new method doClearLandingSync()
******************************************************************************************/
global with sharing class inwiseGlobalAction {

    public static String sCONSTContact{get{
        return inwiseConstants.SOBJECT_CONTACT;
    }}
    public static String sCONSTLead{get{
        return inwiseConstants.SOBJECT_LEAD;
    }}

    public String resultMessage { get; set; }
    
    public inwiseGlobalAction(ApexPages.StandardController std){} 

    public inwiseGlobalAction(){}

    /**
     * Method to delete all logs when clicked on the list button.
     * Limited to 10,000 records for security and performance.
     */
    @RemoteAction
    public static String remoteClearLogs() {
        try {
            // Check if Logs__c object is accessible and deletable
            if (Logs__c.SObjectType.getDescribe().isAccessible() && Logs__c.SObjectType.getDescribe().isDeletable()) {
                // Query logs to delete (LIMIT added for safety)
                List<Logs__c> logsToDelete = [SELECT Id FROM Logs__c WITH SECURITY_ENFORCED LIMIT 10000];

                // Perform deletion only if records are found
                if (!logsToDelete.isEmpty()) {
                    delete logsToDelete;
                }
                return 'Logs successfully deleted.';
            } else {
                return 'You do not have the required permissions to delete logs.';
            }
        } catch (Exception e) {
            // Log and handle errors
            System.debug('Error while clearing logs: ' + e.getMessage());
            return 'An error occurred while deleting logs: ' + e.getMessage();
        }
    }

    /*method will delete all the logs when clicked on list button */
	webservice static void doClearLogs(){
        if(Logs__c.SObjectType.getDescribe().isAccessible() && Logs__c.SObjectType.getDescribe().isDeletable()){
            Delete [Select Id from Logs__c WITH SECURITY_ENFORCED LIMIT 10000]; 
        }
    }

    webservice static void doClearErrorLogs(){
        if(Error_Logs__c.SObjectType.getDescribe().isAccessible() && Error_Logs__c.SObjectType.getDescribe().isDeletable()){
            Delete [Select Id from Error_Logs__c WITH SECURITY_ENFORCED LIMIT 10000]; 
        }
    }

    /* method will delete all the Incoming Webhooks when clicked on list button*/
    webservice static void doClearIncomingWebhooks(){
        if(Incoming_Webhooks__c.SObjectType.getDescribe().isAccessible() && Incoming_Webhooks__c.SObjectType.getDescribe().isDeletable()){
            Delete [Select Id from Incoming_Webhooks__c WITH SECURITY_ENFORCED LIMIT 10000]; 
        }
    }
    
    webservice static void doClearLandingSync(){
        if(Landing_Sync__c.SObjectType.getDescribe().isAccessible() && Landing_Sync__c.SObjectType.getDescribe().isDeletable()){
            Delete [Select Id from Landing_Sync__c WITH SECURITY_ENFORCED LIMIT 10000]; 
        }
    }

    public static void doClearAll(Boolean isTrackLogEnabled){}

    @RemoteAction
    public static String remoteClearSyncMaster(){
        try{
            if(Sync_Master__c.SObjectType.getDescribe().isAccessible() && Sync_Master__c.SObjectType.getDescribe().isDeletable()){
                List<Sync_Master__c> listOfSyncMaster = [Select Id from Sync_Master__c WITH SECURITY_ENFORCED limit 10000];

                if (!listOfSyncMaster.isEmpty()) {
                    delete listOfSyncMaster;
                    return 'All Sync Master records have been deleted.';
                } else {
                    return 'No Sync Master records found to delete.';
                }
            } else {
                return 'You do not have the required permissions to delete Sync Master records.';
            }
        }catch(Exception ex){
            System.debug('exception::-->>' + ex.getMessage());
            return 'An error occurred while deleting Sync Master: ' + ex.getMessage();
        }
    }

    webservice static void doClearSyncMaster(){
        if(Sync_Master__c.SObjectType.getDescribe().isAccessible() && Sync_Master__c.SObjectType.getDescribe().isDeletable()){
            List<Sync_Master__c> listOfSyncMaster = [Select Id from Sync_Master__c WITH SECURITY_ENFORCED limit 10000];
            if(!listOfSyncMaster.isEmpty()){
                try{
                    delete listOfSyncMaster;
                }catch(Exception ex){
                    System.debug('exception::-->>' + ex.getMessage());
                }
            }
        } 
    }

    webservice static void doClearLandingSyncHistory(){
        if(Landing_Sync_History__c.SObjectType.getDescribe().isAccessible() && Landing_Sync_History__c.SObjectType.getDescribe().isDeletable()){
            List<Landing_Sync_History__c> listOfLandingSyncHistory = [Select Id from Landing_Sync_History__c WITH SECURITY_ENFORCED limit 10000];
            if(!listOfLandingSyncHistory.isEmpty()){
                try{
                    delete listOfLandingSyncHistory;
                }catch(Exception ex){
                    System.debug('exception::-->>' + ex.getMessage());
                }
            }
        }
    }

    ////method will remove all logs upto last day
    webservice static void doClearPreviousLogs(){
        //method not in use but can not be commented due to released in previous version as service     
    }

    @remoteAction
    public static Boolean remoteTurnOnOffTrackLog(){
        Settings__c objInwiseSetting = getDefaultSettings();
        if(objInwiseSetting != null && Schema.sObjectType.Settings__c.fields.Track_Logs__c.isUpdateable() && Schema.sObjectType.Settings__c.fields.Track_Logs__c.isCreateable()){
            objInwiseSetting.Track_Logs__c = !objInwiseSetting.Track_Logs__c;
            if(Schema.sObjectType.Settings__c.isUpdateable() && Schema.sObjectType.Settings__c.isCreateable()){
                update objInwiseSetting;
            }
        }
        return objInwiseSetting != null ? objInwiseSetting.Track_Logs__c : false;
    }

    webservice static Boolean doTurnOnOffTrackLog(){
        Settings__c objInwiseSetting = getDefaultSettings();
        if(objInwiseSetting != null && Schema.sObjectType.Settings__c.fields.Track_Logs__c.isUpdateable() && Schema.sObjectType.Settings__c.fields.Track_Logs__c.isCreateable()){
            objInwiseSetting.Track_Logs__c = !objInwiseSetting.Track_Logs__c;
            if(Schema.sObjectType.Settings__c.isUpdateable() && Schema.sObjectType.Settings__c.isCreateable()){
                update objInwiseSetting;
            }
        }
        return objInwiseSetting != null ? objInwiseSetting.Track_Logs__c : false;
    }

    webservice static Boolean doTurnOnOffTrackError(){
        Settings__c objInwiseSetting = getDefaultSettings();
        if(objInwiseSetting != null && Schema.sObjectType.Settings__c.fields.Track_Errors__c.isUpdateable() && Schema.sObjectType.Settings__c.fields.Track_Errors__c.isCreateable()){
            objInwiseSetting.Track_Errors__c = !objInwiseSetting.Track_Errors__c;
            if(Schema.sObjectType.Settings__c.isUpdateable() && Schema.sObjectType.Settings__c.isCreateable()){
                update objInwiseSetting;
            }
        }
        return objInwiseSetting != null ? objInwiseSetting.Track_Errors__c : false;
    } 

    webservice static Boolean doTurnOnOffTrackActivities(){
        Settings__c objInwiseSetting = getDefaultSettings();
        if(objInwiseSetting != null && Schema.sObjectType.Settings__c.fields.Track_inwise_Activities__c.isUpdateable() && Schema.sObjectType.Settings__c.fields.Track_inwise_Activities__c.isCreateable()){
            objInwiseSetting.Track_inwise_Activities__c = !objInwiseSetting.Track_inwise_Activities__c;
            if(Schema.sObjectType.Settings__c.isUpdateable() && Schema.sObjectType.Settings__c.isCreateable()){
                update objInwiseSetting;
            }
        }
        return objInwiseSetting != null ? objInwiseSetting.Track_inwise_Activities__c : false;
    }
 
    webservice static Boolean checkAndCreateRemoteSite(){
        Settings__c objInwiseSetting = getDefaultSettings();
        if(objInwiseSetting != null && Schema.sObjectType.Settings__c.fields.Activate_Advanced_Features__c.isUpdateable() && Schema.sObjectType.Settings__c.fields.Activate_Advanced_Features__c.isCreateable() && !objInwiseSetting.Activate_Advanced_Features__c){
            objInwiseSetting.Activate_Advanced_Features__c = true;
            if(Schema.sObjectType.Settings__c.isUpdateable() && Schema.sObjectType.Settings__c.isCreateable()){
                update objInwiseSetting;
            }
        }
        return objInwiseSetting != null ? objInwiseSetting.Activate_Advanced_Features__c : false;
    }
    
    static Settings__c getDefaultSettings(){
        if(Schema.sObjectType.Settings__c.isAccessible() && Schema.sObjectType.Settings__c.isUpdateable()){
            return Settings__c.getAll().get('default');
        }
        return null;
    }

    webservice static String doSendErrorLogsToSupport(){
        String msg;
        String body = '';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> listOfEmailReceiver = new List<String>{'salesforcesupport@inwise.com'};
        List<Error_Logs__c> listOfLogs = new List<Error_Logs__c>();
        if (Schema.sObjectType.Error_Logs__c.isAccessible() && Schema.sObjectType.Error_Logs__c.fields.Class_Name__c.isAccessible() && 
            Schema.sObjectType.Error_Logs__c.fields.Method_Name__c.isAccessible() && Schema.sObjectType.Error_Logs__c.fields.Message__c.isAccessible() &&
            Schema.sObjectType.Error_Logs__c.fields.Run_By__c.isAccessible() && Schema.sObjectType.Error_Logs__c.fields.Run_On__c.isAccessible() &&
            Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Name.isAccessible()) {

            listOfLogs = [Select Id,Name,Class_Name__c, Method_Name__c, Message__c, Run_By__c,Run_On__c, Run_By__r.Name from Error_Logs__c Order by Name DESC LIMIT 20];
        }
      
        mail.setToAddresses(listOfEmailReceiver);
        if(!listOfLogs.isEmpty()){ 
            for(Error_Logs__c l: listOfLogs){
                body += formatErrorHTML(l);
            }
            mail.setHtmlBody(body);
            mail.setSubject('inwise for Salesforce- Last 20 Logs');
            mails.add(mail);
            if(mails.size() > 0) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
                if(results.isEmpty()){
                    msg =  'Exception in sending email';
                }else{
                    if(results.get(0).isSuccess()){
                        msg =  'Please check mail for recent 20 logs';
                    }else{
                        msg =  String.valueOf(results.get(0).getErrors());  
                    }   
                } 
            }
        }else{
            msg = 'There are no logs to email';
        }    
        return msg;
    }

    webservice static String doSendLogsToSupport(){

        String msg;
        String body = '';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> listOfEmailReceiver = new List<String>{'salesforcesupport@inwise.com'};
        List<Logs__c> listOfLogs = new List<Logs__c>();
        if (Schema.sObjectType.Logs__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Api_Name__c.isAccessible() && 
            Schema.sObjectType.Logs__c.fields.Class_Name__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Method_Name__c.isAccessible() &&
            Schema.sObjectType.Logs__c.fields.Request__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Response__c.isAccessible() &&
            Schema.sObjectType.Logs__c.fields.Run_By__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Run_On__c.isAccessible() &&
            Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Name.isAccessible()) {

            listOfLogs = [Select Id,Name,Api_Name__c,Class_Name__c, Method_Name__c,Request__c,Response__c,  Run_By__c,Run_On__c, Run_By__r.Name from Logs__c Order by Name DESC LIMIT 20];

        }

        mail.setToAddresses(listOfEmailReceiver);
        if(!listOfLogs.isEmpty()){
            for(Logs__c l: listOfLogs){
                body += formatHTML(l);
            }
            mail.setHtmlBody(body);
            mail.setSubject('inwise for Salesforce- Last 20 Logs');
            mails.add(mail);

            if(mails.size() > 0) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
                if(results.isEmpty()){
                    msg = 'Exception in sending email';
                }else{
                    if(results.get(0).isSuccess()){
                        msg = 'Please check mail for recent 20 logs';
                    }else{
                        msg = String.valueOf(results.get(0).getErrors());  
                    }   
                } 
            }
        }else{
            msg = 'There are no logs to email';
        }    
        return msg;
    }

    @RemoteAction
    public static String remoteSendLogsToSupport(){

        String msg;
        String body = '';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> listOfEmailReceiver = new List<String>{'salesforcesupport@inwise.com'};
        List<Logs__c> listOfLogs = new List<Logs__c>();
        if (Schema.sObjectType.Logs__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Api_Name__c.isAccessible() && 
            Schema.sObjectType.Logs__c.fields.Class_Name__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Method_Name__c.isAccessible() &&
            Schema.sObjectType.Logs__c.fields.Request__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Response__c.isAccessible() &&
            Schema.sObjectType.Logs__c.fields.Run_By__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Run_On__c.isAccessible() &&
            Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Name.isAccessible()) {

            listOfLogs = [Select Id,Name,Api_Name__c,Class_Name__c, Method_Name__c,Request__c,Response__c,  Run_By__c,Run_On__c, Run_By__r.Name from Logs__c Order by Name DESC LIMIT 20];

        }
        
        mail.setToAddresses(listOfEmailReceiver);
        if(!listOfLogs.isEmpty()){
            for(Logs__c l: listOfLogs){
                body += formatHTML(l);
            }
            mail.setHtmlBody(body);
            mail.setSubject('inwise for Salesforce- Last 20 Logs');
            mails.add(mail);

            if(mails.size() > 0) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
                if(results.isEmpty()){
                    msg = 'Exception in sending email';
                }else{
                    if(results.get(0).isSuccess()){
                        msg = 'Please check mail for recent 20 logs';
                    }else{
                        msg = String.valueOf(results.get(0).getErrors());  
                    }   
                } 
            }
        }else{
            msg = 'There are no logs to email';
        }    
        return msg;
    }

    private static String formatHTML(Logs__c l){
        String html = '====================================='+'<br/>';
        html += 'Name: ' + l.Name +'<br/>';
        html += 'Api_Name__c: ' + l.Api_Name__c +'<br/>';
        html += 'Class_Name__c: ' + l.Class_Name__c +'<br/>';
        html += 'Method_Name__c: ' + l.Method_Name__c +'<br/>';
        html += 'Run_By__c: ' + l.Run_By__r.Name +'<br/>';
        html += 'Run_On__c: ' + l.Run_On__c +'<br/>';
        html += 'Request__c: ' + l.Request__c +'<br/>';
        html += 'Response__c: ' + l.Response__c +'<br/>';
        html += '=====================================' + '<br/><br/><br/>';
        return html;
    }

    private static String formatErrorHTML(Error_Logs__c l){
        String html = '====================================='+'<br/>';
        html += 'Name: ' + l.Name +'<br/>';
        html += 'Class_Name__c: ' + l.Class_Name__c +'<br/>';
        html += 'Method_Name__c: ' + l.Method_Name__c +'<br/>';
        html += 'Run_By__c: ' + l.Run_By__r.Name +'<br/>';
        html += 'Run_On__c: ' + l.Run_On__c +'<br/>';
        html += 'Message__c: ' + l.Message__c +'<br/>';
        html += '=====================================' + '<br/><br/><br/>';
        return html;
    }

    webservice static String initFailedSyncMaster(Id syncmasterid){
        String msg = '';
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        Sync_Master__c objSyncMaster = inwiseUtil.doGetSyncMaster(syncMasterId);

        if(objInwiseUtil.objInwiseSetting.Log_Sync_Memebers__c){
            if(objSyncMaster.Can_ReSync__c){
                if(objSyncMaster.Total_Memerbs_Count_RollUp__c > objSyncMaster.Processed_Members__c){
                    //BatchSendMemberToInwisev2 objBatchSendMemberToInwise = new BatchSendMemberToInwisev2 ();
                    if(objSyncMaster.Campaign__c != NULL){
                        BatchSendMemberToInwise objBatchSendMemberToInwise = new BatchSendMemberToInwise ();
                        objBatchSendMemberToInwise.init(objSyncMaster.Id,objSyncMaster.Campaign__c,true,true);
                        Database.executeBatch(objBatchSendMemberToInwise,objInwiseUtil.getBatchSize());
                    }
                    
                    //Database.executeBatch(objBatchSendMemberToInwise);
                    msg = 'Sync started for failed record for this Process';  
                }else{
                    msg = 'There are no failed record for this Process';  
                }
            }else{
                if(objSyncMaster.Total_Memerbs_Count_RollUp__c == objSyncMaster.Processed_Members__c){
                    msg = 'There are no failed record for this Process';  
                }else{
                    msg = 'You can not process again due to Log Sync Members was disabled at the time of Sync created.';
                }
            }  
        }
        return msg;
    }

   
    @RemoteAction
    public static String remoteinitFailedSyncMaster(String syncMasterId){

        //String syncMasterId = ApexPages.currentPage().getParameters().get('id');
        System.debug('==remoteinitFailedSyncMaster=syncMasterId='+syncMasterId);
        String msg = '';
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        Sync_Master__c objSyncMaster = inwiseUtil.doGetSyncMaster(syncMasterId);

        if(objInwiseUtil.objInwiseSetting.Log_Sync_Memebers__c){
            if(objSyncMaster.Can_ReSync__c){
                if(objSyncMaster.Total_Memerbs_Count_RollUp__c > objSyncMaster.Processed_Members__c){
                    //BatchSendMemberToInwisev2 objBatchSendMemberToInwise = new BatchSendMemberToInwisev2 ();
                    if(objSyncMaster.Campaign__c != NULL){
                        BatchSendMemberToInwise objBatchSendMemberToInwise = new BatchSendMemberToInwise ();
                        objBatchSendMemberToInwise.init(objSyncMaster.Id,objSyncMaster.Campaign__c,true,true);
                        Database.executeBatch(objBatchSendMemberToInwise,objInwiseUtil.getBatchSize());
                    }
                    
                    //Database.executeBatch(objBatchSendMemberToInwise);
                    msg = 'Sync started for failed record for this Process';  
                }else{
                    msg = 'There are no failed record for this Process';  
                }
            }else{
                if(objSyncMaster.Total_Memerbs_Count_RollUp__c == objSyncMaster.Processed_Members__c){
                    msg = 'There are no failed record for this Process';  
                }else{
                    msg = 'You can not process again due to Log Sync Members was disabled at the time of Sync created.';
                }
            }  
        } else {
            msg = 'Please set Log Sync Memebers true in the custom setting.';     	
        }
        return msg;
    }


    @RemoteAction
    public static List<String> getSelectedPicklistOptions(String fieldapiname, String sobjectName){

        List<String> listOfStringOptions = new List<String>();
        Schema.DescribeSObjectResult objSchema;
        if(sobjectName == sCONSTContact){
            objSchema = Contact.sObjectType.getDescribe();
        }else if(sobjectName == sCONSTLead){ 
            objSchema = Lead.sObjectType.getDescribe();
        }
        
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        Schema.DisplayType fielddataType = fieldMap.get(fieldapiname).getDescribe().getType();

        if(String.valueOf(fielddataType) == 'PICKLIST' || String.valueOf(fielddataType) == 'MULTIPICKLIST'){
            List<Schema.PicklistEntry> ple = fieldmap.get(fieldapiname).getDescribe().getpicklistValues();
            for(Schema.PicklistEntry f : ple){
                listOfStringOptions.add(f.getLabel());
            }
        }
        return listOfStringOptions;
    }
}