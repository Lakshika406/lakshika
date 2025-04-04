/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Trigger which set default field, delete the mapping in case of deletion & remove hyphen at the time of insert/update
/******************************************************************************************/
trigger inwiseActivityTrigger on Activity__c (before insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            inwiseActivityTriggerHandler.insertContactAndLeadOnActivity(Trigger.new);
        }
    }

}