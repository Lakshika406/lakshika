/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 05/15/2018
*Purpose :     opt out button click functionality
 * Logs
 * -------------------------------------------------------------
 * Date(MM/DD/YY)       Version     Name                        Description
 * 06/30/2020           1.0.1       NLINEAXIS(Kapil Goutam)     added new fields for optput in custom setting & code for Toggle Email Opt-in/Opt-out & Toggle Mobile Opt-in/Opt-out section
 * 09/14/2020           1.1.4       NLINEAXIS(Kapil Goutam)     Modified:- 4 new fields for search in lead/contact email/mobile & added code to search without hyphen in phone
 * 03/12/2021           1.1.5       NLINEAXIS(Kapil Goutam)     Modified:- replaced 'incomingwebhooks' with 'inwiseUnsubscribe' in hostUrl
 * 05/20/2021           1.1.6       NLINEAXIS(Kapil Goutam)     Modified:- Added new "getHostUrl" method 
******************************************************************************************/
public with sharing class OptInOutConfigurationController {
  public List<SelectOption> listOfSelectOptionFields_Contact {get;set;}
  public List<SelectOption> listOfSelectOptionFields_Lead {get;set;}
  public List<SelectOption> listOfSOFields_ContactEmailOptinOutField {get;set;}
  public List<SelectOption> listOfSOFields_LeadEmailOptinOutField {get;set;}
  public List<SelectOption> listOfSOFields_ContactMobileOptinOutField {get;set;}
  public List<SelectOption> listOfSOFields_LeadMobileOptinOutField {get;set;}

  public List<SelectOption> listOfSelectOptionFields_Account {get;set;}
  public List<SelectOption> listOfSOFields_AccountEmailOptinOutField {get;set;}
  public List<SelectOption> listOfSOFields_AccountMobileOptinOutField {get;set;}
  public Boolean isSaved {get;set;}
  
  public inwiseLtngConstants objinwiseLtngConstants{get;set;}
  public inwiseUtil objInwiseUtil{get;set;}

  public String getHostUrl() {
    String str = inwiseUtil.hostUrl('inwiseUnsubscribe');
    return str;
  }
  // public String hostUrl{get{
  //       Schema.DescribeSObjectResult dsr = Landing_Sync__c.sObjectType.getDescribe();
  //       System.debug('==dsr=='+dsr);
  //       String namespacePrefix = dsr.getName().remove(dsr.getLocalName());
  //       System.debug('==namespacePrefix=='+namespacePrefix);
        
  //       String s = URL.getOrgDomainUrl().toExternalForm();
  //       if(namespacePrefix == 'inwise__'){
  //         s += '/services/apexrest/inwise/inwiseUnsubscribe';
  //       } else {
  //         s += '/services/apexrest/inwiseUnsubscribe';
  //       }
  //     	//s += '/services/apexrest/incomingwebhooks';
        
  //       return s;
  // }}
  public String activateFeatureLabel{get{
        return '**To activate this feature, please build automation in inwise that send webhook to: ';
  }}
  public OptInOutConfigurationController() {
      isSaved = false;
      objinwiseLtngConstants = new inwiseLtngConstants();
      objInwiseUtil=new inwiseUtil(NULL);
      listOfSelectOptionFields_Contact = new List<SelectOption>();
      listOfSelectOptionFields_Lead = new List<SelectOption>();
      listOfSOFields_ContactEmailOptinOutField = new List<SelectOption>();
      listOfSOFields_LeadEmailOptinOutField = new List<SelectOption>();
      listOfSOFields_ContactMobileOptinOutField  = new List<SelectOption>();
      listOfSOFields_LeadMobileOptinOutField  = new List<SelectOption>();

      listOfSelectOptionFields_Account = new List<SelectOption>();
      listOfSOFields_AccountEmailOptinOutField = new List<SelectOption>();
      listOfSOFields_AccountMobileOptinOutField = new List<SelectOption>();
      List<SelectOption> listOfSelectOptionFields_LeadTemp = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_LEAD,inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL,true);
      List<SelectOption> listOfSelectOptionFields_ContactTemp = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_CONTACT,inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL,true);
      List<SelectOption> listOfSelectOptionFields_AccountTemp = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_ACCOUNT,inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL,true);
      listOfSelectOptionFields_Contact.add(listOfSelectOptionFields_LeadTemp.get(0));
      listOfSelectOptionFields_Lead.add(listOfSelectOptionFields_ContactTemp.get(0));

      listOfSelectOptionFields_Account.add(listOfSelectOptionFields_AccountTemp.get(0));
      listOfSOFields_AccountEmailOptinOutField.add(listOfSelectOptionFields_AccountTemp.get(0));
      listOfSOFields_AccountMobileOptinOutField.add(listOfSelectOptionFields_AccountTemp.get(0));

      listOfSOFields_ContactMobileOptinOutField.add(listOfSelectOptionFields_ContactTemp.get(0));
      listOfSOFields_LeadMobileOptinOutField.add(listOfSelectOptionFields_ContactTemp.get(0));
      listOfSOFields_ContactEmailOptinOutField.add(listOfSelectOptionFields_ContactTemp.get(0));
      listOfSOFields_LeadEmailOptinOutField.add(listOfSelectOptionFields_ContactTemp.get(0));

//      listOfSelectOptionFields_Contact.add(new SelectOption('HasOptedOutOfEmail', 'Email Opt Out (boolean)'));
//      listOfSelectOptionFields_Lead.add(new SelectOption('HasOptedOutOfEmail', 'Email Opt Out (boolean)'));

      for(integer i=1; i<listOfSelectOptionFields_ContactTemp.size(); i++){
            if(listOfSelectOptionFields_ContactTemp.get(i).getLabel().contains('boolean')){
                listOfSelectOptionFields_Contact.add(listOfSelectOptionFields_ContactTemp.get(i));
            }
            if(listOfSelectOptionFields_ContactTemp.get(i).getLabel().contains('email')){
                listOfSOFields_ContactEmailOptinOutField.add(listOfSelectOptionFields_ContactTemp.get(i));
            }
            if(listOfSelectOptionFields_ContactTemp.get(i).getLabel().contains('phone')){
                listOfSOFields_ContactMobileOptinOutField.add(listOfSelectOptionFields_ContactTemp.get(i));
            }

      }
      for(integer i=1; i<listOfSelectOptionFields_LeadTemp.size(); i++){
            if(listOfSelectOptionFields_LeadTemp.get(i).getLabel().contains('boolean')){
                listOfSelectOptionFields_Lead.add(listOfSelectOptionFields_LeadTemp.get(i));
            }
            if(listOfSelectOptionFields_LeadTemp.get(i).getLabel().contains('email')){
                listOfSOFields_LeadEmailOptinOutField.add(listOfSelectOptionFields_LeadTemp.get(i));
            }
            if(listOfSelectOptionFields_LeadTemp.get(i).getLabel().contains('phone')){
                listOfSOFields_LeadMobileOptinOutField.add(listOfSelectOptionFields_LeadTemp.get(i));
            }
      }

      for(integer i=1; i<listOfSelectOptionFields_AccountTemp.size(); i++){
            if(listOfSelectOptionFields_AccountTemp.get(i).getLabel().contains('boolean')){
                listOfSelectOptionFields_Account.add(listOfSelectOptionFields_AccountTemp.get(i));
            }
            if(listOfSelectOptionFields_AccountTemp.get(i).getLabel().contains('email')){
              listOfSOFields_AccountEmailOptinOutField.add(listOfSelectOptionFields_AccountTemp.get(i));
            }
            if(listOfSelectOptionFields_AccountTemp.get(i).getLabel().contains('phone')){
              listOfSOFields_AccountMobileOptinOutField.add(listOfSelectOptionFields_AccountTemp.get(i));
            }
      }

    }

  public PageReference doSave(){
        PageReference pr;
        SchedulableContext ctx;
        try{
            if(Schema.sObjectType.Settings__c.isUpdateable()){
              Settings__c objSetting = new Settings__c(Id=objInwiseUtil.objInwiseSetting.Id);
              if(Schema.sObjectType.Settings__c.fields.Toggle_Email_Opt_in_Opt_out__c.isUpdateable()){
                objSetting.Toggle_Email_Opt_in_Opt_out__c = objInwiseUtil.objInwiseSetting.Toggle_Email_Opt_in_Opt_out__c;
              }
              if(Schema.sObjectType.Settings__c.fields.Toggle_Mobile_Opt_in_Opt_out__c.isUpdateable()){
                objSetting.Toggle_Mobile_Opt_in_Opt_out__c = objInwiseUtil.objInwiseSetting.Toggle_Mobile_Opt_in_Opt_out__c;
              }

              if(Schema.sObjectType.Settings__c.fields.Email_Unsubscribe_Contact_Field__c.isUpdateable()){
                objSetting.Email_Unsubscribe_Contact_Field__c = objInwiseUtil.objInwiseSetting.Email_Unsubscribe_Contact_Field__c;
              }
              if(Schema.sObjectType.Settings__c.fields.Email_Unsubscribe_Lead_Field__c.isUpdateable()){
                objSetting.Email_Unsubscribe_Lead_Field__c = objInwiseUtil.objInwiseSetting.Email_Unsubscribe_Lead_Field__c;
              }
              if(Schema.sObjectType.Settings__c.fields.Mobile_Unsubscribe_Contact_Field__c.isUpdateable()){
                objSetting.Mobile_Unsubscribe_Contact_Field__c = objInwiseUtil.objInwiseSetting.Mobile_Unsubscribe_Contact_Field__c;
              }
              if(Schema.sObjectType.Settings__c.fields.Mobile_Unsubscribe_Lead_Field__c.isUpdateable()){
                objSetting.Mobile_Unsubscribe_Lead_Field__c = objInwiseUtil.objInwiseSetting.Mobile_Unsubscribe_Lead_Field__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Contact_Email_Opt_in_Opt_out__c.isUpdateable()) {
                objSetting.Contact_Email_Opt_in_Opt_out__c = objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Contact_Email_Opt_in_Opt_out_Field__c.isUpdateable()) {
                objSetting.Contact_Email_Opt_in_Opt_out_Field__c = objInwiseUtil.objInwiseSetting.Contact_Email_Opt_in_Opt_out_Field__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Lead_Email_Opt_in_Opt_out__c.isUpdateable()) {
                objSetting.Lead_Email_Opt_in_Opt_out__c = objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Lead_Email_Opt_in_Opt_out_Field__c.isUpdateable()) {
                objSetting.Lead_Email_Opt_in_Opt_out_Field__c = objInwiseUtil.objInwiseSetting.Lead_Email_Opt_in_Opt_out_Field__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Contact_Mobile_Opt_in_Opt_out__c.isUpdateable()) {
                objSetting.Contact_Mobile_Opt_in_Opt_out__c = objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Contact_Mobile_Opt_in_Opt_out_Field__c.isUpdateable()) {
                objSetting.Contact_Mobile_Opt_in_Opt_out_Field__c = objInwiseUtil.objInwiseSetting.Contact_Mobile_Opt_in_Opt_out_Field__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Lead_Mobile_Opt_in_Opt_out__c.isUpdateable()) {
                objSetting.Lead_Mobile_Opt_in_Opt_out__c = objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Lead_Mobile_Opt_in_Opt_out_Field__c.isUpdateable()) {
                objSetting.Lead_Mobile_Opt_in_Opt_out_Field__c = objInwiseUtil.objInwiseSetting.Lead_Mobile_Opt_in_Opt_out_Field__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Contact_Email_Search_Field__c.isUpdateable()) {
                objSetting.Contact_Email_Search_Field__c = objInwiseUtil.objInwiseSetting.Contact_Email_Search_Field__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Contact_Mobile_Search_Field__c.isUpdateable()) {
                objSetting.Contact_Mobile_Search_Field__c = objInwiseUtil.objInwiseSetting.Contact_Mobile_Search_Field__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Lead_Email_Search_Field__c.isUpdateable()) {
                objSetting.Lead_Email_Search_Field__c = objInwiseUtil.objInwiseSetting.Lead_Email_Search_Field__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Lead_Mobile_Search_Field__c.isUpdateable()) {
                objSetting.Lead_Mobile_Search_Field__c = objInwiseUtil.objInwiseSetting.Lead_Mobile_Search_Field__c;
              }

              if (Schema.sObjectType.Settings__c.fields.Person_Account_Email_Opt_In_Out__c.isUpdateable()) {
                objSetting.Person_Account_Email_Opt_In_Out__c = objInwiseUtil.objInwiseSetting.Person_Account_Email_Opt_In_Out__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Person_Account_Email_Opt_In_Out_Field__c.isUpdateable()) {
                objSetting.Person_Account_Email_Opt_In_Out_Field__c = objInwiseUtil.objInwiseSetting.Person_Account_Email_Opt_In_Out_Field__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Person_Account_Mobile_Opt_In_Out__c.isUpdateable()) {
                objSetting.Person_Account_Mobile_Opt_In_Out__c = objInwiseUtil.objInwiseSetting.Person_Account_Mobile_Opt_In_Out__c;
              }
              if (Schema.sObjectType.Settings__c.fields.Person_Account_Mobile_Opt_In_Out_Field__c.isUpdateable()) {
                objSetting.Person_Account_Mobile_Opt_In_Out_Field__c = objInwiseUtil.objInwiseSetting.Person_Account_Mobile_Opt_In_Out_Field__c;
              }
              System.debug('objSetting::-->>>' + objSetting);
              update objSetting;
            }
            apexpages.addmessage(new apexpages.message(apexpages.severity.INFO, 'Saved Successfully'));    
            isSaved = true;  
        }catch(Exception ex){
            apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR, ex.getMessage()));    
            isSaved = true;  
        }
        
        return pr;
  }
  public PageReference doExecuteEmailUnsubscribe(){
      Settings__c objInwiseSetting = Settings__c.getAll().get('default');
      if(!String.isEmpty(objInwiseSetting.Opt_in_Out_to_Salesforce_Email_Job_Id__c)){
          try{
                  System.abortJob(objInwiseSetting.Opt_in_Out_to_Salesforce_Email_Job_Id__c);
                  if(Schema.sObjectType.Settings__c.fields.Opt_in_Out_to_Salesforce_Email_Job_Id__c.isUpdateable()){
                      objInwiseSetting.Opt_in_Out_to_Salesforce_Email_Job_Id__c = NULL;
                      update objInwiseSetting;
                  }
            }catch(Exception ex){
                  System.debug('abort failed::-->>>' + ex.getMessage());
            }
      }
      BatchCalloutUnsubscribe objBatchCalloutUnsubscribe = new BatchCalloutUnsubscribe ();
      objBatchCalloutUnsubscribe.init(ScheduleContactslistUnsubscribed.sChanelTypeEmail,1,true,null,null);
      Database.executeBatch(objBatchCalloutUnsubscribe,1);
      return null;
  }
  public PageReference doExecuteMobileUnsubscribe(){
      Settings__c objInwiseSetting = Settings__c.getAll().get('default');
      if(!String.isEmpty(objInwiseSetting.Opt_in_Out_to_Salesforce_Mobile_Job_Id__c)){
          try{
                  System.abortJob(objInwiseSetting.Opt_in_Out_to_Salesforce_Mobile_Job_Id__c);
                  if(Schema.sObjectType.Settings__c.fields.Opt_in_Out_to_Salesforce_Mobile_Job_Id__c.isUpdateable()){
                      objInwiseSetting.Opt_in_Out_to_Salesforce_Mobile_Job_Id__c = NULL;
                      update objInwiseSetting;
                  }
            }catch(Exception ex){
                  System.debug('abort failed::-->>>' + ex.getMessage());
            }
      }
      BatchCalloutUnsubscribe objBatchCalloutUnsubscribe = new BatchCalloutUnsubscribe ();
      objBatchCalloutUnsubscribe.init(ScheduleContactslistUnsubscribed.sChanelTypeSMS,1,true,null,null);
      Database.executeBatch(objBatchCalloutUnsubscribe,1);
      return null;
  }

  public PageReference doCancel(){
    PageReference pr;
    String retUrl = ApexPages.currentPage().getParameters().get('retUrl');
    if(retUrl != NULL && inwiseUtil.isValidRedirectUrl(retUrl)){
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

}