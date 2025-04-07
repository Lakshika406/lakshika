/******************************************************************************************
* Name          :  BatchSendMemberToInwisev2

* Description   :  Send Member action in batch
                  
* Author        :  Kapil Goutam

Modification Log
----------------
Date                  Version   Developer                  Comments
------------------------------------------------------------------------------------
08/26/2018          1.0.0       K.Goutam                   Created: Copied code from BatchSendMemberToInwise
08/29/2018          1.0.1       K.Goutam                    Modified :- Not in use now  using BatchSendMemberToInwise
/***********************************************************************************/
global with sharing class BatchSendMemberToInwisev2 implements Database.Batchable<sObject>, Database.AllowsCallouts{ 
    //Campaign objCampaign;
    //Sync_Master__c objSyncMaster; 
    //InwiseUtil objInwiseUtil{get;set;}
    //Account__c objInwiseAccount{get;set;}
    //Map<string,Mapping__c> mapInwiseMapping{get;set;}
    //AggregateResult[] objInwiseFields{get;set;}
    //List<Mapping__c> listOfInwiseMapping{get;set;}
    //boolean runForFailedOnly {get;set;}
    //Integer totalRecordsSize{get;set;}
    //Integer currentBatchNo{get;set;}
  /*
    BatchSendMemberToInwisev2 objBatchSendMemberToInwisev2 = new BatchSendMemberToInwisev2 ();
      Database.executeBatch(objBatchSendMemberToInwisev2,1);
  */
  //public void init(Id syncMasterId, Id campaignId, boolean isForFailed){
  //    runForFailedOnly = isForFailed;
  //    //totalRecordsSize = 0;
  //    List<Campaign> listOfCampaign = [Select Id,name,Account__c,Sendid__c,Campaign_Type__c from Campaign where Id=:campaignId];
  //    if(listOfCampaign != NULL && !listOfCampaign.isEmpty()){
  //      objCampaign = listOfCampaign.get(0);
  //    }
  //    objSyncMaster = inwiseUtil.doGetSyncMaster(syncMasterId);
  //    objInwiseAccount = doGetInwiseAccount(campaignId);    
  //    objInwiseUtil = new InwiseUtil(objInwiseAccount);
  //    mapInwiseMapping = new Map<string,Mapping__c>();
  //    if(objInwiseAccount != NULL){
  //         listOfInwiseMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c from Mapping__c where Account__c=:objInwiseAccount.Id];
  //         objInwiseFields = [SELECT inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:objInwiseAccount.Id  group by inwise_FieldId__c,inwise_Field__c];

  //         if(!listOfInwiseMapping.isEmpty()){
  //            System.debug('listOfInwiseMapping::-->>>' + listOfInwiseMapping.size());
  //            for(Mapping__c oMapping:listOfInwiseMapping){
  //                string key= oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
  //                mapInwiseMapping.put(key,oMapping);
  //            }  
  //         }
          
  //  }
  //}
  global Database.QueryLocator start(Database.BatchableContext BC){
    String soqlQuery = '';
    //Id campaignId = objCampaign.Id;
    //String soqlSelect = 'SELECT Id, ContactId, LeadId, CampaignId FROM CampaignMember';
    String soqlSelect = '';
    if (Schema.sObjectType.CampaignMember.isAccessible() &&
        Schema.sObjectType.CampaignMember.fields.Id.isAccessible() &&
        Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() &&
        Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible() &&
        Schema.sObjectType.CampaignMember.fields.CampaignId.isAccessible()) {
        
        // Only execute the query if all necessary fields are accessible
        soqlSelect = 'SELECT Id, ContactId, LeadId, CampaignId FROM CampaignMember';
    } else {
        System.debug('User does not have sufficient permissions to access the CampaignMember object or required fields.');
    }
    //System.debug('runForFailedOnly::-->>' + runForFailedOnly);
    //if(runForFailedOnly){
    //      Set<Id> setOfId = new Set<Id>();
    //      Set<Id> setOfIdSyncMaster = new Set<Id>();
    //      List<Sync_Members__c> listOfSyncMembers = [Select Member_Record_ID__c,Sync_Master__c from Sync_Members__c where Sync_Master__c=:objSyncMaster.Id AND Is_Processed__c = false ];
    //      if(!listOfSyncMembers.isEmpty()){
    //          for(Sync_Members__c sm:listOfSyncMembers){
    //             if(sm.Member_Record_ID__c != NULL){
    //                setOfId.add(sm.Member_Record_ID__c);  
    //             } 
    //             setOfIdSyncMaster.add(sm.Sync_Master__c);
                 
    //          }
    //      }
    //      System.debug('setOfId::-->>' + setOfId.size() + '>>>' + setOfId + '>>>>' + objCampaign);
    //      soqlQuery = 'where CampaignId =:campaignId  and  Id IN:setOfId';
    //      //QueryLocatorOfCampaignMember = Database.getQueryLocator([
    //      //              SELECT Id,ContactId, LeadId,CampaignId FROM CampaignMember where CampaignId  =:objCampaign.Id  and  Id IN:setOfId 
    //      //          ]);
    //  }else{
    //      soqlQuery = 'where CampaignId  =:campaignId';
    //      //QueryLocatorOfCampaignMember = Database.getQueryLocator([
    //      //              SELECT Id,ContactId, LeadId,CampaignId FROM CampaignMember where CampaignId  =:objCampaign.Id  
    //      //          ]);    
    //  }  
    //  System.debug('soqlQuery::-->>>' + soqlQuery);
      Database.QueryLocator QueryLocatorOfCampaignMember = Database.getQueryLocator(soqlSelect + soqlQuery);
    //  //totalRecordsSize = Database.countQuery('SELECT COUNT() FROM CampaignMember '+soqlQuery);
    // // currentBatchNo = 0;
    //  //System.debug('totalRecordsSize::-->>>' + totalRecordsSize);
      return QueryLocatorOfCampaignMember;
    
  }
  global void execute(Database.BatchableContext BC, List<Sobject> scope){
    //  Set<Id> setOfCampaignMemberIds = new Set<Id>();
    //  Sync_Members__c objSyncMember;
    //  List<Sync_Members__c> listOfSyncMembers = new List<Sync_Members__c>();  
    //  List<Logs__c> listOfLogs = new List<Logs__c>();
    //  //++currentBatchNo;   
    //  List<CampaignMember> tmpList =  (List<CampaignMember>) scope;
    //  System.debug('tmpList debug::-->>' + tmpList.size());
    //  for(CampaignMember mbr: (List<CampaignMember>) scope){
    //        objSyncMember = new Sync_Members__c();
    //        if(Schema.sObjectType.Sync_Members__c.fields.Sync_Master__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Sync_Master__c.isCreateable()){
    //          objSyncMember.Sync_Master__c = objSyncMaster.Id;
    //        }
    //        if(Schema.sObjectType.Sync_Members__c.fields.Member_Record_ID__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Member_Record_ID__c.isCreateable() ){
    //            objSyncMember.Member_Record_ID__c = mbr.Id;
    //        }
    //        if(mbr.ContactId != NULL){
    //           if(Schema.sObjectType.Sync_Members__c.fields.Contact__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Contact__c.isCreateable()){
    //                objSyncMember.Contact__c = mbr.ContactId;
    //            }
    //            if(Schema.sObjectType.Sync_Members__c.fields.Type__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Type__c.isCreateable() ){
    //                objSyncMember.Type__c = 'Contact';
    //            }
    //        }
    //        if(mbr.LeadId != NULL){
    //            if(Schema.sObjectType.Sync_Members__c.fields.Lead__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Lead__c.isCreateable()){
    //                objSyncMember.Lead__c = mbr.LeadId;   
    //            }
    //            if(Schema.sObjectType.Sync_Members__c.fields.Type__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Type__c.isCreateable() ){
    //              objSyncMember.Type__c = 'Lead';  
    //          }
    //        }
    //        setOfCampaignMemberIds.add(mbr.Id);
    //        listOfSyncMembers.add(objSyncMember); 
           
    //}

    //System.debug('listOfSyncMembers size::-->>>' + listOfSyncMembers.size());
    //List<Sync_Members__c> listOfSyncMembersTemp;
    //try{
    //    boolean isLastBatch = false;// objInwiseUtil.isLastBatchForSyncWithInwise(totalRecordsSize,currentBatchNo);
    //    System.debug('isLastBatch134::-->>>' + isLastBatch);
    //    if(!listOfSyncMembers.isEmpty()){
    //        boolean isSuccess = doSyncMembersWithInwisev2(setOfCampaignMemberIds,isLastBatch, listOfLogs);
    //        System.debug('isSuccess::137>>' + isSuccess);
    //        if(isSuccess){
    //            if(runForFailedOnly){
    //                listOfSyncMembersTemp = [Select Id from Sync_Members__c where Member_Record_ID__c IN:setOfCampaignMemberIds];
    //            }else{
    //                listOfSyncMembersTemp  = listOfSyncMembers;
    //            }
    //            if(!listOfSyncMembersTemp.isEmpty()){
    //              for(Sync_Members__c sm :listOfSyncMembersTemp){
    //                 sm.Is_Processed__c = true; 
    //                 //code removed because of issue field is not writable
    //                 //issue fix, sync master null in some cases.
    //                 //if(sm.Sync_Master__c == NULL){
    //                 //     sm.Sync_Master__c = objSyncMaster.Id; 
    //                 //}
                     
    //              }
                
    //              if(Schema.sObjectType.Sync_Members__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.isCreateable()){
    //                 // System.debug('listOfSyncMembersTemp::->>>' + listOfSyncMembersTemp.get(0));
    //                  if(objInwiseUtil.objInwiseSetting.Log_Sync_Memebers__c){
    //                      upsert listOfSyncMembersTemp;
    //                  }    
    //              }
    //          }  
    //        }
            
    //    }    
    //     if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
    //              insert listOfLogs;
    //              listOfLogs = new List<Logs__c>(); 
    //     }
    //}catch(Exception ex){
    //    System.debug('Exception in BatchSendMemberToInwisev2' + ex.getMessage());
    //}
    
  
  }

  //public boolean doSyncMembersWithInwisev2(Set<Id> setOfCampaignMemberIds, boolean isLastBatch, List<Logs__c> listOfLogs){
  //  Http http = new Http();
  //  HttpResponse res;
  //  HttpRequest req;
  //  boolean isSuccess;
  //  try{
  //      isSuccess = true;
  //      String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contactsGroups/pushExternalApp?group_id='+ objSyncMaster.Group_Id__c; 
  //      System.debug('isLastBatch::-->>>>' + isLastBatch);
  //      if(isLastBatch){
  //          Datetime dtNowUTC = Datetime.newInstance(Datetime.now().dateGmt(), Datetime.now().timeGmt());
  //          Datetime dtPrevious2Hours = dtNowUTC.addHours(-2);
  //          endpoint += '&delete_existing_contacts_by_last_date='+ EncodingUtil.urlEncode(dtPrevious2Hours.format('yyyy-MM-dd HH:mm:ss'),'UTF-8'); 
  //      }
  //      req = objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint); 
  //      req.setHeader('X-Api-Key',objInwiseUtil.objInwiseAccount.Token__c);        
  //      req.setBody(getBodyMobileJsonPushExternalApp(objCampaign.Id,Integer.valueOf(objSyncMaster.Group_Id__c),listOfInwiseMapping,objInwiseFields,mapInwiseMapping,setOfCampaignMemberIds));
  //      req.setTimeout(120000);
  //      if(!Test.isRunningTest()){
  //          res = http.send(req);
  //          listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups/pushExternalApp','BatchSendMemberToInwisev2','doSyncMembersWithInwisev2'));
  //      }else{
  //          String resBody = '{"status": "complete"}';
  //          res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
  //      }
  //      System.debug('response mobile create group::-->>>' + res + '>>>' + res.getBody()); 
  //  }catch(Exception ex){
  //      String resBody = ex.getMessage();
  //      res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
  //      listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups/pushExternalApp','BatchSendMemberToInwisev2','doSyncMembersWithInwisev2'));
  //      isSuccess = false;
  //  }
  //  return isSuccess;
   
  //}
  //public String getBodyMobileJsonPushExternalApp(String CampaignId,integer grpid,List<Mapping__c> listOfInwiseMapping,AggregateResult[] objInwiseFields,map<string,Mapping__c> mapInwiseMapping, Set<Id> setOfCampaignMemberIds){
  //          String soqlContact = '', soqlLead='';
  //          Set<String> setOfContactFields = new Set<String>();
  //          Set<String> setOfLeadFields = new Set<String>();
  //          Set<Id> setOfContactMember = new Set<Id>();
  //          Set<Id> setOfLeadMember = new Set<Id>();
  //          List<Contact> listOfContact = new List<Contact>();
  //          List<Lead> listOfLead = new List<Lead>();
  //          Map<Id,Id> mapOfCampaignMemberContactVsMemberId = new Map<Id,Id>();
  //          Map<Id,Id> mapOfCampaignMemberLeadVsMemberId = new Map<Id,Id>();
            
  //          for(Mapping__c im:listOfInwiseMapping){
  //               if(im.Salesforce_Field__c != null && im.Salesforce_Field__c != ''){
  //                   if(im.Object_Type__c == InwiseConstants.SOBJECT_CONTACT){
  //                          setOfContactFields.add(im.Salesforce_Field__c);
  //                    }else if(im.Object_Type__c == InwiseConstants.SOBJECT_LEAD){
  //                          setOfLeadFields.add(im.Salesforce_Field__c);
  //                    }
  //               }                      
  //           }   
  //           //add email & phone to pass these in json by default
  //           setOfContactFields.add('Email');
  //           setOfContactFields.add('MobilePhone');
  //           setOfLeadFields.add('Email');
  //           setOfLeadFields.add('MobilePhone');
  //           soqlContact = getSOQLFromSet(setOfContactFields, InwiseConstants.SOBJECT_CONTACT);
  //           soqlLead = getSOQLFromSet(setOfLeadFields, InwiseConstants.SOBJECT_LEAD);
           
  //            if(CampaignId != NULL){
  //                  List<CampaignMember> listOfCampaignMember;
  //                  if(Schema.sObjectType.Sync__c.isAccessible()){
  //                          listOfCampaignMember = [SELECT Id,ContactId, LeadId FROM CampaignMember where Id  IN: setOfCampaignMemberIds];   
  //                  }        
  //                  if(!listOfCampaignMember.isEmpty()){
  //                          for(CampaignMember mbr: listOfCampaignMember){
  //                                  if(mbr.ContactId != NULL){
  //                                          setOfContactMember.add(mbr.ContactId);
  //                                          mapOfCampaignMemberContactVsMemberId.put(mbr.ContactId,mbr.Id);
  //                                  }
  //                                  if(mbr.LeadId != NULL){
  //                                          setOfLeadMember.add(mbr.LeadId); 
  //                                          mapOfCampaignMemberLeadVsMemberId.put(mbr.LeadId, mbr.Id);
  //                                  }
                                   
  //                          }
  //                  } 
  //                  if(!setOfContactMember.isEmpty() &&  !String.isEmpty(soqlContact)){
  //                          listOfContact = Database.query(soqlContact + ' WHERE Id IN:setOfContactMember order by name ASC');
  //                          System.debug('listOfContact255::-->>>' + listOfContact.size());
  //                  }

  //                  if(!setOfLeadMember.isEmpty() &&  !String.isEmpty(soqlLead)){
  //                          listOfLead = Database.query(soqlLead + ' WHERE Id IN:setOfLeadMember order by name ASC');
  //                  }

  //            }  
  //          String jsonString = '[';
  //          if(!listOfContact.isEmpty()){
  //              for(Contact oContact:listOfContact){
  //                      jsonString += jsonForMobileCampaignPerRecord(oContact,InwiseConstants.SOBJECT_CONTACT,listOfInwiseMapping, CampaignId, objInwiseFields, mapInwiseMapping,mapOfCampaignMemberContactVsMemberId);
  //               }   
  //          }
  //          System.debug('jsonString MOBILE listOfContact::-->>>' + jsonString);
  //          if(!listOfLead.isEmpty()){
  //              //jsonString += ',';
  //              for(Lead oLead:listOfLead){
  //                      jsonString += jsonForMobileCampaignPerRecord(oLead,InwiseConstants.SOBJECT_LEAD,listOfInwiseMapping, CampaignId, objInwiseFields, mapInwiseMapping,mapOfCampaignMemberLeadVsMemberId);
  //               }   
  //          }
  //          System.debug('jsonString MOBILE listOfLead::-->>>' + jsonString);
  //          jsonString = jsonString.substring(0, jsonString.length()-1);
  //          jsonString += ' ]';
  //          System.debug('jsonString MOBILE::-->>>' + jsonString);
  //          return jsonString;
  //  }
  //  //public string getXMLReuestForCreateMobileMessage(String sessionId,InwiseUtil objInwiseUtil,String campaignName){
  //  //    String maxidString = '';
  //  //    String soapBody = '<?xml version="1.0" encoding="utf-8"?>';
  //  //    soapBody += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
  //  //    soapBody += '<soap:Header>';
  //  //        soapBody += '<SessionIdHeader xmlns="http://www.inwise.com/webservices/v2">';
  //  //            soapBody += '<SessionId>'+ sessionId+'</SessionId>';
  //  //            soapBody += '<EndSession>true</EndSession>';
  //  //        soapBody += '</SessionIdHeader>';
  //  //    soapBody += '</soap:Header>';

  //  //    soapBody += '<soap:Body>';
  //  //        soapBody += '<Create xmlns="http://www.inwise.com/webservices/v2">';
  //  //            soapBody += '<entity xsi:type="MobileMessage">';
  //  //                    soapBody +='<AccountId xsi:nil="true" />';
  //  //                    soapBody +='<Body> '+ '' +' </Body>';
  //  //                    soapBody +='<Bounces xsi:nil="true" />';
  //  //                    soapBody +='<Charset>unicode</Charset>';
  //  //                    soapBody +='<CreateDate xsi:nil="true" />';
  //  //                    soapBody +='<EndDate xsi:nil="true" />';
  //  //                    soapBody +='<LastSent xsi:nil="true" />';
  //  //                    soapBody +='<Name>'+campaignName+ '</Name>';
  //  //                    soapBody +='<NonSent xsi:nil="true" />';
  //  //                    soapBody +='<Opens xsi:nil="true" />';
  //  //                    soapBody +='<RecipientType xsi:nil="true" />';
  //  //                    soapBody +='<Sender> ' + (objInwiseUtil.objInwiseAccount.SMS_Sender__c != NULL ? objInwiseUtil.objInwiseAccount.SMS_Sender__c : '')  +' </Sender>';
  //  //                    soapBody +='<Sent xsi:nil="true" />';
  //  //                    soapBody +='<Status xsi:nil="true" />';
  //  //                    soapBody +='<TableConnectionId xsi:nil="true" />';
  //  //                    soapBody +='<Unsubscribes xsi:nil="true" />';
  //  //                    soapBody +='<UpdateDate xsi:nil="true" />';
  //  //                    soapBody +='<Validity>1440</Validity>';
  //  //            soapBody += '</entity>';
  //  //        soapBody += '</Create>';    
  //  //    soapBody += '</soap:Body>';
  //  //    soapBody += '</soap:Envelope>';
  //  //    return soapBody;
  //  //}
  //   public String jsonForMobileCampaignPerRecord(SObject obj,String sObjectType, List<Mapping__c> listOfInwiseMapping, String CampaignId, AggregateResult[] objInwiseFields, map<string,Mapping__c> mapInwiseMapping,Map<Id,Id> mapOfCampaignMemberVsMemberId){
  //       Id campaignMemberId;   
  //       String email, mobile;
  //       boolean isNeedToRemoveExtraComma = false;
  //       string key,val;
  //       Mapping__c inw;
  //       String jsonString = '{';
  //              jsonString += '"fields": [';
  //                      campaignMemberId = NULL;
  //                      isNeedToRemoveExtraComma = false;
  //                      for(AggregateResult ar:objInwiseFields){
  //                                  key = ar.get('inwise_FieldId__c') + ':' + sObjectType;
  //                                  val = '';
  //                                  inw=mapInwiseMapping.get(key);
  //                                  if(inw != NULL && inw.Salesforce_Field__c !=null){
  //                                      val = (obj.get(inw.Salesforce_Field__c) != NULL ? string.valueof(obj.get(inw.Salesforce_Field__c)) : '');
  //                                      if(!String.isEmpty(val)){
  //                                          val = val.escapeEcmaScript();
  //                                      }
  //                                      if(!isNeedToRemoveExtraComma){
  //                                          isNeedToRemoveExtraComma = true;    
  //                                      }
  //                                      if(inw.inwise_Field__c == 'Email' && email == NULL){
  //                                              email = val;
  //                                      }else if(inw.inwise_Field__c == 'Mobile' && mobile == NULL){
  //                                                System.debug('Mobile317::--->>>' + val);
  //                                                mobile = inwiseHttpUtil.getFormattedPhone(val, objInwiseUtil);
  //                                                System.debug('Mobile319::--->>>' + val);
  //                                      }else{// to avoid email in inner json fields. as per boaz input
  //                                              jsonString += ' { ';
  //                                                      jsonString += ' "name": "' +inw.inwise_FieldId__c + '",';
  //                                                      jsonString += ' "content": "' + val  +'" ';
  //                                              jsonString += ' },';
  //                                      }
                                        
  //                                  }else{
  //                                          //don't need this code - Commented on 26 Feb 2018
  //                                          //if(ar.get('inwise_Field__c') == InwiseConstants.INWISE_FIELD_SALESFORCECAMPAIGNMEMBERID){
  //                                          //      //add campaign member id, taking it in seprate field for fixing herbew language issue
  //                                          //        if(mapOfCampaignMemberVsMemberId.get(String.valueOf(obj.get('Id'))) != NULL){
  //                                          //              campaignMemberId= mapOfCampaignMemberVsMemberId.get(String.valueOf(obj.get('Id'))); 
  //                                          //        }  
  //                                          //}
                                         
  //                                  }
                                   
  //                      }
  //                      if(isNeedToRemoveExtraComma){
  //                              jsonString = jsonString.substring(0, jsonString.length()-1);
  //                              System.debug('jsonString after split::-->>>' + jsonString);
                       
  //                      }     
  //       System.debug('mapOfCampaignMemberVsMemberId::-->>>' + mapOfCampaignMemberVsMemberId);
  //       if(mapOfCampaignMemberVsMemberId.get(String.valueOf(obj.get('Id'))) != NULL){
  //              campaignMemberId= mapOfCampaignMemberVsMemberId.get(String.valueOf(obj.get('Id'))); 
  //       }
  //       System.debug('campaignMemberId334::-->>>' + campaignMemberId + 'obj.get::-->>>' + obj.get('Id'));                      
  //       jsonString += '],';
  //       jsonString += '"external_id": "' + campaignMemberId +'",';
  //       jsonString += '"email": "'+ (email != NULL? email : '') + '",'; 
  //       jsonString += '"mobile_number": "'+ (mobile != NULL? mobile : '') +'",';
  //       jsonString += ' "confirmation_status": "confirmed",';
  //       jsonString += ' "clear_existing_fields": true'; 
  //       jsonString += '},'; //fields end       
  //       System.debug('jsonString356::-->' +jsonString);
  //       return jsonString;  
  //  }
  //  //@todo-Move in util
  //   public String getSOQLFromSet(Set<String> setOfFields, String objectname){
  //          String soql = 'SELECT ';
  //          if(!setOfFields.isEmpty()){
  //              integer sz=0;
  //              for(String s:setOfFields){
  //                      soql += s  + (setOfFields.Size()-1 == sz ? ' ' : ',');
  //                      sz++;
  //              }
  //              soql += ' from ' + objectname;
  //          }
  //         return soql; 
  //  }
  
  //private Account__c doGetInwiseAccount(String campaignId){
  //      Campaign objCampaign;
  //      String accountid;
  //      List<Campaign> listOfCampaign = [Select Id,name,Account__c,Sendid__c,Campaign_Type__c from Campaign where Id=:campaignId];
  //      if(listOfCampaign != NULL && !listOfCampaign.isEmpty()){
  //          objCampaign = listOfCampaign.get(0);
  //       }
  //      System.debug('campaignId::->>' + campaignId);
  //      System.debug('listOfCampaign::->>' + listOfCampaign);
  //      System.debug('objCampaign::->>' + objCampaign);
  //      Account__c objInwiseAccountTemp;
  //      if(objCampaign != NULL && objCampaign.Account__c != NULL){
  //              accountid = objCampaign.Account__c;
  //      }
  //      if(Schema.sObjectType.Account__c.isAccessible()){
  //          if(accountid != NULL){
  //              objInwiseAccountTemp = [SELECT Id,Name,Password__c,Token__c,User_Name__c,ListEmailFeedBackActionMaxId__c,ListEmailSentMessageMaxId__c FROM Account__c WHERE ID=:accountid limit 1];
  //          }else{
  //                  List<Account__c> listOfInwiseAccount = [SELECT Id,Name,Password__c,Token__c,User_Name__c,ListEmailFeedBackActionMaxId__c,ListEmailSentMessageMaxId__c,  (SELECT inwise_Field__c,inwise_FieldId__c,Object_Type__c,Salesforce_Field__c FROM Mapping__r) FROM Account__c where Default__c= true limit 1];
  //                  if(!listOfInwiseAccount.isEmpty() && listOfInwiseAccount.get(0).Mapping__r.Size()>0){
  //                          objInwiseAccountTemp = listOfInwiseAccount.get(0);
  //                  }
                    
  //          }
  //      }    
  //      return objInwiseAccountTemp;
  //  }
  
  global void finish(Database.BatchableContext BC){
    //inwiseGlobalAction.doClearAll(objInwiseUtil.objInwiseSetting.Track_Logs__c);
    //if(!objInwiseUtil.objInwiseSetting.Track_Logs__c){
    //    inwiseGlobalAction.doClearLogs();
    //    inwiseGlobalAction.doClearSyncMaster();
    //}
  }
 
}