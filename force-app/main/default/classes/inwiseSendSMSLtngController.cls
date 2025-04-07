/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Send SMS functionality
*Modified:   
================================================================
Modified On      Version      Modified By        Purpose  
================================================================
15/12/2021       1.0.0        S. Vaishnav        Modified:- Choose template functionality
30/08/2022       1.0.1        S. Vaishnav        Modified:- Store status and remark in message history
01/09/2022       1.0.2        S. Vaishnav        Modified:- Updated parameters in SendSMSAndCreateActivity method
26/09/2022       1.0.3        S. Vaishnav        Modified:- Added try catch block in SendSMSAndCreateActivity method
16/02/2023       1.0.4        Nlineaxis          Modified:- Added error log for wrong accountId for SMS/Email/WhatsApp
/******************************************************************************************/
public with sharing class inwiseSendSMSLtngController {

    @AuraEnabled public static String getcontactJSONString(String cid){
          
        String strSOLabel = '';
        String strSOValue = '';
        String contactJSON = '';
        String stringSOQLSelect = '';
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        List<inwiseSendSMSLtngController.SelectOption> listOfSelectOptionPhoneNumbers = new List<SelectOption>();
        List<System.SelectOption> listOfSelectOptionFieldsContactP1 = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_CONTACT, inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL, true);
        
        // Ensure CRUD and FLS enforcement
        Schema.DescribeSObjectResult contactDescribe = Schema.SObjectType.Contact;
        if(contactDescribe.isAccessible()){

            // Filter fields based on FLS
            Map<String, Schema.SObjectField> contactFields = contactDescribe.fields.getMap();

            if(!listOfSelectOptionFieldsContactP1.isEmpty()){
                for(System.SelectOption so:listOfSelectOptionFieldsContactP1){
                    if(!String.isEmpty(so.getValue()) && contactFields.containsKey(so.getValue()) && contactFields.get(so.getValue()).getDescribe().isAccessible()){
                        stringSOQLSelect += so.getValue() + ',';
                    }
                }

                if(!String.isEmpty(stringSOQLSelect)){
                    stringSOQLSelect = stringSOQLSelect.substring(0, stringSOQLSelect.length()-1);
                    String soql = 'SELECT  ' + stringSOQLSelect + ' FROM CONTACT where Id =: cid ';

                    List<Contact> listOfContact = Database.query(soql);
                    if(!listOfContact.isEmpty()){
                        Contact objContact = listOfContact.get(0);
                        contactJSON = JSON.serialize(objContact);
                        contactJSON = contactJSON.replace('\\r\n', ' ');
                        contactJSON = contactJSON.replace('\\n', ' ');
                        contactJSON = contactJSON.replace('\\r', ' ');
                    }
                }
            } 
        }
        return contactJSON;
    }

    @AuraEnabled
    public static List<inwiseSendSMSLtngController.SelectOption> getTemplatesList(){
        
        HttpResponse res;
        Http http = new Http();
        List<Logs__c> listOfLogs = new List<Logs__c>();
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        List<inwiseSendSMSLtngController.SelectOption> listOfSelectOptionTemplates = new List<SelectOption>();

        if(objInwiseUtil.objInwiseAccount == null){
            return listOfSelectOptionTemplates;
        }
        
        try{
            Map<String,String> mapOfLandingPageFields = inwiseHttpUtil.InwiseCalloutTemplatesList(objInwiseUtil, listOfLogs);    
            listOfSelectOptionTemplates.add(new SelectOption('', '--None--'));
            if(!mapOfLandingPageFields.isEmpty()){
                for(String k : mapOfLandingPageFields.keySet()){
                    listOfSelectOptionTemplates.add(new inwiseSendSMSLtngController.SelectOption(mapOfLandingPageFields.get(k), k)); 
                }
            }
        }catch(Exception ex){
            //apexpages.addmessage(new apexpages.message(apexpages.severity.Error,ex.getMessage()));      
        }

        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        }        
        return listOfSelectOptionTemplates;
    }
 
    @AuraEnabled
    public static List<inwiseSendSMSLtngController.SelectOption> getLandingPagesList(){
        
        HttpResponse res;
        Http http = new Http();
        List<Logs__c> listOfLogs = new List<Logs__c>();
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        List<inwiseSendSMSLtngController.SelectOption> listOfSelectOptionLandingPages = new List<SelectOption>();

        if(objInwiseUtil.objInwiseAccount == NULL){
            return listOfSelectOptionLandingPages;
        }
        
        try{
            Map<String,String> mapOfLandingPageFields = inwiseHttpUtil.InwiseCalloutLandingPagesList(objInwiseUtil, listOfLogs, false, 'Landing Page');    
            listOfSelectOptionLandingPages.add(new SelectOption('','--None--'));
            if(!mapOfLandingPageFields.isEmpty()){
                for(String k : mapOfLandingPageFields.keySet()){
                    listOfSelectOptionLandingPages.add(new inwiseSendSMSLtngController.SelectOption(k, mapOfLandingPageFields.get(k))); 
                }
            }
        }catch(Exception ex){
            //apexpages.addmessage(new apexpages.message(apexpages.severity.Error,ex.getMessage()));      
        }

        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        }        
        return listOfSelectOptionLandingPages;
    }

    @AuraEnabled
    public static List<inwiseSendSMSLtngController.SelectOption> getlistOfSelectOptionFieldsContact(String cid){
        
        Contact objContact;
        String stringSOQLSelect = '';
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        List<inwiseSendSMSLtngController.SelectOption> listOfSelectOptionContactFields = new List<SelectOption>();
        List<System.SelectOption> listOfSelectOptionFieldsContactP1= inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_CONTACT, inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL, true);
       
        // Ensure CRUD and FLS enforcement
        Schema.DescribeSObjectResult contactDescribe = Schema.SObjectType.Contact;
        if(contactDescribe.isAccessible() ){

            // Filter fields based on FLS
            Map<String, Schema.SObjectField> contactFields = contactDescribe.fields.getMap();
        
            if(!listOfSelectOptionFieldsContactP1.isEmpty()){
                for(System.SelectOption so:listOfSelectOptionFieldsContactP1){
                    if(!String.isEmpty(so.getValue()) && contactFields.containsKey(so.getValue()) && contactFields.get(so.getValue()).getDescribe().isAccessible()){
                        stringSOQLSelect += so.getValue() + ',';
                    }
                    listOfSelectOptionContactFields.add(new inwiseSendSMSLtngController.SelectOption(so.getValue(), so.getLabel()));  
                }
            }
            if(!String.isEmpty(stringSOQLSelect)){
                stringSOQLSelect = stringSOQLSelect.substring(0, stringSOQLSelect.length()-1);
                String soql= 'SELECT  ' + stringSOQLSelect + ' FROM CONTACT where Id =: cid ';
                List<Contact> listOfContact = Database.query(soql);
                if(!listOfContact.isEmpty()){
                    objContact = listOfContact.get(0);
                }               
            }
            listOfSelectOptionContactFields = listOfSelectOptionRemoveNullFields(listOfSelectOptionContactFields,objContact);
        }

        return listOfSelectOptionContactFields;
    }

    /**
    **This method will remove all those fields in the pciklist which are having null values
    **/
    public static List<inwiseSendSMSLtngController.SelectOption> listOfSelectOptionRemoveNullFields(List<inwiseSendSMSLtngController.SelectOption> listofSO, Contact objContactTemp ){
        List<inwiseSendSMSLtngController.SelectOption> listofSONew = new List<inwiseSendSMSLtngController.SelectOption>();
        if(!listofSO.isEmpty()){
            for(SelectOption so:listofSO){
                if(!String.isBlank(so.Value) && objContactTemp.get(so.Value) != NULL){
                    listofSONew.add(so);
                }
            }  
        }
        return listofSONew;
    }
    
    @AuraEnabled 
    public static List<inwiseSendSMSLtngController.SelectOption> getPhoneNumberSO(String cid){
        
        String strSOLabel = '';
        String strSOValue = '';
        String stringSOQLSelect = '';
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        Map<String, Boolean> mapOfAllPhoneApi = new Map<String, Boolean>();
        List<inwiseSendSMSLtngController.SelectOption> listOfSelectOptionPhoneNumbers = new List<SelectOption>();
        List<System.SelectOption> listOfSelectOptionFieldsContactP1 = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_CONTACT, inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL, true);
           
        // Ensure CRUD and FLS enforcement
        Schema.DescribeSObjectResult contactDescribe = Schema.SObjectType.Contact;
        if(contactDescribe.isAccessible() ){

            // Filter fields based on FLS
            Map<String, Schema.SObjectField> contactFields = contactDescribe.fields.getMap();
            if(!listOfSelectOptionFieldsContactP1.isEmpty()){
                for(System.SelectOption so:listOfSelectOptionFieldsContactP1){
                    if(so.getLabel().toLowerCase().contains('(phone)')){
                        mapOfAllPhoneApi.put(so.getValue(),true);
                    }
                    //add all field so will be used in JSON value fetch
                    if(!String.isEmpty(so.getValue()) && contactFields.containsKey(so.getValue()) && contactFields.get(so.getValue()).getDescribe().isAccessible()){
                        stringSOQLSelect += so.getValue() + ',';
                    }
                }

                if(!String.isEmpty(stringSOQLSelect)){
                    stringSOQLSelect = stringSOQLSelect.substring(0, stringSOQLSelect.length()-1);
                    String soql = 'SELECT ' + stringSOQLSelect + ' FROM CONTACT where Id =: cid ';
                    List<Contact> listOfContact = Database.query(soql);

                    if(!listOfContact.isEmpty()){
                        Contact objContact = listOfContact.get(0);
                        for(System.SelectOption so:listOfSelectOptionFieldsContactP1){
                            if(mapOfAllPhoneApi.get(so.getValue()) != NULL && mapOfAllPhoneApi.get(so.getValue())){
                                strSOLabel = (string)objContact.get(so.getValue());
                                if(!String.isEmpty(strSOLabel)){
                                    strSOValue = strSOLabel.replace(' ', '').replace('(', '').replace(')', '').replace('-', '').replace('+', '');
                                    listOfSelectOptionPhoneNumbers.add(new inwiseSendSMSLtngController.SelectOption(strSOValue, strSOLabel));  
                                }
                            }
                        }     
                    }
                }
            } 
        }
        
        return listOfSelectOptionPhoneNumbers;
    }

    public static String SendSMSAndCreateActivity(String messageBody, String selectedNumber, String recoredId, Boolean saveTask, Boolean saveMessagingHistory, String fromNumber, String accountId){
        
        String msg = '';
        Account__c acc = null;
        List<Logs__c> listOfLogs = new List<Logs__c>();
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        try{
            
            if(String.isNotBlank(accountId)){
                if(Schema.sObjectType.Account__c.isAccessible()){
                    acc = [Select Id From Account__c Where Id =: accountId];
                }
            }
            
            InwiseUtil objInwiseUtil = new InwiseUtil(acc);
            Map<String, String> responseMap = inwiseHttpUtil.InwiseCalloutSendSMS(objInwiseUtil, messageBody, selectedNumber, listOfLogs, fromNumber);
            
            if(!responseMap.isEmpty()){
                String status = responseMap.get('status');
                String statusCode = responseMap.get('statusCode');
                String rejectReason = responseMap.get('rejectReason');
                system.debug('=responseMap='+responseMap);
                if(Boolean.valueOf(responseMap.get('isSMSSent'))){
                    msg = 'SUCCESS';
                }
                else{
                    system.debug('=rejected=');
                    msg = String.isNotBlank(rejectReason) ? rejectReason : inwiseConstants.UNABLE_TO_SEND_SMS;
                }
                
                
                if(String.isNotBlank(recoredId) && String.isNotBlank(statusCode) && statusCode == '200'){
                    if(saveTask){
                        task taskrecord = doCreateTask(messageBody, selectedNumber, recoredId,'SMS');
                        if(taskrecord != null){
                            insert taskrecord;
                        }
                    }
                    if(saveMessagingHistory){
                        Messaging_History__c messageHistoryRecord = doCreateMessageHistory(messageBody, selectedNumber, recoredId, status, rejectReason,'SMS','');
                        if(messageHistoryRecord != null){
                            insert messageHistoryRecord;
                        }
                    }
                }
                if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                    insert listOfLogs;
                }
                
            }
        }
        catch(Exception ex){
            if(acc == NULL){
                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord('Please add valid accountId', 'inwiseSendSMSLtngController', 'SendSMSAndCreateActivity'));
            }else{
                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'inwiseSendSMSLtngController', 'SendSMSAndCreateActivity'));
            }
            
        }
        system.debug('=listOfErrorLogs='+listOfErrorLogs);
        if(!listOfErrorLogs.isEmpty()){
            system.debug('=='+listOfErrorLogs);
            insert listOfErrorLogs;
        }        
        return msg;
    }

    public static String SendSMSAndCreateActivity1(String wrapperSMSList/*String messageBody, String selectedNumber, String recoredId, Boolean saveTask, Boolean saveMessagingHistory, String fromNumber, String accountId*/){
        system.debug('SMSWrapperList1 is ==>'+wrapperSMSList);
        list<SMSWrapper> SMSWrapperList = (List<SMSWrapper>) System.JSON.deserialize(wrapperSMSList, List<SMSWrapper>.class);
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        List<Logs__c> listOfLogs = new List<Logs__c>();
        String msg = '';
        List<Task> taskList = new List<Task>();
        List<Messaging_History__c> messageHistoryList = new List<Messaging_History__c>();
        List<Error_Logs__c> errorLogList = new List<Error_Logs__c>();
        
        InwiseUtil objInwiseUtil;
        
        for(SMSWrapper Wrapper:SMSWrapperList){
            system.debug('messageBody is ==>'+Wrapper.smsText);
            system.debug('selectedNumber is ==>'+Wrapper.mobileNumber);
            //system.debug('recoredId is ==>'+Wrapper.recordId);
            system.debug('saveTask is ==>'+Wrapper.saveTask);
            system.debug('saveMessagingHistory is ==>'+ Wrapper.saveMessagingHistory);
            system.debug('fromNumber is ==>'+ Wrapper.fromNumber);
            system.debug('accountId is ==>'+wrapperSMSList);
            
            String messageBody = Wrapper.smsText;
            String selectedNumber =  Wrapper.mobileNumber;
            String recoredId =  Wrapper.recordId;
            Boolean saveTask = Wrapper.saveTask;
            Boolean saveMessagingHistory = Wrapper.saveMessagingHistory;
            String fromNumber = Wrapper.fromNumber;
            String accountId = Wrapper.accountId;
                       
            Account__c acc = null;
            
            try{
                
                if(String.isNotBlank(accountId)){
                    if(Schema.sObjectType.Account__c.isAccessible()){
                        acc = [Select Id From Account__c Where Id =: accountId];
                    }
                }
                
                objInwiseUtil = new InwiseUtil(acc);
                SMSWrapper responseMap = inwiseHttpUtil.InwiseCalloutSendSMS1(objInwiseUtil, messageBody, selectedNumber, listOfLogs, fromNumber);
                
                system.debug('responseMap is ==>'+responseMap);
                system.debug('errorLogList is ==>'+responseMap.errorLogs);
                //system.debug('status is ==>'+responseMap.toMap.get('status'));
                if(responseMap != null){
                    if(responseMap.errorLogs != null){
                        errorLogList.add(responseMap.errorLogs);
                    }
                    
                    String status = responseMap.toMap.get('status');
                    String statusCode = responseMap.toMap.get('statusCode');
                    String rejectReason = responseMap.toMap.get('rejectReason');
                    //system.debug('=responseMap='+responseMap);
                    if(Boolean.valueOf(responseMap.toMap.get('isSMSSent'))){
                        msg = 'SUCCESS';
                    }
                    else{
                        system.debug('=rejected=');
                        msg = String.isNotBlank(rejectReason) ? rejectReason : inwiseConstants.UNABLE_TO_SEND_SMS;
                    }
                    
                    
                    if(String.isNotBlank(recoredId) && String.isNotBlank(statusCode) && statusCode == '200'){
                        if(saveTask){
                            Task taskRecord = doCreateTask(messageBody, selectedNumber, recoredId,'SMS');
                            if(taskRecord != null){
                                taskList.add(taskRecord);
                            }
                        }
                        if(saveMessagingHistory){
                            Messaging_History__c messageHistoryRecord = doCreateMessageHistory(messageBody, selectedNumber, recoredId, status, rejectReason,'SMS','');
                            if(messageHistoryRecord != null){
                                messageHistoryList.add(messageHistoryRecord);
                            }
                        
                        }
                    }
                    system.debug('listOfLogs is ==> '+listOfLogs);
                    
                    
                }
            }
            catch(Exception ex){
                if(acc == NULL){
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord('Please add valid accountId', 'inwiseSendSMSLtngController', 'SendSMSAndCreateActivity'));
                }else{
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'inwiseSendSMSLtngController', 'SendSMSAndCreateActivity'));
                }
                
                
            }            
        }
        
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        }
        system.debug('=listOfErrorLogs='+listOfErrorLogs);
        if(!listOfErrorLogs.isEmpty()){
            system.debug('=='+listOfErrorLogs);
            insert listOfErrorLogs;
        }
        if(!taskList.isEmpty()){
            system.debug('== 1'+taskList);
            insert taskList;
        }
        if(!messageHistoryList.isEmpty()){
            system.debug('== 2'+messageHistoryList);
            insert messageHistoryList;
        }
        if(!errorLogList.isEmpty()){
            system.debug('== 3'+errorLogList);
            insert errorLogList;
        }
       
        
        return msg;
    }
    @AuraEnabled 
    public static String SendSMSAndCreateActivity(String messageBody, String selectedNumber, String contactId){
        
        String msg = '';
        List<Logs__c> listOfLogs = new List<Logs__c>();
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        Webhook_Setting__c objInwiseWebhookSetting = Webhook_Setting__c.getAll().get('default');
       
        if(String.isEmpty(messageBody) || String.isEmpty(selectedNumber)){
            msg = 'Please provide SMS body & phone no';
            return msg;
        }
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        Map<String, String> responseMap = inwiseHttpUtil.InwiseCalloutSendSMS(objInwiseUtil, messageBody, selectedNumber, listOfLogs, '');
        
        if(!responseMap.isEmpty()){
            String status = responseMap.get('status');
            String statusCode = responseMap.get('statusCode');
        	String rejectReason = responseMap.get('rejectReason');
            
            if(Boolean.valueOf(responseMap.get('isSMSSent'))){
                msg = 'SUCCESS';
            }
            else{
                msg = String.isNotBlank(rejectReason) ? rejectReason : inwiseConstants.UNABLE_TO_SEND_SMS;
            }
            
            try{
                if(objInwiseWebhookSetting != null && String.isNotBlank(statusCode) && statusCode == '200') {
                    if(objInwiseWebhookSetting.Save_To_Activity_History__c){
                        task taskRecord = doCreateTask(messageBody, selectedNumber, contactId,'SMS');
                        if(taskRecord != null){
                            insert taskRecord;
                        }                        
                    }
                    if(objInwiseWebhookSetting.Save_To_Messaging_History__c){
                        Messaging_History__c messageHistoryRecord = doCreateMessageHistory(messageBody, selectedNumber, contactId, status, rejectReason,'SMS','');
                        if(messageHistoryRecord != null){
                            insert messageHistoryRecord;
                        }                       
                    }
                }
                if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                    insert listOfLogs;
                }
            }catch(Exception ex){
                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'inwiseSendSMSLtngController', 'SendSMSAndCreateActivity'));
            }
            if(!listOfErrorLogs.isEmpty()){
                insert listOfErrorLogs;
            }
        }        
        return msg;
    }

    public static Task doCreateTask(String messageBody, String selectedNumber, String contactId,String subject){
        String idPrefix = String.isNotBlank(contactId) ? contactId.substring(0,3) : '';
        Task objTask = new task();
        if(Schema.SObjectType.Task.isCreateable()){
            //Task objTask = new task();
            if(Schema.sObjectType.Task.fields.WhoId.isCreateable() ){
                if((idPrefix == '003' || idPrefix == '00Q')){
                    objTask.WhoId = contactId;
                }
                else if(idPrefix == '001'){
                    objTask.WhatId = contactId;
                }
            }
            if(Schema.sObjectType.Task.fields.Subject.isCreateable()){
               objTask.Subject = 'inwise '+subject;
               
            }
            if(Schema.sObjectType.Task.fields.Priority.isCreateable()){
                objTask.priority = 'Normal';
            }
            if(Schema.sObjectType.Task.fields.Status.isCreateable()){
                objTask.status = 'Completed';
            }
            if(Schema.sObjectType.Task.fields.Description.isCreateable()){
                objTask.description = (subject =='SMS' || subject == 'Whatsapp' ? 'Number : ':'Email : ') + selectedNumber + '\n';
            }
            objTask.description += subject+' Body : ' + messageBody;
        
            //insert objTask;
        }
        return objTask;
    }
  
    public static Messaging_History__c doCreateMessageHistory(String messageBody, String selectedNumber, String recordId, String status, String remark , String channelType,String description){
        Messaging_History__c objMsgHistory = new Messaging_History__c();
        if(Schema.SObjectType.Messaging_History__c.isCreateable()){
            String idPrefixs = String.valueOf(recordId).substring(0,3);
            
            if(Schema.sObjectType.Messaging_History__c.fields.Contact__c.isCreateable() && idPrefixs == '003'){
                objMsgHistory.Contact__c = recordId;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Lead__c.isCreateable() && idPrefixs == '00Q'){
                objMsgHistory.Lead__c = recordId;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Account__c.isCreateable() && idPrefixs == '001'){
                objMsgHistory.Account__c = recordId;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Direction__c.isCreateable()){
                objMsgHistory.Direction__c = 'Outgoing';
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Description__c.isCreateable()){
                objMsgHistory.Description__c = (channelType =='SMS' || channelType =='Whatsapp' ? 'Number : ':'Email : ') + selectedNumber + '\n';
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Message__c.isCreateable()){
                objMsgHistory.Message__c = messageBody.length() > 255 ? messageBody.substring(0, 255) : messageBody;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.To_Number__c.isCreateable()){
                objMsgHistory.To_Number__c = selectedNumber;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Channel_Type__c.isCreateable()){
                objMsgHistory.Channel_Type__c = channelType;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Status__c.isCreateable()){
                objMsgHistory.Status__c = status;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Remark__c.isCreateable()){
                objMsgHistory.Remark__c = remark;
            }
            if(channelType == 'SMS'){
                objMsgHistory.Description__c += 'SMS Body : ' + messageBody;
            }
            else if(channelType =='Whatsapp'){
                objMsgHistory.Description__c += 'Whatsapp Body : ' + messageBody;
            }
            else{
                objMsgHistory.Description__c += 'Email Body : ' + messageBody;
            }
            if(String.isNotBlank(description)){
                objMsgHistory.Description__c += description;
            }
            
            //insert objMsgHistory;
        }
        return objMsgHistory;
    }
    // callout for email send
    public static String sendEmailAndCreateActivity(String template_id, String fromEmail, Boolean saveTask, Boolean saveMessagingHistory, String accountId
			, String toName, String subject, String fromName, String tagsLi,String email, String replyTo,String recordId){
            String msg = '';
            Account__c acc = null;
            List<Logs__c> listOfLogs = new List<Logs__c>();
            List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
            Map<string,Mapping__c> mapInwiseMapping = new Map<string,Mapping__c>();
            AggregateResult[] objInwiseFields;
            List<Mapping__c> listOfInwiseMapping;
            InwiseUtil objInwiseUtil ;
            String jsonFields ='';
            try{
                if(String.isNotBlank(accountId)){
                    if(Schema.sObjectType.Account__c.isAccessible()){
                        acc = [Select Id From Account__c Where Id =: accountId];
                    }

                    if(Schema.sObjectType.Mapping__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible() &&
                        Schema.sObjectType.Mapping__c.fields.inwise_Field__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.inwise_FieldId__c.isAccessible() &&
                        Schema.sObjectType.Mapping__c.fields.Object_Type__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isAccessible() ){

                        listOfInwiseMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c from Mapping__c where Account__c=:accountId];
                        objInwiseFields = [SELECT  inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:accountId  group by inwise_FieldId__c,inwise_Field__c];

                    }

                    objInwiseUtil= new InwiseUtil(acc);
                    if(!listOfInwiseMapping.isEmpty()){
                        for(Mapping__c oMapping:listOfInwiseMapping){
                            string key= oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
                            mapInwiseMapping.put(key,oMapping);
                        }  
                    }
                }
                if(String.isNotBlank(recordId)){
                    BatchSyncMemberToInwise batch = new BatchSyncMemberToInwise();
                    batch.objInwiseUtil = objInwiseUtil;
                    String idPrefix = String.valueOf(recordId).substring(0,3);
                    String replaceJson;
                    if(idPrefix == '003'){
                        List<Contact> contList = new List<Contact>();
                        // Check CRUD permissions for Contact object
                        if (Schema.SObjectType.Contact.isAccessible()) {

                            // Get accessible fields from the Contact object
                            Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();
                            String accessibleFields = '';

                            for (String field : getFields('Contact').split(',')) {
                                if (contactFields.containsKey(field.trim()) && contactFields.get(field.trim()).getDescribe().isAccessible()) {
                                    accessibleFields += field.trim() + ',';
                                }
                            }

                            if (String.isNotBlank(accessibleFields)) {
                                // Remove trailing comma
                                accessibleFields = accessibleFields.substring(0, accessibleFields.length() - 1);

                                // Construct and execute the SOQL query with only accessible fields
                                String contQuery = 'SELECT ' + accessibleFields + ' FROM Contact WHERE Id = :recordId';
                                contList = Database.query(contQuery);
                            }
                        }

                        //String contQuery = 'SELECT '+getFields('Contact') +' FROM Contact WHERE Id =\''+String.escapeSingleQuotes(recordId)+'\'';
                        //List<Contact> contList = Database.query(contQuery);

                        jsonFields = batch.jsonForMobileCampaignPerRecord(contList[0],'Contact',listOfInwiseMapping,objInwiseFields,mapInwiseMapping);
                        replaceJson = '"email": "'+ contList[0].Email + '"';
                        jsonFields = jsonFields.replace(replaceJson, '"rcpt": "'+ email + '"');
                        
                        jsonFields =replaceJSONValues(jsonFields);
                    }else if(idPrefix == '00Q'){

                        List<Lead> leadList = new List<Lead>();
                        // Check CRUD permissions for Lead object
                        if (Schema.SObjectType.Lead.isAccessible()) {

                            // Get accessible fields from the Lead object
                            Map<String, Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();
                            String accessibleFields = '';

                            for (String field : getFields('Lead').split(',')) {
                                if (leadFields.containsKey(field.trim()) && leadFields.get(field.trim()).getDescribe().isAccessible()) {
                                    accessibleFields += field.trim() + ',';
                                }
                            }

                            if (String.isNotBlank(accessibleFields)) {
                                // Remove trailing comma
                                accessibleFields = accessibleFields.substring(0, accessibleFields.length() - 1);

                                // Construct and execute the SOQL query with only accessible fields
                                String leadQuery = 'SELECT ' + accessibleFields + ' FROM Lead WHERE Id = :recordId';
                                leadList = Database.query(leadQuery);
                            }
                        }

                        //String leadQuery = 'SELECT '+getFields('Lead') +' FROM Lead WHERE Id =\''+String.escapeSingleQuotes(recordId)+'\'';
                        //List<Lead> leadList = Database.query(leadQuery);

                        jsonFields = batch.jsonForMobileCampaignPerRecord(leadList[0],'Lead',listOfInwiseMapping,objInwiseFields,mapInwiseMapping);
                        replaceJson = '"email": "'+ lead.Email + '"';
                        jsonFields = jsonFields.replace(replaceJson, '"rcpt": "'+ email + '"');
                        jsonFields =replaceJSONValues(jsonFields);
                    }
                    
                }
        
                
                Map<String, String> responseMap = inwiseHttpUtil.InwiseCalloutSendEmail(objInwiseUtil, template_id, listOfLogs, fromEmail,toName,subject,fromName,tagsLi,email,replyTo,jsonFields);
                if(!responseMap.isEmpty()){
                    String status = responseMap.get('status');
                    String statusCode = responseMap.get('statusCode');
                    String rejectReason = responseMap.get('rejectReason');
                    if(Boolean.valueOf(responseMap.get('isEmailSent'))){
                        msg = 'SUCCESS';
                    }
                    else{
                        msg = String.isNotBlank(rejectReason) ? rejectReason :  inwiseConstants.UNABLE_TO_SEND_EMAIL;
                    }
                    
                    
                        if(String.isNotBlank(recordId) && String.isNotBlank(statusCode) && statusCode == '200'){
                            if(saveTask){
                                Task taskRecord = doCreateTask(template_id, email, recordId,'Email');
                                if(taskRecord != null){
                                     insert taskRecord;
                                }
                               
                            }
                            if(saveMessagingHistory){
                                Messaging_History__c messageHistoryRecord = doCreateMessageHistory(subject, email,recordId, status, rejectReason,'Email',inwiseHttpUtil.getJSONSendEmail(template_id,fromEmail,toName,subject,fromName,tagsLi,email,replyTo,jsonFields));
                                if(messageHistoryRecord != null){
                                     insert messageHistoryRecord;
                                }                           
                            }
                            
                        }
                        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                            insert listOfLogs;
                        }
                   
                }    
            } catch(Exception ex){
                if(acc == NULL){
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord('Please add valid accountId', 'inwiseSendSMSLtngController', 'SendEmailAndCreateActivity'));
                }else{
                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'inwiseSendSMSLtngController', 'SendEmailAndCreateActivity'));
                }
            }
            if(!listOfErrorLogs.isEmpty()){
                
                insert listOfErrorLogs;
            }    
                return msg;
    }
    public static String sendBulkEmailAndCreateActivity(String emailWrapperList){
        // String template_id, String fromEmail, Boolean saveTask, Boolean saveMessagingHistory, String accountId
		// 	, String toName, String subject, String fromName, String tagsLi,String email, String replyTo,String recordId
            String msg = '';
            List<Logs__c> listOfLogs = new List<Logs__c>();
            List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
            list<EmailWrapper> emailList = (List<EmailWrapper>) System.JSON.deserialize(emailWrapperList, List<EmailWrapper>.class);
            List<Messaging_History__c> messageHistoryList = new List<Messaging_History__c>();
            InwiseUtil objInwiseUtil ;
            List<Task> taskList = new List<Task>();

            for(EmailWrapper Wrapper : emailList){
                String template_id = Wrapper.template_id;
                String fromEmail  = Wrapper.from_email;
                Boolean saveTask = Wrapper.createTask;  
                Boolean saveMessagingHistory = Wrapper.saveToInwiseMessagingHistory;  
                String accountId = Wrapper.accountId;
                String toName = Wrapper.toname;
                String subject = Wrapper.subject;
                String fromName = Wrapper.from_name;
                String tagsLi = Wrapper.tags;
                String email = Wrapper.email;
                String replyTo = Wrapper.reply_to;
                String recordId = Wrapper.recordId;
            
            Map<string,Mapping__c> mapInwiseMapping = new Map<string,Mapping__c>();
            Account__c acc = null;
           AggregateResult[] objInwiseFields;
            List<Mapping__c> listOfInwiseMapping;
            
            String jsonFields ='';
            try{
                if(String.isNotBlank(accountId)){

                    if(Schema.sObjectType.Account__c.isAccessible()){
                        acc = [Select Id From Account__c Where Id =: accountId];
                    }

                    if(Schema.sObjectType.Mapping__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible() &&
                        Schema.sObjectType.Mapping__c.fields.inwise_Field__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.inwise_FieldId__c.isAccessible() &&
                        Schema.sObjectType.Mapping__c.fields.Object_Type__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isAccessible() ){

                        listOfInwiseMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c from Mapping__c where Account__c=:accountId];
                        objInwiseFields = [SELECT  inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:accountId  group by inwise_FieldId__c,inwise_Field__c];

                    }

                    objInwiseUtil= new InwiseUtil(acc);
                    if(!listOfInwiseMapping.isEmpty()){
                        for(Mapping__c oMapping:listOfInwiseMapping){
                            string key= oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
                            mapInwiseMapping.put(key,oMapping);
                        }  
                    }
                }
                if(String.isNotBlank(recordId)){
                    BatchSyncMemberToInwise batch = new BatchSyncMemberToInwise();
                    batch.objInwiseUtil = objInwiseUtil;
                    String idPrefix = String.valueOf(recordId).substring(0,3);
                    String replaceJson;
                    if(idPrefix == '003'){

                        List<Contact> contList = new List<Contact>();
                        // Check CRUD permissions for Contact object
                        if (Schema.SObjectType.Contact.isAccessible()) {
                            // Get accessible fields from the Contact object
                            Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();
                            String accessibleFields = '';
                            for (String field : getFields('Contact').split(',')) {
                                if (contactFields.containsKey(field.trim()) && contactFields.get(field.trim()).getDescribe().isAccessible()) {
                                    accessibleFields += field.trim() + ',';
                                }
                            }
                            if (String.isNotBlank(accessibleFields)) {
                                // Remove trailing comma
                                accessibleFields = accessibleFields.substring(0, accessibleFields.length() - 1);
                                // Construct and execute the SOQL query with only accessible fields
                                String contQuery = 'SELECT ' + accessibleFields + ' FROM Contact WHERE Id = :recordId';
                                contList = Database.query(contQuery);
                            }
                        }

                        //String contQuery = 'SELECT '+getFields('Contact') +' FROM Contact WHERE Id =\''+String.escapeSingleQuotes(recordId)+'\'';
                        //List<Contact> contList = Database.query(contQuery);

                        jsonFields = batch.jsonForMobileCampaignPerRecord(contList[0],'Contact',listOfInwiseMapping,objInwiseFields,mapInwiseMapping);
                        replaceJson = '"email": "'+ contList[0].Email + '"';
                        jsonFields = jsonFields.replace(replaceJson, '"rcpt": "'+ email + '"');
                        
                        jsonFields =replaceJSONValues(jsonFields);
                    }else if(idPrefix == '00Q'){

                        List<Lead> leadList = new List<Lead>();
                        // Check CRUD permissions for Lead object
                        if (Schema.SObjectType.Lead.isAccessible()) {
                            // Get accessible fields from the Lead object
                            Map<String, Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();
                            String accessibleFields = '';
                            for (String field : getFields('Lead').split(',')) {
                                if (leadFields.containsKey(field.trim()) && leadFields.get(field.trim()).getDescribe().isAccessible()) {
                                    accessibleFields += field.trim() + ',';
                                }
                            }
                            if (String.isNotBlank(accessibleFields)) {
                                // Remove trailing comma
                                accessibleFields = accessibleFields.substring(0, accessibleFields.length() - 1);
                                // Construct and execute the SOQL query with only accessible fields
                                String leadQuery = 'SELECT ' + accessibleFields + ' FROM Lead WHERE Id = :recordId';
                                leadList = Database.query(leadQuery);
                            }
                        }

                        //String leadQuery = 'SELECT '+getFields('Lead') +' FROM Lead WHERE Id =\''+String.escapeSingleQuotes(recordId)+'\'';
                        //List<Lead> leadList = Database.query(leadQuery);

                        jsonFields = batch.jsonForMobileCampaignPerRecord(leadList[0],'Lead',listOfInwiseMapping,objInwiseFields,mapInwiseMapping);
                        replaceJson = '"email": "'+ lead.Email + '"';
                        jsonFields = jsonFields.replace(replaceJson, '"rcpt": "'+ email + '"');
                        jsonFields =replaceJSONValues(jsonFields);
                    }
                    
                }
        
                
                EmailWrapper responseMap = inwiseHttpUtil.InwiseCalloutSendBulkEmail(objInwiseUtil, template_id, listOfLogs, fromEmail,toName,subject,fromName,tagsLi,email,replyTo,jsonFields);
                if(responseMap != null){
                    if(responseMap.errorLogs != null){
                        listOfErrorLogs.add(responseMap.errorLogs);
                    }
                    String status = responseMap.toMap.get('status');
                    String statusCode = responseMap.toMap.get('statusCode');
                    String rejectReason = responseMap.toMap.get('rejectReason');
                    if(Boolean.valueOf(responseMap.toMap.get('isEmailSent'))){
                        msg = 'SUCCESS';
                    }
                    else{
                        msg = String.isNotBlank(rejectReason) ? rejectReason :  inwiseConstants.UNABLE_TO_SEND_EMAIL;
                    }
                    
                    
                        if(String.isNotBlank(recordId) && String.isNotBlank(statusCode) && statusCode == '200'){
                            if(saveTask){
                                Task taskRecord = doCreateTask(template_id, email, recordId,'Email');
                                if(taskRecord != null){
                                    taskList.add(taskRecord);
                                }
                               
                            }
                            if(saveMessagingHistory){
                                Messaging_History__c messageHistoryRecord = doCreateMessageHistory(subject, email,recordId, status, rejectReason,'Email',inwiseHttpUtil.getJSONSendEmail(template_id,fromEmail,toName,subject,fromName,tagsLi,email,replyTo,jsonFields));
                                if(messageHistoryRecord != null){
                                    messageHistoryList.add(messageHistoryRecord);
                                }                           
                            }
                            
                        }
                        
                   
                }    
            } catch(Exception ex){
                if(acc == NULL){
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord('Please add valid accountId', 'inwiseSendSMSLtngController', 'sendBulkEmailAndCreateActivity'));
                }else{
                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'inwiseSendSMSLtngController', 'sendBulkEmailAndCreateActivity'));
                }
            }
        }

            if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                insert listOfLogs;
            }
            if(!messageHistoryList.isEmpty()){
                system.debug('== from email ==='+messageHistoryList);
                insert messageHistoryList;
            }
            if(!listOfErrorLogs.isEmpty()){
                
                insert listOfErrorLogs;
            } 
            if(!taskList.isEmpty()){
                system.debug('taskList=='+taskList);
                insert taskList;
            }   
                return msg;
    }
    //callout for whatsApp Sending
    public static String sendWhatsAppAndCreateActivity(String template_id, String content, Boolean saveTask, Boolean saveMessagingHistory, String accountId
			, String mobileNumber, String templateMapping, String mediaUrl, String tagsLi,Boolean async,String recordId){
            String msg = '';
            Account__c acc = null;
            List<Logs__c> listOfLogs = new List<Logs__c>();
            List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
            Map<string,Mapping__c> mapInwiseMapping = new Map<string,Mapping__c>();
            AggregateResult[] objInwiseFields;
            List<Mapping__c> listOfInwiseMapping;
           InwiseUtil objInwiseUtil ;
            String jsonFields ='';
            try{
                if(String.isNotBlank(accountId)  ){

                    if(Schema.sObjectType.Account__c.isAccessible()){
                        acc = [Select Id From Account__c Where Id =: accountId];
                    }

                    objInwiseUtil= new InwiseUtil(acc);

                    if(Schema.sObjectType.Mapping__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible() &&
                        Schema.sObjectType.Mapping__c.fields.inwise_Field__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.inwise_FieldId__c.isAccessible() &&
                        Schema.sObjectType.Mapping__c.fields.Object_Type__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isAccessible() ){

                        listOfInwiseMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c from Mapping__c where Account__c=:accountId];
                        objInwiseFields = [SELECT  inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:accountId  group by inwise_FieldId__c,inwise_Field__c];

                    }
                    
                    if(!listOfInwiseMapping.isEmpty()){
                        for(Mapping__c oMapping:listOfInwiseMapping){
                            string key= oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
                            mapInwiseMapping.put(key,oMapping);
                        }  
                    }
                }
                if(String.isNotBlank(recordId)){
                    BatchSyncMemberToInwise batch = new BatchSyncMemberToInwise();
                    batch.objInwiseUtil = objInwiseUtil;
                    String idPrefix = String.valueOf(recordId).substring(0,3);
                    String replaceJson;
                    if(idPrefix == '003'){

                        List<Contact> contList = new List<Contact>();
                        // Check CRUD permissions for Contact object
                        if (Schema.SObjectType.Contact.isAccessible()) {
                            // Get accessible fields from the Contact object
                            Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();
                            String accessibleFields = '';
                            for (String field : getFields('Contact').split(',')) {
                                if (contactFields.containsKey(field.trim()) && contactFields.get(field.trim()).getDescribe().isAccessible()) {
                                    accessibleFields += field.trim() + ',';
                                }
                            }
                            if (String.isNotBlank(accessibleFields)) {
                                // Remove trailing comma
                                accessibleFields = accessibleFields.substring(0, accessibleFields.length() - 1);
                                // Construct and execute the SOQL query with only accessible fields
                                String contQuery = 'SELECT ' + accessibleFields + ' FROM Contact WHERE Id = :recordId';
                                contList = Database.query(contQuery);
                            }
                        }
                        
                        //String contQuery = 'SELECT '+getFields('Contact') +' FROM Contact WHERE Id =\''+ String.escapeSingleQuotes(recordId)+'\'';
                        //List<Contact> contList = Database.query(contQuery);

                       // Contact con = [Select Id FROM Contact Where Id =: recordId];
                        jsonFields = batch.jsonForMobileCampaignPerRecord(contList[0],'Contact',listOfInwiseMapping,objInwiseFields,mapInwiseMapping);
                        
                        String mobile = inwiseHttpUtil.getFormattedPhone(contList[0].MobilePhone, objInwiseUtil) ;
                        replaceJson = '"mobile_number": "'+ mobile +'"';
                        
                        jsonFields = jsonFields.replace(replaceJson, '"rcpt": "'+ mobile + '"');
                        
                        jsonFields =replaceJSONValues(jsonFields);
                    }else if(idPrefix == '00Q'){

                        List<Lead> leadList = new List<Lead>();
                        // Check CRUD permissions for Lead object
                        if (Schema.SObjectType.Lead.isAccessible()) {
                            // Get accessible fields from the Lead object
                            Map<String, Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();
                            String accessibleFields = '';
                            for (String field : getFields('Lead').split(',')) {
                                if (leadFields.containsKey(field.trim()) && leadFields.get(field.trim()).getDescribe().isAccessible()) {
                                    accessibleFields += field.trim() + ',';
                                }
                            }
                            if (String.isNotBlank(accessibleFields)) {
                                // Remove trailing comma
                                accessibleFields = accessibleFields.substring(0, accessibleFields.length() - 1);
                                // Construct and execute the SOQL query with only accessible fields
                                String leadQuery = 'SELECT ' + accessibleFields + ' FROM Lead WHERE Id = :recordId';
                                leadList = Database.query(leadQuery);
                            }
                        }

                        //String leadQuery = 'SELECT '+getFields('Lead') +' FROM Lead WHERE Id =\''+String.escapeSingleQuotes(recordId)+'\'';
                        //List<Lead> leadList = Database.query(leadQuery);

                        jsonFields = batch.jsonForMobileCampaignPerRecord(leadList[0],'Lead',listOfInwiseMapping,objInwiseFields,mapInwiseMapping);
                        replaceJson = '"mobile_number": "'+ lead.MobilePhone +'"';
                        jsonFields = jsonFields.replace(replaceJson, '"rcpt": "'+ mobileNumber + '"');
                        jsonFields =replaceJSONValues(jsonFields);
                    }
                   
                }
        
               
                Map<String, String> responseMap = inwiseHttpUtil.InwiseCalloutSendWhatsApp(objInwiseUtil, template_id, listOfLogs, content,mobileNumber,templateMapping,mediaUrl,async,tagsLi,jsonFields);
                if(!responseMap.isEmpty()){
                    String status = responseMap.get('status');
                    String statusCode = responseMap.get('statusCode');
                    String rejectReason = responseMap.get('rejectReason');
                    if(Boolean.valueOf(responseMap.get('isWhtasAppSent'))){
                        msg = 'SUCCESS';
                    }
                    else{
                        msg = String.isNotBlank(rejectReason) ? rejectReason :  inwiseConstants.UNABLE_TO_SEND_EMAIL;
                    }
                    
                   
                        if(String.isNotBlank(recordId) && String.isNotBlank(statusCode) && statusCode == '200'){
                            if(saveTask){
                                task taskRecord = doCreateTask(template_id, mobileNumber, recordId,'Whatsapp');
                                if(taskRecord != null){
                                    insert taskRecord;
                                }                                
                            }
                            if(saveMessagingHistory){
                                Messaging_History__c messageHistoryRecord = doCreateMessageHistory(content, mobileNumber,recordId, status, rejectReason,'Whatsapp',inwiseHttpUtil.getJSONSendWhatsApp(objInwiseUtil,template_id,content,mobileNumber,templateMapping,mediaUrl,async,tagsLi,jsonFields));
                                if(messageHistoryRecord != null){
                                    insert  messageHistoryRecord;
                                }                               
                            }
                        }
                        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                            insert listOfLogs;
                        }
                }
            }
            catch(Exception ex){
                if(acc == NULL){
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord('Please add valid accountId', 'inwiseSendSMSLtngController', 'sendWhatsAppAndCreateActivity'));
                }else{
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'inwiseSendSMSLtngController', 'sendWhatsAppAndCreateActivity'));
                }
                
            }
                    if(!listOfErrorLogs.isEmpty()){
                        system.debug('=='+listOfErrorLogs);
                        insert listOfErrorLogs;
                    }
                       
                return msg;
    }

    public static String sendBulkWhatsAppAndCreateActivity(String whatappWrapperList){
        // String template_id, String content, Boolean saveTask, Boolean saveMessagingHistory, String accountId
		// 	, String mobileNumber, String templateMapping, String mediaUrl, String tagsLi,Boolean async,String recordId
            String msg = '';
            
            List<Logs__c> listOfLogs = new List<Logs__c>();
            List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
            InwiseUtil objInwiseUtil ;
            List<Messaging_History__c> messageHistoryList = new List<Messaging_History__c>();
            List<Task> taskList = new List<Task>();
            List<WhatsappWrapper> WrapperList = (List<WhatsappWrapper>) System.JSON.deserialize(whatappWrapperList, List<WhatsappWrapper>.class);

            for(WhatsappWrapper Wrapper : WrapperList){
                String template_id = Wrapper.template_id;
                String content = Wrapper.content;
                Boolean saveTask = Wrapper.createTask;
                Boolean saveMessagingHistory = Wrapper.saveToInwiseMessagingHistory;
                String accountId = Wrapper.accountId;
                String mobileNumber = Wrapper.mobileNumber;
                String templateMapping = Wrapper.template_fields_mapping;
                String mediaUrl = Wrapper.media_url;
                String tagsLi = Wrapper.tags;
                Boolean async = Wrapper.async;
                String recordId = Wrapper.recordId;
            
            Account__c acc = null;
            Map<string,Mapping__c> mapInwiseMapping = new Map<string,Mapping__c>();
            AggregateResult[] objInwiseFields;
            List<Mapping__c> listOfInwiseMapping;
           
            String jsonFields ='';
            try{
                if(String.isNotBlank(accountId)  ){

                    if(Schema.sObjectType.Account__c.isAccessible()){
                        acc = [Select Id From Account__c Where Id =: accountId];
                    }

                    objInwiseUtil= new InwiseUtil(acc);

                    if(Schema.sObjectType.Mapping__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible() &&
                        Schema.sObjectType.Mapping__c.fields.inwise_Field__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.inwise_FieldId__c.isAccessible() &&
                        Schema.sObjectType.Mapping__c.fields.Object_Type__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isAccessible() ){

                        listOfInwiseMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c from Mapping__c where Account__c=:accountId];
                        objInwiseFields = [SELECT  inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:accountId  group by inwise_FieldId__c,inwise_Field__c];
                    
                    }
                    if(!listOfInwiseMapping.isEmpty()){
                        for(Mapping__c oMapping:listOfInwiseMapping){
                            string key= oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
                            mapInwiseMapping.put(key,oMapping);
                        }  
                    }
                }
                if(String.isNotBlank(recordId)){
                    BatchSyncMemberToInwise batch = new BatchSyncMemberToInwise();
                    batch.objInwiseUtil = objInwiseUtil;
                    String idPrefix = String.valueOf(recordId).substring(0,3);
                    String replaceJson;
                    if(idPrefix == '003'){

                        List<Contact> contList = new List<Contact>();
                        // Check CRUD permissions for Contact object
                        if (Schema.SObjectType.Contact.isAccessible()) {
                            // Get accessible fields from the Contact object
                            Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();
                            String accessibleFields = '';
                            for (String field : getFields('Contact').split(',')) {
                                if (contactFields.containsKey(field.trim()) && contactFields.get(field.trim()).getDescribe().isAccessible()) {
                                    accessibleFields += field.trim() + ',';
                                }
                            }
                            if (String.isNotBlank(accessibleFields)) {
                                // Remove trailing comma
                                accessibleFields = accessibleFields.substring(0, accessibleFields.length() - 1);
                                // Construct and execute the SOQL query with only accessible fields
                                String contQuery = 'SELECT ' + accessibleFields + ' FROM Contact WHERE Id = :recordId';
                                contList = Database.query(contQuery);
                            }
                        }
                        
                        //String contQuery = 'SELECT '+getFields('Contact') +' FROM Contact WHERE Id =\''+ String.escapeSingleQuotes(recordId)+'\'';
                        //List<Contact> contList = Database.query(contQuery);

                       // Contact con = [Select Id FROM Contact Where Id =: recordId];
                        jsonFields = batch.jsonForMobileCampaignPerRecord(contList[0],'Contact',listOfInwiseMapping,objInwiseFields,mapInwiseMapping);
                        
                        String mobile = inwiseHttpUtil.getFormattedPhone(contList[0].MobilePhone, objInwiseUtil) ;
                        replaceJson = '"mobile_number": "'+ mobile +'"';
                        
                        jsonFields = jsonFields.replace(replaceJson, '"rcpt": "'+ mobile + '"');
                        
                        jsonFields =replaceJSONValues(jsonFields);
                    }else if(idPrefix == '00Q'){

                        List<Lead> leadList = new List<Lead>();
                        // Check CRUD permissions for Lead object
                        if (Schema.SObjectType.Lead.isAccessible()) {
                            // Get accessible fields from the Lead object
                            Map<String, Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();
                            String accessibleFields = '';
                            for (String field : getFields('Lead').split(',')) {
                                if (leadFields.containsKey(field.trim()) && leadFields.get(field.trim()).getDescribe().isAccessible()) {
                                    accessibleFields += field.trim() + ',';
                                }
                            }
                            if (String.isNotBlank(accessibleFields)) {
                                // Remove trailing comma
                                accessibleFields = accessibleFields.substring(0, accessibleFields.length() - 1);
                                // Construct and execute the SOQL query with only accessible fields
                                String leadQuery = 'SELECT ' + accessibleFields + ' FROM Lead WHERE Id = :recordId';
                                leadList = Database.query(leadQuery);
                            }
                        }

                        //String leadQuery = 'SELECT '+getFields('Lead') +' FROM Lead WHERE Id =\''+String.escapeSingleQuotes(recordId)+'\'';
                        //List<Lead> leadList = Database.query(leadQuery);

                        jsonFields = batch.jsonForMobileCampaignPerRecord(leadList[0],'Lead',listOfInwiseMapping,objInwiseFields,mapInwiseMapping);
                        replaceJson = '"mobile_number": "'+ lead.MobilePhone +'"';
                        jsonFields = jsonFields.replace(replaceJson, '"rcpt": "'+ mobileNumber + '"');
                        jsonFields =replaceJSONValues(jsonFields);
                    }
                   
                }
        
               
                WhatsappWrapper responseMap = inwiseHttpUtil.InwiseCalloutBulkSendWhatsApp(objInwiseUtil, template_id, listOfLogs, content,mobileNumber,templateMapping,mediaUrl,async,tagsLi,jsonFields);
                if(responseMap != null){
                    if(responseMap.errorLogs != null){
                        listOfErrorLogs.add(responseMap.errorLogs);
                    }
                    String statusCode;
                    String rejectReason;
                    String status;
                    if(responseMap.toMap != null){
                         status = responseMap.toMap.get('status');
                         statusCode = responseMap.toMap.get('statusCode');
                         rejectReason = responseMap.toMap.get('rejectReason');
                        if(Boolean.valueOf(responseMap.toMap.get('isWhtasAppSent'))){
                            msg = 'SUCCESS';
                        }
                        else{
                            msg = String.isNotBlank(rejectReason) ? rejectReason :  inwiseConstants.UNABLE_TO_SEND_EMAIL;
                        }
                    }
                    
                   
                        if(String.isNotBlank(recordId) && String.isNotBlank(statusCode) && statusCode == '200'){
                            if(saveTask){
                                task taskRecord = doCreateTask(template_id, mobileNumber, recordId,'Whatsapp');
                                if(taskRecord != null){
                                    taskList.add(taskRecord);
                                }                                
                            }
                            if(saveMessagingHistory){
                                Messaging_History__c messageHistoryRecord = doCreateMessageHistory(content, mobileNumber,recordId, status, rejectReason,'Whatsapp',inwiseHttpUtil.getJSONSendWhatsApp(objInwiseUtil,template_id,content,mobileNumber,templateMapping,mediaUrl,async,tagsLi,jsonFields));
                                if(messageHistoryRecord != null){
                                    messageHistoryList.add(messageHistoryRecord);
                                }                               
                            }
                        }
                       
                }
            }
            catch(Exception ex){
                if(acc == NULL){
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord('Please add valid accountId', 'inwiseSendSMSLtngController', 'sendBulkWhatsAppAndCreateActivity'));
                }else{
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'inwiseSendSMSLtngController', 'sendBulkWhatsAppAndCreateActivity'));
                }
                
            }
        }
            if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                insert listOfLogs;
            }
            if(!messageHistoryList.isEmpty()){
                system.debug('messageHistoryList=='+messageHistoryList);
                insert messageHistoryList;
            }
            if(!taskList.isEmpty()){
                system.debug('taskList=='+taskList);
                insert taskList;
            }
            if(!listOfErrorLogs.isEmpty()){
                system.debug('=='+listOfErrorLogs);
                    insert listOfErrorLogs;
            }
                       
            return msg;
    }

    public static String replaceJSONValues(String jsonString){
        jsonString = jsonString.replace(' "name": "' , '"name": "Field');
        return jsonString;
    }
    public static String getFields(String objName){
        SObjectType type = Schema.getGlobalDescribe().get(objName);
        Map<String,Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        String fields = '';
        for(Schema.SObjectField fld:mfields.values()){
            fields += fld+',';
        }
        fields = fields.removeEnd(',');
        System.debug('=fields='+fields);
        return fields;
    }
    public class SelectOption {
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
            this.disabled = false;
            this.escapeItem = false;
        }

        public SelectOption(String value, String label, Boolean isDisabled) {
            this.value = value;
            this.label = label;
            this.disabled = isDisabled;
            this.escapeItem = false;
        }

        @AuraEnabled
        public String label         {get;set;}
        @AuraEnabled
        public String value         {get;set;}
        @AuraEnabled
        public Boolean disabled     {get;set;}
        @AuraEnabled
        public Boolean escapeItem   {get;set;}
    }
}