@isTest
private class CustomSettingTokenBatchTest {
    @isTest
    static void testBatchProcessing() {
        // Create test data
        

        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  

        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();
        act1.Default__c = true;
        insert act1;   

        tokenSetting.Account_Id__c = act1.Id;
        update tokenSetting;  

        // Test start method
        Test.startTest();

        // Execute the batch
        CustomSettingTokenBatch batch = new CustomSettingTokenBatch();
        Database.executeBatch(batch, 2); // Process in batches of size 2

        Test.stopTest();

        // Validate custom setting records are created or updated
        List<Token_Setting__c> customSettings = [SELECT Name, Token__c, Account_Id__c FROM Token_Setting__c];
        System.assertEquals(1, customSettings.size(), 'Five custom settings should exist.');

        // Validate the existing custom setting was updated
        Token_Setting__c updatedSetting = [SELECT Name, Token__c FROM Token_Setting__c WHERE Account_Id__c =: act1.Id];
        System.assertEquals('dwsd23232sdssdDE', updatedSetting.Token__c, 'The existing custom setting should have been updated.');

        // Validate accounts were updated
        List<Account__c> updatedAccounts = [SELECT Token__c FROM Account__c WHERE Id =: act1.Id];
        for (Account__c acc : updatedAccounts) {
            System.assertEquals(null, acc.Token__c, 'Account tokens should be cleared.');
        }
    }
}