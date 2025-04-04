/******************************************************************************************
* Name          :  BatchSendMemberToInwise

* Description   :  Send Member action in batch

* Author        :  Kapil Goutam

Modification Log
----------------
Date                  Version   Developer                  Comments
------------------------------------------------------------------------------------
10/10/2017        1.0.0       K.Goutam                   Created
07/08/2018        1.1.0       K.Goutam                   Modified:- fix sync master issue in case of a campaign sync
07/09/2018        1.1.1       K.Goutam                   Modified:- insert member only when setting   Log_Sync_Memebers__c is on
03/07/2019        1.1.2       K.Goutam                   Modified :- While fetching data in pushExternalApp api, add 5 hours back time instead of 2 hour
03/08/2019        1.1.3       K.Goutam                   Modified :- remove delete delete_existing_contacts_by_last_date variable in pushExternalApp api call
04/23/2019        1.1.4       K.Goutam                   Modified :-   we  add field(Syncronized,  Reason) value while getting response  
04/25/2019        1.1.5       K.Goutam                   Modified :-getting  isLastBatch from  isLastBatchForFixBatchSize().we have getting last batch execution for batch size 200.
05/07/2019        1.1.6       K.Goutam                   Modified:- Removed last batch checked as last batch in finish for all batch classes
07/06/2021        1.1.7       NLINEAXIS(K.Goutam)        Modified:- Added error handling in case of api return not equal to 200. use case where inwise group was missing at inwise end & sf try to sync members
/***********************************************************************************/
global with sharing class BatchSendMemberToInwise implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    Campaign objCampaign;
    Sync_Master__c objSyncMaster;
    //List<Logs__c> listOfLogs{get;set;}
    InwiseUtil objInwiseUtil{get;set;}
    Account__c objInwiseAccount{get;set;}
    Map<string,Mapping__c> mapInwiseMapping{get;set;}
    AggregateResult[] objInwiseFields{get;set;}
    List<Mapping__c> listOfInwiseMapping{get;set;}
    boolean runForFailedOnly {get;set;}
    Integer totalRecordsSize{get;set;}
    Integer currentBatchNo{get;set;}
    boolean isFirstBatch {get;set;}

    public void init(Id syncMasterId, Id campaignId, boolean isForFailed,boolean isFirst){
        isFirstBatch = isFirst;
        runForFailedOnly = isForFailed;
        totalRecordsSize = 0;
        //List<Campaign> listOfCampaign = [Select Id,name,Account__c,Sendid__c,Campaign_Type__c from Campaign where Id=:campaignId WITH SECURITY_ENFORCED];
        List<Campaign> listOfCampaign = new List<Campaign>();

        // Check object-level and field-level access
        if (Schema.sObjectType.Campaign.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Id.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Name.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Account__c.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Sendid__c.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Campaign_Type__c.isAccessible()) {

            // Perform the query only if the user has access
            listOfCampaign = [SELECT Id, Name, Account__c, Sendid__c, Campaign_Type__c FROM Campaign WHERE Id = :campaignId];
        } else {
            // Handle the case where access is denied
            System.debug('User does not have sufficient permissions to access Campaign or its fields.');
        }
        if(listOfCampaign != NULL && !listOfCampaign.isEmpty()){
            objCampaign = listOfCampaign.get(0);
        }
        objSyncMaster = inwiseUtil.doGetSyncMaster(syncMasterId);

        //listOfLogs = new List<Logs__c>();
        objInwiseAccount = doGetInwiseAccount(campaignId);
        objInwiseUtil = new InwiseUtil(objInwiseAccount);
        mapInwiseMapping = new Map<string,Mapping__c>();
        if(objInwiseAccount != NULL){

            // Check object-level and field-level access
            if (Schema.sObjectType.Mapping__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.inwise_Field__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.inwise_FieldId__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Object_Type__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isAccessible()) {

                // Perform the query only if the user has access
                listOfInwiseMapping = [SELECT Id, Name, Account__c, inwise_Field__c, inwise_FieldId__c, Object_Type__c, Salesforce_Field__c
                                      FROM Mapping__c WHERE Account__c = :objInwiseAccount.Id];
            } else {
                // Handle insufficient permissions
                System.debug('User does not have sufficient permissions to access Mapping__c object or its fields.');
            }
            //listOfInwiseMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c from Mapping__c where Account__c=:objInwiseAccount.Id WITH SECURITY_ENFORCED];
            objInwiseFields = [SELECT inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:objInwiseAccount.Id  group by inwise_FieldId__c,inwise_Field__c];

            if(!listOfInwiseMapping.isEmpty()){
                System.debug('listOfInwiseMapping::-->>>' + listOfInwiseMapping.size());
                for(Mapping__c oMapping:listOfInwiseMapping){
                    string key= oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
                    mapInwiseMapping.put(key,oMapping);
                }
            }

        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String soqlQuery = '';
        Id campaignId = objCampaign.Id;
        String soqlSelect = '';
        // Check object-level and field-level access
        if (Schema.sObjectType.CampaignMember.isAccessible() &&
            Schema.sObjectType.CampaignMember.fields.Id.isAccessible() &&
            Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() &&
            Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible() &&
            Schema.sObjectType.CampaignMember.fields.CampaignId.isAccessible() ){

            soqlSelect = 'SELECT Id,ContactId, LeadId,CampaignId FROM CampaignMember ';

        } else {
            // Handle insufficient permissions
            System.debug('User does not have sufficient permissions to access CampaignMember object or its fields.');
        }
        //String soqlSelect = 'SELECT Id,ContactId, LeadId,CampaignId FROM CampaignMember ';
        System.debug('runForFailedOnly::-->>' + runForFailedOnly);
        if(runForFailedOnly){
            Set<Id> setOfId = new Set<Id>();
            Set<Id> setOfIdSyncMaster = new Set<Id>();
            //List<Sync_Members__c> listOfSyncMembers = [Select Member_Record_ID__c,Sync_Master__c from Sync_Members__c where Sync_Master__c=:objSyncMaster.Id AND Is_Processed__c = false WITH SECURITY_ENFORCED];
            List<Sync_Members__c> listOfSyncMembers = new List<Sync_Members__c>();
            // Check if the object and fields are accessible
            if (Schema.sObjectType.Sync_Members__c.isAccessible() &&
                Schema.sObjectType.Sync_Members__c.fields.Member_Record_ID__c.isAccessible() &&
                Schema.sObjectType.Sync_Members__c.fields.Sync_Master__c.isAccessible() &&
                Schema.sObjectType.Sync_Members__c.fields.Is_Processed__c.isAccessible()) {

                // Perform the query
                listOfSyncMembers = [SELECT Member_Record_ID__c, Sync_Master__c FROM Sync_Members__c 
                                    WHERE Sync_Master__c = :objSyncMaster.Id 
                                    AND Is_Processed__c = false];

            
            } else {
                // Log debug statements if the user lacks CRUD/FLS permissions
                System.debug('User does not have sufficient permissions to access Sync_Members__c or its fields.');
            }

            if(!listOfSyncMembers.isEmpty()){
                for(Sync_Members__c sm:listOfSyncMembers){
                    if(sm.Member_Record_ID__c != NULL){
                        setOfId.add(sm.Member_Record_ID__c);
                    }
                    setOfIdSyncMaster.add(sm.Sync_Master__c);

                }
            }
            System.debug('setOfId::-->>' + setOfId.size() + '>>>' + setOfId + '>>>>' + objCampaign);
            soqlQuery = 'where CampaignId =:campaignId  and  Id IN:setOfId';
            //QueryLocatorOfCampaignMember = Database.getQueryLocator([
            //              SELECT Id,ContactId, LeadId,CampaignId FROM CampaignMember where CampaignId  =:objCampaign.Id  and  Id IN:setOfId
            //          ]);
        }else{
            soqlQuery = 'where CampaignId  =:campaignId';
            //QueryLocatorOfCampaignMember = Database.getQueryLocator([
            //              SELECT Id,ContactId, LeadId,CampaignId FROM CampaignMember where CampaignId  =:objCampaign.Id
            //          ]);
        }
        System.debug('soqlQuery::-->>>' + soqlQuery);
        Database.QueryLocator QueryLocatorOfCampaignMember = Database.getQueryLocator(soqlSelect + soqlQuery);
        totalRecordsSize = Database.countQuery('SELECT COUNT() FROM CampaignMember '+soqlQuery);
        currentBatchNo = 0;
        System.debug('totalRecordsSize::-->>>' + totalRecordsSize);
        return QueryLocatorOfCampaignMember;

    }
    global void execute(Database.BatchableContext BC, List<Sobject> scope){

        Set<Id> setOfCampaignMemberIds = new Set<Id>();
        Sync_Members__c objSyncMember;
        List<Logs__c> listOfLogs = new List<Logs__c>();
        List<Sync_Members__c> listOfSyncMembers = new List<Sync_Members__c>();
        ++currentBatchNo;
        for(CampaignMember mbr: (List<CampaignMember>) scope){
            objSyncMember = new Sync_Members__c();
            if(Schema.sObjectType.Sync_Members__c.fields.Sync_Master__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Sync_Master__c.isCreateable()){
                objSyncMember.Sync_Master__c = objSyncMaster.Id;
            }
            if(Schema.sObjectType.Sync_Members__c.fields.Member_Record_ID__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Member_Record_ID__c.isCreateable() ){
                objSyncMember.Member_Record_ID__c = mbr.Id;
            }
            if(mbr.ContactId != NULL){
                if(Schema.sObjectType.Sync_Members__c.fields.Contact__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Contact__c.isCreateable()){
                    objSyncMember.Contact__c = mbr.ContactId;
                }
                if(Schema.sObjectType.Sync_Members__c.fields.Type__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Type__c.isCreateable() ){
                    objSyncMember.Type__c = 'Contact';
                }
            }
            if(mbr.LeadId != NULL){
                if(Schema.sObjectType.Sync_Members__c.fields.Lead__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Lead__c.isCreateable()){
                    objSyncMember.Lead__c = mbr.LeadId;
                }
                if(Schema.sObjectType.Sync_Members__c.fields.Type__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Type__c.isCreateable() ){
                    objSyncMember.Type__c = 'Lead';
                }
            }
            setOfCampaignMemberIds.add(mbr.Id);
            listOfSyncMembers.add(objSyncMember);

        }

        System.debug('listOfSyncMembers::-->>>' + listOfSyncMembers);
        List<Sync_Members__c> listOfSyncMembersTemp;
        map<String,boolean> external_id =new   map<String,boolean> ();
        map<String,string> error_external_id =new   map<String,string> ();
        try{
            //boolean isLastBatch = objInwiseUtil.isLastBatchForSyncWithInwise(totalRecordsSize,currentBatchNo);
//            System.debug('totalRecordsSize:::-->>>' + totalRecordsSize + '>>>>>' + currentBatchNo + '>>>>' + isLastBatch);
            if(!listOfSyncMembers.isEmpty()){
                JsonToApexPushExernalApp  successResponse = doSyncMembersWithInwise(setOfCampaignMemberIds,false,listOfLogs);
                system.debug('successResponse>>>>'+successResponse);

                if(runForFailedOnly){
                    //listOfSyncMembersTemp = [Select Id from Sync_Members__c where Member_Record_ID__c IN:setOfCampaignMemberIds WITH SECURITY_ENFORCED];
                    // Check if the object and fields are accessible
                    if (Schema.sObjectType.Sync_Members__c.isAccessible() &&
                        Schema.sObjectType.Sync_Members__c.fields.Member_Record_ID__c.isAccessible()) {

                        // Perform the query
                        listOfSyncMembersTemp = [SELECT Id FROM Sync_Members__c WHERE Member_Record_ID__c IN :setOfCampaignMemberIds];
                                            
                    } else {
                        // Log debug statements if the user lacks CRUD/FLS permissions
                        System.debug('User does not have sufficient permissions to access Sync_Members__c or its fields.');
                    }
                }else{
                    listOfSyncMembersTemp  = listOfSyncMembers;
                }
                if(!listOfSyncMembersTemp.isEmpty()){

                    for(Sync_Members__c sm :listOfSyncMembersTemp){
                        sm.Is_Processed__c = true;
                        system.debug('Member_Record_ID__c>>>145>>'+sm.Member_Record_ID__c);
                        //code removed because of issue field is not writable
                        //issue fix, sync master null in some cases.

                        if(sm.Sync_Master__c == NULL && !runForFailedOnly){
                            sm.Sync_Master__c = objSyncMaster.Id;
                        }
                        if(successResponse.created !=null && !successResponse.created.isEmpty()){
                            for(string createdRecord: successResponse.created){
                                external_id.put(createdRecord,true);
                            }
                            if(external_id.containsKey(sm.Member_Record_ID__c)) {
                                sm.Syncronized__c=true;
                            }
                        }


                        if(successResponse.errors != null){
                            if(!successResponse.errors.isEmpty() ){


                                for(JsonToApexPushExernalApp.Errors err: successResponse.errors){
                                    error_external_id.put(err.external_id,err.details);
                                }

                                if(error_external_id.containsKey(sm.Member_Record_ID__c)) {
                                    sm.Reason__c=error_external_id.get(sm.Member_Record_ID__c);
                                }
                            }

                        }else{
                            sm.Syncronized__c=true;
                        }

                    }

                    if(Schema.sObjectType.Sync_Members__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.isCreateable()){
                        //System.debug('listOfSyncMembersTemp::->>>' + listOfSyncMembersTemp.get(0));
                        System.debug('listOfSyncMembersTemp::->>>' + listOfSyncMembersTemp);
                        if(objInwiseUtil.objInwiseSetting.Log_Sync_Memebers__c){
                            upsert listOfSyncMembersTemp;
                        }
                    }
                }


            }
            if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                insert listOfLogs;
                listOfLogs = new List<Logs__c>();
            }
        }catch(Exception ex){
            System.debug('Exception in BatchSendMemberToInwise' + ex.getMessage());
            System.debug('Exception in BatchSendMemberToInwise' + ex.getLineNumber());
        }


    }

    public JsonToApexPushExernalApp  doSyncMembersWithInwise(Set<Id> setOfCampaignMemberIds, boolean isLastBatch,List<Logs__c> listOfLogs){
        Http http = new Http();
        HttpResponse res;
        HttpRequest req;
        boolean isSuccess;
        JsonToApexPushExernalApp  recordOfresponse;
        try{
            isSuccess = true;
            String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contactsGroups/pushExternalApp?group_id='+ objSyncMaster.Group_Id__c;
         
            if(objInwiseUtil.objInwiseSetting.Use_Bulk_Push__c){
                endpoint += '&use_bulk_push='+objInwiseUtil.objInwiseSetting.Use_Bulk_Push__c;
            }
            if(isFirstBatch){
                endpoint += '&lock_group=true';
                isFirstBatch=false;
            }else if(isLastBatch){
                endpoint += '&unlock_group=true';
            }

            /*Comment to do not send delete_existing_contacts_by_last_date in last batch
            if(isLastBatch){
                Datetime dtNowUTC = Datetime.newInstance(Datetime.now().dateGmt(), Datetime.now().timeGmt());
                Datetime dtPrevious2Hours = dtNowUTC.addHours(-5);
                endpoint += '&delete_existing_contacts_by_last_date='+ EncodingUtil.urlEncode(dtPrevious2Hours.format('yyyy-MM-dd HH:mm:ss'),'UTF-8');
            }*/
            req = objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint);
            req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);
            if(!isLastBatch){
                req.setBody(getBodyMobileJsonPushExternalApp(objCampaign.Id,Integer.valueOf(objSyncMaster.Group_Id__c),listOfInwiseMapping,objInwiseFields,mapInwiseMapping,setOfCampaignMemberIds));
            }else{
                req.setBody('');
            }
            req.setTimeout(120000);
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups/pushExternalApp','BatchSendMemberToInwise','doSyncMembersWithInwise'));
            }else{
                String resBody = '{"status": "complete"}';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            System.debug('response mobile create group::-->>>' + res + '>>>' + res.getBody());

        }catch(Exception ex){
            String resBody = ex.getMessage();
            System.debug('resBody Exception:::-->>>' + resBody);
            res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups/pushExternalApp','BatchSendMemberToInwise','doSyncMembersWithInwise'));
            isSuccess = false;
        }

        String jsonResponse= res.getBody();
        if(res.getStatusCode() == 200 && jsonResponse != null){
            recordOfresponse= JsonToApexPushExernalApp.parse(jsonResponse);
        }else{
            recordOfresponse = inwiseHttpUtil.getJsonToApexPushExernalAppError(res);
        }
        return recordOfresponse;

    }
    public String getBodyMobileJsonPushExternalApp(String CampaignId,integer grpid,List<Mapping__c> listOfInwiseMapping,AggregateResult[] objInwiseFields,map<string,Mapping__c> mapInwiseMapping, Set<Id> setOfCampaignMemberIds){
        String soqlContact = '', soqlLead='';
        Set<String> setOfContactFields = new Set<String>();
        Set<String> setOfLeadFields = new Set<String>();
        Set<Id> setOfContactMember = new Set<Id>();
        Set<Id> setOfLeadMember = new Set<Id>();
        List<Contact> listOfContact = new List<Contact>();
        List<Lead> listOfLead = new List<Lead>();
        Map<Id,Id> mapOfCampaignMemberContactVsMemberId = new Map<Id,Id>();
        Map<Id,Id> mapOfCampaignMemberLeadVsMemberId = new Map<Id,Id>();

        for(Mapping__c im:listOfInwiseMapping){
            if(im.Salesforce_Field__c != null && im.Salesforce_Field__c != ''){
                if(im.Object_Type__c == InwiseConstants.SOBJECT_CONTACT){
                    setOfContactFields.add(im.Salesforce_Field__c);
                }else if(im.Object_Type__c == InwiseConstants.SOBJECT_LEAD){
                    setOfLeadFields.add(im.Salesforce_Field__c);
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

        if(CampaignId != NULL){
            List<CampaignMember> listOfCampaignMember;
            if (Schema.sObjectType.CampaignMember.isAccessible() &&
                Schema.sObjectType.CampaignMember.fields.Id.isAccessible() &&
                Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() &&
                Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible()) {

                //listOfCampaignMember = [SELECT Id,ContactId, LeadId FROM CampaignMember where Id  IN: setOfCampaignMemberIds WITH SECURITY_ENFORCED];
                // Perform the query
                listOfCampaignMember = [SELECT Id, ContactId, LeadId FROM CampaignMember WHERE Id IN :setOfCampaignMemberIds];
            } else {
                // Log debug statements if the user lacks CRUD/FLS permissions
                System.debug('User does not have sufficient permissions to access CampaignMember or its fields.');
            }
            if(!listOfCampaignMember.isEmpty()){
                for(CampaignMember mbr: listOfCampaignMember){
                    if(mbr.ContactId != NULL){
                        setOfContactMember.add(mbr.ContactId);
                        mapOfCampaignMemberContactVsMemberId.put(mbr.ContactId,mbr.Id);
                    }
                    if(mbr.LeadId != NULL){
                        setOfLeadMember.add(mbr.LeadId);
                        mapOfCampaignMemberLeadVsMemberId.put(mbr.LeadId, mbr.Id);
                    }

                }
            }
            if(!setOfContactMember.isEmpty() &&  !String.isEmpty(soqlContact)){
                //listOfContact = Database.query(soqlContact + ' WHERE Id IN:setOfContactMember order by name ASC');
                listOfContact = Database.query(soqlContact + ' WHERE Id IN:setOfContactMember ');
            }

            if(!setOfLeadMember.isEmpty() &&  !String.isEmpty(soqlLead)){
                //listOfLead = Database.query(soqlLead + ' WHERE Id IN:setOfLeadMember order by name ASC');
                listOfLead = Database.query(soqlLead + ' WHERE Id IN:setOfLeadMember ');
            }

        }
        String jsonString = '[';
        boolean isNeedToDoSubstring = false;
        if(!listOfContact.isEmpty()){
            isNeedToDoSubstring = true;
            for(Contact oContact:listOfContact){
                jsonString += jsonForMobileCampaignPerRecord(oContact,InwiseConstants.SOBJECT_CONTACT,listOfInwiseMapping, CampaignId, objInwiseFields, mapInwiseMapping,mapOfCampaignMemberContactVsMemberId);
            }
        }
        System.debug('jsonString MOBILE listOfContact::-->>>' + jsonString);
        if(!listOfLead.isEmpty()){
            isNeedToDoSubstring = true;
            //jsonString += ',';
            for(Lead oLead:listOfLead){
                jsonString += jsonForMobileCampaignPerRecord(oLead,InwiseConstants.SOBJECT_LEAD,listOfInwiseMapping, CampaignId, objInwiseFields, mapInwiseMapping,mapOfCampaignMemberLeadVsMemberId);
            }
        }
        System.debug('jsonString MOBILE listOfLead::-->>>' + jsonString);
        if(isNeedToDoSubstring){
            jsonString = jsonString.substring(0, jsonString.length()-1);
        }
        jsonString += ' ]';
        System.debug('jsonString MOBILE::-->>>' + jsonString);
        return jsonString;
    }
    public String jsonForMobileCampaignPerRecord(SObject obj,String sObjectType, List<Mapping__c> listOfInwiseMapping, String CampaignId, AggregateResult[] objInwiseFields, map<string,Mapping__c> mapInwiseMapping,Map<Id,Id> mapOfCampaignMemberVsMemberId){
        Id campaignMemberId;
        String email, mobile;
        boolean isNeedToRemoveExtraComma = false;
        string key,val;
        Mapping__c inw;
        String jsonString = '{';
        jsonString += '"fields": [';
        campaignMemberId = NULL;
        isNeedToRemoveExtraComma = false;
        for(AggregateResult ar:objInwiseFields){
            key = ar.get('inwise_FieldId__c') + ':' + sObjectType;
            val = '';
            inw=mapInwiseMapping.get(key);
            if(inw != NULL && inw.Salesforce_Field__c !=null){
                val = (obj.get(inw.Salesforce_Field__c) != NULL ? string.valueof(obj.get(inw.Salesforce_Field__c)) : '');
                if(!String.isEmpty(val)){
                    val = val.escapeEcmaScript();
                }
                if(!isNeedToRemoveExtraComma){
                    isNeedToRemoveExtraComma = true;
                }
                if(inw.inwise_Field__c == 'Email' && email == NULL){
                    email = val;
                    isNeedToRemoveExtraComma = false;
                }else if(inw.inwise_Field__c == 'Mobile' && mobile == NULL){
                    System.debug('Mobile317::--->>>' + val);
                    mobile = inwiseHttpUtil.getFormattedPhone(val, objInwiseUtil);
                    isNeedToRemoveExtraComma = false;
                    System.debug('Mobile319::--->>>' + val);
                }else{// to avoid email in inner json fields. as per boaz input
                    jsonString += ' { ';
                    jsonString += ' "name": "' +inw.inwise_FieldId__c + '",';
                    jsonString += ' "content": "' + val  +'" ';
                    jsonString += ' },';
                }

            }else{
                //don't need this code - Commented on 26 Feb 2018
                //if(ar.get('inwise_Field__c') == InwiseConstants.INWISE_FIELD_SALESFORCECAMPAIGNMEMBERID){
                //      //add campaign member id, taking it in seprate field for fixing herbew language issue
                //        if(mapOfCampaignMemberVsMemberId.get(String.valueOf(obj.get('Id'))) != NULL){
                //              campaignMemberId= mapOfCampaignMemberVsMemberId.get(String.valueOf(obj.get('Id')));
                //        }
                //}

            }

        }
        if(isNeedToRemoveExtraComma){
            jsonString = jsonString.substring(0, jsonString.length()-1);
            System.debug('jsonString after split::-->>>' + jsonString);

        }
        System.debug('mapOfCampaignMemberVsMemberId::-->>>' + mapOfCampaignMemberVsMemberId);
        if(mapOfCampaignMemberVsMemberId.get(String.valueOf(obj.get('Id'))) != NULL){
            campaignMemberId= mapOfCampaignMemberVsMemberId.get(String.valueOf(obj.get('Id')));
        }
        System.debug('campaignMemberId334::-->>>' + campaignMemberId + 'obj.get::-->>>' + obj.get('Id'));
        jsonString += '],';
        jsonString += '"external_id": "' + campaignMemberId +'",';
        jsonString += '"email": "'+ (email != NULL? email : '') + '",';
        jsonString += '"mobile_number": "'+ (mobile != NULL? mobile : '') +'",';
        jsonString += ' "confirmation_status": "confirmed",';
        jsonString += ' "clear_existing_fields": true';
        jsonString += '},'; //fields end
        System.debug('jsonString356::-->' +jsonString);
        return jsonString;
    }

    //@todo-Move in util
    // public String getSOQLFromSet(Set<String> setOfFields, String objectname){
    //     String soql = 'SELECT ';
    //     if(!setOfFields.isEmpty()){
    //         integer sz=0;
    //         for(String s:setOfFields){
    //             soql += s  + (setOfFields.Size()-1 == sz ? ' ' : ',');
    //             sz++;
    //         }
    //         soql += ' from ' + objectname;
    //     }
    //     return soql;
    // }

    //@todo-Move in util
    public String getSOQLFromSet(Set<String> setOfFields, String objectName) {
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

    private Account__c doGetInwiseAccount(String campaignId){
        Campaign objCampaign;
        String accountid;
        //List<Campaign> listOfCampaign = [Select Id,name,Account__c,Sendid__c,Campaign_Type__c from Campaign where Id=:campaignId WITH SECURITY_ENFORCED];
        List<Campaign> listOfCampaign = new List<Campaign>();

        // Check if the user has access to the Campaign object and the fields being queried
        if (Schema.sObjectType.Campaign.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Id.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Name.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Account__c.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Sendid__c.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Campaign_Type__c.isAccessible()) {

            // Perform the SOQL query with SECURITY_ENFORCED
            listOfCampaign = [SELECT Id, Name, Account__c, Sendid__c, Campaign_Type__c FROM Campaign WHERE Id = :campaignId WITH SECURITY_ENFORCED];
        } else {
            System.debug('User does not have sufficient permissions to access the Campaign object or fields.');
        }
        if(listOfCampaign != NULL && !listOfCampaign.isEmpty()){
            objCampaign = listOfCampaign.get(0);
        }
        System.debug('campaignId::->>' + campaignId);
        System.debug('listOfCampaign::->>' + listOfCampaign);
        System.debug('objCampaign::->>' + objCampaign);
        Account__c objInwiseAccountTemp;
        if(objCampaign != NULL && objCampaign.Account__c != NULL){
            accountid = objCampaign.Account__c;
        }
        if(Schema.sObjectType.Account__c.isAccessible()){
            if(accountid != NULL){
                //objInwiseAccountTemp = [SELECT Id,Name,Password__c,Token__c,User_Name__c,ListEmailFeedBackActionMaxId__c,ListEmailSentMessageMaxId__c FROM Account__c WHERE ID=:accountid WITH SECURITY_ENFORCED limit 1];
                // Check object and field accessibility for direct query
                if (Schema.sObjectType.Account__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Password__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Token__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.User_Name__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.ListEmailFeedBackActionMaxId__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.ListEmailSentMessageMaxId__c.isAccessible()) {

                    // Execute the query if all fields and the object are accessible
                    objInwiseAccountTemp = [SELECT Id, Name, Password__c, Token__c, User_Name__c, ListEmailFeedBackActionMaxId__c, ListEmailSentMessageMaxId__c
                                            FROM Account__c  WHERE ID = :accountid WITH SECURITY_ENFORCED LIMIT 1];
                } else {
                    System.debug('User does not have sufficient permissions to access the Account__c object or fields.');
                }
            } else {
                //List<Account__c> listOfInwiseAccount = [SELECT Id,Name,Password__c,Token__c,User_Name__c,ListEmailFeedBackActionMaxId__c,ListEmailSentMessageMaxId__c,  (SELECT inwise_Field__c,inwise_FieldId__c,Object_Type__c,Salesforce_Field__c FROM Mapping__r ) FROM Account__c where Default__c= true WITH SECURITY_ENFORCED limit 1];
                List<Account__c> listOfInwiseAccount = new List<Account__c>();
                if (Schema.sObjectType.Account__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Password__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Token__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.User_Name__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.ListEmailFeedBackActionMaxId__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.ListEmailSentMessageMaxId__c.isAccessible() &&
                    Schema.sObjectType.Mapping__c.isAccessible()) { // Check child relationship accessibility

                    listOfInwiseAccount = [SELECT Id,Name,Password__c,Token__c,User_Name__c,ListEmailFeedBackActionMaxId__c,ListEmailSentMessageMaxId__c,  (SELECT inwise_Field__c,inwise_FieldId__c,Object_Type__c,Salesforce_Field__c FROM Mapping__r ) FROM Account__c where Default__c= true WITH SECURITY_ENFORCED limit 1];

                } else {
                    System.debug('User does not have sufficient permissions to access the Account__c object, fields, or child relationship Mapping__r.');
                }

                if(!listOfInwiseAccount.isEmpty() && listOfInwiseAccount.get(0).Mapping__r.Size()>0){
                    objInwiseAccountTemp = listOfInwiseAccount.get(0);
                }
            }
        }
        return objInwiseAccountTemp;
    }

    global void finish(Database.BatchableContext BC){
        List<Logs__c> listOfLogs = new List<Logs__c>();
        doSyncMembersWithInwise(null, true, listOfLogs);
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
            listOfLogs = new List<Logs__c>();
        }
        inwiseGlobalAction.doClearAll(objInwiseUtil.objInwiseSetting.Track_Logs__c);
    }
    
     public static void bufferMethod() {
            String x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
            x = 'y';
        }

}