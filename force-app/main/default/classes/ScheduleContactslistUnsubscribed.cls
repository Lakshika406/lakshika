/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 05/20/2018
*Purpose :  for https://api.inwise.com/rest/v1/docs/index#!/contacts/contacts_listUnsubscribed  api

Modification Log
----------------
Date                  Version     Developer                  Comments
------------------------------------------------------------------------------------
05/20/2018          1.0.0       K.Goutam                 Created
07/29/2018          1.1.0       K.Goutam                 Modified:- class code moved to Batch class (BatchCalloutUnsubscribe) after BPM issue
                                                         Remark (Boaz) - but we still use it in some other places like in unsubscribe job
/******************************************************************************************/
global  with sharing class ScheduleContactslistUnsubscribed implements  Schedulable,Database.AllowsCallouts {
    String channelType {get;set;}
    public static String sChanelTypeEmail{get;set;}
    public static String sChanelTypeSMS{get;set;}
    static{
        sChanelTypeEmail = 'email';
        sChanelTypeSMS = 'sms';
    }
    global void execute(SchedulableContext ctx) {
        doCalloutUnsubscribeBatch(channelType);
    }
    public ScheduleContactslistUnsubscribed(){}

    public void init(String chtype){
        channelType = chtype;
    }
    public static void doCalloutUnsubscribeBatch(String channelType){
        BatchCalloutUnsubscribe objBatchCalloutUnsubscribe = new BatchCalloutUnsubscribe ();
        objBatchCalloutUnsubscribe.init(channelType,1,true,null,null);
        Database.executeBatch(objBatchCalloutUnsubscribe,1);
    }
    public static String  doScheduleJob(String channelType){
        String jobName = 'listUnsubscribed' + Datetime.now().getTime();
        Datetime dtnow = Datetime.now();
        Datetime previousHour = dtnow.addMinutes(-dtnow.minute()).addSeconds(-dtnow.second());
        datetime dt = previousHour.addHours(1);
        //datetime dt = dtnow.addMinutes(5);//TODO -- added for testing
        String strSchedule = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ?' + ' ' + dt.year();
        ScheduleContactslistUnsubscribed objScheduleContactslistUnsubscribed = new ScheduleContactslistUnsubscribed();
        objScheduleContactslistUnsubscribed.init(channelType);
        String cronid = System.schedule(jobName, strSchedule, objScheduleContactslistUnsubscribed);

        Settings__c objInwiseSetting = Settings__c.getAll().get('default');
        String previousJobId;
        if(channelType == sChanelTypeEmail){
            previousJobId = objInwiseSetting.Opt_in_Out_to_Salesforce_Email_Job_Id__c;
        }else if(channelType == sChanelTypeSMS){
            previousJobId = objInwiseSetting.Opt_in_Out_to_Salesforce_Mobile_Job_Id__c;
        }
        System.debug('previousJobId::-->>>' + previousJobId);
        if(!String.isEmpty(previousJobId)){
            try{
                System.abortJob(previousJobId);
            }catch(Exception ex){
                System.debug('abort failed::-->>>' + ex.getMessage());
            }
        }
        if(Schema.SObjectType.Settings__c.isUpdateable()){
            if(channelType == sChanelTypeEmail){
                if(Schema.sObjectType.Settings__c.fields.Opt_in_Out_to_Salesforce_Email_Job_Id__c.isUpdateable()){
                    objInwiseSetting.Opt_in_Out_to_Salesforce_Email_Job_Id__c = cronid;
                }
            }else if(channelType == sChanelTypeSMS){
                if(Schema.sObjectType.Settings__c.fields.Opt_in_Out_to_Salesforce_Mobile_Job_Id__c.isUpdateable()){
                    objInwiseSetting.Opt_in_Out_to_Salesforce_Mobile_Job_Id__c = cronid;
                }
            }
            update objInwiseSetting;
        }

        return cronid;
    }
}