/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 14 Dec 2016
*Purpose :     class to schedule the landing sync job
/******************************************************************************************/
public with sharing class inwiseLandingSyncScheduleJobController {
  /********************************************************************************************************************************************************************************
     Page is NOT in use because individual schedule functionality do not work now for LANDING SYNC ------As per input by Boaz - 17 Aug 2017 ---
     Only One method is in use "getCronExpression"
     ********************************************************************************************************************************************************************************
     public Landing_Sync__c objSync {get;set;}
     public Boolean isSuccess {get;set;}
     public inwiseLtngConstants objinwiseLtngConstants{get;set;}
     public inwiseLandingSyncScheduleJobController() {
          objinwiseLtngConstants = new inwiseLtngConstants();
          Id syncid = ApexPages.CurrentPage().getParameters().get('Id');
           List<Landing_Sync__c> listOfSync = [Select Id,Name,Landing_Page_Name__c,Scheduled_Daily_At__c,Last_JobId__c from Landing_Sync__c where Id=:syncid];
           if(!listOfSync.isEmpty()){
                   objSync = listOfSync.get(0);
                   
           }
           isSuccess = false;
      }
      public PageReference doSchedule(){
            isSuccess = false;
            if(objSync.Scheduled_Daily_At__c == NULL){
                  apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR,inwiseConstants.MSG_JOB_SCHEDULED_TIME_MISSING));
                  return null;
            }
            deletePreviousJob();
            String chString = getCronExpression(objSync.Scheduled_Daily_At__c);
            String jobName =getJobName();
            String cronid = System.schedule(jobName, chString, new inwiseLandingSyncSchedular(objSync.Id));
            if(Schema.sObjectType.Landing_Sync__c.isUpdateable()){
                if(Schema.sObjectType.Landing_Sync__c.fields.Last_JobId__c.isUpdateable()){
                        objSync.Last_JobId__c = cronid;
                }   
                if(Schema.sObjectType.Landing_Sync__c.fields.Last_JobName__c.isUpdateable()){     
                        objSync.Last_JobName__c = jobName;
                 }       
                update objSync;
             }   
            apexpages.addmessage(new apexpages.message(apexpages.severity.INFO,inwiseConstants.MSG_JOB_SCHEDULED));  
            isSuccess = true;    
            return null;
      }
      */
      public static String getCronExpressionTemp(String selectedtime){
          Datetime dt = Datetime.now().addMinutes(3);
          String strSchedule = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ?' + ' ' + dt.year(); 
          return strSchedule;
      }
      public static String getCronExpression(String selectedtime){
            Integer chhour = 0;
            List<String> listOStringTime = selectedtime.split(' ');
            if(!listOStringTime.isEmpty()){
                  String t1 = listOStringTime.get(0); //12:00
                  String t2 = listOStringTime.get(1); //AM
                  t1 = t1.replace(':00','');
                  if(t2 == 'AM'){
                        if(t1 == '12'){
                              chhour = 0;
                        }else{
                            chhour = Integer.valueOf(t1);
                        }
                  }else if(t2 == 'PM'){
                        if(t1 == '12'){
                              chhour = Integer.valueOf(t1);
                          }else{
                              chhour = Integer.valueOf(t1) + 12;    
                          }
                        
                  }
            }
            String chString = '0 0 '+ chhour +' 1/1 * ? *';
            System.debug('time is--->>' +listOStringTime);
            return chString;
      }
      /*
      public void deletePreviousJob(){
           if(objSync.Last_JobId__c != NULL){
                try{
                    System.abortJob(objSync.Last_JobId__c);
                }catch(Exception ex){

                }

          }
      }
      public PageReference doScheduleNow(){
            isSuccess = false;
            List<Landing_Sync__c> listOfSync = inwiseLandingSyncSchedular.getSyncRecord(objSync.Id);
            inwiseLandingSyncSchedular.InwiseCalloutLandingSync(listOfSync);
            apexpages.addmessage(new apexpages.message(apexpages.severity.INFO,inwiseConstants.MSG_JOB_INPROGRESS));  
            isSuccess = true;    
            return null;
      }
       public String getJobName(){
          return  'inwise_'+UserInfo.getUserId()+'_' + Datetime.now().getTime();
      }
      public String  schedulejob(String jobName,datetime dt){
          String strSchedule = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ?' + ' ' + dt.year(); 
          String cronid = System.schedule(jobName, strSchedule, new inwiseLandingSyncSchedular(objSync.Id));
          return cronid;
      }
       public PageReference gotoHome(){
          PageReference pr = Page.inwiseHome;
          pr.setRedirect(true);
          return pr;
      
     } 
     */
}