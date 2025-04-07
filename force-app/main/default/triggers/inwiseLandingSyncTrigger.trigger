/******************************************************************************************
*Created By	:  NlineAxis
*Created On	:  22-August-2022
*Purpose 	:  Trigger on Landing_Sync__c object
Modification Log
----------------
Date              Version   Developer                  Comments
------------------------------------------------------------------------------------
08/22/2022        1.0.0     Shyam Vaishnav             Created
/***********************************************************************************/
trigger inwiseLandingSyncTrigger on Landing_Sync__c (after delete) {
    
    if(trigger.isAfter && trigger.isDelete){
        InwiseLandingSyncTriggerHandler.afterDelete(trigger.old);
    }
}