public with sharing class EmailQueueable implements Queueable {
    public List<String> listOfJSONString ; 
    public EmailQueueable(List<String> contList){
        this.listOfJSONString = contList ;  
    }

    public void execute(QueueableContext context) {
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        List<EmailWrapper> EmailWrapperList = new List<EmailWrapper>();
        try{
            for(Integer i=0;i<listOfJSONString.size();i++){
                system.debug('=listOfJSONString11='+listOfJSONString[i]);
                Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(listOfJSONString[i]);
                String recordId = '';
                String accountId= '';
                Boolean saveTask = false;
                Boolean saveMessagingHistory = false;
                String email = '';
                String replyTo = '';
                String toName= '';
                String subject = '';
                String fromName = '';
                String fromEmail = '';
                String templateId = '';
                String tagsLi = '';
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
                //System.debug('recordId=11=='+recordId);
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
                    //System.debug('recordId==='+recordId);
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
                        EmailWrapperList.add(new EmailWrapper(recordId, accountId, saveTask, saveMessagingHistory, email, replyTo, toName, subject,fromName,fromEmail,templateId,tagsLi,null,null));
                    }
                        
                }
                else if (string.isBlank(subject)){
                    Error_Logs__c errLogForSub = new Error_Logs__c(Message__c = 'Subject is mandatory please provide.',Run_By__c = UserInfo.getUserId(),
                                                                        Run_On__c = datetime.now(),Class_Name__c = 'EMAIL',Method_Name__c = 'Send');
                        listOfErrorLogs.add(errLogForSub);
                }
               
            }
        }
        catch(Exception ex){
           system.debug('==error record==='+ex.getMessage());
           listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'EmailQueueable', 'execute'));
       }

       if(EmailWrapperList != null){  
        system.debug('JSON EmailWrapperList is ==>'+JSON.serialize(EmailWrapperList));
        EMAIL.sendEmailFuture1(JSON.serialize(EmailWrapperList));
        }

       if(listOfErrorLogs.size()>0){
        insert listOfErrorLogs;
    }
    }
}