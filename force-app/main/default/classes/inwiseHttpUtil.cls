/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 07 Oct 2016 
*Purpose :      class will contains all utility method related to callout 
Modification Log
----------------
Date                   Version      Developer               Comments
------------------------------------------------------------------------------------
07/29/2019             1.0.0        Kapil Goutam            Modified: removed "validity": 2 from json .
03/24/2021             1.0.1        K.Goutam                Created record for errorlog [IFS-27 Jira]  
04/07/2021             1.0.2        K.Goutam                modified: Added new method "getJsonToApexPushExernalAppError"
11/03/2021             1.0.3        S. Vaishnav             Modified:- added isAccessible() && isCreateable()
12/28/2021             1.0.4        S. Vaishnav             Modified:- Removed "important" from the send sms json
08/30/2022             1.0.5        S. Vaishnav             Modified:- Updated method return type from boolean to map in InwiseCalloutSendSMS
09/01/2022             1.0.6        S. Vaishnav             Modified:- Added new parameter from in the SMS json
09/26/2022             1.0.7        S. Vaishnav             Modified:- Fixed " and \ error in message body in getJSONSendSMS method
01/06/2022             1.0.8        S. Vaishnav             Added new method for whatsApp


/***********************************************************************************/
public with sharing class inwiseHttpUtil {

    public static Map<String, String> InwiseCalloutTemplatesList(InwiseUtil objInwiseUtil, List<Logs__c> listOfLogs){
        
        //System.debug('objInwiseUtil>>>>'+objInwiseUtil);
        //System.debug(objInwiseUtil.inwiseAccountToken);

        Map<String, String> mapOfTemplates = new Map<String, String>();
        String api = '/rest/v1/templates?create_date_from=2020-01-01&template_types=sms';

        Http http = new Http();
        String endpoint = objInwiseUtil.apiUrl + api;
        HttpRequest req = objInwiseUtil.GetHTTPRequest('GET', 'application/json', endpoint); 
        req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken);
        HttpResponse res;
        
        if(!Test.isRunningTest()){
            res = http.send(req);
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/templates', 'inwiseHttpUtil', 'InwiseCalloutTemplatesList'));
        }else{
            String resBody = '[{"id":20001, "name": "tryingtoreachyou", "channel_type": "email", "create_date": "2021-08-2913:25:00", "content": "Hey{{1}}", "language": "english", "template_type": "sms", "last_update_date": "2021-08-2913:25:00"}]';
            res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
        }

        if(res != NULL){
            if(res.getStatusCode() == 200){

                String templateName;
                String templateValue;
                String jsonString = res.getBody();
                JSONParser parser = JSON.createParser(jsonString);

                while(parser.nextToken() != null) {
                    if(parser.getCurrentName() == 'name' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                        parser.nextToken();
                        templateName = parser.getText();
                    }
                    else if(parser.getCurrentName() == 'content' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                        parser.nextToken();
                        templateValue = parser.getText();
                    }
                    if(templateName != null && templateValue != null){
                        mapOfTemplates.put(templateName, templateValue);
                        templateName = null; 
                        templateValue = null;
                    }  
                }  
            }
        }        
        
        return mapOfTemplates;
    }

    public static Map<String, String> InwiseCalloutLandingPagesList(InwiseUtil objInwiseUtil, List<Logs__c> listOfLogs, Boolean isNeedToincludePageId, String isLandingPage){
        
        System.debug('IsLandingPage>>>>'+isLandingPage);
        //System.debug('objInwiseUtil>>>>'+objInwiseUtil);

        String api = '';
        Map<String, String> mapOfLandingPageFieldsTemp = new Map<String, String>();
        
        if(isLandingPage == 'Landing Page'){
            api = '/rest/v1/pages/landingPage?';
        }else{
            api = '/rest/v1/pages/popups?';
        }

        Http http = new Http();
        String endpoint = objInwiseUtil.apiUrl + api + 'create_date_from=2010-01-01&order_by=id%20desc&is_active=true';
        HttpRequest req = objInwiseUtil.GetHTTPRequest('GET', 'application/json', endpoint); 
        req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken);
        HttpResponse res;

        Integer pageid; String pagename; String pageURL;
        
        if(!Test.isRunningTest()){
            res = http.send(req);
            if(isLandingPage == 'Landing Page'){
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/pages/landingPage', 'inwiseHttpUtil', 'InwiseCalloutLandingPagesList'));
            }else{
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/pages/popups', 'inwiseHttpUtil', 'InwiseCalloutLandingPagesList'));
            }
        }else{
            String resBody = '{"page_id": 12915, "name": "Page_02-11-2017_1", "page_name": "Page_02-11-2017_1", "content": null, "title": null, "cname": null, "page_protocol": "http", "redirect_url": null, "meta_description": null, "meta_keywords": null, "create_date": "2017-11-02 17:37:00", "update_date": "2017-11-02 17:40:00", "page_type": "LandingPage", "canonical_url": null, "thank_you_type": "Template", "is_active": false, "analytics": null, "remarketing": null, "conversion": null, "additional_codes": null, "thank_you_content": null, "goals": null, "forms_ids": [9910], "page_url": "http://sf2.inwise.net/Page_02-11-2017_1"}';
            res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
        }

        if(res != NULL){
            if(res.getStatusCode() == 200){ 
                String jsonString = res.getBody(); 
                JSONParser parser = JSON.createParser(jsonString);
                while(parser.nextToken() != null) {
                    if(parser.getCurrentName() == 'name' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                        parser.nextToken();
                        pagename = parser.getText();
                    }
                    if(parser.getCurrentName() == 'page_url' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                        parser.nextToken();
                        pageURL = parser.getText();
                    }
                    if(parser.getCurrentName() == 'page_id' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                        parser.nextToken();
                        try{
                            pageid = Integer.valueOf(parser.getText());  
                        }catch(Exception ex){
                            System.debug('Exception::-->>' + ex.getMessage());
                        }
                    }
                    if(isNeedToincludePageId){
                        if(pageid != NULL && pagename != NULL){
                            mapOfLandingPageFieldsTemp.put(String.valueOf(pageid),pagename);
                            pageid = NULL; 
                            pagename = NULL;
                        }  
                    }else{
                        if(pageURL != NULL && pagename != NULL){
                            mapOfLandingPageFieldsTemp.put(pageURL,pagename);
                            pageURL = NULL; 
                            pagename = NULL;
                        }  
                    }
                }   
            }
        }                
        
        return mapOfLandingPageFieldsTemp;
    }

    public Static String getReverseFormattedPhone(String phoneno, InwiseUtil objInwiseUtil){
        /**This method will reverse the code whatever we are doing in  getFormattedPhone method**/
        String formattedphone = phoneno;
        Map<String,String> mapOfCountryCode = getCountryCodeMap();
        if(phoneno != NULL && !String.isEmpty(phoneno)){
            if(objInwiseUtil.objInwiseAccount.Country__c != NULL && mapOfCountryCode.get(objInwiseUtil.objInwiseAccount.Country__c) != NULL) {
                if (phoneno.startswith(mapOfCountryCode.get(objInwiseUtil.objInwiseAccount.Country__c))) {
                    phoneno = phoneno.replaceFirst(mapOfCountryCode.get(objInwiseUtil.objInwiseAccount.Country__c),'');
                }
            }
            if(objInwiseUtil.objInwiseAccount.Trim_Leading_Zero__c != NULL &&  objInwiseUtil.objInwiseAccount.Trim_Leading_Zero__c == true){
                phoneno = '0' + phoneno;
            }
            formattedphone = phoneno;
        }
        return formattedphone.replace('-', '');
    }

    public Static String getFormattedPhone(String phoneno, InwiseUtil objInwiseUtil){
        /****
        Country code             trim     mobile value    number to send to api
        972                     true     0546414000      972546414000
        972                     false    0546414000      9720546414000
        1                         true     048372635       148372635
        0(means empty)   false    8473827362      8473827362
        ***/
        System.debug('phoneno == ' + phoneno);
        String formattedphone = phoneno;
        Map<String,String> mapOfCountryCode = getCountryCodeMap();
        if(phoneno != NULL && !String.isEmpty(phoneno)){
            System.debug('phoneno=='+phoneno);
            //System.debug('trim=='+objInwiseUtil.objInwiseAccount.Trim_Leading_Zero__c );
            if(objInwiseUtil.objInwiseAccount.Trim_Leading_Zero__c != NULL &&  objInwiseUtil.objInwiseAccount.Trim_Leading_Zero__c == true){
                if(phoneno.startswith('0')){
                    formattedphone = phoneno.subString(1, phoneno.length());
                }
            }
            if(objInwiseUtil.objInwiseAccount.Country__c != NULL && mapOfCountryCode.get(objInwiseUtil.objInwiseAccount.Country__c) != NULL){
                formattedphone = mapOfCountryCode.get(objInwiseUtil.objInwiseAccount.Country__c) + formattedphone;
            }
        }
        return formattedphone;
    }

    public static string getJSONSendSMS(String msg, String phoneNo, InwiseUtil objInwiseUtil, String fromNumber){

        if(msg.contains('\\')){
            msg = msg.replace('\\', '\\\\');
        }
        if(msg.contains('"')){
            msg = msg.replace('"', '\\\"');
        }

        String jsonString = '{';
        jsonString +=' "message": { '; 
        jsonString += ' "content": "' + msg  +'", ';
        jsonString +=   ' "to": [ ';
        jsonString += '{ ';
        jsonString += ' "mobile_number": "' + getFormattedPhone(phoneNo, objInwiseUtil) + '" ';
        jsonString += '} ';
        jsonString += ' ], ';

        if(String.isNotBlank(fromNumber) || (objInwiseUtil.objInwiseAccount != null && String.isNotBlank(objInwiseUtil.objInwiseAccount.SMS_Sender__c))){
            jsonString += ' "from": "' + (String.isNotBlank(fromNumber) ? fromNumber : objInwiseUtil.objInwiseAccount.SMS_Sender__c) + '", ';
        }

        jsonString += ' "track_opens": true, ';
        jsonString += ' "track_clicks": true ';
        jsonString += ' }';
        jsonString += '}' ;
        return jsonString;
    }

    public static Map<String, String> InwiseCalloutSendSMS(InwiseUtil objInwiseUtil, String messageBody, String selectedNumber, List<Logs__c> listOfLogs, String fromNumber){
        
        HttpResponse res;
        Http http = new Http();
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        Map<String, String> responseMap = new Map<String, String>{'isSMSSent' => 'false', 'status' => '', 'rejectReason' => '', 'statusCode' => ''};
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/transactional/sms/send'; //?api_key=' +  objInwiseUtil.inwiseAccountToken +  '&create_date_from=2010-01-01&order_by=id%20desc';
        HttpRequest req = objInwiseUtil.GetHTTPRequest('POST','application/json', endpoint); 
        req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken); 
        req.setBody(getJSONSendSMS(messageBody, selectedNumber, objInwiseUtil, fromNumber));

        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/transactional/sms/send', 'inwiseHttpUtil', 'InwiseCalloutSendSMS'));
            }else{
                String resBody = '[   {     "mobile_number": "91-7-742507700",     "status": "sent",     "reject_reason": null,     "transaction_id": "db7459f4896b458eac2fbdc68b4d9b6a",     "code": null,     "name": null   } ]';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res != NULL){
                String jsonString = res.getBody();
                system.debug('=statusCode='+res.getStatusCode());
                responseMap.put('statusCode', res.getStatusCode()+'');

                if(res.getStatusCode() == 200){
                    system.debug('=In If Part='+res.getBody());
                    List<JsonToApexSendSMS.SendSMS> listOfSendSMS = JsonToApexSendSMS.parse(jsonString);
                    
                    if(!listOfSendSMS.isEmpty()){
                        JsonToApexSendSMS.SendSMS objSendSMS = listOfSendSMS.get(0);
                        if(objSendSMS != NULL){
                            
                            String status = String.isNotBlank(objSendSMS.status) ? objSendSMS.status : '';
                            String rejectReason = String.isNotBlank(objSendSMS.reject_reason) ? objSendSMS.reject_reason : '';

                            if(String.isNotBlank(status)){
                                if(status == 'sent'){
                                    responseMap.put('isSMSSent', 'true');
                                }
                                if(String.isNotBlank(rejectReason)){
                                    if(status == 'rejected' && rejectReason == 'unsubscribe'){
                                        rejectReason = inwiseConstants.UNSUBSCRIBE_MESSAGE;
                                    }
                                    if(status == 'invalid' && rejectReason == 'invalid-number'){
                                        rejectReason = inwiseConstants.INVALID_NUMBER;
                                    }
                                }
                            }
                            responseMap.put('status', status);
                            responseMap.put('rejectReason', rejectReason);
                        }
                    }
                }
                else{
                    system.debug('=In else Part=');
                    listOfErrorLogs.add(getErrorLogRecord(jsonString, 'inwiseHttpUtil','InwiseCalloutSendSMS'));
                }
            }                
        }catch(Exception ex){
            // insertSyncHistory(ex.getMessage(),null,objSync.Id);
        }

        if(!listOfErrorLogs.isEmpty()){
            insert listOfErrorLogs;
        }

        return responseMap;
    }
    public static SMSWrapper InwiseCalloutSendSMS1(InwiseUtil objInwiseUtil, String messageBody, String selectedNumber, List<Logs__c> listOfLogs, String fromNumber){
        
        HttpResponse res;
        Http http = new Http();
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        Error_Logs__c errorLog = new Error_Logs__c();
        Map<String, String> responseMap = new Map<String, String>{'isSMSSent' => 'false', 'status' => '', 'rejectReason' => '', 'statusCode' => ''};
        
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/transactional/sms/send'; //?api_key=' +  objInwiseUtil.inwiseAccountToken +  '&create_date_from=2010-01-01&order_by=id%20desc';
        HttpRequest req = objInwiseUtil.GetHTTPRequest('POST','application/json', endpoint); 
        req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken); 
        req.setBody(getJSONSendSMS(messageBody, selectedNumber, objInwiseUtil, fromNumber));

        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/transactional/sms/send', 'inwiseHttpUtil', 'InwiseCalloutSendSMS'));
            }else{
                String resBody = '[   {     "mobile_number": "91-7-742507700",     "status": "sent",     "reject_reason": null,     "transaction_id": "db7459f4896b458eac2fbdc68b4d9b6a",     "code": null,     "name": null   } ]';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res != NULL){
                String jsonString = res.getBody();
                system.debug('=statusCode='+res.getStatusCode());
                responseMap.put('statusCode', res.getStatusCode()+'');

                if(res.getStatusCode() == 200){
                    system.debug('=In If Part='+res.getBody());
                    List<JsonToApexSendSMS.SendSMS> listOfSendSMS = JsonToApexSendSMS.parse(jsonString);
                    
                    if(!listOfSendSMS.isEmpty()){
                        JsonToApexSendSMS.SendSMS objSendSMS = listOfSendSMS.get(0);
                        if(objSendSMS != NULL){
                            
                            String status = String.isNotBlank(objSendSMS.status) ? objSendSMS.status : '';
                            String rejectReason = String.isNotBlank(objSendSMS.reject_reason) ? objSendSMS.reject_reason : '';

                            if(String.isNotBlank(status)){
                                if(status == 'sent'){
                                    responseMap.put('isSMSSent', 'true');
                                }
                                if(String.isNotBlank(rejectReason)){
                                    if(status == 'rejected' && rejectReason == 'unsubscribe'){
                                        rejectReason = inwiseConstants.UNSUBSCRIBE_MESSAGE;
                                    }
                                    if(status == 'invalid' && rejectReason == 'invalid-number'){
                                        rejectReason = inwiseConstants.INVALID_NUMBER;
                                    }
                                }
                            }
                            responseMap.put('status', status);
                            responseMap.put('rejectReason', rejectReason);
                        }
                    }
                    errorLog = null;
                }
                else{
                    system.debug('=In else Part=');
                    errorLog = getErrorLogRecord(jsonString, 'inwiseHttpUtil','InwiseCalloutSendSMS');
                    //listOfErrorLogs.add(getErrorLogRecord(jsonString, 'inwiseHttpUtil','InwiseCalloutSendSMS'));
                }
            }                
        }catch(Exception ex){
            // insertSyncHistory(ex.getMessage(),null,objSync.Id);
        }
        
        if(!listOfErrorLogs.isEmpty()){
           // insert listOfErrorLogs;
        }
        
        
        return new SMSWrapper(null, null, null, null, null, null, null, responseMap, errorLog);
    }
    
    public static Logs__c getHttpLogRecord(HttpRequest request,HttpResponse response,String apiname, String callerClassname,String callerMethod){
        String httpRequest, httpResponse;
        String maxLengthMsg = '...data truncated for column';
        httpRequest = String.valueOf(request);
        if(request.getHeader('X-Api-Key') != NULL){
            httpRequest += '\nX-Api-Key:-' + request.getHeader('X-Api-Key');
        }
        if(request.getBody()  != NULL){
            httpRequest += '\n---------------------------------------------------------------------------------\n';
            httpRequest += request.getBody();
            if(httpRequest.length() > 131072){
                httpRequest = httpRequest.subString(0,131000);
                httpRequest += maxLengthMsg;
            }
        }
        httpResponse = String.valueOf(response);
        if(response.getBody()  != NULL){
            httpResponse += '\n---------------------------------------------------------------------------------\n';
            httpResponse += response.getBody();
            if(httpResponse.length() > 131072){
                httpResponse = httpResponse.subString(0,131000);
                httpResponse += maxLengthMsg;
            }
        }
        //insertHttpLogs(httpRequest,httpResponse);
        return getHttpLogRecord(httpRequest,httpResponse,apiname,callerClassname,callerMethod);
    }  

    public static JsonToApexPushExernalApp getJsonToApexPushExernalAppError(HttpResponse res){
        JsonToApexPushExernalApp objJsonToApexPushExernalApp = new JsonToApexPushExernalApp();
        JsonToApexPushExernalApp.Errors objErrors = new JsonToApexPushExernalApp.Errors();
        objErrors.details = res.getBody();
        objErrors.external_id = String.valueOf(res.getStatusCode());
        objJsonToApexPushExernalApp.status = res.getStatus();
        objJsonToApexPushExernalApp.errors = new List<JsonToApexPushExernalApp.Errors>();
        objJsonToApexPushExernalApp.errors.add(objErrors);
        return objJsonToApexPushExernalApp;
    }

    public static Logs__c getHttpLogRecord(String request, String response, String apiname, String callerClassname, String callerMethod){
        Logs__c objLog;
        if(Logs__c.SObjectType.getDescribe().isAccessible() && Logs__c.SObjectType.getDescribe().isCreateable()){
            objLog = new Logs__c();
            if(Schema.sObjectType.Logs__c.fields.Request__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Request__c.isCreateable()){
                objLog.Request__c = request; //  'Missing login information to execute batch';
            }   
            if(Schema.sObjectType.Logs__c.fields.Response__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Response__c.isCreateable()){
                objLog.Response__c = response;
            }
            if(Schema.sObjectType.Logs__c.fields.Run_By__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Run_By__c.isCreateable()){
                objLog.Run_By__c = UserInfo.getUserId();
            }    
            if(Schema.sObjectType.Logs__c.fields.Run_On__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Run_On__c.isCreateable()){
                objLog.Run_On__c = datetime.now();
            }    
            if(Schema.sObjectType.Logs__c.fields.Api_Name__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Api_Name__c.isCreateable()){
                objLog.Api_Name__c = apiname;
            }    
            if(Schema.sObjectType.Logs__c.fields.Class_Name__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Class_Name__c.isCreateable()){
                objLog.Class_Name__c = callerClassname;
            }    
            if(Schema.sObjectType.Logs__c.fields.Method_Name__c.isAccessible() && Schema.sObjectType.Logs__c.fields.Method_Name__c.isCreateable()){
                objLog.Method_Name__c = callerMethod;
            }    
        }
        return objLog;   
    }

    public static Error_Logs__c getErrorLogRecord(String errorMessage, String callerClassname, String callerMethod){
        Error_Logs__c objErrorLog;
        if(Error_Logs__c.SObjectType.getDescribe().isAccessible() && Error_Logs__c.SObjectType.getDescribe().isCreateable()){
            objErrorLog = new Error_Logs__c();
            if(Schema.sObjectType.Error_Logs__c.fields.Message__c.isAccessible() && Schema.sObjectType.Error_Logs__c.fields.Message__c.isCreateable()){
                objErrorLog.Message__c = errorMessage; //  'Missing login information to execute batch';
            }    
            if(Schema.sObjectType.Error_Logs__c.fields.Run_By__c.isAccessible() && Schema.sObjectType.Error_Logs__c.fields.Run_By__c.isCreateable()){
                objErrorLog.Run_By__c = UserInfo.getUserId();
            }    
            if(Schema.sObjectType.Error_Logs__c.fields.Run_On__c.isAccessible() && Schema.sObjectType.Error_Logs__c.fields.Run_On__c.isCreateable()){
                objErrorLog.Run_On__c = datetime.now();
            }    
            if(Schema.sObjectType.Error_Logs__c.fields.Class_Name__c.isAccessible() && Schema.sObjectType.Error_Logs__c.fields.Class_Name__c.isCreateable()){
                objErrorLog.Class_Name__c = callerClassname;
            }    
            if(Schema.sObjectType.Error_Logs__c.fields.Method_Name__c.isAccessible() && Schema.sObjectType.Error_Logs__c.fields.Method_Name__c.isCreateable()){
                objErrorLog.Method_Name__c = callerMethod;
            }    
        }
        return objErrorLog;   
    }
    // Api callout for email send
    public static Map<String, String> InwiseCalloutSendEmail(InwiseUtil objInwiseUtil, String template_id,  List<Logs__c> listOfLogs,String fromEmail, String toName, String subject, String fromName, String tagsLi,String email, String replyTo,String jsonFields){
        HttpResponse res;
        Http http = new Http();
        system.debug('InwiseCalloutSendEmail method 11 =='  );
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        Map<String, String> responseMap = new Map<String, String>{'isEmailSent' => 'false', 'status' => '', 'rejectReason' => '', 'statusCode' => ''};
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/transactional/emails/sendTemplate'; //?api_key=' +  objInwiseUtil.inwiseAccountToken +  '&create_date_from=2010-01-01&order_by=id%20desc';
        HttpRequest req = objInwiseUtil.GetHTTPRequest('POST','application/json', endpoint); 
       // system.debug(' Token__c ======='+objInwiseUtil.inwiseAccountToken  );
        req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken); 
        req.setBody(getJSONSendEmail(template_id,fromEmail,toName,subject,fromName,tagsLi,email,replyTo,jsonFields));
        system.debug('InwiseCalloutSendEmail method =='  );
        // res = http.send(req);
        // system.debug('response is  : ' + res.getBody());
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                system.debug('=response='+res);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/transactional/emails/sendTemplate', 'inwiseHttpUtil', 'InwiseCalloutSendEmail'));
            }else{
                String resBody = '[   {     "Email": "boaz.apt@gmail.com",     "status": "sent",     "reject_reason": null,     "transaction_id": "db7459f4896b458eac2fbdc68b4d9b6a",     "code": null,     "name": null   } ]';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res != NULL){
                String jsonString = res.getBody();
                system.debug('=statusCode='+res.getStatusCode());
                responseMap.put('statusCode', res.getStatusCode()+'');

                if(res.getStatusCode() == 200){
                    system.debug('=In If Part='+res.getBody());
                    List<JsonToApexSendEmail.SendEmail> listOfSendEmail = JsonToApexSendEmail.parse(jsonString);
                    
                    if(!listOfSendEmail.isEmpty()){
                        JsonToApexSendEmail.SendEmail objSendEmail = listOfSendEmail.get(0);
                        if(objSendEmail != NULL){
                            
                            String status = String.isNotBlank(objSendEmail.status) ? objSendEmail.status : '';
                            String rejectReason = String.isNotBlank(objSendEmail.reject_reason) ? objSendEmail.reject_reason : '';

                            if(String.isNotBlank(status)){
                                if(status == 'sent'){
                                    responseMap.put('isEmailSent', 'true');
                                }
                                if(String.isNotBlank(rejectReason)){
                                    if(status == 'rejected' && rejectReason == 'unsubscribe'){
                                        rejectReason = inwiseConstants.UNABLE_TO_SEND_EMAIL;
                                    }
                                    if(status == 'invalid' && rejectReason == 'invalid-EMAIL'){
                                        rejectReason = inwiseConstants.INVALID_EMAIL;
                                    }
                                }
                            }
                            responseMap.put('status', status);
                            responseMap.put('rejectReason', rejectReason);
                        }
                    }
                }
                else{
                    system.debug('=In else Part=');
                    listOfErrorLogs.add(getErrorLogRecord(jsonString, 'inwiseHttpUtil','InwiseCalloutSendSMS'));
                }
            }                
        }catch(Exception ex){
            // insertSyncHistory(ex.getMessage(),null,objSync.Id);
        }

        if(!listOfErrorLogs.isEmpty()){
            insert listOfErrorLogs;
        }

        return responseMap;
    }
    public static EmailWrapper InwiseCalloutSendBulkEmail(InwiseUtil objInwiseUtil, String template_id,  List<Logs__c> listOfLogs,String fromEmail, String toName, String subject, String fromName, String tagsLi,String email, String replyTo,String jsonFields){
        HttpResponse res;
        Http http = new Http();
        system.debug('InwiseCalloutSendEmail method 11 =='  );
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        Error_Logs__c errorLog = new Error_Logs__c();
        Map<String, String> responseMap = new Map<String, String>{'isEmailSent' => 'false', 'status' => '', 'rejectReason' => '', 'statusCode' => ''};
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/transactional/emails/sendTemplate'; //?api_key=' +  objInwiseUtil.inwiseAccountToken +  '&create_date_from=2010-01-01&order_by=id%20desc';
        HttpRequest req = objInwiseUtil.GetHTTPRequest('POST','application/json', endpoint); 
       // system.debug(' Token__c ======='+objInwiseUtil.inwiseAccountToken  );
        req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken); 
        req.setBody(getJSONSendEmail(template_id,fromEmail,toName,subject,fromName,tagsLi,email,replyTo,jsonFields));
        system.debug('InwiseCalloutSendEmail method =='  );
        // res = http.send(req);
        // system.debug('response is  : ' + res.getBody());
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                system.debug('=response='+res);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/transactional/emails/sendTemplate', 'inwiseHttpUtil', 'InwiseCalloutSendBulkEmail'));
            }else{
                String resBody = '[   {     "Email": "boaz.apt@gmail.com",     "status": "sent",     "reject_reason": null,     "transaction_id": "db7459f4896b458eac2fbdc68b4d9b6a",     "code": null,     "name": null   } ]';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res != NULL){
                String jsonString = res.getBody();
                system.debug('=statusCode='+res.getStatusCode());
                responseMap.put('statusCode', res.getStatusCode()+'');

                if(res.getStatusCode() == 200){
                    system.debug('=In If Part='+res.getBody());
                    List<JsonToApexSendEmail.SendEmail> listOfSendEmail = JsonToApexSendEmail.parse(jsonString);
                    
                    if(!listOfSendEmail.isEmpty()){
                        JsonToApexSendEmail.SendEmail objSendEmail = listOfSendEmail.get(0);
                        if(objSendEmail != NULL){
                            
                            String status = String.isNotBlank(objSendEmail.status) ? objSendEmail.status : '';
                            String rejectReason = String.isNotBlank(objSendEmail.reject_reason) ? objSendEmail.reject_reason : '';

                            if(String.isNotBlank(status)){
                                if(status == 'sent'){
                                    responseMap.put('isEmailSent', 'true');
                                }
                                if(String.isNotBlank(rejectReason)){
                                    if(status == 'rejected' && rejectReason == 'unsubscribe'){
                                        rejectReason = inwiseConstants.UNABLE_TO_SEND_EMAIL;
                                    }
                                    if(status == 'invalid' && rejectReason == 'invalid-EMAIL'){
                                        rejectReason = inwiseConstants.INVALID_EMAIL;
                                    }
                                }
                            }
                            responseMap.put('status', status);
                            responseMap.put('rejectReason', rejectReason);
                        }
                    }
                    errorLog = null;
                }
                else{
                    system.debug('=In else Part=');
                    //listOfErrorLogs.add(getErrorLogRecord(jsonString, 'inwiseHttpUtil','InwiseCalloutSendSMS'));
                    errorLog = getErrorLogRecord(jsonString, 'inwiseHttpUtil','InwiseCalloutSendBulkEmail');
                }
            }                
        }catch(Exception ex){
            // insertSyncHistory(ex.getMessage(),null,objSync.Id);
        }

        // if(!listOfErrorLogs.isEmpty()){
        //     insert listOfErrorLogs;
        // }

        return new EmailWrapper(null, null, null, null, null, null, null,null, null, null, null, null, responseMap, errorLog);
    }
    public static string getJSONSendEmail(String template_id,String fromEmail, String toName, String subject, String fromName, String tagsLi,String email, String replyTo,String jsonFields){
        String sendEmailJSONString = '{';
        sendEmailJSONString +=' "template_id":  "' + template_id  +'" ,'; 
        sendEmailJSONString +=' "message": { '; 
            sendEmailJSONString += ' "subject": "'+subject+'", ';
            sendEmailJSONString += ' "from_email":  "' + fromEmail  +'", ';
            sendEmailJSONString += ' "reply_to":  "'+replyTo+'", ';
            sendEmailJSONString += ' "from_name":  "'+fromName+'", ';
            sendEmailJSONString += ' "to": [ ';
                sendEmailJSONString += '{ ';
                sendEmailJSONString += ' "email": "'+email+'", ';
                sendEmailJSONString += ' "name": "'+toName+'", ';
                sendEmailJSONString += ' "type": "to" ';
                sendEmailJSONString += '} ';
            sendEmailJSONString += ' ], ';
            sendEmailJSONString += ' "field_vars": [ ';
             sendEmailJSONString += jsonFields;
               
            sendEmailJSONString += ' ], ';
            sendEmailJSONString += ' "tags":  "'+tagsLi+'" ';
        sendEmailJSONString += '} ';
        sendEmailJSONString += '} ';

        System.debug('sendEmailJSONString=='+sendEmailJSONString); 
        return sendEmailJSONString;
    }
    // Api callout for SendWhatsApp send
    public static Map<String, String> InwiseCalloutSendWhatsApp(InwiseUtil objInwiseUtil, String template_id,  List<Logs__c> listOfLogs,String content, String mobileNumber, String templateMapping, String mediaUrl, Boolean async,String tags, String jsonFields){
        HttpResponse res;
        Http http = new Http();
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        Map<String, String> responseMap = new Map<String, String>{'isWhtasAppSent' => 'false', 'status' => '', 'rejectReason' => '', 'statusCode' => ''};
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/transactional/whatsapp/send'; //?api_key=' +  objInwiseUtil.inwiseAccountToken +  '&create_date_from=2010-01-01&order_by=id%20desc';
        HttpRequest req = objInwiseUtil.GetHTTPRequest('POST','application/json', endpoint); 
       // system.debug(' Token__c ======='+objInwiseUtil.inwiseAccountToken  );
        req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken); 
        String bodyJsonString = getJSONSendWhatsApp(objInwiseUtil,template_id,content,mobileNumber,templateMapping,mediaUrl,async,tags,jsonFields);
        System.debug('bodyJsonString===='+bodyJsonString);
        //listOfErrorLogs.add(getErrorLogRecord(bodyJsonString, 'inwiseHttpUtil','InwiseCalloutSendWhatsApp'));
        req.setBody(bodyJsonString);
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/transactional/whatsapp/send', 'inwiseHttpUtil', 'InwiseCalloutSendWhatsApp'));
            }else{
                String resBody = '[   {     "Email": "boaz.apt@gmail.com",     "status": "sent",     "reject_reason": null,     "transaction_id": "db7459f4896b458eac2fbdc68b4d9b6a",     "code": null,     "name": null   } ]';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res != NULL){
                String jsonString = res.getBody();
                responseMap.put('statusCode', res.getStatusCode()+'');
                System.debug('jsonString===='+jsonString);
                if(res.getStatusCode() == 200){
                    List<JsonToApexSendEmail.SendEmail> listOfWhatsAppSend = JsonToApexSendEmail.parse(jsonString);
                    
                    if(!listOfWhatsAppSend.isEmpty()){
                        JsonToApexSendEmail.SendEmail objSendEmail = listOfWhatsAppSend.get(0);
                        if(objSendEmail != NULL){
                            
                            String status = String.isNotBlank(objSendEmail.status) ? objSendEmail.status : '';
                            String rejectReason = String.isNotBlank(objSendEmail.reject_reason) ? objSendEmail.reject_reason : '';

                            if(String.isNotBlank(status)){
                                if(status == 'sent'){
                                    responseMap.put('isWhtasAppSent', 'true');
                                }
                                if(String.isNotBlank(rejectReason)){
                                    if(status == 'rejected' && rejectReason == 'unsubscribe'){
                                        rejectReason = 'Unable to send whatsApp, for more detail check message history';
                                    }
                                    if(status == 'invalid'){
                                        rejectReason = 'invalid-number';
                                    }
                                }
                            }
                            responseMap.put('status', status);
                            responseMap.put('rejectReason', rejectReason);
                        }
                    }
                }
                else{
                    system.debug('=In else Part=');
                    listOfErrorLogs.add(getErrorLogRecord(jsonString, 'inwiseHttpUtil','InwiseCalloutSendWhatsApp'));
                }
            }                
        }catch(Exception ex){
            // insertSyncHistory(ex.getMessage(),null,objSync.Id);
        }

        if(!listOfErrorLogs.isEmpty()){
            insert listOfErrorLogs;
        }

        return responseMap;
    }

    public static WhatsappWrapper InwiseCalloutBulkSendWhatsApp(InwiseUtil objInwiseUtil, String template_id,  List<Logs__c> listOfLogs,String content, String mobileNumber, String templateMapping, String mediaUrl, Boolean async,String tags, String jsonFields){
        HttpResponse res;
        Http http = new Http();
        Error_Logs__c errorLog = new Error_Logs__c();
        Map<String, String> responseMap = new Map<String, String>{'isWhtasAppSent' => 'false', 'status' => '', 'rejectReason' => '', 'statusCode' => ''};
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/transactional/whatsapp/send'; //?api_key=' +  objInwiseUtil.inwiseAccountToken +  '&create_date_from=2010-01-01&order_by=id%20desc';
        HttpRequest req = objInwiseUtil.GetHTTPRequest('POST','application/json', endpoint); 
       // system.debug(' Token__c ======='+objInwiseUtil.inwiseAccountToken  );
        req.setHeader('X-Api-Key', objInwiseUtil.inwiseAccountToken); 
        
        req.setBody(getJSONSendWhatsApp(objInwiseUtil,template_id,content,mobileNumber,templateMapping,mediaUrl,async,tags,jsonFields));
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/transactional/whatsapp/send', 'inwiseHttpUtil', 'InwiseCalloutBulkSendWhatsApp'));
            }else{
                String resBody = '[   {     "Email": "boaz.apt@gmail.com",     "status": "sent",     "reject_reason": null,     "transaction_id": "db7459f4896b458eac2fbdc68b4d9b6a",     "code": null,     "name": null   } ]';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res != NULL){
                String jsonString = res.getBody();
                responseMap.put('statusCode', res.getStatusCode()+'');
                System.debug('jsonString===='+jsonString);
                if(res.getStatusCode() == 200){
                    List<JsonToApexSendEmail.SendEmail> listOfWhatsAppSend = JsonToApexSendEmail.parse(jsonString);
                    
                    if(!listOfWhatsAppSend.isEmpty()){
                        JsonToApexSendEmail.SendEmail objSendEmail = listOfWhatsAppSend.get(0);
                        if(objSendEmail != NULL){
                            
                            String status = String.isNotBlank(objSendEmail.status) ? objSendEmail.status : '';
                            String rejectReason = String.isNotBlank(objSendEmail.reject_reason) ? objSendEmail.reject_reason : '';

                            if(String.isNotBlank(status)){
                                if(status == 'sent'){
                                    responseMap.put('isWhtasAppSent', 'true');
                                }
                                if(String.isNotBlank(rejectReason)){
                                    if(status == 'rejected' && rejectReason == 'unsubscribe'){
                                        rejectReason = 'Unable to send whatsApp, for more detail check message history';
                                    }
                                    if(status == 'invalid'){
                                        rejectReason = 'invalid-number';
                                    }
                                }
                            }
                            responseMap.put('status', status);
                            responseMap.put('rejectReason', rejectReason);
                        }
                    }
                    errorLog = null;
                }
                else{
                    system.debug('=In else Part=');
                    errorLog = getErrorLogRecord(jsonString, 'inwiseHttpUtil','InwiseCalloutBulkSendWhatsApp');
                }
            }                
        }catch(Exception ex){
            // insertSyncHistory(ex.getMessage(),null,objSync.Id);
        }


        return new WhatsappWrapper(null, null, null, null, null, null,null, null, null, null, null, responseMap, errorLog);
    }
    public static string getJSONSendWhatsApp(InwiseUtil objInwiseUtil,String template_id,String content, String mobileNumber, String templateMapping, String mediaUrl, Boolean async,String tags,String jsonFields){
        String sendEmailJSONString = '{';
        sendEmailJSONString +=' "message": { '; 
            sendEmailJSONString += ' "content": "'+content+'", ';
            sendEmailJSONString +=' "template_id":  "' + template_id  +'" ,'; 
            
            sendEmailJSONString += ' "to": [ ';
                sendEmailJSONString += '{ ';
                sendEmailJSONString += ' "mobile_number": "'+getFormattedPhone(mobileNumber, objInwiseUtil)+'", ';
                sendEmailJSONString += '} ';
            sendEmailJSONString += ' ], ';
            sendEmailJSONString += ' "field_vars": [ ';
             sendEmailJSONString += jsonFields;
               
            sendEmailJSONString += ' ], ';
            sendEmailJSONString += ' "tags":  "'+tags+'" ,';
            //sendEmailJSONString += ' "template_fields_mapping":  "'+templateMapping+'" ,';
            sendEmailJSONString += ' "template_fields_mapping":  '+templateMapping+' ,';
            sendEmailJSONString += ' "media_url":  "'+mediaUrl+'" ';
        sendEmailJSONString += '} ,';
        sendEmailJSONString += ' "async":  "'+async+'" ';
        sendEmailJSONString += '} ';

        System.debug('sendEmailJSONString=='+sendEmailJSONString); 
        return sendEmailJSONString;
    }
    
    public class WrapperStatisticsResponse{
        public String sessionid {get;set;}
        public String serviceUrl {get;set;}
        
        public WrapperStatisticsResponse(){
            sessionid = '';
            serviceUrl = '';
        }
    }
    
    public Static Map<String,String> getCountryCodeMap(){
        Map<String,String> mapOfCountryCode = new Map<String,String>{ 'Afghanistan' => '93','Albania' => '355','Algeria' => '213','American Samoa' => '1684','Andorra' => '376','Angola' => '244','Anguilla' => '1264','Antigua and Barbuda' => '1268','Argentina' => '54','Armenia' => '374','Aruba' => '297','Australia' => '61','Austria' => '43','Azerbaijan' => '994','Bahamas' => '1242','Bahrain' => '973','Bangladesh' => '880','Belarus' => '375','Belgium' => '32','Belize' => '501','Benin' => '229','Bhutan' => '975','Bolivia' => '591','Bosnia and Herzegovina' => '387','Botswana' => '267','Brazil' => '55','Brunei' => '673','Bulgaria' => '359','Burkina Faso' => '226','Burundi' => '257','Cambodia' => '855','Cameroon' => '237','Cape Verde' => '238','Chile' => '56','Colombia' => '57','Comoros' => '269','Costa Rica' => '506','Croatia' => '385','Cuba' => '53','Cyprus' => '357','Czech Republic' => '420','Democratic Republic of Congo' => '243','Denmark' => '45','Djibouti' => '253','Dominica' => '1767','East Timor' => '670','Ecuador' => '593','Egypt' => '20','El Salvador' => '503','Equatorial Guinea' => '240','Eritrea' => '297','Estonia' => '372','Ethiopia' => '251','Fiji' => '679','Finland' => '358','France' => '33','Gambia' => '220','Georgia' => '995','Germany' => '49','Ghana' => '233','Gibraltar' => '350','Greece' => '30','Grenada' => '1473','Guatemala' => '502','Guinea' => '224','Guinea-Bissau' => '245','Guyana' => '592','Haiti' => '509','Honduras' => '504','Hong Kong' => '852','Hungary' => '36','Iceland' => '354','India' => '91','Indonesia' => '62','Iran' => '98','Iraq' => '964','Ireland' => '353','Israel' => '972','Italy' => '39','Ivory Coast' => '225','Jamaica' => '1876','Japan' => '81','Jordan' => '962','Kazakhstan' => '7','Kenya' => '254','Kosovo' => '377','Kuwait' => '965','Kyrgyzstan' => '996','Laos' => '856','Latvia' => '371','Lebanon' => '961','Lesotho' => '266','Libya' => '218','Liechtenstein' => '423','Lithuania' => '370','Luxembourg' => '352','Macau' => '853','Madagascar' => '261','Malawi' => '265','Malaysia' => '60','Maldives' => '223','Malta' => '356','Mauritania' => '222','Mauritius' => '230','Mexico' => '52','Moldova' => '373','Monaco' => '377','Mongolia' => '976','MontenegroMontenegro' => '382','Morocco' => '212','Mozambique' => '258','Myanmar' => '95','Namibia' => '264','Nauru' => '674','Nepal' => '977','Netherlands' => '31','New Zealand' => '64','Nicaragua' => '505','Nigeria' => '234','North Korea' => '850','Norway' => '47','Oman' => '968','Pakistan' => '92','Palestinian Authority' => '970','Panama' => '507','Papua New Guinea' => '675','Paraguay' => '595','Peru' => '51','Philippines' => '63','Poland' => '48','Portugal' => '351','Qatar' => '974','Republic of Congo' => '242','Republic of Macedonia' => '389','Romania' => '40','Russia' => '7','Rwanda' => '250','Samoa' => '685','San Marino' => '378','São Tomé and Príncipe' => '239','Saudi Arabia' => '966','Senegal' => '221','Serbia' => '381','Seychelles' => '248','Sierra Leone' => '232','Singapore' => '65','Slovakia' => '421','Slovenia' => '386','South Africa' => '27','South Korea' => '82','Spain' => '34','Sri Lanka' => '94','Sudan' => '249','Suriname' => '597','Swaziland' => '268','Sweden' => '46','Switzerland' => '41','Syria' => '963','Taiwan' => '886','Tajikistan' => '992','Tanzania' => '255','Thailand' => '66','Togo' => '228','Tunisia' => '216','Turkey' => '90','Turkmenistan' => '993','Uganda' => '256','Ukraine' => '380','United Arab Emirates' => '971','United Kingdom' => '44','United States/Canada' => '1','Uruguay' => '598','Uzbekistan' => '998','Vanuatu' => '678','Venezuela' => '58','Vietnam' => '84','Yemen' => '967','Zambia' => '260','Zimbabwe' => '263'};
        return mapOfCountryCode;
    }
}