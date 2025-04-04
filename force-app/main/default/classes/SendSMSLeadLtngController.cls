/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 26 Feb 2018
*Purpose :     lightning component controller for lead send sms button
================================================================
Modified On      Version      Modified By        Purpose  
================================================================
13/12/2021       1.0.0        S. Vaishnav        Modified:- Choose template functionality
30/08/2022       1.0.1        S. Vaishnav        Modified:- Store status and remark in message history
26/09/2022       1.0.2        S. Vaishnav        Modified:- Added try catch block in SendSMSAndCreateActivity method

/******************************************************************************************/
public with sharing class SendSMSLeadLtngController {
  
    @AuraEnabled public static String getLeadJSONString(String lid){

        String leadJSON = '';
        String strSOLabel = '';
        String strSOValue = '';
        String stringSOQLSelect = '';
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        List<SendSMSLeadLtngController.SelectOption> listOfSelectOptionPhoneNumbers = new List<SelectOption>();
        List<System.SelectOption> listOfSelectOptionFieldsLeadP1 = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_LEAD, inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL, true);
        
        if (Schema.SObjectType.Lead.isAccessible()) {
            Map<String, Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();

            if(!listOfSelectOptionFieldsLeadP1.isEmpty()){
                for(System.SelectOption so:listOfSelectOptionFieldsLeadP1){
                    if(!String.isEmpty(so.getValue())){
                        if (leadFields.containsKey(so.getValue()) && leadFields.get(so.getValue()).getDescribe().isAccessible()) {
                            stringSOQLSelect += so.getValue() + ',';
                        }
                    }
                }
                //System.debug('stringSOQLSelect::-->>>' + stringSOQLSelect);
                if(!String.isEmpty(stringSOQLSelect)){
                    stringSOQLSelect = stringSOQLSelect.substring(0, stringSOQLSelect.length()-1);
                    String soql= 'SELECT  ' + stringSOQLSelect + ' FROM LEAD where Id =: lid ';

                    List<Lead> listOfLead = Database.query(soql);
                    if(!listOfLead.isEmpty()){
                        Lead objLead = listOfLead.get(0);
                        leadJSON = JSON.serialize(objLead);
                        leadJSON = leadJSON.replace('\\r\n', ' ');
                        leadJSON = leadJSON.replace('\\n', ' ');
                        leadJSON = leadJSON.replace('\\r', ' ');
                    }
                }
            } 
        }
        return leadJSON;
    }

    @AuraEnabled
    public static List<SendSMSLeadLtngController.SelectOption> getTemplatesList(){
        
        HttpResponse res;
        Http http = new Http();
        List<Logs__c> listOfLogs = new List<Logs__c>();
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        List<SendSMSLeadLtngController.SelectOption> listOfSelectOptionTemplates = new List<SelectOption>();
        
        if(objInwiseUtil.objInwiseAccount == null){
            return listOfSelectOptionTemplates;
        }
        try{
            Map<String,String> mapOfLandingPageFields = inwiseHttpUtil.InwiseCalloutTemplatesList(objInwiseUtil, listOfLogs);    
            listOfSelectOptionTemplates.add(new SelectOption('', '--None--'));
            if(!mapOfLandingPageFields.isEmpty()){
                for(String k : mapOfLandingPageFields.keySet()){
                    listOfSelectOptionTemplates.add(new SendSMSLeadLtngController.SelectOption(mapOfLandingPageFields.get(k), k)); 
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
    public static List<SendSMSLeadLtngController.SelectOption> getLandingPagesList(){
        
        HttpResponse res;
        Http http = new Http();
        List<Logs__c> listOfLogs = new List<Logs__c>();
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        List<SendSMSLeadLtngController.SelectOption> listOfSelectOptionLandingPages = new List<SelectOption>();
        
        if(objInwiseUtil.objInwiseAccount == NULL){
            return listOfSelectOptionLandingPages;
        }
        try{
            Map<String,String> mapOfLandingPageFields = inwiseHttpUtil.InwiseCalloutLandingPagesList(objInwiseUtil, listOfLogs, false, 'Landing Page');    
            listOfSelectOptionLandingPages.add(new SelectOption('', '--None--'));
            if(!mapOfLandingPageFields.isEmpty()){
                for(String k:mapOfLandingPageFields.keySet()){
                    listOfSelectOptionLandingPages.add(new SendSMSLeadLtngController.SelectOption(k, mapOfLandingPageFields.get(k))); 
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
    public static List<SendSMSLeadLtngController.SelectOption> getlistOfSelectOptionFieldsLead(String lid){
        
        Lead objLead;
        String stringSOQLSelect = '';
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        List<SendSMSLeadLtngController.SelectOption> listOfSelectOptionLeadFields = new List<SelectOption>();
        List<System.SelectOption> listOfSelectOptionFieldsLeadP1= inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_LEAD, inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL, true);

        if (Schema.SObjectType.Lead.isAccessible()) {
            Map<String, Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();

            if(!listOfSelectOptionFieldsLeadP1.isEmpty()){
                for(System.SelectOption so:listOfSelectOptionFieldsLeadP1){
                    if(!String.isEmpty(so.getValue())){
                        if (leadFields.containsKey(so.getValue()) && leadFields.get(so.getValue()).getDescribe().isAccessible()) {
                            stringSOQLSelect += so.getValue() + ',';
                        }
                    }
                    listOfSelectOptionLeadFields.add(new SendSMSLeadLtngController.SelectOption(so.getValue(),so.getLabel()));  
                }
            }
            if(!String.isEmpty(stringSOQLSelect)){
                stringSOQLSelect = stringSOQLSelect.substring(0, stringSOQLSelect.length()-1);
                String soql= 'SELECT  ' + stringSOQLSelect + ' FROM LEAD where Id=:lid ';
                List<Lead> listOfLead = Database.query(soql);
                if(!listOfLead.isEmpty()){
                    objLead = listOfLead.get(0);
                }               
            }
            listOfSelectOptionLeadFields  = listOfSelectOptionRemoveNullFieldsLead(listOfSelectOptionLeadFields, objLead);
        }
        return listOfSelectOptionLeadFields;
    }

    /**
    **This method will remove all those fields in the pciklist which are having null values
    **/
    public static List<SendSMSLeadLtngController.SelectOption> listOfSelectOptionRemoveNullFieldsLead(List<SendSMSLeadLtngController.SelectOption> listofSO, Lead objLeadTemp ){
        List<SendSMSLeadLtngController.SelectOption> listofSONew = new List<SendSMSLeadLtngController.SelectOption>();
        if(!listofSO.isEmpty()){
            // Get the map of populated fields for the Contact record
            Map<String, Object> populatedFields = objLeadTemp.getPopulatedFieldsAsMap();
            
            for(SelectOption so:listofSO){
                if(!String.isBlank(so.Value) && populatedFields.containsKey(so.Value) && objLeadTemp.get(so.Value) != null){
                    listofSONew.add(so);
                }
            }  
        }
        return listofSONew;
    }

    @AuraEnabled 
    public static List<SendSMSLeadLtngController.SelectOption> getPhoneNumberSOLead(String lid){

        String strSOLabel = '';
        String strSOValue = '';
        String stringSOQLSelect = '';
        Map<String, Boolean> mapOfAllPhoneApi = new Map<String, Boolean>();
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        List<SendSMSLeadLtngController.SelectOption> listOfSelectOptionPhoneNumbers = new List<SelectOption>();
        List<System.SelectOption> listOfSelectOptionFieldsLeadP1 = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_LEAD, inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL, true);
           
        if (Schema.SObjectType.Lead.isAccessible()) {
            Map<String, Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();
            if(!listOfSelectOptionFieldsLeadP1.isEmpty()){
                for(System.SelectOption so:listOfSelectOptionFieldsLeadP1){
                    if(so.getLabel().toLowerCase().contains('(phone)')){
                        mapOfAllPhoneApi.put(so.getValue(), true);
                    }
                    //add all field so will be used in JSON value fetch
                    if(!String.isEmpty(so.getValue())){
                        if (leadFields.containsKey(so.getValue()) && leadFields.get(so.getValue()).getDescribe().isAccessible()) {
                            stringSOQLSelect += so.getValue() + ',';
                        }
                    }
                }

                if(!String.isEmpty(stringSOQLSelect)){
                    stringSOQLSelect = stringSOQLSelect.substring(0, stringSOQLSelect.length()-1);
                    String soql = 'SELECT  ' + stringSOQLSelect + ' FROM LEAD where Id=:lid ';
                    List<Lead> listOfLead = Database.query(soql);
                    if(!listOfLead.isEmpty()){
                        Lead objLead = listOfLead.get(0);
                        for(System.SelectOption so:listOfSelectOptionFieldsLeadP1){
                            if(mapOfAllPhoneApi.get(so.getValue()) != NULL && mapOfAllPhoneApi.get(so.getValue())){
                                strSOLabel = (string)objLead.get(so.getValue());
                                if(!String.isEmpty(strSOLabel)){
                                    strSOValue = strSOLabel.replace(' ', '').replace('(', '').replace(')', '').replace('-', '').replace('+', '');
                                    listOfSelectOptionPhoneNumbers.add(new SendSMSLeadLtngController.SelectOption(strSOValue, strSOLabel));  
                                }
                            }
                        }
                    }
                }
            }
        }
        return listOfSelectOptionPhoneNumbers;
    }

    @AuraEnabled 
    public static String SendSMSAndCreateActivity(String messageBody, String selectedNumber, String leadId){

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
                        doCreateTask(messageBody, selectedNumber, leadId);
                    }
                    if(objInwiseWebhookSetting.Save_To_Messaging_History__c){
                        doCreateMessageHistory(messageBody, selectedNumber, leadId, status, rejectReason);
                    }
                }
                
                if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                    insert listOfLogs;
                }
            }catch(Exception ex){
                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'SendSMSLeadLtngController', 'SendSMSAndCreateActivity'));
            }
            if(!listOfErrorLogs.isEmpty()){
                insert listOfErrorLogs;
            }
        }      
        return msg;
    }

    public static void doCreateTask(String messageBody, String selectedNumber, String leadId){

        if(Schema.SObjectType.Task.isCreateable()){
            Task objTask = new task();
            if(Schema.sObjectType.Task.fields.WhoId.isCreateable()){
                objTask.WhoId = leadId;
            }
            if(Schema.sObjectType.Task.fields.Subject.isCreateable()){
                objTask.Subject = 'inwise SMS';
            }
            if(Schema.sObjectType.Task.fields.Priority.isCreateable()){
                objTask.priority = 'Normal';
            }
            if(Schema.sObjectType.Task.fields.Status.isCreateable()){
                objTask.status = 'Completed';
            }
            if(Schema.sObjectType.Task.fields.Description.isCreateable()){
                objTask.description = 'Number : ' + selectedNumber + '\n';
            }
            objTask.description += 'SMS Body : ' + messageBody;
        
            insert objTask;
        }
    }
  
    public static void doCreateMessageHistory(String messageBody, String selectedNumber, String leadId, String status, String remark){

        if(Schema.SObjectType.Messaging_History__c.isCreateable()){
            Messaging_History__c objMsgHistory = new Messaging_History__c();
            if(Schema.sObjectType.Messaging_History__c.fields.Lead__c.isCreateable()){
                objMsgHistory.Lead__c = leadId;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Direction__c.isCreateable()){
                objMsgHistory.Direction__c = 'Outgoing';
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Description__c.isCreateable()){
                objMsgHistory.Description__c += 'Number : ' + selectedNumber + '\n';
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Message__c.isCreateable()){
                objMsgHistory.Message__c = messageBody.length() > 255 ? messageBody.substring(0, 255) : messageBody;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.To_Number__c.isCreateable()){
                objMsgHistory.To_Number__c = selectedNumber;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Channel_Type__c.isCreateable()){
                objMsgHistory.Channel_Type__c = 'SMS';
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Status__c.isCreateable()){
                objMsgHistory.Status__c = status;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Remark__c.isCreateable()){
                objMsgHistory.Remark__c = remark;
            }
                
            objMsgHistory.Description__c += 'SMS Body : ' + messageBody;
            insert objMsgHistory;
        }
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