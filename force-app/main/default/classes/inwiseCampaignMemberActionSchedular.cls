/***********************************************************************
CLASS NOT IN USE - 26 NOV 2017, NEW CLASS CREATED FOR THIS FUNCTIONALITY 
***********************************************************************/
//campaign button action "Get members actions from inwise" called every hour
global  with sharing class inwiseCampaignMemberActionSchedular implements  Schedulable,Database.AllowsCallouts {
      public inwiseCampaignMemberActionSchedular(){

      } 
      global void execute(SchedulableContext ctx) {
          //callMemberActionCallout();
      }
      //@Future(callout=true)
      //public static void callMemberActionCallout(){
      //      SendToInwiseController objSendToInwiseController = new SendToInwiseController(true,null);
      //     objSendToInwiseController.InwiseCalloutLogon(true);  
      //}
 
      //public static String  schedulejob(){
      //    String jobName = 'inwiseGetAction' + Datetime.now().getTime();
      //    Datetime dtnow = Datetime.now();
      //    Datetime previousHour = dtnow.addMinutes(-dtnow.minute()).addSeconds(-dtnow.second());
      //    datetime dt = previousHour.addHours(1);
      //    //datetime dt = previousHour.addMinutes(10);
      //    String strSchedule = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ?' + ' ' + dt.year(); 
      //    String cronid = System.schedule(jobName, strSchedule, new inwiseCampaignMemberActionSchedular());

      //    Settings__c objInwiseSetting = Settings__c.getAll().get('default');
      //    //System.debug('objInwiseSetting::-->>>' + objInwiseSetting);
      //    if(!String.isEmpty(objInwiseSetting.Campaign_Member_Action_Job_Id__c)){
      //        try{
      //                System.abortJob(objInwiseSetting.Campaign_Member_Action_Job_Id__c);
      //          }catch(Exception ex){
      //                System.debug('abort failed::-->>>' + ex.getMessage());
      //          }
      //    }
      //    if(Schema.SObjectType.Settings__c.isUpdateable()){
      //    objInwiseSetting.Campaign_Member_Action_Job_Id__c = cronid;
      //    update objInwiseSetting;
      //  }
      //    System.debug('objInwiseSetting updated::-->>>' + objInwiseSetting);
      //    return cronid;
      //}
}