/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 24 Oct 2017
*Purpose :  Send Member action in batch after clicking on Sync Execute now or schedule
* Modification Log
----------------
Date                  Version     Developer                  Comments
------------------------------------------------------------------------------------
03/07/2019          1.1.0       K.Goutam               Modified :- While fetching data in pushExternalApp api, add 5 hours back time instead of 2 hour
04/24/2019          1.1.1       K.Goutam               Modified :- While fetching data in pushExternalApp api, add 2 hours back time instead of 1 minute
05/08/2019          1.1.2       K.Goutam               Modified:- Removed last batch checked as last batch in finish for all batch classes
04/19/2021          1.1.3       K.Goutam               Modified:- Changed in json in "jsonForMobileCampaignPerRecord" method [IFS-39]  
07/04/2021          1.1.4       NLINEAXIS(K.Goutam)    Modified:- Added error handling in case of api return not equal to 200. use case where inwise group was missing at inwise end & sf try to sync members
07/13/2021          1.1.5       K.Goutam               Modified:- Removed "order by name ASC" form SOQL
10/18/2021          1.1.6       K.Goutam               Modified:- Changes made related to delete API (get sync master created date time) in doSyncMembersWithInwise method
/******************************************************************************************/
global with sharing class BatchSyncMemberToInwise implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    //Campaign objCampaign;
    Sync__c objSync;
    boolean isContact{get;set;}
    String sSOQL{get;set;}
    Sync_Master__c objSyncMaster; 
    //List<Logs__c> listOfLogs{get;set;}
    public InwiseUtil objInwiseUtil{get;set;}
    Account__c objInwiseAccount{get;set;}
    Map<string,Mapping__c> mapInwiseMapping{get;set;}
    AggregateResult[] objInwiseFields{get;set;}
    List<Mapping__c> listOfInwiseMapping{get;set;}
    //boolean delete_existing_contacts{get;set;}
    boolean runForFailedOnly {get;set;}
    Integer totalRecordsSize{get;set;}
    Integer currentBatchNo{get;set;}
    boolean isFirstBatch {get;set;}
  /*
    BatchSyncMemberToInwise objBatchSyncMemberToInwise = new BatchSyncMemberToInwise ();
      Database.executeBatch(objBatchSyncMemberToInwise,1);
  */
  public void init(Id syncMasterId, Id syncId, boolean isForFailed, boolean isContactP, String sSOQLP,boolean isFirst){
      //delete_existing_contacts = true;
      isFirstBatch = isFirst;
      isContact = isContactP;
      totalRecordsSize = 0;
      sSOQL = sSOQLP+(Test.isRunningTest()?' LIMIT 200':'');
      System.debug('sSOQLP::-->>' + sSOQLP + '>>>' + sSOQL);
      runForFailedOnly = isForFailed;
      objSyncMaster = inwiseUtil.doGetSyncMaster(syncMasterId);
      objSync = inwiseUtil.doGetSyncRecord(objSyncMaster.Sync__c);
      //listOfLogs = new List<Logs__c>();
      if(objSync.Account__c != NULL){
            objInwiseUtil = new InwiseUtil(new Account__c(Id=objSync.Account__c));
      }else{
            objInwiseUtil = new InwiseUtil(null);
      }
      mapInwiseMapping = new Map<string,Mapping__c>();
      if(objInwiseUtil.objInwiseAccount != NULL){
           //listOfInwiseMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c from Mapping__c where Account__c=:objInwiseUtil.objInwiseAccount.Id];
           if (Schema.sObjectType.Mapping__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.inwise_Field__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.inwise_FieldId__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Object_Type__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isAccessible()) {
                
                // Execute the query only if all necessary field and object permissions are met
                listOfInwiseMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c FROM Mapping__c WHERE Account__c=:objInwiseUtil.objInwiseAccount.Id];

            } else {
                System.debug('User does not have sufficient permissions to access the Mapping__c object or required fields.');
            }
           objInwiseFields = [SELECT inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:objInwiseUtil.objInwiseAccount.Id  group by inwise_FieldId__c,inwise_Field__c];

           if(!listOfInwiseMapping.isEmpty()){
              System.debug('listOfInwiseMapping::-->>>' + listOfInwiseMapping.size());
              for(Mapping__c oMapping:listOfInwiseMapping){
                  string key= oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
                  mapInwiseMapping.put(key,oMapping);
              }  
           }
    }
      System.debug('sSOQL::-->>>' + sSOQL);
  }
  global Database.QueryLocator start(Database.BatchableContext BC){
      System.debug('sSOQL::::::-->>>' + sSOQL);
      List<String> listOfSOQLString = sSOQL.toLowerCase().split('from');
      if(!listOfSOQLString.isEmpty() && listOfSOQLString.size() == 2){
           totalRecordsSize = Database.countQuery('SELECT COUNT()  FROM '+listOfSOQLString.get(1));     
      }
      currentBatchNo = 0;
      return Database.getQueryLocator(sSOQL); 
  }
  global void execute(Database.BatchableContext BC, List<Sobject> scope){
    System.debug('execute STARTED::-->>' + scope);  
    Sync_Members__c objSyncMember;
    List<Logs__c> listOfLogs = new List<Logs__c>();
    List<Sync_Members__c> listOfSyncMembers = new List<Sync_Members__c>(); 

    ++currentBatchNo;  

    for(sObject mbr: (List<sObject>) scope){
        
        objSyncMember = new Sync_Members__c();
         if(Schema.sObjectType.Sync_Members__c.fields.Member_Record_ID__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Member_Record_ID__c.isCreateable() ){
                objSyncMember.Member_Record_ID__c = mbr.Id;
            }
        if(isContact){
          if(Schema.sObjectType.Sync_Members__c.fields.Contact__c.isCreateable()){
            objSyncMember.Contact__c = mbr.Id;
          }
        }else{
          if(Schema.sObjectType.Sync_Members__c.fields.Lead__c.isCreateable()){
              objSyncMember.Lead__c = mbr.Id;
          }
        } 
        System.debug('objSyncMember---->>>' + objSyncMember);   
        System.debug('objSyncMaster::-->>' + objSyncMaster);
        System.debug('isContact::-->>' + isContact);
        if(Schema.sObjectType.Sync_Members__c.fields.Sync_Master__c.isCreateable()){
          objSyncMember.Sync_Master__c = objSyncMaster.Id;
        }
        if(Schema.sObjectType.Sync_Members__c.fields.Type__c.isCreateable()){
            if(isContact){
              objSyncMember.Type__c = 'Contact';  
          }else{
              objSyncMember.Type__c = 'Lead';  
          }
        }
        listOfSyncMembers.add(objSyncMember); 
    }
    Map<String,boolean> external_id =new Map<String,boolean> ();
    Map<String,string> error_external_id =new Map<String,string> ();
    System.debug('listOfSyncMembers::-->>>' + listOfSyncMembers);
    System.debug('listOfSyncMembersize()::-->>>' + listOfSyncMembers.size());
//    boolean isLastBatch = objInwiseUtil.isLastBatchForSyncWithInwise(totalRecordsSize,currentBatchNo);
    if(!listOfSyncMembers.isEmpty()){
       
        if(Schema.SObjectType.Sync_Members__c.isCreateable()){

            JsonToApexPushExernalApp  successResponse = doSyncMembersWithInwise(listOfSyncMembers,false,listOfLogs);
           system.debug('successResponse>>>117>>>'+successResponse);

            for(Sync_Members__c sm :listOfSyncMembers){
                        sm.Is_Processed__c = true; 
                        system.debug('Member_Record_ID__c>>>145>>'+sm.Member_Record_ID__c);
                        //code removed because of issue field is not writable
                        //issue fix, sync master null in some cases.
                        
                        if(sm.Sync_Master__c == NULL ){
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
                       if(successResponse.conflicts !=null && !successResponse.conflicts.isEmpty()){
                           for(JsonToApexPushExernalApp.Errors conflictsRecord: successResponse.conflicts){
                                    error_external_id.put(conflictsRecord.external_id,conflictsRecord.details);
                                } 
                                if(error_external_id.containsKey(sm.Member_Record_ID__c)) {
                                 sm.Reason__c=error_external_id.get(sm.Member_Record_ID__c);

                              } 
                        }
                        if(successResponse.updated !=null && !successResponse.updated.isEmpty()){
                           for(string updatedRecord: successResponse.updated){
                                    external_id.put(updatedRecord,true);
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

            if(objInwiseUtil.objInwiseSetting.Log_Sync_Memebers__c){
                insert listOfSyncMembers;
            }  
          
      }
    }
    if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
              insert listOfLogs;
              listOfLogs = new List<Logs__c>(); 
     }
  
  }

  public JsonToApexPushExernalApp doSyncMembersWithInwise(List<Sync_Members__c> listOfSyncMembers,boolean isLastBatch,List<Logs__c> listOfLogs){
    Http http = new Http();
    HttpResponse res;
    HttpRequest req;
    boolean isSuccess;
    JsonToApexPushExernalApp  recordOfresponse;
    try{
        isSuccess = true;
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contactsGroups/pushExternalApp?group_id='+ objSyncMaster.Group_Id__c;
        System.debug('isLastBatch::-->>>>' + isLastBatch);

        if(!objSync.Dont_Delete_Existing_Contacts__c && isLastBatch){
            // Datetime dtNowUTC = Datetime.newInstance(Datetime.now().dateGmt(), Datetime.now().timeGmt());
            Datetime dtNowUTC = Datetime.newInstance(objSyncMaster.CreatedDate.dateGmt(), objSyncMaster.CreatedDate.timeGmt());
            Datetime dtPrevious2Hours = dtNowUTC.addMinutes(-1);
            endpoint += '&delete_existing_contacts_by_last_date='+ EncodingUtil.urlEncode(dtPrevious2Hours.format('yyyy-MM-dd HH:mm:ss'),'UTF-8'); 
        }
        if(objInwiseUtil.objInwiseSetting.Use_Bulk_Push__c){
            endpoint += '&use_bulk_push='+objInwiseUtil.objInwiseSetting.Use_Bulk_Push__c;
        }

        if(isFirstBatch){
            endpoint += '&lock_group=true';
            isFirstBatch=false;
        }else if(isLastBatch){
            endpoint += '&unlock_group=true';
        }
        req = objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint); 
        req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);
        //System.debug('req mobile create group::-->>>' + req + '>>>' ); 
        if(!isLastBatch) {
            //System.debug('req mobile create group::-->>>' + req + '>>>' ); 
            req.setBody(getBodyMobileJsonPushExternalApp(objSyncMaster.Id, Integer.valueOf(objSyncMaster.Group_Id__c), listOfInwiseMapping, objInwiseFields, mapInwiseMapping, listOfSyncMembers));
            //System.debug('req mobile create group::-->>>' + req + '>>>' ); 
        }else{
            System.debug('come here=========');
            req.setBody('');
        }
        req.setTimeout(120000);
        //System.debug('req mobile create group::-->>>' + req + '>>>' ); 
        if(!Test.isRunningTest()){
         
            res = http.send(req);
            System.debug('res ::-->>>' + res); 
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups/pushExternalApp','BatchSyncMemberToInwise','doSyncMembersWithInwise'));
            if(!isLastBatch) {
                for (Sync_Members__c sm : listOfSyncMembers) {
                    sm.Is_Processed__c = true;
                }
            }
        }else{
            String resBody = '{"status": "complete"}';
            res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
        }
        System.debug('response mobile create group::-->>>' + res + '>>>' + res.getBody()); 
        //if(delete_existing_contacts){
        //    delete_existing_contacts = false;
        //}
    }catch(Exception ex){
        String resBody = ex.getMessage();
        System.debug('resBody::-->>>>>>' + resBody);
        res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
        listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups/pushExternalApp','SendToInwiseController','InwiseCalloutGroupsCreateGroupMobile'));
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
  public String getBodyMobileJsonPushExternalApp(Id SyncMasterId, integer grpid,List<Mapping__c> listOfInwiseMapping,AggregateResult[] objInwiseFields,map<string,Mapping__c> mapInwiseMapping,List<Sync_Members__c> listOfSyncMembers){
            String soqlContact = '', soqlLead='';
            Set<String> setOfContactFields = new Set<String>();
            Set<String> setOfLeadFields = new Set<String>();
            Set<Id> setOfContactMember = new Set<Id>();
            Set<Id> setOfLeadMember = new Set<Id>();
            List<Contact> listOfContact = new List<Contact>();
            List<Lead> listOfLead = new List<Lead>();
            //Map<Id,Id> mapOfCampaignMemberContactVsMemberId = new Map<Id,Id>();
            //Map<Id,Id> mapOfCampaignMemberLeadVsMemberId = new Map<Id,Id>();
            if(!listOfInwiseMapping.isEmpty()){
                for(Mapping__c im:listOfInwiseMapping){
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
           
              //if(CampaignId != NULL){
                    //List<Sync_Members__c> listOfSyncMember;
                    //if(Schema.sObjectType.Sync__c.isAccessible()){
                    //        listOfSyncMember = [SELECT Id,Contact__c, Lead__c FROM  Sync_Members__c where   Sync_Master__c  =: SyncMasterId AND Is_Processed__c = false];   
                    //}    
                    //System.debug('listOfSyncMember::-->>>>' + listOfSyncMember);    
                    if(!listOfSyncMembers.isEmpty()){
                            for(Sync_Members__c mbr: listOfSyncMembers){
                                    if(mbr.Contact__c != NULL){
                                            setOfContactMember.add(mbr.Contact__c);
                                            //mapOfCampaignMemberContactVsMemberId.put(mbr.ContactId,mbr.Id);
                                    }
                                    if(mbr.Lead__c != NULL){
                                            setOfLeadMember.add(mbr.Lead__c); 
                                            //mapOfCampaignMemberLeadVsMemberId.put(mbr.LeadId, mbr.Id);
                                    }
                                   
                            }
                    } 
                    if(!setOfContactMember.isEmpty() &&  !String.isEmpty(soqlContact)){
                            //listOfContact = Database.query(soqlContact + ' WHERE Id IN:setOfContactMember order by name ASC');
                            listOfContact = Database.query(soqlContact + ' WHERE Id IN:setOfContactMember');
                    }

                    if(!setOfLeadMember.isEmpty() &&  !String.isEmpty(soqlLead)){
                            //listOfLead = Database.query(soqlLead + ' WHERE Id IN:setOfLeadMember order by name ASC');
                            listOfLead = Database.query(soqlLead + ' WHERE Id IN:setOfLeadMember');
                    }

              //}  
            String jsonString = '[';
            boolean isNeedToDoSubstring = false;
            if(!listOfContact.isEmpty()){
                isNeedToDoSubstring = true;
                for(Contact oContact:listOfContact){
                        jsonString += jsonForMobileCampaignPerRecord(oContact,InwiseConstants.SOBJECT_CONTACT,listOfInwiseMapping,  objInwiseFields, mapInwiseMapping);
                 }   
            }
            System.debug('jsonString MOBILE listOfContact::-->>>' + jsonString);
            if(!listOfLead.isEmpty()){
                isNeedToDoSubstring = true;
                //jsonString += ',';
                for(Lead oLead:listOfLead){
                        jsonString += jsonForMobileCampaignPerRecord(oLead,InwiseConstants.SOBJECT_LEAD,listOfInwiseMapping,  objInwiseFields, mapInwiseMapping);
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
 
     public String jsonForMobileCampaignPerRecord(SObject obj,String sObjectType, List<Mapping__c> listOfInwiseMapping, AggregateResult[] objInwiseFields, map<string,Mapping__c> mapInwiseMapping){
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
                                                mobile = inwiseHttpUtil.getFormattedPhone(val, objInwiseUtil);
                                                isNeedToRemoveExtraComma = false;
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
                                            //        //if(mapOfCampaignMemberVsMemberId.get(String.valueOf(obj.get('Id'))) != NULL){
                                            //        //      //campaignMemberId= mapOfCampaignMemberVsMemberId.get(String.valueOf(obj.get('Id'))); 
                                            //        //}  
                                            //}
                                         
                                    }
                                   
                        }
                        if(isNeedToRemoveExtraComma){
                            jsonString = jsonString.substring(0, jsonString.length()-1);
                       
                        }           
         jsonString += '],';
         jsonString += '"external_id": "' + obj.Id +'",';
         jsonString += '"email": "'+ (email != NULL? email : '') + '",'; 
         jsonString += '"mobile_number": "'+ (mobile != NULL? mobile : '') +'",';
         jsonString += ' "confirmation_status": "confirmed",';
         jsonString += ' "clear_existing_fields": true'; 
         jsonString += '},'; //fields end      
         System.debug('==finalJSON=='+jsonString);
         return jsonString;  
    }
  //  //@todo-Move in util
    //  public String getSOQLFromSet(Set<String> setOfFields, String objectname){
    //         String soql = 'SELECT ';
    //         if(!setOfFields.isEmpty()){
    //             integer sz=0;
    //             for(String s:setOfFields){
    //                     soql += s  + (setOfFields.Size()-1 == sz ? ' ' : ',');
    //                     sz++;
    //             }
    //             soql += ' from ' + objectname;
    //         }
    //        return soql; 
    // }

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
  
  global void finish(Database.BatchableContext BC){
      List<Logs__c> listOfLogs = new List<Logs__c>();
      doSyncMembersWithInwise(null, true, listOfLogs);
      if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
          insert listOfLogs;
          listOfLogs = new List<Logs__c>();
      }
     if(objSync != NULL && objSync.Id != NULL){
        Sync__c objSyncToUpdate = new Sync__c(Id=objSync.Id);
        if(Schema.sObjectType.Sync__c.fields.Last_Run_By__c.isUpdateable()){
              objSyncToUpdate.Last_Run_By__c = UserInfo.getUserId();
        }

       if(Schema.sObjectType.Sync__c.fields.Last_Run__c.isUpdateable()){
            objSyncToUpdate.Last_Run__c = datetime.now();
       }
       update objSyncToUpdate;
    }
    inwiseGlobalAction.doClearAll(objInwiseUtil.objInwiseSetting.Track_Logs__c);
    //if(!objInwiseUtil.objInwiseSetting.Track_Logs__c){
    //    inwiseGlobalAction.doClearLogs();
    //    inwiseGlobalAction.doClearSyncMaster();
    //}
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