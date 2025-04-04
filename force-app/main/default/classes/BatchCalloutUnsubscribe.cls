/***********************************************************************************
* Name          :  BatchCalloutUnsubscribe

* Description   :  Batch for unsubscribe more than 10000 record. class created after BPM job issue.
                  
* Author        :  Kapil Goutam

Modification Log
----------------
Date               Version     Developer                  Comments
------------------------------------------------------------------------------------
07/29/2018        1.0.0       NLINEAXIS(K.Goutam)         Created
12/12/2019        1.1.0       NLINEAXIS(Kapil Goutam)     Modified:- added code to update email & Sms last run field in setting after jon execution.
02/20/2019        1.1.1       NLINEAXIS(Kapil Goutam)     Modified:- added code to  email & Sms last run field save in UTC time.
08/12/2020        1.1.2       NLINEAXIS(Kapil Goutam)     Modified:- Added two new buttons for unsubsuscribe email & mobile, fix issue to send same date time while multiple calls
09/14/2020        1.1.4       NLINEAXIS(Kapil Goutam)     Modified:- 4 new fields for search in lead/contact email/mobile & added code to search without hyphen in phone
10/20/2020        1.1.5       NLINEAXIS(Kapil Goutam)     Modified:- added logs in catch as this class is not executing for few clients.
11/24/2020        1.1.6       NLINEAXIS(Kapil Goutam)     Modified:- removed logs deletion logic as this was throwing too many DML rows exception for few end clients.
11/25/2020        1.1.7       NLINEAXIS(Kapil Goutam)     Modified:- removed dummy logs which is added for testing for a client failure
/***********************************************************************************/
global with sharing class BatchCalloutUnsubscribe implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{ 
    List<Logs__c> listOfLogs{get;set;}
    InwiseUtil objInwiseUtil{get;set;}
    Integer index{get;set;} 
    String channelType{get;set;}
    List<JSONToApexContactUnsubscribed> listOfJSONToApexContactUnsubscribed;
    integer rowlimitsetting{get;set;}
  
    Datetime dtNow{get;set;}
    Datetime lastDTUTC{get;set;}
    boolean isNeedToScheduleNextHour {get;set;}
    global void init(String chType, Integer indx,Boolean isNeedToReschedule, Datetime dtNowParam, Datetime lastDTUTCParam){
        listOfLogs = new List<Logs__c>();
        objInwiseUtil = new InwiseUtil(null);
        listOfJSONToApexContactUnsubscribed = new List<JSONToApexContactUnsubscribed>();
        rowlimitsetting = objInwiseUtil.objInwiseSetting != NULL && objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c != NULL ? Integer.valueOf(objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c) : 85;
  
        if(dtNowParam == null){
            dtNow = Datetime.newInstance(Datetime.now().dateGmt(), Datetime.now().timeGmt());
        }else{
            dtNow = dtNowParam;
        }
  
  
        index = indx;
        channelType = chType;
        isNeedToScheduleNextHour = isNeedToReschedule;
        if(lastDTUTCParam == null){
            DateTime lastRunOn;
            if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeEmail && objInwiseUtil.objInwiseSetting.Opt_in_Out_to_Salesforce_Email_Last_Run__c != NULL){
                lastRunOn = objInwiseUtil.objInwiseSetting.Opt_in_Out_to_Salesforce_Email_Last_Run__c;
            }else if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeSMS && objInwiseUtil.objInwiseSetting.Opt_in_Out_to_Salesforce_Mobile_Last_Run__c != NULL){
                lastRunOn = objInwiseUtil.objInwiseSetting.Opt_in_Out_to_Salesforce_Mobile_Last_Run__c;
            }
            System.debug('lastRunOn::-->>>' +lastRunOn);
            if(lastRunOn != null){
                lastDTUTC = Datetime.newInstanceGmt(lastRunOn.date(), lastRunOn.time());
            }
        }else{
            lastDTUTC = lastDTUTCParam;
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
      //start query is just to start job always
       
      // Check if the user has access to the User object and the required fields
        if (Schema.sObjectType.User.isAccessible() &&
            Schema.sObjectType.User.fields.Id.isAccessible() &&
            Schema.sObjectType.User.fields.Name.isAccessible()) {

            // Return the query locator
            return Database.getQueryLocator([
                SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1
            ]);
        } else {
            // Log or handle insufficient permissions
            System.debug('User does not have sufficient permissions to access the User object or the required fields.');
            // Return an empty query locator as a fallback
            return Database.getQueryLocator('SELECT Id FROM User WHERE Id = NULL');
        }
    }
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        doCalloutUnsubscribe();
    }
    global void finish(Database.BatchableContext BC){
      if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
              insert listOfLogs;
      }
       //commented this on 24 November 2020 as this was throwing issue for big customers.
      //inwiseGlobalAction.doClearAll(objInwiseUtil.objInwiseSetting.Track_Logs__c);
      System.debug('call again doCalloutUnsubscribe::-->>>' +index + '>>>' + listOfJSONToApexContactUnsubscribed + '>>>>' +  rowlimitsetting);
      if(listOfJSONToApexContactUnsubscribed != NULL && listOfJSONToApexContactUnsubscribed.size() == rowlimitsetting){
          ++index;
          BatchCalloutUnsubscribe objBatchCalloutUnsubscribe = new BatchCalloutUnsubscribe ();
          objBatchCalloutUnsubscribe.init(channelType,index,isNeedToScheduleNextHour,dtNow, lastDTUTC);
          Database.executeBatch(objBatchCalloutUnsubscribe,1);
      }  
      
      Settings__c objInwiseSetting = Settings__c.getAll().get('default');
      if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeEmail){
            if(!String.isEmpty(objInwiseSetting.Opt_in_Out_to_Salesforce_Email_Job_Id__c)){
                try{
                        System.abortJob(objInwiseSetting.Opt_in_Out_to_Salesforce_Email_Job_Id__c);
                        if(Schema.sObjectType.Settings__c.fields.Opt_in_Out_to_Salesforce_Email_Job_Id__c.isUpdateable()){
                            objInwiseSetting.Opt_in_Out_to_Salesforce_Email_Job_Id__c = NULL;
                      }
                  }catch(Exception ex){
                        System.debug('abort failed::-->>>' + ex.getMessage());
                  }
            }
  
       }else if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeSMS){     
            if(!String.isEmpty(objInwiseSetting.Opt_in_Out_to_Salesforce_Mobile_Job_Id__c)){
                try{
                        System.abortJob(objInwiseSetting.Opt_in_Out_to_Salesforce_Mobile_Job_Id__c);
                        if(Schema.sObjectType.Settings__c.fields.Opt_in_Out_to_Salesforce_Mobile_Job_Id__c.isUpdateable()){
                          objInwiseSetting.Opt_in_Out_to_Salesforce_Mobile_Job_Id__c = NULL;
                        }
                  }catch(Exception ex){
                        System.debug('abort failed::-->>>' + ex.getMessage());
                  }
            }
  
       }     
        update objInwiseSetting;
    }
    /**other methods copied from previous schedulable classes **/
     public void doCalloutUnsubscribe(){
            Http http = new Http();
            HttpResponse res;
            String endpoint = getEnpoint('/rest/v1/contacts/listUnsubscribed', index,dtNow,channelType,objInwiseUtil,lastDTUTC);
            //System.debug('endpoint::-->>>' + endpoint);
            HttpRequest req = objInwiseUtil.GetHTTPRequest('GET','application/json',endpoint); 
            req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);     
            try{
                if(!Test.isRunningTest()){
                    res = http.send(req);
                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contacts/contacts_listUnsubscribed','ScheduleContactslistUnsubscribed','doCalloutUnsubscribe'));                 
                }else{
                    String resBody = '[{ "id": 22634427, "target": "barr_tim@grandhotels.com", "contact_id": null, "reason": "manually", "timestamp": "2018-02-09 06:48:00"},{ "id": 22645899, "target": "test101@domain.com", "contact_id": null, "reason": "manually", "timestamp": "2018-02-20 09:04:00"},{ "id": 22646373, "target": "kkml@sdfg.com", "contact_id": null, "reason": "manually", "timestamp": "2018-02-20 15:01:00"},{ "id": 22646374, "target": "email@email.com", "contact_id": null, "reason": "manually", "timestamp": "2018-02-20 15:01:00"},{ "id": 22646375, "target": "boaz1912@gmail.com", "contact_id": null, "reason": "manually", "timestamp": "2018-02-20 15:01:00"},{ "id": 22646376, "target": "boaz3333@gmail.com", "contact_id": null, "reason": "manually", "timestamp": "2018-02-20 15:01:00"},{ "id": 22646377, "target": "ddyynn170209@gmail.com", "contact_id": null, "reason": "manually", "timestamp": "2018-02-20 15:01:00"},{ "id": 22646378, "target": "boaz20170113@yahoo.com", "contact_id": null, "reason": "manually", "timestamp": "2018-02-20 15:01:00"},{ "id": 22646379, "target": "boaz20170213_3@yahoo.com", "contact_id": null, "reason": "manually", "timestamp": "2018-02-20 15:01:00"},{ "id": 22646380, "target": "boaz20170213_4@yahoo.com", "contact_id": null, "reason": "manually", "timestamp": "2018-02-20 15:01:00"} ]';
                    res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'text/xml');
                }
                
                if(res != NULL && res.getStatusCode() == 200 && res.getBody() != NULL){
                    System.debug('res::-->>' + res + '>>>>' + res.getBody());    
                    listOfJSONToApexContactUnsubscribed = (List<JSONToApexContactUnsubscribed>) System.JSON.deserialize(res.getBody(), List<JSONToApexContactUnsubscribed>.class);
                    System.debug('listOfJSONToApexContactUnsubscribed::-->>' + listOfJSONToApexContactUnsubscribed);
                    System.debug('rowlimitsetting::-->>' + rowlimitsetting);
                    if(listOfJSONToApexContactUnsubscribed != NULL && !listOfJSONToApexContactUnsubscribed.isEmpty()){
                        doUpdateContactLead(listOfJSONToApexContactUnsubscribed, channelType,objInwiseUtil);
                    }
                }
                if(objInwiseUtil.objInwiseSetting != null && index == 1){
                  Integer offset = UserInfo.getTimezone().getOffset(dtNow);
                    Settings__c objInwiseSetting = new Settings__c(Id=objInwiseUtil.objInwiseSetting.Id);
                    if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeEmail){
                        if(Schema.sObjectType.Settings__c.fields.Opt_in_Out_to_Salesforce_Email_Last_Run__c.isUpdateable()){
                            objInwiseSetting.Opt_in_Out_to_Salesforce_Email_Last_Run__c = dtNow.addSeconds(offset/1000);
                        }
                    }else if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeSMS){
                        if(Schema.sObjectType.Settings__c.fields.Opt_in_Out_to_Salesforce_Mobile_Last_Run__c.isUpdateable()){
                            objInwiseSetting.Opt_in_Out_to_Salesforce_Mobile_Last_Run__c = dtNow.addSeconds(offset/1000);
                        }
                    }
  
                    if(Schema.sObjectType.Settings__c.isUpdateable()){
                        update objInwiseSetting;
                        //System.debug('custom setting updated:--->>'+ objInwiseSetting);
                    }
                }
            }catch(Exception ex){
                //ErrorMsg = 'Exception Occured!'; 
                System.debug('Exception in BatchCalloutUnsubscribe::-->>>' + ex.getMessage());
                //System.debug('Exception in BatchCalloutUnsubscribe::-->>>' + ex.getMessage());
                String resBody = ex.getMessage();
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contacts/listUnsubscribed','BatchCalloutUnsubscribe','execute'));
            }
           
      }
      public static void doUpdateContactLead(List<JSONToApexContactUnsubscribed> listOfJSONToApexContactUnsubscribed, String channelType,InwiseUtil objInwiseUtil){
          List<Contact> listOfContactToUpdate = new List<Contact>();
          List<Lead> listOfLeadToUpdate = new List<Lead>();
          Contact objContact;
          Lead objLead;
          Set<String> setOfEmail = new Set<String>();
          Set<String> setOfMobile = new Set<String>();
          String fieldApiContact, fieldApiLead;
          Boolean isValidField;
          String formattedPhone;
          System.debug('listOfJSONToApexContactUnsubscribed::-->>>' + listOfJSONToApexContactUnsubscribed);
          if(objInwiseUtil.objInwiseSetting != NULL){
              if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeEmail){
                    fieldApiContact = objInwiseUtil.objInwiseSetting.Email_Unsubscribe_Contact_Field__c; 
                    fieldApiLead = objInwiseUtil.objInwiseSetting.Email_Unsubscribe_Lead_Field__c; 
                    isValidField = isValidsObjectField(fieldApiContact, inwiseConstants.SOBJECT_CONTACT);
                    if(isValidField == false){
                        fieldApiContact = NULL;
                    }
                    isValidField = isValidsObjectField(fieldApiLead, inwiseConstants.SOBJECT_LEAD);
                    if(isValidField == false){
                        fieldApiLead = NULL;
                    }
              }else if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeSMS){
                    fieldApiContact = objInwiseUtil.objInwiseSetting.Mobile_Unsubscribe_Contact_Field__c; 
                    fieldApiLead = objInwiseUtil.objInwiseSetting.Mobile_Unsubscribe_Lead_Field__c; 
                    isValidField = isValidsObjectField(fieldApiContact, inwiseConstants.SOBJECT_CONTACT);
                     if(isValidField == false){
                        fieldApiContact = NULL;
                    }
                    isValidField = isValidsObjectField(fieldApiLead, inwiseConstants.SOBJECT_LEAD);
                    if(isValidField == false){
                        fieldApiLead = NULL;
                    }
              }
          }
          
          if(!listOfJSONToApexContactUnsubscribed.isEmpty()){
                for(JSONToApexContactUnsubscribed j:listOfJSONToApexContactUnsubscribed){
                    if(j.target != NULL){
                        if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeEmail){
                              setOfEmail.add(j.target); 
                         }else if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeSMS){ 
                              formattedPhone = reformatPhone(j.target,objInwiseUtil);
                             system.debug('formatted phone'+formattedPhone);
                              setOfMobile.add(formattedPhone);
                              if(formattedPhone.contains('-')){
                                  String formattedPhoneWithoutHyphen = formattedPhone.replace('-','');
                                  setOfMobile.add(formattedPhoneWithoutHyphen);
                              }
                         }  
                    }
                }
          }  
          System.debug('setOfEmail::--->>>'+  setOfEmail);
          System.debug('setOfMobile::--->>>' +  setOfMobile);
          System.debug('fieldApiContact::--->>>' +  fieldApiContact);
          System.debug('objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c::--->>>' +  objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c);
          //System.debug('channelType::--->>>'+  channelType +'=ScheduleContactslistUnsubscribed.sChanelTypeEmail='+ScheduleContactslistUnsubscribed.sChanelTypeEmail);
          if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeEmail){
                if(!setOfEmail.isEmpty() && fieldApiContact != NULL && objInwiseUtil.objInwiseSetting != null && objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c != null){
                    //String cquery =  'Select Id,Name from Contact where '+ objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c +' IN:setOfEmail';
                    //System.debug('cquery::--->>>' +  cquery);
                    //List<Contact> listOfContact = Database.query(cquery);
                    List<Contact> listOfContact = new List<Contact>();
                    if (Schema.sObjectType.Contact.isAccessible() &&
                        Schema.sObjectType.Contact.fields.Id.isAccessible() &&
                        Schema.sObjectType.Contact.fields.Name.isAccessible() &&
                        Schema.sObjectType.Contact.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c) &&
                        Schema.sObjectType.Contact.fields.getMap().get(objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c).getDescribe().isAccessible()) {

                        String cquery =  'Select Id,Name from Contact where '+ objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c +' IN:setOfEmail';
                        // Execute the query
                        listOfContact = Database.query(cquery);

                    } else {
                        System.debug('User does not have sufficient permissions to access the Contact object or fields.');
                        // Handle the case where permissions are insufficient
                    }
                    System.debug('listOfContact::--->>>' +  listOfContact);
                    if(!listOfContact.isEmpty()){
                        for(Contact c:listOfContact){
                            objContact = new Contact(Id=c.id);
                            objContact.put(fieldApiContact,true);
                            listOfContactToUpdate.add(objContact);
                        }
                    }
                }
  
                if(!setOfEmail.isEmpty() && fieldApiLead != NULL && objInwiseUtil.objInwiseSetting != null && objInwiseUtil.objInwiseSetting.Lead_Email_Search_Field__c != null){
                    //String lquery =  'Select Id,Name from Lead where '+ objInwiseUtil.objInwiseSetting.Lead_Email_Search_Field__c +' IN:setOfEmail';
                    //List<Lead> listOfLead = Database.query(lquery);
                    List<Lead> listOfLead = new List<Lead>();
                    if (Schema.sObjectType.Lead.isAccessible() &&
                        Schema.sObjectType.Lead.fields.Id.isAccessible() &&
                        Schema.sObjectType.Lead.fields.Name.isAccessible() &&
                        Schema.sObjectType.Lead.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Lead_Email_Search_Field__c) &&
                        Schema.sObjectType.Lead.fields.getMap().get(objInwiseUtil.objInwiseSetting.Lead_Email_Search_Field__c).getDescribe().isAccessible()) {

                        String lquery =  'Select Id,Name from Lead where '+ objInwiseUtil.objInwiseSetting.Lead_Email_Search_Field__c +' IN:setOfEmail';
                        // Execute the query
                        listOfLead = Database.query(lquery);

                    } else {
                        System.debug('User does not have sufficient permissions to access the Lead object or fields.');
                        // Handle the case where permissions are insufficient
                    }
                    if(!listOfLead.isEmpty()){
                        for(Lead c:listOfLead){
                            objLead = new Lead(Id=c.id);
                            objLead.put(fieldApiLead,true);
                            listOfLeadToUpdate.add(objLead);
                        }
                    }
                }
          }else if(channelType == ScheduleContactslistUnsubscribed.sChanelTypeSMS){ 
               if(!setOfMobile.isEmpty() && fieldApiContact != NULL && objInwiseUtil.objInwiseSetting != null && objInwiseUtil.objInwiseSetting.Contact_Mobile_Search_Field__c != null){
                    //String cquery =  'Select Id,Name from Contact where '+ objInwiseUtil.objInwiseSetting.Contact_Mobile_Search_Field__c +' IN:setOfMobile';
                    //List<Contact> listOfContact = Database.query(cquery);
                 
                    List<Contact> listOfContact = new List<Contact>();
                    if (Schema.sObjectType.Contact.isAccessible() &&
                        Schema.sObjectType.Contact.fields.Id.isAccessible() &&
                        Schema.sObjectType.Contact.fields.Name.isAccessible() &&
                        Schema.sObjectType.Contact.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Contact_Mobile_Search_Field__c) &&
                        Schema.sObjectType.Contact.fields.getMap().get(objInwiseUtil.objInwiseSetting.Contact_Mobile_Search_Field__c).getDescribe().isAccessible()) {

                        String cquery =  'Select Id,Name from Contact where '+ objInwiseUtil.objInwiseSetting.Contact_Mobile_Search_Field__c +' IN:setOfMobile';
                        // Execute the query
                        listOfContact = Database.query(cquery);

                    } else {
                        System.debug('User does not have sufficient permissions to access the Contact object or fields.');
                        // Handle the case where permissions are insufficient
                    }

                    if(!listOfContact.isEmpty()){
                        for(Contact c:listOfContact){
                            objContact = new Contact(Id=c.id);
                            objContact.put(fieldApiContact,true);
                            listOfContactToUpdate.add(objContact);
                        }
                    }
                }
  
                if(!setOfMobile.isEmpty() && fieldApiLead != NULL && objInwiseUtil.objInwiseSetting != null && objInwiseUtil.objInwiseSetting.Lead_Mobile_Search_Field__c != null){
                    //String lquery =  'Select Id,Name from Lead where '+ objInwiseUtil.objInwiseSetting.Lead_Mobile_Search_Field__c +' IN:setOfMobile';
                    //List<Lead> listOfLead = Database.query(lquery);
                    List<Lead> listOfLead = new List<Lead>();
                    if (Schema.sObjectType.Lead.isAccessible() &&
                        Schema.sObjectType.Lead.fields.Id.isAccessible() &&
                        Schema.sObjectType.Lead.fields.Name.isAccessible() &&
                        Schema.sObjectType.Lead.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Lead_Mobile_Search_Field__c) &&
                        Schema.sObjectType.Lead.fields.getMap().get(objInwiseUtil.objInwiseSetting.Lead_Mobile_Search_Field__c).getDescribe().isAccessible()) {

                        String lquery =  'Select Id,Name from Lead where '+ objInwiseUtil.objInwiseSetting.Lead_Mobile_Search_Field__c +' IN:setOfMobile';
                        // Execute the query
                        listOfLead = Database.query(lquery);

                    } else {
                        System.debug('User does not have sufficient permissions to access the Lead object or fields.');
                        // Handle the case where permissions are insufficient
                    }
                    if(!listOfLead.isEmpty()){
                        for(Lead c:listOfLead){
                            objLead = new Lead(Id=c.id);
                            objLead.put(fieldApiLead,true);
                            listOfLeadToUpdate.add(objLead);
                        }
                    }
                }
          }
          
          System.debug('listOfContactToUpdate::-->>' + listOfContactToUpdate);
          if(!listOfContactToUpdate.isEmpty()){
              ExecutionManager.isNeedToByPass_ContactTrigger = true;
              update listOfContactToUpdate;
              ExecutionManager.isNeedToByPass_ContactTrigger = false;
          }
  
          System.debug('listOfLeadToUpdate::-->>' + listOfLeadToUpdate);
          if(!listOfLeadToUpdate.isEmpty()){
              ExecutionManager.isNeedToByPass_LeadTrigger = true;
              update listOfLeadToUpdate;
              ExecutionManager.isNeedToByPass_LeadTrigger = false;
          }
      }
      public static String reformatPhone(String phoneno, InwiseUtil objInwiseUtil){
          String formattedphone = phoneno;
          Map<String,String> mapOfCountryCode = inwiseHttpUtil.getCountryCodeMap();
          if(phoneno != NULL && !String.isEmpty(phoneno)){
                if(objInwiseUtil.objInwiseAccount.Country__c != NULL && mapOfCountryCode.get(objInwiseUtil.objInwiseAccount.Country__c) != NULL){
                      String countrycodetemp = mapOfCountryCode.get(objInwiseUtil.objInwiseAccount.Country__c);
                      String phone2Temp  = phoneno.substring(0, countrycodetemp.length());
                      if(phone2Temp != NULL && phone2Temp == countrycodetemp){
                              formattedphone = phoneno.replaceFirst(countrycodetemp, '');
                      }
                }
                if(objInwiseUtil.objInwiseAccount.Trim_Leading_Zero__c != NULL &&  objInwiseUtil.objInwiseAccount.Trim_Leading_Zero__c == true){
                      formattedphone = '0' + formattedphone;
                }
                
            }
          if(formattedphone != NULL){
                formattedphone = formattedphone.replaceFirst('-', '');
          }
          return formattedphone;
      }
    // public static boolean isValidsObjectField(String fieldapi, String sobjectname){
    //     boolean isValidField = false;
    //     String qry = 'SELECT Id, ' + fieldapi + ' FROM ' + sobjectname + ' LIMIT 1';
    //     try{
    //         Database.query(qry);
    //         isValidField = true;
    //     }catch(Exception ex){
    //         isValidField = false;
    //     }
    //     return isValidField;  
    // }

    public static boolean isValidsObjectField(String fieldapi, String sobjectname) {
        boolean isValidField = false;
    
        // Check if the object is accessible
        if (!Schema.getGlobalDescribe().containsKey(sobjectname)) {
            return false; // Object does not exist
        }
    
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(sobjectname).getDescribe();
        if (!objDescribe.isAccessible()) {
            return false; // Object is not accessible
        }
    
        // Check if the field is accessible
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        if (!fieldMap.containsKey(fieldapi)) {
            return false; // Field does not exist
        }
    
        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldapi).getDescribe();
        if (!fieldDescribe.isAccessible()) {
            return false; // Field is not accessible
        }
    
        // If both object and field are accessible, execute the query
        String qry = 'SELECT Id, ' + fieldapi + ' FROM ' + sobjectname + ' LIMIT 1';
        try {
            Database.query(qry);
            isValidField = true;
        } catch (Exception ex) {
            isValidField = false; // Query failed, likely due to an invalid field or other issue
        }
        return isValidField;
    }
  
    public static String getEnpoint(String apiURL, Integer index,Datetime dtNow, String channelType, InwiseUtil objInwiseUtil,DateTime lastRunOn){
          String endpoint = objInwiseUtil.apiUrl + apiURL + '?channel_type=' + channelType ; 
          integer rowlimitsetting = objInwiseUtil.objInwiseSetting != NULL && objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c != NULL ? Integer.valueOf(objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c) : 85;
  
          if(lastRunOn != NULL){
              Datetime lastRunUTC =  Datetime.newInstance(lastRunOn.dateGmt(), lastRunOn.timeGmt());
              endpoint += '&unsubscribe_date_from=' + EncodingUtil.urlEncode(lastRunUTC.formatGMT('yyyy-MM-dd HH:mm:ss'),'UTF-8') + '&unsubscribe_date_to=' + EncodingUtil.urlEncode(dtNow.format('yyyy-MM-dd HH:mm:ss'),'UTF-8') + '&limit=' + rowlimitsetting + '&page_index=' + index;
          }else{
              endpoint += '&unsubscribe_date_from=' + EncodingUtil.urlEncode(dtNow.addDays(-1).format('yyyy-MM-dd HH:mm:ss'),'UTF-8') + '&unsubscribe_date_to=' + EncodingUtil.urlEncode(dtNow.format('yyyy-MM-dd HH:mm:ss'),'UTF-8') + '&limit=' + rowlimitsetting+ '&page_index=' + index;
          }
          return endpoint;     
      }
  
       public class JSONToApexContactUnsubscribed {
            public Integer id{get;set;}
            public String target{get;set;}
            public String contact_id{get;set;}
            public String reason{get;set;}
            public String timestamp{get;set;}
      }
  }