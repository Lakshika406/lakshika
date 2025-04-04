/*
*Created By:  Kapil Goutam
*Created On: Oct 12, 2018
*Purpose :   
*================================================================
*Modified On   Version   Modified By                Purpose
*================================================================
*04/12/2021    1.1.0  NLINEAXIS(Kapil Goutam)     Modified:- Add jqxComboBox on vf page that show account according to user
*04/19/2021    1.1.1  NLINEAXIS(Kapil Goutam)     Modified:- Added error msg (Cannot add " And \ character in campaign name) [Jira IFS-40]
*06/28/2021    1.1.2  NLINEAXIS(Kapil Goutam)     Modified:- Added system admin should be able to see all options (Show all account picklist value for system admin)
*03/14/2023    1.1.2  NLINEAXIS                   Modified:- Added pop up error message when user has no permission on account 

******************************************************************/
public with sharing class CampaignDetailController {
    public Campaign objCampaign{get;set;}
    public Boolean isEditMode{get;set;}
    public String actionType{get;set;}
    public String selectedAccount{get;set;}  
    public String selectedAccountId{get;set;}
    public Integer selectedAccountIndex{get;set;}
    public List<Account__c> listOfAccount{get;set;}
    
    public Boolean isAdminUser ;
    public String userProfileName ;
    public Set<Id> setOfAccountIds ;
    public Map<String,Integer> mapOfAccountIndex;
    public Integer Bounced{get{
        return objCampaign.Bounced__c != null ? Integer.valueOf(objCampaign.Bounced__c) : 0;
    }}
    public Integer Clicked{get{
        return objCampaign.Clicked__c != null ? Integer.valueOf(objCampaign.Clicked__c) : 0;
    }}
    public Integer ClicksUnique{get{
        return objCampaign.Clicks_Unique__c != null ? Integer.valueOf(objCampaign.Clicks_Unique__c) : 0;
    }}
    public Integer Groupid{get{
        return objCampaign.Groupid__c != null ? Integer.valueOf(objCampaign.Groupid__c) : 0;
    }}
    public Integer Nonsent{get{
        return objCampaign.Nonsent__c != null ? Integer.valueOf(objCampaign.Nonsent__c) : 0;
    }}
    public Integer Opened{get{
        return objCampaign.Opened__c != null ? Integer.valueOf(objCampaign.Opened__c) : 0;
    }}
    public Integer OpensUnique{get{
        return objCampaign.Opens_Unique__c != null ? Integer.valueOf(objCampaign.Opens_Unique__c) : 0;
    }}
    public Integer Sendid{get{
        return objCampaign.Sendid__c != null ? Integer.valueOf(objCampaign.Sendid__c) : 0;
    }}
    public Integer Sent{get{
        return objCampaign.Sent__c != null ? Integer.valueOf(objCampaign.Sent__c) : 0;
    }}
    public Integer Unsubscribe{get{
        return objCampaign.Unsubscribe__c != null ? Integer.valueOf(objCampaign.Unsubscribe__c) : 0;
    }}
    
    public CampaignDetailController(ApexPages.StandardController controller){
        mapOfAccountIndex = new Map<String,Integer>();
        if(Campaign.SObjectType.getDescribe().isAccessible() && Campaign.SObjectType.getDescribe().isUpdateable()){
            objCampaign = (Campaign)controller.getRecord();
        }
        init(new List<Campaign>{objCampaign});
        isAdminUser = true;
        //userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
        if (Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.fields.Name.isAccessible()) {

            userProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
           
        } else {
            System.debug('User does not have access to the Profile object or Name field.');
        }
        List<String> listOfFinalUserProfileName = new List<String>();
        
        for(Setting__mdt customMetadataObj : [SELECT Id, MasterLabel, DeveloperName, Setting_Value__c FROM Setting__mdt WHERE MasterLabel = 'System Admin Profile' LIMIT 10000]) {
            listOfFinalUserProfileName.add(customMetadataObj.Setting_Value__c); 
        }
        
        isAdminUser = listOfFinalUserProfileName.contains(userProfileName);  
        listOfAccount = new List<Account__c>();
        setOfAccountIds = new Set<Id>();
        
        if (Schema.sObjectType.Account_SalesforceUser_Mapping__c.isAccessible() &&
            Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.Account__c.isAccessible() &&
            Schema.sObjectType.Account_SalesforceUser_Mapping__c.fields.User__c.isAccessible()) {

            for(Account_SalesforceUser_Mapping__c accMap : [SELECT Id, Name, Account__c, User__c FROM Account_SalesforceUser_Mapping__c WHERE User__c =: UserInfo.getUserId() LIMIT 49999]){
                setOfAccountIds.add(accMap.Account__c);
            }
        } else {
            System.debug('User does not have sufficient permissions to access Account_SalesforceUser_Mapping__c or its fields.');
        }
        
        Integer count = 0;
        if(isAdminUser) {
            //listOfAccount = [SELECT Id, Name FROM Account__c order by name ASC LIMIT 49999];
            if (Schema.sObjectType.Account__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Name.isAccessible()) {

                listOfAccount = [SELECT Id, Name FROM Account__c order by name ASC LIMIT 49999];
            } else {
                System.debug('User does not have sufficient permissions to access the Account__c object or its fields.');
            }

            for(Account__c acc: listOfAccount) {
                mapOfAccountIndex.put(acc.Id, count);
                count++;
            }
        } else { 
            //listOfAccount = [SELECT Id, Name FROM Account__c WHERE Id IN : setOfAccountIds order by name ASC LIMIT 49999];
            if (Schema.sObjectType.Account__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Name.isAccessible()) {

                listOfAccount = [SELECT Id, Name FROM Account__c WHERE Id IN : setOfAccountIds order by name ASC LIMIT 49999];
            } else {
                System.debug('User does not have sufficient permissions to access the Account__c object or its fields.');
            }
            for(Account__c acc: listOfAccount) {
                mapOfAccountIndex.put(acc.Id, count);
                count++;
            }
        }
        
        if(objCampaign.Account__c == null){
            if(listOfAccount.size() > 0){
                selectedAccountIndex = 0;
                selectedAccount = listOfAccount[0].Name;
                selectedAccountId = listOfAccount[0].Id;
            }
        } else {
            //List<Account__c> listOfAcc = [SELECT Id, Name FROM Account__c WHERE Id =: objCampaign.Account__c LIMIT 1];
            List<Account__c> listOfAcc = new List<Account__c>();
            if (Schema.sObjectType.Account__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Name.isAccessible()) {

                listOfAcc = [SELECT Id, Name FROM Account__c WHERE Id =: objCampaign.Account__c LIMIT 1];
            } else {
                System.debug('User does not have sufficient permissions to access the Account__c object or its fields.');
            }
            
            if(listOfAcc.size() > 0){
                selectedAccountIndex = mapOfAccountIndex.get(objCampaign.Account__c);
                selectedAccount = objCampaign.Account__r.Name;
                selectedAccountId = objCampaign.Account__c;
            }
        }
    }
    
    public void init(List<Campaign> objCampaignLi){
        Campaign objCampaignT = objCampaignLi[0];
        if(objCampaignT != null && objCampaignT.Id != null && Campaign.sObjectType.getDescribe().isAccessible()){
            //List<Campaign> campaignLi = [SELECT Id, Name, Bounced__c,Campaign_Type__c,Clicked__c,Clicks_Unique__c,Groupid__c,Account__c,Nonsent__c,Opened__c,Opens_Unique__c,Sendid__c,Sent__c,Unsubscribe__c, Account__r.Name from Campaign where Id =: objCampaignT.Id];
            List<Campaign> campaignLi = new List<Campaign>();
            if (Schema.sObjectType.Campaign.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Id.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Name.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Bounced__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Campaign_Type__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Clicked__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Clicks_Unique__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Groupid__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Account__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Nonsent__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Opened__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Opens_Unique__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Sendid__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Sent__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Unsubscribe__c.isAccessible() &&
                Schema.sObjectType.Account.fields.Name.isAccessible()) { // Check for related Account field

                campaignLi = [SELECT Id, Name, Bounced__c,Campaign_Type__c,Clicked__c,Clicks_Unique__c,Groupid__c,Account__c,Nonsent__c,Opened__c,Opens_Unique__c,Sendid__c,Sent__c,Unsubscribe__c, Account__r.Name from Campaign where Id =: objCampaignT.Id];


            } else {
                System.debug('User does not have sufficient permissions to access Campaign or related Account fields.');
            }
            if(!campaignLi.isEmpty()){
                objCampaign = campaignLi[0];
            }
        }
    }
    
    public PageReference doOpeninEditMode(){
        Integer count = 0;
        if(mapOfAccountIndex.values().size() > 0 && listOfAccount.size() > 0) {
            for(Account__c acc: listOfAccount) {
                mapOfAccountIndex.put(acc.Id, count);
                count++;
            }
            selectedAccountIndex = mapOfAccountIndex.get(objCampaign.Account__c) != null ? mapOfAccountIndex.get(objCampaign.Account__c) : 0;
            if(selectedAccountIndex == 0 && !isAdminUser){
                selectedAccountId = listOfAccount[0].Id;
                
            }
        }
        isEditMode = true;
        return null;
    }
    
    public PageReference doCancel(){
        selectedAccount = objCampaign.Account__r.Name;
        isEditMode = false;
        return null;
    }
    
    public PageReference doSave(){
        
        if(Schema.sObjectType.Campaign.fields.Account__c.isCreateable() && Schema.sObjectType.Campaign.fields.Account__c.isUpdateable()){
               objCampaign.Account__c = selectedAccountId;
        }
        if(Campaign.sObjectType.getDescribe().isAccessible() && Campaign.sObjectType.getDescribe().isUpdateable()){
            update objCampaign;
        }
        isEditMode = false;
        init(new List<Campaign>{objCampaign});
        selectedAccount = objCampaign.Account__r.Name;
        return null;
    }
    
    public PageReference selectedAccId(){
       return null;
    }
    
    public boolean displayPopup {get; set;}
    
    public void closePopup() {
        displayPopup = false;
    }
    public String Msg{get;set;}
    
    public void showPopup() {
        ApexPages.StandardController stdController = new ApexPages.StandardController(objCampaign);
        SendToInwiseController objSendToInwiseController = new SendToInwiseController(stdController);
        if(selectedAccount == Null){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select inwise account'));
            Msg = 'Please select inwise Account';
            displayPopup = true;
            return;
        }
        if(objCampaign.Name.contains('"') || objCampaign.Name.contains('\\')){
            Msg = 'Cannot sync campaign with '+' " ' +'or ' +'\\'+' character.';
            displayPopup = true;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Cannot sync campaign with '+' " ' +'or ' +'\\'+' character.'));
        } else {
            if(actionType != null){
                if(actionType == 'InwiseMembersActions'){
                    objSendToInwiseController.OnLoad(objCampaign.Id, 'InwiseStatistics');
                }
                objSendToInwiseController.OnLoad(objCampaign.Id, actionType);
                Msg = objSendToInwiseController.ErrorMsg;
            }
            init(new List<Campaign>{objCampaign});
            displayPopup = true;
        }
    }
}