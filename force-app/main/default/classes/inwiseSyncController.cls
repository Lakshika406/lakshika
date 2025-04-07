/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Class to show mapping & save
/******************************************************************************************/
public with sharing class inwiseSyncController {
    public List<wrapperClass> listOfWrapperClass {get;set;}
    public List<SelectOption> listOfSelectOptionFields_Contact {get;set;}
    public List<SelectOption> listOfSelectOptionFields_Lead {get;set;}
    public Account__c objInwiseAccount{get;set;} 
    map<string,Mapping__c> objInvMapping{get;set;}
    public boolean IsNeedToBlock {get;set;}
    public inwiseLtngConstants objinwiseLtngConstants{get;set;}
    public boolean isHelpOnload {get;set;}
    public String csrfToken { get; set; }
    //don't need this code - Commented on 26 Feb 2018
    //public String fieldSalesForceCampaignMemberID{get{
    //       return InwiseConstants.INWISE_FIELD_SALESFORCECAMPAIGNMEMBERID; 
    //}} 
    public inwiseUtil objInwiseUtil{get;set;}
    
    public inwiseSyncController(ApexPages.StandardController controller){
        csrfToken = inwiseUtil.generateCSRFToken(); // Generate a unique token
        listOfWrapperClass = new List<wrapperClass>();
        objinwiseLtngConstants = new inwiseLtngConstants();
        objInwiseAccount = new Account__c();
        if(ApexPages.CurrentPage().getParameters().get('aid') != NULL){
            if(Schema.sObjectType.Account__c.isAccessible() && Schema.sObjectType.Account__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Account__c.fields.Token__c.isAccessible() ){

                objInwiseAccount =[Select Id,Name,Token__c from  Account__c where Id =:ApexPages.CurrentPage().getParameters().get('aid') WITH SECURITY_ENFORCED];
            }        
        } 
        IsNeedToBlock = false;
        objInwiseUtil=new inwiseUtil(objInwiseAccount); 
        listOfSelectOptionFields_Lead = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_LEAD,inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL,true);
        listOfSelectOptionFields_Contact = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_CONTACT,inwiseScheduleSyncObject.setOfAcceptableTypeForSOQL,true);
    }
    
    public void InitializeWrapperClass(){

        String csrfTokenValue = ApexPages.currentPage().getParameters().get('csrfToken');

        // Validate the CSRF token
        if (csrfTokenValue == null || !inwiseUtil.validateCSRFToken(csrfTokenValue)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid CSRF token. Action cannot be performed.'));
            return;
        }
        
        List<Logs__c> listOfLogs = new List<Logs__c>();
        listOfWrapperClass = new List<wrapperClass>();
        Map<Integer,boolean> mapOfFieldMappingUsed = new Map<Integer,boolean>();//map which will store which field is used from 1 to 20 so we can use merge new field for SalesForce Camp Member ID field   
        List<SelectOption> listOfInwiseFields = objInwiseUtil.GetInwiseFields(listOfLogs);
        if(objInwiseUtil.Error_Messages.size() > 0){
            for(string msg:objInwiseUtil.Error_Messages){
                apexpages.addmessage(new apexpages.message(apexpages.severity.info,msg));
                return;
            }
        }
        LoadPreviousMappings();
     
        if(!listOfInwiseFields.isEmpty()){
            wrapperClass wc=null;
                for(SelectOption s:listOfInwiseFields){
                    wc = new wrapperClass();
                    wc.inwiseField = s.getlabel();
                    wc.inwiseFieldId = s.getvalue();
                    string contactKey=wc.inwiseFieldId + ':' + InwiseConstants.SOBJECT_CONTACT;
                    string LeadKey=wc.inwiseFieldId + ':' + InwiseConstants.SOBJECT_LEAD;
                    //string personaccountKey = wc.inwiseFieldId + ':' + InwiseConstants.SOBJECT_PERSONACCOUNT;
                    
                    Mapping__c objMap=null;
                    if(Schema.sObjectType.Mapping__c.isCreateable() && Schema.sObjectType.Mapping__c.isUpdateable()){
                            if(objInvMapping.containsKey(contactKey)){
                                objMap = objInvMapping.get(contactKey);
                            }else{
                                objMap = CreateNewMappingInstance(wc,InwiseConstants.SOBJECT_CONTACT,listOfSelectOptionFields_Contact.get(0).getValue());
                                
                            }
                            wc.ContactInfo=objMap;
                     }       
                    
                    
                    objMap=null;
                    if(Schema.sObjectType.Mapping__c.isCreateable() && Schema.sObjectType.Mapping__c.isUpdateable()){
                            if(objInvMapping.containsKey(LeadKey)){
                                objMap = objInvMapping.get(LeadKey);
                            }else{
                                objMap = CreateNewMappingInstance(wc,InwiseConstants.SOBJECT_LEAD,listOfSelectOptionFields_Lead.get(0).getValue());
                            }               
                            wc.LeadInfo=objMap;
                     }       
                    //=== check for field, if field is not in list then do not allow him to save 
                    //if(IsNeedToBlock && wc.inwiseField == InwiseConstants.INWISE_FIELD_SALESFORCECAMPAIGNMEMBERID){
                    //        IsNeedToBlock = false;
                    //        //do not add wc in this case because don't want to show on page/ui
                    //}
                    //checke which field is used
                    if(wc.inwiseFieldId != NULL && Integer.valueOf(wc.inwiseFieldId) >= 1 && Integer.valueOf(wc.inwiseFieldId) <= 20){
                         mapOfFieldMappingUsed.put(Integer.valueOf(wc.inwiseFieldId),true);   
                    }
                    listOfWrapperClass.add(wc);    
                    
                    
                    
                }
            } 
            //if(IsNeedToBlock){
            //        //Integer blankField = NULL;
            //        //for(Integer i=1; i<=20; i++){
            //        //       if(mapOfFieldMappingUsed.get(i) == NULL){
            //        //            blankField = i;
            //        //            break;
            //        //       } 
            //        //}
            //        ////System.debug('blankField:--->>>' + blankField);
            //        //boolean isSuccsss = createSalesForceCampMemberIDFieldAtinwise(blankField, listOfLogs);
            //        //if(isSuccsss){
            //        //          InitializeWrapperClass();  
            //        //}else{
            //        //      //apexpages.addmessage(new apexpages.message(apexpages.severity.info, InwiseConstants.INWISE_MISSING_FIELD_SALESFORCECAMPAIGNMEMBERID));  
            //        //}
                    
            //}
            if(!listOfWrapperClass.isEmpty()){
                listOfWrapperClass = doDefaultMapping(listOfWrapperClass);
            }
            System.debug('listOfWrapperClass::-->>>' + listOfWrapperClass);
                if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
                    if(Logs__c.SObjectType.getDescribe().isCreateable()){
                        insert listOfLogs;
                }
            }            
    }
    //for default mapping on load
    public List<wrapperClass> doDefaultMapping(List<wrapperClass> listOfWrapperClass){
         Map<String,String> mapOfDefaultMappingContact = new Map<String,String>{'email' =>'Email' , 'mobile' => 'MobilePhone' , 'phone - home' => 'HomePhone', 'last name' => 'LastName' , 'city' => 'MailingCity', 'zip' => 'MailingPostalCode', 'fname' => 'FirstName', 'lname' => 'LastName', 'gender' =>'Title' };
         Map<String,String> mapOfDefaultMappingLead = new Map<String,String>{'email' =>'Email' , 'mobile' => 'MobilePhone' ,  'phone - home' => 'Phone' , 'last name' => 'LastName', 'city' => 'City', 'zip'=>'PostalCode', 'fname' => 'FirstName', 'lname' => 'LastName', 'gender' =>'Title'};
        for(wrapperClass wc: listOfWrapperClass){
                if(wc.inwiseField != NULL){
                        if(wc.ContactInfo != NULL && wc.ContactInfo.Id == NULL && wc.ContactInfo.Salesforce_Field__c != NULL){
                                if(mapOfDefaultMappingContact.get(wc.inwiseField.tolowercase())  != NULL){
                                        wc.ContactInfo.Salesforce_Field__c = mapOfDefaultMappingContact.get(wc.inwiseField.tolowercase());
                                }
                        }
                        if(wc.LeadInfo != NULL && wc.LeadInfo.Id == NULL && wc.LeadInfo.Salesforce_Field__c != NULL){
                                if(mapOfDefaultMappingLead.get(wc.inwiseField.tolowercase())  != NULL){
                                        wc.LeadInfo.Salesforce_Field__c = mapOfDefaultMappingLead.get(wc.inwiseField.tolowercase());
                                }
                        }
                }
        }
        return listOfWrapperClass;
    }
    //add SalesForce Camp Member ID field at inwise
    public boolean createSalesForceCampMemberIDFieldAtinwise(Integer blankField,List<Logs__c> listOfLogs){
        boolean isSuccsss = false;
        Http http =  new Http();
        HttpResponse res;
        String endpoint = objInwiseUtil.apiUrl + '/rest/v1/contacts/mergeFields';
        HttpRequest req =objInwiseUtil.GetHTTPRequest('POST','application/json',endpoint); 
        //String reqBody = '[' +
           String reqBody = '{' +
                                       ' "api_key":"  ' +  objInwiseUtil.inwiseAccountToken +' ",' + 
                                       ' "id": ' + blankField +',' +
                                        ' "description": ' +  ' "SalesForce Camp Member ID", ' +
                                        ' "slicing": false, ' +
                                        '   "options": [ ' +
                                                    '   "string" ' +
                                            '] ' +
                                    '}';
        req.setBody(reqBody);
        if(!Test.isRunningTest()){
             res = http.send(req);
             listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'/rest/v1/contacts/mergeFields','inwiseSyncController','createSalesForceCampMemberIDFieldAtinwise'));
        }else{
           res = new HttpResponse();
           res.setHeader('Content-Type', 'application/json');
           String resBody = '[   {     "id": 1,     "description": "first name",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 220,     "description": "xml1",     "slicing": false,     "type": "generic",     "options": null   },   {     "id": 240,     "description": "boaz xml",     "slicing": false,     "type": "generic",     "options": null   },   {     "id": 10,     "description": "מספר פקס",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 8,     "description": "טלפון נוסף",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 4,     "description": "קוד",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 21,     "description": "Birthday",     "slicing": false,     "type": "date",     "options": null   },   {     "id": 3,     "description": "SalesForce Camp Member ID",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 2,     "description": "last name",     "slicing": false,     "type": "text",     "options": null   },   {     "id": 6,     "description": "עיר",     "slicing": false,     "type": "text",     "options": null   } ]';
           res.setBody(resBody);
           res.setStatusCode(200);
           res.setStatus('OK');            
        }
        if(res.getStatusCode() == 200  && res.getBody() != NULL){ 
                isSuccsss = true; 
        }
        System.debug('isSuccsss::-->>' + isSuccsss +'>>>' + res.getStatusCode());  
        return isSuccsss;
    }
    
    private Mapping__c CreateNewMappingInstance(wrapperClass wc,string objectType,string salesforceField){
         Mapping__c mapping= new Mapping__c();
         if(Schema.sObjectType.Mapping__c.fields.Account__c.isCreateable() && Schema.sObjectType.Mapping__c.fields.Account__c.isUpdateable()){
                mapping.Account__c = objInwiseAccount.Id;
         }
         if(Schema.sObjectType.Mapping__c.fields.Inwise_Field__c.isCreateable() && Schema.sObjectType.Mapping__c.fields.Inwise_Field__c.isUpdateable()){
                mapping.Inwise_Field__c = wc.inwiseField;
         }
         if(Schema.sObjectType.Mapping__c.fields.Inwise_FieldId__c.isCreateable() && Schema.sObjectType.Mapping__c.fields.Inwise_FieldId__c.isUpdateable()){
                mapping.Inwise_FieldId__c = wc.inwiseFieldId;
          }
         if(Schema.sObjectType.Mapping__c.fields.Object_Type__c.isCreateable() && Schema.sObjectType.Mapping__c.fields.Object_Type__c.isUpdateable()){
                mapping.Object_Type__c = objectType;
         }
         if(Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isCreateable() && Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isUpdateable()){
                mapping.Salesforce_Field__c = salesforceField;
         }
         
         return mapping;     
    }
    private void LoadPreviousMappings(){
        objInvMapping = new map<string,Mapping__c>();
        if (Schema.sObjectType.Mapping__c.isAccessible() &&
            Schema.sObjectType.Mapping__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Mapping__c.fields.Name.isAccessible() &&
            Schema.sObjectType.Mapping__c.fields.Account__c.isAccessible() &&
            Schema.sObjectType.Mapping__c.fields.Inwise_Field__c.isAccessible() &&
            Schema.sObjectType.Mapping__c.fields.Object_Type__c.isAccessible() &&
            Schema.sObjectType.Mapping__c.fields.Salesforce_Field__c.isAccessible() &&
            Schema.sObjectType.Mapping__c.fields.Inwise_FieldId__c.isAccessible()) {

            for(Mapping__c oMapping:[SELECT Id,name,Account__c,Inwise_Field__c, Object_Type__c, Salesforce_Field__c,Inwise_FieldId__c from Mapping__c where Account__c=:objInwiseAccount.Id WITH SECURITY_ENFORCED]){
                string key= oMapping.Inwise_FieldId__c + ':' + oMapping.Object_Type__c;
                objInvMapping.put(key,oMapping);
            }
        }        
    }
    public PageReference doSave(){
        PageReference pr;    
        try{
            if(objInwiseAccount == NULL || objInwiseAccount.Id == NULL){
            apexpages.addmessage(new apexpages.message(apexpages.severity.info, 'Please select an account from Inwise Setup tab before selecting mapping'));
            return pr;
        }
            List<Mapping__c> listOfInwiseMapping = new List<Mapping__c>();
            for(wrapperClass wc:listOfWrapperClass){
                            System.debug('==wc.ContactInfo=='+wc.ContactInfo);
                            System.debug('==wc=='+wc);
                // Email mapping is required 
                if(wc.inwiseFieldId == String.valueOf(InwiseConstants.INWISE_FIELDID_EMAIL) && (wc.ContactInfo.Salesforce_Field__c == NULL && wc.LeadInfo.Salesforce_Field__c == NULL)){
                    apexpages.addmessage(new apexpages.message(apexpages.severity.info, 'Please check mapping for ' + wc.inwiseField + ', mapping is required for this field'));
                    listOfInwiseMapping = new List<Mapping__c>();
                    return pr;
                }
                
                listOfInwiseMapping.Add(wc.ContactInfo);
                listOfInwiseMapping.Add(wc.LeadInfo);
            }
            if(listOfInwiseMapping.size()>0){
                if(Schema.sObjectType.Mapping__c.isUpdateable() && Schema.sObjectType.Mapping__c.isCreateable()){
                        upsert listOfInwiseMapping;
                        apexpages.addmessage(new apexpages.message(apexpages.severity.info, InwiseConstants.INWISE_MAPPING_SAVED_SUCCESS));
                        //if(ApexPages.CurrentPage().getParameters().get('doSave') != NULL ){
                        //        pr = Page.inwiseHome;
                        //        pr.setRedirect(true);
                        //}
                }
                
            }
            
            
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,ex.getMessage())); 
        }
        return pr;
    }
    public PageReference goToHome(){
        PageReference pr = Page.inwiseHome;
        pr.setRedirect(true);
        return pr;
    }
    public PageReference toggleshowhelp(){
           objInwiseUtil.updateOverlayHelp(isHelpOnload);
            PageReference pr = Page.InwiseSync;
            pr.getParameters().put('aid',objInwiseAccount.Id);
            pr.setRedirect(true);    
            return pr;
    }    
    public class wrapperClass{ 
        public String inwiseField {get;set;}
        public String inwiseFieldId {get;set;}
        public Mapping__c ContactInfo{get;set;}
        public Mapping__c LeadInfo{get;set;}
    }
    
}