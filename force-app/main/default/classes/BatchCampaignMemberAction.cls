/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 21 Nov 2017
*Purpose :    Get member action in batch
* ----------------------------------------------------------------
Date            By                          Detail
----------------------------------------------------------------
03/09/2019     NLINEAXIS(Kapil Goutam)     Modified:-commented all code in this class because of 50000 campaign member sync was creating issue
                                            when "Get member action from inwise" clicked. New solution is built with Step1, Step2 & Step3 classes.
/******************************************************************************************/
global with sharing class BatchCampaignMemberAction implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{ 
    
    List<Logs__c> listOfLogs                {get;set;}
    InwiseUtil objInwiseUtil                {get;set;}
    Account__c objInwiseAccount             {get;set;}
    public boolean isNeedToScheduleNextHour {get;set;}

    // BatchCampaignMemberAction objBatchCampaignMemberAction = new BatchCampaignMemberAction ();
    // Database.executeBatch(objBatchCampaignMemberAction,1);

    public void BatchCampaignMemberAction(){}

    public void init(Boolean isNeedToReschedule){
        listOfLogs = new List<Logs__c>();
        objInwiseUtil = new InwiseUtil(null);
        isNeedToScheduleNextHour = isNeedToReschedule;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        // Check if the Campaign has access to the Campaign object and the required fields
        if (Schema.sObjectType.Campaign.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Id.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Account__c.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Sendid__c.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Campaign_Type__c.isAccessible() &&
            Schema.sObjectType.Campaign.fields.Name.isAccessible()) {

            // Return the query locator
            return Database.getQueryLocator([
                SELECT Id,Name,Account__c,Sendid__c,Campaign_Type__c FROM Campaign where (Campaign_Type__c = 'Email' Or Campaign_Type__c = 'Mobile') AND Sendid__c != NULL AND CreatedDate = LAST_N_DAYS:30 WITH SECURITY_ENFORCED
            ]);
        } else {
            // Log or handle insufficient permissions
            System.debug('User does not have sufficient permissions to access the Campaign object or the required fields.');
            // Return an empty query locator as a fallback
            return Database.getQueryLocator('SELECT Id FROM Campaign WHERE Id = NULL');
        }

      	//return Database.getQueryLocator([SELECT Id,Name,Account__c,Sendid__c,Campaign_Type__c FROM Campaign where (Campaign_Type__c = 'Email' Or Campaign_Type__c = 'Mobile') AND Sendid__c != NULL AND CreatedDate = LAST_N_DAYS:30 WITH SECURITY_ENFORCED]);    
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        System.debug('=scope='+scope);
        /*List<Campaign> listOfCampaign =  (List<Campaign>) scope;
        Datetime dtNowUTC = Datetime.newInstance(Datetime.now().dateGmt(), Datetime.now().timeGmt());
        System.debug('listOfCampaign.Size()::-->>' + listOfCampaign.size() + '>>>>>' + listOfCampaign);
        Map<Id, CampaignMember> mapOfCampaignMemberToUpdate = new Map<Id, CampaignMember>();
        for(Campaign camp: listOfCampaign){
            System.debug('camp execute::-->>>>' + camp);
            SendToInwiseController objSendToInwiseController = new SendToInwiseController(true,camp.Account__c);
            system.debug('accoutis---->>' +objSendToInwiseController);
            objSendToInwiseController.objCampaign = camp;
            mapOfCampaignMemberToUpdate.putAll(objSendToInwiseController.mapOfCampaignMemberToUpdate);
        }
        System.debug('update all map Member:::-->>' + mapOfCampaignMemberToUpdate);
        if(!mapOfCampaignMemberToUpdate.isEmpty()){
            update mapOfCampaignMemberToUpdate.values();
        }*/
    }
    
    global void finish(Database.BatchableContext BC){
        /*inwiseGlobalAction.doClearAll(objInwiseUtil.objInwiseSetting.Track_Logs__c);
        System.debug('objInwiseUtil::-->>>' + objInwiseUtil);
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
            insert listOfLogs;
        }

        Datetime dtNow = Datetime.newInstance(Datetime.now().dateGmt(), Datetime.now().timeGmt());
        Settings__c objInwiseSetting = new Settings__c(Id=objInwiseUtil.objInwiseSetting.Id);
        if(Schema.sObjectType.Settings__c.fields.Campaign_Member_Action_Last_Run_On__c.isUpdateable()){
            objInwiseSetting.Campaign_Member_Action_Last_Run_On__c = dtNow;
        }
        if(Schema.sObjectType.Settings__c.isUpdateable()){
            update objInwiseSetting;
        }
        System.debug('isNeedToScheduleNextHour::-->>>' + isNeedToScheduleNextHour);
        if(isNeedToScheduleNextHour){
            //inwiseCampaignMemberActionSchedularV2.schedulejob(Datetime.now().addMinutes(5)); //@TODO- remove this, only added for testing
            inwiseCampaignMemberActionSchedularV2.schedulejob(null);
        }*/
    }
}