/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 26 Nov 2017
*Purpose :    created new class because package was not allowing to remove callout interface implementation
* Modification Log
----------------
Date                  Version     Developer                Comments
------------------------------------------------------------------------------------
09/11/2019            1.1.0       K.Goutam                 Modified:- Code was commented in constructor & because of that job was  not executing on client org.
                                                                      Uncommented that code & added null value for updated method.

/******************************************************************************************/
//campaign button action "Get members actions from inwise" called every hour
global with  sharing class inwiseCampaignMemberActionSchedularV2 implements  Schedulable {
      public inwiseCampaignMemberActionSchedularV2(){

      } 
      global void execute(SchedulableContext ctx) {
          callMemberActionCallout();
      }
      public static void callMemberActionCallout(){
            SendToInwiseController objSendToInwiseController = new SendToInwiseController(true,null);
            objSendToInwiseController.doClickMemberAction(true,null);
      }
 
      public static String  schedulejob(Datetime nextScheduleTime){
          datetime dt;
          String jobName = 'inwiseGetAction' + Datetime.now().getTime();
          if(nextScheduleTime == NULL){
              Datetime dtnow = Datetime.now();
              Datetime previousHour = dtnow.addMinutes(-dtnow.minute()).addSeconds(-dtnow.second());
              dt = previousHour.addHours(1);
             // dt = dtnow.addMinutes(5);//@todo remove temp code
          }else{
              dt = nextScheduleTime;
          }
          String strSchedule = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ?' + ' ' + dt.year(); 
          inwiseCampaignMemberActionSchedularV2 objinwiseCampaignMemberActionSchedularV2 = new inwiseCampaignMemberActionSchedularV2();
          String cronid = System.schedule(jobName, strSchedule,objinwiseCampaignMemberActionSchedularV2);
          

          Settings__c objInwiseSetting = Settings__c.getAll().get('default');
          //System.debug('objInwiseSetting::-->>>' + objInwiseSetting);
          if(!String.isEmpty(objInwiseSetting.Campaign_Member_Action_Job_Id__c)){
              try{
                      System.abortJob(objInwiseSetting.Campaign_Member_Action_Job_Id__c);
                }catch(Exception ex){
                      System.debug('abort failed::-->>>' + ex.getMessage());
                }
          }
          if(Schema.SObjectType.Settings__c.fields.Campaign_Member_Action_Job_Id__c.isUpdateable()){
              objInwiseSetting.Campaign_Member_Action_Job_Id__c = cronid;
              update objInwiseSetting;
          }
          //System.debug('objInwiseSetting updated::-->>>' + objInwiseSetting.Campaign_Member_Action_Job_Id__c);
          return cronid;
      }
}