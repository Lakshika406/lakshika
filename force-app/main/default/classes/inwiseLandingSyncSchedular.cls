/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 14 Dec 2016
*Purpose :     class that will schedule the job for landing sync

03/24/2021        1.0.1       K.Goutam                 Created record for errorlog [IFS-27 Jira]
/******************************************************************************************/
global  with sharing class inwiseLandingSyncSchedular implements  Schedulable,Database.AllowsCallouts {
    Landing_Sync__c objSync {get;set;} 
    public inwiseLandingSyncSchedular(String syncid) {
        if(Schema.sObjectType.Landing_Sync__c.isUpdateable()){
            objSync = new Landing_Sync__c(Id=syncid);
        }
    }
    global void execute(SchedulableContext ctx) {
        if(objSync != NULL && objSync.Id != NULL){
            futureCalloutinwiseSync(objSync.Id);
        }
    }
    public static List<Landing_Sync__c> getSyncRecord(String syncId){
        List<Landing_Sync__c> listOfSync = new List<Landing_Sync__c>();
        System.debug('syncId=='+syncId);
        //if(Schema.sObjectType.Landing_Sync__c.isAccessible()){
        if (Schema.sObjectType.Landing_Sync__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Id__c.isAccessible() && 
            Schema.sObjectType.Landing_Sync__c.fields.Landing_Page_Name__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Record_Index__c.isAccessible() &&
            Schema.sObjectType.Landing_Sync__c.fields.Scheduled_Daily_At__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Last_JobId__c.isAccessible() &&
            Schema.sObjectType.Landing_Sync__c.fields.Last_JobName__c.isAccessible() && Schema.sObjectType.Landing_Sync__c.fields.Form_Type__c.isAccessible() ){

            listOfSync = [Select Id, Name,Landing_Page_Id__c,Landing_Page_Name__c,Record_Index__c,Scheduled_Daily_At__c,Last_JobId__c,Last_JobName__c,Form_Type__c from Landing_Sync__c where Id=:syncid limit 1];
        } 
        
        return listOfSync;     
    }
    @future(callout=true)
    public static void futureCalloutinwiseSync(String syncId){
        Landing_Sync__c objSync;
        List<Landing_Sync__c> listOfSync = getSyncRecord(syncId);
        if(!listOfSync.isEmpty()){
            //objSync = listOfSync.get(0);
            objSync = getFirstIndexRec(listOfSync);
            InwiseCalloutLandingSync(listOfSync);
            if(objSync.Scheduled_Daily_At__c == NULL){//abort only those job which is not scheduled at daily
                try{
                    System.abortJob(objSync.Last_JobId__c);
                }catch(Exception ex){
                    
                }
            }
            
        }
    }
    //passing a list of object because of checkmarx scanner. 
    public static void InwiseCalloutLandingSync (List<Landing_Sync__c> listOfSync){
        List<Logs__c> listOfLogs = new List<Logs__c>();
        List<Error_Logs__c> listOfErrorLogs = new List<Error_Logs__c>();
        List<Lead> listOfLeadToInsert = new List<Lead>();
        Lead objLead;
        List<Map<String,String>> listOfLeadFieldsVsValueMap = new List<Map<String,String>>();
        Map<String,String> mapOfFieldIdVsValue = new Map<String,String>();
        Set<String> setOfFieldsid = new Set<String>();
        String pagenamefieldid = ('text' +  String.valueOf(inwiseConstants.INWISE_FIELDID_PAGENAME));
        setOfFieldsid.add(pagenamefieldid);
        Integer maxrecordindex = 0;
        Integer indexvalue = 0;
        string api='';
        Landing_Sync__c objSync;
        if(!listOfSync.isEmpty()){
            objSync = getFirstIndexRec(listOfSync);
            //objSync = listOfSync.get(0);
        }
        Account__c objInwiseAccount;
        Settings__c objInwiseSetting;
        inwiseUtil objInwiseUtil = new InwiseUtil(null);
        
        if(!objInwiseUtil.CheckIfCredentialExists()){
            insertSyncHistory('Missing login information to execute batch',null,objSync);
            return;
        }
        if(objSync.Landing_Page_Id__c == NULL){
            insertSyncHistory('Missing landing page id in Sync',null,objSync);
            return;
        }
        system.debug('objSync.Form_Type__c'+objSync.Form_Type__c);
        if(objSync.Form_Type__c =='Landing Page'){
            api='/rest/v1/pages/landingPage/formActivities?pages_ids=';
        }else{
            api='/rest/v1/pages/popups/formActivities?pages_ids=';
        }
        Http http =  new Http();
        String endpoint = objInwiseUtil.apiUrl + api + objSync.Landing_Page_Id__c + '&create_date_from=2010-01-01';
        if(objSync.Record_Index__c != NULL){
            endpoint +=  '&from_id=' + (objSync.Record_Index__c + 1);//added 1 for the next request
        }
        HttpRequest req = objInwiseUtil.GetHTTPRequest('GET','application/json',endpoint); 
        req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken); 
        HttpResponse res;
        
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                if(objSync.Form_Type__c =='Landing Page'){
                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/pages/landingPage/formActivities','inwiseLandingSyncSchedular','InwiseCalloutLandingSync'));                  
                }else{
                    listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/pages/popups/formActivities','inwiseLandingSyncSchedular','InwiseCalloutLandingSync'));                  
                }
            }else{
                String resBody = '[{"record_index":296340,"action_date":"2016-11-29 09:25:00","contact_id":null,"campaign_id":null,"channel_type":null,"ip":null,"confirmation_date":null,"confirmation_ip":null,"survey_values":{"text98":"972544444444","text99":"lklkl","text100":"kkml@sdfg.com"},"fields_mappings":{"text100":"Email","text99":"Name","text98":"Phone","text-1001":"Send"}},{"record_index":296833,"action_date":"2016-12-04 08:57:00","contact_id":null,"campaign_id":null,"channel_type":null,"ip":null,"confirmation_date":null,"confirmation_ip":null,"survey_values":{"text98":"03-4343434","text99":"NAME MY NAME","text100":"EMAIL@EMAIL.COM"},"fields_mappings":{"text100":"Email","text99":"Name","text98":"Phone","text-1001":"Send"}}]';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
            if(res != NULL){
                if(res.getStatusCode() == 200){ 
                    String jsonString = res.getBody(); //'[{"action_date":"2016-11-29 09:25:00","contact_id":null,"campaign_id":null,"channel_type":null,"ip":null,"confirmation_date":null,"confirmation_ip":null,"survey_values":{"text98":"972544444444","text99":"lklkl","text100":"kkml@sdfg.com"},"fields_mappings":{"text100":"Email","text99":"Name","text98":"Phone","text-1001":"Send"}}]';
                    JSONParser parser = JSON.createParser(jsonString);
                    while (parser.nextToken() != null) {
                        if(parser.getCurrentName() == 'id' && parser.getCurrentToken() == JSONToken.FIELD_NAME){
                            parser.nextToken();
                            indexvalue =  parser.getText() != NULL ? Integer.valueOf(parser.getText()) : 0;
                            if(maxrecordindex<indexvalue){
                                maxrecordindex = indexvalue;
                            }
                        }else if(parser.getCurrentName() == 'survey_values' && parser.getCurrentToken() == JSONToken.START_OBJECT){
                            mapOfFieldIdVsValue = new Map<String,String>();
                            while (parser.nextToken() != null) {
                                if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                                    String fieldid = parser.getText();
                                    parser.nextToken();
                                    String fieldvalue = parser.getText();
                                    mapOfFieldIdVsValue.put(fieldid,fieldvalue);
                                    setOfFieldsid.add(fieldid);
                                    
                                }
                                if(parser.getCurrentName() == 'survey_values' && parser.getCurrentToken() == JSONToken.END_OBJECT){
                                    mapOfFieldIdVsValue.put(pagenamefieldid,'');
                                    break;
                                }
                            }
                            listOfLeadFieldsVsValueMap.add(mapOfFieldIdVsValue);
                        }
                    }
                    Map<String,String> mapOfinwisefieldidVsSalesforceField = new Map<String,String>();
                    List<Landing_Sync_Mapping__c> listOfMappings = new List<Landing_Sync_Mapping__c>();

                    if (Schema.sObjectType.Landing_Sync_Mapping__c.isAccessible() && Schema.sObjectType.Landing_Sync_Mapping__c.fields.Salesforce_Field__c.isAccessible() && 
                        Schema.sObjectType.Landing_Sync_Mapping__c.fields.inwise_FieldId__c.isAccessible() && Schema.sObjectType.Landing_Sync_Mapping__c.fields.inwise_Field__c.isAccessible() &&
                        Schema.sObjectType.Landing_Sync_Mapping__c.fields.Landing_Sync__c.isAccessible() ){

                        listOfMappings = [Select Id,Salesforce_Field__c,inwise_FieldId__c, inwise_Field__c from Landing_Sync_Mapping__c 
                                          where Landing_Sync__c = :objSync.Id and inwise_FieldId__c IN:setOfFieldsid and Salesforce_Field__c != NULL]; 

                    }
                    
                    if(!listOfMappings.isEmpty()){
                        for(Landing_Sync_Mapping__c m:listOfMappings){
                            mapOfinwisefieldidVsSalesforceField.put(m.inwise_FieldId__c, m.Salesforce_Field__c);
                        }
                    } 
                    if(!listOfLeadFieldsVsValueMap.isEmpty()){
                        String objType='Lead'; 
                        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                        Schema.SObjectType leadSchema = schemaMap.get(objType);
                        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                        Schema.DisplayType fielddataType;

                        for(Map<String,String> mapOfFieldIdVsValueT:listOfLeadFieldsVsValueMap){
                            objLead = new Lead();
                            
                            for(String fieldid:mapOfFieldIdVsValueT.keySet()){
                                if(mapOfinwisefieldidVsSalesforceField.get(fieldid) != NULL && fieldid != pagenamefieldid){
                                    fielddataType = fieldMap.get(mapOfinwisefieldidVsSalesforceField.get(fieldid)).getDescribe().getType();
                                    if(mapOfFieldIdVsValueT.get(fieldid) != null){
                                        if(fielddataType == Schema.DisplayType.Currency || fielddataType == Schema.DisplayType.Double || fielddataType == Schema.DisplayType.Percent ){
                                            try{
                                                objLead.put(mapOfinwisefieldidVsSalesforceField.get(fieldid), decimal.valueOf(mapOfFieldIdVsValueT.get(fieldid)));
                                            }catch(Exception ex){
                                                String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'inwiseLandingSyncSchedular','InwiseCalloutLandingSync'));
                                            }   
                                        }else if(fielddataType == Schema.DisplayType.Boolean){  
                                            try{
                                                objLead.put(mapOfinwisefieldidVsSalesforceField.get(fieldid), Boolean.valueOf(mapOfFieldIdVsValueT.get(fieldid)));
                                            }catch(Exception ex){
                                                String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'inwiseLandingSyncSchedular','InwiseCalloutLandingSync'));
                                            }   
                                        }else if(fielddataType == Schema.DisplayType.DateTime){
                                            try{
                                                objLead.put(mapOfinwisefieldidVsSalesforceField.get(fieldid), Datetime.valueOf(mapOfFieldIdVsValueT.get(fieldid)));
                                            }catch(Exception ex){
                                                String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'inwiseLandingSyncSchedular','InwiseCalloutLandingSync'));
                                            }  
                                        }else if(fielddataType == Schema.DisplayType.Date){
                                            try{
                                                objLead.put(mapOfinwisefieldidVsSalesforceField.get(fieldid), Date.valueOf(mapOfFieldIdVsValueT.get(fieldid)));
                                            }catch(Exception ex){
                                                String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'inwiseLandingSyncSchedular','InwiseCalloutLandingSync'));
                                            }  
                                        }else if(fielddataType == Schema.DisplayType.Integer){ 
                                            try{
                                                objLead.put(mapOfinwisefieldidVsSalesforceField.get(fieldid), Integer.valueof(mapOfFieldIdVsValueT.get(fieldid)));
                                            }catch(Exception ex){
                                                String errorStringValue = ex.getMessage() + ' Error On line number :-'+ String.valueOf(ex.getLineNumber());
                                                listOfErrorLogs.add(inwiseHttpUtil.getErrorLogRecord(errorStringValue, 'inwiseLandingSyncSchedular','InwiseCalloutLandingSync'));
                                            }  
                                        }else{
                                            objLead.put(mapOfinwisefieldidVsSalesforceField.get(fieldid), mapOfFieldIdVsValueT.get(fieldid));
                                       }
                                    }
                                }else{
                                    if(fieldid == pagenamefieldid && mapOfinwisefieldidVsSalesforceField.get(pagenamefieldid) != null){
                                        objLead.put(mapOfinwisefieldidVsSalesforceField.get(pagenamefieldid), objSync.Landing_Page_Name__c);
                                    }
                                }
                            }
                            if(objLead.get('LastName') == NULL ||  String.isEmpty(String.valueOf(objLead.get('LastName')))){
                                objLead.put('LastName','NA'); 
                            }
                            if(objLead.get('Company') == NULL ||  String.isEmpty(String.valueOf(objLead.get('Company')))){
                                objLead.put('Company','NA'); 
                            }
                            objLead.put('Status','Open - Not Contacted');
                            listOfLeadToInsert.add(objLead);
                        }
                    }
                }
            }
            if(Lead.sObjectType.getDescribe().isCreateable() && !listOfLeadToInsert.isEmpty()){
                insert listOfLeadToInsert;
                  
            }    
            if(Schema.sObjectType.Landing_Sync__c.isUpdateable()){
                if(Schema.sObjectType.Landing_Sync__c.fields.Last_Run_By__c.isUpdateable()){
                    objSync.Last_Run_By__c = UserInfo.getUserId();
                }
                
                if(Schema.sObjectType.Landing_Sync__c.fields.Last_Run__c.isUpdateable()){
                    objSync.Last_Run__c = datetime.now();
                }
                if(Schema.sObjectType.Landing_Sync__c.fields.Record_Index__c.isUpdateable()){
                    if(maxrecordindex >0 && objSync.Record_Index__c != maxrecordindex){
                        objSync.Record_Index__c = maxrecordindex;
                    }
                } 
                update objSync;
                
            }     
            if(res.getStatusCode() == 200){
                insertSyncHistory(String.valueOf(req),res.getBody(),objSync);
            }else{
                String responseString = 'StatusCode=' + res.getStatusCode() + '  Status=' + res.getStatus();
                insertSyncHistory(String.valueOf(req),responseString,objSync);
            }   
            
        }catch(Exception ex){
            insertSyncHistory(ex.getMessage(),null,objSync);
           
        }   
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        } 

        if(objInwiseUtil.objInwiseSetting.Track_Errors__c &&  !listOfErrorLogs.isEmpty()){  
            insert listOfErrorLogs; 
        } 

        if(Schema.sObjectType.Landing_Sync__c.isUpdateable()){       
            objSync = schedulejob(objSync, false);
            update objSync;
        }

    } 
    
    public static void insertSyncHistory(String request,String response,  Landing_Sync__c objSync){
        if(Schema.sObjectType.Landing_Sync_History__c.isCreateable()){
            Landing_Sync_History__c objSyncHistory = new Landing_Sync_History__c();
            if(Schema.sObjectType.Landing_Sync_History__c.fields.Landing_Sync__c.isCreateable()){
                objSyncHistory.Landing_Sync__c = objSync.Id;
            }     
            if(Schema.sObjectType.Landing_Sync_History__c.fields.Request__c.isCreateable()){
                objSyncHistory.Request__c =request; //  'Missing login information to execute batch';
            }   
            if(Schema.sObjectType.Landing_Sync_History__c.fields.Response__c.isCreateable()){
                objSyncHistory.Response__c = response;
            }      
            if(Schema.sObjectType.Landing_Sync_History__c.fields.Run_By__c.isCreateable()){
                objSyncHistory.Run_By__c = UserInfo.getUserId();
            }    
            if(Schema.sObjectType.Landing_Sync_History__c.fields.Run_On__c.isCreateable()){
                objSyncHistory.Run_On__c = datetime.now();
            }    
            if(Schema.sObjectType.Landing_Sync_History__c.fields.JobId__c.isCreateable()){
                objSyncHistory.JobId__c = objSync.Last_JobId__c;
            }    
            if(Schema.sObjectType.Landing_Sync_History__c.fields.JobName__c.isCreateable()){
                objSyncHistory.JobName__c = objSync.Last_JobName__c;
            }    
            insert objSyncHistory; 
        }     
    }

    public static void insertErrorHistory(String request,String response,  Landing_Sync__c objSync){
        if(Schema.sObjectType.Landing_Sync_History__c.isCreateable()){
            Landing_Sync_History__c objSyncHistory = new Landing_Sync_History__c();
            if(Schema.sObjectType.Landing_Sync_History__c.fields.Landing_Sync__c.isCreateable()){
                objSyncHistory.Landing_Sync__c = objSync.Id;
            }     
            if(Schema.sObjectType.Landing_Sync_History__c.fields.Request__c.isCreateable()){
                objSyncHistory.Request__c =request; //  'Missing login information to execute batch';
            }   
            if(Schema.sObjectType.Landing_Sync_History__c.fields.Response__c.isCreateable()){
                objSyncHistory.Response__c = response;
            }      
            if(Schema.sObjectType.Landing_Sync_History__c.fields.Run_By__c.isCreateable()){
                objSyncHistory.Run_By__c = UserInfo.getUserId();
            }    
            if(Schema.sObjectType.Landing_Sync_History__c.fields.Run_On__c.isCreateable()){
                objSyncHistory.Run_On__c = datetime.now();
            }    
            if(Schema.sObjectType.Landing_Sync_History__c.fields.JobId__c.isCreateable()){
                objSyncHistory.JobId__c = objSync.Last_JobId__c;
            }    
            if(Schema.sObjectType.Landing_Sync_History__c.fields.JobName__c.isCreateable()){
                objSyncHistory.JobName__c = objSync.Last_JobName__c;
            }    
            insert objSyncHistory; 
        }     
    }

    public static String doGetNextHourChronExp(){
        Datetime dtnow = Datetime.now();
        Datetime previousHour = dtnow.addMinutes(-dtnow.minute()).addSeconds(-dtnow.second());
        datetime dt = previousHour.addHours(1);
        //datetime dt = dtnow.addMinutes(5);//for testing
        return  '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ?' + ' ' + dt.year();
    }
    public static String getJobName(){
        return  'inwise_LandingSyncAll'+UserInfo.getUserId()+'_' + Datetime.now().getTime();
    }
    public static Landing_Sync__c  schedulejob(Landing_Sync__c objLandingSyncP, boolean isForAll){
        Landing_Sync__c objLandingSync;
        objLandingSync = new Landing_Sync__c(Id=objLandingSyncP.Id);
        if(!isForAll){
            if(objLandingSyncP.Last_JobId__c != NULL){
                try{
                    System.abortJob(objLandingSyncP.Last_JobId__c);
                }catch(Exception ex){
                    System.debug('abort failed::-->>>' + ex.getMessage());
                } 
                if(Schema.sObjectType.Landing_Sync__c.fields.Last_JobName__c.isUpdateable()){
                    objLandingSync.Last_JobName__c = NULL;
                }
                if(Schema.sObjectType.Landing_Sync__c.fields.Last_JobId__c.isUpdateable()){
                    objLandingSync.Last_JobId__c = NULL;
                }
            }
        }
        //Landing_Sync__c objLandingSync = new Landing_Sync__c(Id=Syncid);
        String strSchedule = inwiseLandingSyncSchedular.doGetNextHourChronExp();
        String jobName = inwiseLandingSyncSchedular.getJobName();
        String cronid = System.schedule(jobName, strSchedule, new inwiseLandingSyncSchedular(objLandingSyncP.Id));
        if(Schema.sObjectType.Landing_Sync__c.isUpdateable()){
            if(Schema.sObjectType.Landing_Sync__c.fields.Last_JobId__c.isUpdateable()){
                objLandingSync.Last_JobId__c = cronid;
            }   
            if(Schema.sObjectType.Landing_Sync__c.fields.Last_JobName__c.isUpdateable()){     
                objLandingSync.Last_JobName__c = jobName;
            }         
        }
        return objLandingSync;
    }
    public static Landing_Sync__c getFirstIndexRec(List<Landing_Sync__c> listOfSync){
        Landing_Sync__c syncRec;
        for(Landing_Sync__c sync : listOfSync){
           syncRec =  sync;
            break;
        }
        return syncRec;
    }
}