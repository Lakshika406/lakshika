/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: Oct 2016
*Purpose :     class that will schedule the job for a sync
UPDATE
********************************
CLASS NOT IN USE
************************************
/******************************************************************************************/
global  with sharing class inwiseSchedular implements  Schedulable,Database.AllowsCallouts {
    Sync__c objSync {get;set;}
    static String newLineFeed = '\n';
    public inwiseSchedular(String syncid){
          if(Schema.sObjectType.Sync__c.isUpdateable()){
              objSync = new Sync__c(Id=syncid);
          }
    }
    global void execute(SchedulableContext ctx) {
            if(objSync != NULL && objSync.Id != NULL){
                  //futureCalloutinwiseSync(objSync.Id);
            }
    }
    
}