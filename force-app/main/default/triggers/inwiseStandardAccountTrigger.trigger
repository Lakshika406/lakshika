trigger inwiseStandardAccountTrigger on Account (after update) {

    // Check if Person Accounts are enabled dynamically
    Boolean isPersonAccountEnabled = Schema.sObjectType.Account.fields.getMap().containsKey('IsPersonAccount');
    List<Account> listOfAccount = new List<Account>();
    Map<Id,Account> mapOfOldAccount = new Map<Id,Account>();
    if(trigger.isAfter && trigger.isUpdate){
        if(ExecutionManager.isNeedToByPass_ContactTrigger == false){
            for(account acc : trigger.new){
                Boolean isPersonAccount = false;

                if (isPersonAccountEnabled) {
                    // Dynamically fetch the IsPersonAccount value 
                    isPersonAccount = (Boolean) acc.get('IsPersonAccount');
                }


                if (isPersonAccount) {
                    // Logic for Person Accounts
                    listOfAccount.add(acc);
                    
                } else {
                    // Logic for Business Accounts
                }
            }

            for(account acc : trigger.old){
                Boolean isPersonAccount = false;

                if (isPersonAccountEnabled) {
                    // Dynamically fetch the IsPersonAccount value
                    isPersonAccount = (Boolean) acc.get('IsPersonAccount');
                }

                if (isPersonAccount) {
                    // Logic for Person Accounts
                    mapOfOldAccount.put(acc.Id,acc);
                    
                } else {
                    // Logic for Business Accounts
                }
            }

            if(listOfAccount.size() > 0){
                Settings__c objInwiseSetting = Settings__c.getAll().get('default');
                if(objInwiseSetting != NULL && (objInwiseSetting.Toggle_Email_Opt_in_Opt_out__c || objInwiseSetting.Toggle_Mobile_Opt_in_Opt_out__c)){
                    InwiseStandardAccountTriggerHandler.updateSubscription(listOfAccount,mapOfOldAccount);
                }  
            }

        }
    }
}