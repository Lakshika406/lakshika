/******************************************************************************************
* Created By	: 	NlineAxis
* Created On	: 	22 Aug 2022
* Purpose 		:   Batch class to delete inwise automation
/******************************************************************************************
Modification Log
----------------
Date              Version   Developer                  Comments
------------------------------------------------------------------------------------
08/22/2022        1.0.0     Shyam Vaishnav             Created
/***********************************************************************************/
global class BatchDeleteInwiseAutomation implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{

    List<String> automationIdList = new List<String>();
    Map<String, String> automationMap = new Map<String, String>();

    public BatchDeleteInwiseAutomation(Map<String, String> automationIdMap){
        automationMap = automationIdMap;
        automationIdList.addAll(automationIdMap.keySet());
    }

    global Iterable<String> start(Database.BatchableContext info){
        return new BatchIterable(automationIdList);
    }

    global void execute(Database.BatchableContext info, List<String> scope){

        if(!scope.isEmpty() && !automationMap.isEmpty() && automationMap.containsKey(scope[0]) && String.isNotBlank(automationMap.get(scope[0]))){
			System.debug(automationMap.get(scope[0]));
            if(Schema.sObjectType.Account__c.isAccessible()){
                Account__c acc = [Select Id From Account__c where Id =: automationMap.get(scope[0]) LIMIT 1];
                    
                if(acc != null){
                    HttpResponse res;
                    Http http = new Http();
                    inwiseUtil util = new inwiseUtil(acc);
                    List<Logs__c> listOfLogs = new List<Logs__c>();
                    
                    HttpRequest req = util.GetHTTPRequest('DELETE', 'application/json', util.apiUrl + '/rest/v1/automations/delete?automationId=' + scope[0]);
                    req.setHeader('X-Api-Key', util.inwiseAccountToken);
                    
                    if(!Test.isRunningTest()){
                        res = http.send(req);
                        listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res, '/rest/v1/automations/delete?automationId=' + scope[0], 'BatchDeleteInwiseAutomation', 'delete inwise automation'));        
                    }else{
                        res = new HttpResponse();
                        res.setStatus('OK');
                        res.setStatusCode(200);
                        res.setHeader('Content-Type', 'application/json');
                    }
                    
                    System.debug('res.getStatusCode()::-->>' + res.getStatusCode());
                    if(res.getStatusCode() == 200 && res.getBody() != NULL){ 
                        String jsonString = res.getBody();
                        System.debug('Response body::-->>  ' + jsonString);
                    }
                    
                    if(util.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                        insert listOfLogs;
                    }
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC){}
}