/******************************************************************************************
*Created By:  Kapil Goutam
*Created On:  07 April 2021
*Purpose :    insert the contact and lead on Activity object on before trigger [SalesforceId__c id set in "BatchCampaignMemberActionStep3" class]
/******************************************************************************************/
public with sharing class inwiseActivityTriggerHandler {

    public static void insertContactAndLeadOnActivity(List<Activity__c> listOfActivity){ 
        Map<String,CampaignMember> mapOfCampaignMember = new Map<String,CampaignMember>();
        Set<Id> setOfCampaignMemberIds = new Set<Id>();
        for(Activity__c actObj : listOfActivity){
            //System.debug('==actObj.SalesforceId__c=='+actObj.SalesforceId__c);
            if(actObj.SalesforceId__c != null){
                setOfCampaignMemberIds.add(actObj.SalesforceId__c);
            }
        }

        if(setOfCampaignMemberIds.size() > 0){
            for(CampaignMember camMemberObj : [SELECT Id, Name, ContactId, LeadId FROM CampaignMember WHERE Id =: setOfCampaignMemberIds WITH SECURITY_ENFORCED LIMIT 49999]){
                mapOfCampaignMember.put(camMemberObj.Id, camMemberObj);
            }
        }

        if(mapOfCampaignMember.values().size() > 0) {
            for(Activity__c actObj : listOfActivity){
                if(mapOfCampaignMember.get(actObj.SalesforceId__c).ContactId != null){
                    actObj.Contact__c = mapOfCampaignMember.get(actObj.SalesforceId__c).ContactId;
                }
                if(mapOfCampaignMember.get(actObj.SalesforceId__c).LeadId != null){
                    actObj.Lead__c = mapOfCampaignMember.get(actObj.SalesforceId__c).LeadId;
                }
                //System.debug('==listOfActivityObj=='+actObj);
            }
        }
    }
}