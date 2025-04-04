/*
* Created by         :       Kapil Goutam
*Created On         :
*Purpose:             :       Set inwise account & inwise campaign type from parent campaign    
*/
//Code Commented for Professional Edition Installation fix 13 Feb 2017
trigger inwiseCampaignTrigger on Campaign (before insert,before update) {
   if(Trigger.isBefore){
      if(Trigger.isInsert){
          Set<Id> setOfParentCampaign = new Set<Id>();
          for(Campaign c: Trigger.new){
              if(c.ParentId != NULL){
                  setOfParentCampaign.add(c.ParentId);
              }
          }
          //inwiseUtil objinwiseUtil = new inwiseUtil(null);
          if(!setOfParentCampaign.isEmpty()){
                Map<Id,Campaign> mapOfCampaign;
                //if(Schema.sObjectType.Campaign.isAccessible()){
                if (Schema.sObjectType.Campaign.isAccessible() &&
                    Schema.sObjectType.Campaign.fields.Account__c.isAccessible() &&
                    Schema.sObjectType.Campaign.fields.Campaign_Type__c.isAccessible()) {

                    mapOfCampaign = new Map<Id,Campaign>([Select Id, Account__c,Campaign_Type__c from Campaign where Id IN:setOfParentCampaign and Account__c != NULL]);
                }
              
              for(Campaign c: Trigger.new){
                  if(c.ParentId != NULL && mapOfCampaign.get(c.ParentId) != NULL){
                         if(mapOfCampaign.get(c.ParentId).Account__c != NULL){
                               if(Schema.sObjectType.Campaign.fields.Account__c.isUpdateable()){
                                    c.Account__c = mapOfCampaign.get(c.ParentId).Account__c;  
                               }                         
                                
                         }
                         if(mapOfCampaign.get(c.ParentId).Campaign_Type__c != NULL){
                              if(Schema.sObjectType.Campaign.fields.Campaign_Type__c.isUpdateable()){
                                 c.Campaign_Type__c =  mapOfCampaign.get(c.ParentId).Campaign_Type__c;  
                             }    
                         }
                        
                  }
              }
          }
      }
      if(Trigger.isInsert || Trigger.isUpdate){
          Set<Id> setofCampaignId = new Set<Id>();
          Account__c defaultAccount;
          Map<Id, Account__c> mapOfAccount;
          for(Campaign c: Trigger.new){
                if(c.Account__c != NULL){
                      setofCampaignId.add(c.Account__c);
                }
          }
          System.debug('setofCampaignId::-->>>' + setofCampaignId);
          //if(!setofCampaignId.isEmpty()){
                if (Schema.sObjectType.Account__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Default_Campaign_Type__c.isAccessible() &&
                    Schema.sObjectType.Account__c.fields.Default__c.isAccessible()) {

                    mapOfAccount = new Map<Id,Account__c>([SELECT Id, Default_Campaign_Type__c,Default__c from Account__c where Id IN:setofCampaignId OR Default__c = true]);
                    System.debug('mapOfAccount::-->>>' + mapOfAccount);
                }
                if(mapOfAccount != NULL && !mapOfAccount.isEmpty()){
                    for(Account__c a:mapOfAccount.values()){

                        if(a.Default__c && defaultAccount == NULL){
                            defaultAccount = a;
                            break;
                        }
                    }
                }
                System.debug('defaultAccount::-->>>>>'  + defaultAccount);
               for(Campaign c: Trigger.new){
                    System.debug('c.Campaign_Type__c::-->>>' + c.Campaign_Type__c + '>>>>>' + c.Account__c);
                    if(c.Campaign_Type__c == NULL && c.Account__c == NULL){
                          if(defaultAccount != NULL){
                              c.Account__c = defaultAccount.Id;
                              c.Campaign_Type__c = defaultAccount.Default_Campaign_Type__c != NULL ? defaultAccount.Default_Campaign_Type__c : 'Email';     
                          }
                    }else if(c.Campaign_Type__c == NULL && c.Account__c != NULL){
                          c.Campaign_Type__c = mapOfAccount != NULL && mapOfAccount.get(c.Account__c) != NULL && mapOfAccount.get(c.Account__c).Default_Campaign_Type__c != NULL ? mapOfAccount.get(c.Account__c).Default_Campaign_Type__c : 'Email';
                          System.debug('c.Campaign_Type__c::-->>>' + c.Campaign_Type__c);
                    }
               } 
          //}

          ////check the Campaign_Type__c field on campaign & if it is not filled by parent then set it by default account
          //List<Account__c> listOfDefaultAccount = [Select Id, Default_Campaign_Type__c from Account__c where Default__c = true LIMIT 1];
          //System.debug('listOfDefaultAccount::-->>' + listOfDefaultAccount);
          //if(!listOfDefaultAccount.isEmpty()){
          //      for(Campaign c: Trigger.new){
          //        if(c.Account__c == NULL){
          //            c.Account__c = listOfDefaultAccount.get(0).Id;
          //        }
          //        if(Trigger.isInsert){
          //            if(c.Campaign_Type__c == NULL){
          //                c.Campaign_Type__c = listOfDefaultAccount.get(0).Default_Campaign_Type__c;
          //            }  
          //        }
                  
          //    }
          //}else{
          //   //Commented on 20 Feb as it was preventing client to do other stuff.
          //   //if(listOfDefaultAccount.isEmpty()){
          //   // for(Campaign c :Trigger.new){
          //   //     c.adderror('No default account is found');
          //   // }
          //   //}
          //}

      }
  }   
}