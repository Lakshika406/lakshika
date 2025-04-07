/*
* Created by         :       Kapil Goutam
*Created On         :       11 Aug  2017
*Purpose:             :       Mark a recipient as Subscribe / unsubscribe
*/
trigger inwiseLeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   switch on Trigger.operationType {
            when BEFORE_INSERT {
                
            } 
            when BEFORE_UPDATE {
                
            }
            when BEFORE_DELETE {
               
            }
            when AFTER_INSERT {
              
            }
            when AFTER_UPDATE {
                
                if(ExecutionManager.isNeedToByPass_LeadTrigger == false){
                    Settings__c objInwiseSetting = Settings__c.getAll().get('default');
                    if(objInwiseSetting != NULL && (objInwiseSetting.Toggle_Email_Opt_in_Opt_out__c || objInwiseSetting.Toggle_Mobile_Opt_in_Opt_out__c)){
                        inwiseLeadTriggerHandler.updateSubscription(trigger.new,trigger.oldMap);
                    }
                }  
               
            }
            when AFTER_DELETE {
                
            } 
            when AFTER_UNDELETE {
               
            }
        }
    
    /* if(trigger.isAfter && trigger.isUpdate){
        if(ExecutionManager.isNeedToByPass_LeadTrigger == false){
            Settings__c objInwiseSetting = Settings__c.getAll().get('default');
            if(objInwiseSetting != NULL && (objInwiseSetting.Toggle_Email_Opt_in_Opt_out__c || objInwiseSetting.Toggle_Mobile_Opt_in_Opt_out__c)){
                inwiseLeadTriggerHandler.updateSubscription(trigger.new,trigger.oldMap);
            }
        }     
        
    }*/
}