/******************************************************************************************
*Created By:  Kapil Goutam
*Created On:  08-Oct-2019
*Purpose :    controller to show inbound sms configuration
* * -----------------------------------------------------
* Modified On       Modified By     Purpose
* Date(MM/DD/YY)    Version         Name                        Description
* 05/20/2021        1.1.1           NLINEAXIS(Kapil Goutam)     Modified:- Added new "getHostUrl" method 
* 11/03/2021        1.1.2           NLINEAXIS(S. Vaishnav)      Modified:- Check Webhook_Setting__c object accesible or createable

******************************************************************************************/

public with sharing class InboundSMSConfigurationController {

    public inwiseLtngConstants objinwiseLtngConstants{get;set;}
    public Boolean isSaved {get;set;}
    public Boolean isContactSelected{get;set;}
    public Boolean isLeadSelected{get;set;}
    public Boolean isAccountSelected{get;set;}
    public Boolean isActivityHistorySelected{get;set;}
    public Boolean isMessageHistorySelected{get;set;}
    public String sSelectedContactField{get;set;}
    public String sSelectedLeadField{get;set;}
    public String sSelectedAccountField{get;set;}
    public Boolean addActivityToAll{get;set;}
    public List<SelectOption> listOfSelectOptionFields_Contact {get;set;}
    public List<SelectOption> listOfSelectOptionFields_Lead {get;set;}
    public List<SelectOption> listOfSelectOptionFields_Account {get;set;}

    public String getHostUrl() {
        String str = inwiseUtil.hostUrl('inwiseinboudsms');
        return str;
    }

    public InboundSMSConfigurationController(){
        isSaved = false;
        isContactSelected = false;
        isLeadSelected = false;
        isAccountSelected = false;
        addActivityToAll = false;
        objinwiseLtngConstants = new inwiseLtngConstants();
        Set<String> setOfAcceptableTypeForSOQL = new Set<String>{inwiseScheduleSyncObject.FIELD_TYPE_PHONE};
        listOfSelectOptionFields_Contact = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_CONTACT,setOfAcceptableTypeForSOQL,true);
        listOfSelectOptionFields_Lead = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_LEAD,setOfAcceptableTypeForSOQL,true);
        listOfSelectOptionFields_Account = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_ACCOUNT,setOfAcceptableTypeForSOQL,true);
        doLoadPreviousWebhookSetting();
    }

    public void doLoadPreviousWebhookSetting(){
        Webhook_Setting__c objInwiseWebhookSetting = Webhook_Setting__c.getAll().get('default');
        if(objInwiseWebhookSetting != null){
            if(objInwiseWebhookSetting.Contact_Field__c != null){
                isContactSelected = true;
                sSelectedContactField = objInwiseWebhookSetting.Contact_Field__c;
            }
            if(objInwiseWebhookSetting.Account_Field__c != null){
                isAccountSelected = true;
                sSelectedAccountField = objInwiseWebhookSetting.Account_Field__c;
            }
            if(objInwiseWebhookSetting.Lead_Field__c != null){
                isLeadSelected = true;
                sSelectedLeadField = objInwiseWebhookSetting.Lead_Field__c;
            }
            addActivityToAll = objInwiseWebhookSetting.Add_activity_to_all_records__c;
            isActivityHistorySelected = objInwiseWebhookSetting.Save_To_Activity_History__c;
            isMessageHistorySelected =  objInwiseWebhookSetting.Save_To_Messaging_History__c;
        }
    }

    public PageReference doCheckOnChange(){
        return null;
    }

    public PageReference doSave() {
        PageReference pr;
        try{
            if(isActivityHistorySelected == false && isMessageHistorySelected == false ){
                apexpages.addmessage(new apexpages.message(apexpages.severity.INFO, 'Please select Save To Activity History & Messaging History.'));
                return pr;
            }
            if(isContactSelected == false && isLeadSelected == false && isAccountSelected == false){
                apexpages.addmessage(new apexpages.message(apexpages.severity.INFO, 'Please select object & a field.'));
                return pr;
            }
            if(isContactSelected && sSelectedContactField == null){
                apexpages.addmessage(new apexpages.message(apexpages.severity.INFO, 'Please select Contact field.'));
                return pr;
            }
            if(isAccountSelected && sSelectedAccountField == null){
                apexpages.addmessage(new apexpages.message(apexpages.severity.INFO, 'Please select Account field.'));
                return pr;
            }
            if(isLeadSelected && sSelectedLeadField == null){
                apexpages.addmessage(new apexpages.message(apexpages.severity.INFO, 'Please select Lead field.'));
                return pr;
            }
             
            if(Webhook_Setting__c.sObjectType.getDescribe().isAccessible() && Webhook_Setting__c.sObjectType.getDescribe().isCreateable()){
                Webhook_Setting__c objInwiseWebhookSetting = Webhook_Setting__c.getAll().get('default');
                if(objInwiseWebhookSetting == null && Webhook_Setting__c.sObjectType.getDescribe().isCreateable()){
                    objInwiseWebhookSetting = new Webhook_Setting__c();
                    if(Schema.sObjectType.Webhook_Setting__c.fields.Name.isUpdateable() && Schema.sObjectType.Webhook_Setting__c.fields.Name.isCreateable()){
                        objInwiseWebhookSetting.Name = 'default';
                    }
                }
                if(Schema.sObjectType.Webhook_Setting__c.fields.Contact_Field__c.isCreateable() && Schema.sObjectType.Webhook_Setting__c.fields.Contact_Field__c.isUpdateable()){
                    objInwiseWebhookSetting.Contact_Field__c = sSelectedContactField;
                }
                if(Schema.sObjectType.Webhook_Setting__c.fields.Account_Field__c.isCreateable() && Schema.sObjectType.Webhook_Setting__c.fields.Account_Field__c.isUpdateable()){
                    objInwiseWebhookSetting.Account_Field__c = sSelectedAccountField;
                }
                if(Schema.sObjectType.Webhook_Setting__c.fields.Lead_Field__c.isCreateable() && Schema.sObjectType.Webhook_Setting__c.fields.Lead_Field__c.isUpdateable()){
                    objInwiseWebhookSetting.Lead_Field__c = sSelectedLeadField;
                }
                if(Schema.sObjectType.Webhook_Setting__c.fields.Add_activity_to_all_records__c.isCreateable() && Schema.sObjectType.Webhook_Setting__c.fields.Add_activity_to_all_records__c.isUpdateable()){
                    objInwiseWebhookSetting.Add_activity_to_all_records__c = addActivityToAll;
                }
                if(Schema.sObjectType.Webhook_Setting__c.fields.Save_To_Activity_History__c.isCreateable() && Schema.sObjectType.Webhook_Setting__c.fields.Save_To_Activity_History__c.isUpdateable()){
                    objInwiseWebhookSetting.Save_To_Activity_History__c = isActivityHistorySelected;
                }
                if(Schema.sObjectType.Webhook_Setting__c.fields.Save_To_Messaging_History__c.isCreateable() && Schema.sObjectType.Webhook_Setting__c.fields.Save_To_Messaging_History__c.isUpdateable()){
                    objInwiseWebhookSetting.Save_To_Messaging_History__c = isMessageHistorySelected;
                }
                if(Webhook_Setting__c.sObjectType.getDescribe().isCreateable() && Webhook_Setting__c.sObjectType.getDescribe().isUpdateable()){
                    upsert objInwiseWebhookSetting;
                }
            }

            apexpages.addmessage(new apexpages.message(apexpages.severity.INFO, 'Saved Successfully'));
            isSaved = true;
        }catch(Exception ex){
            apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR, ex.getMessage()));
            isSaved = true;
        }

        return pr;
    }

    public PageReference doCancel(){
        PageReference pr;
       	String retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        if(retUrl != NULL && inwiseUtil.isValidRedirectUrl(retUrl)){
        //if (retUrl != null) {
            pr = new PageReference(retUrl);
            pr.setRedirect(true);
        }else{
            return gotoHome();
        }
        return pr;
    }

    public PageReference gotoHome(){
        PageReference pr = Page.inwiseHome;
        pr.setRedirect(true);
        return pr;
    }

    /**
     * Validates if the URL is a safe redirect target.
     * Allows only URLs within the current Salesforce domain.
    */
    private Boolean isValidRedirectUrl(String rURL) {
        // Get the current Salesforce domain
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        //System.debug('==baseUrl='+baseUrl);

        // Check if the URL starts with the Salesforce domain
        return rURL != null && rURL.startsWith(baseUrl);
    }
}