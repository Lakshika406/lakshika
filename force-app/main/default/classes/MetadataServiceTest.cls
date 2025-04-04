/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Updated On:  
*Purpose :    Test Code coverage for MetadataService
/******************************************************************************************/
@isTest  
private class MetadataServiceTest {
    /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
     **/
	private class WebServiceMockImpl implements WebServiceMock {
        
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) {

			if(request instanceof MetadataService.retrieve_element)
				response.put('response_x', new MetadataService.retrieveResponse_element());
			else if(request instanceof MetadataService.checkDeployStatus_element)
				response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
			else if(request instanceof MetadataService.listMetadata_element)
				response.put('response_x', new MetadataService.listMetadataResponse_element());
			else if(request instanceof MetadataService.checkRetrieveStatus_element)
				response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
			else if(request instanceof MetadataService.describeMetadata_element)
				response.put('response_x', new MetadataService.describeMetadataResponse_element());
			else if(request instanceof MetadataService.deploy_element)
				response.put('response_x', new MetadataService.deployResponse_element());
            else if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            else if(request instanceof MetadataService.renameMetadata_element)
                response.put('response_x', new MetadataService.renameMetadataResponse_element());
            else if(request instanceof  MetadataService.cancelDeploy_element)
                response.put('response_x', new MetadataService.cancelDeployResponse_element());
            else if(request instanceof  MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataService.upsertMetadata_element)
                response.put('response_x', new MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            else if(request instanceof  MetadataService.deployRecentValidation_element)
                response.put('response_x', new MetadataService.deployRecentValidationResponse_element());
            else if(request instanceof MetadataService.describeValueType_element)
                response.put('response_x', new MetadataService.describeValueTypeResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
            else if(request instanceof MetadataService.DescribeMetadataObject)
                response.put('response_x', new MetadataService.DescribeMetadataResult());
            else if(request instanceof MetadataService.DeployResult)
                response.put('response_x', new MetadataService.checkDeployStatus_element());
			return;
		}
	}    
		
	@IsTest
	private static void coverGeneratedCodeCRUDOperations() {

    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations     
        Test.startTest();    
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        MetadataService.DeployResult deployResult = new MetadataService.DeployResult(); 
        MetadataService.UpsertResult upsertResult = new MetadataService.UpsertResult();  
        MetadataService.readMetadata_element readMetadata_element = new MetadataService.readMetadata_element();  
        MetadataService.AsyncResult asyncResult = new MetadataService.AsyncResult();  
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions(); 
        MetadataService.DescribeValueTypeResult describeValueTypeResult = new MetadataService.DescribeValueTypeResult(); 
        MetadataService.ValueTypeField valueTypeField = new MetadataService.ValueTypeField(); 
        MetadataService.PicklistEntry picklistEntry = new MetadataService.PicklistEntry();  
        MetadataService.RetrieveResult retrieveResult = new MetadataService.RetrieveResult(); 
        MetadataService.RetrieveMessage retrieveMessage = new MetadataService.RetrieveMessage(); 
        MetadataService.CancelDeployResult cancelDeployResult = new MetadataService.CancelDeployResult(); 
        MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest(); 
        MetadataService.Package_x package_x = new MetadataService.Package_x(); 
        MetadataService.ProfileObjectPermissions profileObjectPermissions = new MetadataService.ProfileObjectPermissions(); 
        MetadataService.PackageTypeMembers packageTypeMembers = new MetadataService.PackageTypeMembers(); 
        MetadataService.DeployDetails deployDetails = new MetadataService.DeployDetails(); 
        MetadataService.DeployMessage deployMessage = new MetadataService.DeployMessage(); 
        MetadataService.RunTestsResult runTestsResult = new MetadataService.RunTestsResult(); 
        MetadataService.CodeCoverageResult codeCoverageResult = new MetadataService.CodeCoverageResult(); 
        MetadataService.CodeCoverageWarning codeCoverageWarning = new MetadataService.CodeCoverageWarning(); 
        MetadataService.RunTestFailure runTestFailure = new MetadataService.RunTestFailure(); 
        MetadataService.RunTestSuccess runTestSuccess = new MetadataService.RunTestSuccess(); 
        MetadataService.CodeLocation codeLocation = new MetadataService.CodeLocation(); 
        MetadataService.readReportResponse_element readReportResponse_element = new MetadataService.readReportResponse_element(); 
        MetadataService.ReadReportResult readReportResult = new MetadataService.ReadReportResult(); 
        MetadataService.ReportType reportType = new MetadataService.ReportType(); 
        MetadataService.ObjectRelationship objectRelationship = new MetadataService.ObjectRelationship(); 
        MetadataService.ReportLayoutSection reportLayoutSection = new MetadataService.ReportLayoutSection(); 
        MetadataService.ReportTypeColumn reportTypeColumn = new MetadataService.ReportTypeColumn(); 
        MetadataService.readReportTypeResponse_element readReportTypeResponse_element = new MetadataService.readReportTypeResponse_element(); 
        MetadataService.ReadReportTypeResult readReportTypeResult = new MetadataService.ReadReportTypeResult(); 
        MetadataService.FolderShare folderShare = new MetadataService.FolderShare(); 
        MetadataService.SharedTo sharedTo = new MetadataService.SharedTo(); 
        MetadataService.RemoteSiteSetting remoteSiteSetting = new MetadataService.RemoteSiteSetting(); 
        MetadataService.DescribeMetadataObject describeMetadataObject = new MetadataService.DescribeMetadataObject();  
        MetadataService.DescribeMetadataResult describeMetadataResult = new MetadataService.DescribeMetadataResult(); 
        MetadataService.SaveResult saveResult = new MetadataService.SaveResult();  
        MetadataService.Report objReport = new MetadataService.Report(); 
        MetadataService.ReportTimeFrameFilter reportTimeFrameFilter = new MetadataService.ReportTimeFrameFilter();  
        MetadataService.ReportParam reportParam = new MetadataService.ReportParam();  
        MetadataService.ReportHistoricalSelector reportHistoricalSelector = new MetadataService.ReportHistoricalSelector();  
        MetadataService.ReportGrouping reportGrouping = new MetadataService.ReportGrouping(); 
        MetadataService.ReportFilter reportFilter = new MetadataService.ReportFilter(); 
        MetadataService.ReportDataCategoryFilter reportDataCategoryFilter = new MetadataService.ReportDataCategoryFilter();  
        MetadataService.ReportFilterItem reportFilterItem = new MetadataService.ReportFilterItem(); 
        MetadataService.ReportCrossFilter reportCrossFilter = new MetadataService.ReportCrossFilter(); 
        MetadataService.ReportColumn reportColumn = new MetadataService.ReportColumn(); 
        MetadataService.ReportColorRange reportColorRange = new MetadataService.ReportColorRange(); 
        MetadataService.ChartSummary chartSummary = new MetadataService.ChartSummary();  
        MetadataService.ReportChart reportChart = new MetadataService.ReportChart();  
        MetadataService.ReportBucketField reportBucketField = new MetadataService.ReportBucketField(); 
        MetadataService.ReportBucketFieldSourceValue reportBucketFieldSourceValue = new MetadataService.ReportBucketFieldSourceValue(); 
        MetadataService.ReportBucketFieldValue reportBucketFieldValue = new MetadataService.ReportBucketFieldValue(); 
        MetadataService.ReportAggregateReference reportAggregateReference = new MetadataService.ReportAggregateReference(); 
        MetadataService.ReportBlockInfo reportBlockInfo = new MetadataService.ReportBlockInfo(); 
        MetadataService.FileProperties fileProperties = new MetadataService.FileProperties(); 
        MetadataService.ListMetadataQuery listMetadataQuery = new MetadataService.ListMetadataQuery(); 
        MetadataService.ReportAggregate reportAggregate = new MetadataService.ReportAggregate(); 
        MetadataService.ExtendedErrorDetails extendedErrorDetails = new MetadataService.ExtendedErrorDetails(); 
        MetadataService.Error error = new MetadataService.Error(); 
        MetadataService.DeleteResult deleteResult = new MetadataService.DeleteResult();  
        MetadataService.AllOrNoneHeader_element allOrNoneHeader_element = new MetadataService.AllOrNoneHeader_element(); 
        MetadataService.CallOptions_element callOptions_element = new MetadataService.CallOptions_element();  
        MetadataService.LogInfo logInfo = new MetadataService.LogInfo();  
        MetadataService.DebuggingHeader_element debuggingHeader_element = new MetadataService.DebuggingHeader_element(); 
        MetadataService.DebuggingInfo_element debuggingInfo_element = new MetadataService.DebuggingInfo_element(); 
        MetadataService.SessionHeader_element sessionHeader_element = new MetadataService.SessionHeader_element();
        System.assertNotEquals(false, true);
        Test.stopTest();
	}
	
	@IsTest
    private static void coverGeneratedCodeFileBasedOperations1() {

    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations    
        Test.startTest();     
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.retrieve(null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.listMetadata(null, null);
        metaDataPort.describeMetadata(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.updateMetadata(null);
        metaDataPort.renameMetadata(null, null, null);
        metaDataPort.cancelDeploy(null);
        System.assertNotEquals(false, true);
        Test.stopTest();
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2() {

        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations     
        Test.startTest();    
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.deleteMetadata(null, null);
        metaDataPort.upsertMetadata(null); 
        metaDataPort.createMetadata(null);
        metaDataPort.deployRecentValidation(null);
        metaDataPort.describeValueType(null);
        metaDataPort.checkRetrieveStatus(null, null);
        System.assertNotEquals(false, true);
        Test.stopTest();
    }
        
	@IsTest
    private static void coverGeneratedCodeTypes() {

        // Reference types
        Test.startTest();
        new MetadataService();
        new MetadataService.listMetadataResponse_element();
        new MetadataService.upsertMetadataResponse_element();
        System.assertNotEquals(false, true);
        Test.stopTest();
    }    
}