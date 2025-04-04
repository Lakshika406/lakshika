/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :      
/******************************************************************************************/
global class WebServiceMockImpl implements WebServiceMock {

    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
        if(request instanceof MetadataService.listMetadata_element){

            MetadataService.listMetadataResponse_element responseElement = new MetadataService.listMetadataResponse_element();
            MetadataService.FileProperties objFileProperties = new MetadataService.FileProperties();
            List<MetadataService.FileProperties> listOfFileProperties = new List<MetadataService.FileProperties>();
            objFileProperties.fileName = 'reports/TestReports';
            objFileProperties.fullName = 'TestReports';
            objFileProperties.manageableState = 'unmanaged';
            objFileProperties.namespacePrefix = null;
            objFileProperties.type_x = 'ReportFolder';
            listOfFileProperties.add(objFileProperties);
            responseElement.result = listOfFileProperties;

            response.put('response_x', responseElement);
        }else if(request instanceof MetadataService.readMetadata_element){

            List<MetadataService.Report> listOdRep = new List<MetadataService.Report>();
            MetadataService.readReportResponse_element objReadReportResponse = new MetadataService.readReportResponse_element();
            MetadataService.Report objRep = new MetadataService.Report();
            objRep.type = 'Report';
            objRep.fullName = 'ReportTest'; 
            objRep.reportType = 'Test_Contact__c';
            listOdRep.add(objRep);

            MetadataService.ReadReportResult obj = new MetadataService.ReadReportResult();
            obj.records = listOdRep;

            objReadReportResponse.result = obj;
            response.put('response_x', objReadReportResponse);
        }
    }
}