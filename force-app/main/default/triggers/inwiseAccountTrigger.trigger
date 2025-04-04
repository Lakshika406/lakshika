/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Trigger which set default field, delete the mapping in case of deletion & remove hyphen at the time of insert/update
/******************************************************************************************/
trigger inwiseAccountTrigger on Account__c (before delete, before insert, before update,after insert, after update) {
  if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        InwiseAccountTriggerHandler.SetUnsetDefault(Trigger.new);
  }
  if(Trigger.isBefore){
      if(Trigger.isDelete){//delete related mapping for the account
            InwiseAccountTriggerHandler.deleteAccountMapping(Trigger.oldMap);  
      }
      if(Trigger.isInsert || Trigger.isUpdate){
          InwiseAccountTriggerHandler.BeforeInsertUpdate(Trigger.new);
      }
      
  }
}