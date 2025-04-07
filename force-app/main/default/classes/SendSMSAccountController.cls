/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 19/11/2020
*Purpose :     Send SMS functionality
*Modified:   
================================================================
Modified On      Version      Modified By        Purpose  
================================================================
15/12/2021       1.0.0        S. Vaishnav        Modified:- Choose template functionality
30/08/2022       1.0.1        S. Vaishnav        Modified:- Store status and remark in message history
26/09/2022       1.0.2        S. Vaishnav        Modified:- Added try catch block in doSendSMS method

/******************************************************************************************/
public with sharing class SendSMSAccountController {
    
    public Boolean isSMSSent                                    {get;set;}
    public Account objAccount                                   {get;set;}
    public String messageBody                                   {get;set;}
    public String accountJSON                                   {get;set;}
    public String selectedNumber                                {get;set;}
    public String selectedTemplate                              {get;set;}
    public Boolean isPersonEnabled                              {get;set;}
    public String selectedLandingPage                           {get;set;}
    public String selectedAccountField                          {get;set;}
    public List<SelectOption> listOfSelectOptionTemplates       {get;set;}
    public List<SelectOption> listOfSelectOptionPhoneNumbers    {get;set;}
    public List<SelectOption> listOfSelectOptionLandingPages    {get;set;}
    public List<SelectOption> listOfSelectOptionFields_Account  {get;set;}
    public String csrfToken                                     { get; set; }
    
    List<Logs__c> listOfLogs;
    InwiseUtil objInwiseUtil                                    {get;set;}
    
    public SendSMSAccountController(ApexPages.StandardController std) {

        csrfToken = inwiseUtil.generateCSRFToken(); // Generate a unique token
        listOfSelectOptionTemplates = new List<SelectOption>();
        listOfSelectOptionPhoneNumbers = new List<SelectOption>();
        listOfSelectOptionLandingPages = new List<SelectOption>();
        listOfSelectOptionFields_Account = new List<SelectOption>();
        
        objInwiseUtil = new InwiseUtil(null);
        List<Account> listOfAccount = [Select Id,Name from Account where Id =: std.getRecord().Id WITH SECURITY_ENFORCED LIMIT 1];
        
        if(!listOfAccount.isEmpty()){
            objAccount = listOfAccount.get(0);
            listOfSelectOptionFields_Account = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_ACCOUNT, inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL, true);
            getAccountPhoneNumbers(listOfSelectOptionFields_Account, objAccount.Id);
            listOfSelectOptionFields_Account = listOfSelectOptionRemoveNullFields(listOfSelectOptionFields_Account, objAccount);
            
            getTemplatesList();
            getLandingPagesList();
        }
    }
    
    public void insertLogs(){

        String csrfTokenValue = ApexPages.currentPage().getParameters().get('csrfToken');

        // Validate the CSRF token
        if (csrfTokenValue == null || !inwiseUtil.validateCSRFToken(csrfTokenValue)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid CSRF token. Action cannot be performed.'));
            return;
        }
        
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            if(Logs__c.SObjectType.getDescribe().isCreateable()){
                insert listOfLogs;
            } 
        }
    }
    
    /**
**This method will remove all those fields in the pciklist which are having null values
**/
    public List<SelectOption> listOfSelectOptionRemoveNullFields(List<SelectOption> listofSO, Account objAccountTemp ){
        List<SelectOption> listofSONew = new List<SelectOption>();
        if(!listofSO.isEmpty()){
            for(SelectOption so : listofSO){
                if(!String.isBlank(so.getValue()) && objAccountTemp.get(so.getValue()) != null){
                    listofSONew.add(so);
                }
            }  
        }
        return listofSONew;
    }
    
    public List<SelectOption> getAccountPhoneNumbers(List<SelectOption> listOfSelectOptionFieldsAccountP1, Id cid){
        
        String strSOLabel = '';
        String strSOValue = '';
        String stringSOQLSelect = '';
        Map<String, Boolean> mapOfAllPhoneApi = new Map<String, Boolean>();
        listOfSelectOptionPhoneNumbers.add(new SelectOption('', '--None--'));
        
        if (Schema.SObjectType.Account.isAccessible()) {
            // Get accessible fields from the Account object
            Map<String, Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();
            if(!listOfSelectOptionFieldsAccountP1.isEmpty()){
                
                Boolean isNameFieldAdded = false;
                for(SelectOption so : listOfSelectOptionFieldsAccountP1){
                    if(so.getLabel().toLowerCase().contains('(phone)')){
                        mapOfAllPhoneApi.put(so.getValue(), true);
                    }
                    //add all field so will be used in JSON value fetch
                    if(!String.isEmpty(so.getValue())){
                        if (accountFields.containsKey(so.getValue()) && accountFields.get(so.getValue()).getDescribe().isAccessible()) {
                            //Added this if block because we are getting Name.isFilterable() false while adding Name
                            if(!isNameFieldAdded && so.getValue() == 'Name'){
                                isNameFieldAdded = true;
                            }
                            stringSOQLSelect += so.getValue() + ',';
                        }
                    }
                }
                if(!isNameFieldAdded){
                    stringSOQLSelect = 'Name,' + stringSOQLSelect;
                }
                
                if(!String.isEmpty(stringSOQLSelect)){
                    stringSOQLSelect = stringSOQLSelect.substring(0, stringSOQLSelect.length()-1);
                    String soql = 'SELECT ' + String.escapeSingleQuotes(stringSOQLSelect) + ' FROM ACCOUNT where Id =: cid';
                    List<Account> listOfAccount = Database.query(soql);
                    
                    if(!listOfAccount.isEmpty()){
                        objAccount = listOfAccount.get(0);
                        accountJSON = JSON.serialize(objAccount);
                        accountJSON = accountJSON.replace('\\r\n', ' ');
                        accountJSON = accountJSON.replace('\\n', ' ');
                        accountJSON = accountJSON.replace('\\r', ' ');
                        
                        for(SelectOption so : listOfSelectOptionFieldsAccountP1){
                            if(mapOfAllPhoneApi.get(so.getValue()) != null && mapOfAllPhoneApi.get(so.getValue())){
                                strSOLabel = (string)objAccount.get(so.getValue());
                                if(!String.isEmpty(strSOLabel)){
                                    strSOValue = strSOLabel.replace(' ', '').replace('(', '').replace(')', '').replace('-', '').replace('+', '');
                                    listOfSelectOptionPhoneNumbers.add(new SelectOption(strSOValue, strSOLabel));  
                                }
                            }
                        }   
                    }
                }
            } 
        }
        return null;
    }
    
    public void getTemplatesList(){
        
        listOfLogs = new List<Logs__c>();
        if(!objInwiseUtil.CheckIfCredentialExists()){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error, InwiseConstants.INWISE_CREDENTIAL_MISSING));      
            return;
        } 
        try{
            Map<String, String> mapOfTemplateFields = inwiseHttpUtil.InwiseCalloutTemplatesList(objInwiseUtil, listOfLogs);    
            listOfSelectOptionTemplates.add(new SelectOption('', '--None--'));
            if(!mapOfTemplateFields.isEmpty()){
                for(String k : mapOfTemplateFields.keySet()){
                    listOfSelectOptionTemplates.add(new SelectOption(mapOfTemplateFields.get(k), k));            
                }
            }
        }catch(Exception ex){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error, ex.getMessage()));      
        }
    }
    
    public void getLandingPagesList(){
        
        if(!objInwiseUtil.CheckIfCredentialExists()){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error, InwiseConstants.INWISE_CREDENTIAL_MISSING));      
            return;
        } 
        try{
            Map<String, String> mapOfLandingPageFields = inwiseHttpUtil.InwiseCalloutLandingPagesList(objInwiseUtil, listOfLogs, false, 'Landing Page');    
            listOfSelectOptionLandingPages.add(new SelectOption('', '--None--'));
            if(!mapOfLandingPageFields.isEmpty()){
                for(String k : mapOfLandingPageFields.keySet()){
                    listOfSelectOptionLandingPages.add(new SelectOption(k, mapOfLandingPageFields.get(k)));            
                }
            }
        }catch(Exception ex){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error, ex.getMessage()));      
        }
    }
    
    public PageReference doSendSMS(){
        
        PageReference pr; 
        isSMSSent = false;
        listOfLogs = new List<Logs__c>();
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        Webhook_Setting__c objInwiseWebhookSetting = Webhook_Setting__c.getAll().get('default');
        
        if(selectedNumber == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Please select a number to send SMS');
            ApexPages.addMessage(myMsg);
            return pr;
        } 
        else if(String.isEmpty(messageBody)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Please provide SMS body');
            ApexPages.addMessage(myMsg);
            return pr;
        }
        
        Map<String, String> responseMap = inwiseHttpUtil.InwiseCalloutSendSMS(objInwiseUtil, messageBody, selectedNumber, listOfLogs, '');
        
        if(!responseMap.isEmpty()){
            String status = responseMap.get('status');
            String statusCode = responseMap.get('statusCode');
        	String rejectReason = responseMap.get('rejectReason');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, inwiseConstants.SMS_SENT_SUCCESS);

            if(Boolean.valueOf(responseMap.get('isSMSSent'))){
                isSMSSent = true;
            }
            else{
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, String.isNotBlank(rejectReason) ? rejectReason : inwiseConstants.UNABLE_TO_SEND_SMS);
            }
            ApexPages.addMessage(myMsg);
            
            try{
                if(objInwiseWebhookSetting != null && String.isNotBlank(statusCode) && statusCode == '200') {
                    if(objInwiseWebhookSetting.Save_To_Activity_History__c){
                        doCreateTask();
                    }
                    if(objInwiseWebhookSetting.Save_To_Messaging_History__c){
                        doCreateMessageHistory(status, rejectReason);
                    }
                }
                insertLogs();
            }catch(Exception ex){
                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'SendSMSAccountController', 'doSendSMS'));
            }
            if(!listOfErrorLogs.isEmpty()){
                insert listOfErrorLogs;
            }
        }
        return pr;
    }
    
    public void doCreateTask(){
        
        if(Schema.SObjectType.Task.isCreateable()){
            Task objTask = new task();
            if(Schema.sObjectType.Task.fields.WhatId.isCreateable()){
                objTask.WhatId = objAccount.id;
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
                objTask.description = 'SMS has been to ' + objAccount.Name + '\n';
            }
            objTask.description += 'Number : ' + selectedNumber + '\n';
            objTask.description += 'SMS Body : ' + messageBody;
            insert objTask;
        }
    }
    
    public void doCreateMessageHistory(String status, String remark){
        
        if(Schema.SObjectType.Messaging_History__c.isCreateable()){
            Messaging_History__c objMsgHistory = new Messaging_History__c();
            if(Schema.sObjectType.Messaging_History__c.fields.Account__c.isCreateable()){
                objMsgHistory.Account__c = objAccount.id;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Direction__c.isCreateable()){
                objMsgHistory.Direction__c = 'Outgoing';
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Description__c.isCreateable()){
                objMsgHistory.Description__c = 'SMS has been to ' + objAccount.Name + '\n';
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
            objMsgHistory.Description__c += 'Number : ' + selectedNumber + '\n';
            objMsgHistory.Description__c += 'SMS Body : ' + messageBody;
            insert objMsgHistory;
        }
    }
}