/******************************************************************************************
*Created By:  NLINEAXIS
*Created On: 07 December 2021
*Purpose :   Rest resource class to send sms to the contacts

Modification Log
----------------
Date                  Version     Developer                  Comments
------------------------------------------------------------------------------------
07/12/2021            1.1.0       NLINEAXIS(S. Vaishnav)     Created

/******************************************************************************************/
@RestResource(urlMapping='/smsservice/*')
global with sharing class SMSService {

    @HttpPost
	global static String doSendSMS(){
        RestRequest request = RestContext.request;
        
        String jsonString = request.requestBody.toString();
        System.debug(jsonString);
        //String jsonString = '{"contactid": "dtygzdfhfdgbg56", "smstext":"this is test sms"}';
        List<Logs__c> listOfLogs = new List<Logs__c>();
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);

        try {
            if(responseMap != null && responseMap.containsKey('contactid')){
                String conId = responseMap.get('contactid')+'';
                if(String.isNotBlank(conId)){
                    String smsText = responseMap.containsKey('smstext') ? responseMap.get('smstext')+'' : '';
                    sendSMSFuture(conId, smsText);
                }
            }
        }catch(Exception ex){
            System.debug(ex.getMessage()+'>>' + ex.getLineNumber());
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(jsonString, (ex.getMessage() + ex.getLineNumber()), '/smsservice', 'SMSService', 'Rest API call'));
        }
        if(!listOfLogs.isEmpty()){
            if(Logs__c.SObjectType.getDescribe().isCreateable()){
                insert listOfLogs;
            }
        }

        return null;
	}

    @future(callout=true)
    static void sendSMSFuture(String contactId, String smsText) {

        List<Contact> conLi = [Select Id,Description,MobilePhone From Contact Where Id =: contactId WITH SECURITY_ENFORCED];
        if(!conLi.isEmpty()){
            inwiseSendSMSLtngController.SendSMSAndCreateActivity(smsText, conLi[0].MobilePhone, conLi[0].Id);
        }
    }
}