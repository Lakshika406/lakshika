/******************************************************************************************
*Created By:  Shyam Vaishnav
*Created On: Dec 2021
*Purpose :     

Modification Log
--------------------
Date            Version     Developer                  Comments
------------------------------------------------------------------------------------
12/15/2021      1.0.0       NLINEAXIS(S.Vaishnav)      Created
08/30/2022      1.0.1       NLINEAXIS(S.Vaishnav)      Modified: saveToInwiseActivity replaced with createTask
26/09/2022      1.0.2       NLINEAXIS(S.Vaishnav)      Modified:- Added try catch block in send method
30/01/2023      1.0.3       NLINEAXIS(K. Goutam)       Modified:- Added deprecated on class & removed global from phoneNumber variable. 

/******************************************************************************************/
//@deprecated
global class TransactionalHelper{
    static string phoneNumber;
    @InvocableMethod(label='Send' description='Method to use send sms')
    global static void send(List<String> listOfJSONString) { 
        
        if(!listOfJSONString.isEmpty()){
            String smsText ;
            String mobileNumber;
            String subject;
            String templateId;
            
            List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
            try{
                Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(listOfJSONString[0]);
                
                //for SMS
                String fromNumber = dataMap.containsKey('from') ? (String)dataMap.get('from') : '';
                smsText = dataMap.containsKey('smsText') ? (String)dataMap.get('smsText') : '';
                String recordId = dataMap.containsKey('recordId') ? (String)dataMap.get('recordId') : '';
                String accountId = dataMap.containsKey('inwiseAccount') ? (String)dataMap.get('inwiseAccount') : '';
                mobileNumber = dataMap.containsKey('mobileNumber') ? (String)dataMap.get('mobileNumber') : '';
                Boolean saveTask = dataMap.containsKey('createTask') ? (Boolean)dataMap.get('createTask') : false;
                Boolean saveMessagingHistory = dataMap.containsKey('saveToInwiseMessagingHistory') ? (Boolean)dataMap.get('saveToInwiseMessagingHistory') : false;
                //for EMail 
                String email= dataMap.containsKey('email') ? (String)dataMap.get('email') : '';
                String replyTo = dataMap.containsKey('reply_to') ? (String)dataMap.get('reply_to') : '';
                String toName = dataMap.containsKey('toname') ? (String)dataMap.get('toname') : '';
                subject = dataMap.containsKey('subject') ? (String)dataMap.get('subject') : '';
                String fromName = dataMap.containsKey('from_name') ? (String)dataMap.get('from_name') : '';
                String fromEmail = dataMap.containsKey('from_email') ? (String)dataMap.get('from_email') : '';
                templateId = dataMap.containsKey('template_id') ? String.valueOf(dataMap.get('template_id')) : '';
                String tagsLi = dataMap.containsKey('tags') ? String.valueOf(dataMap.get('tags')) : '';
                if(String.isBlank(accountId)){
                    accountId = [Select Id FROM Account__c WHERE Default__c = :true WITH SECURITY_ENFORCED].Id;
                }    
                //System.debug('=accountId='+accountId);
                String idPrefix = String.isNotBlank(recordId) ? recordId.substring(0,3) : '';
                if(dataMap.containsKey('subject')){
                    
                    if(String.isBlank(email)){
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
                      // Error_Logs__c errLogForEmail = new Error_Logs__c(Message__c = 'Please add any one value email or recordId.',Run_By__c = UserInfo.getUserId(),
                                                                       // Run_On__c = datetime.now(),Class_Name__c = 'TransactionalHealper',Method_Name__c = 'Send');
                           // listOfErrorLogs.add(errLogForEmail); 
                    }
                    else if(string.isNotBlank(templateId) && string.isNotBlank(subject)){
                        if(idPrefix == '001' && String.isBlank(email) ){
                           // Error_Logs__c errorLogs = new Error_Logs__c(Message__c = inwiseConstants.EMAIL_Error_MSG_FOR_Acc,Run_By__c = UserInfo.getUserId(),
                                                                      //  Run_On__c = datetime.now(),Class_Name__c = 'TransactionalHealper',Method_Name__c = 'Send');
                           // listOfErrorLogs.add(errorLogs);
                        }
                        else{
                            //sendEmailFuture(templateId, fromEmail, saveTask, saveMessagingHistory, accountId,toname,subject,fromName,tagsLi,email,replyTo,recordId);
                        }
                        
                    }
                    else if (string.isBlank(subject)){
                        Error_Logs__c errLogForSub = new Error_Logs__c(Message__c = 'Subject is mandatory please provide.',Run_By__c = UserInfo.getUserId(),
                                                                        Run_On__c = datetime.now(),Class_Name__c = 'TransactionalHealper',Method_Name__c = 'Send');
                            listOfErrorLogs.add(errLogForSub);
                    }
                 }
                
                if(String.isNotBlank(smsText) && String.isNotBlank(mobileNumber)){
                   
                    //if(smsText.length() <= 600){
                   // sendSMSFuture(smsText, mobileNumber, recordId, saveTask, saveMessagingHistory, fromNumber, accountId);
                    // }
                    // else{
                    //     listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(smsText, 'SMS', 'send'));
                    // }
                }
                
            }catch(Exception ex){
                
               // listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'TransactionalHealper', 'send'));
                
                
            }
            if(!listOfErrorLogs.isEmpty()){
                //insert listOfErrorLogs;
            }
        }
    }
    
    @future(callout=true)
    static void sendSMSFuture(String smsText, String mobileNumber, String recordId, Boolean saveTask, Boolean saveMessagingHistory, String fromNumber, String accountId) {
        
       // String msg = inwiseSendSMSLtngController.SendSMSAndCreateActivity(smsText, mobileNumber, recordId, saveTask, saveMessagingHistory, fromNumber, accountId);
    }
    @future(callout=true)
    static void sendEmailFuture(String templateId,String fromEmail, Boolean saveTask, Boolean saveMessagingHistory, String accountId
                                , String toName, String subject, String fromName, String tagsLi,String email, String replyTo ,String recordId) {
                                    
                                   // String msg = inwiseSendSMSLtngController.sendEmailAndCreateActivity(templateId,fromEmail, saveTask, saveMessagingHistory, accountId,toname,subject,fromName,tagsLi,email,replyTo,recordId);
                                }
}