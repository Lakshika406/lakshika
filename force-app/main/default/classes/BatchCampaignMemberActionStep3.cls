/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 06 Mar 2019
*Purpose :  To fix apex heap size issue while executing previous batch
* * * -----------------------------------------------------
* Modified On       Modified By                 Purpose
* 08/17/2019        NLINEAXIS(Kapil Goutam)    Added functionality to execute statistics function for a campaign as well.
*                                               In this case no need to update custom setting
* 11/25/2020        NLINEAXIS(Kapil Goutam)    To avoid deletion issue if the campaign member is deleted & job try to process it again & again.
* 11/26/2020        NLINEAXIS(Kapil Goutam)    Added empty check in campaign member update
* 03/18/2021        NLINEAXIS(Kapil Goutam)    replaced value from "linkClicked" to "smsClicked" in campaign member update [Jira story IFS-35]
* 04/16/2021        NLINEAXIS(Kapil Goutam)    Added value "Additional Date" from "additional_data" field for sms/activities & sms/sentSms [Jira story QA3]
* 04/16/2021        NLINEAXIS(Kapil Goutam)    Added logic >> check value before insert in Activity SF that is already exist or not [Jira story IFS-34]
* 11/03/2021        NLINEAXIS(S. Vaishnav)     Modified:- Check Activity__c object accesible or createable
/******************************************************************************************/
global with sharing class BatchCampaignMemberActionStep3 implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    public Id memberActionId{get;set;}
    public boolean isNeedToScheduleNextHour {get;set;}
    public String callType{get;set;}

    public void init(Id ma, Boolean isNextHour, String cType){
        memberActionId = ma;
        isNeedToScheduleNextHour = isNextHour;
        callType = cType;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

            // Check object-level access
        if (Schema.sObjectType.Rest_API_Call__c.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Name.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Response__c.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Call_Type__c.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Members_Action__c.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Status__c.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Call_Index__c.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Channel_Type__c.isAccessible()) {

            // Perform the query
            return Database.getQueryLocator([SELECT Id, Name, Response__c, Call_Type__c, Channel_Type__c FROM Rest_API_Call__c
                                            WHERE Members_Action__c = :memberActionId AND Call_Type__c = :callType AND Status__c != 'Completed' ORDER BY Call_Index__c ASC
            ]);
        } else {
            // Log or handle insufficient permissions
            System.debug('User does not have sufficient permissions to access the Rest_API_Call__c object or the required fields.');
            return Database.getQueryLocator('SELECT Id FROM Rest_API_Call__c WHERE Id = NULL');
        }
        //return Database.getQueryLocator([SELECT Id,Name,Response__c,Call_Type__c, Channel_Type__c FROM Rest_API_Call__c where Members_Action__c =: memberActionId AND Call_Type__c =: callType AND Status__c != 'Completed' ORDER BY Call_Index__c ASC ]);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope){

        List<Rest_API_Call__c> listOfRestAPICalls =  (List<Rest_API_Call__c>) scope;
        
        
        List<Rest_API_Call__c> listOfRestAPICallsToUpdate = new List<Rest_API_Call__c>();
        List<Activity__c> listOfActivitieForInsert = new List<Activity__c>();
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>(); 
        Map<Id, CampaignMember> mapOfCampaignMemberToUpdate = new Map<Id, CampaignMember>();
        Map<Id, CampaignMember> mapOfCampaignMemberFinalUpdate = new Map<Id, CampaignMember>();
        List<SendToInwiseController.JSON2ApexWrapperInwisemembersActions> listOfCampaignMembersJson;
        List<SendToInwiseController.JSON2ApexWrapperInwisemembersActionsSENT> listOfCampaignMembersJsonSENT;
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        CampaignMember member;
        Map<String, Activity__c> mapOfStoredActivitie = new Map<String, Activity__c>();
        for(Activity__c acc : [SELECT Id, Name, Action_Date__c, SalesforceId__c, Action_Type__c, Additional_Data__c, inwiseId__c, Channel_Type__c, Contact__c, Lead__c FROM Activity__c WITH SECURITY_ENFORCED LIMIT 49999]) {
            mapOfStoredActivitie.put(acc.inwiseId__c, acc);
        }
		 
        for(Rest_API_Call__c r:listOfRestAPICalls){
            
            if(r.Call_Type__c == 'Activities'){

                listOfCampaignMembersJson = (List<SendToInwiseController.JSON2ApexWrapperInwisemembersActions>) System.JSON.deserialize(r.Response__c, List<SendToInwiseController.JSON2ApexWrapperInwisemembersActions>.class);
                if(!listOfCampaignMembersJson.isEmpty()){

                    if(Activity__c.sObjectType.getDescribe().isAccessible() && Activity__c.sObjectType.getDescribe().isCreateable()){
                        for(SendToInwiseController.JSON2ApexWrapperInwisemembersActions mba:listOfCampaignMembersJson){
                            Activity__c activitieObj = new Activity__c();

                            if(mba.external_id != null) {

                                member = mapOfCampaignMemberToUpdate.get(mba.external_id);
                                if(member == NULL) {
                                    member = new CampaignMember(Id = mba.external_id);
                                }

                                if(mba.action_type != NULL) {
                                    if('smsClicked'.equalsIgnoreCase(mba.action_type) || 'emailClicked'.equalsIgnoreCase(mba.action_type)) {
                                        member.Clicked__c = true;
                                    }
                                    if('smsOpened'.equalsIgnoreCase(mba.action_type) || 'emailOpened'.equalsIgnoreCase(mba.action_type)) {
                                        member.Opened__c = true;
                                    }
                                    if('smsUnsubscribed'.equalsIgnoreCase(mba.action_type) || 'emailUnsubscribed'.equalsIgnoreCase(mba.action_type)) {
                                        member.Unsubscribe__c = true;
                                    }
                                    if('smsBounced'.equalsIgnoreCase(mba.action_type) || 'emailBounced'.equalsIgnoreCase(mba.action_type)) {
                                        member.Bounced__c = true;
                                    }

                                    if(!mapOfStoredActivitie.containsKey(String.valueof(mba.id)) && activitieObj != null){
                                        if(mba.action_date != null && !String.isBlank(mba.action_date)){
                                            if(Schema.sObjectType.Activity__c.fields.Action_Date__c.isCreateable() && Schema.sObjectType.Activity__c.fields.Action_Date__c.isUpdateable()){
                                                try{
                                                    activitieObj.Action_Date__c = DateTime.valueOf(mba.action_date);
                                                }catch(Exception ex){
                                                    String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                                    listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'BatchCampaignMemberActionStep3','execute'));
                                                }
                                            }
                                        }
                                        if(mba.id != null && Schema.sObjectType.Activity__c.fields.inwiseId__c.isCreateable() && Schema.sObjectType.Activity__c.fields.inwiseId__c.isUpdateable()){
                                            try{
                                                activitieObj.inwiseId__c = String.valueof(mba.id);
                                            }catch(Exception ex){
                                                String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'BatchCampaignMemberActionStep3','execute'));
                                            }  
                                        }
                                        if(mba.external_id != null && Schema.sObjectType.Activity__c.fields.SalesforceId__c.isCreateable() && Schema.sObjectType.Activity__c.fields.SalesforceId__c.isUpdateable()){
                                            try{ 
                                                activitieObj.SalesforceId__c = String.valueof(mba.external_id);
                                            }catch(Exception ex){
                                                String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'BatchCampaignMemberActionStep3','execute'));
                                            }  
                                        }
                                        if(mba.campaign_id != null && Schema.sObjectType.Activity__c.fields.inwise_CampaignId__c.isCreateable() && Schema.sObjectType.Activity__c.fields.inwise_CampaignId__c.isUpdateable()){ 
                                            try{ 
                                                activitieObj.inwise_CampaignId__c = String.valueof(mba.campaign_id);
                                            }catch(Exception ex){
                                                String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'BatchCampaignMemberActionStep3','execute'));
                                            }  
                                        }

                                        if(Schema.sObjectType.Activity__c.fields.Action_Type__c.isCreateable() && Schema.sObjectType.Activity__c.fields.Action_Type__c.isUpdateable()){
                                            activitieObj.Action_Type__c = mba.action_type;
                                        }
                                        if(Schema.sObjectType.Activity__c.fields.Additional_Data__c.isCreateable() && Schema.sObjectType.Activity__c.fields.Additional_Data__c.isUpdateable()){
                                            activitieObj.Additional_Data__c = mba.additional_data;
                                        }
                                        if(Schema.sObjectType.Activity__c.fields.Channel_Type__c.isCreateable() && Schema.sObjectType.Activity__c.fields.Channel_Type__c.isUpdateable()){
                                            activitieObj.Channel_Type__c = r.Channel_Type__c; 
                                        }

                                        if(Activity__c.sObjectType.getDescribe().isUpdateable() && Activity__c.sObjectType.getDescribe().isCreateable()){
                                            listOfActivitieForInsert.add(activitieObj);
                                        }
                                    }
                                    mapOfCampaignMemberToUpdate.put(member.Id, member);
                                    
                                }
                            }
                        }
                    }
                }
            }else if(r.Call_Type__c == 'Sent'){

                listOfCampaignMembersJsonSENT = (List<SendToInwiseController.JSON2ApexWrapperInwisemembersActionsSENT>) System.JSON.deserialize(r.Response__c, List<SendToInwiseController.JSON2ApexWrapperInwisemembersActionsSENT>.class);
                if(!listOfCampaignMembersJsonSENT.isEmpty()){

                    if(Activity__c.sObjectType.getDescribe().isAccessible() && Activity__c.sObjectType.getDescribe().isCreateable()){
                        for(SendToInwiseController.JSON2ApexWrapperInwisemembersActionsSENT mba:listOfCampaignMembersJsonSENT){
                            
                            Activity__c activitieObj = new Activity__c();
                            if(mba.external_id != null) {

                                member = mapOfCampaignMemberToUpdate.get(mba.external_id);
                                if(member == NULL) {
                                    member = new CampaignMember(Id = mba.external_id);
                                }
                                member.Sent__c = true;
                                mapOfCampaignMemberToUpdate.put(member.Id, member);

                                if(!mapOfStoredActivitie.containsKey(String.valueof(mba.row_index)) && activitieObj != null){   
                                    if(mba.date_sent != null && !String.isBlank(mba.date_sent)){
                                        if(Schema.sObjectType.Activity__c.fields.Action_Date__c.isCreateable() && Schema.sObjectType.Activity__c.fields.Action_Date__c.isUpdateable()){
                                            try{
                                                activitieObj.Action_Date__c = DateTime.valueOf(mba.date_sent);
                                            }catch(Exception ex){
                                                String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'BatchCampaignMemberActionStep3','execute'));
                                            }
                                        }
                                    }
                                    if(mba.row_index != null && Schema.sObjectType.Activity__c.fields.inwiseId__c.isCreateable() && Schema.sObjectType.Activity__c.fields.inwiseId__c.isUpdateable()){
                                        try{
                                            activitieObj.inwiseId__c = String.valueof(mba.row_index);
                                        }catch(Exception ex){
                                            String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                            listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'BatchCampaignMemberActionStep3', 'execute'));
                                        }
                                    }
                                    if(mba.external_id != null && Schema.sObjectType.Activity__c.fields.SalesforceId__c.isCreateable() && Schema.sObjectType.Activity__c.fields.SalesforceId__c.isUpdateable()){ 
                                        try{
                                            activitieObj.SalesforceId__c = String.valueof(mba.external_id);
                                        }catch(Exception ex){
                                            String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                            listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'BatchCampaignMemberActionStep3','execute'));
                                        }  
                                    }
                                    if(mba.campaign_id != null && Schema.sObjectType.Activity__c.fields.inwise_CampaignId__c.isCreateable() && Schema.sObjectType.Activity__c.fields.inwise_CampaignId__c.isUpdateable()){
                                        try{ 
                                            activitieObj.inwise_CampaignId__c = String.valueof(mba.campaign_id);
                                        }catch(Exception ex){
                                            String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                            listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'BatchCampaignMemberActionStep3','execute'));
                                        }  
                                    }
                                    
                                    if(r.Channel_Type__c == 'Email' && Schema.sObjectType.Activity__c.fields.Action_Type__c.isCreateable() && Schema.sObjectType.Activity__c.fields.Action_Type__c.isUpdateable()){
                                        activitieObj.Action_Type__c = 'emailSent';
                                    }else if(r.Channel_Type__c == 'Mobile' && Schema.sObjectType.Activity__c.fields.Action_Type__c.isCreateable() && Schema.sObjectType.Activity__c.fields.Action_Type__c.isUpdateable()){
                                        activitieObj.Action_Type__c = 'smsSent';
                                    }

                                    if(Schema.sObjectType.Activity__c.fields.Channel_Type__c.isCreateable() && Schema.sObjectType.Activity__c.fields.Channel_Type__c.isUpdateable()){  
                                        activitieObj.Channel_Type__c = r.Channel_Type__c;
                                    }

                                    if(Activity__c.sObjectType.getDescribe().isUpdateable() && Activity__c.sObjectType.getDescribe().isCreateable()){
                                        listOfActivitieForInsert.add(activitieObj);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if(!mapOfCampaignMemberToUpdate.isEmpty()){
            //skip those records if they are deleted in between
            mapOfCampaignMemberFinalUpdate = new Map<Id, CampaignMember>();
            Map<Id, CampaignMember> mapOfCampaignMeIdsExistingInSystem = new Map<Id, CampaignMember>([Select Id from CampaignMember where Id IN : mapOfCampaignMemberToUpdate.keySet() WITH SECURITY_ENFORCED]);
            
            for(Id k : mapOfCampaignMemberToUpdate.keySet()){
                if(mapOfCampaignMeIdsExistingInSystem.get(k) != null){
                    mapOfCampaignMemberFinalUpdate.put(k, mapOfCampaignMemberToUpdate.get(k));
                }
            }

            if(!mapOfCampaignMemberFinalUpdate.isEmpty()){
                update mapOfCampaignMemberFinalUpdate.values();
            }
            if(objInwiseUtil.objInwiseSetting.Track_inwise_Activities__c && !listOfActivitieForInsert.isEmpty()){
                if(Activity__c.SObjectType.getDescribe().isUpdateable() && Activity__c.SObjectType.getDescribe().isCreateable()){
                    insert listOfActivitieForInsert;
                }
            }

            if(objInwiseUtil.objInwiseSetting.Track_Errors__c &&  !listOfErrorLogs.isEmpty()){  
                insert listOfErrorLogs; 
            } 
        }

        //keeping this in different block to avoid batch recursion in case of blank response from call
        if(!listOfRestAPICalls.isEmpty()){
            for(Rest_API_Call__c r:listOfRestAPICalls){
                listOfRestAPICallsToUpdate.add(new Rest_API_Call__c(Id = r.Id, Status__c = 'Completed'));
            }
            update listOfRestAPICallsToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC){

        List<Members_Action__c> listOfMembersActions = [Select Id,Is_Called_By_Button_Click__c,Execution_Date_Time__c from Members_Action__c where Id =: memberActionId WITH SECURITY_ENFORCED LIMIT 1];
        if(!listOfMembersActions.isEmpty()){

            Members_Action__c objMembersAction = listOfMembersActions.get(0);
            //Custom setting need to update only if the job is called from batch
            if(!objMembersAction.Is_Called_By_Button_Click__c){

                InwiseUtil objInwiseUtil = new InwiseUtil(null);
                
                // Boaz: take the time that we used in the process instead of creating new one that might little different
                Datetime dtNow = Datetime.newInstance(objMembersAction.Execution_Date_Time__c.date(), objMembersAction.Execution_Date_Time__c.time());
                
                Settings__c objInwiseSetting = new Settings__c(Id=objInwiseUtil.objInwiseSetting.Id);
                if(Schema.sObjectType.Settings__c.fields.Campaign_Member_Action_Last_Run_On__c.isUpdateable()){
                    objInwiseSetting.Campaign_Member_Action_Last_Run_On__c = dtNow;
                }
                if(Schema.sObjectType.Settings__c.isUpdateable()){
                    update objInwiseSetting;
                }
            }
        }

        List<Rest_API_Call__c> listOfPendingToProcess = new List<Rest_API_Call__c>();
        if (Schema.sObjectType.Rest_API_Call__c.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Name.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Members_Action__c.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Status__c.isAccessible() && 
            Schema.sObjectType.Rest_API_Call__c.fields.Call_Index__c.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Response__c.isAccessible() &&
            Schema.sObjectType.Rest_API_Call__c.fields.Call_Type__c.isAccessible()) {

            listOfPendingToProcess = [SELECT Id,Name,Response__c,Call_Type__c FROM Rest_API_Call__c where Members_Action__c =: memberActionId AND Call_Type__c =: callType AND Status__c != 'Completed' ORDER BY Call_Index__c ASC];

        }
        if(!listOfPendingToProcess.isEmpty()){
            BatchCampaignMemberActionStep3 objBatchCampaignMemberActionStep3 = new BatchCampaignMemberActionStep3();
            objBatchCampaignMemberActionStep3.init(memberActionId, isNeedToScheduleNextHour, callType);
            Database.executeBatch(objBatchCampaignMemberActionStep3, 1);
        }

        if(isNeedToScheduleNextHour){
            List<Rest_API_Call__c> listOfApis = [SELECT Id FROM Rest_API_Call__c where Members_Action__c =: memberActionId AND Call_Type__c =: callType AND Status__c != 'Completed' WITH SECURITY_ENFORCED];
            if(listOfApis.isEmpty()){
                inwiseCampaignMemberActionSchedularV2.schedulejob(null);
            }
        }
    }
}