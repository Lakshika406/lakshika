/*
* Created by         :       Kapil Goutam
*Created On         :       11 Aug  2017
*Purpose:             :       Mark a recipient as Subscribe / unsubscribe
*/
trigger inwiseLeadTrigger on Lead (after update) {
    if(trigger.isAfter && trigger.isUpdate){
          if(ExecutionManager.isNeedToByPass_LeadTrigger == false){
              Settings__c objInwiseSetting = Settings__c.getAll().get('default');
              if(objInwiseSetting != NULL && (objInwiseSetting.Toggle_Email_Opt_in_Opt_out__c || objInwiseSetting.Toggle_Mobile_Opt_in_Opt_out__c)){
                  inwiseLeadTriggerHandler.updateSubscription(trigger.new,trigger.oldMap);
              }
         }     
          
    }
}