/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Test class code for inwiseSyncController
/******************************************************************************************/
@isTest
private class inwiseSyncControllerTest {

    static testMethod void inwiseSyncControllerTest1() { 
        // Test with no mapping and no account__c
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Track_Logs__c =true;
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  

        Test.setCurrentPage(Page.inwiseSync);
        ApexPages.currentPage().getParameters().put('aid', null);
        ApexPages.StandardController std = new ApexPages.StandardController(new Account__c());
        inwiseSyncController objinwiseSyncController = new inwiseSyncController(std);
        objinwiseSyncController.InitializeWrapperClass();
        //System.assertEquals(ApexPages.getMessages().get(0).getSummary(),'Please provide required credentials to connect');
        objinwiseSyncController.doSave();
        List<Mapping__c> listOfInwiseMapping = [Select Id from Mapping__c where Account__c=:null];
        System.assertEquals(listOfInwiseMapping.size(),0);  
        
        // Test with field is None for both Lead as well as contact
        //Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        //objSetting.Track_Logs__c =true;
        //insert objSetting;
        //Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        //act1.Default__c = true;
        //insert act1;
        Mapping__c mapping1= inwiseTestDataFactory.createMapping(act1.Id,'emailAddress',null, 'contact');
        insert mapping1;
        Mapping__c mapping2= inwiseTestDataFactory.createMapping(act1.Id,'Name Text',null, 'lead');
        insert mapping2;        
        ApexPages.currentPage().getParameters().put('aid', act1.Id);
        std = new ApexPages.StandardController(new Account__c());
        objinwiseSyncController = new inwiseSyncController(std);
        objinwiseSyncController.doSave();
        listOfInwiseMapping = [Select Id from Mapping__c where Account__c=:act1.Id];
        System.assert(listOfInwiseMapping.size()>1,'Mapping Insertion Failed');  
        
        // Test with field is not none for both Lead as well as contact
        Mapping__c mapping3= inwiseTestDataFactory.createMapping(act1.Id,'emailAddress','email', 'contact');
        insert mapping3;
        Mapping__c mapping4= inwiseTestDataFactory.createMapping(act1.Id,'Name Text','name', 'lead');
        insert mapping4;      

        Test.setCurrentPage(Page.inwiseSync);
        ApexPages.currentPage().getParameters().put('aid', act1.Id);
        std = new ApexPages.StandardController(new Account__c());
        objinwiseSyncController = new inwiseSyncController(std);
        objinwiseSyncController.InitializeWrapperClass();
        objinwiseSyncController.doSave();
        listOfInwiseMapping = [Select Id from Mapping__c where Account__c=:act1.Id];
        System.assert(listOfInwiseMapping.size()>1,'Mapping Insertion Failed');  
        objinwiseSyncController.isHelpOnload = true;
        objinwiseSyncController.toggleshowhelp();
        String currentPage = string.valueOf(ApexPages.currentPage());
        system.assertEquals(currentPage.contains('inwisesync'),true);
        List<Logs__c> listOfLogs = new List<Logs__c>();
        objinwiseSyncController.createSalesForceCampMemberIDFieldAtinwise(0,listOfLogs);
        objinwiseSyncController.goToHome();
        inwiseGlobalAction.doClearLogs();
    }    
}