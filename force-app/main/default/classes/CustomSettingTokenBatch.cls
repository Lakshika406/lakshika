global class CustomSettingTokenBatch implements Database.Batchable<SObject> {

    private String encryptionKeyForToken; // Class level variable to hold the string parameter

    // Constructor to accept dynamic parameters (like encryption key)
    public CustomSettingTokenBatch(String encryptionKey) {
        updateInwiseAccountToken(encryptionKey);

    }

    
    // Constructor for dynamic data setup if required
    global CustomSettingTokenBatch() {
    }

    // Start method to define the scope
    global Database.QueryLocator start(Database.BatchableContext context) {
        // Query Account__c or other related objects as per your use case
        //return Database.getQueryLocator('SELECT Id, Name, Token__c FROM Account__c WHERE Token__c != null'); 

        // Check object-level access
        if (Schema.sObjectType.Account__c.isAccessible() &&
            Schema.sObjectType.Account__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
            Schema.sObjectType.Account__c.fields.Token__c.isAccessible() ) {

            // Perform the query
            return Database.getQueryLocator('SELECT Id, Name, Token__c FROM Account__c WHERE Token__c != null'); 

        } else {
            // Log or handle insufficient permissions
            System.debug('User does not have sufficient permissions to access the Account__c object or the required fields.');
            return Database.getQueryLocator('SELECT Id FROM Account__c WHERE Id = NULL');
        }
    }

    // Execute method to perform operations on each batch
    global void execute(Database.BatchableContext context, List<SObject> scope) {
        List<Token_Setting__c> customSettingsToInsert = new List<Token_Setting__c>();
        List<Token_Setting__c> customSettingsToUpdate = new List<Token_Setting__c>();
        List<Account__c> inwsieAccountToUpdate = new List<Account__c>();

        
        for (SObject sObj : scope) {
            Account__c acc = (Account__c)sObj; // Cast the object if needed

            // Query the custom setting to check if it exists
            List<Token_Setting__c> existingSettings = [SELECT Id, Name, Token__c, Account_Id__c FROM Token_Setting__c WHERE Account_Id__c =: acc.Id WITH SECURITY_ENFORCED LIMIT 1];

            if (existingSettings.isEmpty()) {
                if(Schema.sObjectType.Token_Setting__c.isCreateable()){
                    // Create a new record
                    Token_Setting__c newSetting = new Token_Setting__c();
                    if(Schema.sObjectType.Token_Setting__c.fields.Name.isCreateable()){
                        newSetting.Name = acc.Name + ' - Setting';
                    }
                    if(Schema.sObjectType.Token_Setting__c.fields.Token__c.isCreateable()){
                        newSetting.Token__c = acc.Token__c; // Replace with dynamic logic
                    }
                    if(Schema.sObjectType.Token_Setting__c.fields.Account_Id__c.isCreateable()){
                        newSetting.Account_Id__c = acc.Id;
                    }
                    customSettingsToInsert.add(newSetting);
                }
            } else {
                if(Schema.sObjectType.Token_Setting__c.isCreateable() && Schema.sObjectType.Token_Setting__c.isUpdateable()){

                    // Update the existing record
                    Token_Setting__c existingSetting = existingSettings[0];
                    if(Schema.sObjectType.Token_Setting__c.fields.Token__c.isUpdateable()){
                        existingSetting.Token__c = acc.Token__c; // Replace with dynamic logic
                    }
                    customSettingsToUpdate.add(existingSetting);
                }
            }

            if(Schema.sObjectType.Account__c.isCreateable() && Schema.sObjectType.Account__c.isUpdateable()){
                Account__c accObj = new Account__c();
                accObj.Id = acc.Id;
                if(Schema.sObjectType.Account__c.fields.Token__c.isUpdateable()){
                    accObj.Token__c = null;
                }
                inwsieAccountToUpdate.add(accObj);
            }
        }

        // Perform DML operations
        if (!customSettingsToInsert.isEmpty()) {
            try {
                insert customSettingsToInsert;
            } catch (DmlException e) {
                System.debug('Error inserting custom settings: ' + e.getMessage());
            }
        }

        if (!customSettingsToUpdate.isEmpty()) {
            try {
                update customSettingsToUpdate;
            } catch (DmlException e) {
                System.debug('Error updating custom settings: ' + e.getMessage());
            }
        }

        if (!inwsieAccountToUpdate.isEmpty()) {
            try {
                update inwsieAccountToUpdate;
            } catch (DmlException e) {
                System.debug('Error updating Inwise Account Token: ' + e.getMessage());
            }
        }
    }

    // Finish method for post-processing
    global void finish(Database.BatchableContext context) {
        System.debug('Batch processing for custom settings is complete.');
    }

    public static void updateInwiseAccountToken(String encryptionKey){
        List<Account__c> listOfInwiseAccount = new List<Account__c>();
        for(Account__c acc : [SELECT Id, Name, Token__c FROM Account__c WHERE Token__c != null WITH SECURITY_ENFORCED LIMIT 49999]){
            if(Schema.sObjectType.Account__c.isCreateable() && Schema.sObjectType.Account__c.isUpdateable()){
                Account__c inwiseAcc = new Account__c();
                inwiseAcc.Id = acc.Id;
                try{
                    Blob key ;
                    if(encryptionKey != null ){
                        key = Blob.valueOf(encryptionKey);
                    }
                    Blob encryptedBlob = EncodingUtil.base64Decode(acc.Token__c);  // Decode the Base64 string
                    Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', key, encryptedBlob);  // Decrypt with AES128
                    System.debug('Token decrypted successfully.');
                    if(Schema.sObjectType.Account__c.fields.Token__c.isUpdateable()){
                        inwiseAcc.Token__c = decryptedBlob.toString();
                    }
                    listOfInwiseAccount.add(inwiseAcc);
                } catch(Exception ex){
                    if(Schema.sObjectType.Account__c.fields.Token__c.isUpdateable()){
                        inwiseAcc.Token__c = acc.Token__c;
                    }
                    listOfInwiseAccount.add(inwiseAcc);
                }
            } else {
                System.debug('You have not Account Object Access.');
            }
        }
        if(listOfInwiseAccount.size() > 0){
            update listOfInwiseAccount;
        }
    }
}