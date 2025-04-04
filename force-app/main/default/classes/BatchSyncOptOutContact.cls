/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 07 Feb 2018
*Purpose :    batch to unsubscribe all contacts from the org
/******************************************************************************************/
global with sharing class BatchSyncOptOutContact implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{ 
    List<Logs__c> listOfLogs{get;set;}
    InwiseUtil objInwiseUtil{get;set;}
    Account__c objInwiseAccount{get;set;}  
    global Database.QueryLocator start(Database.BatchableContext BC){
        // return Database.getQueryLocator([
        //       SELECT Id,Name,Email,HasOptedOutOfEmail,MobilePhone from Contact where HasOptedOutOfEmail = true and Email != NULL
        //   ]);    

        if (Schema.sObjectType.Contact.isAccessible() &&
            Schema.sObjectType.Contact.fields.Id.isAccessible() &&
            Schema.sObjectType.Contact.fields.Name.isAccessible() &&
            Schema.sObjectType.Contact.fields.Email.isAccessible() &&
            Schema.sObjectType.Contact.fields.HasOptedOutOfEmail.isAccessible() &&
            Schema.sObjectType.Contact.fields.MobilePhone.isAccessible() ) {

          // Perform the query
          return Database.getQueryLocator([
            SELECT Id,Name,Email,HasOptedOutOfEmail,MobilePhone from Contact where HasOptedOutOfEmail = true and Email != NULL
          ]);    

        } else {
            // Log or handle insufficient permissions
            System.debug('User does not have sufficient permissions to access the Contact object or the required fields.');
            return Database.getQueryLocator('SELECT Id FROM Contact WHERE Id = NULL');
        }
    }
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        Http http = new Http();
        HttpResponse res;
        HttpRequest req;
        List<Contact> listOfContact=  (List<Contact>) scope;
        try{
            String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contacts/unsubscribe'; 
            req = objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint); 
            req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);        
            req.setBody(getXMLOptOut(listOfContact));
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contacts/unsubscribe','BatchSyncOptOutContact','execute'));
            }else{
                //String resBody = '{"status": "complete"}';
                //res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
        }catch(Exception ex){
            String resBody = ex.getMessage();
            res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contacts/unsubscribe','BatchSyncOptOutContact','execute'));
            
        }
    }
    global void finish(Database.BatchableContext BC){
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        }
    }   
    public void init(InwiseUtil objInwiseUtilP){
        listOfLogs = new List<Logs__c>();
        objInwiseUtil = objInwiseUtilP;
    }
    public String getXMLOptOut(List<Contact> listOfContact){
       String xmlString = '';
       integer sz = 1;
       xmlString +=  '{';
        xmlString += '"emails":';
          xmlString += '[';
               if(!listOfContact.isEmpty()){
                    for(Contact c:listOfContact){
                        if(c.Email != null) {
                            xmlString += '{';
                            xmlString += '"email": "' + c.Email + '",';
                            xmlString += '"remark": "Salesforce opt out"';
                            xmlString += '}' + (sz == listOfContact.size() ? '' : ',');
                        }
                        sz++;
                    }
               }
          xmlString += '],';
        //xmlString += '},';
        sz = 1;
        //xmlString +=  '{';
        xmlString += '"sms_mobile_numbers":';
        xmlString += '[';
        if(!listOfContact.isEmpty()){
            for(Contact c:listOfContact){
                if(c.MobilePhone != null) {
                    xmlString += '{';
                    xmlString += '"mobile_number": "' + BatchCalloutUnsubscribe.reformatPhone(c.MobilePhone, objInwiseUtil) + '",';
                    xmlString += '"remark": "Salesforce opt out"';
                    xmlString += '}' + (sz == listOfContact.size() ? '' : ',');
                }
                sz++;
            }
        }
        xmlString += ']';
        xmlString += '}';
       return xmlString;
    } 

}