/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     check Account__c object field default set/unset
/******************************************************************************************/
@isTest 
private class inwiseAccountTriggerHandlerTest {
    static testMethod void inwiseAccountTriggerHandlerTest1() {
        List<Account__c> accList = new List<Account__c>();
        Token_Setting__c tokenSetting = inwiseTestDataFactory.GetInwiseTokenSetting();
        insert tokenSetting;  
        Account__c act1 = inwiseTestDataFactory.GetInwiseAccount();  
        act1.Default__c = true;       
        accList.add(act1);

        Token_Setting__c tokenSetting1 = inwiseTestDataFactory.GetInwiseTokenSetting();
        //insert tokenSetting1;  

        Account__c act2 = inwiseTestDataFactory.GetInwiseAccount();   
        act2.Default__c = true;   
        accList.add(act2);   

        Token_Setting__c tokenSetting2 = inwiseTestDataFactory.GetInwiseTokenSetting();
        //insert tokenSetting2;  

        Account__c act3 = inwiseTestDataFactory.GetInwiseAccount();   
        act3.Default__c = true;   
        accList.add(act3);  

        Token_Setting__c tokenSetting3 = inwiseTestDataFactory.GetInwiseTokenSetting();
        //insert tokenSetting3;  

        Account__c act4 = inwiseTestDataFactory.GetInwiseAccount();     
        accList.add(act4);                         
        insert accList;    
        
        tokenSetting.Account_Id__c = accList[0].Id;
        //update tokenSetting;  
        
        tokenSetting1.Account_Id__c = accList[1].Id;
        //update tokenSetting1;  

        tokenSetting2.Account_Id__c = accList[2].Id;
        //update tokenSetting2;  

        tokenSetting3.Account_Id__c = accList[3].Id;
        //update tokenSetting3;  

        // as trigger inwiseAccountTrigger fired field Default__c value of all records where 
        // Default__c = true will replaced with false other than 1st occurance
        List<Account__c> listOfAccount = [Select Id from Account__c where Default__c = false];
        system.assertEquals(listOfAccount.Size() , 3);      
        listOfAccount = [Select Id from Account__c where Default__c = true];
        system.assertEquals(listOfAccount.Size() , 1);
        
    }
}