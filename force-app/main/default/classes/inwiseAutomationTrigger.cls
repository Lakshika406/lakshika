/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 19 April 2019
*Purpose :  This class used for automation purpose(sync data at inwis). when changes in contact and lead record. 
            we passed a json from process builder. example like as
            '[{"RecordID":"'+reference of contact and Lead Id +'","trigger_identifier":"'+"12345"+'"}]'
*Modified:   
================================================================
Modified On     Version     Modified By                Purpose  
================================================================
27/09/2022      1.0.0       NLINEAXIS(S.Vaishnav)      Modified:- Added inwiseAccount value in the json string
* 06/20/2024    1.1.1       NLINEAXIS(Kapil Goutam)    Modified:- Added changes for security check (added with sharing)

/******************************************************************************************/
global with sharing class inwiseAutomationTrigger {
    
    @InvocableMethod
    global static void inwiseAutomation(List<String> trigger_identifier) {
        System.debug('==trigger_identifier='+trigger_identifier);
        System.debug('==trigger_identifier=size='+trigger_identifier.size());
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        if(!trigger_identifier.isEmpty()){
            if(trigger_identifier.size() == 1){
                try{
                    List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(trigger_identifier.get(0));
                    Map<String, Object> data = (Map<String, Object>)fieldList.get(0);

                    String recordId = (String)data.get('RecordID');
                    String triggeridentifier = (String)data.get('trigger_identifier');
                    String accountId = data.containsKey('inwiseAccount') ? (String)data.get('inwiseAccount') : '';
                    calloutmethod(triggeridentifier, recordId, accountId);
                } catch(Exception e){
                    system.debug('====ex=='+e.getMessage());
                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(e.getMessage(), 'inwiseAutomationTrigger', 'inwiseAutomation'));
                }
            } else {
                for(Integer i=0;i<trigger_identifier.size();i++){
                    try{
                        List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(trigger_identifier.get(i));
                        Map<String, Object> data = (Map<String, Object>)fieldList.get(0);
        
                        String recordId = (String)data.get('RecordID');
                        String triggeridentifier = (String)data.get('trigger_identifier');
                        String accountId = data.containsKey('inwiseAccount') ? (String)data.get('inwiseAccount') : '';
                        calloutmethod(triggeridentifier, recordId, accountId);
                    } catch(Exception e){
                        system.debug('====ex=='+e.getMessage());
                        listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(e.getMessage(), 'inwiseAutomationTrigger', 'inwiseAutomation'));
                    }
                }
            }

            if(!listOfErrorLogs.isEmpty()){
                System.debug('=listOfErrorLogs=='+listOfErrorLogs);
                insert listOfErrorLogs;
            }
        }
    }
    
    
    @future(callout=true)
    public static void calloutmethod(String trigger_identifier, String recordId, String accountId){

        Account__c acc = null;
        List<Logs__c> listOfLogs = new List<Logs__c>();

        if(String.isNotBlank(accountId)){
            if (Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Id.isAccessible()) {

                acc = [Select Id From Account__c Where Id =: accountId];
            }
        }

        HttpRequest req;
        HttpResponse res;
        InwiseUtil objInwiseUtil = new InwiseUtil(acc);
        
        try{
            //System.debug('contactId' + objInwiseUtil.objInwiseAccount.Token__c); 
            Http http = new Http();
            String endpoint = objInwiseUtil.apiUrl + ('/rest/v1/automations/customTrigger'); 
            req = objInwiseUtil.GetHTTPRequest('POST', 'application/json', endpoint);
            req.setBody(getJSONBody(trigger_identifier, recordId, acc));
            req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken);

            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, ('/rest/v1/automations/customTrigger'), 'inwiseAutomationTrigger', 'inwiseAutomation'));      
            }else{
                String resBody = '{"identifier": "' + trigger_identifier + '","contact_data": {"fields": [{ "name": "1", "content": "Kapil" },{ "name": "2", "content": "Male" }],"email": "the contact/lead email address","mobile_number": "the contact/lead mobile address","confirmed": true,"external_id": "0030o00002lDNg0"}}';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
        }catch(Exception ex){
            String resBody = ex.getMessage();
            res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, ('/rest/v1/automations/customTrigger'), 'inwiseAutomationTrigger', 'inwiseAutomation'));      
            System.debug('ex.getMessage()'+ex.getMessage());
        }

        System.debug('size list of logs::-->>' + listOfLogs.size());
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        } 
    }
    
    public static String getJSONBody(String trigger_identifier, String recordId, Account__c acc){
        
        AggregateResult[] objInwiseFields;
        List<Mapping__c> listOfInwiseMapping;
        String soqlContact = '', soqlLead = '';
              
        Set<Id> setOfLeadMember = new Set<Id>();
        Set<Id> setOfContactMember = new Set<Id>();

        List<Lead> listOfLead = new List<Lead>();
        List<Contact> listOfContact = new List<Contact>();

        Set<String> setOfLeadFields = new Set<String>();
        Set<String> setOfContactFields = new Set<String>();
        Map<String, Mapping__c> mapInwiseMapping = new Map<String, Mapping__c>();

        InwiseUtil objInwiseUtil = new InwiseUtil(acc);
        
        if(objInwiseUtil.objInwiseAccount != NULL){

            if (Schema.sObjectType.Mapping__c.isAccessible() && 
                Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.inwise_Field__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.inwise_FieldId__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Object_Type__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isAccessible()) {

                listOfInwiseMapping = [SELECT Id,Name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c FROM Mapping__c WHERE Account__c =: objInwiseUtil.objInwiseAccount.Id];
            }

            objInwiseFields = [SELECT inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c FROM Mapping__c WHERE Account__c =: objInwiseUtil.objInwiseAccount.Id group by inwise_FieldId__c,inwise_Field__c];
            
            if(!listOfInwiseMapping.isEmpty()){
                System.debug('listOfInwiseMapping::-->>>' + listOfInwiseMapping.size());
                for(Mapping__c oMapping : listOfInwiseMapping){
                    String key = oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
                    mapInwiseMapping.put(key, oMapping);
                }  
            }
        }
        
        if(!listOfInwiseMapping.isEmpty()){
            for(Mapping__c im : listOfInwiseMapping){
                if(im.Salesforce_Field__c != null && im.Salesforce_Field__c != ''){
                    if(im.Object_Type__c == InwiseConstants.SOBJECT_CONTACT){
                        setOfContactFields.add(im.Salesforce_Field__c);
                    }else if(im.Object_Type__c == InwiseConstants.SOBJECT_LEAD){
                        setOfLeadFields.add(im.Salesforce_Field__c);
                    }
                }                      
            }  
        }
        
        //add email & phone to pass these in json by default
        setOfContactFields.add('Email');
        setOfContactFields.add('MobilePhone');
        setOfLeadFields.add('Email');
        setOfLeadFields.add('MobilePhone');
        soqlContact = getSOQLFromSet(setOfContactFields, InwiseConstants.SOBJECT_CONTACT);
        soqlLead = getSOQLFromSet(setOfLeadFields, InwiseConstants.SOBJECT_LEAD);
        String objectName = findObjectNameFromRecordIdPrefix(recordId);
        
        if(objectName == InwiseConstants.SOBJECT_CONTACT){
            listOfContact = Database.query(soqlContact + ' WHERE Id =: recordId Limit 1');
        }
        
        if(objectName == InwiseConstants.SOBJECT_LEAD){
            listOfLead = Database.query(soqlLead + ' WHERE  Id =: recordId Limit 1');
        }
        
        String jsonString = '{';
        jsonString += '"identifier": "' + trigger_identifier + '","contact_data": ';
        
        if(!listOfContact.isEmpty()){
            
            for(Contact oContact : listOfContact){
                jsonString += jsonForRecord(oContact, InwiseConstants.SOBJECT_CONTACT, listOfInwiseMapping, objInwiseFields, mapInwiseMapping, objInwiseUtil);
            }
            jsonString = jsonString.substring(0, jsonString.length()-1);
            jsonString += ',"email": "'+listOfContact.get(0).Email;
            jsonString += '","mobile_number": "' + inwiseHttpUtil.getFormattedPhone(listOfContact.get(0).MobilePhone, objInwiseUtil);
            jsonString += ' ","confirmed": true,"external_id": "' + recordId + '"}}';
            System.debug('jsonString MOBILE listOfContact::-->>>' + jsonString);
        }
        
        if(!listOfLead.isEmpty()){
            for(Lead oLead:listOfLead){
                jsonString += jsonForRecord(oLead, InwiseConstants.SOBJECT_LEAD, listOfInwiseMapping, objInwiseFields, mapInwiseMapping, objInwiseUtil);
            }
            System.debug('jsonString MOBILE listOfLead::-->>>' + jsonString);
            jsonString = jsonString.substring(0, jsonString.length()-1);
            jsonString += ',"email": "' + listOfLead.get(0).Email;
            jsonString += '","mobile_number": "' + inwiseHttpUtil.getFormattedPhone(listOfLead.get(0).MobilePhone, objInwiseUtil);
            jsonString += ' ","confirmed": true,"external_id": "' + recordId + '"}}';
        }
        
        System.debug('final Json::-->>>' + jsonString);
        return jsonString;
    }

    public static String jsonForRecord(SObject obj, String sObjectType, List<Mapping__c> listOfInwiseMapping, AggregateResult[] objInwiseFields, Map<String, Mapping__c> mapInwiseMapping, InwiseUtil objInwiseUtil){
        
        String key,val;
        Mapping__c inw;
        String email, mobile;
        Boolean isNeedToRemoveExtraComma = false;
        String jsonString = '{"fields": [';
        
        for(AggregateResult ar : objInwiseFields){
            key = ar.get('inwise_FieldId__c') + ':' + sObjectType;
            val = '';
            inw = mapInwiseMapping.get(key);

            if(inw != NULL && inw.Salesforce_Field__c !=null){
                val = (obj.get(inw.Salesforce_Field__c) != NULL ? string.valueof(obj.get(inw.Salesforce_Field__c)) : '');
                if(!String.isEmpty(val)){
                    val = val.escapeEcmaScript();
                }
                if(!isNeedToRemoveExtraComma){
                    isNeedToRemoveExtraComma = true;    
                }
                
                jsonString += ' { ';
                jsonString += ' "name": "' +inw.inwise_FieldId__c + '",';
                jsonString += ' "content": "' + val  +'" ';
                jsonString += ' },';
            }
        }

        if(isNeedToRemoveExtraComma){
            jsonString = jsonString.substring(0, jsonString.length()-1);
            System.debug('jsonString after split::-->>>' + jsonString);
        }           
        jsonString += '],';
        
        return jsonString;  
    }

    // public static String getSOQLFromSet(Set<String> setOfFields, String objectname){
    //     String soql = 'SELECT ';
    //     if(!setOfFields.isEmpty()){
    //         Integer sz = 0;
    //         for(String s : setOfFields){
    //             soql += s + (setOfFields.Size()-1 == sz ? ' ' : ',');
    //             sz++;
    //         }
    //         soql += ' FROM ' + objectname;
    //     }
    //     return soql; 
    // }

    public static String getSOQLFromSet(Set<String> setOfFields, String objectName) {
        String soql = '';
        if (!setOfFields.isEmpty()) {
            // Check if the object is accessible
            if (!Schema.getGlobalDescribe().containsKey(objectName)) {
                System.debug('Object does not exist: ' + objectName);
                return '';
            }
            
            Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
            if (!objDescribe.isAccessible()) {
                System.debug('User does not have access to the object: ' + objectName);
                return '';
            }

            // Validate each field in the set for accessibility
            List<String> accessibleFields = new List<String>();
            for (String field : setOfFields) {
                if (objDescribe.fields.getMap().containsKey(field)) {
                    if (objDescribe.fields.getMap().get(field).getDescribe().isAccessible()) {
                        accessibleFields.add(field);
                    } else {
                        System.debug('User does not have access to the field: ' + field);
                    }
                } else {
                    System.debug('Field does not exist on object: ' + field);
                }
            }

            // Build the SOQL query if there are accessible fields
            if (!accessibleFields.isEmpty()) {
                soql = 'SELECT ' + String.join(accessibleFields, ',') + ' FROM ' + objectName;
            } else {
                System.debug('No accessible fields available for object: ' + objectName);
            }
        }
        return soql;
    }

    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
}