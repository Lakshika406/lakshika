/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
/******************************************************************************************/
public with sharing class SendToInwiseControllerltng{
    @AuraEnabled  
    public Static String getMsg(Id recId,String actionType){
        Campaign objCampaign = new Campaign();
        if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.fields.Account__c.isAccessible() && 
            Schema.sObjectType.Campaign.fields.Sendid__c.isAccessible() && Schema.sObjectType.Campaign.fields.name.isAccessible()){

            List<Campaign> listOfCampaign = [Select Id,name,Account__c,Sendid__c from Campaign where Id=:recId];
            if(listOfCampaign != NULL && !listOfCampaign.isEmpty()){
                objCampaign = listOfCampaign.get(0);
            }
        }    
        ApexPages.StandardController sc = new ApexPages.StandardController(objCampaign);        
         SendToInwiseController objSendToInwiseController = new SendToInwiseController(sc);
        if(actionType == 'InwiseMembersActions'){
            objSendToInwiseController.OnLoad(objCampaign.Id, 'InwiseStatistics');
        }
        objSendToInwiseController.OnLoad(objCampaign.Id, actionType);

        objSendToInwiseController.OnLoad(recId,actionType);
        return objSendToInwiseController.ErrorMsg;
    }
}