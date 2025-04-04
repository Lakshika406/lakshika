/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 2nd May 2017
*Purpose :     Test Code coverage for SendToInwiseControllerltng
/******************************************************************************************/
@isTest
private class SendToInwiseControllerltngTest
{
        @isTest
        static void SendToInwiseControllerltngTest1()
        {
                Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
                insert tokenSetting;  

                Account__c objinwiseAcc = inwiseTestDataFactory.GetInwiseAccount();
                objinwiseAcc.Default__c = true;
                insert objinwiseAcc;

                tokenSetting.Account_Id__c = objinwiseAcc.Id;
                update tokenSetting;  

                Campaign objCampaign=new Campaign();
                objCampaign.Name='Test Run Campaing';
                objCampaign.ParentId = null;
                objCampaign.Account__c = objinwiseAcc.id;
                insert objCampaign;
                string result = SendToInwiseControllerltng.getMsg(objCampaign.Id,'SendMember');
                System.assertEquals(result,'You don’t have any member on this campaign yet, please add your members first');
        }
}