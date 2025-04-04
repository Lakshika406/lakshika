/******************************************************************************************
*Created By:  Kapil Goutam
*Created On:  26 -february -2018
*Purpose :      Test code coverage for inwiseContactTriggerHandler
/******************************************************************************************/

@isTest
private class inwiseContactTriggerHandlerTest {
	static testmethod void inwiseContactTriggerHandlerTestMethod(){

        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
        objSetting.Toggle_Email_Opt_in_Opt_out__c = true;
        objSetting.Contact_Email_Opt_in_Opt_out__c = 'HasOptedOutOfEmail ';
        objSetting.Contact_Mobile_Opt_in_Opt_out__c = 'HasOptedOutOfFax';
        objSetting.Contact_Mobile_Opt_in_Opt_out_Field__c = 'MobilePhone';
        objSetting.Contact_Email_Opt_in_Opt_out_Field__c = 'Email';
        insert objSetting;

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  
        
        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Contact';
        con.email = 'inwise@inwisetest.com';
        con.HasOptedOutOfEmail = false;
        con.HasOptedOutOfFax = false;
        con.MobilePhone = '1234567890';
        insert con;

          Contact listOfContact = [select id,Name,HasOptedOutOfEmail from Contact where id = :con.id];
        System.debug('listOfContac--->>' +listOfContact);
        System.assertEquals(false,listOfContact.HasOptedOutOfEmail);
        Contact con2 = new Contact(id=con.id);
        con2.HasOptedOutOfEmail = true;
        con2.HasOptedOutOfFax = true;
        con2.MobilePhone = '901234567';
        update con2;

          listOfContact = [select id,Name,HasOptedOutOfEmail from Contact where id = :con.id];
          System.debug('listOfContact2--->>' +listOfContact);
          System.assertEquals(true,listOfContact.HasOptedOutOfEmail);

  }
}