/******************************************************************************************
*Created By:    NLINEAXIS
*Created On:    Feb 20 2023
*Purpose :     

Modification Log 
--------------------
Date            Version     Developer                  Comments
------------------------------------------------------------------------------------
09/27/2021      1.0.0       NLINEAXIS      Created

/******************************************************************************************/
global with sharing class EMAIL{

    @InvocableMethod(label='Send' description='Method to use send an email')
    global static void send(List<String> listOfJSONString) {                
        system.debug('listOfJSONString from email ' + listOfJSONString);
        system.debug('listOfJSONString from email ' + listOfJSONString[0]);
        String jsonString = listOfJSONString[0];
        // Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        // System.debug('dataMap is ' + dataMap);


        if(!listOfJSONString.isEmpty()){
            if(listOfJSONString.size() ==1){
            String subject;
            String templateId;
            List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
            try{
                Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
                String recordId='';
                String accountId='';
                Boolean saveTask=false;
                Boolean saveMessagingHistory =false;
                String email ='';
                String replyTo ='';
                String toName ='';
                String fromName ='';
                String fromEmail='';
                String tagsLi ='';

                for(String key : datamap.keySet()){
                    if (key.equalsIgnoreCase('RecordId')) {
                        recordId = (String)dataMap.get(key);
                    }
                    else if(key.equalsIgnoreCase('inwiseAccount')){
                        accountId =  (String)dataMap.get(key);
                    }
                    else if(key.equalsIgnoreCase('createTask')){
                        saveTask = (Boolean)dataMap.get(key);
                    }
                    else if(key.equalsIgnoreCase('saveToInwiseMessagingHistory')){
                        saveMessagingHistory = (Boolean)dataMap.get(key);
                    }
                    else if(key.equalsIgnoreCase('email')){
                        email = (String)dataMap.get(key);
                    }
                    else if(key.equalsIgnoreCase('reply_to')){
                        replyTo = (String)dataMap.get(key);
                    }
                    else if(key.equalsIgnoreCase('toname')){
                        toname = (String)dataMap.get(key);
                    }
                    else if(key.equalsIgnoreCase('subject')){
                        subject =(String)dataMap.get(key);
                    }
                    else if(key.equalsIgnoreCase('from_name')){
                        fromName = (String)dataMap.get(key);
                    }
                    else if(key.equalsIgnoreCase('from_email')){
                        fromEmail = (String)dataMap.get(key);
                    }
                    else if(key.equalsIgnoreCase('template_id')){
                        templateId = (String)dataMap.get(key);
                    }
                    else if(key.equalsIgnoreCase('tags')){
                        tagsLi = (String)dataMap.get(key);
                    }
                }

                if(String.isBlank(accountId)){
                    accountId = [Select Id FROM Account__c WHERE Default__c = :true WITH SECURITY_ENFORCED].Id;
                }
                String idPrefix = String.isNotBlank(recordId) ? recordId.substring(0,3) : '';
                if(String.isBlank(email)){
                    System.debug('==email==11='+email);
                    if(idPrefix == '003'){
                            email = [Select Email FROM Contact Where Id =:recordId WITH SECURITY_ENFORCED].Email;
                    }
                    else if(idPrefix == '00Q'){
                        email = [Select Email FROM Lead Where Id =:recordId WITH SECURITY_ENFORCED].Email;
                    }
                    }
                else{
                    if(String.isNotBlank(recordId)){
                        saveTask = true;
                        saveMessagingHistory = true;
                    }
                    else{
                        saveTask = false;
                        saveMessagingHistory = false;
                    }
                }
                
                if(string.isBlank(email) && string.isBlank(recordId)){
                    Error_Logs__c errLogForEmail = new Error_Logs__c(Message__c = 'Please add any one value email or recordId.',Run_By__c = UserInfo.getUserId(),
                                                                        Run_On__c = datetime.now(),Class_Name__c = 'EMAIL',Method_Name__c = 'Send');
                            listOfErrorLogs.add(errLogForEmail); 
                }
                else if(string.isNotBlank(templateId) && string.isNotBlank(subject)){
                    if(idPrefix == '001' && String.isBlank(email) ){
                        Error_Logs__c errorLogs = new Error_Logs__c(Message__c = inwiseConstants.EMAIL_Error_MSG_FOR_Acc,Run_By__c = UserInfo.getUserId(),
                                                                        Run_On__c = datetime.now(),Class_Name__c = 'EMAIL',Method_Name__c = 'Send');
                        listOfErrorLogs.add(errorLogs);
                    }
                    else{
                        sendEmailFuture(templateId, fromEmail, saveTask, saveMessagingHistory, accountId,toname,subject,fromName,tagsLi,email,replyTo,recordId);
                    }
                        
                }
                else if (string.isBlank(subject)){
                    Error_Logs__c errLogForSub = new Error_Logs__c(Message__c = 'Subject is mandatory please provide.',Run_By__c = UserInfo.getUserId(),
                                                                        Run_On__c = datetime.now(),Class_Name__c = 'EMAIL',Method_Name__c = 'Send');
                        listOfErrorLogs.add(errLogForSub);
                }
            }catch(Exception ex){
                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'EMAIL', 'send'));
                system.debug('exception is ' + ex.getMessage());
            }
            if(!listOfErrorLogs.isEmpty()){
                insert listOfErrorLogs;
                system.debug('list of logs ' + listOfErrorLogs);
            }
        }
    	else{
        emailFuture(listOfJSONString);
    }
            }
    }

    @future(callout=true)
    static void sendEmailFuture(String templateId,String fromEmail, Boolean saveTask, Boolean saveMessagingHistory, String accountId
                                , String toName, String subject, String fromName, String tagsLi,String email, String replyTo ,String recordId) {
        String msg = inwiseSendSMSLtngController.sendEmailAndCreateActivity(templateId,fromEmail, saveTask, saveMessagingHistory, accountId,toname,subject,fromName,tagsLi,email,replyTo,recordId);
    }

    @future(callout=true)
    public static void sendEmailFuture1(String wrapperEmailList/*String smsText, String mobileNumber, String recordId, Boolean saveTask, Boolean saveMessagingHistory, String fromNumber, String accountId*/) {
        //system.debug('sendSMSFuture1 is ==>'+wrapperEmailList);
        inwiseSendSMSLtngController.sendBulkEmailAndCreateActivity(wrapperEmailList);
    }

    public static void emailFuture(List<String> listOfJSONString){
        System.debug('listOfJSONString==='+listOfJSONString.size());
        Integer batchSize =50;
        // Determine the number of batches needed
        Integer numBatches = (listOfJSONString.size() + batchSize - 1) / batchSize;
        System.debug('numBatches==='+numBatches);
        // Loop through the recordIds and create batches
        for (Integer i = 0; i < numBatches; i++) {
            Integer startIdx = i * batchSize;
            Integer endIdx = Math.min((i + 1) * batchSize, listOfJSONString.size());
            
            List<String> contactList = new List<String>();
            for (Integer j = startIdx; j < endIdx; j++) {
                contactList.add(listOfJSONString[j]);
            }
            System.debug('contactList==='+contactList.size());
            EmailQueueable emailQueue = new EmailQueueable(contactList);
            ID jobId = System.enqueueJob(emailQueue);
            System.debug('jobId===='+jobId);
            
        }
        
    }
}