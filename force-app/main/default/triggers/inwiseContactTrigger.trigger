/*
* Created by         :       Kapil Goutam
*Created On         :       08 Aug  2017
*Purpose:             :       Mark a recipient as Subscribe / unsubscribe
*/
trigger inwiseContactTrigger on Contact (after update) {
  if(trigger.isAfter && trigger.isUpdate){
      System.debug('====contact trigger');
        if(ExecutionManager.isNeedToByPass_ContactTrigger == false){
            Settings__c objInwiseSetting = Settings__c.getAll().get('default');
            if(objInwiseSetting != NULL && (objInwiseSetting.Toggle_Email_Opt_in_Opt_out__c || objInwiseSetting.Toggle_Mobile_Opt_in_Opt_out__c)){
                inwiseContactTriggerHandler.updateSubscription(trigger.new,trigger.oldMap);
            }  
        }
 }
}