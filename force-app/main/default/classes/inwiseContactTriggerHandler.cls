/******************************************************************************************
* Created by         :       Kapil Goutam
*Created On         :       08 Aug  2017
*Purpose:             :       Mark a recipient as Subscribe / unsubscribe to handle the trigger inwiseContactTrigger
* Logs
 * -------------------------------------------------------------
 * Name                      Date(MM/DD/YY)   Version         Description
 * Kapil Goutam(NLINEAXIS)   06/30/2020       1.1.0           added new fields for optput in custom setting & code for Toggle Email Opt-in/Opt-out & Toggle Mobile Opt-in/Opt-out section
 * Kapil Goutam(NLINEAXIS)   07/25/2020       1.1.1           Fix for email vs mobile, it was sending both even if one gets changed on UI
 * NLINEAXIS(Kapil Goutam)   06/20/2024       1.1.2          Modified:- Added changes for security check (added with sharing)
******************************************************************************************/
public  with sharing class inwiseContactTriggerHandler {
    public static String sCONST_RESUBSCRIBE = 'resubscribe';
    public static String sCONST_UNSUBSCRIBE = 'unsubscribe';
    static inwiseUtil objInwiseUtil;
    static{
        objInwiseUtil=new inwiseUtil(NULL);
    }
    public static void updateSubscription(list<Contact> conList,Map<Id,Contact> oldMap){
       List<Contact> listToUnSubscribe = new List<Contact>();
       List<Contact> listToCancelUnSubscribe = new List<Contact>();
       Map<Id,Boolean> mapOfContactForEmailProcess = new Map<Id,Boolean>();
       Map<Id,Boolean> mapOfContactForPhoneProcess = new Map<Id,Boolean>();
         for(Contact con:conList){
             if(objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out__c != null && con.get(objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out__c) != null
                      && con.get(objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out__c) != oldMap.get(con.Id).get(objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out__c)){
                 if(con.get(objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out__c) == true){
                     listToUnSubscribe.add(con);
                 }
                 if(con.get(objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out__c) == false) {
                     listToCancelUnSubscribe.add(con);
                 }
                 mapOfContactForEmailProcess.put(con.Id,true);

             }
             if(objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out__c != null && con.get(objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out__c) != null
                      && con.get(objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out__c) != oldMap.get(con.Id).get(objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out__c)){
                 if(con.get(objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out__c) == true){
                     listToUnSubscribe.add(con);
                 }
                 if(con.get(objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out__c) == false) {
                     listToCancelUnSubscribe.add(con);
                 }
                 mapOfContactForPhoneProcess.put(con.Id,true);

             }
         }
         if(!listToUnSubscribe.isEmpty()){
               doRecipientAction(listToUnSubscribe, sCONST_UNSUBSCRIBE,mapOfContactForEmailProcess,mapOfContactForPhoneProcess);
         }
         if(!listToCancelUnSubscribe.isEmpty()){
               doRecipientAction(listToCancelUnSubscribe, sCONST_RESUBSCRIBE,mapOfContactForEmailProcess,mapOfContactForPhoneProcess);
         }           
    }

    private static void doRecipientAction(List<Contact> listToUnSubscribe,String soapAction, Map<Id,Boolean> mapOfContactForEmailChanges, Map<Id,Boolean> mapOfContactForPhoneChanges){
        List<String> listOfEmails = new  List<String>();
        List<String> listOfMobiles = new  List<String>();
        List<Contact> listOfContacts = new  List<Contact>();
        if(Schema.sObjectType.Contact.isAccessible() ){
            String sSelect = '';
            if(objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out_Field__c != null) {
                if (Schema.sObjectType.Contact.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out_Field__c) &&
                    Schema.sObjectType.Contact.fields.getMap().get(objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out_Field__c).getDescribe().isAccessible()) {

                    sSelect += objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out_Field__c;
                }
            }

            if (Schema.sObjectType.Contact.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out_Field__c) &&
                Schema.sObjectType.Contact.fields.getMap().get(objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out_Field__c).getDescribe().isAccessible()) {
                if(objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out_Field__c != null){
                    if(sSelect != ''){
                        sSelect += ',';
                    }
                    sSelect += objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out_Field__c;

                }
            }
            String sQuery = 'SELECT Id,' + sSelect + ' FROM Contact where Id IN:listToUnSubscribe';
            listOfContacts = Database.query(sQuery);
        }
        
        for(Contact c:listOfContacts){
            if(objInwiseUtil.objInwiseSetting.Toggle_Email_Opt_in_Opt_out__c == true && objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out_Field__c != null && c.get(objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out_Field__c) != null && mapOfContactForEmailChanges.get(c.Id) == true){
                listOfEmails.add(String.valueOf(c.get(objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out_Field__c)));
            }
            if(objInwiseUtil.objInwiseSetting.Toggle_Mobile_Opt_in_Opt_out__c == true && objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out_Field__c != null && c.get(objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out_Field__c) != null && mapOfContactForPhoneChanges.get(c.Id) == true){
                listOfMobiles.add(String.valueOf(c.get(objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out_Field__c)));
            }
        }
        if(!listOfEmails.isEmpty() || !listOfMobiles.isEmpty()){
            doCalloutUnsubscribeOrCancel(listOfEmails, listOfMobiles, soapAction);
        }
       
    }
    @future (callout=true)
    public static void doCalloutUnsubscribeOrCancel(List<String> listOfEmails, List<String> listOfMobiles,  String restAPIAction){
         List<Logs__c> listOfLogs = new List<Logs__c>();
         InwiseUtil objInwiseUtil = new InwiseUtil(null);
         //String soapBody = '';
         HttpResponse res; 
         Http http = new Http();
         String endpoint = objInwiseUtil.apiUrl;
         endpoint +=  ('/rest/v1/contacts/' + restAPIAction); 
         HttpRequest req = objInwiseUtil.GetHTTPRequest('GET','application/json',endpoint); 
         req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);     
         req.setBody(getJSONBody(listOfEmails,listOfMobiles, restAPIAction, objInwiseUtil));
         if(!Test.isRunningTest()){
               res = http.send(req);   
               listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, ('/rest/v1/contacts/' + restAPIAction),'inwiseContactTriggerHandler','doCalloutUnsubscribeOrCancel'));               
         }else{
               String resBody = '{ "emails": [ { "email": "test101@domain.com", "status": "success" } ], "sms_mobile_numbers": [ { "sms_mobile_number": "string", "status": "invalid_mobile_number" } ] }';
               res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
         }
         System.debug('size list of logs::-->>' + listOfLogs.size());
         if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
             insert listOfLogs;
         }              

    }
    public static String getJSONBody(List<String> listOfEmails, List<String> listOfMobiles,  String restAPIAction, InwiseUtil objInwiseUtil){
       String jsonBody = '';
       Integer sz = 1;
       if(restAPIAction == sCONST_RESUBSCRIBE){
             jsonBody += '{';
                 jsonBody += '"emails": [';
                  for(String s: listOfEmails){
                     jsonBody += '"'+ s +'"' + (listOfEmails.size() == sz ? '':',');
                     sz++;
                  } 
                           
                 jsonBody += '],';
                 sz = 1;
                 jsonBody += '"sms_mobile_numbers": [';
                   for(String s: listOfMobiles){
                       jsonBody += '"'+ inwiseHttpUtil.getFormattedPhone(s,objInwiseUtil) +'"' + (listOfMobiles.size() == sz ? '':',');
                       sz++;
                   }
                 jsonBody += ']';
             jsonBody += '}';
       }else if(restAPIAction == sCONST_UNSUBSCRIBE){
           jsonBody += '{';
                         sz = 1;
                         jsonBody += '"emails": [';
                             for(String s: listOfEmails){
                                       jsonBody += '{';
                                             jsonBody +=  '"email": "'+ s +'",';
                                             jsonBody += '"remark": ""';
                                       jsonBody += '}' + (listOfEmails.size() == sz ? '':',');
                                       sz++;
                              }         
                         jsonBody += '],';
                         sz = 1;
                         jsonBody += '"sms_mobile_numbers": [';
                              for(String s: listOfMobiles) {
                                  jsonBody += '{';
                                      jsonBody += '"mobile_number": "'+ inwiseHttpUtil.getFormattedPhone(s, objInwiseUtil) +'",';
                                      jsonBody += '"remark": ""';
                                  jsonBody += '}' + (listOfMobiles.size() == sz ? '':',');
                              }
                         jsonBody += ']';
           jsonBody += '}';
       }
       return jsonBody;

    }

}