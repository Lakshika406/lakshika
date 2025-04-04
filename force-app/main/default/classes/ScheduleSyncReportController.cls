/*
*Created By:  Kapil Goutam
*Created On: June 10, 2021
*Purpose :    will provide report based sync creation
================================================================
Modified On   Version   Modified By                Purpose
================================================================
20/06/2021    1.1.0     NLINEAXIS(Kapil Goutam)     Modified:- added search functionality for reports doSearchReports, checkReports method added.
06/28/2021    1.1.1     NLINEAXIS(Kapil Goutam)     Modified:- Added system admin should be able to see all options (Show all account picklist value for system admin)
08/23/2021    1.1.2     NLINEAXIS(S. Vaishnav)      Modified:- Commented iTotalCount1 variable
08/23/2021    1.1.3     NLINEAXIS(S. Vaishnav)      Modified:- Get report data code modified in nextStep method. Now we can get data more than 2000 records
10/21/2021    1.1.4     NLINEAXIS(S. Vaishnav)      Modified:- Code indentation and optimization
10/22/2021    1.1.5     NLINEAXIS(S. Vaishnav)      Modified:- Fixed issue 'System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out'
11/09/2021    1.1.6     NLINEAXIS(S. Vaishnav)      Modified:- Fixed issue "this report is not related the contact"
11/19/2021    1.1.7     NLINEAXIS(S. Vaishnav)      Modified:- Fixed issue report field drop down list is empty
11/26/2021    1.1.8     NLINEAXIS(S. Vaishnav)      Modified:- Fixed record filter issue in report describe
06/20/2024    1.1.9     NLINEAXIS(Kapil Goutam)     Modified:- Added changes for security check (added method encodeForHTML)
*/
public with sharing class ScheduleSyncReportController {

    public inwiseScheduleSyncController.WrapperSync objWrapperSync  {get;set;} 
    InwiseUtil objInwiseUtil                                        {get;set;}
    public List<SelectOption> listOfSelectOptionGroups              {get;set;}
    public List<SelectOption> listOfSelectOptionAccounts            {get;set;}
    public Map<String,String> mapOfGroup                            {get;set;}//id is a string here not sure about the length
    public inwiseLtngConstants objinwiseLtngConstants               {get;set;}
    public String strGroupName                                      {get;set;}
    public Map<Id, Account__c> mapOfAccounts                        {get;set;}
    public List<SelectOption> listOfReport                          {get;set;}
    public String selectedReportObjType                             {get;set;}
    public List<SelectOption> listOfAvailableReport                 {get;set;}
    public String selectedReport                                    {get;set;}
    public ApexPages.StandardSetController objStdSetControllerContact   {get;set;}
    public ApexPages.StandardSetController objStdSetControllerLead      {get;set;}
    public List<WrapperResult> listOfWrapperResult                      {get;set;}
    public Decimal iTotalCount                                          {get;set;}

    public String MSG_SYNC_CHECKBOX{get{
        return inwiseConstants.MSG_SYNC_CHECKBOX;
    }}

    public Boolean disabledOnEdit                                               {get;set;}
    public Boolean showReportList                                               {get;set;}
    public String strReportName                                                 {get;set;}
    public String reportSelected                                                {get;set;}  
    public List<SelectOption> reportOptions                                     {get;set;} 
    public List<Report> listOfReports                                           {get;set;} 
    public List<WrapperReport> listOfWrapperReport                              {get;set;}
    public List<wrapperClass> listOfWrapperClass                                {get;set;}
    public List<wrapperClassForReportLookup> listOfWrapperClassForReportLookup  {get;set;}
    public List<wrapperClass> listOfWrapperClass1                               {get;set;}
    public List<SelectOption> listOfSelectOptionFields_Contact                  {get;set;}
    public List<SelectOption> listOfSelectOptionFields_Report                   {get;set;}
    public List<SelectOption> listOfSelectOptionFields_Lead                     {get;set;}
    map<string,Mapping__c> objInvMapping                                        {get;set;}
    map<string,Report_Lookup_Mapping__c> objInvReportLookupMapping              {get;set;}
    public Account__c objInwiseAccount                                          {get;set;} 
    public inwiseUtil objInwiseUtil1                                            {get;set;}

    List<wrapperClass> listOfWrap;
    public Boolean notAnyDefaultAcc;
    public Map<String, String> mapOfReportColumn;
    public Map<String, String> mapOfReportAllColumn;
    public Map<String, List<Contact>> mapOfReportAllColumnAndRow;
    List<wrapperClassForReportLookup> listOfWrapClassForReportLookup;

    public ScheduleSyncReportController(ApexPages.StandardController stdConntroller) {

        disabledOnEdit = false;
        listOfWrap = new List<wrapperClass>();
        listOfWrapClassForReportLookup = new List<wrapperClassForReportLookup>();
        mapOfReportColumn = new Map<String, String>(); 
        mapOfReportAllColumn = new Map<String, String>();
        mapOfReportAllColumnAndRow = new Map<String, List<Contact>>();
        listOfWrapperClass = new List<wrapperClass>();
        listOfWrapperClassForReportLookup = new List<wrapperClassForReportLookup>();
        listOfWrapperClass1 = new List<wrapperClass>();
        listOfSelectOptionFields_Report = new List<SelectOption>();

        listOfSelectOptionFields_Lead = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_LEAD,inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL,true);
        listOfSelectOptionFields_Contact = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_CONTACT,inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL,true);
        
        if(ApexPages.currentPage().getParameters().get('sid') != NULL){
            objWrapperSync = new inwiseScheduleSyncController.WrapperSync(ApexPages.currentPage().getParameters().get('sid'));
            disabledOnEdit = true;
        }else{
            objWrapperSync = new inwiseScheduleSyncController.WrapperSync();
        }

        objinwiseLtngConstants = new inwiseLtngConstants();
        listOfSelectOptionGroups = new List<SelectOption>();
        listOfSelectOptionAccounts = new List<SelectOption>();
        mapOfGroup = new Map<String,String>();
        objWrapperSync.Step1 = true;
        objWrapperSync.currentStep = objWrapperSync.CONS_STEP1;
        objWrapperSync.Step2 = objWrapperSync.Step3 = false;
        objWrapperSync.isCanProceed = true;
        notAnyDefaultAcc = true;
        mapOfAccounts = new Map<Id, Account__c>([SELECT Id,Name,Default__c FROM Account__c WITH SECURITY_ENFORCED LIMIT 1000]);

        String userProfileName = [SELECT Name FROM profile WHERE Id =: userinfo.getProfileId() WITH SECURITY_ENFORCED].Name;
        List<Setting__mdt> customMetadataLi = [SELECT Id FROM Setting__mdt WHERE MasterLabel = 'System Admin Profile' AND Setting_Value__c =: userProfileName];
        
        Boolean isAdminUser = false;
        if(!customMetadataLi.isEmpty()){
            isAdminUser = true;
        }

        if(isAdminUser) {
            if(Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Name.isAccessible() ){
                for(Account__c acc : [SELECT Id, Name FROM Account__c ORDER BY Name ASC LIMIT 49999]){
                    listOfSelectOptionAccounts.add(new SelectOption(acc.Id,acc.Name));
                }
            }
            if(objWrapperSync.selectedAccount == NULL){
                List<Account__c> listOfAccLocal = [SELECT Id, Name, Default__c FROM Account__c WHERE Default__c = true WITH SECURITY_ENFORCED LIMIT 1];
                if(listOfAccLocal.size() > 0){
                    objWrapperSync.selectedAccount = listOfAccLocal[0].Id;
                } 
            }
        }else {
            List<Account_SalesforceUser_Mapping__c> listofAccountUsers = [SELECT Id, Account__c, User__c,Account__r.name,Account__r.Default__c FROM Account_SalesforceUser_Mapping__c where User__c =: UserInfo.getUserId() WITH SECURITY_ENFORCED] ;
            if(!listofAccountUsers.isEmpty()){
                for(Account_SalesforceUser_Mapping__c a:listofAccountUsers){
                    listOfSelectOptionAccounts.add(new SelectOption(a.Account__c, a.Account__r.name));
                    if(a.Account__r.Default__c && objWrapperSync.selectedAccount == NULL){
                        objWrapperSync.selectedAccount = a.Account__c;
                        notAnyDefaultAcc = false;
                    }
                }

                if(notAnyDefaultAcc & objWrapperSync.selectedAccount == NULL) {
                    objWrapperSync.selectedAccount = listofAccountUsers[0].Account__c;
                }
            }
        }

        listOfReport = new List<SelectOption>();
        listOfReport.add(new SelectOption('','--None--'));
        listOfReport.add(new SelectOption(inwiseConstants.SOBJECT_CONTACT,inwiseConstants.SOBJECT_CONTACT));
        listOfReport.add(new SelectOption(inwiseConstants.SOBJECT_LEAD,inwiseConstants.SOBJECT_LEAD));

        listOfAvailableReport = new List<SelectOption>();
        listOfAvailableReport.add(new SelectOption('','--Select Report--'));

        if(Schema.sObjectType.Contact.isAccessible() ){
            String query = 'SELECT Name FROM Contact LIMIT 1';
            objStdSetControllerContact = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        }

        if(Schema.sObjectType.Lead.isAccessible() ){
            String query = 'SELECT Name FROM Lead LIMIT 1';
            objStdSetControllerLead = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        }

        listOfWrapperResult = new List<WrapperResult>();
        if(objWrapperSync.objSync.Is_Created_By_Report__c){
            if(objWrapperSync.objSync.Contacts__c && objWrapperSync.objSync.Contact_Report__c != NULL){
                selectedReportObjType = InwiseConstants.SOBJECT_CONTACT;
                reportSelected = objWrapperSync.objSync.Contact_Report__c;
                
                List<Report> reportLst = [SELECT Id, OwnerId, FolderName, DeveloperName, Name FROM Report WHERE DeveloperName =: objWrapperSync.objSync.Contact_Report__c WITH SECURITY_ENFORCED];
                if(reportLst.size() > 0){
                    strReportName = reportLst[0].Name;
                    doSearchReports();
                }
            }else if(objWrapperSync.objSync.Leads__c && objWrapperSync.objSync.Lead_Report__c != NULL){
                selectedReportObjType = InwiseConstants.SOBJECT_LEAD;
                reportSelected = objWrapperSync.objSync.Lead_Report__c;

                List<Report> reportLst = [SELECT Id, OwnerId, FolderName, DeveloperName, Name FROM Report WHERE DeveloperName =: objWrapperSync.objSync.Lead_Report__c WITH SECURITY_ENFORCED];
                if(reportLst.size() > 0){
                    strReportName = reportLst[0].Name;
                    doSearchReports();
                }
            }
        }     
        objInwiseUtil1=new inwiseUtil(new Account__c(Id=objWrapperSync.selectedAccount));
        objInwiseAccount = new Account__c(); 
        objInwiseAccount.Id = objWrapperSync.selectedAccount;
    }

    public void init(){
        if(objWrapperSync.selectedAccount != NULL){
            getInwiseGroups(true, new List<Logs__c>());
        }   
    }

    public void checkReports(){

        Boolean isStandardReportType = true;
        String strFolderId;
        String strAddFolderName;
        String baseObjectForContact;
        String baseObjectForLead;
       
        reportSelected = ApexPages.currentPage().getParameters().get('reportDeveloperName');
        //System.debug('==reportSelected=='+reportSelected);

        if(!listOfReports.isEmpty()){
            for(Report report : listOfReports)  {
                if(report.DeveloperName  == reportSelected) {
                    strFolderId = (String) report.get('OwnerId');
                }   
            }

            if(String.isNotBlank(strFolderId) && String.valueOf(strFolderId).substring(0,3) == '00D'){
                strAddFolderName = 'unfiled$public/'+reportSelected;
            }else {
                List<Folder> listOfFolder = [SELECT Id, Name, DeveloperName FROM Folder WHERE Id =: strFolderId WITH SECURITY_ENFORCED];
                if(listOfFolder.size() > 0){
                    strAddFolderName = listOfFolder[0].DeveloperName + '/' + reportSelected;
                }
            }


            
            MetadataService.MetadataPort service = inwiseUtil.createMetadataService();

            if(service != null && service.SessionHeader != null && service.SessionHeader.sessionId != null){
                String[] reportNames = new String[]{};
                reportNames.add(strAddFolderName);
                Map<String, Set<String>> mapOfReportType = new Map<String, Set<String>>();
                List<String> listOfContact = new List<String>();
                List<String> listOfLead = new List<String>();
                Map<String,String> mapOfReports = new Map<String,String>();
                String[] reportTypeNames = new String[]{};
                if(!test.isRunningTest()){
                    
                    System.debug('reportNames=='+reportNames);
                    MetadataService.IReadResult res = service.readMetadata('Report', reportNames);

                    // check added "reportType.startsWith(" to check report type if we have custom object lookup on Contact or Lead
                    for(MetadataService.Metadata md : res.getRecords()) {
                        System.debug('md.md=='+md);
                        if(md instanceof MetadataService.Report) {
                            MetadataService.Report mdReport = (MetadataService.Report) md;
                            System.debug('mdReport.reportType=='+mdReport.reportType);
                            String reportType = mdReport.reportType;
                            System.debug('reportType=='+reportType);
                            if(reportType == 'ContactList' || reportType.startsWith('ContactList@Contact.') || reportType =='ContactAsset' || reportType.startsWith('ContactAsset@Contact.') || reportType == 'ContactAuditHistory' || reportType.startsWith('ContactAuditHistory@Contact.')){  
                                isStandardReportType =  false;
                                baseObjectForContact = 'Contact';
                            }else if(reportType == 'LeadList' || reportType.startsWith('LeadList@Lead.') || reportType =='OpportunityLead' || reportType.startsWith('OpportunityLead@Lead.') || reportType == 'LeadAuditHistory' || reportType.startsWith('LeadAuditHistory@Lead.')){
                                isStandardReportType =  false;
                                baseObjectForLead = 'Lead';
                            }
                            String[] arrTest = mdReport.reportType.split('__c');
                            reportTypeNames.add(arrTest[0]);
                            mapOfReports.put(mdReport.fullName, mdReport.name);
                        }
                    }
                }
                        
                
                if(isStandardReportType && !test.isRunningTest()){
                    MetadataService.IReadResult res1 = service.readMetadata('ReportType', reportTypeNames);
                    for(MetadataService.Metadata md: res1.getRecords()) {
                        if(md instanceof MetadataService.ReportType) {
                            MetadataService.ReportType mdReport = (MetadataService.ReportType) md;
                            if(selectedReportObjType == inwiseConstants.SOBJECT_CONTACT && mdReport.baseObject != inwiseConstants.SOBJECT_CONTACT){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'This report is not related to the contact'));
                            }
                            else if(selectedReportObjType == inwiseConstants.SOBJECT_LEAD && mdReport.baseObject != inwiseConstants.SOBJECT_LEAD){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'This report is not related to the Lead'));
                            }
                        }
                    }
                }
                else {
                    if(selectedReportObjType == inwiseConstants.SOBJECT_CONTACT && baseObjectForContact != inwiseConstants.SOBJECT_CONTACT){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'This report is not related to the contact'));
                    }
                    else if(selectedReportObjType == inwiseConstants.SOBJECT_LEAD && baseObjectForLead != inwiseConstants.SOBJECT_LEAD){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'This report is not related to the Lead'));
                    }
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please check the Salesforce Named Credential - Get SF Access Token Named.'));
            }
                
        }
    }

    public void doLoadReports(){

        reportOptions = new List<SelectOption>(); 
        listOfWrapperReport = new List<WrapperReport>();
        listOfReports = new List<Report>();
        strReportName = '';
        listOfWrapperClass = new List<wrapperClass>();
        listOfWrapperClassForReportLookup = new List<wrapperClassForReportLookup>();
        listOfWrap = new List<wrapperClass>();
        listOfWrapClassForReportLookup = new List<wrapperClassForReportLookup>();
        mapOfReportColumn = new Map<String, String>(); 
        mapOfReportAllColumn = new Map<String, String>();
        mapOfReportAllColumnAndRow = new Map<String, List<Contact>>();
        listOfReports.clear();
        reportOptions.clear();
        listOfWrapperClass.clear();
        listOfWrapperClassForReportLookup.clear();
        listOfWrap.clear();
        listOfWrapClassForReportLookup.clear();
    }

    public void doSearchReports(){

        Integer count = 0;
        showReportList = false;
        reportOptions = new List<SelectOption>(); 
        listOfReports = new List<Report>();
        listOfWrapperReport = new List<WrapperReport>();
        mapOfReportColumn = new Map<String, String>(); 
        mapOfReportAllColumn = new Map<String, String>();
        mapOfReportAllColumnAndRow = new Map<String, List<Contact>>();

        if(strReportName != ''){
            String strSearch = '%'+strReportName+'%';
            if (Schema.sObjectType.Report.isAccessible() &&
                Schema.sObjectType.Report.fields.Id.isAccessible() &&
                Schema.sObjectType.Report.fields.OwnerId.isAccessible() &&
                Schema.sObjectType.Report.fields.FolderName.isAccessible() &&
                Schema.sObjectType.Report.fields.DeveloperName.isAccessible() &&
                Schema.sObjectType.Report.fields.Name.isAccessible()) {

                for(Report report : [SELECT Id, OwnerId, FolderName, DeveloperName, Name FROM Report WHERE Name LIKE :strSearch ORDER BY CreatedDate LIMIT 49999]){
                    if(String.valueOf(report.OwnerId).substring(0,3) != '005') {
                        count++;
                        if(count <= 10){
                            listOfReports.add(report);
                            listOfWrapperReport.add(new WrapperReport(count, report.Id, count+' - '+report.Name, report.DeveloperName));
                            reportOptions.add(new SelectOption(report.DeveloperName,report.Name));
                            showReportList = true; 
                        }
                        else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,inwiseConstants.INWISE_REPORT));
                        }
                    }
                }
            }
        }
    }

    public Integer doCreateGroup(String groupname,List<Logs__c> listOfLogs){

        Http http = new Http();
        HttpResponse res;
        Integer grpId = 0;
        Boolean isSuccess = false;
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contactsGroups/externalAppGeneric?group_name=' + EncodingUtil.urlEncode(groupname, 'utf-8'); 
        
        HttpRequest req = objInwiseUtil.GetHTTPRequest('POST', 'application/json', endpoint); 
        req.setBody('');
        req.setTimeout(120000);
        req.setHeader('X-Api-Key',objInwiseUtil.inwiseAccountToken);
        
        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/contactsGroups/externalAppGeneric', 'ScheduleSyncViewController', 'doCreateGroup'));
            }else{
                String resBody = '{"group_id": "642084"}';   
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'text/xml');
            }

            if(!String.isEmpty(res.getBody())){
                if(res.getStatusCode() == 200){
                    SendToInwiseController.JSON2ApexGroupId objJSON2ApexGroupId = (SendToInwiseController.JSON2ApexGroupId)JSON.deserialize(res.getBody(), SendToInwiseController.JSON2ApexGroupId.class);  
                    grpId = Integer.valueOf(objJSON2ApexGroupId.group_id);
                }else{
                    String msg = res.getBody().replace('"','');
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error,msg));      
                }
            }
        }catch(Exception ex){
            //ErrorMsg = 'Exception! -' + ex.getMessage(); 
        }   
        return grpId;
    }

    public PageReference nextStep(){

        PageReference pr;
        List<Logs__c> listOfLogs = new List<Logs__c>();

        if(String.isEmpty(objWrapperSync.selectedGroup) && String.isEmpty(strGroupName)){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error, InwiseConstants.MSG_SELECT_OR_CREATE_GROUP));      
            return pr;
        }
        if(selectedReportObjType == NULL || reportSelected == NULL){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,inwiseConstants.MSG_SELECT_REPORT));      
            return pr;                      
        }

        objWrapperSync.selectedGroupName = mapOfGroup.get(objWrapperSync.selectedGroup);

        try{
            if(objWrapperSync.currentStep == objWrapperSync.CONS_STEP1){
                if(!String.ISBLANK(objWrapperSync.objSync.Name)){
                    if(String.isEmpty(objWrapperSync.selectedGroup) && !String.isEmpty(strGroupName)){

                        Integer grpid = doCreateGroup(strGroupName, listOfLogs);

                        if(grpid != 0){
                            objWrapperSync.selectedGroup = String.valueOf(grpid);
                            objWrapperSync.selectedGroupName = strGroupName;

                            // to reload groups in list box
                            if(objWrapperSync.selectedAccount != NULL){
                                getInwiseGroups(false, listOfLogs);
                            }
                            if(!mapOfGroup.isEmpty()){
                                objWrapperSync.isCanProceed = true;
                            }
                        }else{
                            if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                                insert listOfLogs;
                            }
                            return null;
                        }
                    }  

                    listOfWrapperResult = new List<WrapperResult>();
                    iTotalCount = 0;
                    Set<Id> allSelectedIds = new Set<Id>();
                    ApexPages.StandardSetController objStdSetController;

                    if(selectedReportObjType == inwiseConstants.SOBJECT_CONTACT){
                        objStdSetController = objStdSetControllerContact;
                    }else if(selectedReportObjType == inwiseConstants.SOBJECT_LEAD){
                        objStdSetController = objStdSetControllerLead;
                    }
                    
                    objStdSetController.first();
                    objStdSetController.setPageSize(1000);
                    iTotalCount = objStdSetController.getResultSize();
                    Boolean hasNext = iTotalCount > 0 ? true : false;

                    while(hasNext){
                        hasNext = objStdSetController.getHasNext();
                        objStdSetController.next();
                    }

                    List<Report> reportList = [SELECT Id,DeveloperName FROM Report WHERE DeveloperName =: reportSelected WITH SECURITY_ENFORCED];
                    if(!reportList.isEmpty()){

                        String columnName = '';
                        Integer idColumnIndexNumber = 0;
                        Boolean isIdColumnFound = false;

                        if(selectedReportObjType == inwiseConstants.SOBJECT_CONTACT){
                            columnName = 'CONTACT_ID';
                        }
                        else if(selectedReportObjType == inwiseConstants.SOBJECT_LEAD){
                            columnName = 'LEAD_ID';
                        }

                        // Describe selected report
                        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportList[0].Id);
                        Reports.ReportMetadata reportMd = describe.getReportMetadata();

                        for(String name : reportMd.getDetailColumns()){
                            if(name == columnName ){
                                isIdColumnFound = true;
                                break;
                            }
                            if(name == 'Contact.Id'){
                                columnName =  name;
                                isIdColumnFound = true;
                                break;
                            }
                            if(name == 'Lead.Id'){
                                columnName =  name;
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
                            Boolean isColumnAlreadyExecuted = false;

                            objWrapperSync.currentStep = objWrapperSync.CONS_STEP2;
                            objWrapperSync.Step2 = true;
                            objWrapperSync.Step1 = false;

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

                                if(!isColumnAlreadyExecuted){

                                    isColumnAlreadyExecuted = true;
                                    // Get detail columns from extended metadata
                                    Reports.ReportExtendedMetadata rmd = results.getReportExtendedMetadata();
                                    Map<String, Reports.DetailColumn> colMap = rmd.getDetailColumnInfo();

                                    for(String key : colMap.KeySet()){
                                        
                                        if(columnName == 'Contact.Id'){
                                            String str = key.replace('Contact.', '');
                                            if(str.contains('.')){
                                                mapOfReportColumn.put(Key, colMap.get(key).getLabel());
                                            }
                                        }else if(columnName == 'Lead.Id'){
                                            String str = key.replace('Lead.', '');
                                            if(str.contains('.')){
                                                mapOfReportColumn.put(Key, colMap.get(key).getLabel());
                                            }
                                        }else {
                                            if(Key.contains('.') || Key.startsWith('FK_')){
                                                mapOfReportColumn.put(Key, colMap.get(key).getLabel());
                                            }
                                        }
                                    }
                                }

                                if(!results.getAllData() || !isLastExecution){

                                    isLastExecution = results.getAllData() ? true : false;
                                    Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
                                    List<Reports.ReportDetailRow> listOfDetailRow = factDetails.getRows();

                                    for(Reports.ReportDetailRow row : listOfDetailRow){
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
                            listOfWrapClassForReportLookup = InitializeWrapperClass(mapOfReportColumn);
                            System.debug('listOfWrapClassForReportLookup '+listOfWrapClassForReportLookup);
                        }
                        else{
                            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Id column does not found in the selected report.')));      
                            return pr;
                        }
                    }

                    //Below if block moved down due to error 'System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out'
                    if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                        insert listOfLogs;
                    }

                    if(!allSelectedIds.isEmpty()){
                        iTotalCount = allSelectedIds.size();
                        if(selectedReportObjType == inwiseConstants.SOBJECT_CONTACT){ //  order by name ASC
                            if(Schema.sObjectType.Contact.isAccessible() ){
                                List<Contact> listOfContact = Database.query('Select Id,Name from Contact where Id IN:allSelectedIds LIMIT 10');
                                if(!listOfContact.isEmpty()){
                                    for(Contact c : listOfContact){
                                        listOfWrapperResult.add(new WrapperResult(c.Id, c.Name));
                                    }
                                }
                            }
                        }else if(selectedReportObjType == inwiseConstants.SOBJECT_LEAD){  // order by name ASC
                            if(Schema.sObjectType.Lead.isAccessible() ){
                                List<Lead> listOfLead = Database.query('Select Id,Name from Lead where Id IN:allSelectedIds  LIMIT 10');
                                if(!listOfLead.isEmpty()){
                                    for(Lead l : listOfLead){
                                        listOfWrapperResult.add(new WrapperResult(l.Id, l.Name));
                                    }
                                }
                            }
                        }
                    }
                }else {
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Required field Sync Name should not be Blank')));      
                    return pr;                      
                }
            }else if(objWrapperSync.currentStep == objWrapperSync.CONS_STEP2){
                if(selectedReportObjType == NULL || reportSelected == NULL){
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error,inwiseConstants.MSG_SELECT_REPORT));      
                    return pr;                      
                }
                if(Schema.sObjectType.Sync__c.fields.Group_Name__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Group_Name__c.isUpdateable()){
                    objWrapperSync.objSync.Group_Name__c = objWrapperSync.selectedGroupName;
                }
                if(Schema.sObjectType.Sync__c.fields.Account__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Account__c.isUpdateable()){
                    objWrapperSync.objSync.Account__c = objWrapperSync.selectedAccount;
                }
                if(Schema.sObjectType.Sync__c.fields.Group_Id__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Group_Id__c.isUpdateable()){
                    objWrapperSync.objSync.Group_Id__c = Integer.valueOf(objWrapperSync.selectedGroup);
                }
                if(Schema.sObjectType.Sync__c.fields.Is_Created_By_Report__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Is_Created_By_Report__c.isUpdateable()){
                    objWrapperSync.objSync.Is_Created_By_Report__c = true;
                }
                if(selectedReportObjType == inwiseConstants.SOBJECT_CONTACT){
                    if(Schema.sObjectType.Sync__c.fields.Contact_Report__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Contact_Report__c.isUpdateable()){
                        objWrapperSync.objSync.Contact_Report__c = reportSelected;
                        if(Schema.sObjectType.Sync__c.fields.Lead_Report__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Lead_Report__c.isUpdateable()){
                            objWrapperSync.objSync.Lead_Report__c = null;
                        }
                    }
                    if(Schema.sObjectType.Sync__c.fields.Contacts__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Contacts__c.isUpdateable()){
                        objWrapperSync.objSync.Contacts__c = true;
                        if(Schema.sObjectType.Sync__c.fields.Leads__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Leads__c.isUpdateable()){
                            objWrapperSync.objSync.Leads__c = false;
                        } 
                    }
                }else if(selectedReportObjType == inwiseConstants.SOBJECT_LEAD){
                    if(Schema.sObjectType.Sync__c.fields.Lead_Report__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Lead_Report__c.isUpdateable()){
                        objWrapperSync.objSync.Lead_Report__c = reportSelected;
                        if(Schema.sObjectType.Sync__c.fields.Contact_Report__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Contact_Report__c.isUpdateable()){
                            objWrapperSync.objSync.Contact_Report__c = null;
                        }
                    }
                    if(Schema.sObjectType.Sync__c.fields.Leads__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Leads__c.isUpdateable()){
                        objWrapperSync.objSync.Leads__c = true;
                        if(Schema.sObjectType.Sync__c.fields.Contacts__c.isCreateable() && Schema.sObjectType.Sync__c.fields.Contacts__c.isUpdateable()){
                            objWrapperSync.objSync.Contacts__c = false;
                        }
                    }
                }
                if(Schema.sObjectType.Sync__c.isUpdateable() && Schema.sObjectType.Sync__c.isCreateable()){
                    upsert objWrapperSync.objSync;
                }

                if(listOfWrapClassForReportLookup.size() > 0){
                    List<Mapping__c> listOfInwiseMapping = new List<Mapping__c>();
                    Map<String, Report_Lookup_Mapping__c> mapOfReportLookupMapping = new Map<String, Report_Lookup_Mapping__c>();
                
                    for(wrapperClassForReportLookup wc : listOfWrapClassForReportLookup){
                        if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.Sync__c.isCreateable() && Schema.sObjectType.Report_Lookup_Mapping__c.fields.inwise_FieldId__c.isCreateable() 
                            && Schema.sObjectType.Report_Lookup_Mapping__c.fields.inwise_FieldId__c.isUpdateable() && Schema.sObjectType.Report_Lookup_Mapping__c.isCreateable() 
                            && Schema.sObjectType.Report_Lookup_Mapping__c.isUpdateable()){
                            if(wc.ContactInfo.Salesforce_Field__c != null && wc.ContactInfo.Sync__c == null){
                                if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.Sync__c.isAccessible() && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Sync__c.isCreateable() && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Sync__c.isUpdateable()){
                                    wc.ContactInfo.Sync__c = objWrapperSync.objSync.Id;
                                }
                                if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.inwise_FieldId__c.isAccessible()){
                                    mapOfReportLookupMapping.put(wc.ContactInfo.inwise_FieldId__c, wc.ContactInfo);
                                }
                            }else if(wc.LeadInfo.Salesforce_Field__c != null && wc.LeadInfo.Sync__c == null){
                                if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.Sync__c.isAccessible() && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Sync__c.isCreateable() && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Sync__c.isUpdateable()){
                                    wc.LeadInfo.Sync__c = objWrapperSync.objSync.Id;
                                }
                                if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.inwise_FieldId__c.isAccessible()){
                                    mapOfReportLookupMapping.put(wc.LeadInfo.inwise_FieldId__c, wc.LeadInfo);
                                }
                            }
                            if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.Sync__c.isAccessible()){
                                if(wc.ContactInfo.Sync__c != null){
                                    if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.inwise_FieldId__c.isAccessible()){
                                    	mapOfReportLookupMapping.put(wc.ContactInfo.inwise_FieldId__c, wc.ContactInfo);
                                    }
                                }
                                else if( wc.LeadInfo.Sync__c != null){
                                    if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.inwise_FieldId__c.isAccessible()){
                                    	mapOfReportLookupMapping.put(wc.LeadInfo.inwise_FieldId__c, wc.LeadInfo);
                                    }
                                }
                            }
                        }
                    }

                    if(mapOfReportLookupMapping.values().size()>0){
                        if(Schema.sObjectType.Report_Lookup_Mapping__c.isAccessible() && (Schema.sObjectType.Report_Lookup_Mapping__c.isUpdateable() && Schema.sObjectType.Report_Lookup_Mapping__c.isCreateable())){
                            upsert mapOfReportLookupMapping.values();
                        }
                    }
                }
            
                pr = Page.inwiseHome;
                pr.setRedirect(true);
            }
        }
        catch(Exception ex){
            Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(ex.getMessage(), 'ScheduleSyncReportController', 'nextStep');
            if(errorLog != null){
                insert errorLog;
            }
            return null;
        }
        return pr;
    } 
  
    public void getInwiseGroups(Boolean isCalledFromInit, List<Logs__c> listOfLogs){

        mapOfGroup = new Map<String,String>();
        listOfSelectOptionGroups = new List<SelectOption>();
        listOfSelectOptionGroups.add(new SelectOption('','--None--'));
        
        if(objWrapperSync.selectedAccount != NULL){
            objInwiseUtil = new InwiseUtil(new Account__c(Id=objWrapperSync.selectedAccount));
        }
        if(!objInwiseUtil.CheckIfCredentialExists()){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,InwiseConstants.INWISE_CREDENTIAL_MISSING));      
            return;
        } 
        if(!objInwiseUtil.CheckIfMappingExists()){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,InwiseConstants.INWISE_ACCOUNT_MAPPING_MISSING));      
            return;
        }

        Http http = new Http();
        HttpResponse res;
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contactsGroups?create_date_from=2010-01-01&group_type=generic_push&order_by=id%20desc'; 
        HttpRequest req = objInwiseUtil.GetHTTPRequest('GET', 'application/json', endpoint);
        req.setTimeout(120000);

        if(objWrapperSync.selectedAccount != NULL && mapOfAccounts != NULL && mapOfAccounts.get(objWrapperSync.selectedAccount) != NULL ){
            //req.setHeader('X-Api-Key', inwiseUtil.decryptToken(mapOfAccounts.get(objWrapperSync.selectedAccount).Token__c));    
            String tokenFromSetting = inwiseUtil.getTokenToAccId(mapOfAccounts.get(objWrapperSync.selectedAccount).Id);
            req.setHeader('X-Api-Key',tokenFromSetting);
        }

        try{
            if(!Test.isRunningTest()){
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contactsGroups','ScheduleSyncViewController','getInwiseGroups'));
            }else{
                String resBody = ' [   {     "id": "653415",     "name": "boaz20171020-9",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653414",     "name": "boaz20171020-8",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653346",     "name": "Campaign11Oct-32",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653345",     "name": "Campaign11Oct-31",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653344",     "name": "Campaign11Oct-30",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653343",     "name": "Campaign11Oct-29",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653342",     "name": "boaz20171020-7",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653341",     "name": "boaz20171020-6",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653338",     "name": "boaz20171020-5",     "create_date": "2017-10-22",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653337",     "name": "boaz20171020-4",     "create_date": "2017-10-21",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653336",     "name": "boaz20171020-3",     "create_date": "2017-10-21",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653335",     "name": "Campaign11Oct-28",     "create_date": "2017-10-21",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653249",     "name": "boaz20171020-2",     "create_date": "2017-10-20",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "653229",     "name": "boaz20171020",     "create_date": "2017-10-20",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652451",     "name": "Campaign11Oct-27",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652423",     "name": "Campaign11Oct-26",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652414",     "name": "Campaign11Oct-25",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652409",     "name": "Campaign11Oct-24",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652407",     "name": "Campaign11Oct-23",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652401",     "name": "Campaign11Oct-22",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652400",     "name": "Campaign11Oct-21",     "create_date": "2017-10-16",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652074",     "name": "ManyMembers29",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652073",     "name": "boaz test 9",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652048",     "name": "boaz test 8",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652047",     "name": "boaz test 7",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652046",     "name": "Campaign11Oct-20",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652045",     "name": "boaz test 6",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652044",     "name": "boaz test 5",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652043",     "name": "ManyMembers28",     "create_date": "2017-10-13",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652018",     "name": "boaz test 4",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652011",     "name": "ManyMembers27",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652010",     "name": "Campaign11Oct-19",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652009",     "name": "ManyMembers25",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652008",     "name": "ManyMembers24",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652007",     "name": "ManyMembers23",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652006",     "name": "Campaign11Oct-18",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652005",     "name": "Campaign11Oct-17",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "652004",     "name": "Campaign11Oct-16",     "create_date": "2017-10-12",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651960",     "name": "Campaign11Oct-15",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651954",     "name": "Campaign11Oct-13",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651949",     "name": "Campaign11Oct-12",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651941",     "name": "Campaign11Oct-11",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651928",     "name": "Campaign11Oct-10",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651927",     "name": "Campaign11Oct-8",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651926",     "name": "Campaign11Oct-7",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651920",     "name": "Campaign11Oct-6",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651919",     "name": "Campaign11Oct-4",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651918",     "name": "Campaign11Oct-3",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651914",     "name": "Campaign11Oct-2",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651913",     "name": "Campaign11Oct-1",     "create_date": "2017-10-11",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651870",     "name": "boaz test 3",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651854",     "name": "ManyMembers22",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651853",     "name": "ManyMembers21",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651852",     "name": "ManyMembers20",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651849",     "name": "ManyMembers19",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651848",     "name": "ManyMembers18",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651847",     "name": "ManyMembers17",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651846",     "name": "ManyMembers16",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651844",     "name": "ManyMembers15",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651833",     "name": "ManyMembers14",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651832",     "name": "ManyMembers13",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651831",     "name": "ManyMembers12",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651830",     "name": "ManyMembers11",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651829",     "name": "ManyMembers10",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651824",     "name": "ManyMembers9",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651822",     "name": "ManyMembers8",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651820",     "name": "ManyMembers7",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651819",     "name": "ManyMembers6",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651818",     "name": "ManyMembers5",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651817",     "name": "ManyMembers4",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "651773",     "name": "ManyMembers3",     "create_date": "2017-10-10",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "646274",     "name": "test campaign29Aug32",     "create_date": "2017-08-29",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "646271",     "name": "test campaign29Aug2",     "create_date": "2017-08-29",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "646270",     "name": "test campaign29Aug",     "create_date": "2017-08-29",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "646264",     "name": "test campaign29Aug3",     "create_date": "2017-08-29",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642838",     "name": "test campaign03Aug3",     "create_date": "2017-08-03",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642821",     "name": "test campaign03Aug2",     "create_date": "2017-08-02",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642820",     "name": "test campaign03Aug1",     "create_date": "2017-08-02",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642819",     "name": "test campaign03Aug",     "create_date": "2017-08-02",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642100",     "name": "test campaign 28th July",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642089",     "name": "test 43 newtest",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642084",     "name": "test 43 new",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642080",     "name": "Campaign28July11.14AM",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642075",     "name": "Campaign28July11.05AM",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642073",     "name": "Campaign28July10.46AM",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "642071",     "name": "Campaign28July10.28AM",     "create_date": "2017-07-28",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641996",     "name": "boaz20170727",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641961",     "name": "Campaign27 July04.50PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641959",     "name": "Campaign27 July04.43PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641952",     "name": "Campaign27 July02.28PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641947",     "name": "Campaign27 July02.20PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641946",     "name": "Campaign27 July02.15PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641933",     "name": "Campaign27 July02.10PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641910",     "name": "Campaign27 July10.52PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641909",     "name": "Campaign27 July10.50PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641908",     "name": "Campaign27 July10.40PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641899",     "name": "Campaign27 July10.39PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641898",     "name": "Campaign27 July10.35PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641892",     "name": "Campaign27 July10.33PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   },   {     "id": "641891",     "name": "Campaign27 July10.30PM",     "create_date": "2017-07-27",     "group_type": "generic_push",     "target_type": "group"   } ]';
                res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
            }

            if(res != NULL){
                if(res.getStatusCode() == 200){ 
                    List<inwiseScheduleSyncController.JSON2ApexGroupList> listOfGroupList = (List<inwiseScheduleSyncController.JSON2ApexGroupList>) System.JSON.deserialize(res.getBody(), List<inwiseScheduleSyncController.JSON2ApexGroupList>.class);
                    if(!listOfGroupList.isEmpty()){
                        for(inwiseScheduleSyncController.JSON2ApexGroupList l:listOfGroupList){
                            listOfSelectOptionGroups.add(new SelectOption(l.id,l.name));
                            mapOfGroup.put(l.id,l.name);
                        }
                    }
                }else{
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error, res.getBody()));      
                    return;
                } 
            }
        }catch(Exception ex){
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,ex.getMessage()));      
        }

        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty() && isCalledFromInit){
            insert listOfLogs;
        }       
    }

    public PageReference doPrevStep(){
        PageReference pr;
        objWrapperSync.currentStep = objWrapperSync.CONS_STEP1;
        objWrapperSync.Step2 = false;
        objWrapperSync.Step1 = true;
        return pr;
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

    public PageReference redirectToSyncWizard(){
        PageReference pr = Page.inwiseScheduleSync;
        pr.getParameters().put('retUrl', Page.inwiseHome.getUrl());
        pr.setRedirect(true);
        return pr;
    }

    public List<wrapperClassForReportLookup> InitializeWrapperClass(Map<String, String> mapOfReportColumn){

        List<Logs__c> listOfLogs = new List<Logs__c>();
        wrapperClassForReport obj = new wrapperClassForReport();
        listOfWrapperClassForReportLookup = new List<wrapperClassForReportLookup>();
        listOfSelectOptionFields_Report = getReportFields(mapOfReportColumn);
        System.debug('listOfSelectOptionFields_Report '+listOfSelectOptionFields_Report);

        if(objInwiseUtil1.Error_Messages.size() > 0){
            for(string msg:objInwiseUtil1.Error_Messages){
                apexpages.addmessage(new apexpages.message(apexpages.severity.info,msg));
                return null;
            }
        }
        LoadPreviousMappings();

        wrapperClassForReportLookup wc = null;
        for(SelectOption inwiseS : objInwiseUtil.GetInwiseFields(listOfLogs)){

            wc = new wrapperClassForReportLookup();
            for(SelectOption reports : listOfSelectOptionFields_Report){
                obj.reportFieldSelectOption = reports; 
            }

            obj.inwiseFieldSelectOption = inwiseS;
            wc.inwiseField = obj.inwiseFieldSelectOption.getlabel();
            wc.inwiseFieldId = obj.inwiseFieldSelectOption.getvalue();
            
            String contactKey=wc.inwiseFieldId + ':' + InwiseConstants.SOBJECT_CONTACT;
            String LeadKey=wc.inwiseFieldId + ':' + InwiseConstants.SOBJECT_LEAD;
            Report_Lookup_Mapping__c objMap = null;

            if(Schema.sObjectType.Mapping__c.isCreateable() && Schema.sObjectType.Mapping__c.isUpdateable()){
                if(InwiseConstants.SOBJECT_CONTACT == selectedReportObjType){
                    if(Report_Lookup_Mapping__c.sObjectType.getDescribe().isAccessible()){
                        if(objInvReportLookupMapping.containsKey(contactKey)){
                            objMap = objInvReportLookupMapping.get(contactKey);
                        }else{
                            objMap = CreateNewMappingInstance(wc, InwiseConstants.SOBJECT_CONTACT, listOfSelectOptionFields_Contact.get(0).getValue()); 
                        }
                        wc.ContactInfo=objMap;
                    }
                }
                
                objMap = null;
                if(InwiseConstants.SOBJECT_LEAD == selectedReportObjType) {
                    if(Report_Lookup_Mapping__c.sObjectType.getDescribe().isAccessible()){
                        if(objInvReportLookupMapping.containsKey(LeadKey)){
                            objMap = objInvReportLookupMapping.get(LeadKey);
                        }else{
                             objMap = CreateNewMappingInstance(wc,InwiseConstants.SOBJECT_LEAD,listOfSelectOptionFields_Lead.get(0).getValue());
                        }
                        wc.LeadInfo=objMap;
                    }
                }
            }       
            
            listOfWrapperClassForReportLookup.add(wc);
            System.debug('listOfWrapperClassForReportLookup '+listOfWrapperClassForReportLookup);
        }
       
        return listOfWrapperClassForReportLookup;          
    }

    private void LoadPreviousMappings(){
        objInvReportLookupMapping = new map<string,Report_Lookup_Mapping__c>();
        if(Schema.sObjectType.Report_Lookup_Mapping__c.isAccessible()){
            for(Report_Lookup_Mapping__c oMapping : [SELECT Id,name,Account__c,Inwise_Field__c, Object_Type__c, Salesforce_Field__c,Inwise_FieldId__c,Sync__c from Report_Lookup_Mapping__c
                                                        WHERE Account__c =: objInwiseAccount.Id AND Sync__c =: objWrapperSync.objSync.Id WITH SECURITY_ENFORCED]){
                String key = oMapping.Inwise_FieldId__c + ':' + oMapping.Object_Type__c;
                objInvReportLookupMapping.put(key,oMapping);
            }
        }        
    }

    private Report_Lookup_Mapping__c CreateNewMappingInstance(wrapperClassForReportLookup wc, String objectType, String salesforceField){

        Report_Lookup_Mapping__c mapping;
        if(Schema.sObjectType.Report_Lookup_Mapping__c.isAccessible() && Schema.sObjectType.Report_Lookup_Mapping__c.isUpdateable() && Schema.sObjectType.Report_Lookup_Mapping__c.isCreateable()){
            mapping = new Report_Lookup_Mapping__c();
            
            if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.Account__c.isAccessible()  && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Account__c.isCreateable() && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Account__c.isUpdateable()){
                mapping.Account__c = objInwiseAccount.Id;
            }
            if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.Inwise_Field__c.isAccessible()  && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Inwise_Field__c.isCreateable() && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Inwise_Field__c.isUpdateable()){
                mapping.Inwise_Field__c = wc.inwiseField;
            }
            if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.Inwise_FieldId__c.isAccessible()  && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Inwise_FieldId__c.isCreateable() && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Inwise_FieldId__c.isUpdateable()){
                mapping.Inwise_FieldId__c = wc.inwiseFieldId;
            }
            if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.Object_Type__c.isAccessible()  && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Object_Type__c.isCreateable() && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Object_Type__c.isUpdateable()){
                mapping.Object_Type__c = objectType;
            }
            if(Schema.sObjectType.Report_Lookup_Mapping__c.fields.Salesforce_Field__c.isAccessible() && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Salesforce_Field__c.isCreateable() && Schema.sObjectType.Report_Lookup_Mapping__c.fields.Salesforce_Field__c.isUpdateable()){
                mapping.Salesforce_Field__c = salesforceField;
            }
        }
        return mapping;     
    }

    public List<SelectOption> getReportFields(Map<String, String> mapOfReportColumn){
        List<SelectOption> listOfReportFields = new List<SelectOption>(); 
        listOfReportFields.Add(new SelectOption('', '--None--'));
        for(String key : mapOfReportColumn.KeySet()){
            listOfReportFields.Add(new SelectOption(Key, mapOfReportColumn.get(key)));
        } 
        return listOfReportFields;
    }

    public class wrapperClass{ 
        public String reportField       {get;set;}
        public String reportFieldId     {get;set;}
        public String inwiseField       {get;set;}
        public String inwiseFieldId     {get;set;}
        public Mapping__c ContactInfo   {get;set;}
        public Mapping__c LeadInfo      {get;set;}
        public Mapping__c reportInfo    {get;set;}
    }

    public class wrapperClassForReportLookup{ 
        public String reportField                   {get;set;}
        public String reportFieldId                 {get;set;}
        public String inwiseField                   {get;set;}
        public String inwiseFieldId                 {get;set;}
        public Report_Lookup_Mapping__c ContactInfo {get;set;}
        public Report_Lookup_Mapping__c LeadInfo    {get;set;}
        public Report_Lookup_Mapping__c reportInfo  {get;set;}
    }

    public class wrapperClassForReport{ 
        public SelectOption inwiseFieldSelectOption {get;set;}
        public SelectOption reportFieldSelectOption {get;set;}
    }

    public class WrapperResult{
        public String recordid      {get;set;}
        public String recordname    {get;set;}

        public WrapperResult(String recordid, String recordname){
            this.recordid = recordid;
            this.recordname = ScheduleSyncReportController.encodeForHTML(recordname);
        }
    }
    
    public static string encodeForHTML(String input) {
        if (input == null) {
            return null;
        }
        return input.replace('&', '&amp;')
            .replace('<', '&lt;')
            .replace('>', '&gt;')
            .replace('"', '&quot;')
            .replace('"', '&#x27;')
            .replace('/', '&#x2F;');
    }

    public class WrapperReport{
        public Integer reportSNO            {get;set;}
        public Id reportId                  {get;set;}
        public String reportName            {get;set;}
        public String reportDeveloperName   {get;set;}

        public WrapperReport(Integer reportSNO, Id reportId, String reportName, String reportDeveloperName){
            this.reportSNO = reportSNO;
            this.reportId = reportId;
            this.reportName = reportName;
            this.reportDeveloperName = reportDeveloperName;
        }
    }
}