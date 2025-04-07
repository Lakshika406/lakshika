/******************************************************************************************
*Created By:  Kapil Goutam
*Created On:  19 - Nov - 2024
*Purpose :      Test code coverage for InwiseStandardAccountTriggerHandler
/******************************************************************************************/

@isTest
private class InwiseStandardAccountTriggerHandlerTest {

    // @isTest
    // static void testUpdateSubscriptionForEmail() {

    //     // Fetch RecordTypeId for Person Account
    //     Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

    //     Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
    //     objSetting.Toggle_Email_Opt_in_Opt_out__c = true;
    //     objSetting.Contact_Email_Opt_in_Opt_out__c = 'inwise__Phone_Opt_Out__c';
    //     objSetting.Contact_Email_Opt_in_Opt_out_Field__c = 'Phone';
    //     insert objSetting;

    //     Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
    //     insert tokenSetting;  
        
    //     Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
    //     act1.Default__c = true;
    //     insert act1;

    //     tokenSetting.Account_Id__c = act1.Id;
    //     update tokenSetting;  

    //     Account a = new Account();
    //     a.FirstName = 'Test';
    //     a.LastName = 'Person Account';
    //     //a.PersonHasOptedOutOfEmail = false;
    //     //a.PersonEmail = 'tess@gmail.com';
    //     a.RecordTypeId = personAccountRecordTypeId; 
    //     insert a;
        
    //     Account acc = new Account();
    //     acc.Id = a.Id;
    //     //acc.PersonHasOptedOutOfEmail = true;
        
    //     update acc;  
        
    //     List<Account> listOfAcc = [SELECT id, Name, FirstName FROM Account WHERE id =: acc.id];
    //     System.assertEquals(true,listOfAcc[0].FirstName  !=null);

    // }
    
    @isTest
    static void testUpdateSubscriptionForPhone() {
        
        
        // Fetch RecordTypeId for Person Account
        //Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        //Id stExam = Schema.SObjectType.Student_Records__c.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();


        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Toggle_Mobile_Opt_in_Opt_out__c = true;
        //objSetting.Contact_Mobile_Opt_in_Opt_out__c = 'inwise__Phone_Opt_Out__c';
        objSetting.Contact_Mobile_Opt_in_Opt_out_Field__c = 'Phone';
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  

        Account objAcc = new Account(name = 'test inwise account', Phone = '93434343242');
        insert objAcc;
        
        //Account a = new Account();
        //a.FirstName = 'Test';
        //a.LastName = 'Person Account';
        //a.inwise__Phone_Opt_Out__c = false;
        //a.Phone = '93434343242';
        //a.RecordTypeId = stExam; //'012580000005mxjAAA';
        //insert a;
        
        Account acc = new Account();
        acc.Id = objAcc.Id;
        //acc.inwise__Phone_Opt_Out__c = true;
        
        update acc;  
        
        List<Account> listOfAcc = [SELECT id, Name FROM Account WHERE id =: acc.id];
        //System.assertEquals(true,listOfAcc[0].inwise__Phone_Opt_Out__c);
        
    }
}