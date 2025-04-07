/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     fuctions
//*Groups_CreateGroupResult
//*Recipients_RegularImport
//*class call these two method from external web service.
//Service url - http://api.inwise.com/inwisewebservices.asmx
Modification History
----------------------------------------------------------------
Date            By              Detail
----------------------------------------------------------------
* 12/10/2018     Kapil Goutam     Added SMS rest api for sms/activities & sms/sentSms
* 04/16/2021     Kapil Goutam     Added "additional_data" field for sms/activities & sms/sentSms
06/20/2024     NLINEAXIS(Kapil Goutam)     Modified:- Added changes for security check 
/******************************************************************************************/
public with sharing class SendToInwiseController {

    public String csrfToken { get; set; }
    // public String submittedToken { get; set; }
    public String ErrorMsg{get;set;}
    public Campaign objCampaign {get;set;} 
    public boolean isNeedToRedirectOnSetup {get;set;}
    public String setupPageUrl {get;set;}
    Account__c objInwiseAccount{get;set;}
    InwiseUtil objInwiseUtil{get;set;}
    public static String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
    public static String serviceNS = 'http://www.inwise.com/webservices/v2';
    public String  LIST_EmailFeedBackAction =  'EmailFeedBackAction';
    public String LIST_EmailSentMessage =  'EmailSentMessage';
    public String MSG_GROUP_NAME_ALREADY_EXISTS = 'Group name already exists';
    public inwiseLtngConstants objinwiseLtngConstants{get;set;}
    //this is decalred here because of recursive call of 
    public Map<Id, CampaignMember> mapOfCampaignMemberToUpdate{get;set;}
    
    String newLineFeed = '\n';
    //*******************************************************************
    //METHOD: Contructor 
    //*******************************************************************
    public SendToInwiseController(ApexPages.StandardController std){
        System.debug('==SendToInwiseController=1=');
       
        csrfToken = inwiseUtil.generateCSRFToken(); // Generate a unique token
        isNeedToRedirectOnSetup= false;
        objinwiseLtngConstants = new inwiseLtngConstants();
        mapOfCampaignMemberToUpdate = new Map<Id, CampaignMember>(); 
        Id cid;
        if(objinwiseLtngConstants.isLightning){
            cid = std.getRecord().ID;
        }else{
            cid = ApexPages.currentPage().getParameters().get('Id'); 
        }
        if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.fields.Account__c.isAccessible() && 
            Schema.sObjectType.Campaign.fields.Sendid__c.isAccessible() && Schema.sObjectType.Campaign.fields.Campaign_Type__c.isAccessible()){
            List<Campaign> listOfCampaign = [Select Id,name,Account__c,Sendid__c,Campaign_Type__c from Campaign where Id=:cid WITH SECURITY_ENFORCED];
            if(listOfCampaign != NULL && !listOfCampaign.isEmpty()){
                objCampaign = getFirstIndexRec(listOfCampaign);//listOfCampaign.get(0);
                objInwiseAccount = GetInwiseAccount(false,null);
            }
        }  
        
        
    }
    public static Campaign getFirstIndexRec(List<Campaign> listOfCampaign){
        Campaign camRec;
        for(Campaign camp : listOfCampaign){
            camRec = camp;
            break;
        }
        return camRec;
    }

    //constructor for scheduled job
    public SendToInwiseController(boolean isScheduled,String accountid){
        mapOfCampaignMemberToUpdate = new Map<Id, CampaignMember>();
        objInwiseAccount = GetInwiseAccount(isScheduled, accountid);
    }

    //=====================================================================================================================//
    //Method calling from the page JS on load method.
    //1.InwiseCalloutGroupsCreateGroup
    //-------------------------
    //Call Groups_CreateGroup & get groupid
    //take group id & pas this in Recipients_RegularImport, this will return either sync member success or not.

    //2.InwiseCalloutStatisticsGetMessageResults
    //-----------------------
    //Call Statistics_GetMessageResults & get result. Update campaign fields, Opened__c, Sent__c, Bounced__c, Clicked__c


    //3.InwiseCalloutLogon
    //-----------------------
    //Call Logon method & get next request service url & session.
    //Call List method & get RecipientId from this.
    //Call Pass all RecipientId one by one & call Recipients_GetById method.- this call will return a campaign member id in field 20.
    //update all campaign member fields(Opened__c, Bounced__c, Clicked__c,Unsubscribe__c) which is in field 20 by the action number which is, we get in List call.
    //=====================================================================================================================//
    public pageReference OnLoad(){
        System.debug('==OnLoad=1=');
        

        ErrorMsg = '';
        string actionType=ApexPages.currentPage().getParameters().get('action');
        string campaignId = ApexPages.currentPage().getParameters().get('Id');
        String csrfTokenValue = ApexPages.currentPage().getParameters().get('csrfToken'); // Get CSRF token from request
        System.debug('==actionType=1='+actionType);
        System.debug('==campaignId=1='+campaignId);
        if (csrfTokenValue == null || !inwiseUtil.validateCSRFToken(csrfTokenValue)) {
            ErrorMsg = 'Invalid CSRF token. Action cannot be performed.';
            return null;
        }

        OnLoad(campaignId,actionType);        
        return null;
    }

    public pageReference OnLoad(string campaignId,string actionType){

        System.debug('==OnLoad=2=');
        ErrorMsg = '';
        if(actionType != NULL){
            actionType = actionType.tolowercase();
            if(actionType == 'sendmember' && String.isNotBlank(campaignId)){
                Decimal totalCount = getCampaignMembersCount(campaignId);
                if(totalCount > 0){
                    InwiseCalloutGroupsCreateGroup();
                }else{
                    ErrorMsg = inwiseConstants.MSG_NO_CAMPAIGN_MEMBER_FOUND;     
                    return null;    
                }
            }else if(actionType == 'inwisestatistics'){
                InwiseCalloutStatisticsGetMessageResults();
            }else if(actionType == 'inwisemembersactions'){
                doClickMemberAction(false, campaignId);
            }
        }   
        return null;
    }

    public Decimal getCampaignMembersCount(String campaignId){
        Decimal totalCount = 0;    
        List<Campaign> listOfCampaign = new List<Campaign>();
        //if(Schema.sObjectType.Campaign.isAccessible()){
        if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.fields.Total_Member_Count__c.isAccessible()){
            listOfCampaign = [SELECT Id,Total_Member_Count__c FROM Campaign where Id  =: campaignId WITH SECURITY_ENFORCED];   
        }
        if(!listOfCampaign.isEmpty()){
            totalCount = listOfCampaign.get(0).Total_Member_Count__c;
        }
        return totalCount;

    }

    private Account__c GetInwiseAccount(boolean isScheduled, String accountid){
        Account__c objInwiseAccount;
        if(isScheduled == false){
            if(objCampaign.Account__c != NULL){
                accountid = objCampaign.Account__c;
            }
        }
        //if(Schema.sObjectType.Account__c.isAccessible()){
        
        if(accountid != NULL){
            if (Schema.sObjectType.Account__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Password__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Token__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.User_Name__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.ListEmailFeedBackActionMaxId__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.ListEmailSentMessageMaxId__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.SMS_Sender__c.isAccessible()) {

                objInwiseAccount = [SELECT Id,Name,Password__c,Token__c,User_Name__c,ListEmailFeedBackActionMaxId__c,ListEmailSentMessageMaxId__c,SMS_Sender__c FROM Account__c WHERE ID=:accountid limit 1];
            }
        }else{
            if (Schema.sObjectType.Account__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Default__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Password__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Token__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.User_Name__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.ListEmailFeedBackActionMaxId__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.ListEmailSentMessageMaxId__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.SMS_Sender__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.isAccessible() && 
                Schema.sObjectType.Mapping__c.fields.inwise_Field__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.inwise_FieldId__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Object_Type__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isAccessible()) {

                List<Account__c> listOfInwiseAccount = [SELECT Id,Name,Password__c,Token__c,User_Name__c,ListEmailFeedBackActionMaxId__c,ListEmailSentMessageMaxId__c, SMS_Sender__c, (SELECT inwise_Field__c,inwise_FieldId__c,Object_Type__c,Salesforce_Field__c FROM Mapping__r) FROM Account__c where Default__c= true limit 1];
                if(!listOfInwiseAccount.isEmpty() && listOfInwiseAccount.get(0).Mapping__r.Size()>0){
                    objInwiseAccount = listOfInwiseAccount.get(0);
                }
            }
        }
        //}    
        return objInwiseAccount;
    }

    //*******************************************************************
    //METHOD: InwiseCalloutGroupsCreateGroup
    //this method called at the time of page load & fire two http request & process response
    //*******************************************************************
    public void InwiseCalloutGroupsCreateGroup (){
        List<Logs__c> listOfLogs = new List<Logs__c>();
        AggregateResult[] objInwiseFields;
        List<Mapping__c> listOfInwiseMapping;
        objInwiseUtil = new InwiseUtil(objInwiseAccount);
        
        if(!objInwiseUtil.CheckIfCredentialExists()){
            ErrorMsg = InwiseConstants.INWISE_CREDENTIAL_MISSING;
            return;
        }
        if(objInwiseAccount != NULL){
            if (Schema.sObjectType.Account__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Password__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Token__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.User_Name__c.isAccessible() &&
                Schema.sObjectType.Account__c.fields.SMS_Sender__c.isAccessible()) {

                objInwiseAccount = [SELECT Id,Name,Password__c,Token__c,User_Name__c,SMS_Sender__c FROM Account__c WHERE ID=:objInwiseAccount.Id limit 1];
            }

            if (Schema.sObjectType.Mapping__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.inwise_Field__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.inwise_FieldId__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Object_Type__c.isAccessible() &&
                Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isAccessible()) {
    
                listOfInwiseMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c from Mapping__c where Account__c=:objInwiseAccount.Id];

            }
            objInwiseFields = [SELECT inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:objInwiseAccount.Id  group by inwise_FieldId__c,inwise_Field__c];
        }
        if(listOfInwiseMapping == NULL || listOfInwiseMapping.isEmpty()){
            ErrorMsg = InwiseConstants.INWISE_ACCOUNT_MAPPING_MISSING;
            isNeedToRedirectOnSetup = true;
            PageReference pr = Page.InwiseHome;
            setupPageUrl = pr.getUrl();
            setupPageUrl = Url.getSalesforceBaseUrl().toExternalForm()+ setupPageUrl;
            return;
        }
        
        //prepare map for mapping vales
        Map<string,Mapping__c> mapInwiseMapping = new Map<string,Mapping__c>();
        for(Mapping__c oMapping:listOfInwiseMapping){
            string key= oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
            mapInwiseMapping.put(key,oMapping);
        }
        InwiseCalloutGroupsCreateGroupMobile(objInwiseFields,listOfInwiseMapping, mapInwiseMapping,listOfLogs);
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        }
    }

    public String getCampaignName(){
        String campaignname = '';
        //fixed Name:NameLengthExeceeded issue in cae of campaign name > 111
        if(objCampaign.Name.length() > 40){
            campaignname = objCampaign.Name.substring(0,40);
        }else{
            campaignname = objCampaign.Name;
        }
        return campaignname;
    }

    public void InwiseCalloutGroupsCreateGroupMobile (AggregateResult[] objInwiseFields,List<Mapping__c> listOfInwiseMapping,Map<string,Mapping__c> mapInwiseMapping,List<Logs__c> listOfLogs){
        Http http = new Http();
        HttpResponse res;
        integer grpId = 0;
        WrapperResult objWrapperResult;

        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contactsGroups/externalAppGeneric?group_name='+ EncodingUtil.urlEncode(getCampaignName(),'utf-8');
        HttpRequest req = objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint); 
        req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);        
        req.setBody('');//set blank body
       
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups/externalAppGeneric','SendToInwiseController','InwiseCalloutGroupsCreateGroupMobile'));
            }else{
                String resBody = '{"group_id": "642084"}';   
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'text/xml');
            }

            if(!String.isEmpty(res.getBody())){
                if(res.getStatusCode() == 200){
                    JSON2ApexGroupId objJSON2ApexGroupId = (JSON2ApexGroupId)JSON.deserialize(res.getBody(), JSON2ApexGroupId.class);  
                    grpId = Integer.valueOf(objJSON2ApexGroupId.group_id);
                }else{
                    ErrorMsg = res.getBody().replace('"','');
                }
            }
            
            if(grpid != 0){
                if(objCampaign.Campaign_Type__c == 'Mobile'){
                    //objWrapperResult = CreateMobileMessageLogon(listOfLogs);    
                    objWrapperResult = CreateMobileMessageJSON(listOfLogs);
                }
                else if (objCampaign.Campaign_Type__c == 'WhatsApp') {
                    objWrapperResult = CreateWhatsAppMessageJSON(listOfLogs); // New method for WhatsApp
                }
                else{
                    //fixed Name:NameLengthExeceeded issue in cae of campaign name > 111
                    objWrapperResult= getSendIdCampaign(getCampaignName(),listOfLogs);
                }
                //in both cases Sendid__c needs to update
                if(Schema.sObjectType.Campaign.fields.Sendid__c.isUpdateable()){
                    if(objWrapperResult.isSuccess){
                        objCampaign.Sendid__c = objWrapperResult.resultSendId;
                    }
                }
               
                if(!objWrapperResult.isSuccess){
                    //special case where need to show different message to user
                    if(objWrapperResult.msg == 'Unprocessable Entity'){
                        ErrorMsg = inwiseConstants.MSG_ACCOUNT_SENDERID_MISSING;
                    }else{
                        ErrorMsg = objWrapperResult.msg;
                    }
                    return;
                }
                if(Schema.sObjectType.Campaign.fields.Groupid__c.isUpdateable()){
                    objCampaign.Groupid__c = grpId;
                }
                if(Schema.sObjectType.Campaign.isUpdateable()){
                    update objCampaign;
                }  

                List<Campaign> listOfCampaign = new List<Campaign>();
                if (Schema.sObjectType.Campaign.isAccessible() &&
                    Schema.sObjectType.Campaign.fields.Id.isAccessible() &&
                    Schema.sObjectType.Campaign.fields.Name.isAccessible() &&
                    Schema.sObjectType.Campaign.fields.Total_Member_Count__c.isAccessible()) {

                    listOfCampaign = [select id,name,Total_Member_Count__c from Campaign where id =:objCampaign.id];

                }

                boolean IsSuccess = doInsertMemberInWrapperObject(listOfCampaign,grpId);
                if(IsSuccess){
                    ErrorMsg = 'Sync started!'; 
                }else{
                    ErrorMsg = 'Seems no members in the campaign!'; 
                }
            }
        }catch(Exception ex){
            ErrorMsg = 'Exception Occurred!'; 
        }   
    }

    public boolean doInsertMemberInWrapperObject(List<Campaign> listOfCampaign, Integer grpId){
       boolean IsSuccess = false;
       Integer batchsize = objInwiseUtil.getBatchSize();
       Sync_Members__c objSyncMember;

       if(!listOfCampaign.isEmpty()){
            Campaign objCampaign = listOfCampaign.get(0);
                 
            if(objCampaign.Total_Member_Count__c >0){
                Sync_Master__c objSyncMaster = new Sync_Master__c();
                if(Schema.sObjectType.Sync_Master__c.fields.Campaign__c.isCreateable()){
                    objSyncMaster.Campaign__c = objCampaign.Id;
                }
                if(Schema.sObjectType.Sync_Master__c.fields.Group_Id__c.isCreateable()){
                    objSyncMaster.Group_Id__c = grpId;
                }
                if(Schema.sObjectType.Sync_Master__c.fields.Total_Memerbs_Count__c.isCreateable()){
                    objSyncMaster.Total_Memerbs_Count__c = objCampaign.Total_Member_Count__c;
                }
                if(Schema.sObjectType.Sync_Master__c.fields.Track_Members_When_Sync_Started__c.isCreateable()){
                    objSyncMaster.Track_Members_When_Sync_Started__c = objInwiseUtil.objInwiseSetting.Track_Logs__c;
                }
                if(Schema.SObjectType.Sync_Master__c.isCreateable()){
                    insert objSyncMaster;
                }

                IsSuccess = true;
                BatchSendMemberToInwise objBatchSendMemberToInwise = new BatchSendMemberToInwise();
                objBatchSendMemberToInwise.init(objSyncMaster.Id,objCampaign.Id,false,true);
                Database.executeBatch(objBatchSendMemberToInwise,objInwiseUtil.getBatchSize());
            } 
        }
        return IsSuccess;
    }

    public WrapperResult CreateMobileMessageJSON(List<Logs__c> listOfLogs){
        WrapperResult objWrapperResult = new WrapperResult();
        Http http = new Http();
        HttpResponse res;
        HttpRequest req; 

        try{
            String endpoint = objInwiseUtil.apiUrl + '/rest/v1/campaigns/sms'; 
            req = objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint);
            req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);
            //fixed Name:NameLengthExeceeded issue in cae of campaign name > 111
            req.setBody(getCreateSMSJSON(getCampaignName()));
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/campaigns/sms','SendToInwiseController','CreateMobileMessageJSON'));
            }else{
                String resBody = '{ "name": "Test Camp 19Feb-v3", "body": "string", "charset": "unicode", "tags": [ "string" ], "validity_minutes": 1440, "sender": "972546414000", "track_links": false, "unsubscribed_text": "string", "add_unsubscribe": false, "reply_to_unsubscribe": false, "campaign_id": 25921, "create_date": "2018-02-19 13:53:00", "update_date": "2018-02-19 13:53:00", "reply_to_unsubscribe_code": "", "reply_to_unsubscribe_text": "" }';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res.getStatusCode() == 200){
                objWrapperResult.isSuccess = true;
                objWrapperResult.msg = InwiseConstants.SYNC_MEMBER_SUCCESS;
                if(res.getBody() != null){
                    JSONParser parser = JSON.createParser(res.getBody());
                    while (parser.nextToken() != null) {
                        
                        if(parser.getCurrentName() == 'campaign_id' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                            parser.nextToken();
                            objWrapperResult.resultSendId =  parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                            break;
                        }
                    }
                }
            }else{
                objWrapperResult.isSuccess = false;
                objWrapperResult.msg = res.getStatus();
            }
        }catch(Exception ex){
            String resBody = ex.getMessage();
            res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/campaigns/sms','SendToInwiseController','CreateMobileMessageJSON'));
            objWrapperResult.isSuccess = false;
            objWrapperResult.msg = resBody;
        }
        return objWrapperResult;
    }

    public String getCreateSMSJSON(String campaignname){
        String s = '{';
        s += '"name": "'+ campaignname +'",';
        //s += '"body": "string",';
        s += '"charset": "unicode",';
        s += '"tags": [';
        s += '"Salesforce"';
        s += '],';
        s += '"validity_minutes": 0,';
        s += '"sender": "'+ (objInwiseUtil.objInwiseAccount.SMS_Sender__c != NULL ? objInwiseUtil.objInwiseAccount.SMS_Sender__c : '') +'",';
        s += '"track_links": true,';
        //s += '"unsubscribed_text": "string",';
        s += '"add_unsubscribe": true,';
        s += '"reply_to_unsubscribe": true';
        return s;
    }
    
    public WrapperResult getSendIdCampaign(String CampaignName, List<Logs__c> listOfLogs){

        Http http = new Http();
        WrapperResult objWrapperResult = new WrapperResult();
        HttpResponse res;
        integer sendid = 0;
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/campaigns/email'; 
        //string soapBody = getXMLReuestForCreateNewMessage(CampaignName);
        string soapBody = getJSONReuestForCreateNewMessage(CampaignName);
        HttpRequest req = objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint); 
        req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);    
        req.setBody(soapBody);

        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/campaigns/email_create','SendToInwiseController','getSendIdCampaign'));
            }else{
                //String resBody = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><Messages_CreateNewMessageResponse xmlns="http://www.inwise.com/schemas"><Messages_CreateNewMessageResult>1099846</Messages_CreateNewMessageResult></Messages_CreateNewMessageResponse></soap:Body></soap:Envelope>';
                String resBody = '{ "campaign_id": 1220650, "name": "Campaign 23 feb -6", "html": "string", "subject": "string", "from_email": "newsletter@return-email.com", "reply_to": "shaic27@inwise.com", "from_name": "string", "charset": "utf-8", "content_type": "Html", "tags": [ "string" ], "google_analytics_campaign": null, "attachments_mapping": null, "allow_sending_for_contact_with_no_value": false, "delete_files_after_sending": false, "http_attachments_mapping": [ 0 ], "http_allow_sending_for_contact_with_no_value": true, "google_analytics": "", "use_personalized_attachment": false, "to_name": "", "is_onSite_tracking": false, "onSite_tracking_timeout": null, "attachment_file_data": "", "attachment_file_name": "", "create_date": "2018-02-23 07:15:00", "update_date": "2018-02-23 07:15:00" }';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'text/xml'); 
            } 

            if(res.getStatusCode() == 200){
                if(res.getBody() != NULL){
                    JSONParser parser = JSON.createParser(res.getBody());
                    while (parser.nextToken() != null) {
                        if(parser.getCurrentName() == 'campaign_id' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                            parser.nextToken();
                            sendid =  parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                            objWrapperResult.isSuccess = true;
                            objWrapperResult.resultSendId = sendid;
                            break;
                        }
                    }     
                }
            }else{
                objWrapperResult.isSuccess = false;
                objWrapperResult.msg = res.getBody();
            } 
        }catch(Exception ex){
            //ErrorMsg = 'Exception Occured!'; 
            objWrapperResult.isSuccess = false;
            objWrapperResult.msg = ex.getMessage();
        }
        return objWrapperResult;
    }
  
    public string getJSONReuestForCreateNewMessage(String CampaignName){
        String sJson=   '{';
        sJson +=  '"name": "'+ CampaignName+'",'; 
        sJson += '"html": "string",';
        sJson += '"subject": "'+ CampaignName +'",';
        sJson += '"from_email": "",';
        sJson +=  '"reply_to": "",';
        sJson += '"from_name": "string",';
        sJson += '"charset": "utf-8",';
        sJson += '"content_type": "html",';
        sJson += '"tags": ["SalesForce"],';
        sJson += '"google_analytics_campaign": "",';
        sJson += '"attachments_mapping": [';
        sJson += '0';
        sJson += '],';
        sJson += '"allow_sending_for_contact_with_no_value": true,';
        sJson += '"delete_files_after_sending": true,';
        sJson += '"http_attachments_mapping": [';
        sJson += '0';
        sJson += '],';
        sJson += '"http_allow_sending_for_contact_with_no_value": true,';
        sJson += '"google_analytics": "",';
        sJson += '"use_personalized_attachment": true,';
        sJson += '"to_name": "",';
        sJson += '"is_onSite_tracking": true,';
        sJson += '"onSite_tracking_timeout": 0,';
        sJson += '"attachment_file_data": "",';
        sJson += '"attachment_file_name": ""';
        sJson += '}';
        return sJson;
    }

  public WrapperResult CreateWhatsAppMessageJSON(List<Logs__c> listOfLogs) {
    WrapperResult objWrapperResult = new WrapperResult();
    Http http = new Http();
    HttpResponse res;
    HttpRequest req;

    try {
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/campaigns/whatsapp';
        req = objInwiseUtil.GetHTTPRequest('POST', 'application/json', endpoint);
        req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken);
        
        // Generate JSON payload for WhatsApp
        req.setBody(getCreateWhatsAppJSON(getCampaignName()));
         //System.debug('APIsss Response: ' + res.getBody());
          

        if (!Test.isRunningTest()) {
            res = http.send(req);
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/campaigns/whatsapp', 'SendToInwiseController', 'CreateWhatsAppMessageJSON'));
            System.debug('listOfLogs: ' + listOfLogs);

            System.debug('API Response: ' + res.getBody());
            System.debug('Status Code: ' + res.getStatusCode());

        } else {
            String resBody = '{ "campaign_id": 12345, "status": "success" }';
            res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            System.debug('API Response2: ' + res.getBody());
            System.debug('Status Code2: ' + res.getStatusCode());
        }

        if (res.getStatusCode() == 200) {
            objWrapperResult.isSuccess = true;
            objWrapperResult.msg = InwiseConstants.SYNC_MEMBER_SUCCESS;
            
            // Extract campaign_id from response
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if (parser.getCurrentName() == 'campaign_id' && parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    parser.nextToken();
                    objWrapperResult.resultSendId = parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                    break;
                }
            }
        } else {
            objWrapperResult.isSuccess = false;
            objWrapperResult.msg = res.getStatus();
        }
    } catch (Exception ex) {
        String resBody = ex.getMessage();
        res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
        listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/campaigns/whatsapp', 'SendToInwiseController', 'CreateWhatsAppMessageJSON'));
        objWrapperResult.isSuccess = false;
        objWrapperResult.msg = resBody;
    }
    return objWrapperResult;
}
public String getCreateWhatsAppJSON(String campaignName) {
    String s = '{';
    s += '"name": "'+ campaignName +'",';
    s += '"tags": ["SalesForce"],';
   // s += '"sender": "'+ (objInwiseUtil.objInwiseAccount.WhatsApp_Sender__c != NULL ? objInwiseUtil.objInwiseAccount.WhatsApp_Sender__c : '') +'",';
    s += '"validity_minutes": 0,';
    s += '"charset": "Unicode",';
    s += '"track_links": true,';
    s += '"add_unsubscribe": true,';
    s += '"reply_to_unsubscribe": true';
    s += '}';
    return s;
}



    //in case of button click, call it only for that campaign
    public void  doClickMemberAction(boolean isNeedToScheduleNextHour, Id campaignId){

        Set<Id> setOfCampaign = new Set<Id>();
        InwiseUtil objInwiseUtil = new InwiseUtil(null);
        Datetime dtNow = Datetime.newInstance(Datetime.now().date(), Datetime.now().time());
        Datetime lastDTUTC;

        if(campaignId != null){
            //List<Campaign> listOfCampaign = [Select Id,CreatedDate from Campaign where Id=:campaignId LIMIT 1];
            List<Campaign> listOfCampaign = new List<Campaign>();
            if (Schema.sObjectType.Campaign.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Id.isAccessible() ) {

                listOfCampaign = [Select Id,CreatedDate from Campaign where Id=:campaignId LIMIT 1];

            }

            if(!listOfCampaign.isEmpty()){
                lastDTUTC = listOfCampaign.get(0).CreatedDate.addDays(-1);
                //lastDTUTC = DateTime.newInstance(2020, 6, 6, 3, 3, 3);
            }else{
                lastDTUTC =  Datetime.now().addYears(-1);
                //lastDTUTC = DateTime.newInstance(2020, 6, 6, 3, 3, 3);
            }
        }else{
            if(objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Last_Run_On__c != null){
                
                //lastDTUTC = DateTime.newInstance(objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Last_Run_On__c.year(), objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Last_Run_On__c.month(), objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Last_Run_On__c.day(),objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Last_Run_On__c.hour(), objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Last_Run_On__c.minute(),objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Last_Run_On__c.second());
                //Boaz (this way we retrive the date and time object from DB  and then take the GMT part of it to use it):
                //lastDTUTC = DateTime.newInstance(2020, 6, 6, 3, 3, 3); 
                lastDTUTC = DateTime.newInstance(objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Last_Run_On__c.dateGmt(), objInwiseUtil.objInwiseSetting.Campaign_Member_Action_Last_Run_On__c.timeGmt());
            }
        }

        List<Members_Action__c> listOfMemberActions = new List<Members_Action__c>();
        List<Campaign> listCampaignsToInsert;
        Boolean isCalledByButtonClick = false;
        if(campaignId == null){
            if (Schema.sObjectType.Campaign.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Id.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Name.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Account__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Sendid__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Campaign_Type__c.isAccessible()) {

                listCampaignsToInsert = [SELECT Id,Name,Account__c,Sendid__c,Campaign_Type__c FROM Campaign where (Campaign_Type__c = 'Email' Or Campaign_Type__c = 'Mobile' Or Campaign_Type__c = 'Whatsapp') AND Sendid__c != NULL AND CreatedDate = LAST_N_DAYS:30];
            }
        }else{
            if (Schema.sObjectType.Campaign.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Id.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Name.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Account__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Sendid__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.Campaign_Type__c.isAccessible()) {

                listCampaignsToInsert = [SELECT Id,Name,Account__c,Sendid__c,Campaign_Type__c FROM Campaign where (Campaign_Type__c = 'Email' Or Campaign_Type__c = 'Mobile' Or Campaign_Type__c = 'Whatsapp') AND Sendid__c != NULL AND Id =:campaignId];
            }
            isCalledByButtonClick = true;
        }

        if(!listCampaignsToInsert.isEmpty()){
            for(Campaign c: listCampaignsToInsert){
                if(Members_Action__c.sObjectType.getDescribe().isAccessible() && Members_Action__c.sObjectType.getDescribe().isCreateable()){
                    Members_Action__c member = new Members_Action__c();
                    if(Schema.sObjectType.Members_Action__c.fields.Campaign__c.isAccessible() && Schema.sObjectType.Members_Action__c.fields.Campaign__c.isCreateable()){
                        member.Campaign__c=c.Id;
                    }
                    if(Schema.sObjectType.Members_Action__c.fields.Execution_Date_Time__c.isAccessible() && Schema.sObjectType.Members_Action__c.fields.Execution_Date_Time__c.isCreateable()){
                        member.Execution_Date_Time__c=dtNow;
                    }
                    if(Schema.sObjectType.Members_Action__c.fields.From_Date__c.isAccessible() && Schema.sObjectType.Members_Action__c.fields.From_Date__c.isCreateable()){
                        member.From_Date__c=lastDTUTC;
                    }
                    if(Schema.sObjectType.Members_Action__c.fields.Is_Called_By_Button_Click__c.isAccessible() && Schema.sObjectType.Members_Action__c.fields.Is_Called_By_Button_Click__c.isCreateable()){
                        member.Is_Called_By_Button_Click__c=isCalledByButtonClick;
                    }
                    listOfMemberActions.add(member);
                    setOfCampaign.add(c.Id);
                }
            }
            if(!setOfCampaign.isEmpty()){
                List<Members_Action__c> listOfMemberActionToDelete = new List<Members_Action__c>();
                if (Schema.sObjectType.Members_Action__c.isAccessible() &&
                    Schema.sObjectType.Members_Action__c.fields.Id.isAccessible() &&
                    Schema.sObjectType.Members_Action__c.fields.Campaign__c.isAccessible()) {

                    listOfMemberActionToDelete = [Select Id from Members_Action__c where Campaign__c IN : setOfCampaign];
                }
                if(Members_Action__c.SObjectType.getDescribe().isDeletable()){
                    if(listOfMemberActionToDelete != null && !listOfMemberActionToDelete.isEmpty()){
                        delete listOfMemberActionToDelete;
                    }
                }
                
            }
        }
         
        if(Members_Action__c.sObjectType.getDescribe().isCreateable()){
            if(!listOfMemberActions.isEmpty()){
                insert listOfMemberActions;
                if(!listOfMemberActions.isEmpty()){
                    for(Members_Action__c ma:listOfMemberActions){
                        BatchCampaignMemberActionStep1 objBatchCampaignMemberActionStep1 = new BatchCampaignMemberActionStep1();
                        objBatchCampaignMemberActionStep1.init(1,ma.Id,isNeedToScheduleNextHour);
                        Database.executeBatch(objBatchCampaignMemberActionStep1,1);
                        
                        BatchCampaignMemberActionStep2 objBatchCampaignMemberActionStep2 = new BatchCampaignMemberActionStep2();
                        objBatchCampaignMemberActionStep2.init(1,ma.Id,isNeedToScheduleNextHour);
                        Database.executeBatch(objBatchCampaignMemberActionStep2,1);
                    }
                }
            }
        }
        ErrorMsg = inwiseConstants.MSG_PROCESS_STARTED;
    }

    //=========================================//
    //== Callout - Statistics_GetMessageResults
    //called on Campaign Statistics
    //=========================================//
    public void InwiseCalloutStatisticsGetMessageResults(){
        List<Logs__c> listOfLogs = new List<Logs__c>();
        objInwiseUtil = new InwiseUtil(objInwiseAccount);
        
        if(!objInwiseUtil.CheckIfCredentialExists()){
            ErrorMsg = InwiseConstants.INWISE_CREDENTIAL_MISSING;
            return;
        }
        
        if(objCampaign == NULL || objCampaign.Sendid__c == NULL || objCampaign.Sendid__c == 0){
            ErrorMsg = InwiseConstants.INWISE_SENDID_MISSING;
            return;
        }else{
            string sendId ;
            if (objCampaign != null && objCampaign.Sendid__c != null) {
                sendId = string.valueof(objCampaign.Sendid__c);
            }
            
            Http http = new Http();
            HttpResponse res;
            integer grpId = 0;
            String callType = '';
            if(objCampaign.Campaign_Type__c == 'Mobile'){
                callType = 'sms';
            }
            else if (objCampaign.Campaign_Type__c == 'WhatsApp') {
                callType = 'whatsapp';
            }
            else{
                callType = 'email';
            }
            String endpoint ;// + sendId;
            if (objInwiseUtil.apiUrl != null) {
                endpoint = objInwiseUtil.apiUrl + '/rest/v1/campaigns/'+ callType +'/activitiesSummary?campaign_id='+sendId;// + sendId;
            }
            
            HttpRequest req = objInwiseUtil.GetHTTPRequest('GET','application/json',endpoint); 
            req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);     

            try{
                if(!Test.isRunningTest()){
                    res = http.send(req);
                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/campaigns/'+ callType+'/activitiesSummary','SendToInwiseController','InwiseCalloutStatisticsGetMessageResults'));
                }else{
                    String resBody = '{ "opens": 1, "opens_unique": 2, "clicks": 3, "clicks_unique": 5, "sent": 0, "undelivered": 5, "bounces": 0, "bounces_unique": 0, "webversions_unique": 0, "unsubscribes": 0, "unsubscribes_unique": 0, "report_spam": 0, "report_spam_unique": 0, "onsite": 0, "onsite_unique": 0 }';
                    res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'text/xml');
                }
                
                if(res != NULL){
                    if(res.getStatusCode() == 200){
                        ProcessStatisticsGetMessageResultsResponse(res);
                        
                    }else{
                        ErrorMsg = res.getStatus();
                    } 
                }
            }
            catch(Exception ex){
                ErrorMsg = 'Exception Occured!'; 
            }
        }

        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        }        
    }
   
    private void ProcessStatisticsGetMessageResultsResponse(HttpResponse res){
        string resBody = res.getBody();
        if(resBody != NULL){
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if(parser.getCurrentName() == 'opens' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    parser.nextToken();
                    if(Schema.sObjectType.Campaign.fields.Opened__c.isUpdateable()){
                        objCampaign.Opened__c = parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                    }    
                }else if(parser.getCurrentName() == 'opens_unique' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    parser.nextToken();
                    if(Schema.sObjectType.Campaign.fields.Opens_Unique__c.isUpdateable()){
                        objCampaign.Opens_Unique__c = parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                    }
                }else if(parser.getCurrentName() == 'clicks' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    parser.nextToken();
                    if(Schema.sObjectType.Campaign.fields.Clicked__c.isUpdateable()){
                        objCampaign.Clicked__c = parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                    }    
                }else if(parser.getCurrentName() == 'clicks_unique' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    parser.nextToken();
                    if(Schema.sObjectType.Campaign.fields.Clicks_Unique__c.isUpdateable()){
                        objCampaign.Clicks_Unique__c = parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                    }
                }else if(parser.getCurrentName() == 'sent' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    parser.nextToken();
                    if(Schema.sObjectType.Campaign.fields.Sent__c.isUpdateable()){
                        objCampaign.Sent__c = parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                    }    
                }else if(parser.getCurrentName() == 'undelivered' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    parser.nextToken();
                    if(Schema.sObjectType.Campaign.fields.Nonsent__c.isUpdateable()){
                        objCampaign.Nonsent__c = parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                    }
                }else if(parser.getCurrentName() == 'bounces_unique' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    parser.nextToken();
                    if(Schema.sObjectType.Campaign.fields.Bounced__c.isUpdateable()){
                        objCampaign.Bounced__c = parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                    }    
                }else if(parser.getCurrentName() == 'unsubscribes_unique' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    parser.nextToken();
                    if(Schema.sObjectType.Campaign.fields.Unsubscribe__c.isUpdateable()){
                        objCampaign.Unsubscribe__c = parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                    }
                }
            }
            update objCampaign;
            ErrorMsg = InwiseConstants.GENERIC_SUCCESS;
        }
    }
    
    public static String ProcessBadResponse(HttpResponse res){
        String msg = '';   
        XmlStreamReader reader = new XmlStreamReader(res.getBody());
        while(reader.hasNext()) {
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ErrorDescription'){
                reader.next(); 
                if(reader.getText() != NULL){
                    msg = reader.getText();
                    break;
                }
            }
            reader.next(); 
        } 
        
        if(msg == NULL || msg == ''){
            msg = InwiseConstants.BAD_REQUEST;
        }
        return msg;
    }

    public class JSON2ApexGroupId {
        public String group_id;
    }

    public class WrapperResult{
        public String msg{get;set;}
        public boolean isSuccess{get;set;}
        public Integer resultSendId{get;set;}
        public WrapperResult(){
            isSuccess = false;
            resultSendId = 0;
        }
    }

    public class JSON2ApexWrapperInwisemembersActions {
        public Integer id{get;set;}
        public String action_date{get;set;}
        public Integer contact_id{get;set;}
        public Integer campaign_id{get;set;}
        public String ip{get;set;}
        public String action_type{get;set;}
        public String external_id{get;set;}
        public String remarks{get;set;} 
        public String additional_data{get;set;}
    }

    public class JSON2ApexWrapperInwisemembersActionsSENT {
        public Long row_index{get;set;}
        public String transaction_id{get;set;}
        public Integer contact_id{get;set;}
        public Integer campaign_id{get;set;}
        public String date_sent{get;set;}
        public String email{get;set;}
        public Integer message_size{get;set;}
        public String sending_source{get;set;}
        public String external_id{get;set;}
        public String additional_data{get;set;}
    }
}