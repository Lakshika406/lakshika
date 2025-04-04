/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 02 Mar 2019
*Purpose :  To fix apex heap size issue while executing previous batch
* -----------------------------------------------------
* Modified On       Modified By     Purpose
* 08/17/2019        Kapil Goutam    Added functionality to execute statistics function for a campaign as well.
* 11/03/2021        S. Vaishnav     Modified:- Send list of Members_Action__c in doInwiseMembersActions method
/******************************************************************************************/
global with sharing class BatchCampaignMemberActionStep1 implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    Integer index{get;set;}
    InwiseUtil objInwiseUtil{get;set;}
    public Id memberActionId{get;set;}//if this parameter is coming means this campaign need to process, otherwise pick next one
    public boolean isNeedToScheduleNextHour {get;set;}
    List<SendToInwiseController.JSON2ApexWrapperInwisemembersActions> listOfCampaignMembersJson{get;set;}
    
    public void init(Integer indx, Id ma,Boolean isNextHour){
        objInwiseUtil = new InwiseUtil(null);
        index = indx;
        memberActionId = ma;
        isNeedToScheduleNextHour = isNextHour;
        listOfCampaignMembersJson = new List<SendToInwiseController.JSON2ApexWrapperInwisemembersActions>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,Name, Campaign__c, Execution_Date_Time__c, From_Date__c, Campaign__r.Campaign_Type__c, Campaign__r.Sendid__c,Account_Token__c, Campaign__r.Account__c FROM Members_Action__c Where Id =: memberActionId WITH SECURITY_ENFORCED LIMIT 1]);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        List<Members_Action__c> listOfMemberAction =  (List<Members_Action__c>) scope;
        Members_Action__c action = listOfMemberAction[0];
        Integer sendid = action.Campaign__r.Sendid__c != null ? Integer.valueOf(action.Campaign__r.Sendid__c) : 0;
        doInwiseMembersActions(index, action.Execution_Date_Time__c, action.Campaign__r.Campaign_Type__c, sendid, listOfMemberAction, action.From_Date__c);
    }

    global void finish(Database.BatchableContext BC){

        Integer rowlimitsetting = objInwiseUtil.objInwiseSetting != NULL && objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c != NULL ? Integer.valueOf(objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c) : 85;
       	
        if(listOfCampaignMembersJson != NULL && listOfCampaignMembersJson.size() == rowlimitsetting){
           
            //call again with next index
            BatchCampaignMemberActionStep1 objBatchCampaignMemberActionStep1 = new BatchCampaignMemberActionStep1();
            objBatchCampaignMemberActionStep1.init(++index,memberActionId,isNeedToScheduleNextHour);
            Database.executeBatch(objBatchCampaignMemberActionStep1,1);
        }else{
             
            //not start next batch which will update the campaign member
            BatchCampaignMemberActionStep3 objBatchCampaignMemberActionStep3 = new BatchCampaignMemberActionStep3();
            objBatchCampaignMemberActionStep3.init(memberActionId,isNeedToScheduleNextHour, 'Activities');
            Database.executeBatch(objBatchCampaignMemberActionStep3,1);// means in once block there are 250 records & it would be 250*20 = 8750
        }
    }

    void  doInwiseMembersActions(Integer index, Datetime dtNow, String sCampaignType, Integer sendid, List<Members_Action__c> objMembersActionLi, Datetime lastDTUTC){
        
        Http http = new Http();
        HttpResponse res;
        HttpRequest req;
        CampaignMember member;
        List<Logs__c> listOfLogs = new List<Logs__c>();
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        Members_Action__c objMembersAction = objMembersActionLi[0];
        
        //lastDTUTC = DateTime.newInstance(2010, 6, 6, 3, 3, 3).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        //lastDTUTC  = lastDTUTC1.format(dateFormat);
        // dtNow = DateTime.newInstance(2020, 6, 6, 3, 3, 3).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        //String dtNow2  = dtNow1.format(dateFormat);
        if(!objInwiseUtil.CheckIfCredentialExists()){
            return;
        }

        if(sendid == null){
            return;
        }
        String endpointUrl = '';
        if(sCampaignType != null && sCampaignType == 'Mobile'){
            endpointUrl = 'sms';
        }else{
            endpointUrl = 'email';
        }

        String endpoint = getEnpoint('/rest/v1/campaigns/' + endpointUrl +'/activities?campaign_id=',index, dtNow, sendid, objInwiseUtil, lastDTUTC);
        Integer rowlimitsetting = objInwiseUtil.objInwiseSetting != NULL && objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c != NULL ? Integer.valueOf(objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c) : 85;
        req = objInwiseUtil.GetHTTPRequest('GET','application/json',endpoint);

        // if(objMembersAction.Account_Token__c != null){
        //     req.setHeader('X-Api-Key',objMembersAction.Account_Token__c);
        // }else {
        //     req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken);
        // }

        if(objMembersAction.Campaign__r.Account__c != null){ 
            String tokenFromSetting = '';
            if (objInwiseUtil.accIdWithTokenMap.containsKey(objMembersAction.Campaign__r.Account__c)) {
                tokenFromSetting = objInwiseUtil.accIdWithTokenMap.get(objMembersAction.Campaign__r.Account__c);
            } 
            req.setHeader('X-Api-Key',tokenFromSetting);
        }else {
            req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken);
        }

        req.setTimeout(120000);
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                if(objInwiseUtil.objInwiseSetting.Track_Logs__c){
                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/campaigns/'+ endpointUrl +'/activities', 'BatchCampaignMemberActionStep1', 'doInwiseMembersActions'));
                }
            }else{
                List<CampaignMember> listOfCampaignMemberTemp = [SELECT Id,ContactId, LeadId FROM CampaignMember where CampaignId =:objMembersAction.Campaign__c WITH SECURITY_ENFORCED];
                String resBody = '[{    "id": 2064933115,    "action_date": "2017-11-16 09:44:00",    "contact_id": -1,    "campaign_id": 1151942,    "ip": "192.117.103.75",    "action_type": null,    "external_id": null,    "remarks": null},{    "id": 2064159028,    "action_date": "2017-11-15 06:58:00",    "contact_id": 397346236,    "campaign_id": 1198735,    "ip": "80.179.84.79",    "action_type": "opened",    "external_id": "'+listOfCampaignMemberTemp.get(0).Id+ '",    "remarks": null} ]';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res != null && res.getStatusCode() == 200 && res.getBody() != null){
                listOfCampaignMembersJson = (List<SendToInwiseController.JSON2ApexWrapperInwisemembersActions>) System.JSON.deserialize(res.getBody(), List<SendToInwiseController.JSON2ApexWrapperInwisemembersActions>.class);
                
                if(Rest_API_Call__c.sObjectType.getDescribe().isAccessible() && Rest_API_Call__c.sObjectType.getDescribe().isCreateable()){
                    Rest_API_Call__c objRestAPICall = new Rest_API_Call__c();
                    if(Schema.sObjectType.Rest_API_Call__c.fields.Members_Action__c.isAccessible() && Schema.sObjectType.Rest_API_Call__c.fields.Members_Action__c.isCreateable()){
                        objRestAPICall.Members_Action__c = objMembersAction.Id;
                    }
                    if(Schema.sObjectType.Rest_API_Call__c.fields.Call_Index__c.isAccessible() && Schema.sObjectType.Rest_API_Call__c.fields.Call_Index__c.isCreateable()){
                        objRestAPICall.Call_Index__c = index;
                    }
                    if(Schema.sObjectType.Rest_API_Call__c.fields.Call_Type__c.isAccessible() && Schema.sObjectType.Rest_API_Call__c.fields.Call_Type__c.isCreateable()){
                        objRestAPICall.Call_Type__c= 'Activities';
                    }
                    if(Schema.sObjectType.Rest_API_Call__c.fields.Channel_Type__c.isAccessible() && Schema.sObjectType.Rest_API_Call__c.fields.Channel_Type__c.isCreateable()){
                        objRestAPICall.Channel_Type__c = sCampaignType;
                    }
                    if(Schema.sObjectType.Rest_API_Call__c.fields.Status__c.isAccessible() && Schema.sObjectType.Rest_API_Call__c.fields.Status__c.isCreateable()){
                        objRestAPICall.Status__c = 'Pending Update';
                    }
                    if(Schema.sObjectType.Rest_API_Call__c.fields.Response__c.isAccessible() && Schema.sObjectType.Rest_API_Call__c.fields.Response__c.isCreateable()){
                        objRestAPICall.Response__c = res.getBody();
                    }
                    if(Schema.sObjectType.Rest_API_Call__c.fields.Request__c.isAccessible() && Schema.sObjectType.Rest_API_Call__c.fields.Request__c.isCreateable()){
                        objRestAPICall.Request__c = req.getBody();
                    }
                    
                    insert objRestAPICall;   
                }
            }

            if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                insert listOfLogs;
            }
        }catch(Exception ex){
            // ErrorMsg = InwiseConstants.MSG_EXCEPTION_CALL + '-' + ex.getMessage();
        }
    }
    
    public static String getEnpoint(String apiURL, Integer index,Datetime dtNow, Integer sendId,InwiseUtil objInwiseUtil, Datetime lastDTUTC){
        String endpoint = objInwiseUtil.apiUrl + apiURL + sendId;
        integer rowlimitsetting = objInwiseUtil.objInwiseSetting != NULL && objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c != NULL ? Integer.valueOf(objInwiseUtil.objInwiseSetting.Sync_Members_Batch_Size__c) : 85;

        Datetime dtNowUTC = Datetime.newInstance(dtNow.dateGmt(), dtNow.timeGmt());
            
        if(lastDTUTC != NULL){    
            endpoint += '&date_from=' + EncodingUtil.urlEncode(lastDTUTC.format('yyyy-MM-dd HH:mm:ss'),'UTF-8') + '&date_to=' + EncodingUtil.urlEncode(dtNowUTC.format('yyyy-MM-dd HH:mm:ss'),'UTF-8') + '&limit=' + rowlimitsetting + '&page_index=' + index;
        }else{
            endpoint += '&date_from=' + EncodingUtil.urlEncode(dtNowUTC.addDays(-1).format('yyyy-MM-dd HH:mm:ss'),'UTF-8') + '&date_to=' + EncodingUtil.urlEncode(dtNowUTC.format('yyyy-MM-dd HH:mm:ss'),'UTF-8') + '&limit=' + rowlimitsetting+ '&page_index=' + index;
        }
        return endpoint;
    }
}