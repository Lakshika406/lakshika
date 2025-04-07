/******************************************************************************************
* Created By	: 	Shyam Vaishnav
* Created On	: 	22 Aug 2022
* Purpose 		:   Handler class of inwiseLandingSyncTrigger trigger
/******************************************************************************************
Modification Log
----------------
Date              Version   Developer                  Comments
------------------------------------------------------------------------------------
08/22/2022        1.0.0     Shyam Vaishnav             Created
/***********************************************************************************/
public with sharing class InwiseLandingSyncTriggerHandler {
    
    public static void afterDelete(List<Landing_Sync__c> listOldLandingSync){
        
        Map<String, String> automationIdMap = new Map<String, String>();
        if(Schema.sObjectType.Landing_Sync__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Automation_Id__c.isAccessible()){
            for(Landing_Sync__c oldLandingSync : listOldLandingSync){
                if(String.isNotBlank(oldLandingSync.Automation_Id__c) && String.isNotBlank(oldLandingSync.Account__c)){
                    automationIdMap.put(oldLandingSync.Automation_Id__c, oldLandingSync.Account__c);
                }
            }
        }    
        
        if(!automationIdMap.isEmpty()){
            Database.executeBatch(new BatchDeleteInwiseAutomation(automationIdMap), 1);
        }
    }
}