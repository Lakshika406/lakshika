global with sharing class WhatsApp {
    @InvocableMethod(label='Send' description='Method to use send WhatsApp')
    global static void send(List<String> listOfJSONString) { 
        System.debug('==='+listOfJSONString.size());
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        if(!listOfJSONString.isEmpty()){
            System.debug('=2=='+listOfJSONString.size());
            if(listOfJSONString.size() ==1){
                System.debug('=3=='+listOfJSONString.size());
                try{
                    System.debug('=4=='+listOfJSONString[0]);
                    System.debug('=444=='+listOfJSONString);
                    String jsonString = listOfJSONString[0];
                    Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
                    System.debug('=dataMap=='+dataMap);
                    String recordId = '';	
                    String content = '';
                    String templateId = '';	
                    String mobileNumber = '';	
                    boolean saveMessagingHistory =false;
                    boolean saveTask = false;
                    String tagsLi = '';
                    String accountId = '';
                    String media_url = '';	
                    boolean async = false;
                    //String templateFieldsMapping = '';
                    String templateFieldsMapping = '[';
                    
                    for(String key : datamap.keySet()){
                        System.debug('=key=='+key);
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
                        else if(key.equalsIgnoreCase('content')){
                            content = (String)dataMap.get(key);
                        }
                        else if(key.equalsIgnoreCase('mobileNumber')){
                            mobileNumber = (String)dataMap.get(key);
                        }
                        else if(key.equalsIgnoreCase('media_url')){
                            media_url = (String)dataMap.get(key);
                        }
                        else if(key.equalsIgnoreCase('async')){
                            async = (Boolean)dataMap.get(key);
                        }
                        else if(key.equalsIgnoreCase('template_fields_mapping')){
                            //templateFieldsMapping = (String)dataMap.get(key);
                            
                            List<Object> templateFieldsMappingList = (List<Object>) dataMap.get(key);
                            System.debug('=templateFieldsMappingList=='+templateFieldsMappingList);
                            if (templateFieldsMappingList != null) {
                                //Integer i = 0;
                                //for (Object mapping : templateFieldsMappingList) {
                                for (Integer i = 0; i < templateFieldsMappingList.size(); i++) {
                                    Object mapping = templateFieldsMappingList[i];
                                    Map<String, Object> mappingEntry = (Map<String, Object>) mapping;
                                    if (mappingEntry.containsKey('key') && mappingEntry.containsKey('value')) {
                                        System.debug('Key: ' + mappingEntry.get('key') + ', Value: ' + mappingEntry.get('value'));
                                        //{key: 1,value: "#field3#"},{key: 2,value: "#field5#"}
                                        String key1 = String.valueOf(mappingEntry.get('key'));
                                        String value = String.valueOf(mappingEntry.get('value'));
                                        System.debug('key=='+key1);
                                        System.debug('value=='+value);
                                        
                                        // Append to templateFieldsMapping string
                                        templateFieldsMapping += '{key: ' + key1 + ',value: "' + value + '"}'; // (String.isEmpty(templateFieldsMapping) ? '' : ',')  + 
                                        //templateFieldsMapping = '{}'
                                        // Add a comma if it's not the last element
                                        if (i < templateFieldsMappingList.size() - 1) {
                                            templateFieldsMapping += ',';
                                        }
                                        //i++;
                                    }
                                    
                                }
                            }
                            templateFieldsMapping += ']'; // Close the JSON-like string
                            System.debug('templateFieldsMapping=='+templateFieldsMapping);
                        }
                        else if(key.equalsIgnoreCase('template_id')){
                            templateId = (String)dataMap.get(key);
                        }
                        else if(key.equalsIgnoreCase('tags')){
                            tagsLi = (String)dataMap.get(key);
                        }
                    }
                    String idPrefix = String.isNotBlank(recordId) ? recordId.substring(0,3) : '';
                    if(String.isBlank(accountId)){
                        accountId = [Select Id FROM Account__c WHERE Default__c = :true WITH SECURITY_ENFORCED].Id;
                    }
                    if(String.isBlank(mobileNumber)){
                        if(idPrefix == '003'){
                            mobileNumber = [Select MobilePhone FROM Contact Where Id =:recordId WITH SECURITY_ENFORCED].MobilePhone;
                        }
                        else if(idPrefix == '00Q'){
                            mobileNumber = [Select MobilePhone FROM Lead Where Id =:recordId WITH SECURITY_ENFORCED].MobilePhone;
                        }
                        else if(idPrefix == '001'){
                            mobileNumber = [Select Phone FROM Account Where Id =:recordId WITH SECURITY_ENFORCED].Phone;
                        }
                    }
                    if(String.isBlank(mobileNumber)  ){
                        Error_Logs__c errLogForWhatsApp = new Error_Logs__c(Run_By__c = UserInfo.getUserId(), Run_On__c = datetime.now(),Class_Name__c = 'InwiseTransactionalWhatsApp',Method_Name__c = 'Send');                       
                        errLogForWhatsApp.Message__c =  String.isBlank(recordId) ? 'Please add any one value MobileNumber or recordId.' :'MobileNumber is mandatory please provide.';
                        listOfErrorLogs.add(errLogForWhatsApp); 
                    }
                    else if(String.isBlank(content) && String.isBlank(templateId)){
                        Error_Logs__c errLogForWhatsApp = new Error_Logs__c(Run_By__c = UserInfo.getUserId(), Run_On__c = datetime.now(),Class_Name__c = 'InwiseTransactionalWhatsApp',Method_Name__c = 'Send');                       
                        errLogForWhatsApp.Message__c = 'User have to send at least one of these two fields: “content”, “template_id”';
                        listOfErrorLogs.add(errLogForWhatsApp); 
                    }
                    
                    else{
                        System.debug('=future==');
                        sendWhatsAppFuture(templateId,content,saveTask,saveMessagingHistory,accountId,mobileNumber,media_url,async,templateFieldsMapping,recordId,tagsLi);
                    }
                    
                }
                catch(Exception e){
                    system.debug('====ex=='+e.getMessage());
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(e.getMessage(), 'WhatsApp', 'send'));
                }

                if(!listOfErrorLogs.isEmpty()){
                    System.debug('=listOfErrorLogs=='+listOfErrorLogs);
                    insert listOfErrorLogs;
                }
                
            }
            
            else{
                whatappFuture(listOfJSONString);
            }
        }
        
    }
    @future(callout=true)
    static void sendWhatsAppFuture(String templateId,String content, Boolean saveTask, Boolean saveMessagingHistory, String accountId
                                   , String mobileNumber, String media_url, Boolean async, String templateFieldsMapping,String recordId,String tagsLi ) {
                                       
                                       String msg = inwiseSendSMSLtngController.sendWhatsAppAndCreateActivity(templateId,content, saveTask, saveMessagingHistory, accountId,mobileNumber,templateFieldsMapping,media_url,tagsLi,async,recordId);
                                   }
    
    @future(callout=true)
    public static void sendWhatsAppFuture(String wrapperEmailList ) {
        String msg = inwiseSendSMSLtngController.sendBulkWhatsAppAndCreateActivity(wrapperEmailList);
    }
    
    public static void whatappFuture(List<String> listOfJSONString){
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
            WhatsappQueueable whatappQueue = new WhatsappQueueable(contactList);
            ID jobId = System.enqueueJob(whatappQueue);
            System.debug('jobId===='+jobId);
            
        }
        
    }
}