/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 17 Nov 2016
*Purpose :     Test code coverage for PostInstallClass
/******************************************************************************************/
@isTest
private class inwisePostInstallClassTest{
  static testmethod void inwisePostInstallClassTest1(){

          Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
          insert tokenSetting;  
          Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
          act1.Default__c = true;
          insert act1;
          tokenSetting.Account_Id__c = act1.Id;
          update tokenSetting;  
          inwisePostInstallClass postinstall = new inwisePostInstallClass();
          Test.testInstall(postinstall, null);
          List<Settings__c> listOfSetting = [Select id, name from Settings__c where name ='default'];
          System.assertEquals(listOfSetting.size(), 1, 'Setting default record could not be inserted');

  }
}