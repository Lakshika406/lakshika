/******************************************************************************************
*Created By: Nlineaxis
*Created On: Feb 20 2023
*Purpose :     

Modification Log
--------------------
Date            Version     Developer                  Comments
------------------------------------------------------------------------------------
02/20/2023      1.0.0       NLINEAXIS                   Created


/******************************************************************************************/
global with Sharing class SMS{
    
    @InvocableMethod(label='Send' description='Method to use send sms')
    global static void send(List<String> listOfJSONString) {                
        system.debug('=listOfJSONString='+listOfJSONString.size());
        system.debug('=listOfJSONString DATA ='+listOfJSONString);
        list<SMSWrapper> SMSWrapperList = new list<SMSWrapper>();
        if(!listOfJSONString.isEmpty()){
            if(listOfJSONString.size() ==1){
                List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
                try{
                    system.debug('=listOfJSONString11='+listOfJSONString[0]);
                    Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(listOfJSONString[0]);
                    system.debug('=dataMap='+dataMap);
                    String fromNumber = '';
                    String smsText = '';
                    String recordId= '';
                    String accountId = '';
                    String mobileNumber = '';
                    Boolean saveTask = false;
                    Boolean saveMessagingHistory = false;
                    for(String key : datamap.keySet()){
                        system.debug('=key===12='+key);
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
                        else if(key.equalsIgnoreCase('smsText')){
                            smsText = (String)dataMap.get(key);
                        }
                        else if(key.equalsIgnoreCase('mobileNumber')){
                            mobileNumber = (String)dataMap.get(key);
                        }
                        else if(key.equalsIgnoreCase('from')){
                            fromNumber = (String)dataMap.get(key);
                        }
                    }
                    if(String.isBlank(accountId)){
                        accountId = [Select Id FROM Account__c WHERE Default__c = :true WITH SECURITY_ENFORCED].Id;
                    }    
                    String idPrefix = String.isNotBlank(recordId) ? recordId.substring(0,3) : '';
                    if(String.isBlank(mobileNumber)){
                        if(idPrefix == '003'){
                            mobileNumber = [Select MobilePhone FROM Contact Where Id =:recordId WITH SECURITY_ENFORCED].MobilePhone;
                        }
                        else if(idPrefix == '00Q'){
                            mobileNumber = [Select MobilePhone FROM Lead Where Id =:recordId WITH SECURITY_ENFORCED].MobilePhone;
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
                    if(String.isNotBlank(smsText) && String.isNotBlank(mobileNumber)){
                        system.debug('=smsText.length()='+smsText.length());
                        //if(smsText.length() <= 600){
                        sendSMSFuture(smsText, mobileNumber, recordId, saveTask, saveMessagingHistory, fromNumber, accountId);
                        // }
                        // else{
                        //     listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(smsText, 'SMS', 'send'));
                        // }
                    }
                }catch(Exception ex){
                    system.debug('==error record==='+ex.getMessage());
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'SMS', 'send'));
                }
                if(!listOfErrorLogs.isEmpty()){
                    insert listOfErrorLogs;
                }
            }
            else{
                SMSFuture(listOfJSONString);
            }
        }
        
    }
    
    @future(callout=true)
    public static void sendSMSFuture(String smsText, String mobileNumber, String recordId, Boolean saveTask, Boolean saveMessagingHistory, String fromNumber, String accountId) {                     
        String msg = inwiseSendSMSLtngController.SendSMSAndCreateActivity(smsText, mobileNumber, recordId, saveTask, saveMessagingHistory, fromNumber, accountId);
    }
    
    @future(callout=true)
    public static void sendSMSFuture1(String wrapperSMSList/*String smsText, String mobileNumber, String recordId, Boolean saveTask, Boolean saveMessagingHistory, String fromNumber, String accountId*/) {
        system.debug('sendSMSFuture1 is ==>'+wrapperSMSList);
        inwiseSendSMSLtngController.SendSMSAndCreateActivity1(wrapperSMSList);
    }
    
    
    public static void SMSFuture(List<String> listOfJSONString){
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
            SMSQueueable smsQueue = new SMSQueueable(contactList);
            ID jobId = System.enqueueJob(smsQueue);
            System.debug('jobId===='+jobId);
            
        }
        
    }
}