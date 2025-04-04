/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 20/01/2020
*Purpose :    Conversation view controller for latest 200 message history
*Modified:   
================================================================
Modified On      Version      Modified By        Purpose  
================================================================
30/08/2022       1.0.0        S. Vaishnav        Modified:- Store status and remark in message history


/******************************************************************************************/
public with sharing class ConversationViewController {

    public Lead objLead 											{get; set;}
    public Id selectedId 											{get; set;}
    public String messageBody										{get; set;}
    public Contact objContact 										{get; set;}
    public List<string> lstFlds 									{get; private set;}
    public List<sObject> lstObjs 									{get; set;}
    public String selectedNumber 									{get; set;}
    public Boolean recentSelected 									{get; set;}
    public String recentHistoryCount								{get; set;}
    public String unReadMessageCount								{get; set;}
    public Map<String, String> messageRecentMap						{get; set;}
    public Map<String, Integer> messageUnreadMap					{get; set;}
    public List<MessageWrapper> messageWrapperList			 		{get; set;}
    public List<Messaging_History__c> ListofMessage					{get; set;}
    public List<Messaging_History__c> ListofMessageAll				{get; set;} 
    public Map<String,List<Messaging_History__c>> messageHistoryMap	{get; set;}
    
    InwiseUtil objInwiseUtil										{get; set;}
    public String csrfToken                                         { get; set; }
    
    public  ConversationViewController(){
        csrfToken = inwiseUtil.generateCSRFToken(); // Generate a unique token
        String RecordId = ApexPages.currentPage().getParameters().get('id');
        messageWrapperList = new List<MessageWrapper>();
        objInwiseUtil = new InwiseUtil(null);
        selectedId = Id.valueOf(RecordId);
        recentSelected = false;
        fetchMessageHistory(selectedId);
    }
    
    public PageReference myClosePopup() {
        PageReference pr;
        if(ApexPages.currentPage().getParameters().get('id') != NULL){
            pr = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
        }
        return pr;
    }

    public void selectedRecord(){
        messageWrapperList.clear();
        if(selectedId != null){
            fetchMessageHistory(selectedId);
        }else{
            fetchMessageHistory(ApexPages.currentPage().getParameters().get('id'));
        }
    }
    
    public void fetchMessageHistory(Id RecordId){

        string query = '';
        messageRecentMap = new Map<String,String>();
        messageUnreadMap = new  Map<String,Integer>();
        messageHistoryMap = new Map<String,List<Messaging_History__c>>();
        String sObjName = RecordId.getSObjectType().getDescribe().getName();
        
        if(sObjName=='Contact'){
            if (Schema.sObjectType.Messaging_History__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Channel_Type__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Contact__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Direction__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Message__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.To_Number__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Read__c.isAccessible() &&
                Schema.sObjectType.Contact.fields.Name.isAccessible()) { // Check for related Contact field permissions 

                ListofMessage = [SELECT Id, Channel_Type__c, Contact__c ,Direction__c,Message__c,To_Number__c,Contact__r.name ,Read__c,createdDate FROM Messaging_History__c WHERE Contact__c =: RecordId AND Message__c != null ORDER BY createdDate LIMIT 200];
            }
            if (Schema.sObjectType.Messaging_History__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Channel_Type__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Contact__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Direction__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Message__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.To_Number__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Read__c.isAccessible() &&
                Schema.sObjectType.Lead.fields.Name.isAccessible() &&
                Schema.sObjectType.Contact.fields.Name.isAccessible()) { // Check for related Contact field permissions 

                ListofMessageAll = [SELECT Channel_Type__c, Contact__c ,Direction__c,Message__c,To_Number__c,Contact__r.name,Lead__c,Lead__r.name,Read__c FROM Messaging_History__c WHERE Contact__c != null AND Message__c != null ORDER BY createdDate ASC LIMIT 200];
            }
            
            recentHistoryCount = 'Contacts ';
        }else{
            if (Schema.sObjectType.Messaging_History__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Id.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Channel_Type__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Direction__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Message__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.To_Number__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Read__c.isAccessible() &&
                Schema.sObjectType.Lead.fields.Name.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Lead__c.isAccessible()) { // Check for related Contact field permissions 

                ListofMessage = [SELECT Id, Channel_Type__c, Lead__c ,Direction__c,Message__c,To_Number__c,Lead__r.name,Read__c,createdDate FROM Messaging_History__c WHERE Lead__c =: RecordId AND Message__c != null ORDER BY createdDate ASC LIMIT 200];
            }
            if (Schema.sObjectType.Messaging_History__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Channel_Type__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Contact__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Direction__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Message__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.To_Number__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Read__c.isAccessible() &&
                Schema.sObjectType.Messaging_History__c.fields.Lead__c.isAccessible() &&
                Schema.sObjectType.Lead.fields.Name.isAccessible() &&
                Schema.sObjectType.Contact.fields.Name.isAccessible()) { // Check for related Contact field permissions 

                ListofMessageAll = [SELECT Channel_Type__c, Contact__c ,Direction__c,Message__c,To_Number__c,Contact__r.name,Lead__c,Lead__r.name,Read__c FROM Messaging_History__c WHERE Lead__c != null AND Message__c != null ORDER BY createdDate ASC LIMIT 200];
            }

            recentHistoryCount = 'Leads ';
        }
        
        for(Messaging_History__c msgobj:ListofMessageAll){
            if(msgobj.Contact__c !=null){
                if(messageHistoryMap.containskey(msgobj.Contact__c)){
                    messageHistoryMap.get(msgobj.Contact__c).add(msgobj);
                } else{
                    messageHistoryMap.put(msgobj.Contact__c, new List<Messaging_History__c>{msgobj});
                }
                messageRecentMap.put(msgobj.Contact__c, msgobj.Contact__r.name);
            }else{
                if(messageHistoryMap.containskey(msgobj.Lead__c)){
                    messageHistoryMap.get(msgobj.Lead__c).add(msgobj);
                } else{
                    messageHistoryMap.put(msgobj.Lead__c, new List<Messaging_History__c>{msgobj});
                }
                messageRecentMap.put(msgobj.Lead__c, msgobj.Lead__r.name);
            }
        }
        
        for(String parentId : messageHistoryMap.keyset()) {
            Integer count = 0;
            for(Messaging_History__c messageHistory : messageHistoryMap.get(parentId)) {
                if(messageHistory.Read__c == false) {
                    count++;
                }
            }
            messageUnreadMap.put(parentId, count);
        }
        
        for(String parentId : messageHistoryMap.keyset()) {
            MessageWrapper msgWrapper = new MessageWrapper();
            msgWrapper.parentId = parentId;
            msgWrapper.parentName = messageRecentMap.get(parentId);
            msgWrapper.unReadMessageCount = messageUnreadMap.get(parentId);
            messageWrapperList.add(msgWrapper);
        }
        recentHistoryCount += '(' + messageHistoryMap.size() + ')';

        if(recentSelected){
            init();  
        }
    }
    
    public void init(){ 
        System.debug('==init=');

        String csrfTokenValue = ApexPages.currentPage().getParameters().get('csrfToken');
        // Validate the CSRF token
        if (csrfTokenValue == null || !inwiseUtil.validateCSRFToken(csrfTokenValue)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid CSRF token. Action cannot be performed.'));
            return;
        }

        List<Messaging_History__c> msgUpdate = new List<Messaging_History__c>();
        for(Messaging_History__c msgobj : ListofMessage){
            if(Schema.sObjectType.Messaging_History__c.fields.Read__c.isAccessible() && Schema.sObjectType.Messaging_History__c.fields.Read__c.isUpdateable() && !msgobj.Read__c){
                msgUpdate.add(new Messaging_History__c(Id = msgobj.Id, Read__c = true));
            }
        }
        
        if(!msgUpdate.isEmpty() && Schema.sObjectType.Messaging_History__c.isUpdateable()){
            update msgUpdate;
        } 
        recentSelected = false;
    }
    
    public void doSendSMS(){
        
        String soql;
        List<Lead> listOfLead;
        List<Contact> listOfContact;
        List<Logs__c> listOfLogs = new List<Logs__c>();
        String sObjName = selectedId.getSObjectType().getDescribe().getName();
        String messageText = Apexpages.currentPage().getParameters().get('theTextInput');
        Webhook_Setting__c objInwiseWebhookSetting = Webhook_Setting__c.getAll().get('default');

        if(sObjName == 'Contact'){
            if (Schema.sObjectType.Contact.isAccessible() &&
                Schema.sObjectType.Contact.fields.FirstName.isAccessible() &&
                Schema.sObjectType.Contact.fields.LastName.isAccessible() &&
                Schema.sObjectType.Contact.fields.getMap().containsKey(objInwiseWebhookSetting.Contact_Field__c) &&
                Schema.sObjectType.Contact.fields.getMap().get(objInwiseWebhookSetting.Contact_Field__c).getDescribe().isAccessible()) {

                soql= 'SELECT FirstName,LastName, ' + objInwiseWebhookSetting.Contact_Field__c + ' FROM CONTACT where Id=\'' + String.valueOf(selectedId) + '\'';
            }
            listOfContact = Database.query(soql);
            objContact = listOfContact.get(0);
            selectedNumber = (String) listOfContact[0].get(objInwiseWebhookSetting.Contact_Field__c);
        }else{
            if (Schema.sObjectType.Lead.isAccessible() &&
                Schema.sObjectType.Lead.fields.FirstName.isAccessible() &&
                Schema.sObjectType.Lead.fields.LastName.isAccessible() &&
                Schema.sObjectType.Lead.fields.getMap().containsKey(objInwiseWebhookSetting.Lead_Field__c) &&
                Schema.sObjectType.Lead.fields.getMap().get(objInwiseWebhookSetting.Lead_Field__c).getDescribe().isAccessible()) {

                soql= 'SELECT FirstName,LastName, ' + objInwiseWebhookSetting.Lead_Field__c + ' FROM Lead where Id=\'' + String.valueOf(selectedId) + '\'';
            }
            listOfLead = Database.query(soql);
            objLead = listOfLead.get(0);
            selectedNumber = (String) listOfLead[0].get(objInwiseWebhookSetting.Lead_Field__c);
        }
        
        if(messageText != null && messageText != ''){
            messageBody = messageText;
        }

        if(messageBody != null && messageBody != ''){
            Map<String, String> responseMap = inwiseHttpUtil.InwiseCalloutSendSMS(objInwiseUtil, messageBody, selectedNumber, listOfLogs, '');
        
            if(!responseMap.isEmpty()){
                String status = responseMap.get('status');
                String statusCode = responseMap.get('statusCode');
                String rejectReason = responseMap.get('rejectReason');
                
                if(objInwiseWebhookSetting != null && String.isNotBlank(statusCode) && statusCode == '200') {
                    if(objInwiseWebhookSetting.Save_To_Activity_History__c && objInwiseWebhookSetting.Save_To_Messaging_History__c){
                        doCreateTask();
                        doCreateMessageHistory(status, rejectReason);
                    }
                    if(objInwiseWebhookSetting.Save_To_Messaging_History__c && !objInwiseWebhookSetting.Save_To_Activity_History__c){
                        doCreateMessageHistory(status, rejectReason);
                    }
                    if(objInwiseWebhookSetting.Save_To_Activity_History__c && !objInwiseWebhookSetting.Save_To_Messaging_History__c) {
                        doCreateTask();
                    }
                }
                fetchMessageHistory(selectedId);
                messageBody = '';
            }
        }
        if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty() && Schema.SObjectType.Logs__c.isCreateable()){
            insert listOfLogs;
        }
    }
    
    public void doCreateTask(){
        String sObjName = selectedId.getSObjectType().getDescribe().getName();
        if(Schema.SObjectType.Task.isCreateable()){
            
            Task objTask = new task();
            if(sObjName == 'Contact'){
                if(Schema.sObjectType.Task.fields.WhoId.isCreateable()){
                    objTask.WhoId = objContact.Id;
                }
                if(Schema.sObjectType.Task.fields.Description.isCreateable()){
                    objTask.description = 'SMS has been to ' + objContact.FirstName + ' ' + objContact.LastName + '\n';
                }
            }else{
                if(Schema.sObjectType.Task.fields.WhoId.isCreateable()){
                    objTask.WhoId = objLead.Id;
                }
                if(Schema.sObjectType.Task.fields.Description.isCreateable()){
                    objTask.description = 'SMS has been to ' + objLead.FirstName + ' ' + objLead.LastName + '\n';
                }
            }
            
            if(Schema.sObjectType.Task.fields.Subject.isCreateable()){
                objTask.Subject = 'inwise SMS';
            }
            if(Schema.sObjectType.Task.fields.Priority.isCreateable()){
                objTask.priority = 'Normal';
            }
            if(Schema.sObjectType.Task.fields.Status.isCreateable()){
                objTask.status = 'Completed';
            }
            
            objTask.description += 'Number : ' + selectedNumber + '\n';
            objTask.description += 'SMS Body : ' + messageBody;
            insert objTask;
        }
    }
    
    public void doCreateMessageHistory(String status, String remark){

        String sObjName = selectedId.getSObjectType().getDescribe().getName();
        if(Schema.SObjectType.Messaging_History__c.isCreateable()){

            Messaging_History__c objMsgHistory = new Messaging_History__c();
            if(sObjName == 'Contact'){
                if(Schema.sObjectType.Messaging_History__c.fields.Contact__c.isCreateable()){
                    objMsgHistory.Contact__c = objContact.Id;
                }
                if(Schema.sObjectType.Messaging_History__c.fields.Description__c.isCreateable()){
                    objMsgHistory.Description__c = 'SMS has been to ' + objContact.FirstName + ' ' + objContact.LastName + '\n';
                }
            }else{
                if(Schema.sObjectType.Messaging_History__c.fields.Lead__c.isCreateable()){
                    objMsgHistory.Lead__c = objLead.Id;
                }
                if(Schema.sObjectType.Messaging_History__c.fields.Description__c.isCreateable()){
                    objMsgHistory.Description__c = 'SMS has been to ' + objLead.FirstName + ' ' + objLead.LastName + '\n';
                }
            }
            
            if(Schema.sObjectType.Messaging_History__c.fields.Direction__c.isCreateable()){
                objMsgHistory.Direction__c = 'Outgoing';
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Message__c.isCreateable()){
                objMsgHistory.Message__c = messageBody;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.To_Number__c.isCreateable()){
                objMsgHistory.To_Number__c = selectedNumber;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Channel_Type__c.isCreateable()){
                objMsgHistory.Channel_Type__c = 'SMS';
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Read__c.isCreateable()){
                objMsgHistory.Read__c = true;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Status__c.isCreateable()){
                objMsgHistory.Status__c = status;
            }
            if(Schema.sObjectType.Messaging_History__c.fields.Remark__c.isCreateable()){
                objMsgHistory.Remark__c = remark;
            }

            objMsgHistory.Description__c += 'Number : ' + selectedNumber + '\n';
            objMsgHistory.Description__c += 'SMS Body : ' + messageBody;
            insert objMsgHistory;
        }
    }

    @AuraEnabled
    public static boolean getuserLicence(){
        Boolean isLicence = false;
        try{
            if(UserInfo.isCurrentUserLicensed('inwise__')){
                isLicence =true;
            }
            return isLicence;   
        }catch(exception ex){
              return isLicence; 
        }
    }
    
    public class MessageWrapper{
        public string parentId 				{get; set;}
        public string parentName 			{get; set;}
        public Integer unReadMessageCount	{get; set;}
    }      
}