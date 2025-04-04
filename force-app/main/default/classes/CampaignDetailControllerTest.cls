/**
 * Created by Kapil Goutam on 12/18/2018.
 */

@IsTest
private class CampaignDetailControllerTest {
    @IsTest
    static void AccountDetailControllerTest1() {

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;  

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  

        Campaign objCampaign = new Campaign();
        if(Campaign.SObjectType.getDescribe().isCreateable() || Campaign.SObjectType.getDescribe().isUpdateable() ){
            objCampaign = inwiseTestDataFactory.getInwiseCampaing(act1);
            if(Schema.sObjectType.Campaign.fields.Campaign_Type__c.isAccessible() && (Schema.sObjectType.Campaign.fields.Campaign_Type__c.isCreateable() || Schema.sObjectType.Campaign.fields.Campaign_Type__c.isUpdateable())){
                objCampaign.Campaign_Type__c = 'Email';
            }
            insert objCampaign;
        }
        
         
        Account_SalesforceUser_Mapping__c objAccoutUserMapping = inwiseTestDataFactory.createAccountSalesforceUserMapping(); 
        objAccoutUserMapping.User__c = UserInfo.getUserId();
        objAccoutUserMapping.Account__c = act1.Id;
        insert objAccoutUserMapping;
        Test.setCurrentPage(Page.CampaignDetail);
        ApexPages.currentPage().getParameters().put('id', objCampaign.Id);
        ApexPages.StandardController std;
        if(Campaign.SObjectType.getDescribe().isAccessible() && Campaign.SObjectType.getDescribe().isUpdateable()){
            std = new ApexPages.StandardController(objCampaign);
            CampaignDetailController objAccountDetailController = new CampaignDetailController(std);
            Integer i = objAccountDetailController.Clicked;
            i = objAccountDetailController.Bounced;
            i = objAccountDetailController.ClicksUnique;
            i = objAccountDetailController.Opened;
            i = objAccountDetailController.Groupid;
            i = objAccountDetailController.Opened;
            i = objAccountDetailController.OpensUnique; 
            i = objAccountDetailController.Nonsent; 
            i = objAccountDetailController.Sendid;
            i = objAccountDetailController.Sent;
            i = objAccountDetailController.Unsubscribe;
            objAccountDetailController.showPopup(); 
            objAccountDetailController.doOpeninEditMode(); 
            objAccountDetailController.doCancel();
            objAccountDetailController.doSave();
            objAccountDetailController.closePopup(); 
            objAccountDetailController.selectedAccId();
            system.assertEquals(i,0);
        }

    }
}