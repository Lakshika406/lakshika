/******************************************************************************************
*Created By:  NlineAxis
*Created On: 16-February-2022
*Purpose :   activitiesWebhook Api

06/20/2024     NLINEAXIS(Kapil Goutam)     Modified:- Added changes for security check 
******************************************************************************************/

@RestResource(urlMapping='/activitiesRestApi/*')
global with sharing class activitiesRestApi {

    @HttpPost
    global static void inwiseActivitiesService(){
        
        List<Logs__c> listOfLogs = new List<Logs__c>();
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        List<Activity__c> objActivitiesList = new List<Activity__c>();
        CampaignMember member ;
        RestRequest request = RestContext.request;
        String paramTimeStamp = request.params.get('timeStamp');
        String paramTriggerType = request.params.get('trigger_type');
        String paramTriggerdescription = request.params.get('trigger_description');
        String paramChannelType = request.params.get('channel_type');
        String paramCampaignId = request.params.get('campaign_id');
        String paramGroupId = request.params.get('group_id');
        String paramIP = request.params.get('ip');
        string paramId = request.params.get('contact[id]');
        String paramRecipientEmail = request.params.get('contact[email]');
        String paramRecipientExternalID = request.params.get('contact[external_id]');
        String paramAdditionalDetail = request.params.get('additional_details');
        
        String requestString = request.toString();
        requestString += ';timeStamp=' + paramTimeStamp;
        requestString += ';trigger_type=' + paramTriggerType;
        requestString += ';channel_type=' + paramChannelType;
        requestString += ';campaign_id=' + paramCampaignId;
        requestString += ';group_id=' + paramGroupId;
        requestString += ';ip=' + paramIP;
        requestString += ';contact[email]=' + paramRecipientEmail;
        requestString += ';contact[external_id]=' + paramRecipientExternalID;
        requestString += ';additional_details=' + paramAdditionalDetail;
        
      
        try{
            if(Schema.SObjectType.Activity__c.isCreateable()){
                Activity__c objActivities = new Activity__c();
                
                if(paramTimeStamp != null && paramTimeStamp != '' && Schema.sObjectType.Activity__c.fields.Action_Date__c.isCreateable()){
                    objActivities.Action_Date__c = Datetime.valueOf(paramTimeStamp);
                }
                if(paramTriggerType != null && paramTriggerType != '' && Schema.sObjectType.Activity__c.fields.Action_Type__c.isCreateable()){
                    objActivities.Action_Type__c = paramTriggerType;
                }
                if(paramChannelType != null && paramChannelType != '' && Schema.sObjectType.Activity__c.fields.Channel_Type__c.isCreateable()){
                    
                    if(paramChannelType == 'Email'){
                        objActivities.Channel_Type__c = 'Email';
                    }
                    else if(paramChannelType == 'Sms'){
                        objActivities.Channel_Type__c = 'Mobile';
                    }
                }
                if(paramCampaignId != null && paramCampaignId != '' && Schema.sObjectType.Activity__c.fields.inwise_CampaignId__c.isCreateable()){
                    objActivities.inwise_CampaignId__c = paramCampaignId;
                }
                if(paramGroupId != null && paramGroupId != '' && Schema.sObjectType.Activity__c.fields.Group_Id__c.isCreateable()){
                    objActivities.Group_Id__c = paramGroupId;
                }
                if(paramIP != null && paramIP != '' && Schema.sObjectType.Activity__c.fields.IP_Address__c.isCreateable()){
                    objActivities.IP_Address__c = paramIP;
                }
                if(paramId != null && paramId != '' && Schema.sObjectType.Activity__c.fields.inwiseId__c.isCreateable()){
                    objActivities.inwiseId__c = paramId;
                }
                if(paramAdditionalDetail != null && paramAdditionalDetail != '' &&Schema.sObjectType.Activity__c.fields.Additional_Data__c.isCreateable()){
                    objActivities.Additional_Data__c = paramAdditionalDetail;                   
                }           
                if(paramRecipientExternalID != null && paramRecipientExternalID != ''){
                    
                    objActivities.Request__c = requestString;
                    objActivities.SalesforceId__c=paramRecipientExternalID;
                    String sObjName = Id.valueOf(paramRecipientExternalID).getSObjectType().getDescribe().getName();
                    
                    if(sObjName == 'Contact' && Schema.sObjectType.Activity__c.fields.Contact__c.isCreateable()){
                        objActivities.Contact__c = paramRecipientExternalID;
                    } 
                    if(sObjName == 'CampaignMember' && Schema.sObjectType.Activity__c.fields.inwise_CampaignId__c.isCreateable()){
                    
                     	objActivities.inwise_CampaignId__c = paramCampaignId;
                        List<CampaignMember> lstofMember = new List<CampaignMember>();
                        // Check if the user has access to the CampaignMember object
                        if (Schema.sObjectType.CampaignMember.isAccessible()) {
                            // Query with SECURITY_ENFORCED to enforce field-level security
                            lstofMember = [SELECT Id,ContactId,LeadId,Bounced__c, Clicked__c, Opened__c, Sent__c, Unsubscribe__c From CampaignMember WHERE Id =: paramRecipientExternalID WITH SECURITY_ENFORCED];

                        } else {
                            // Handle the scenario where the user lacks access to the CampaignMember object
                            System.debug('User does not have access to the CampaignMember object.');
                        }
                        
                        if(!lstofMember.isEmpty()){
                            member = new CampaignMember(Id = lstofMember.get(0).Id);
                            if(lstofMember.get(0).ContactId != null && Schema.sObjectType.Activity__c.fields.Contact__c.isCreateable()) {
                                objActivities.Contact__c = lstofMember.get(0).ContactId;
                            }
                            if(lstofMember.get(0).LeadId != null && Schema.sObjectType.Activity__c.fields.Lead__c.isCreateable()) {
                                objActivities.Lead__c = lstofMember.get(0).LeadId;
                            }
                            if(Schema.sObjectType.CampaignMember.fields.Sent__c.isUpdateable() && (paramTriggerType == 'emailSent' || paramTriggerType == 'smsSent')){
                                member.Sent__c = true;
                            }
                            else if(Schema.sObjectType.CampaignMember.fields.Clicked__c.isUpdateable() && (paramTriggerType == 'emailClicked' || paramTriggerType == 'smsClicked')){
                                member.Clicked__c = true;
                            }
                            else if(Schema.sObjectType.CampaignMember.fields.Opened__c.isUpdateable() && paramTriggerType == 'emailOpened'){
                                member.Opened__c = true;
                            }
                            else if(Schema.sObjectType.CampaignMember.fields.Bounced__c.isUpdateable() && paramTriggerType == 'emailBounced'){
                                member.Bounced__c = true;
                            }
                            else if(Schema.sObjectType.CampaignMember.fields.Unsubscribe__c.isUpdateable() && (paramTriggerType == 'emailUnsubscribed' || paramTriggerType == 'smsUnsubscribed')){
                                member.Unsubscribe__c = true;
                            }
                        }
                    }
                    
                    if(sObjName == 'Lead' && Schema.sObjectType.Activity__c.fields.Lead__c.isCreateable()){
                        objActivities.Lead__c = paramRecipientExternalID;
                    }
                }
                
                if(objActivities != null){
                    objActivitiesList.add(objActivities);
                }
                if(Activity__c.SObjectType.getDescribe().isCreateable() && !objActivitiesList.isEmpty()){
                    insert objActivitiesList;
                }
                if(CampaignMember.SObjectType.getDescribe().isUpdateable() && member != null){
                    update member;
                }
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, 'Created Activities record :-'+objActivities.id ,'/activitiesRestApi', 'activitiesRestApi', 'inwiseActivitiesService'));
            }
        }catch(Exception ex){
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, (ex.getMessage() + ex.getLineNumber()), '/activitiesRestApi', 'activitiesRestApi', 'inwiseActivitiesService'));
        }
        
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            if(Logs__c.SObjectType.getDescribe().isCreateable()){
                insert listOfLogs;
            }
        }
    }
}