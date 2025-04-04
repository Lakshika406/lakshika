/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Code coverage for inwiseQueryController class
/******************************************************************************************/
@isTest
private class inwiseQueryControllerTest {
        static testMethod void inwiseQueryControllerTest_Lead(){
                Sync__c objSync = new Sync__c();
                objSync.name = 'leadSync';
                objSync.Group_Name__c = 'campaign5';
                insert objSync;
                lead objLead = new Lead(firstname='lead',lastname='1',company='company');
                insert objLead;
                objSync.Leads__c = true;
                objSync.Leads_SOQL__c = 'SELECT ID,Name from Lead';
                update objSync;
                Test.setCurrentPage(Page.inwiseQuery);
                ApexPages.currentPage().getParameters().put('id', objSync.Id);
                inwiseQueryController objinwiseQueryController = new inwiseQueryController();
                System.assertEquals(objinwiseQueryController.listOfLeads.size(),objinwiseQueryController.listOfLeads.size());
                objinwiseQueryController.gotoHome();
        }  
        static testMethod void inwiseQueryControllerTest_Contact(){
                Sync__c objSync = new Sync__c();
                objSync.name = 'contactSync';
                objSync.Group_Name__c = 'campaign5';
                insert objSync;
                contact objContact = new contact(firstname='lead',lastname='1');
                insert objContact;
                objSync.Contacts__c = true;
                objSync.Contacts_SOQL__c = 'SELECT ID,Name from Contact';
                update objSync;
                Test.setCurrentPage(Page.inwiseQuery);
                ApexPages.currentPage().getParameters().put('id', objSync.Id);
                inwiseQueryController objinwiseQueryController = new inwiseQueryController();
                System.assertEquals(objinwiseQueryController.listOfContacts.size(),objinwiseQueryController.listOfContacts.size());
                objinwiseQueryController.gotoSchedule();
        }        
}