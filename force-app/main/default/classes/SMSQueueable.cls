public with sharing class SMSQueueable implements Queueable {
    public List<String> listOfJSONString ; 
    public SMSQueueable(List<String> contList){
        this.listOfJSONString = contList ;  
    }
    public void execute(QueueableContext context) {
        
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        List<SMSWrapper> SMSWrapperList = new List<SMSWrapper>();
        
        for(Integer i=0;i<listOfJSONString.size();i++){
       
            try{
                system.debug('=listOfJSONString11='+listOfJSONString[i]);
                //SMSWrapper Wrapper = new SMSWrapper();
                Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(listOfJSONString[i]);
                system.debug('=dataMap='+dataMap);
                String fromNumber='';
                String smsText ='';
                String recordId ='';
                String accountId ='';
                String mobileNumber ='';
                Boolean saveTask = false;
                Boolean saveMessagingHistory = false;
                for(String key : datamap.keySet()){
                    system.debug('=key='+key);
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
                System.debug('mobileNumber=='+mobileNumber);
                System.debug('smsText=='+smsText);
                System.debug('smsText=='+recordId);
                if(String.isNotBlank(smsText) && String.isNotBlank(mobileNumber)){
                    system.debug('=smsText.length()='+smsText.length());
                    //if(smsText.length() <= 600){
                    SMSWrapperList.add(new SMSWrapper(smsText, mobileNumber, recordId, saveTask, saveMessagingHistory, fromNumber, accountId, null, null));
                    system.debug('SMSWrapperList is ==>'+SMSWrapperList);
                    // SMS.sendSMSFuture(smsText, mobileNumber, recordId, saveTask, saveMessagingHistory, fromNumber, accountId);
                    // }
                    // else{
                    //     listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(smsText, 'SMS', 'send'));
                    // }
                }
            }catch(Exception ex){
                system.debug('==error record==='+ex.getMessage());
                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'SMS', 'send'));
            }           
        }
        system.debug('before if JSON SMSWrapperList is ==>'+JSON.serialize(SMSWrapperList));
        if(SMSWrapperList != null){  
           system.debug('JSON SMSWrapperList is ==>'+JSON.serialize(SMSWrapperList));
           SMS.sendSMSFuture1(JSON.serialize(SMSWrapperList));
        }
        if(listOfErrorLogs.size()>0){
            insert listOfErrorLogs;
        }
    }
}