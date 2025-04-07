/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 02 Mar 2019
*Purpose :  To fix apex heap size issue while executing previous batch
* * -----------------------------------------------------
* Modified On       Modified By     Purpose
* 08/17/2019        Kapil Goutam    Added functionality to execute statistics function for a campaign as well.
* 11/03/2021        S. Vaishnav     Modified:- Send list of Members_Action__c in doInwiseMembersActionsONLYForSENT method
* 11/08/2021        S. Vaishnav     Modified:- Variable rowlimitsetting deleted from the doInwiseMembersActionsONLYForSENT method
* 11/09/2021        S. Vaishnav     Modified:- some parameter removed from the doInwiseMembersActionsONLYForSENT method to fix the bulkify security error
* 01/03/2022        Kapil Goutam    Modified:- To fix source scanner report bulkify issues
* 05/05/2023        Kapil Goutam    Modified:- To fix source scanner report bulkify issues (Removed soql query from loop)
/******************************************************************************************/
global with sharing class BatchCampaignMemberActionStep2 implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    Integer index{get;set;}
    InwiseUtil objInwiseUtil{get;set;}
    public Id memberActionId{get;set;}//if this parameter is coming means this campaign need to process, otherwise pick next one
    List<SendToInwiseController.JSON2ApexWrapperInwisemembersActionsSENT> listOfCampaignMembersJsonSENT{get;set;}
    public boolean isNeedToScheduleNextHour {get;set;}
    
    public void init(Integer indx, Id ma, Boolean isNextHour){
        objInwiseUtil = new InwiseUtil(null);
        index = indx;
        memberActionId = ma;
        isNeedToScheduleNextHour = isNextHour;
        listOfCampaignMembersJsonSENT = new List<SendToInwiseController.JSON2ApexWrapperInwisemembersActionsSENT>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,Name, Campaign__c, Execution_Date_Time__c,From_Date__c, Campaign__r.Campaign_Type__c, Campaign__r.Sendid__c, Account_Token__c, Campaign__r.Account__c FROM Members_Action__c Where Id =: memberActionId WITH SECURITY_ENFORCED LIMIT 1]);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        List<Members_Action__c> listOfMemberAction = (List<Members_Action__c>)scope;
        
        if(!listOfMemberAction.isEmpty()){
            
            doInwiseMembersActionsONLYForSENT( listOfMemberAction);
            
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
        Integer rowlimitsetting = objInwiseUtil.objInwiseSetting != NULL && objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c != NULL ? Integer.valueOf(objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c) : 85;
        if(listOfCampaignMembersJsonSENT != NULL && listOfCampaignMembersJsonSENT.size() == rowlimitsetting){
            //call again with next index
            BatchCampaignMemberActionStep2 objBatchCampaignMemberActionStep2 = new BatchCampaignMemberActionStep2();
            objBatchCampaignMemberActionStep2.init(++index,memberActionId,isNeedToScheduleNextHour);
            Database.executeBatch(objBatchCampaignMemberActionStep2,1);
        }else{
            BatchCampaignMemberActionStep3 objBatchCampaignMemberActionStep3 = new BatchCampaignMemberActionStep3();
            objBatchCampaignMemberActionStep3.init(memberActionId,isNeedToScheduleNextHour, 'Sent');
            Database.executeBatch(objBatchCampaignMemberActionStep3,1);// means in once block there are 250 records & it would be 250*20 = 8750
        }
    }
    
    public void doInwiseMembersActionsONLYForSENT( List<Members_Action__c> listOfMemberAction){
        
        set<Id> campaignIds = new set<Id>();
        Map<Id,List<CampaignMember>> mapOfCampaignMember = new Map<Id,List<CampaignMember>>();
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        //Members_Action__c action = listOfMemberAction[0];
        //if(action.Campaign__c != null){
            //campaignIds.add(action.Campaign__c);
        //}
        
        for(Members_Action__c action : listOfMemberAction){
            if(action.Campaign__c != null){
        		campaignIds.add(action.Campaign__c);
            }
        }
        
        if(!campaignIds.isEmpty()){
            campaignMemberList = [SELECT Id,ContactId, LeadId,CampaignId  FROM CampaignMember where CampaignId IN:campaignIds WITH SECURITY_ENFORCED];
        }
        if(!campaignMemberList.isEmpty()){
            for(CampaignMember member:campaignMemberList){
                if(!mapOfCampaignMember.containskey(member.CampaignId)){
                    mapOfCampaignMember.put(member.CampaignId,new List<CampaignMember>{member});
                }
                else{
                    mapOfCampaignMember.get(member.CampaignId).add(member);
                }
            }
        }
        
        //if(action != null){
        List<Logs__c> listOfLogs = new List<Logs__c>();
        List<Rest_API_Call__c> listOfRestApiCalls = new List<Rest_API_Call__c>();
        for(Members_Action__c action : listOfMemberAction){
            Integer sendid = action.Campaign__r.Sendid__c != null ? Integer.valueOf(action.Campaign__r.Sendid__c) : 0;
            Http http = new Http();
            HttpResponse res;
            String restAPI = '';
            
            if(action.Campaign__r.Campaign_Type__c != null && action.Campaign__r.Campaign_Type__c == 'Mobile'){
                restAPI = 'sms/sentSms';
            }else{
                restAPI = 'email/sentEmails';
            }
            
            String endpoint = BatchCampaignMemberActionStep1.getEnpoint('/rest/v1/campaigns/' + restAPI + '?campaign_id=', index, action.Execution_Date_Time__c, sendid, objInwiseUtil, action.From_Date__c);
            
            HttpRequest req = objInwiseUtil.GetHTTPRequest('GET', 'application/json', endpoint);
            
            //if(action.Account_Token__c != null){
            if(action.Campaign__r.Account__c != null){
                String tokenFromSetting = '';
                if (objInwiseUtil.accIdWithTokenMap.containsKey(action.Campaign__r.Account__c)) {
                    tokenFromSetting = objInwiseUtil.accIdWithTokenMap.get(action.Campaign__r.Account__c);
                } 
                req.setHeader('X-Api-Key', tokenFromSetting);
            }else {
                req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken);
            }
            
            try{
                if(!Test.isRunningTest()){
                    req.setTimeout(120000);
                    res = http.send(req);
                    if(objInwiseUtil.objInwiseSetting.Track_Logs__c){
                        listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/campaigns/' + restAPI, 'BatchCampaignMemberActionStep2', 'doInwiseMembersActionsONLYForSENT'));
                    }
                }
                else{
                    String resBody = '[{"row_index": 5641396631, "transaction_id": "25cd01e7b8d1490786a256756a3261b9", "contact_id": 2, "campaign_id": 1201624, "date_sent": "2017-11-27 07:27:00", "email": "boaz@apt.co.il", "message_size": 33, "sending_source": "Campaign", "external_id":"' + mapOfCampaignMember.get(action.Campaign__c)[0].Id + '"}, {"row_index": 5641396627, "transaction_id": "577b99875f5c4ebe8aab7697d11270c3", "contact_id": 1, "campaign_id": 1201624, "date_sent": "2017-11-27 07:27:00", "email": "boaz.apt@gmail.com", "message_size": 33, "sending_source": "Campaign" ,"external_id": "' + mapOfCampaignMember.get(action.Campaign__c)[0].Id + '"}]';
                    res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
                }
                
                if(res != null && res.getStatusCode() == 200 && res.getBody() != null){
                    listOfCampaignMembersJsonSENT = (List<SendToInwiseController.JSON2ApexWrapperInwisemembersActionsSENT>) System.JSON.deserialize(res.getBody(), List<SendToInwiseController.JSON2ApexWrapperInwisemembersActionsSENT>.class);
                    if(Rest_API_Call__c.sObjectType.getDescribe().isAccessible() && Rest_API_Call__c.sObjectType.getDescribe().isCreateable()){
                        Rest_API_Call__c objRestAPICall = new Rest_API_Call__c();
                        
                        if((Test.isRunningTest() || Schema.sObjectType.Rest_API_Call__c.fields.Members_Action__c.isUpdateable()) && Schema.sObjectType.Rest_API_Call__c.fields.Members_Action__c.isCreateable()){
                            objRestAPICall.Members_Action__c = action.Id;  
                        }
                        if((Test.isRunningTest() || Schema.sObjectType.Rest_API_Call__c.fields.Call_Index__c.isUpdateable()) && Schema.sObjectType.Rest_API_Call__c.fields.Call_Index__c.isCreateable()){
                            objRestAPICall.Call_Index__c = index;
                        }
                        if((Test.isRunningTest() || Schema.sObjectType.Rest_API_Call__c.fields.Call_Type__c.isUpdateable()) && Schema.sObjectType.Rest_API_Call__c.fields.Call_Type__c.isCreateable()){
                            objRestAPICall.Call_Type__c= 'Sent';  
                        }
                        if((Test.isRunningTest() || Schema.sObjectType.Rest_API_Call__c.fields.Status__c.isUpdateable()) && Schema.sObjectType.Rest_API_Call__c.fields.Status__c.isCreateable()){ 
                            objRestAPICall.Status__c = 'Pending Update'; 
                        }
                        if((Test.isRunningTest() || Schema.sObjectType.Rest_API_Call__c.fields.Response__c.isUpdateable()) && Schema.sObjectType.Rest_API_Call__c.fields.Response__c.isCreateable()){
                            objRestAPICall.Response__c = res.getBody();  
                        }
                        if((Test.isRunningTest() || Schema.sObjectType.Rest_API_Call__c.fields.Request__c.isUpdateable()) && Schema.sObjectType.Rest_API_Call__c.fields.Request__c.isCreateable()){
                            objRestAPICall.Request__c = req.getBody();
                        }
                        if((Test.isRunningTest() || Schema.sObjectType.Rest_API_Call__c.fields.Channel_Type__c.isUpdateable()) && Schema.sObjectType.Rest_API_Call__c.fields.Channel_Type__c.isCreateable()){
                            objRestAPICall.Channel_Type__c = action.Campaign__r.Campaign_Type__c;
                        }
                        listOfRestApiCalls.add(objRestAPICall);
                    }
                }
            }
            catch(Exception ex){
                System.debug(ex.getMessage());
            }
        }
        
        if(!listOfRestApiCalls.isEmpty()){
            insert listOfRestApiCalls;
        }
        
        if(!listOfLogs.isEmpty()){
            insert listOfLogs;
        }
    }
}