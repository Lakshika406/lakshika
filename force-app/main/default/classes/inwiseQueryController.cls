/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     controller class for inwiseQuery page which is showing the records after query on contact & Lead

Modification Log
----------------
Date                Version     Developer                 Comments
------------------------------------------------------------------------------------
01/27/2017          1.0.0       NlineAxis                 Created
06/03/2021          1.1.0       NlineAxis                 Modified :- Condition added to check Name field encrypted or not
/******************************************************************************************/
public with sharing class inwiseQueryController {

    public Sync__c objSync                               {get;set;}
    public Integer totalLeads                            {get;set;}
    public Integer totalContacts                         {get; private set;}
    public List<Lead> listOfLeads                        {get;private set;}
    public List<Contact> listOfContacts                  {get;set;}
    public inwiseLtngConstants objinwiseLtngConstants    {get;set;}
      
    public inwiseQueryController() {
    
        objinwiseLtngConstants = new inwiseLtngConstants();
        Id syncid = ApexPages.CurrentPage().getParameters().get('Id');
        totalLeads = 0;
        totalContacts = 0;
        listOfLeads = new List<Lead>();
        listOfContacts = new List<Contact>();
        
        List<Sync__c> listOfSync = new List<Sync__c>();
        if(Schema.sObjectType.Sync__c.isAccessible() && Schema.sObjectType.Sync__c.fields.Leads__c.isAccessible() &&
           Schema.sObjectType.Sync__c.fields.Leads_SOQL__c.isAccessible() && Schema.sObjectType.Sync__c.fields.Contacts__c.isAccessible() &&
           Schema.sObjectType.Sync__c.fields.Contacts_SOQL__c.isAccessible() && 
           Schema.sObjectType.Sync__c.fields.Campaign_Members__c.isAccessible() && Schema.sObjectType.Sync__c.fields.Campaign_Members_SOQL__c.isAccessible()){

           listOfSync = [Select Id,Name,Leads__c,Leads_SOQL__c,Contacts__c,Contacts_SOQL__c,Campaign_Members__c,Campaign_Members_SOQL__c from Sync__c where Id=:syncid WITH SECURITY_ENFORCED];
        }
        
        if(!listOfSync.isEmpty()){
            objSync = listOfSync.get(0);
            if(objSync.Leads__c && objSync.Leads_SOQL__c != NULL){
                try{
                    if(Schema.sObjectType.Lead.isAccessible()){
                        String soql = objSync.Leads_SOQL__c;
                        if (String.isBlank(soql)) {
                            throw new IllegalArgumentException('Invalid SOQL query.');
                        }
                        if(!sObjectType.Lead.fields.Name.isEncrypted()){
                            soql += ' Order By Name ASC';
                        }
                        else{
                            soql += ' Order By CreatedDate DESC';
                        }
                        soql += ' LIMIT 10 WITH SECURITY_ENFORCED';
                        
                        listOfLeads = Database.query(soql);
                        String countString = objSync.Leads_SOQL__c.substringAfter('from');
                        countString = 'SELECT COUNT() from ' + String.escapeSingleQuotes(countString)+' WITH SECURITY_ENFORCED';
                        totalLeads = database.countquery(countString);
                    }
                }catch(Exception ex){
                
                }
            }
        
            if(objSync.Contacts__c && objSync.Contacts_SOQL__c != NULL){
                try{
                    if(Schema.sObjectType.Contact.isAccessible()){
                        String soql = objSync.Contacts_SOQL__c;
                        if(!sObjectType.Contact.fields.Name.isEncrypted()){
                            soql += ' Order By Name ASC';
                        }
                        else{
                            soql += ' Order By CreatedDate DESC';
                        }
                        soql += ' LIMIT 10 WITH SECURITY_ENFORCED';
                        
                        listOfContacts = Database.query(soql);
                        String countString = objSync.Contacts_SOQL__c.substringAfter('from');
                        countString = 'SELECT COUNT() from ' + countString +' WITH SECURITY_ENFORCED';
                        totalContacts = database.countquery(countString);
                    }
                }catch(Exception ex){
                
                }
            }
        }
    }
    
    public PageReference gotoHome(){
        PageReference pr = Page.inwiseHome;
        pr.setRedirect(true);
        return pr;
    }
     
    public PageReference gotoSchedule(){
        PageReference pr = Page.inwiseScheduleJob;
        pr.getParameters().put('Id',objSync.Id);
        pr.getParameters().put('retUrl',Page.inwiseHome.getUrl());
        pr.setRedirect(true);
        return pr;
    } 
}