/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Trigger which set default field, delete the mapping in case of deletion & remove hyphen at the time of insert/update
/******************************************************************************************/
trigger inwiseAccountTrigger on Account__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
      switch on Trigger.operationType {
        when BEFORE_INSERT {
            // handler.beforeInsert(Trigger.new);
            InwiseAccountTriggerHandler.BeforeInsertUpdate(Trigger.new);
        } 
        when BEFORE_UPDATE {
           
            InwiseAccountTriggerHandler.BeforeInsertUpdate(Trigger.new);
        }
        when BEFORE_DELETE {
            
            InwiseAccountTriggerHandler.deleteAccountMapping(Trigger.oldMap); 
        }
        when AFTER_INSERT {
            
            InwiseAccountTriggerHandler.SetUnsetDefault(Trigger.new);
        }
        when AFTER_UPDATE {
            
            InwiseAccountTriggerHandler.SetUnsetDefault(Trigger.new);
        }
        when AFTER_DELETE {
            // handler.afterDelete(Trigger.old, Trigger.oldMap);
        } 
        when AFTER_UNDELETE {
            // handler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }
   /* if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            // Handle before delete
            InwiseAccountTriggerHandler.deleteAccountMapping(Trigger.oldMap);  
        } else if (Trigger.isInsert || Trigger.isUpdate) {
            // Handle before insert or update
            InwiseAccountTriggerHandler.BeforeInsertUpdate(Trigger.new);
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            // Handle after insert or update
            InwiseAccountTriggerHandler.SetUnsetDefault(Trigger.new);
        }
    }*/
    
 }