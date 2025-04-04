/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     class contains all constant for inwise app
================================================================
Modified On    Version    Modified By    Purpose
================================================================
27/01/2017     1.0.0      NLINEAXIS      Created
09/06/2021     1.1.0      NLINEAXIS      Modified:- Added new variable ORG_REST_API, METADATA_API_VERSION and ORGANIZATION_BASE_URL
14/06/2021     1.1.1      NLINEAXIS      Modified:- Added new variable ADVANCED_FEATURES_ALREADY, ADVANCED_FEATURES_ERROR and ADVANCED_FEATURES_ACTIVATED
20/06/2021     1.1.2      NLINEAXIS      Modified:- Added new variable MSG_SELECT_REPORT
28/06/2021     1.1.3      NLINEAXIS      Modified:- Added new variable INWISE_REPORT
30/08/2021     1.1.4      NLINEAXIS      Modified:- Added new variable UNSUBSCRIBE_MESSAGE AND UNABLE_TO_SEND_SMS
01/09/2021     1.1.5      NLINEAXIS      Modified:- Added new variable INVALID_NUMBER and SMS_SENT_SUCCESS
30/01/2023     1.1.6      NLINEAXIS      Modified:- Added new variable emailUnsubscribed and smsUnsubscribed
*/
public with sharing class inwiseConstants {
    
    public static final String SOBJECT_CONTACT = 'Contact';
    public static final String SOBJECT_LEAD = 'Lead';
    public static final String SOBJECT_ACCOUNT = 'Account';
    
    public static final Integer INWISE_FIELDID_EMAIL = 0; 
    public static final Integer INWISE_FIELDID_MOBILE = 1000;
    public static final Integer INWISE_FIELDID_PAGENAME = 1100;
    public static final String INWISE_FIELD_PAGENAME = 'Page name';
    
    public static final String INWISE_SERVICE_SCHEMA_BASEURL = 'http://www.inwise.com/schemas';
    public static final String INWISE_SERVICE_SCHEMA_BASEURL2 = 'http://www.inwise.com/webservices/v2';
    public static final String CONTENT_TYPE_UTF8 = 'text/xml; charset=utf-8';
    
    public static final Double METADATA_API_VERSION = 50.0; //Should be minimum 32.0
    public static final String ORG_REST_API = 'ORG_Rest_API';
    public static final String ORGANIZATION_BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();
    
    //************* Messages ******************************
    public static final String INWISE_REPORT = 'The search result count is more than 10 but showing only the first 10 reports.'; 
    public static final String INWISE_CREDENTIAL_MISSING = 'Please provide required credentials to connect'; 
    public static final String INWISE_ACCOUNT_MAPPING_MISSING = 'Please provide mapping for inwise account'; 
    public static final String INWISE_ACCOUNT_MISSING = 'Please map your SalseForce fileds into your inwise account fileds before synchronize your campaign members to inwise';
    public static final String SYNC_MEMBER_SUCCESS = 'Members were successfully sent to inwise and will be imported shortly';
    public static final String INWISE_MAPPING_SAVED_SUCCESS = 'Successfully saved';
    public static final String GENERIC_SUCCESS = 'Successfully Completed';
    public static final String INWISE_SENDID_MISSING = 'Inwise Sendid not defined';
    public static final String BAD_REQUEST = 'Bad Request';
    //public static final String INWISE_MISSING_FIELD_SALESFORCECAMPAIGNMEMBERID = 'Please add SalesForce Camp Member ID field in inwise before you map your inwise fields to SalesForce';
    //public static final String INWISE_FIELD_SALESFORCECAMPAIGNMEMBERID = 'SalesForce Camp Member ID';  //'SalesForceCampaignMemberID';
    public static final String MSG_NO_RESULT_CALL = 'No Result in Call';
    public static final String MSG_EXCEPTION_CALL = 'Exception Occured in Call';
    public static final String MSG_EXCEPTION_CAMPAIGN_NOT_CONNECTED = 'No inwise campagin is connected yet';

    //public static final String MSG_NO_VALID_RESULT_LOGON = 'Invalid session id or service url returned from logon.';
    public static final String MSG_SELECT_GROUP = 'Please select group';
    public static final String MSG_SELECT_OR_CREATE_GROUP = 'Please select group or provide a name to create new group';
    public static final String MSG_JOB_INPROGRESS = 'Start executing now, please go to home page to see the progress.';
    public static final String MSG_JOB_SCHEDULED ='Scheduled, Please go to home page to see the progress.';
    public static final String MSG_JOB_SCHEDULED_TIME_MISSING ='Please select time to schedule a Sync.';
    public static final String MSG_NO_CAMPAIGN_MEMBER_FOUND = 'You don’t have any member on this campaign yet, please add your members first';
    public static final String MSG_GROUP_NAME_ALREADY_EXIST = 'Group name already exist in inwise. You probably already sync this campaign. If you want to update you members in inwise, please change here your campaign name first and sync again.';
    public static final String MSG_PROCESS_STARTED = 'Process started';
    public static final String MSG_SELECT_VIEW = 'Please choose Salesforce view';
    public static final String MSG_SELECT_REPORT = 'Please choose Salesforce report';
    public static final String MSG_SELECTED_VIEW_DELETED = 'Selected view deleted for this Sync';
    public static final String MSG_JOB_CANCELED = 'Selected Sync scheduling canceled';
    public static final String MSG_JOB_CANCELED_NA = 'There is no existing job to cancel';
    public static final String MSG_ACCOUNT_SENDERID_MISSING = 'Sender name/number of you sms campaign is not allowed, to fix the problem you can change the value in account configuration page according the permitted values in inwise or you can leave blank in order to use the default in your inwise account';
    public static final String MSG_SYNC_CHECKBOX = 'Add the leads/contacts to group. If unchecked, existing leads/contacts records  will be deleted';
    public static final String emailUnsubscribed = 'EmailUnsubscribed';
    public static final String smsUnsubscribed = 'SmsUnsubscribed';

    public static final String ADVANCED_FEATURES_ALREADY = 'This Remote Site Name already exists or has been previously used. Please choose a different name';
    public static final String ADVANCED_FEATURES_ERROR = 'Some error occurred, please check error logs for more detail';
    public static final String ADVANCED_FEATURES_ACTIVATED = 'Advanced features are activated now';
    public static final String SCHEDULED_DAILY_AT = 'Please select Scheduled Daily At';
    public static final String UNSUBSCRIBE_MESSAGE = 'The mobile phone is unsubscribe in inwise';
    public static final String UNABLE_TO_SEND_SMS = 'Unable to send SMS, for more detail check message history';
    public static final String UNABLE_TO_SEND_EMAIL = 'Unable to send Email, for more detail check message history';
    public static final String INVALID_NUMBER = 'The number format is invalid';
    public static final String INVALID_EMAIL = 'The email is invalid';
    public static final String SMS_SENT_SUCCESS = 'SMS Sent Successfully';
    public static final String EMAIL_Error_MSG_FOR_Acc  = 'Email field not available on Account.';
    public static final string  MSG_SELECT_OR_CREATE_ACCOUNT = 'Please select a account';

    public enum CalloutResponse{
           NORESULT,
           EXCEPTIONOCCURED,
           SUCCESSFULL 
    }
    //************* Messages ******************************
}