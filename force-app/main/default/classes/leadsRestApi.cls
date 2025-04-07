/******************************************************************************************
*Created By	:  NlineAxis
*Created On	:  29-July-2022
*Purpose 	:  Controller class for leadsWebhook Api
Modification Log
----------------
Date              Version   Developer                  Comments
------------------------------------------------------------------------------------
08/29/2022        1.0.0     Shyam Vaishnav             Created
/***********************************************************************************/

@RestResource(urlMapping='/leadsRestApi/*')
global class leadsRestApi {

    @HttpPost
    global static void inwiseLeadsService(){

        System.debug('Here it is');
    
        Boolean isError = false;
        List<Logs__c> listOfLogs = new List<Logs__c>();
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        List<Activity__c> objActivitiesList = new List<Activity__c>();
        
        RestRequest request = RestContext.request;
        String paramTimeStamp = request.params.get('timeStamp');
        String paramTriggerType = request.params.get('trigger_type');
        String paramTriggerDescription = request.params.get('trigger_description');
        String paramSurveyFieldPhone = request.params.get('survey_field[2]');
        String paramSurveyFieldEmail = request.params.get('survey_field[3]');
        String paramSurveyFieldFirstName = request.params.get('survey_field[5]');
        String paramSurveyFieldLastName = request.params.get('survey_field[6]');
        String paramGroupId = request.params.get('group_id');
        String paramIP = request.params.get('ip');
        string paramContactId = request.params.get('contact[id]');
        String paramContactEmail = request.params.get('contact[email]');
        String paramContactMobileNumber = request.params.get('contact[mobile_number]');
        String paramContactExternalID = request.params.get('contact[external_id]');
        String paramContactFirstName = request.params.get('contact[field1]');
        String paramContactLastName = request.params.get('contact[field2]');
        String landingSyncId = request.params.get('page_id');
        // String landingSyncId = request.params.get('form_id'); //For the future use
        
        String requestString = request.toString();
        requestString += ';timeStamp=' + paramTimeStamp;
        requestString += ';trigger_type=' + paramTriggerType;
        requestString += ';survey_field[2]=' + paramSurveyFieldPhone;
        requestString += ';survey_field[3]=' + paramSurveyFieldEmail;
        requestString += ';survey_field[5]=' + paramSurveyFieldFirstName;
        requestString += ';survey_field[6]=' + paramSurveyFieldLastName;
        requestString += ';group_id=' + paramGroupId;
        requestString += ';ip=' + paramIP;
        requestString += ';contact[email]=' + paramContactEmail;
        requestString += ';contact[mobile_number]=' + paramContactMobileNumber;
        requestString += ';contact[external_id]=' + paramContactExternalID;
        requestString += ';contact[field1]=' + paramContactFirstName;
        requestString += ';contact[field2]=' + paramContactLastName;
        requestString += ';page_id=' + landingSyncId;

        System.debug('paramTimeStamp '+paramTimeStamp);
        System.debug('paramTimeStamp '+paramTriggerType);
        System.debug('paramTimeStamp '+paramTriggerDescription);
        System.debug('paramTimeStamp '+paramSurveyFieldPhone);
        System.debug('paramTimeStamp '+paramSurveyFieldEmail);
        System.debug('paramTimeStamp '+paramSurveyFieldFirstName);
        System.debug('paramTimeStamp '+paramSurveyFieldLastName);
        System.debug('paramTimeStamp '+paramGroupId);
        System.debug('paramTimeStamp '+paramIP);
        System.debug('paramTimeStamp '+paramContactId);
        System.debug('paramTimeStamp '+paramContactEmail);
        System.debug('paramTimeStamp '+paramContactMobileNumber);
        System.debug('paramTimeStamp '+paramContactExternalID);
        System.debug('paramTimeStamp '+paramContactFirstName);
        System.debug('paramTimeStamp '+paramContactLastName);
        System.debug('landingSyncId '+landingSyncId);
        
        try{
            if(Schema.SObjectType.Activity__c.isCreateable()){
                Activity__c objActivities = new Activity__c();
                if(paramTimeStamp != null && paramTimeStamp != '' && Schema.sObjectType.Activity__c.fields.Action_Date__c.isCreateable()){
                    objActivities.Action_Date__c = Datetime.valueOf(paramTimeStamp);
                }
                if(paramTriggerType != null && paramTriggerType != '' && Schema.sObjectType.Activity__c.fields.Action_Type__c.isCreateable()){
                    objActivities.Action_Type__c = paramTriggerType;
                }
                if(paramGroupId != null && paramGroupId != '' && Schema.sObjectType.Activity__c.fields.Group_Id__c.isCreateable()){
                    objActivities.Group_Id__c = paramGroupId;
                }
                if(paramIP != null && paramIP != '' && Schema.sObjectType.Activity__c.fields.IP_Address__c.isCreateable()){
                    objActivities.IP_Address__c = paramIP;
                }
                if(paramContactId != null && paramContactId != '' && Schema.sObjectType.Activity__c.fields.inwiseId__c.isCreateable()){
                    objActivities.inwiseId__c = paramContactId;
                }
                if(paramContactExternalID != null && paramContactExternalID != ''){
                    
                    objActivities.Request__c = requestString;
                    objActivities.SalesforceId__c = paramContactExternalID;
                    String sObjName = Id.valueOf(paramContactExternalID).getSObjectType().getDescribe().getName();
                    
                    if(sObjName == 'Contact' && Schema.sObjectType.Activity__c.fields.Contact__c.isCreateable()){
                        objActivities.Contact__c = paramContactExternalID;
                    } 
                    if(sObjName == 'CampaignMember' && Schema.sObjectType.Activity__c.fields.inwise_CampaignId__c.isCreateable()){
                    
                        objActivities.inwise_CampaignId__c = baseUrl + '/' + paramContactExternalID; 
                        List<CampaignMember> lstofMember = [SELECT Id,ContactId,LeadId From CampaignMember WHERE Id =: paramContactExternalID];
                        
                        if(!lstofMember.isEmpty()){
                            if(lstofMember.get(0).ContactId != null && Schema.sObjectType.Activity__c.fields.Contact__c.isCreateable()) {
                                objActivities.Contact__c = lstofMember.get(0).ContactId;
                            }
                            if(lstofMember.get(0).LeadId != null && Schema.sObjectType.Activity__c.fields.Lead__c.isCreateable()) {
                                objActivities.Lead__c = lstofMember.get(0).LeadId;
                            }
                        }
                    }
                    
                    if(sObjName == 'Lead' && Schema.sObjectType.Activity__c.fields.Lead__c.isCreateable()){
                        objActivities.Lead__c = paramContactExternalID;
                    }
                }
                
                if(objActivities != null){
                    objActivitiesList.add(objActivities);
                }

                if(!objActivitiesList.isEmpty()){
                    insert objActivitiesList;
                }
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, 'Created Activities record :-'+objActivities.id, '/leadsRestApi/*', 'leadsRestApi', 'inwiseLeadsService'));
            }
            isError = false;
        }catch(Exception ex){
            isError = true;
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, (ex.getMessage() + ex.getLineNumber()), '/leadsRestApi/*', 'leadsRestApi', 'inwiseLeadsService'));
        }
        
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            if(Logs__c.SObjectType.getDescribe().isCreateable()){
                insert listOfLogs;
            }
        }
        
        if(String.isNotBlank(landingSyncId) && !isError){
            //inwiseUtil.executeLandingSync(landingSyncId);
        }
    }
}