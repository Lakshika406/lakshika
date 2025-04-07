/******************************************************************************************
*Created By:  Kapil Goutam
*Created On:  19 April 2019
*Purpose :      Test code coverage for inwiseAutomationTrigger
/******************************************************************************************/
@isTest

public class inwiseAutomationTriggerTest {
    
    static testmethod void inwiseAutomationTriggerTestMethod(){
        
        Settings__c objSetting = inwiseTestDataFactory.GetInwiseSetting();
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
        con.MobilePhone ='123458';
        insert con;
        
        Lead objLead = new Lead();
        objLead.FirstName = 'inwise';
        objLead.LastName = 'Test Lead';
        objLead.Email = 'inwise@inwisetest.com';
        objLead.Status = 'Open - Not Contacted';        
        objLead.Company = 'inwise';
        insert ObjLead;
        
        map<string,Mapping__c> mapping  = inwiseTestDataFactory.GetInwiseFieldMapping(act1);
        insert mapping.values();
        
        con.LastName = 'test';
        update con;
        
        ObjLead.LastName= 'test';
        update ObjLead;

        //addding direct call here because in packaging org we do not have process builder.
        inwiseAutomationTrigger.inwiseAutomation(new List<String>{'[{"RecordID":"'+ con.Id +'","trigger_identifier":"5"}]'});
        inwiseAutomationTrigger.inwiseAutomation(new List<String>{'[{"RecordID":"'+ ObjLead.Id +'","trigger_identifier":"5"}]'});
        
        String resBody ='[{"identifier": "5","contact_data": {"fields": [{ "name": "1", "content": "Kapil" },{"name": "2", "content": "Male" }],"email": "test@gmail.com","mobile_number": "1215454646","confirmed": true,"external_id": "0030o00002lDNg0"}}]';
        HttpResponse res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'application/json');
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('OK',res.getStatus());
    }
}