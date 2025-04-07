/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 17 Nov 2016
*Purpose :     inwisePostInstallClass to insert the default record in custom setting
================================================================
Modified On    Version    Modified By                Purpose
================================================================
17/11/2016     1.0.0      NLINEAXIS(Kapil Goutam)    Created
09/06/2021     1.1.0      NLINEAXIS(S. V.)           Modified:- Added new method checkAndCreateRemoteSite and createRemoteSite to check/create Remote Site Setting
14/06/2021     1.1.0      NLINEAXIS(Kapil Goutam)    Modified:- removed code to add remote site setting to check if this piece of code generating issue while installation.
08/10/2024     1.1.1      NLINEAXIX                  Modified:- Added updateEncryptedTokenOnAccnt method to encrypted existing token values 
/******************************************************************************************/
global class inwisePostInstallClass implements InstallHandler {


    global void onInstall(InstallContext context) {
    
        Boolean isNewPackageInstall = false;
        if(context.previousVersion() == null) {
        
            isNewPackageInstall = true;
            if(Schema.sObjectType.Settings__c.isCreateable()){
            
                Settings__c objSetting = new Settings__c();
                if(Schema.sObjectType.Settings__c.fields.Name.isCreateable()){
                    objSetting.Name = 'default';
                }
                //if(Schema.sObjectType.Settings__c.fields.API_Url__c.isCreateable()){
                //      objSetting.API_Url__c = 'https://api.inwise.com';
                //}
                //if(Schema.sObjectType.Settings__c.fields.APP_Url__c.isCreateable()){
                //      objSetting.APP_Url__c = 'https://app.inwise.com/default.aspx';
                //}
                if(Schema.sObjectType.Settings__c.fields.Sync_Members_Batch_Size__c.isCreateable()){
                    objSetting.Sync_Members_Batch_Size__c = 100;
                }
                //if(Schema.sObjectType.Settings__c.fields.Campaign_Member_Action_Job_Row_Limit__c.isCreateable()){
                //      objSetting.Campaign_Member_Action_Job_Row_Limit__c = 50;
                //}
                if(Schema.sObjectType.Settings__c.fields.Overlay_Help__c.isCreateable()){
                    objSetting.Overlay_Help__c = true;
                }
                if(Schema.sObjectType.Settings__c.fields.Page_Size__c.isCreateable()){
                    objSetting.Page_Size__c = 5;
                }
                if(Schema.sObjectType.Settings__c.fields.Toggle_Email_Opt_in_Opt_out__c.isCreateable()){
                    objSetting.Toggle_Email_Opt_in_Opt_out__c = false;
                }
                if(Schema.sObjectType.Settings__c.fields.Track_Logs__c.isCreateable()){
                    objSetting.Track_Logs__c = false;
                }
                insert objSetting;
            }
        }

        String encryptionKey = '1234567890123456';
        CustomSettingTokenBatch batchInstance = new CustomSettingTokenBatch(encryptionKey);
        Database.executeBatch(batchInstance, 200);

        //createOrUpdateDefaultTokenSetting();
        //updateEncryptedTokenOnAccnt();
        //Check and create Remote Site Setting
        //checkAndCreateRemoteSite(isNewPackageInstall);
    }
    // private static void updateEncryptedTokenOnAccnt(){
    //     System.debug('updateEncryptedTokenOnAccnt==');
    //     String encryptionKeyStr = '1234567890123456';
    //     List<Account__c> accList = [SELECT Id, Token__c from Account__c WHERE Token__c != NULL WITH SECURITY_ENFORCED LIMIT 49999];
    //     //List<Account__c> accListToUpdate = new List<Account__c>();

    //     if (accList.isEmpty()) {
    //         System.debug('No Account__c records with Token__c found. Skipping update.');
    //         return;
    //     }

    //     //List<Token_Setting__c> tokenSettingList = new List<Token_Setting__c>();
    //     if(!accList.isEmpty()){
    //         //tokenSettingList = [SELECT Id, Encryption_Key__c FROM Token_Setting__c WHERE Name = 'default' LIMIT 1];
    //         // if (tokenSettingList.isEmpty() || String.isEmpty(tokenSettingList[0].Encryption_Key__c)) {
    //         //     System.debug('No Token_Setting__c default record found or Encryption_Key__c is empty. Skipping update.');
    //         //     return;
    //         // }
    //         for(Account__c acc : accList){
    //             //if(tokenSettingList[0].Encryption_Key__c != null && acc.Token__c != null){
    //             if(acc.Token__c != null){

    //                 String isEncrtpted = decryptToken(acc.Token__c, encryptionKeyStr);
                    
    //                 // if(isEncrtpted == null){
    //                 //     acc.Token__c = encryptToken(acc.Token__c, tokenSettingList[0].Encryption_Key__c);
    //                 //     accListToUpdate.add(acc);
    //                 // }

    //                 if(isEncrtpted != null){
    //                     createOrUpdateTokenSetting(acc, isEncrtpted, encryptionKeyStr);
    //                 } else if(isEncrtpted == null){
    //                     createOrUpdateTokenSetting(acc, acc.Token__c, encryptionKeyStr);
    //                 }
    //             }

    //         }
    //         // if(!accListToUpdate.isEmpty()){
    //         //     update accListToUpdate;
    //         // }
    //     } else {
    //         // Query the custom setting to check for an existing record with the given Account Id
    //         List<Token_Setting__c> existingSettings = [ SELECT Id, Account_Id__c, Token__c, Encryption_Key__c FROM Token_Setting__c 
    //                                                     WHERE Name = 'default' LIMIT 1];


    //         // If a matching record is found, update the token
    //         if (existingSettings.size() > 0 && Schema.sObjectType.Token_Setting__c.isCreateable() && Schema.sObjectType.Token_Setting__c.isUpdateable()) { 
    //             if(Schema.sObjectType.Token_Setting__c.fields.Encryption_Key__c.isUpdateable() && Schema.sObjectType.Token_Setting__c.fields.Encryption_Key__c.isCreateable()){
    //                 existingSettings[0].Encryption_Key__c = encryptionKeyStr;
    //             }
    //             update existingSettings;
    //             System.debug('Updated Token_Setting__c record.');
    //         } else {
    //             // No record found, create a new record 
    //             if(Schema.sObjectType.Token_Setting__c.isCreateable()){
    //                 Token_Setting__c newSetting = new Token_Setting__c();
    //                 if(Schema.sObjectType.Token_Setting__c.fields.Name.isCreateable()){
    //                     newSetting.Name ='default';
    //                 }

    //                 if(Schema.sObjectType.Token_Setting__c.fields.Encryption_Key__c.isCreateable()){
    //                     newSetting.Encryption_Key__c = encryptionKeyStr;
    //                 }


    //                 insert newSetting;
    //                 System.debug('Created Token_Setting__c record.');
    //             }
    //         }
    //     }
    // }

    // private static String decryptToken(String encryptedToken, String encryptionKey){
    //     try{
    //         Blob key = Blob.valueOf(encryptionKey);
    //         Blob encryptedBlob = EncodingUtil.base64Decode(encryptedToken);  // Decode the Base64 string
    //         Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', key, encryptedBlob);
    //         return decryptedBlob.toString();  // Convert Blob back to a string
    //         //return true;
    //     }
    //     catch(Exception ex){
    //         return null;
    //     }
    // }
    // private static String encryptToken(String token, String encryptionKey) {
    //     Blob key = Blob.valueOf(encryptionKey);
    //     Blob tokenBlob = Blob.valueOf(token);  // Convert the token to Blob
    //     Blob encryptedBlob = Crypto.encryptWithManagedIV('AES128', key, tokenBlob);  // Encrypt with AES128
    //     return EncodingUtil.base64Encode(encryptedBlob);  // Return the encrypted token as a Base64 string
    // }

    // private static void createOrUpdateTokenSetting(Account__c inwiseAcc, String token, String encryptionKey) {
    //     System.debug('createOrUpdateTokenSetting==');
    //     // Query the custom setting to check for an existing record with the given Account Id
    //     List<Token_Setting__c> existingSettings = [ SELECT Id, Account_Id__c, Token__c FROM Token_Setting__c 
    //                                                 WHERE Account_Id__c = :inwiseAcc.Id LIMIT 1];


    //     // If a matching record is found, update the token
    //     if (existingSettings.size() > 0 && Schema.sObjectType.Token_Setting__c.isCreateable() && Schema.sObjectType.Token_Setting__c.isUpdateable()) { 
    //         if(Schema.sObjectType.Token_Setting__c.fields.Token__c.isUpdateable() && Schema.sObjectType.Token_Setting__c.fields.Token__c.isCreateable()){
    //             existingSettings[0].Token__c = encryptToken(token, encryptionKey);
    //         }
    //         update existingSettings;
    //         System.debug('Updated Token_Setting__c record.');
    //     } else {
    //         // No record found, create a new record 
    //         if(Schema.sObjectType.Token_Setting__c.isCreateable()){
    //             Token_Setting__c newSetting = new Token_Setting__c();
    //             if(Schema.sObjectType.Token_Setting__c.fields.Name.isCreateable()){
    //                 newSetting.Name = inwiseAcc.Name + ' Setting';
    //             }

    //             if(Schema.sObjectType.Token_Setting__c.fields.Account_Id__c.isCreateable()){
    //                 newSetting.Account_Id__c = inwiseAcc.Id;
    //             }

    //             if(Schema.sObjectType.Token_Setting__c.fields.Token__c.isCreateable()){
    //                 newSetting.Token__c = encryptToken(token, encryptionKey);
    //             }

                

    //             insert newSetting;
    //             System.debug('Created Token_Setting__c record.');
    //         }
    //     }


    //     // Query the custom setting to check for an existing record with the given Account Id
    //     List<Token_Setting__c> existingDefaultSettings = [ SELECT Id, Account_Id__c, Token__c, Encryption_Key__c FROM Token_Setting__c 
    //                                                 WHERE Name = 'default' LIMIT 1];


    //     // If a matching record is found, update the token
    //     if (existingDefaultSettings.size() > 0 && Schema.sObjectType.Token_Setting__c.isCreateable() && Schema.sObjectType.Token_Setting__c.isUpdateable()) { 
    //         if(Schema.sObjectType.Token_Setting__c.fields.Encryption_Key__c.isUpdateable() && Schema.sObjectType.Token_Setting__c.fields.Encryption_Key__c.isCreateable()){
    //             existingDefaultSettings[0].Encryption_Key__c = encryptionKey;
    //         }

    //         update existingDefaultSettings;
    //         System.debug('Updated Token_Setting__c record.');
    //     } else {
    //     // No record found, create a new record 
    //         if(Schema.sObjectType.Token_Setting__c.isCreateable()){
    //             Token_Setting__c newSetting = new Token_Setting__c();
    //             if(Schema.sObjectType.Token_Setting__c.fields.Name.isCreateable()){
    //                 newSetting.Name ='default';
    //             }

    //             if(Schema.sObjectType.Token_Setting__c.fields.Encryption_Key__c.isCreateable()){
    //                 newSetting.Encryption_Key__c = encryptionKey;
    //             }


    //             insert newSetting;
    //             System.debug('Created Token_Setting__c record.');
    //         }
    //     }

    // }


    // private static void createOrUpdateDefaultTokenSetting(){
    //     System.debug('createOrUpdateDefaultTokenSetting==');

    //     // Check if a Token_Setting__c record with the name "default" already exists
    //     List<Token_Setting__c> existingRecord = [SELECT Id, Name, Encryption_Key__c FROM Token_Setting__c WHERE Name = 'default' LIMIT 1];
    //     if (existingRecord.size() > 0) {
    //         if(Schema.sObjectType.Token_Setting__c.isCreateable() && Schema.sObjectType.Token_Setting__c.isUpdateable()){
    //             if(Schema.sObjectType.Token_Setting__c.fields.Encryption_Key__c.isUpdateable() && Schema.sObjectType.Token_Setting__c.fields.Encryption_Key__c.isCreateable()){
    //                 // Update the Encryption_Key__c of the existing record
    //                 existingRecord[0].Encryption_Key__c = '1234567890123456';
    //             }
    //             update existingRecord;
    //         }
            
    //     } else {
    //         if(Schema.sObjectType.Token_Setting__c.isCreateable()){
            
    //             Token_Setting__c objTokenSetting = new Token_Setting__c();
    //             if(Schema.sObjectType.Token_Setting__c.fields.Name.isCreateable()){
    //                 objTokenSetting.Name = 'default';
    //             }
    
    //             if(Schema.sObjectType.Token_Setting__c.fields.Encryption_Key__c.isCreateable()){
    //                 objTokenSetting.Encryption_Key__c = '1234567890123456';
    //             }

    //             insert objTokenSetting;
    //             System.debug('Created default Token_Setting__c record.');
    //         }
    //     }
    // }

    // private static void createOrUpdateDefaultTokenSetting() {
    //     try {
    //         // Check if the custom setting is createable
    //         if (!Schema.sObjectType.inwise__Token_Setting__c.isCreateable()) {
    //             System.debug('Error: Token_Setting__c is not createable.');
    //             return;
    //         }
    
    //         // Check for existing default record
    //         List<inwise__Token_Setting__c> existingRecord = [SELECT Id FROM inwise__Token_Setting__c WHERE Name = 'default' LIMIT 1];
    
    //         if (existingRecord.isEmpty()) {
    //             // Create a new default record
    //             inwise__Token_Setting__c defaultSetting = new inwise__Token_Setting__c();
    
    //             if (Schema.sObjectType.inwise__Token_Setting__c.fields.Name.isCreateable()) {
    //                 defaultSetting.Name = 'default';
    //             }
    //             if (Schema.sObjectType.inwise__Token_Setting__c.fields.inwise__Encryption_Key__c.isCreateable()) {
    //                 defaultSetting.inwise__Encryption_Key__c = '1234567890123456'; // Replace with secure key
    //             }
    
    //             insert defaultSetting;
    //             System.debug('Default Token_Setting__c created.');
    //         } else {
    //             System.debug('Default Token_Setting__c already exists.');
    //         }
    //     } catch (Exception ex) {
    //         System.debug('Error in createOrUpdateDefaultTokenSetting: ' + ex.getMessage());
    //         throw ex;
    //     }
    // }
    
    // private void checkAndCreateRemoteSite(Boolean isNewPackageInstall){
        
    //     if(isNewPackageInstall){
    //         createRemoteSite();
    //     }
    //     else {
    //         Boolean isError = false;
    //         Boolean isRemoteSiteExist = false;
    //         List<MetadataService.ListMetadataQuery> listMetadataQueryList = new List<MetadataService.ListMetadataQuery>();
    //         MetadataService.ListMetadataQuery remoteSites = new MetadataService.ListMetadataQuery();
    //         remoteSites.type_x = 'RemoteSiteSetting';
    //         listMetadataQueryList.add(remoteSites);
            
    //         try{
    //             MetadataService.MetadataPort service = inwiseUtil.createMetadataService();
    //             List<MetadataService.FileProperties> filePropertiesList = service.listMetadata(listMetadataQueryList, inwiseConstants.METADATA_API_VERSION);
                
    //             if(filePropertiesList != null && filePropertiesList.size() > 0){
    //                 for(MetadataService.FileProperties fileProperties : filePropertiesList){
    //                     if(fileProperties.fullName == inwiseConstants.ORG_REST_API){
    //                         isRemoteSiteExist = true;
    //                         break;
    //                     }
    //                 }
    //             }
    //         }
    //         catch(Exception exp){
    //             isError = true;
    //             Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(exp.getMessage(), 'inwisePostInstallClass', 'checkAndCreateRemoteSite');
    //             if(errorLog != null){
    //                 insert errorLog;
    //             }
    //         }
            
    //         if(!isError && !isRemoteSiteExist){
    //             createRemoteSite();
    //         }
    //     }
    // }
    
    // private void createRemoteSite(){
        
    //     List<MetadataService.Metadata> metadataList = new List<MetadataService.Metadata>();
    //     MetadataService.RemoteSiteSetting remoteSiteDetails = new MetadataService.RemoteSiteSetting();
    //     remoteSiteDetails.isActive = true;
    //     remoteSiteDetails.disableProtocolSecurity = false;
    //     remoteSiteDetails.fullName = inwiseConstants.ORG_REST_API;
    //     remoteSiteDetails.url = inwiseConstants.ORGANIZATION_BASE_URL;
    //     metadataList.add(remoteSiteDetails);
        
    //     try{
    //         Boolean isSucessfull = false;
    //         MetadataService.MetadataPort service = inwiseUtil.createMetadataService();
    //         List<MetadataService.UpsertResult> results = service.upsertMetadata(metadataList);
            
    //         if(results != null && results.size() > 0){
    //             MetadataService.UpsertResult result = results[0];
    //             if(result.success){
    //                 isSucessfull = true;
    //             }
    //             else{
    //                 if(result.errors != null && result.errors.size() > 0){
    //                     Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(result.errors[0].message, 'inwisePostInstallClass', 'createRemoteSite');
    //                     if(errorLog != null){
    //                         insert errorLog;
    //                     }
    //                 }
    //             }
    //         }
    //     }
    //     catch(Exception exp){
    //         Error_Logs__c errorLog = inwiseHttpUtil.getErrorLogRecord(exp.getMessage(), 'inwisePostInstallClass', 'createRemoteSite');
    //         if(errorLog != null){
    //             insert errorLog;
    //         }
    //     }
    // }
}