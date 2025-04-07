/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: Oct 2016
*Purpose :     unset other account as defaule if a account set to default account
/******************************************************************************************/
public with sharing class inwiseAccountTriggerHandler {
     public static void SetUnsetDefault(List<Account__c> listOfInwiseAccount){
    	     List<Account__c> listOfInwiseAccounttoUpdate = new List<Account__c>();
    	     Id activeAccount = NULL;
           if(Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Default__c.isAccessible()){
            	for(Account__c ia:listOfInwiseAccount){
            		if(ia.Default__c){
            			activeAccount = ia.Id;
            			break;
            		}
            	}
            }    
    	       if(activeAccount != NULL){
                      if(Schema.sObjectType.Account__c.isAccessible() &&  Schema.sObjectType.Account__c.fields.Default__c.isAccessible() &&  Schema.sObjectType.Account__c.fields.Default__c.isUpdateable()){
                            for(Account__c ia:[Select Id from Account__c where Default__c = true and Id !=:activeAccount WITH SECURITY_ENFORCED]){
                                listOfInwiseAccounttoUpdate.add(new Account__c(Id=ia.Id, Default__c=false));
                            }
                      }  
    		
    	     }
           if(Schema.sObjectType.Account__c.isUpdateable()){
                if(!listOfInwiseAccounttoUpdate.isEmpty()){
                	update listOfInwiseAccounttoUpdate;
                }  
          }
    }
    public static void deleteAccountMapping(map<id,Account__c> accMap){
      if(!accMap.isEmpty()){
            SET<ID> keys = accMap.keyset();
            List<Mapping__c> mappingList = new List<Mapping__c>();
            if(Schema.sObjectType.Mapping__c.isAccessible() &&  Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible() ){
                mappingList = [Select id,Account__c from Mapping__c where Account__c = : keys WITH SECURITY_ENFORCED]; 
            }

            if(!mappingList.isEmpty()){
                if(Mapping__c.SObjectType.getDescribe().isDeletable()){
                    Delete mappingList;
                }
            }        
        }
    }
    /*
    * Remove hyphen from token
    */
    public static void BeforeInsertUpdate(List<Account__c> listOfInwiseAccount){
        if(!listOfInwiseAccount.isEmpty()){
            for(Account__c act:listOfInwiseAccount){
                  if(act.Token__c != NULL){
                      act.Token__c = act.Token__c.replace('-', '');
                  }
                  if(act.Default_Campaign_Type__c == NULL){
                      act.Default_Campaign_Type__c = 'Email';
                  }
            }
        }
    }
}