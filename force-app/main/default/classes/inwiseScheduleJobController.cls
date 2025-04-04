/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: Oct 2016
*Purpose :     class to schedule the job

Modification Log
--------------------
Date                  Version     Developer                  Comments
------------------------------------------------------------------------------------
11/25/2021            1.0.0       NLINEAXIS(S.Vaishnav)      Modified:- Code indentation and required "Scheduled Daily At" field
/******************************************************************************************/
global with sharing class inwiseScheduleJobController {

      public Sync__c objSync                                 {get;set;}
      public Boolean isSuccess                               {get;set;}
      InwiseUtil objInwiseUtil                               {get;set;}
      public String sCurrentStepText                         {get;set;}
      public inwiseLtngConstants objinwiseLtngConstants      {get;set;}
      
       public inwiseScheduleJobController() {
             Id syncid = ApexPages.CurrentPage().getParameters().get('Id');
             sCurrentStepText = 'Step 4';
             objinwiseLtngConstants = new inwiseLtngConstants();
 
             if(Schema.sObjectType.Sync__c.isAccessible()){
                   objSync = inwiseUtil.doGetSyncRecord(syncid);
                   if(objSync.Is_Created_By_View__c){
                         sCurrentStepText = 'Step 3';
                   }
             }
             if(objSync.Account__c != NULL){
                   objInwiseUtil = new InwiseUtil(new Account__c(Id = objSync.Account__c));
             }else{
                   objInwiseUtil = new InwiseUtil(null);
             }
             isSuccess = false;
       }
 
       public PageReference doSchedule(){
             isSuccess = false;
             //if value is none abort previous job, new feature - 22, 23 May 2018
             if(objSync.Scheduled_Daily_At__c == NULL){
                   apexpages.addmessage(new apexpages.message(apexpages.severity.INFO, inwiseConstants.SCHEDULED_DAILY_AT));                              
                   return null;
             }
 
             if(objSync.Last_JobId__c != NULL){
                   try{
                         System.abortJob(objSync.Last_JobId__c);
                         apexpages.addmessage(new apexpages.message(apexpages.severity.INFO,inwiseConstants.MSG_JOB_CANCELED));
                   }catch(Exception ex){
                         apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR,ex.getMessage()));
                   }
                   if(Schema.sObjectType.Sync__c.isUpdateable()){
                         Sync__c objSyncToUpdate = new Sync__c(Id = objSync.Id);
                         if(Schema.sObjectType.Sync__c.fields.Last_JobId__c.isUpdateable()){
                               objSyncToUpdate.Last_JobId__c = NULL;
                         }
                         if(Schema.sObjectType.Sync__c.fields.Last_JobName__c.isUpdateable()){
                               objSyncToUpdate.Last_JobName__c = NULL;
                         }
                         if(Schema.sObjectType.Sync__c.fields.Scheduled_Daily_At__c.isUpdateable()){
                               objSyncToUpdate.Scheduled_Daily_At__c = NULL;
                         }
                         update objSyncToUpdate;
                   }
             }
 
             //check if the view deleted before sync
             if(!doCheckIfViewAvailable()){
                   apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR, inwiseConstants.MSG_SELECTED_VIEW_DELETED));
                   return null;
             }
 
             deletePreviousJob();
             inwiseGlobalAction.doClearAll(objInwiseUtil.objInwiseSetting.Track_Logs__c); 
             //inwiseGlobalAction.doClearSyncMaster();
             //inwiseGlobalAction.doClearPreviousLogs();
             //@todo-temp code for executing job in next 5 minutes
             //String chString = inwiseLandingSyncScheduleJobController.getCronExpressionTemp(objSync.Scheduled_Daily_At__c);
             String chString = inwiseLandingSyncScheduleJobController.getCronExpression(objSync.Scheduled_Daily_At__c);  
             String jobName = getJobName();
             String cronid = System.schedule(jobName, chString, new inwiseSchedularNew(objSync.Id));
             if(Schema.sObjectType.Sync__c.isUpdateable()){
                   if(Schema.sObjectType.Sync__c.fields.Last_JobId__c.isUpdateable()){
                         objSync.Last_JobId__c = cronid;
                   }     
                   if(Schema.sObjectType.Sync__c.fields.Last_JobName__c.isUpdateable()){      
                         objSync.Last_JobName__c = jobName;
                   }      
                   update objSync;
             }   
             apexpages.addmessage(new apexpages.message(apexpages.severity.INFO, inwiseConstants.MSG_JOB_SCHEDULED));  
             isSuccess = true;    
             return null;
       }
 
       public Boolean doCheckIfViewAvailable(){
            Boolean isViewDeleted = false;
            ApexPages.StandardSetController objStdSetController;
            if(objSync.Is_Created_By_View__c){
                  if(objSync.Contacts__c && objSync.Contact_View__c != NULL){
                        String query = '';
                        if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible()){
                              query = 'SELECT Name FROM Contact LIMIT 1';
                        }
                        //String query = 'SELECT Name FROM Contact LIMIT 1';
                        objStdSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                        List<SelectOption> listOfAvailableView = objStdSetController.getListViewOptions();
                        isViewDeleted = inwiseSchedularNew.doCheckIfViewDeleted(listOfAvailableView, objSync.Contact_View__c);
                  }else if(objSync.Leads__c && objSync.Lead_View__c != NULL){
                        //String query = 'SELECT Name FROM Lead LIMIT 1';
                        String query = '';
                        if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.fields.Name.isAccessible()){
                              query = 'SELECT Name FROM Lead LIMIT 1';
                        }
                        objStdSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                        List<SelectOption> listOfAvailableView = objStdSetController.getListViewOptions();
                        isViewDeleted = inwiseSchedularNew.doCheckIfViewDeleted(listOfAvailableView, objSync.Lead_View__c);
                  }
            }
      
            return !isViewDeleted;
       }
 
       public void deletePreviousJob(){
             if(objSync.Last_JobId__c != NULL){
                   try{
                         System.abortJob(objSync.Last_JobId__c);
                   }catch(Exception ex){
 
                   }
             }
       }
 
       public PageReference doScheduleNow(){
             inwiseGlobalAction.doClearAll(objInwiseUtil.objInwiseSetting.Track_Logs__c);
             List<Sync__c> listOfSync = new List<Sync__c>();
             listOfSync.add(objSync);
             inwiseUtil.WrapperStatus objStatus =inwiseSchedularNew.doSyncMembersBySchedule(listOfSync, objInwiseUtil);
             isSuccess = objStatus.isSuccess;
             if(!objStatus.isSuccess){
                   apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR, objStatus.msg));  
             }
             return null;
       }
 
       public String getJobName(){
             return  'inwise_' + UserInfo.getUserId() + '_' + Datetime.now().getTime();
       }
 
       public String  schedulejob(String jobName, datetime dt){
             String strSchedule = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ?' + ' ' + dt.year(); 
             String cronid = System.schedule(jobName, strSchedule, new inwiseSchedularNew(objSync.Id));
             return cronid;
       }
 
       public PageReference gotoHome(){
             PageReference pr = Page.inwiseHome;
             pr.setRedirect(true);
             return pr;
       } 
 }