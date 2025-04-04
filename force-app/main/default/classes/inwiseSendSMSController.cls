/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 20/06/2017
*Purpose :     Send SMS functionality
*Modified:   
================================================================
Modified On      Version      Modified By        Purpose  
================================================================
13/12/2021       1.0.0        S. Vaishnav        Modified:- Choose template functionality
30/08/2022       1.0.1        S. Vaishnav        Modified:- Store status and remark in message history
26/09/2022       1.0.2        S. Vaishnav        Modified:- Added try catch block in doSendSMS method

/******************************************************************************************/
public with sharing class inwiseSendSMSController {
    
    InwiseUtil objInwiseUtil                                    {get;set;}
    public Contact objContact                                   {get;set;}
    public String contactJSON                                   {get;set;}
    public Boolean isSMSSent                                    {get;set;}
    public String messageBody                                   {get;set;}
    public String selectedNumber                                {get;set;}
    public String selectedTemplate                              {get;set;}
    public String selectedLandingPage                           {get;set;}
    public String selectedContactField                          {get;set;}
    public List<SelectOption> listOfSelectOptionTemplates       {get;set;}
    public List<SelectOption> listOfSelectOptionPhoneNumbers    {get;set;}
    public List<SelectOption> listOfSelectOptionLandingPages    {get;set;}
    public List<SelectOption> listOfSelectOptionFields_Contact  {get;set;}
    public String csrfToken                                     { get; set; }
    
    List<Logs__c> listOfLogs;
    
    public inwiseSendSMSController(ApexPages.StandardController std) {
        
        csrfToken = inwiseUtil.generateCSRFToken(); // Generate a unique token
        objInwiseUtil = new InwiseUtil(null);
        listOfLogs = new List<Logs__c>();
        listOfSelectOptionTemplates = new List<SelectOption>();
        listOfSelectOptionPhoneNumbers = new List<SelectOption>();
        listOfSelectOptionLandingPages = new List<SelectOption>();
        listOfSelectOptionFields_Contact = new List<SelectOption>();

        List<Contact> listOfContact = new List<Contact>();
        
        if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.FirstName.isAccessible() &&
            Schema.sObjectType.Contact.fields.LastName.isAccessible() ){

            listOfContact = [Select Id,FirstName,LastName from Contact where Id =: std.getRecord().Id LIMIT 1];
        }
        if(!listOfContact.isEmpty()){
            objContact = listOfContact.get(0);
            listOfSelectOptionFields_Contact = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_CONTACT, inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL, true);
           
            getContactPhoneNumbers(listOfSelectOptionFields_Contact,objContact.Id);
            listOfSelectOptionFields_Contact = listOfSelectOptionRemoveNullFields(listOfSelectOptionFields_Contact, objContact);
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
    
    //This method will remove all those fields in the pciklist which are having null values
    public List<SelectOption> listOfSelectOptionRemoveNullFields(List<SelectOption> listofSO, Contact objContactTemp ){
        
        List<SelectOption> listofSONew = new List<SelectOption>();
        if(!listofSO.isEmpty()){

            // Get the map of populated fields for the Contact record
            Map<String, Object> populatedFields = objContactTemp.getPopulatedFieldsAsMap();

            for(SelectOption so : listofSO){
       
                //if(!String.isBlank(so.getValue()) && objContactTemp.get(so.getValue()) != NULL){
                if(!String.isBlank(so.getValue()) && populatedFields.containsKey(so.getValue()) && objContactTemp.get(so.getValue()) != NULL){ 
                    System.debug('=so@@@='+so);
                    listofSONew.add(so);
                }
            }  
        }
        return listofSONew;
    }
    
    public List<SelectOption> getContactPhoneNumbers(List<SelectOption> listOfSelectOptionFieldsContactP1, Id cid){
        
        String stringSOQLSelect = '';
        String strSOLabel = '', strSOValue='';
        Map<String,boolean> mapOfAllPhoneApi = new Map<String,boolean>();
        listOfSelectOptionPhoneNumbers.add(new SelectOption('','--None--'));

        // Ensure CRUD and FLS enforcement
        Schema.DescribeSObjectResult contactDescribe = Schema.SObjectType.Contact;
        if(contactDescribe.isAccessible() ){

            // Filter fields based on FLS
            Map<String, Schema.SObjectField> contactFields = contactDescribe.fields.getMap();
        
            if(!listOfSelectOptionFieldsContactP1.isEmpty()){
                for(SelectOption so:listOfSelectOptionFieldsContactP1){
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
                    String soql = 'SELECT  ' + String.escapeSingleQuotes(stringSOQLSelect) + ' FROM CONTACT where Id =: cid ';
                    List<Contact> listOfContact = Database.query(soql);
                    
                    if(!listOfContact.isEmpty()){
                        objContact = listOfContact.get(0);
                        contactJSON = JSON.serialize(objContact);
                        contactJSON = contactJSON.replace('\\r\n', ' ');
                        contactJSON = contactJSON.replace('\\n', ' ');
                        contactJSON = contactJSON.replace('\\r', ' ');
                        
                        for(SelectOption so:listOfSelectOptionFieldsContactP1){
                            if(mapOfAllPhoneApi.get(so.getValue()) != NULL && mapOfAllPhoneApi.get(so.getValue())){
                                strSOLabel = (string)objContact.get(so.getValue());
                                if(!String.isEmpty(strSOLabel)){
                                    strSOValue = strSOLabel.replace(' ', '').replace('(','').replace(')','').replace('-','').replace('+','');
                                    listOfSelectOptionPhoneNumbers.add(new SelectOption(strSOValue,strSOLabel));  
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
            Map<String, String> mapOfTemplates = inwiseHttpUtil.InwiseCalloutTemplatesList(objInwiseUtil, listOfLogs);    
            listOfSelectOptionTemplates.add(new SelectOption('', '--None--'));
            
            if(!mapOfTemplates.isEmpty()){
                for(String key : mapOfTemplates.keySet()){
                    listOfSelectOptionTemplates.add(new SelectOption(mapOfTemplates.get(key), key));            
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
        system.debug('=messageBody='+messageBody);
        Map<String, String> responseMap = inwiseHttpUtil.InwiseCalloutSendSMS(objInwiseUtil, messageBody, selectedNumber, listOfLogs, '');
        system.debug('=responseMap='+responseMap);
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
                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'inwiseSendSMSController', 'doSendSMS'));
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
            if(Schema.sObjectType.Task.fields.WhoId.isCreateable()){
                objTask.WhoId = objContact.id;
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
                objTask.description = 'SMS has been to ' + objContact.FirstName + ' ' + objContact.LastName + '\n';
            }
            objTask.description += 'Number : ' + selectedNumber + '\n';
            objTask.description += 'SMS Body : ' + messageBody;
            insert objTask;
        }
    }
    
    public void doCreateMessageHistory(String status, String remark){
        
        if(Schema.SObjectType.Messaging_History__c.isCreateable()){
            Messaging_History__c objMsgHistory = new Messaging_History__c();
            if(Schema.sObjectType.Messaging_History__c.fields.Contact__c.isCreateable()){
                objMsgHistory.Contact__c = objContact.id;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Direction__c.isCreateable()){
                objMsgHistory.Direction__c = 'Outgoing';
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Description__c.isCreateable()){
                objMsgHistory.Description__c = 'SMS has been to ' + objContact.FirstName + ' ' + objContact.LastName+'\n';
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