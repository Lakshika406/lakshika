/******************************************************************************************
*Created By:  Kapil Goutam
*Created On:  04/20/2021
*Purpose :    Test class for inwiseActivityTriggerHandler class
/******************************************************************************************/   
@isTest
public class inwiseActivityTriggerHandlerTest {
     static testmethod void sendSMSAccountController_Test1() {
         inwiseActivityTriggerHandler obj = new inwiseActivityTriggerHandler(); 
         Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

         Account__c acc = inwiseTestDataFactory.GetInwiseAccount(); 
         insert acc;

        tokenSetting.Account_Id__c = acc.Id;
        update tokenSetting;  
        
         Contact con = inwiseTestDataFactory.GetInwiseContact(); 
         insert con;
         Campaign camObj = inwiseTestDataFactory.getInwiseCampaing(acc);
         insert camObj;
         CampaignMember camMember = inwiseTestDataFactory.getInwiseCampaignMember(camObj, con);
         insert camMember;
         Lead lead = inwiseTestDataFactory.GetInwiseLead();
         insert lead;
         List<Activity__c> listOfActivity = new List<Activity__c>();
         Activity__c activitieObj = inwiseTestDataFactory.getInwiseActivity();
         activitieObj.SalesforceId__c = camMember.Id;
         activitieObj.Contact__c = con.Id;
         activitieObj.Lead__c = lead.Id;
         insert activitieObj;
         listOfActivity.add(activitieObj);
         test.startTest();
         	inwiseActivityTriggerHandler.insertContactAndLeadOnActivity(listOfActivity); 
         	system.assertEquals(listOfActivity.size(),1);
         test.stopTest();
     }

}