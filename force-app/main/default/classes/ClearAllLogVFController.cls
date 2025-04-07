/******************************************************************************************
*Created By:  Nlineaxis
*Created On: 03/10/2024  
*Purpose :     clear landing sync history

******************************************************************************************/
global with sharing class ClearAllLogVFController {
	public ClearAllLogVFController(ApexPages.StandardSetController std){
      
    } 
    
    webservice static void doClearLandingSyncHistory(){
        if(Landing_Sync_History__c.SObjectType.getDescribe().isAccessible() && Landing_Sync_History__c.SObjectType.getDescribe().isDeletable()){
            List<Landing_Sync_History__c> listOfLandingSyncHistory = [Select Id from Landing_Sync_History__c limit 1];
            System.debug('listOfLandingSyncHistory::@@@-->>' +listOfLandingSyncHistory);
            if(!listOfLandingSyncHistory.isEmpty()){
                try{
                    //System.debug('exception::@@@-->>' );
                    delete listOfLandingSyncHistory;
                    
                }catch(Exception ex){
                    System.debug('exception::-->>' + ex.getMessage());
                }
            }
        }
    }
}