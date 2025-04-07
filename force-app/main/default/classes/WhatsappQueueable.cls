public with sharing class WhatsappQueueable implements Queueable {
    public List<String> listOfJSONString ; 
    public WhatsappQueueable(List<String> contList) {
        this.listOfJSONString = contList ;  
    }
    public void execute(QueueableContext context) {
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        List<WhatsappWrapper> whatsappWrapperList = new List<WhatsappWrapper>();
        try{
            for(Integer i=0;i<listOfJSONString.size();i++){
                system.debug('=listOfJSONString11='+listOfJSONString[i]);
                Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(listOfJSONString[i]);
                
                String recordId = '';	
                String content = '';
                String templateId = '';	
                String mobileNumber = '';	
                boolean saveMessagingHistory =false;
                boolean saveTask = false;
                String tags = '';
                String accountId = '';
                String media_url = '';	
                boolean async = false;
                //String templateFieldsMapping = '';
                String templateFieldsMapping = '[';
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
                            for (Integer temFieldMappingCount = 0; temFieldMappingCount < templateFieldsMappingList.size(); temFieldMappingCount++) {
                                Object mapping = templateFieldsMappingList[temFieldMappingCount];
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
                                    if (temFieldMappingCount < templateFieldsMappingList.size() - 1) {
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
                        tags = (String)dataMap.get(key);
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
                    // String templateId, String content,Boolean saveTask, Boolean saveMessagingHistory,String accountId,String mobileNumber, String media_url, 
                    //                 Boolean async, String templateFieldsMapping,String recordId,String tagsLi,Map<String,String> responseMap,Error_Logs__c errorLogs
                    whatsappWrapperList.add(new WhatsappWrapper(templateId,content,saveTask,saveMessagingHistory,accountId,mobileNumber,media_url,async,templateFieldsMapping,recordId,tags,null,null));
                }
                
                
            }
            system.debug('before if JSON whatsappWrapperList is ==>'+JSON.serialize(whatsappWrapperList));
            if(whatsappWrapperList != null){  
                system.debug('JSON whatsappWrapperList is ==>'+JSON.serialize(whatsappWrapperList));
                WhatsApp.sendWhatsAppFuture(JSON.serialize(whatsappWrapperList));
            }
        }
        catch(Exception e){
            system.debug('=error='+e.getMessage());
            //system.debug('=error='+e.getStackTraceString());
            listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(e.getMessage(), 'Email', 'send'));
        }

        if(!listOfErrorLogs.isEmpty()){
            System.debug('=listOfErrorLogs=='+listOfErrorLogs);
            insert listOfErrorLogs;
        }
    }
}