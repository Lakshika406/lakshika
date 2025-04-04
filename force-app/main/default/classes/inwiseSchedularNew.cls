/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 01 Nov 2017
*Purpose :    copied from old class because package was not allowing to remove callout interface

Modification Log
----------------
Date                  Version     Developer              Comments
------------------------------------------------------------------------------------
11/01/2017          1.0.0       K.Goutam                 Created
06/09/2021          1.1.0       K.Goutam                 Modified:-Added code for BatchSyncMemberToInwiseReports call.
11/11/2021          1.1.1       S.Vaishnav               Modified:- Fixed report filter issue in report sync
11/26/2021          1.1.2       S.Vaishnav               Modified:- Fixed record filter issue in report describe

/******************************************************************************************/
global  with sharing class inwiseSchedularNew implements  Schedulable {

    Sync__c objSync {get;set;}
    static String newLineFeed = '\n';

    public inwiseSchedularNew(String syncid){
        if(Schema.sObjectType.Sync__c.isUpdateable()){
            objSync = new Sync__c(Id=syncid);
        }
    }

    global void execute(SchedulableContext ctx) {
        if(objSync != NULL && objSync.Id != NULL){
            futureCalloutinwiseSync(objSync.Id);
        }
    }
   
    //@future(callout=true)
    public static void futureCalloutinwiseSync(String syncId){
        Sync__c objSync =inwiseUtil.doGetSyncRecord(syncId);
        List<Sync__c> listOfSync = new List<Sync__c>();
        listOfSync.add(objSync);

        InwiseCalloutGroupsCreateGroup(listOfSync);
        if(Schema.sObjectType.Sync__c.fields.Scheduled_Daily_At__c.isAccessible() && Schema.sObjectType.Sync__c.fields.Last_JobId__c.isAccessible()){
            if(objSync.Scheduled_Daily_At__c == NULL){//abort only those job which is not scheduled at daily
                try{
                    System.abortJob(objSync.Last_JobId__c);
                }catch(Exception ex){
                    //System.debug(ex.getMessage());
                }
            }
        }  
    }

    //passing a list of object because of checkmarx scanner. 
    public static void InwiseCalloutGroupsCreateGroup (List<Sync__c> listOfSync){

        List<Contact> listOfContact = new List<Contact>();
        List<Lead> listOfLead = new List<Lead>();
        Sync__c objSync;

        if(!listOfSync.isEmpty()){
            objSync = listOfSync.get(0);
        }

        Account__c objInwiseAccount;
        Settings__c objInwiseSetting;
        AggregateResult[] objInwiseFields;
        List<Mapping__c> listOfInwiseMapping;
        inwiseUtil objInwiseUtil;

        if(objSync.Account__c != NULL){
            objInwiseUtil = new InwiseUtil(new Account__c(Id=objSync.Account__c));
        }else{
            objInwiseUtil = new InwiseUtil(null);
        }
        
        if(!objInwiseUtil.CheckIfCredentialExists()){
            insertSyncHistory('Missing login information to execute batch',null,objSync);
            return;
        }
      
        if(Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Default__c.isAccessible()){
            List<Account__c> listOfAccounts = [SELECT Id,Name FROM Account__c WHERE Default__c = true limit 1];
            if(!listOfAccounts.isEmpty()){
                objInwiseAccount = listOfAccounts.get(0);
                if(Schema.sObjectType.Mapping__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible() &&
                    Schema.sObjectType.Mapping__c.fields.inwise_Field__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.inwise_FieldId__c.isAccessible() &&
                    Schema.sObjectType.Mapping__c.fields.Object_Type__c.isAccessible() && Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isAccessible()){

                    listOfInwiseMapping = [SELECT Id,name,Account__c,inwise_Field__c, inwise_FieldId__c,Object_Type__c, Salesforce_Field__c from Mapping__c where Account__c=:objInwiseAccount.Id];
                    objInwiseFields = [SELECT inwise_FieldId__c inwise_FieldId__c,inwise_Field__c inwise_Field__c from Mapping__c where Account__c=:objInwiseAccount.Id  group by inwise_FieldId__c,inwise_Field__c];
                }      
            }
        }
        
        if(objInwiseAccount == NULL || listOfInwiseMapping.isEmpty() || objInwiseFields == NULL){
            insertSyncHistory('Missing mapping information to execute batch',null,objSync); 
            return ;
         }
        
        //prepare map for mapping vales
        Map<string,Mapping__c> mapInwiseMapping = new Map<string,Mapping__c>();
        
        for(Mapping__c oMapping:listOfInwiseMapping){
            string key= oMapping.inwise_FieldId__c + ':' + oMapping.Object_Type__c;
            mapInwiseMapping.put(key,oMapping);
        }

        Http http = new Http();
        HttpResponse res;
        Integer grpId = Integer.valueOf(objSync.Group_Id__c);

        try{
            if(grpId != 0){
                doSyncMembersBySchedule(listOfSync, objInwiseUtil);
            }   
        }catch(Exception ex){
            //System.debug('Exception::-->>' + ex.getMessage());
        }   
    }

    //to bulkify method for security review
    public static inwiseUtil.WrapperStatus doSyncMembersBySchedule(List<Sync__c> listOfSync,InwiseUtil objInwiseUtil){

        inwiseUtil.WrapperStatus objStatus = new inwiseUtil.WrapperStatus();
        List<Contact> listOfContact = new List<Contact>();
        List<Lead> listOfLead = new List<Lead>();
        Sync__c objSync;

        if(!listOfSync.isEmpty()){
            objSync = listOfSync.get(0);
        }
        try{
            Decimal totalMembers = 0;
            Boolean isViewDeleted = false;
            if(objSync.Is_Created_By_View__c){
                Set<Id> allSelectedIds = new Set<Id>();
                ApexPages.StandardSetController objStdSetController;

                if(objSync.Contacts__c && objSync.Contact_View__c != NULL){
                    String query = '';
                    if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible()){
                        query = 'SELECT Name FROM Contact LIMIT 1';
                    }
                    objStdSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                    List<SelectOption> listOfAvailableView = objStdSetController.getListViewOptions();
                    isViewDeleted = doCheckIfViewDeleted(listOfAvailableView,objSync.Contact_View__c);

                    if(!isViewDeleted){
                        objStdSetController.setFilterId(objSync.Contact_View__c);
                    }else{
                        objStdSetController = NULL;
                    }
                }else if(objSync.Leads__c && objSync.Lead_View__c != NULL){
                    //String query = 'SELECT Name FROM Lead LIMIT 1';
                    String query = '';
                    if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.fields.Name.isAccessible()){
                        query = 'SELECT Name FROM Lead LIMIT 1';
                    }
                    objStdSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                    List<SelectOption> listOfAvailableView = objStdSetController.getListViewOptions();
                    isViewDeleted = doCheckIfViewDeleted(listOfAvailableView,objSync.Lead_View__c);
                    if(!isViewDeleted){
                        objStdSetController.setFilterId(objSync.Lead_View__c);
                    }else{
                        objStdSetController = NULL;
                    }   
                }

                //@todo - test if view deleted at this time..
                if(objStdSetController != NULL){
                    objStdSetController.first();
                    objStdSetController.setPageSize(1000);
                    totalMembers = objStdSetController.getResultSize();
                    boolean hasNext =  totalMembers > 0 ? true : false;

                    while(hasNext){
                        allSelectedIds.addAll(new Map<Id, sObject>(objStdSetController.getRecords()).keySet());
                        hasNext = objStdSetController.getHasNext();
                        objStdSetController.next();
                    }
                }
            }else if(objSync.Is_Created_By_Report__c){
                List<Report> reportList;
                Set<String> allSelectedIds = new Set<String>();
                if(objSync.Contacts__c){
                    if(Schema.sObjectType.Report.isAccessible() && Schema.sObjectType.Report.fields.DeveloperName.isAccessible()){
                        reportList = [SELECT Id,DeveloperName FROM Report WHERE DeveloperName = :objSync.Contact_Report__c ];
                    }
                }else{
                    if(Schema.sObjectType.Report.isAccessible() && Schema.sObjectType.Report.fields.DeveloperName.isAccessible()){
                        reportList = [SELECT Id,DeveloperName FROM Report WHERE DeveloperName = :objSync.Lead_Report__c ];
                    }
                }
            
                if(!reportList.isEmpty()){

                    String columnName = '';
                    Integer idColumnIndexNumber = 0;
                    Boolean isIdColumnFound = false;

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
                        if(name == columnName){
                            isIdColumnFound = true;
                            break;
                        }
                        idColumnIndexNumber++;
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
                                    Reports.ReportDataCell dataCell = cells[idColumnIndexNumber];
                                    allSelectedIds.add((Id)dataCell.getValue());
                                    filterRecordIds += (String)dataCell.getValue() + ',';
                                }
                            }
                            else{
                                isNext = false;
                            }
                        }
                    }
                }

                if(objSync.Contacts__c){
                    String countString = 'SELECT COUNT() from Contact WHERE Id IN :allSelectedIds';
                    totalMembers = database.countquery(countString);
                }else{
                    String countString = 'SELECT COUNT() from Lead WHERE Id IN :allSelectedIds';
                    totalMembers = database.countquery(countString);
                }
            }else{
                if(objSync.Contacts__c && objSync.Contacts_SOQL__c != NULL){
                    try{
                        String countString = objSync.Contacts_SOQL__c.substringAfter('from');
                        countString = 'SELECT COUNT() from ' + countString;
                        totalMembers = database.countquery(countString);
                    }catch(Exception ex){
                        // System.debug('Exception SOQL::-->>>' + ex.getMessage());
                    }   
                }
                if(objSync.Leads__c && objSync.Leads_SOQL__c != NULL){
                    try{
                        String countString = objSync.Leads_SOQL__c.substringAfter('from');
                        countString = 'SELECT COUNT() from ' + countString;
                        totalMembers += database.countquery(countString);
                    }catch(Exception ex){
                        // System.debug('Exception SOQL::-->>>' + ex.getMessage());
                    }
                }
            }
                
            Integer batchSize = objInwiseUtil.getBatchSize();
            if(objSync.Is_Created_By_View__c && isViewDeleted){
                objStatus.isSuccess = false;
                objStatus.msg = inwiseConstants.MSG_SELECTED_VIEW_DELETED;
                return objStatus;
            }
            
            Sync_Master__c objSyncMaster = new Sync_Master__c();
            if(Schema.sObjectType.Sync_Master__c.fields.Group_Id__c.isCreateable()){
                objSyncMaster.Group_Id__c = objSync.Group_Id__c;
            }
            if(Schema.sObjectType.Sync_Master__c.fields.Total_Memerbs_Count__c.isCreateable()){
                objSyncMaster.Total_Memerbs_Count__c = totalMembers;
            }
            if(Schema.sObjectType.Sync_Master__c.fields.Track_Members_When_Sync_Started__c.isCreateable()){
                    objSyncMaster.Track_Members_When_Sync_Started__c = objInwiseUtil.objInwiseSetting.Track_Logs__c;
                }
            if(Schema.sObjectType.Sync_Master__c.fields.Sync__c.isCreateable()){
                objSyncMaster.Sync__c = objSync.Id;
            }
            if(Schema.SObjectType.Sync_Master__c.isCreateable()){
                insert objSyncMaster;
            }
            
            if(!Test.isRunningTest()){
                if(objSync.Is_Created_By_View__c){
                    if(!isViewDeleted){//don't do anything if view deleted
                        if(!String.isEmpty(objSync.Contact_View__c)){
                            BatchSyncMemberToInwiseView objBatchSyncMemberToInwiseView = new BatchSyncMemberToInwiseView();
                            objBatchSyncMemberToInwiseView.init(objSyncMaster.Id, objSync.Id, false, true, objSync.Contact_View__c,true);
                            Database.executeBatch(objBatchSyncMemberToInwiseView,batchSize);
                        }
                        if(!String.isEmpty(objSync.Lead_View__c)){
                            BatchSyncMemberToInwiseView objBatchSyncMemberToInwiseView2 = new BatchSyncMemberToInwiseView();
                            objBatchSyncMemberToInwiseView2.init(objSyncMaster.Id, objSync.Id, false, false, objSync.Lead_View__c,true);
                            Database.executeBatch(objBatchSyncMemberToInwiseView2,batchSize);
                        }  
                    }
                }else if(objSync.Is_Created_By_Report__c){
                    if(!String.isEmpty(objSync.Contact_Report__c)){
                        BatchSyncMemberToInwiseReports objBatchSyncMemberToInwiseReport = new BatchSyncMemberToInwiseReports();
                        objBatchSyncMemberToInwiseReport.init(objSyncMaster.Id, objSync.Id, false, true, objSync.Contact_Report__c,true);
                        Database.executeBatch(objBatchSyncMemberToInwiseReport,batchSize);
                    }
                    if(!String.isEmpty(objSync.Lead_Report__c)){
                        BatchSyncMemberToInwiseReports objBatchSyncMemberToInwiseReport = new BatchSyncMemberToInwiseReports();
                        objBatchSyncMemberToInwiseReport.init(objSyncMaster.Id, objSync.Id, false, false, objSync.Lead_Report__c,true);
                        Database.executeBatch(objBatchSyncMemberToInwiseReport,batchSize);
                    }
                }else{
                    if(!String.isEmpty(objSync.Contacts_SOQL__c)){
                        BatchSyncMemberToInwise objBatchSyncMemberToInwise = new BatchSyncMemberToInwise();
                        objBatchSyncMemberToInwise.init(objSyncMaster.Id, objSync.Id, false, true, objSync.Contacts_SOQL__c,true);
                        Database.executeBatch(objBatchSyncMemberToInwise,batchSize);
                    }
                    if(!String.isEmpty(objSync.Leads_SOQL__c)){
                        BatchSyncMemberToInwise objBatchSyncMemberToInwise2 = new BatchSyncMemberToInwise();
                        objBatchSyncMemberToInwise2.init(objSyncMaster.Id, objSync.Id, false, false, objSync.Leads_SOQL__c,true);
                        Database.executeBatch(objBatchSyncMemberToInwise2,batchSize);
                    }
                }
            }
            objStatus.isSuccess = true;
            objStatus.msg = inwiseConstants.GENERIC_SUCCESS;
        }catch(Exception ex){
            objStatus.isSuccess = false;
            objStatus.msg = ex.getMessage();
        }
            
        return objStatus; 
    }

    public static Boolean doCheckIfViewDeleted(List<SelectOption> listOfAvailableView, Id selectedviewid){
        Boolean isDeleted = true;
        if(!listOfAvailableView.isEmpty()){
            for(SelectOption so : listOfAvailableView){
                if(so.getValue() == selectedviewid){
                    isDeleted = false;
                    break;
                }
            }
        }
        return isDeleted;
    }

    public static void insertSyncHistory(String request,String response,  Sync__c objSync){
        if(Schema.sObjectType.Sync_History__c.isCreateable()){
            Sync_History__c objSyncHistory = new Sync_History__c();
            if(Schema.sObjectType.Sync_History__c.fields.Sync__c.isCreateable()){
                objSyncHistory.Sync__c = objSync.Id;
            }     
            if(Schema.sObjectType.Sync_History__c.fields.Request__c.isCreateable()){
                objSyncHistory.Request__c =request; //  'Missing login information to execute batch';
            }   
            if(Schema.sObjectType.Sync_History__c.fields.Response__c.isCreateable()){
                objSyncHistory.Response__c = response;
            }      
            if(Schema.sObjectType.Sync_History__c.fields.Run_By__c.isCreateable()){
                objSyncHistory.Run_By__c = UserInfo.getUserId();
            }    
            if(Schema.sObjectType.Sync_History__c.fields.Run_On__c.isCreateable()){
                objSyncHistory.Run_On__c = datetime.now();
            }    
            if(Schema.sObjectType.Sync_History__c.fields.JobId__c.isCreateable()){
                objSyncHistory.JobId__c = objSync.Last_JobId__c;
            }    
            if(Schema.sObjectType.Sync_History__c.fields.JobName__c.isCreateable()){
                objSyncHistory.JobName__c = objSync.Last_JobName__c;
            }    
            insert objSyncHistory;
        }     
    }
}