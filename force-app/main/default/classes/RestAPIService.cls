/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 08-Oct-2019
*Purpose :   RestWebHook Api

06/20/2024    1.0.0    NLINEAXIS(Kapil Goutam)     Modified:- Added changes for security check 
******************************************************************************************/
@RestResource(urlMapping='/inwiseinboudsms/*')
global with sharing class RestAPIService {
    @HttpPost
    global static String ApiService() {
        system.debug('api called');
        List<Logs__c> listOfLogs = new List<Logs__c>();
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        RestRequest request = RestContext.request;
        System.debug('request::-->>>' + request);
        String paramTimeStamp = request.params.get('timeStamp');
        String paramTriggerType = request.params.get('trigger_type');
        String paramChannelType = request.params.get('channel_type');
        String paramSendId = request.params.get('sendId');
        String paramReplyContent = request.params.get('ReplyContent');
        String paramRecipientmobileNumber = request.params.get('contact[mobile_number]');
        String requestString = request.toString();
        requestString += ';timeStamp=' + paramTimeStamp;
        requestString += ';trigger_type=' + paramTriggerType;
        requestString += ';channel_type=' + paramChannelType;
        requestString += ';sendId=' + paramSendId;
        requestString += ';ReplyContent=' + paramReplyContent;
        requestString += ';contact[mobile_number]=' + paramRecipientmobileNumber;
        
        try {
            Webhook_Setting__c objInwiseWebhookSetting = Webhook_Setting__c.getAll().get('default');
            String soqlQueryContact = '';
            String soqlQueryLead = '';
            if(Schema.sObjectType.Contact.isAccessible() ){
                soqlQueryContact = 'SELECT Id from Contact where ';
            }

            if(Schema.sObjectType.Lead.isAccessible() ){
                soqlQueryLead = 'SELECT Id from Lead where ';
            }
            
            
            List<Contact> listOfContact;
            List<Lead> listOfLead;
            Task objTask;
            Messaging_History__c objMessageHistory;
            List<Task> listOfTasksToInsert = new List<Task>();
            List<Messaging_History__c> listofMessageHistoryToInsert = new List<Messaging_History__c>();
            String sTaskSubject = 'SMS Reply';
            System.debug('objInwiseWebhookSetting::-->>>' + objInwiseWebhookSetting);
            if (objInwiseWebhookSetting != null) {
                if (objInwiseWebhookSetting.Contact_Field__c != null && paramRecipientmobileNumber != null &&
                    Schema.sObjectType.Contact.fields.getMap().containsKey(objInwiseWebhookSetting.Contact_Field__c) &&
                    Schema.sObjectType.Contact.fields.getMap().get(objInwiseWebhookSetting.Contact_Field__c).getDescribe().isAccessible()) {

                    soqlQueryContact += objInwiseWebhookSetting.Contact_Field__c + '=\'' + inwiseHttpUtil.getReverseFormattedPhone(paramRecipientmobileNumber, objInwiseUtil) + '\'';
                    listOfContact = Database.query(soqlQueryContact);
                    System.debug('listOfContact::->>>' + soqlQueryContact + '>>>' + listOfContact);
                    if (!listOfContact.isEmpty()) {
                        for (Contact c : listOfContact) {
                            
                            if (objInwiseWebhookSetting.Save_To_Activity_History__c && objInwiseWebhookSetting.Save_To_Messaging_History__c){
                                objTask = doCreateTask(paramReplyContent,sTaskSubject,c.Id);
                                objMessageHistory = doCreateMessageHistory(paramTriggerType,paramChannelType,paramReplyContent, paramRecipientmobileNumber,c.Id,requestString);
                                listOfTasksToInsert.add(objTask); 
                                listofMessageHistoryToInsert.add(objMessageHistory); 
                            }
                            if (objInwiseWebhookSetting.Save_To_Messaging_History__c && !objInwiseWebhookSetting.Save_To_Activity_History__c){
                                objMessageHistory = doCreateMessageHistory(paramTriggerType,paramChannelType,paramReplyContent, paramRecipientmobileNumber,c.Id,requestString);
                                listofMessageHistoryToInsert.add(objMessageHistory); 
                            }
                            if(objInwiseWebhookSetting.Save_To_Activity_History__c && !objInwiseWebhookSetting.Save_To_Messaging_History__c) {
                                objTask = doCreateTask(paramReplyContent,sTaskSubject,c.Id);
                                listOfTasksToInsert.add(objTask); 
                                
                            } if (!objInwiseWebhookSetting.Add_activity_to_all_records__c) {
                                break;
                            }
                        }
                        if (objInwiseWebhookSetting.Save_To_Activity_History__c && objInwiseWebhookSetting.Save_To_Messaging_History__c){
                            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Contact record updated with Activity History ' + objTask.WhoId), '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
                            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Contact record updated with  Messaging History '+ objMessageHistory.Contact__c ), '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
                            
                        } 
                        if (objInwiseWebhookSetting.Save_To_Messaging_History__c && !objInwiseWebhookSetting.Save_To_Activity_History__c){
                            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Contact record updated with  Messaging History '+ objMessageHistory.Contact__c ), '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
                        }
                        if(objInwiseWebhookSetting.Save_To_Activity_History__c && !objInwiseWebhookSetting.Save_To_Messaging_History__c) {
                            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Contact record updated  with Activity History' + objTask.WhoId), '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
                        }
                        
                    } else {
                        listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Contact record not found with ' + (inwiseHttpUtil.getReverseFormattedPhone(paramRecipientmobileNumber, objInwiseUtil)) + ' phone number'), '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
                    }
                }
                
                //for lead
                if (objInwiseWebhookSetting.Lead_Field__c != null && paramRecipientmobileNumber != null &&
                    Schema.sObjectType.Lead.fields.getMap().containsKey(objInwiseWebhookSetting.Lead_Field__c) &&
                    Schema.sObjectType.Lead.fields.getMap().get(objInwiseWebhookSetting.Lead_Field__c).getDescribe().isAccessible()) {

                    soqlQueryLead += objInwiseWebhookSetting.Lead_Field__c + '=\'' + inwiseHttpUtil.getReverseFormattedPhone(paramRecipientmobileNumber, objInwiseUtil) + '\'';
                    listOfLead = Database.query(soqlQueryLead);
                    System.debug('soqlQueryLead--->>'+soqlQueryLead);
                    System.debug('listOfContact::-->>>>' + listOfLead + '>>>>>' + soqlQueryContact);
                    if (!listOfLead.isEmpty()) {
                        for (Lead l : listOfLead) {
                            if (objInwiseWebhookSetting.Save_To_Activity_History__c && objInwiseWebhookSetting.Save_To_Messaging_History__c){
                                objTask = doCreateTask(paramReplyContent,sTaskSubject,l.Id);
                                objMessageHistory = doCreateMessageHistory(paramTriggerType,paramChannelType,paramReplyContent, paramRecipientmobileNumber,l.Id,requestString);
                                listOfTasksToInsert.add(objTask); 
                                listofMessageHistoryToInsert.add(objMessageHistory); 
                                
                            } 
                           if (objInwiseWebhookSetting.Save_To_Messaging_History__c && !objInwiseWebhookSetting.Save_To_Activity_History__c){
                                if(Messaging_History__c.sObjectType.getDescribe().isAccessible() ){
                                    objMessageHistory = doCreateMessageHistory(paramTriggerType,paramChannelType,paramReplyContent, paramRecipientmobileNumber,l.Id,requestString);
                                    listofMessageHistoryToInsert.add(objMessageHistory);  
                                }
                            }
                            if(objInwiseWebhookSetting.Save_To_Activity_History__c && !objInwiseWebhookSetting.Save_To_Messaging_History__c) {
                                if(Task.sObjectType.getDescribe().isAccessible() ){
                                    objTask = doCreateTask(paramReplyContent,sTaskSubject,l.Id);
                                    listOfTasksToInsert.add(objTask); 
                                }
                            } 
                            if (!objInwiseWebhookSetting.Add_activity_to_all_records__c) {
                                break;
                            }
                        }
                        if (objInwiseWebhookSetting.Save_To_Activity_History__c && objInwiseWebhookSetting.Save_To_Messaging_History__c){
                            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Lead record updated with Activity History ' + objTask.WhoId), '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
                            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Lead record updated with  messaging history '+ objMessageHistory.Lead__c ), '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
                            
                        } 
                        if (objInwiseWebhookSetting.Save_To_Messaging_History__c && !objInwiseWebhookSetting.Save_To_Activity_History__c){
                            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Lead record updated with  messaging history '+ objMessageHistory.Lead__c ), '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
                            
                        }
                        if(objInwiseWebhookSetting.Save_To_Activity_History__c && !objInwiseWebhookSetting.Save_To_Messaging_History__c){
                            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Lead record updated with Activity History' + objTask.WhoId), '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
                        }
                        
                    } else {
                        listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Lead record not found with ' + (inwiseHttpUtil.getReverseFormattedPhone(paramRecipientmobileNumber, objInwiseUtil)) + ' phone number'), '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
                    }
                }
            } else {
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, 'Custom Setting record not available', '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
            }
            System.debug('listOfTasksToInsert::-->>>' + listOfTasksToInsert);
            System.debug('listofMessageHistoryToInsert::-->>>' + listofMessageHistoryToInsert);
            if(Task.sObjectType.getDescribe().isCreateable()){
                if (!listOfTasksToInsert.isEmpty()) {
                    insert listOfTasksToInsert;
                }
            }
            if(Messaging_History__c.sObjectType.getDescribe().isCreateable()){
                if (!listofMessageHistoryToInsert.isEmpty()) {
                    insert listofMessageHistoryToInsert;
                }
            }
        }catch(Exception ex){
            system.debug(ex.getMessage()+'>>'+ex.getLineNumber());
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, (ex.getMessage() + ex.getLineNumber()), '/inwiseinboudsms', 'RestAPIService', 'Rest API call'));
        }
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            if(Logs__c.SObjectType.getDescribe().isCreateable()){
                insert listOfLogs;
            }
        }
        
        return null;
    }
    public static Task doCreateTask(String sParamReplyContent, String sTaskSubject, Id whoId){
        Task objTask = new Task();
        if(Schema.sObjectType.Task.fields.ActivityDate.isAccessible() && Schema.sObjectType.Task.fields.ActivityDate.isCreateable()){
            objTask.ActivityDate = date.today();
        }
        if(Schema.sObjectType.Task.fields.Description.isAccessible() && Schema.sObjectType.Task.fields.Description.isCreateable()){
            objTask.Description = sParamReplyContent;
        }
        if(Schema.sObjectType.Task.fields.Subject.isAccessible() && Schema.sObjectType.Task.fields.Subject.isCreateable()){
            objTask.Subject = sTaskSubject;
        }
        if(Schema.sObjectType.Task.fields.WhoId.isAccessible() && Schema.sObjectType.Task.fields.WhoId.isCreateable()){
            objTask.WhoId = whoId;
        }
        if(Schema.sObjectType.Task.fields.Status.isAccessible() && Schema.sObjectType.Task.fields.Status.isCreateable()){
            objTask.Status = 'Completed';
        }
        
        return objTask;
    }
    public static Messaging_History__c doCreateMessageHistory(String paramTriggerType, String paramChannelType, String paramReplyContent,String paramRecipientmobileNumber, Id RecordId,String requestString){
        String sObjName = RecordId.getSObjectType().getDescribe().getName();
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        Messaging_History__c objMsgHistory = new Messaging_History__c();
        if(sObjName=='Contact'){
            if(Schema.sObjectType.Messaging_History__c.fields.Contact__c.isAccessible() && Schema.sObjectType.Messaging_History__c.fields.Contact__c.isCreateable()){
                objMsgHistory.Contact__c = RecordId;
            }
        }else{
            if(Schema.sObjectType.Messaging_History__c.fields.Lead__c.isAccessible() && Schema.sObjectType.Messaging_History__c.fields.Lead__c.isCreateable()){
                objMsgHistory.Lead__c = RecordId;
            }
        }
        if(Schema.sObjectType.Messaging_History__c.fields.Description__c.isAccessible() && Schema.sObjectType.Messaging_History__c.fields.Description__c.isCreateable()){
            objMsgHistory.Description__c = requestString;
        }
        if(Schema.sObjectType.Messaging_History__c.fields.Channel_Type__c.isAccessible() && Schema.sObjectType.Messaging_History__c.fields.Channel_Type__c.isCreateable()){
            objMsgHistory.Channel_Type__c ='SMS';
        }
        if(Schema.sObjectType.Messaging_History__c.fields.Direction__c.isAccessible() && Schema.sObjectType.Messaging_History__c.fields.Direction__c.isCreateable()){
            objMsgHistory.Direction__c = 'Incoming';
        }
        if(Schema.sObjectType.Messaging_History__c.fields.Message__c.isAccessible() && Schema.sObjectType.Messaging_History__c.fields.Message__c.isCreateable()){
            objMsgHistory.Message__c = paramReplyContent;
        }
        if(Schema.sObjectType.Messaging_History__c.fields.To_Number__c.isAccessible() && Schema.sObjectType.Messaging_History__c.fields.To_Number__c.isCreateable()){
            objMsgHistory.To_Number__c = inwiseHttpUtil.getReverseFormattedPhone(paramRecipientmobileNumber, objInwiseUtil);
        }
        return objMsgHistory;
    }
    
}