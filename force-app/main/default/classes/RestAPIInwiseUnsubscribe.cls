/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 30-Nov-2020
*Purpose :     Rest Unsubscribe Api
/******************************************************************************************/
@RestResource(urlMapping='/inwiseUnsubscribe/*')
global with sharing class RestAPIInwiseUnsubscribe {
    @HttpPost
    global static String ApiService() {
        List<Logs__c> listOfLogs = new List<Logs__c>();
        RestRequest request = RestContext.request;
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        String paramTimeStamp = request.params.get('timeStamp');
        String paramGroupId = request.params.get('group_id');
        String paramTriggerType = request.params.get('trigger_type');
        String paramChannelType = request.params.get('channel_type');
        String paramContactExternalID = request.params.get('contact[external_id]');
        String paramLeadExternalID = request.params.get('lead[external_id]');
        String paramRecipientmobileNumber = request.params.get('contact[mobile_number]');
        String paramRecipientEmail = request.params.get('contact[email]');
        String requestString = request.toString();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        requestString += ';timeStamp=' + paramTimeStamp;
        requestString += ';trigger_type=' + paramTriggerType;
        requestString += ';channel_type=' + paramChannelType;
        requestString += ';group_id=' + paramGroupId;
        requestString += ';contact[email]=' + paramRecipientEmail;
        requestString += ';contact[external_id]=' + paramContactExternalID;
        requestString += ';contact[mobile_number]=' + paramRecipientmobileNumber;
        try {
            if(paramTriggerType == inwiseConstants.emailUnsubscribed || 
                paramTriggerType == inwiseConstants.smsUnsubscribed){
                List<Contact> listOfContactToUpdate = new List<Contact>();
                List<Lead> listOfLeadToUpdate = new List<Lead>();
                Contact objContact;
                Lead objLead;
                Set<String> setOfMobile = new Set<String>();
                String fieldApiContact, fieldApiLead;
                Boolean isValidField;
                String formattedPhone;
                String emailSearch;
                if(objInwiseUtil.objInwiseSetting != NULL){
                    if(paramChannelType == ScheduleContactslistUnsubscribed.sChanelTypeEmail){
                        fieldApiContact = objInwiseUtil.objInwiseSetting.Email_Unsubscribe_Contact_Field__c; 
                        fieldApiLead = objInwiseUtil.objInwiseSetting.Email_Unsubscribe_Lead_Field__c; 
                        isValidField = BatchCalloutUnsubscribe.isValidsObjectField(fieldApiContact, inwiseConstants.SOBJECT_CONTACT);
                        if(isValidField == false){
                            fieldApiContact = NULL;
                        }
                        isValidField = BatchCalloutUnsubscribe.isValidsObjectField(fieldApiLead, inwiseConstants.SOBJECT_LEAD);
                        if(isValidField == false){
                            fieldApiLead = NULL;
                        }
                        
                    } else if(paramChannelType == ScheduleContactslistUnsubscribed.sChanelTypeSMS){
                        fieldApiContact = objInwiseUtil.objInwiseSetting.Mobile_Unsubscribe_Contact_Field__c; 
                        fieldApiLead = objInwiseUtil.objInwiseSetting.Mobile_Unsubscribe_Lead_Field__c;
                        isValidField = BatchCalloutUnsubscribe.isValidsObjectField(fieldApiContact, inwiseConstants.SOBJECT_CONTACT);
                        if(isValidField == false){
                            fieldApiContact = NULL;
                        }
                        isValidField = BatchCalloutUnsubscribe.isValidsObjectField(fieldApiLead, inwiseConstants.SOBJECT_LEAD);
                        if(isValidField == false){
                            fieldApiLead = NULL;
                        }
                        
                    }
                    
                    
                    if(paramContactExternalID != null){
                        
                        if(fieldApiContact != NULL && objInwiseUtil.objInwiseSetting != null ){
                            String campQuery = '';
                            if (Schema.sObjectType.CampaignMember.isAccessible() &&
                                Schema.sObjectType.CampaignMember.fields.Id.isAccessible() &&
                                Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() &&
                                Schema.sObjectType.CampaignMember.fields.Type.isAccessible() &&
                                Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible()) {

                                campQuery =  'SELECT Id, ContactId, Type, LeadId  FROM CampaignMember WHERE Id = :paramContactExternalID';
                            }
                            List<CampaignMember> CampaignMemberRec = Database.query(campQuery);
                            if(CampaignMemberRec.size() > 0){
                                if(CampaignMemberRec[0].Type == 'Contact'){
                                    String contactId = CampaignMemberRec[0].ContactId;
                                    String cquery = '';
                                    if (Schema.sObjectType.Contact.isAccessible() && 
                                        Schema.sObjectType.Contact.fields.Id.isAccessible() && 
                                        Schema.sObjectType.Contact.fields.Name.isAccessible()) {

                                        cquery =  'Select Id,Name from Contact where Id = :contactId';
                                    }
                                    List<Contact> ContactRec = Database.query(cquery);
                                    if(ContactRec.size() > 0){
                                        ContactRec[0].put(fieldApiContact,true);
                                        listOfContactToUpdate.add(ContactRec[0]);
                                    }else{
                                        listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, 'No Contact record found of Campaign Member'+paramContactExternalID, '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
                                    }
                                    
                                } else if(CampaignMemberRec[0].Type == 'Lead'){
                                    String leadId = CampaignMemberRec[0].LeadId;
                                    String lquery = '';
                                    if (Schema.sObjectType.Lead.isAccessible() && 
                                        Schema.sObjectType.Lead.fields.Id.isAccessible() && 
                                        Schema.sObjectType.Lead.fields.Name.isAccessible()) {

                                        lquery =  'Select Id,Name from Lead where Id = :leadId';
                                    }
                                    List<Lead> LeadRec = Database.query(lquery);
                                    if(LeadRec.size() > 0){
                                        LeadRec[0].put(fieldApiLead,true);
                                        listOfLeadToUpdate.add(LeadRec[0]);
                                    }else{
                                        listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, 'No Lead record found of Campaign Member'+paramContactExternalID, '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
                                    }
                                }
                            } else{
                                //String cquery =  'Select Id,Name from Contact where Id = :paramContactExternalID';
                                String cquery = '';
                                if (Schema.sObjectType.Contact.isAccessible() && 
                                    Schema.sObjectType.Contact.fields.Id.isAccessible() && 
                                    Schema.sObjectType.Contact.fields.Name.isAccessible()) {

                                    cquery =  'Select Id,Name from Contact where Id = :paramContactExternalID';
                                }
                                List<Contact> ContactRec = Database.query(cquery);
                                if(ContactRec.size() > 0){
                                    ContactRec[0].put(fieldApiContact,true);
                                    listOfContactToUpdate.add(ContactRec[0]);
                                } else{
                                    //String lquery =  'Select Id,Name from Lead where Id = :paramContactExternalID';
                                    String lquery = '';
                                    if (Schema.sObjectType.Lead.isAccessible() && 
                                        Schema.sObjectType.Lead.fields.Id.isAccessible() && 
                                        Schema.sObjectType.Lead.fields.Name.isAccessible()) {

                                        lquery =  'Select Id,Name from Lead where Id = :paramContactExternalID';
                                    }
                                    List<Lead> LeadRec = Database.query(lquery);
                                    if(LeadRec.size() > 0){
                                        LeadRec[0].put(fieldApiLead,true);
                                        listOfLeadToUpdate.add(LeadRec[0]);
                                    } else{
                                        listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, 'No Campaign Member, Lead or Contact record found with external id'+paramContactExternalID, '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
                                    }
                                }
                                
                            }
                            
                        }
                    } else{
                        if(paramChannelType == ScheduleContactslistUnsubscribed.sChanelTypeEmail){
                            emailSearch = paramRecipientEmail;
                        } else if(paramChannelType == ScheduleContactslistUnsubscribed.sChanelTypeSMS){ 
                            formattedPhone = BatchCalloutUnsubscribe.reformatPhone(paramRecipientmobileNumber,objInwiseUtil);
                            setOfMobile.add(formattedPhone);
                            if(formattedPhone != null && formattedPhone.contains('-')){
                                String formattedPhoneWithoutHyphen = formattedPhone.replace('-','');
                                setOfMobile.add(formattedPhoneWithoutHyphen);
                            }
                        }
                        if(paramChannelType == ScheduleContactslistUnsubscribed.sChanelTypeEmail){
                            if(fieldApiContact != NULL && objInwiseUtil.objInwiseSetting != null && objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c != null){
                                String cquery = '';
                                if (Schema.sObjectType.Contact.isAccessible() && 
                                    Schema.sObjectType.Contact.fields.Id.isAccessible() && 
                                    Schema.sObjectType.Contact.fields.Name.isAccessible() &&
                                    Schema.sObjectType.Contact.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c) &&
                                    Schema.sObjectType.Contact.fields.getMap().get(objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c).getDescribe().isAccessible()) {

                                    cquery =  'Select Id,Name from Contact where '+ objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c +' =:emailSearch';
                                }

                                List<Contact> listOfContact = Database.query(cquery);
                                if(!listOfContact.isEmpty()){
                                    for(Contact c:listOfContact){
                                        objContact = new Contact(Id=c.id);
                                        objContact.put(fieldApiContact,true);
                                        listOfContactToUpdate.add(objContact);
                                    }
                                } else{
                                    
                                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Contact record not found with ' + emailSearch + ' email'), '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
                                }
                                
                                
                            }
                            if(fieldApiLead != NULL && objInwiseUtil.objInwiseSetting != null && objInwiseUtil.objInwiseSetting.Lead_Email_Search_Field__c != null){
                                //String lquery =  'Select Id,Name from Lead where '+ objInwiseUtil.objInwiseSetting.Lead_Email_Search_Field__c +' =:emailSearch';
                                String lquery = '';
                                if (Schema.sObjectType.Lead.isAccessible() && 
                                    Schema.sObjectType.Lead.fields.Id.isAccessible() && 
                                    Schema.sObjectType.Lead.fields.Name.isAccessible() &&
                                    Schema.sObjectType.Lead.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Lead_Email_Search_Field__c) &&
                                    Schema.sObjectType.Lead.fields.getMap().get(objInwiseUtil.objInwiseSetting.Lead_Email_Search_Field__c).getDescribe().isAccessible()) {

                                    lquery =  'Select Id,Name from Lead where '+ objInwiseUtil.objInwiseSetting.Lead_Email_Search_Field__c +' =:emailSearch';
                                }
                                List<Lead> listOfLead = Database.query(lquery);
                                if(!listOfLead.isEmpty()){
                                    for(Lead c:listOfLead){
                                        objLead = new Lead(Id=c.id);
                                        objLead.put(fieldApiLead,true);
                                        listOfLeadToUpdate.add(objLead);
                                    }
                                } else{
                                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Lead record not found with ' + emailSearch + ' email'), '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
                                }
                            }
                            
                        } else if(paramChannelType == ScheduleContactslistUnsubscribed.sChanelTypeSMS){ 
                            if(fieldApiContact != NULL && objInwiseUtil.objInwiseSetting != null && objInwiseUtil.objInwiseSetting.Contact_Mobile_Search_Field__c != null){
                                //String cquery =  'Select Id,Name from Contact where '+ objInwiseUtil.objInwiseSetting.Contact_Mobile_Search_Field__c+' IN :setOfMobile';
                                String cquery = '';
                                if (Schema.sObjectType.Contact.isAccessible() && 
                                    Schema.sObjectType.Contact.fields.Id.isAccessible() && 
                                    Schema.sObjectType.Contact.fields.Name.isAccessible() &&
                                    Schema.sObjectType.Contact.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Contact_Mobile_Search_Field__c) &&
                                    Schema.sObjectType.Contact.fields.getMap().get(objInwiseUtil.objInwiseSetting.Contact_Mobile_Search_Field__c).getDescribe().isAccessible()) {

                                    cquery =  'Select Id,Name from Contact where '+ objInwiseUtil.objInwiseSetting.Contact_Mobile_Search_Field__c+' IN :setOfMobile';
                                }
                                List<Contact> listOfContact = Database.query(cquery);
                                if(!listOfContact.isEmpty()){
                                    for(Contact c:listOfContact){
                                        objContact = new Contact(Id=c.id);
                                        objContact.put(fieldApiContact,true);
                                        listOfContactToUpdate.add(objContact);
                                    }
                                } else{
                                    
                                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Contact record not found with ' + setOfMobile + ' phone number'), '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
                                }
                                
                                
                            }
                            if(fieldApiLead != NULL && objInwiseUtil.objInwiseSetting != null && objInwiseUtil.objInwiseSetting.Lead_Mobile_Search_Field__c != null){
                                //String lquery =  'Select Id,Name from Lead where '+ objInwiseUtil.objInwiseSetting.Lead_Mobile_Search_Field__c +' IN :setOfMobile';
                                String lquery = '';
                                if (Schema.sObjectType.Lead.isAccessible() && 
                                    Schema.sObjectType.Lead.fields.Id.isAccessible() && 
                                    Schema.sObjectType.Lead.fields.Name.isAccessible() &&
                                    Schema.sObjectType.Lead.fields.getMap().containsKey(objInwiseUtil.objInwiseSetting.Lead_Mobile_Search_Field__c) &&
                                    Schema.sObjectType.Lead.fields.getMap().get(objInwiseUtil.objInwiseSetting.Lead_Mobile_Search_Field__c).getDescribe().isAccessible()) {

                                    lquery =  'Select Id,Name from Lead where '+ objInwiseUtil.objInwiseSetting.Lead_Mobile_Search_Field__c +' IN :setOfMobile';
                                }
                                List<Lead> listOfLead = Database.query(lquery);
                                if(!listOfLead.isEmpty()){
                                    for(Lead c:listOfLead){
                                        objLead = new Lead(Id=c.id);
                                        objLead.put(fieldApiLead,true);
                                        listOfLeadToUpdate.add(objLead);
                                    }
                                } else{
                                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, ('Lead record not found with ' + setOfMobile + ' phone number'), '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
                                }
                                
                                
                            }
                        }
                    }
                } else{
                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, 'Custom Setting record not available', '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
                }
                
                if(!listOfContactToUpdate.isEmpty()){
                    ExecutionManager.isNeedToByPass_ContactTrigger = true;
                    update listOfContactToUpdate;
                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, 'Contact record updated', '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
                    ExecutionManager.isNeedToByPass_ContactTrigger = false;
                }
                if(!listOfLeadToUpdate.isEmpty()){
                    ExecutionManager.isNeedToByPass_LeadTrigger = true;
                    update listOfLeadToUpdate;
                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, 'Lead record updated', '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
                    ExecutionManager.isNeedToByPass_LeadTrigger = false;
                }
            }  
            else{
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, 'Trigger type is not supported:' +  paramTriggerType, '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
            }
            
            
        }catch(Exception ex){
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(requestString, (ex.getMessage() + ex.getLineNumber()), '/inwiseUnsubscribe', 'RestAPIinwiseUnsubscribe', 'Rest API call'));
            
        }
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            if(Logs__c.SObjectType.getDescribe().isCreateable()){
                insert listOfLogs;
            }
        }
        return null;
        
    }
    
    
    
}