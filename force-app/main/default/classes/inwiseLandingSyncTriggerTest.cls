/******************************************************************************************
*Created By	:  NlineAxis
*Created On	:  24 August 2022
*Purpose 	:  Test class of inwiseLandingSyncTriggerTest trigger
/******************************************************************************************
*Modified:   
================================================================
Modified On   Version   Modified By             Purpose
================================================================
08/24/2022    1.0.0  	Shyam Vaishnav     		Created

/******************************************************************************************/
@isTest
private class inwiseLandingSyncTriggerTest {
    
    static testMethod void unitTesting() {
        
        Account__c acc = inwiseTestDataFactory.GetInwiseAccount();
        acc.Default__c = true;
        insert acc;
        
        Landing_Sync__c sync = new Landing_Sync__c();
        sync.Leads__c = true;
        sync.Form_Type__c = null;
        sync.Account__c = acc.Id;
        sync.Landing_Page_Id__c = null;
        sync.Name = 'Test Landing Page';
        sync.Automation_Id__c = '951753';
        sync.Landing_Page_Name__c = 'Landing Page1';
        insert sync;
        
        delete sync;
    }
}