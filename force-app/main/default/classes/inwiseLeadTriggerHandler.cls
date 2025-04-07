/******************************************************************************************
* Created by         :       Kapil Goutam
*Created On         :       11 Aug  2017
*Purpose:             :       Mark a recipient as Subscribe / unsubscribe
* Logs
* -----------------------------------------
* Logs
 * -------------------------------------------------------------
 * Name                      Date(MM/DD/YY)   Version         Description
 * Kapil Goutam(NLINEAXIS)   06/30/2020       1.1.0           added new fields for optput in custom setting & code for Toggle Email Opt-in/Opt-out & Toggle Mobile Opt-in/Opt-out section
 * Kapil Goutam(NLINEAXIS)   07/25/2020       1.1.1           Fix for email vs mobile, it was sending both even if one gets changed on UI
******************************************************************************************/
public with sharing class inwiseLeadTriggerHandler {
    static inwiseUtil objInwiseUtil;
    static{
         objInwiseUtil=new inwiseUtil(NULL);
     }
    public static void updateSubscription(list<Lead> listOfLead,Map<Id,Lead> oldMap){
    
            List<Lead> listToUnSubscribe = new List<Lead>();
            List<Lead> listToCancelUnSubscribe = new List<Lead>();
            Map<Id,Boolean> mapOfLeadForEmailProcess = new Map<Id,Boolean>();
            Map<Id,Boolean> mapOfLeadForPhoneProcess = new Map<Id,Boolean>();

            for(Lead l:listOfLead){
                
                  if(objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out__c != null && l.get(objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out__c) != null
                       && l.get(objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out__c) != oldMap.get(l.Id).get(objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out__c)){
                      if(l.get(objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out__c) == true){
                          listToUnSubscribe.add(l);
                      }
                      if(l.get(objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out__c) == false) {
                          listToCancelUnSubscribe.add(l);
                      }
                      mapOfLeadForEmailProcess.put(l.Id,true);
                  }

                  if(objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out__c != null && l.get(objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out__c) != null
                       && l.get(objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out__c) != oldMap.get(l.Id).get(objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out__c)){
                      if(l.get(objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out__c) == true){
                          listToUnSubscribe.add(l);
                      }
                      if(l.get(objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out__c) == false) {
                          listToCancelUnSubscribe.add(l);
                      }
                      mapOfLeadForPhoneProcess.put(l.Id,true);
                  }
                  System.debug('listToUnSubscribe::-->>' + listToUnSubscribe);
                  System.debug('listToUnSubscribe::-->>' + listToCancelUnSubscribe);
            }
            if(!listToUnSubscribe.isEmpty()){
                    doRecipientAction(listToUnSubscribe, inwiseContactTriggerHandler.sCONST_UNSUBSCRIBE,mapOfLeadForEmailProcess,mapOfLeadForPhoneProcess);
            }
            if(!listToCancelUnSubscribe.isEmpty()){
                    doRecipientAction(listToCancelUnSubscribe, inwiseContactTriggerHandler.sCONST_RESUBSCRIBE,mapOfLeadForEmailProcess,mapOfLeadForPhoneProcess);
            }           
     }

     private static void doRecipientAction(List<Lead> listToUnSubscribe,String soapAction,Map<Id,Boolean> mapOfLeadForEmailChanges, Map<Id,Boolean> mapOfLeadForPhoneChanges){
        List<String> listOfEmails = new  List<String>();
        List<String> listOfMobiles = new  List<String>();
        List<Lead> listOfLeads = new  List<Lead>();
        if(Schema.sObjectType.Lead.isAccessible() ){
            String sSelect = '';
            if(objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out_Field__c != null) {
                if (Schema.sObjectType.Lead.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out_Field__c) &&
                    Schema.sObjectType.Lead.fields.getMap().get(objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out_Field__c).getDescribe().isAccessible()) {

                    sSelect += objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out_Field__c;
                }
            }

            if (Schema.sObjectType.Lead.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out_Field__c) &&
                Schema.sObjectType.Lead.fields.getMap().get(objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out_Field__c).getDescribe().isAccessible()) {

                if(objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out_Field__c != null){
                    if(sSelect != ''){
                        sSelect += ',';
                    }
                    sSelect += objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out_Field__c;
                }
            }

            String sQuery = 'SELECT Id,' + sSelect + ' FROM Lead where Id IN:listToUnSubscribe';
            listOfLeads = Database.query(sQuery);
            System.debug('listOfLeads::-->>>>' + listOfLeads);
        }
        
        for(Lead l:listOfLeads){
            if(objInwiseUtil.objInwiseSetting.Toggle_Email_Opt_in_Opt_out__c == true && objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out_Field__c != null && l.get(objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out_Field__c) != null && mapOfLeadForEmailChanges.get(l.Id) == true){
                listOfEmails.add(String.valueOf(l.get(objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out_Field__c)));
            }
            if(objInwiseUtil.objInwiseSetting.Toggle_Mobile_Opt_in_Opt_out__c == true && objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out_Field__c != null && l.get(objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out_Field__c) != null && mapOfLeadForPhoneChanges.get(l.Id) == true){
                listOfMobiles.add(String.valueOf(l.get(objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out_Field__c)));
            }
        }
        if(!listOfEmails.isEmpty() || !listOfMobiles.isEmpty()){
                inwiseContactTriggerHandler.doCalloutUnsubscribeOrCancel(listOfEmails, listOfMobiles, soapAction);
        }
     }
}