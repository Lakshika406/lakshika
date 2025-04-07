/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 04-April-2020
*Purpose :   IncomingWebhooks Api
******************************************************************************************/
@RestResource(urlMapping='/IncomingWebhooks/*')
global with sharing class RestAPIIncomingWebhooks {
    @HttpPost
    global static void ApiService() {
        List<Logs__c> listOfLogs = new List<Logs__c>();
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        List<Incoming_Webhooks__c>  IncomingWebhookslist =new  List<Incoming_Webhooks__c> () ;
        RestRequest request = RestContext.request;
        String paramTimeStamp = request.params.get('timeStamp');
        String paramTriggerType = request.params.get('trigger_type');
        String paramChannelType = request.params.get('channel_type');
        String paramCampaignId = request.params.get('campaign_id');
        String paramGroupId = request.params.get('group_id');
        String paramRemarks = request.params.get('remarks');
        String paramIP = request.params.get('ip');
        String paramRecipientEmail = request.params.get('contact[email]');
        String paramRecipientExternalID = request.params.get('contact[external_id]');
        String requestString = JSON.serializePretty(request);
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        requestString += ';timeStamp=' + paramTimeStamp;
        requestString += ';trigger_type=' + paramTriggerType;
        requestString += ';channel_type=' + paramChannelType;
        requestString += ';campaign_id=' + paramCampaignId;
        requestString += ';group_id=' + paramGroupId;
        requestString += ';remarks=' + paramRemarks;
        requestString += ';ip=' + paramIP;
        requestString += ';contact[email]=' + paramRecipientEmail;
        requestString += ';contact[external_id]=' + paramRecipientExternalID;
        
        try {
            if(Schema.SObjectType.Incoming_Webhooks__c.isCreateable()){
                Incoming_Webhooks__c objIncomingWebhooks= new Incoming_Webhooks__c();
                if(paramTimeStamp !=null && paramTimeStamp !='' && Schema.sObjectType.Incoming_Webhooks__c.fields.Time_Stamp__c.isCreateable()){
                    objIncomingWebhooks.Time_Stamp__c = Datetime.valueOf(paramTimeStamp);
                }
                if(paramTriggerType !=null && paramTriggerType !='' && Schema.sObjectType.Incoming_Webhooks__c.fields.Trigger_Type__c.isCreateable()){
                    objIncomingWebhooks.Trigger_Type__c = paramTriggerType;
                }
                
                if(paramChannelType !=null && paramChannelType !='' && Schema.sObjectType.Incoming_Webhooks__c.fields.Channel_Type__c.isCreateable()){
                    objIncomingWebhooks.Channel_Type__c = paramChannelType;
                }
                
                if(paramCampaignId !=null && paramCampaignId !='' && Schema.sObjectType.Incoming_Webhooks__c.fields.campaign_id__c.isCreateable()){
                    objIncomingWebhooks.campaign_id__c = paramCampaignId;
                }
                
                if(paramGroupId !=null && paramGroupId !='' && Schema.sObjectType.Incoming_Webhooks__c.fields.Group_Id__c.isCreateable()){
                    objIncomingWebhooks.Group_Id__c = paramGroupId;
                }
                if(paramRemarks !=null && paramRemarks !='' && Schema.sObjectType.Incoming_Webhooks__c.fields.Remarks__c.isCreateable()){
                    objIncomingWebhooks.Remarks__c = paramRemarks;
                }
                
                if(paramIP !=null && paramIP !='' && Schema.sObjectType.Incoming_Webhooks__c.fields.IP_Address__c.isCreateable()){
                    objIncomingWebhooks.IP_Address__c = paramIP;
                }
                objIncomingWebhooks.Request__c = requestString;
                if(paramRecipientExternalID !=null && paramRecipientExternalID !=''){
                    objIncomingWebhooks.External_ID__c = paramRecipientExternalID;
                    
                    String sObjName = Id.valueOf(paramRecipientExternalID).getSObjectType().getDescribe().getName();
                    
                    if(sObjName=='Contact' && Schema.sObjectType.Incoming_Webhooks__c.fields.Contact__c.isCreateable()){
                        objIncomingWebhooks.Contact__c = paramRecipientExternalID;
                    } 
                    if(sObjName=='CampaignMember' && Schema.sObjectType.Incoming_Webhooks__c.fields.Campaign_Member__c.isCreateable()){
                        objIncomingWebhooks.Campaign_Member__c = baseUrl+'/'+paramRecipientExternalID; 
                        List<CampaignMember> lstofMember = new List<CampaignMember>();
                        if (Schema.sObjectType.CampaignMember.isAccessible() &&
                            Schema.sObjectType.CampaignMember.fields.Id.isAccessible() &&
                            Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() &&
                            Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible()) {

                            lstofMember = [ SELECT  Id,ContactId,LeadId from CampaignMember WHERE Id = :paramRecipientExternalID WITH SECURITY_ENFORCED]; 

                        }
                        if(lstofMember.get(0).ContactId !=null  && Schema.sObjectType.Incoming_Webhooks__c.fields.Contact__c.isCreateable()) {
                            objIncomingWebhooks.Contact__c = lstofMember.get(0).ContactId;
                        }
                        if(lstofMember.get(0).LeadId !=null  && Schema.sObjectType.Incoming_Webhooks__c.fields.Lead__c.isCreateable()) {
                            objIncomingWebhooks.Lead__c = lstofMember.get(0).LeadId;
                        }   
                        
                    }
                    
                    if(sObjName=='Lead' && Schema.sObjectType.Incoming_Webhooks__c.fields.Lead__c.isCreateable()){
                        objIncomingWebhooks.Lead__c = paramRecipientExternalID;
                    }
                    
                }
                
                if(objIncomingWebhooks != null){
                    IncomingWebhookslist.add(objIncomingWebhooks);
                }
                
                
                if(!IncomingWebhookslist.isEmpty()){
                    insert objIncomingWebhooks;
                }
                
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, 'Created Incoming Webhooks record :-'+objIncomingWebhooks.id , '/IncomingWebhooks', 'RestAPIService', 'ApiService'));
                
            }
            
            
        }catch(Exception ex){
            system.debug(ex.getMessage()+'>>'+ex.getLineNumber());
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, (ex.getMessage() + ex.getLineNumber()), '/IncomingWebhooks', 'RestAPIService', 'ApiService'));
        }
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            if(Logs__c.SObjectType.getDescribe().isCreateable()){
                insert listOfLogs;
            }
        }
        // return null;
    }
    
    
}