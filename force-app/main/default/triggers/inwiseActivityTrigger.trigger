/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Trigger which set default field, delete the mapping in case of deletion & remove hyphen at the time of insert/update
/******************************************************************************************/
trigger inwiseActivityTrigger on Activity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   switch on Trigger.operationType {
            when BEFORE_INSERT {
                 inwiseActivityTriggerHandler.insertContactAndLeadOnActivity(Trigger.new);
            } 
            when BEFORE_UPDATE {
                
            }
            when BEFORE_DELETE {
               
            }
            when AFTER_INSERT {
              
            }
            when AFTER_UPDATE {
               
            }
            when AFTER_DELETE {
                
            } 
            when AFTER_UNDELETE {
               
            }
        }
    /*if(Trigger.isBefore){
        if(Trigger.isInsert){
            inwiseActivityTriggerHandler.insertContactAndLeadOnActivity(Trigger.new);
        }
    }*/

}