/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 10 June 2021
*Purpose :   batch for report sync 

Modification Log
----------------
Date                  Version     Developer                  Comments
------------------------------------------------------------------------------------
20/06/2021            1.1.0       NLINEAXIS(Kapil Goutam)     Modified:- modified search of reports.
07/04/2021            1.1.1       NLINEAXIS(K.Goutam)         Modified:- Added error handling in case of api return not equal to 200. use case where inwise group was missing at inwise end & sf try to sync members
10/18/2021            1.1.2       NLINEAXIS(K.Goutam)         Modified:- Changes made related to delete API (get sync master created date time) in doSyncMembersWithInwise method
10/19/2021            1.1.3       NLINEAXIS(S.Vaishnav)       Modified:- Code indentation and optimization
10/21/2021            1.1.4       NLINEAXIS(S.Vaishnav)       Modified:- Fixed field duplicity issue in JSON
11/11/2021            1.1.5       NLINEAXIS(S.Vaishnav)       Modified:- Fixed report filter issue in report sync
11/22/2021            1.1.6       NLINEAXIS(S.Vaishnav)       Modified:- Fixed mobile phone mapping issue in report sync to inwise
11/23/2021            1.1.7       NLINEAXIS(S.Vaishnav)       Modified:- Fixed lookup field mapping issue in report sync to inwise
11/26/2021            1.1.8       NLINEAXIS(S.Vaishnav)       Modified:- Fixed record filter issue in report describe and Report lookup field mapping issue
12/02/2021            1.1.9       NLINEAXIS(S.Vaishnav)       Modified:- Fixed lookup field mapping issue in report sync to inwise
12/06/2021            1.1.10      NLINEAXIS(S.Vaishnav)       Modified:- Removed '-' from the json value in report sync to inwise

/******************************************************************************************/
global with sharing class BatchSyncMemberToInwiseReports implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

    boolean isContact                                           {get;set;}
    String sReportId                                            {get;set;}
    InwiseUtil objInwiseUtil                                    {get;set;}
    Account__c objInwiseAccount                                 {get;set;}
    Map<string,Mapping__c> mapInwiseMapping                     {get;set;}
    Map<string,Report_Lookup_Mapping__c> mapInwiseReportMapping {get;set;}
    AggregateResult[] objInwiseFields                           {get;set;}
    List<Mapping__c> listOfInwiseMapping                        {get;set;}
    List<Report_Lookup_Mapping__c> listOfInwiseReportMapping    {get;set;}
    boolean runForFailedOnly                                    {get;set;}
    Integer totalRecordsSize                                    {get;set;}
    Integer currentBatchNo                                      {get;set;}
    boolean isFirstBatch                                        {get;set;}

    Sync__c objSync;
    Sync_Master__c objSyncMaster;
    Map<Id,Contact> mapOfContact;
    Map<String, String> mapOfReportAllColumnAndRow;
    Map<Integer, String> mapOfReportAllColumn;

    public void init(Id syncMasterId, Id syncId, boolean isForFailed, boolean isContactP, String sReportIdP,boolean isFirst){

        mapOfContact = new Map<Id, Contact>();
        mapOfReportAllColumnAndRow = new Map<String, String>();
        mapOfReportAllColumn = new Map<Integer, String>();
        isFirstBatch = isFirst;
        isContact = isContactP;
        totalRecordsSize = 0;
        sReportId = sReportIdP;
        runForFailedOnly = isForFailed;

        objSyncMaster = inwiseUtil.doGetSyncMaster(syncMasterId);
        objSync = inwiseUtil.doGetSyncRecord(objSyncMaster.Sync__c);
        
        if(objSync.Account__c != NULL){
            objInwiseUtil = new InwiseUtil(new Account__c(Id = objSync.Account__c));
        }else{
            objInwiseUtil = new InwiseUtil(null);
        }
       
       mapInwiseMapping = new Map<string,Mapping__c>();
       mapInwiseReportMapping = new Map<string,Report_Lookup_Mapping__c>();
       
       if(objInwiseUtil.objInwiseAccount != NULL){

            listOfInwiseMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c from Mapping__c where Account__c =: objInwiseUtil.objInwiseAccount.Id AND Salesforce_Field__c != null WITH SECURITY_ENFORCED];
            listOfInwiseReportMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c,Sync__c, Salesforce_Field__c FROM Report_Lookup_Mapping__c where Account__c =: objInwiseUtil.objInwiseAccount.Id 
                                            AND Salesforce_Field__c != null AND Sync__c =: objSync.Id WITH SECURITY_ENFORCED];
            objInwiseFields = [SELECT inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:objInwiseUtil.objInwiseAccount.Id  group by inwise_FieldId__c,inwise_Field__c];
            
            if(!listOfInwiseMapping.isEmpty()){
                for(Mapping__c oMapping : listOfInwiseMapping){
                    String key = oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
                    mapInwiseMapping.put(key, oMapping);
                }  
            }

            if(!listOfInwiseReportMapping.isEmpty()){
                for(Report_Lookup_Mapping__c oMapping : listOfInwiseReportMapping){

                    String key = oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
                    Report_Lookup_Mapping__c objReportLookup = new Report_Lookup_Mapping__c();
                    objReportLookup = oMapping;

                    if(oMapping.Object_Type__c == 'Contact'){
                        if(oMapping.Salesforce_Field__c.contains('Contact.')){
                            objReportLookup.Salesforce_Field__c = oMapping.Salesforce_Field__c.replace('Contact.','');
                        }
                        else{
                            if((objReportLookup.Salesforce_Field__c.startsWith('FK_') && !objReportLookup.Salesforce_Field__c.contains('.')) || objReportLookup.Salesforce_Field__c.contains('.')){
                                objReportLookup.Salesforce_Field__c = oMapping.Salesforce_Field__c.replace('_','');
                            }
                            // if(objReportLookup.Salesforce_Field__c == 'FK_NAME'){
                            //     objReportLookup.Salesforce_Field__c = oMapping.Salesforce_Field__c.replace('FK_NAME','FKNAME');
                            // }
                        }
                    }
                    else if(oMapping.Object_Type__c == 'Lead'){
                        if(oMapping.Salesforce_Field__c.contains('Lead.')){
                            objReportLookup.Salesforce_Field__c = oMapping.Salesforce_Field__c.replace('Lead.','');
                        }
                        else {
                            if((objReportLookup.Salesforce_Field__c.startsWith('FK_') && !objReportLookup.Salesforce_Field__c.contains('.')) || objReportLookup.Salesforce_Field__c.contains('.')){
                                objReportLookup.Salesforce_Field__c = oMapping.Salesforce_Field__c.replace('_','');
                            }
                            // if(objReportLookup.Salesforce_Field__c == 'FK_NAME'){
                            //     objReportLookup.Salesforce_Field__c = oMapping.Salesforce_Field__c.replace('FK_NAME','FKNAME');
                            // }
                        }
                    }
                    mapInwiseReportMapping.put(key, objReportLookup);
                }
            }
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        currentBatchNo = 0;
        Integer columnNo = 1;
        List<Sobject> listOfSO=  new List<Sobject>();
        List<String> allSelectedIds = new List<String>();
        ApexPages.StandardSetController objStdSetController;
      
        List<Report> reportList = [SELECT Id,DeveloperName FROM Report WHERE DeveloperName =: sReportId WITH SECURITY_ENFORCED];
        if(!reportList.isEmpty()){

            String columnName = '';
            Boolean isIdColumnFound = false;
            Integer idColumnIndexNumber = -1;

            if(objSync.Contacts__c){
                columnName = 'CONTACT_ID';
            }
            else if(objSync.Leads__c){
                columnName = 'LEAD_ID';
            }

            // Describe selected report
            Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportList[0].Id);
            Reports.ReportMetadata reportMd = describe.getReportMetadata();

            for(String name : reportMd.getDetailColumns()){

                if(!isIdColumnFound){
                    idColumnIndexNumber++;
                }
                if(name == columnName){
                    isIdColumnFound = true;
                }

                if(name.contains('Contact.')){
                    if(name == 'Contact.Id'){
                        columnName = name;
                        isIdColumnFound = true;
                    }
                    String str = name.replace('Contact.','');
                    mapOfReportAllColumn.put(columnNo, str);
                }
                else if(name.contains('Lead.')){
                    if(name == 'Lead.Id'){
                        columnName = name;
                        isIdColumnFound = true;
                    }
                    String str = name.replace('Lead.','');
                    mapOfReportAllColumn.put(columnNo, str);
                }
                else{
                    mapOfReportAllColumn.put(columnNo, name);
                }
                columnNo++;
            }
            
            if(isIdColumnFound){

                Boolean isNext = true;
                String filterRecordIds = '';
                Boolean isLastExecution = false;
                Boolean isBooleanFilterAdded = false;

                while(isNext){

                    List<Reports.ReportFilter> reportFilterLi = new List<Reports.ReportFilter>();
                    if(reportMd.getReportFilters().size() > 0){
                        reportFilterLi.addAll(reportMd.getReportFilters());
                    }
                    
                    if(!isBooleanFilterAdded){
                        isBooleanFilterAdded = true;
                        Reports.ReportFilter reportFilter = new Reports.ReportFilter(columnName, 'notEqual', filterRecordIds);
                        reportFilterLi.add(reportFilter);
                        
                        String booleanFilter = reportMd.getReportBooleanFilter();
                        if(String.isNotBlank(booleanFilter)){
                            booleanFilter = '(' + booleanFilter + ') AND ' + reportFilterLi.size()+'';
                            reportMd.setReportBooleanFilter(booleanFilter);
                        }
                    }
                    else{
                        reportFilterLi.remove(reportFilterLi.size() - 1);
                        Reports.ReportFilter reportFilter = new Reports.ReportFilter(columnName, 'notEqual', filterRecordIds);
                        reportFilterLi.add(reportFilter);
                    }
                    reportMd.setReportFilters(reportFilterLi);

                    // Run a report synchronously
                    Reports.reportResults results = Reports.ReportManager.runReport(reportList[0].Id, reportMd, true);

                    if(!results.getAllData() || !isLastExecution){

                        isLastExecution = results.getAllData() ? true : false;
                        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
                        List<Reports.ReportDetailRow> listOfDetailRow = factDetails.getRows();

                        for(Reports.ReportDetailRow row : listOfDetailRow){
                            //iTotalCount1++;
                            List<Reports.ReportDataCell> cells = row.getDataCells();
                            
                            Integer rowDataNo = 1;
                            Reports.ReportDataCell dataCell = cells[idColumnIndexNumber];
                            allSelectedIds.add((Id)dataCell.getValue());
                            filterRecordIds += (String)dataCell.getValue() + ',';

                            // In custom report type we are getting Mobile column name "MobilePhone" in report metadata
                            // In standard report type we are getting Mobile column name "Phone3" in report metadata
                            // In our code we are managing field mapping on the basis of "MobilePhone" that's why we are replacing phone3 with mobilephone
                            for(Reports.ReportDataCell reportRow : cells){

                                String reportRowData = '';
                                String key = (Id)dataCell.getValue() + '-';

                                if(mapOfReportAllColumn.get(rowDataNo).contains('_') && !mapOfReportAllColumn.get(rowDataNo).contains('__c')){
                                    reportRowData = mapOfReportAllColumn.get(rowDataNo).replace('_','');
                                    key += reportRowData.toUpperCase() == 'PHONE3' ? 'MOBILEPHONE' : reportRowData.toUpperCase();
                                    mapOfReportAllColumnAndRow.put(key, reportRow.getLabel());
                                }else {
                                    key += mapOfReportAllColumn.get(rowDataNo).toUpperCase() == 'PHONE3' ? 'MOBILEPHONE' : mapOfReportAllColumn.get(rowDataNo).toUpperCase();
                                    mapOfReportAllColumnAndRow.put(key, reportRow.getLabel());
                                }
                                rowDataNo++;
                            }
                        }
                    }
                    else{
                        isNext = false;
                    }
                }
            }
        }
            
        String query = '';
        if(isContact){
            //query = 'SELECT Name FROM Contact WHERE Id IN : allSelectedIds'+(Test.isRunningTest()?' LIMIT 200':'');
            if (Schema.sObjectType.Contact.isAccessible()) {
                
                // Ensure all queried fields are accessible
                if (Schema.sObjectType.Contact.fields.Name.isAccessible()) {
                    query = 'SELECT Name FROM Contact WHERE Id IN : allSelectedIds'+(Test.isRunningTest()?' LIMIT 200':'');
                }
            }
        }else{
            //query = 'SELECT Name FROM Lead WHERE Id IN : allSelectedIds'+(Test.isRunningTest()?' LIMIT 200':'');
            if (Schema.sObjectType.Lead.isAccessible()) {
                
                // Ensure all queried fields are accessible
                if (Schema.sObjectType.Lead.fields.Name.isAccessible()) {
                    query = 'SELECT Name FROM Lead WHERE Id IN : allSelectedIds'+(Test.isRunningTest()?' LIMIT 200':'');
                }
            }
        }
        return(Database.getQueryLocator(query));
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope){

        try{
            ++currentBatchNo;
            Sync_Members__c objSyncMember;
            List<Logs__c> listOfLogs = new List<Logs__c>();
            List<Sync_Members__c> listOfSyncMembers = new List<Sync_Members__c>(); 

            for(sObject mbr: (List<sObject>) scope){
            
                objSyncMember = new Sync_Members__c();
    
                if(isContact){
                    if(Schema.sObjectType.Sync_Members__c.fields.Contact__c.isCreateable()){
                        objSyncMember.Contact__c = mbr.Id;
                    }
                }else{
                    if(Schema.sObjectType.Sync_Members__c.fields.Lead__c.isCreateable()){
                        objSyncMember.Lead__c = mbr.Id;
                    }
                } 
            
                if(Schema.sObjectType.Sync_Members__c.fields.Member_Record_ID__c.isUpdateable() && Schema.sObjectType.Sync_Members__c.fields.Member_Record_ID__c.isCreateable() ){
                    objSyncMember.Member_Record_ID__c = mbr.Id;
                }

                if(Schema.sObjectType.Sync_Members__c.fields.Sync_Master__c.isCreateable()){
                    objSyncMember.Sync_Master__c = objSyncMaster.Id;
                }
                if(Schema.sObjectType.Sync_Members__c.fields.Type__c.isCreateable()){
                    if(isContact){
                        objSyncMember.Type__c = 'Contact';  
                    }else{
                        objSyncMember.Type__c = 'Lead';  
                    }
                }
                listOfSyncMembers.add(objSyncMember); 
            }

            Map<String,boolean> external_id =new Map<String,boolean> ();
            Map<String,string> error_external_id =new Map<String,string> ();

            if(!listOfSyncMembers.isEmpty()){
                if(Schema.SObjectType.Sync_Members__c.isCreateable()){

                    JsonToApexPushExernalApp  successResponse = doSyncMembersWithInwise(listOfSyncMembers,false,listOfLogs);
          
                    for(Sync_Members__c sm : listOfSyncMembers){

                        sm.Is_Processed__c = true; 
                        //code removed because of issue field is not writable
                        //issue fix, sync master null in some cases.
                         
                        if(sm.Sync_Master__c == NULL ){
                            sm.Sync_Master__c = objSyncMaster.Id; 
                        }
                        if(successResponse.created !=null && !successResponse.created.isEmpty()){
                            for(String createdRecord: successResponse.created){
                                external_id.put(createdRecord,true);
                            } 
                            if(external_id.containsKey(sm.Member_Record_ID__c)) {
                                sm.Syncronized__c = true;
                            } 
                        }
 
                        if(successResponse.conflicts != null && !successResponse.conflicts.isEmpty()){
                            for(JsonToApexPushExernalApp.Errors conflictsRecord : successResponse.conflicts){
                                error_external_id.put(conflictsRecord.external_id, conflictsRecord.details);
                            } 
                            if(error_external_id.containsKey(sm.Member_Record_ID__c)) {
                                sm.Reason__c = error_external_id.get(sm.Member_Record_ID__c);
                            }
                        }
                        if(successResponse.updated !=null && !successResponse.updated.isEmpty()){
                            for(string updatedRecord: successResponse.updated){
                                external_id.put(updatedRecord,true);
                            } 
                            if(external_id.containsKey(sm.Member_Record_ID__c)) {
                                sm.Syncronized__c = true;
                            } 
                        }
 
                        if(successResponse.errors != null){
                            if(!successResponse.errors.isEmpty() ){
                                
                                for(JsonToApexPushExernalApp.Errors err: successResponse.errors){
                                    error_external_id.put(err.external_id,err.details);
                                }
                                if(error_external_id.containsKey(sm.Member_Record_ID__c)) {
                                    sm.Reason__c = error_external_id.get(sm.Member_Record_ID__c);
                                }
                            }
                        }else{
                            sm.Syncronized__c = true;
                        }
                    }

                    if(objInwiseUtil.objInwiseSetting.Log_Sync_Memebers__c){
                        insert listOfSyncMembers;
                    }
                }
            }

            if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                insert listOfLogs;
                listOfLogs = new List<Logs__c>(); 
            }
        }catch(Exception ex){
            System.debug(ex.getMessage()+''+ex.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext BC){

        List<Logs__c> listOfLogs = new List<Logs__c>();
        doSyncMembersWithInwise(null, true, listOfLogs);

        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
            listOfLogs = new List<Logs__c>();
        }
        if(objSync != NULL && objSync.Id != NULL){
            Sync__c objSyncToUpdate = new Sync__c(Id=objSync.Id);
            if(Schema.sObjectType.Sync__c.fields.Last_Run_By__c.isUpdateable()){
                objSyncToUpdate.Last_Run_By__c = UserInfo.getUserId();
            }
            if(Schema.sObjectType.Sync__c.fields.Last_Run__c.isUpdateable()){
                objSyncToUpdate.Last_Run__c = datetime.now();
            }
            update objSyncToUpdate;
        }
        // Commented because of method code is commented
        // inwiseGlobalAction.doClearAll(objInwiseUtil.objInwiseSetting.Track_Logs__c); 
    }
 
    public JsonToApexPushExernalApp doSyncMembersWithInwise(List<Sync_Members__c> listOfSyncMembers, boolean isLastBatch, List<Logs__c> listOfLogs){
        
        Http http = new Http();
        HttpResponse res;
        HttpRequest req;
        boolean isSuccess;
        JsonToApexPushExernalApp  recordOfresponse;

        try{
            isSuccess = true;
            String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contactsGroups/pushExternalApp?group_id='+ objSyncMaster.Group_Id__c;
 
            if(!objSync.Dont_Delete_Existing_Contacts__c && isLastBatch){
                // Datetime dtNowUTC = Datetime.newInstance(Datetime.now().dateGmt(), Datetime.now().timeGmt());
                Datetime dtNowUTC = Datetime.newInstance(objSyncMaster.CreatedDate.dateGmt(), objSyncMaster.CreatedDate.timeGmt());
                Datetime dtPrevious2Hours = dtNowUTC.addMinutes(-1);
                endpoint += '&delete_existing_contacts_by_last_date='+ EncodingUtil.urlEncode(dtPrevious2Hours.format('yyyy-MM-dd HH:mm:ss'),'UTF-8'); 
            }
            if(objInwiseUtil.objInwiseSetting.Use_Bulk_Push__c){
                endpoint += '&use_bulk_push='+objInwiseUtil.objInwiseSetting.Use_Bulk_Push__c;
            }

            if(isFirstBatch){
                endpoint += '&lock_group=true';
                isFirstBatch=false;
            }else if(isLastBatch){
                endpoint += '&unlock_group=true';
            }
 
            req = objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint); 
            req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);

            if(!isLastBatch) {
                req.setBody(getBodyMobileJsonPushExternalApp(objSyncMaster.Id, Integer.valueOf(objSyncMaster.Group_Id__c), listOfInwiseMapping, objInwiseFields, mapInwiseMapping, listOfSyncMembers));
            }else{
                req.setBody('');
            }

            req.setTimeout(120000);
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups/pushExternalApp','BatchSyncMemberToInwiseReports','doSyncMembersWithInwise'));
                if(!isLastBatch){
                    for(Sync_Members__c sm:listOfSyncMembers){
                        sm.Is_Processed__c = true;
                    }
                }
            }else{
                String resBody = '{"status": "complete"}';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }
        }catch(Exception ex){
            String resBody = ex.getMessage();
            res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups/pushExternalApp','SendToInwiseController','InwiseCalloutGroupsCreateGroupMobile'));
            isSuccess = false;
        }

        String jsonResponse= res.getBody();
        if(res.getStatusCode() == 200 && jsonResponse != null){
            recordOfresponse= JsonToApexPushExernalApp.parse(jsonResponse);
        }else{
            recordOfresponse = inwiseHttpUtil.getJsonToApexPushExernalAppError(res);
        }

        return recordOfresponse;
    }

    public String getBodyMobileJsonPushExternalApp(Id SyncMasterId, integer grpid,List<Mapping__c> listOfInwiseMapping,AggregateResult[] objInwiseFields,map<string,Mapping__c> mapInwiseMapping,List<Sync_Members__c> listOfSyncMembers){
        
        String soqlContact = '', soqlLead='';
        Set<String> setOfContactFields = new Set<String>();
        Set<String> setOfContactParentFields = new Set<String>();
        Set<String> setOfLeadParentFields = new Set<String>();
        Set<String> setOfLeadFields = new Set<String>();
        Set<Id> setOfContactMember = new Set<Id>();
        Set<Id> setOfLeadMember = new Set<Id>();
        List<Contact> listOfContact = new List<Contact>();
        List<Lead> listOfLead = new List<Lead>();
        
        if(!listOfInwiseMapping.isEmpty()){
            for(Mapping__c im:listOfInwiseMapping){

                if(im.Salesforce_Field__c.contains('_') && !im.Salesforce_Field__c.contains('__c')){
                    im.Salesforce_Field__c = im.Salesforce_Field__c.replace('_','');
                }
                if(im.Salesforce_Field__c.contains('__c.')){
                    im.Salesforce_Field__c = im.Salesforce_Field__c.replace('__c','__r');
                }

                if(im.Salesforce_Field__c != null && im.Salesforce_Field__c != '' && im.Salesforce_Field__c != 'None'){
                    if(im.Object_Type__c == InwiseConstants.SOBJECT_CONTACT){
                        setOfContactFields.add(im.Salesforce_Field__c);
                        if(im.Salesforce_Field__c.contains('.')){
                            setOfContactParentFields.add(im.Salesforce_Field__c);
                        }
                    }else if(im.Object_Type__c == InwiseConstants.SOBJECT_LEAD){
                        setOfLeadFields.add(im.Salesforce_Field__c);
                        if(im.Salesforce_Field__c.contains('.')){
                            setOfLeadParentFields.add(im.Salesforce_Field__c);
                        }
                    }
                }                      
            }  
        }
                
        //add email & phone to pass these in json by default
        setOfContactFields.add('Email');
        setOfContactFields.add('MobilePhone');
        setOfLeadFields.add('Email');
        setOfLeadFields.add('MobilePhone');
        soqlContact = getSOQLFromSet(setOfContactFields, InwiseConstants.SOBJECT_CONTACT);
        soqlLead = getSOQLFromSet(setOfLeadFields, InwiseConstants.SOBJECT_LEAD);
  
        if(!listOfSyncMembers.isEmpty()){
            for(Sync_Members__c mbr: listOfSyncMembers){
                if(mbr.Contact__c != NULL){
                    setOfContactMember.add(mbr.Contact__c);
                }
                if(mbr.Lead__c != NULL){
                    setOfLeadMember.add(mbr.Lead__c); 
                }
            }
        }

        if(!setOfContactMember.isEmpty() &&  !String.isEmpty(soqlContact)){
            listOfContact = Database.query(soqlContact + ' WHERE Id IN : setOfContactMember');
        }
        if(!setOfLeadMember.isEmpty() &&  !String.isEmpty(soqlLead)){
            listOfLead = Database.query(soqlLead + ' WHERE Id IN : setOfLeadMember');
        }

        String jsonString = '[';
        if(!listOfContact.isEmpty()){
            for(Contact oContact : listOfContact){
                jsonString += jsonForMobileCampaignPerRecord(oContact, InwiseConstants.SOBJECT_CONTACT, listOfInwiseMapping, objInwiseFields, mapInwiseMapping);
            }   
        }

        if(!listOfLead.isEmpty()){
            for(Lead oLead : listOfLead){
                jsonString += jsonForMobileCampaignPerRecord(oLead, InwiseConstants.SOBJECT_LEAD, listOfInwiseMapping, objInwiseFields, mapInwiseMapping);
            }   
        }

        if(jsonString.endsWith('},')){
            jsonString = jsonString.substring(0, jsonString.length()-1);
        }
        jsonString += ' ]';

        return jsonString;
    }
   
    public String jsonForMobileCampaignPerRecord(SObject obj, String sObjectType, List<Mapping__c> listOfInwiseMapping, AggregateResult[] objInwiseFields, Map<String, Mapping__c> mapInwiseMapping){
          
        Id campaignMemberId;   
        String email, mobile;
        Boolean isNeedToRemoveExtraComma = false;
        String key,val,val1;
        Mapping__c inw;
        Report_Lookup_Mapping__c inwReport;
          
        String jsonString = '{';
        jsonString += '"fields": [';
        campaignMemberId = NULL;
        isNeedToRemoveExtraComma = false;
        Boolean isFieldAlreadyAdded = false;// To avoid name field duplicity in JSON

        /*for(String str : mapOfReportAllColumnAndRow.keySet()){
            if(str.contains('0034H00002PCcmH')){
                System.debug(str);
            }
        }*/

        for(AggregateResult ar : objInwiseFields){

            val = '';
            key = ar.get('inwise_FieldId__c') + ':' + sObjectType;

            isFieldAlreadyAdded = false;
            inw = mapInwiseMapping.get(key);
            inwReport = mapInwiseReportMapping.get(key);

            /*if(inwReport != NULL && inwReport.Salesforce_Field__c != null && String.valueOf(obj.Id).contains('0034H00002PCcmH')){
                System.debug(obj.Id + '-' + inwReport.Salesforce_Field__c.toUpperCase());
            }
            
            if(inw != NULL && inw.Salesforce_Field__c != null && String.valueOf(obj.Id).contains('0034H00002PCcmH')){
                System.debug(obj.Id + '-' + inw.Salesforce_Field__c.toUpperCase());
            }*/

            // Priority to map report sync field mapping first
            if(inwReport != NULL && inwReport.Salesforce_Field__c != null && mapOfReportAllColumnAndRow.keySet().contains(obj.Id + '-' + inwReport.Salesforce_Field__c.toUpperCase())){
                    
                isFieldAlreadyAdded = true;
                val1 = mapOfReportAllColumnAndRow.get(obj.Id + '-' + inwReport.Salesforce_Field__c.toUpperCase());
                if(!String.isEmpty(val1)){
                    val1 = val1.escapeEcmaScript();
                }

                jsonString += ' { ';
                jsonString += ' "name": "' + inwReport.inwise_FieldId__c + '",';
                jsonString += ' "content": "' + (val1 == '-' ? '' : val1)  +'" ';
                jsonString += ' },';
            }
                    
            if(inw != NULL && inw.Salesforce_Field__c != null && mapOfReportAllColumnAndRow.keySet().contains(obj.Id + '-' + inw.Salesforce_Field__c.toUpperCase())){
                
                val = mapOfReportAllColumnAndRow.get(obj.Id + '-' + inw.Salesforce_Field__c.toUpperCase());
                if(!String.isEmpty(val)){
                    val = val.escapeEcmaScript();
                }
                if(!isNeedToRemoveExtraComma){
                    isNeedToRemoveExtraComma = true;    
                }

                if(inw.inwise_Field__c == 'Email' && email == NULL){
                    email = val;
                    isNeedToRemoveExtraComma = false;
                }else if(inw.inwise_Field__c == 'Mobile' && mobile == NULL){
                    mobile = inwiseHttpUtil.getFormattedPhone(val, objInwiseUtil);
                    isNeedToRemoveExtraComma = false;
                }else if(!isFieldAlreadyAdded){// to avoid email in inner json fields. as per boaz input
                    jsonString += ' { ';
                    jsonString += ' "name": "' + inw.inwise_FieldId__c + '",';
                    jsonString += ' "content": "' + (val == '-' ? '' : val) +'" ';
                    jsonString += ' },';
                }
            }
        }

        if(isNeedToRemoveExtraComma){
            jsonString = jsonString.substring(0, jsonString.length()-1);
        }

        if(jsonString.endsWith('},')){
            jsonString = jsonString.substring(0, jsonString.length()-1);
        }

        jsonString += '],';
        jsonString += '"external_id": "' + obj.Id +'",';
        jsonString += '"email": "'+ (email != NULL ? email == '-' ? '' : email : '') + '",'; 
        jsonString += '"mobile_number": "'+ (mobile != NULL ? mobile == '-' ? '' : mobile : '') +'",';
        jsonString += ' "confirmation_status": "confirmed",';
        jsonString += ' "clear_existing_fields": true'; 
        jsonString += '},'; //fields end  

        return jsonString;  
    }

    //@todo-Move in util
    // public String getSOQLFromSet(Set<String> setOfFields, String objectname){

    //     String soql = 'SELECT ';
    //     if(!setOfFields.isEmpty()){
    //         integer sz = 0;
    //         for(String s : setOfFields){
    //             soql += s  + (setOfFields.Size()-1 == sz ? ' ' : ',');
    //             sz++;
    //         }
    //         soql += ' from ' + objectname;
    //     }
    //     return soql; 
    // }

    public String getSOQLFromSet(Set<String> setOfFields, String objectName) {
        String soql = '';
        if (!setOfFields.isEmpty()) {
            // Check if the object is accessible
            if (!Schema.getGlobalDescribe().containsKey(objectName)) {
                System.debug('Object does not exist: ' + objectName);
                return '';
            }
            
            Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
            if (!objDescribe.isAccessible()) {
                System.debug('User does not have access to the object: ' + objectName);
                return '';
            }

            // Validate each field in the set for accessibility
            List<String> accessibleFields = new List<String>();
            for (String field : setOfFields) {
                if (objDescribe.fields.getMap().containsKey(field)) {
                    if (objDescribe.fields.getMap().get(field).getDescribe().isAccessible()) {
                        accessibleFields.add(field);
                    } else {
                        System.debug('User does not have access to the field: ' + field);
                    }
                } else {
                    System.debug('Field does not exist on object: ' + field);
                }
            }

            // Build the SOQL query if there are accessible fields
            if (!accessibleFields.isEmpty()) {
                soql = 'SELECT ' + String.join(accessibleFields, ',') + ' FROM ' + objectName;
            } else {
                System.debug('No accessible fields available for object: ' + objectName);
            }
        }
        return soql;
    }
}