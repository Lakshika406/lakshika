/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 07 Feb 2018
*Purpose :    batch to unsubscribe all lead & Lead from the org
/******************************************************************************************/
global with sharing class BatchSyncOptOutLead implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{ 
    List<Logs__c> listOfLogs{get;set;}
    InwiseUtil objInwiseUtil{get;set;}
    Account__c objInwiseAccount{get;set;}  
    global Database.QueryLocator start(Database.BatchableContext BC){
        //   return Database.getQueryLocator([
        //       SELECT Id,Name,Email,HasOptedOutOfEmail,MobilePhone from Lead where HasOptedOutOfEmail = true and Email  != NULL
        //   ]);  

        if (Schema.sObjectType.Lead.isAccessible() &&
            Schema.sObjectType.Lead.fields.Id.isAccessible() &&
            Schema.sObjectType.Lead.fields.Name.isAccessible() &&
            Schema.sObjectType.Lead.fields.Email.isAccessible() &&
            Schema.sObjectType.Lead.fields.HasOptedOutOfEmail.isAccessible() &&
            Schema.sObjectType.Lead.fields.MobilePhone.isAccessible() ) {

            // Perform the query
            return Database.getQueryLocator([
                SELECT Id,Name,Email,HasOptedOutOfEmail,MobilePhone from Lead where HasOptedOutOfEmail = true and Email != NULL
            ]);    

        } else {
            // Log or handle insufficient permissions
            System.debug('User does not have sufficient permissions to access the Lead object or the required fields.');
            return Database.getQueryLocator('SELECT Id FROM Lead WHERE Id = NULL');
        }
    }
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        Http http = new Http();
        HttpResponse res;
        HttpRequest req;
        List<Lead> listOfLead=  (List<Lead>) scope;
        try{
            String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contacts/unsubscribe'; 
            req = objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint); 
            req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);        
            req.setBody(getXMLOptOut(listOfLead));
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contacts/unsubscribe','BatchSyncOptOutLead','execute'));
            }else{
                //String resBody = '{"status": "complete"}';
                //res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
        }catch(Exception ex){
            String resBody = ex.getMessage();
            res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contacts/unsubscribe','BatchSyncOptOutLead','execute'));
            
        }
    }
    global void finish(Database.BatchableContext BC){
        //System.debug('objInwiseUtil::-->>>' + objInwiseUtil);
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        }
    }    
    public void init(InwiseUtil objInwiseUtilP){
        listOfLogs = new List<Logs__c>();
        objInwiseUtil = objInwiseUtilP;
    }
    public String getXMLOptOut(List<Lead> listOfLead){
       String xmlString = '';
       integer sz = 1;
       xmlString +=  '{';
        xmlString += '"emails":';
          xmlString += '[';
           if(!listOfLead.isEmpty()){
                for(Lead l:listOfLead){
                    if(l.Email != null){
                        xmlString +=  '{';
                        xmlString += '"email": "'+ l.Email +'",';
                        xmlString += '"remark": "Salesforce opt out"';
                        xmlString +=  '}' + (sz == listOfLead.size() ? '':',');
                    }

                    sz++;
                }
           }
          xmlString += '],';
      // xmlString += '}';
        sz = 1;
       // xmlString +=  '{';
        xmlString += '"sms_mobile_numbers":';
        xmlString += '[';
        if(!listOfLead.isEmpty()){
            for(Lead l:listOfLead){
                if(l.MobilePhone != null){
                    xmlString +=  '{';
                    xmlString += '"mobile_number": "'+ BatchCalloutUnsubscribe.reformatPhone(l.MobilePhone, objInwiseUtil) +'",';
                    xmlString += '"remark": "Salesforce opt out"';
                    xmlString +=  '}' + (sz == listOfLead.size() ? '':',');
                }

                sz++;
            }
        }
        xmlString += ']';
        xmlString += '}';
       return xmlString;
    } 
}