/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 30th Mar 2017
*Purpose :     class use to create inwise Registration
/******************************************************************************************/
public with sharing class inwiseRegistrationController{
    /*
  public String companyName{get;set;}
  public String contactName{get;set;}
  public String phone{get;set;}
  public String email{get;set;}
  public inwiseUtil objInwiseUtil {get;set;}
  public String contactPassword{get;set;}
  public set<String> setOfExstingAccounts{get;set;}
  public boolean isSuccsss {get;set;}
  public inwiseLtngConstants objinwiseLtngConstants{get;set;}
  public inwiseRegistrationController(ApexPages.StandardController controller){
      objinwiseLtngConstants = new inwiseLtngConstants();
      this.companyName = '';
      this.contactName = '';
      this.phone = '';
      this.email = '';
      contactPassword = '';
      setOfExstingAccounts = new set<String>();
      for(Account__c objActount: [select User_Name__c from Account__c limit 1000]){
        setOfExstingAccounts.add(objActount.User_Name__c);
      }
      objInwiseUtil = new InwiseUtil(null);
  }
  public pageReference getStarted(){
        List<Logs__c> listOfLogs = new List<Logs__c>();
        System.debug('objInwiseUtil.objInwiseAccount >>'+objInwiseUtil.objInwiseAccount);
        if(objInwiseUtil.objInwiseAccount != null){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'This feature is only for users that doesn’t have any inwise account configure in their Salesforce yet'));
          return null;
        }
        HttpResponse res;
        String resBody;
        Http http = new Http();  
        isSuccsss = false;
        String contentType = 'text/xml; charset=utf-8';
        if(String.isEmpty(Email) || String.isEmpty(companyName) || String.isEmpty(contactName)){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'Please fill all fields for registration'));
              return null;
        }
        String soapBody = getXMLBody(companyName,contactName,phone,email);
        System.debug('soapBody >>'+soapBody);
        HttpRequest req = objInwiseUtil.GetHTTPRequest('POST', contentType, objInwiseUtil.apiUrl + '/inwisewebservicesadmin.asmx');
        req.setHeader('SOAPAction','http://tempuri.org/CreateNewAccount');
        req.setBody(soapBody);    
        //System.debug('Request  >>'+req);
        if(!Test.isRunningTest()){ 
                res = http.send(req);
                listOfLogs.add(inwiseHttpUtil.getHttpLogRecord(req, res,'CreateNewAccount','inwiseRegistrationController','getStarted'));
      }else{
          resBody = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><CreateAccountResponse xmlns="http://tempuri.org/"><CreateAccountResult><Success>true</Success><ErrorCode>0</ErrorCode><Data><anyType xsi:type="xsd:int">14766</anyType><anyType xsi:type="xsd:string">11d800ef8275474bb269cd2d752c17f5</anyType><anyType xsi:type="xsd:string">http://app.inwise.com/Default.aspx?token=7db90c7381254f768d6b286163797166</anyType></Data></CreateAccountResult></CreateAccountResponse></soap:Body></soap:Envelope>';
          res = inwiseTestDataFactory.getDumpHttpResponse(resBody, 'text/xml');
    }    
    if(res.getStatusCode() == 200 && res.getBody() != NULL){
            resBody = res.getBody();
            //one other output
            //<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><CreateAccountResponse xmlns="http://tempuri.org/"><CreateAccountResult><Success>false</Success><ErrorDescription>The system could not complete your request. The error code is :</ErrorDescription><ErrorCode>5</ErrorCode></CreateAccountResult></CreateAccountResponse></soap:Body></soap:Envelope>
            integer j = resBody.indexOf('<ErrorDescription>');//@todo change this parsing to xml parser
            integer j2 = resBody.indexOf('</ErrorDescription>'); //@todo change this parsing to xml parser
            if(j >0 && j2 >0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,resBody.substring(j+18,j2)));   
            }else{
                  String authenticationToken = getAuthToken(resBody);
                if(String.isNotEmpty(authenticationToken)){
                      if(!setOfExstingAccounts.contains(email)){
                            createAccount(companyName,email,contactPassword,authenticationToken);
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM , 'You successfully created an account!');
                            ApexPages.addMessage(myMsg);    
                            isSuccsss = true;
                    }else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR , 'This account already exist in the database');
                        ApexPages.addMessage(myMsg);  
                  }
            }
        }
    }else if(res.getStatusCode() == 500 && res.getBody() != NULL){
        resBody = res.getBody();
        integer j = resBody.indexOf('<faultstring>');//@todo change this parsing to xml parser
        integer j2 = resBody.indexOf('</faultstring>'); //@todo change this parsing to xml parser
        if(j >0 && j2 >0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,resBody.substring(j+13,j2)));   
        }
    }
    System.debug('size list of logs::-->>' + listOfLogs.size());
    if(objInwiseUtil.objInwiseSetting.Track_Logs__c && !listOfLogs.isEmpty()){
        insert listOfLogs;
    }    
    return null;
  }
  public PageReference gotoHome(){
        PageReference pr = Page.inwiseHome;
        pr.setRedirect(true);
        return pr;
    
  } 
  public String getXMLBody(String contactCompanyName,String contactName, String contactPhone,String contactEmail){
        String soapBody = '';
        String uName = 'boazapttemp';
        String uPassword = 'WSIjdhbI'; 
        contactPassword = 'a9Z'  + String.valueof(DateTime.now().getTime());
        soapBody += '<?xml version="1.0" encoding="utf-8"?>';
        soapBody +=  '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
          soapBody += '<soap:Header>';
            soapBody += '<SecHeader xmlns="http://tempuri.org/">';
              soapBody += '<username>'+EncodingUtil.urlEncode(uName,'UTF-8')+'</username>';
              soapBody += '<pass>'+EncodingUtil.urlEncode(uPassword,'UTF-8')+'</pass>'; 
            soapBody += '</SecHeader>';
          soapBody += '</soap:Header>';
          soapBody += '<soap:Body>';
            soapBody += '<CreateNewAccount xmlns="http://tempuri.org/">';
              soapBody += '<account>';
                  soapBody += '<UserName>'+ contactEmail +'</UserName>';
                                  soapBody += '<ManagerId>14072</ManagerId>';
                                  soapBody += '<CreateApiKey>true</CreateApiKey>';
                                  soapBody += '<CompanyName>'+ contactCompanyName +'</CompanyName>';
                                  soapBody += '<ContactName>'+ contactName +'</ContactName>';
                                  soapBody += '<ContactEmail>'+ contactEmail +'</ContactEmail>';
                                  soapBody += '<ContactPhone>111-22-3333333</ContactPhone>';//because of soap service issue passing hardcoded number
                                  soapBody += '<Language>english</Language>';
                                  soapBody += '<Locale>en-US</Locale>';
                                  soapBody += '<Password>'+ contactPassword +'</Password>';
                                  soapBody += '<AddToMarketingAccount>true</AddToMarketingAccount>';
                                  soapBody += '<MarketingGroupId>663924</MarketingGroupId>';
              soapBody += '</account>';
          soapBody += '</CreateNewAccount>';
          soapBody += ' </soap:Body>'; 
        soapBody += '</soap:Envelope>';
        return soapBody;
    }
    public String getAuthToken(String resBody){
        XmlStreamReader reader = new XmlStreamReader(resBody);
        String token = '';
        integer endTagCount = 1;
        while(reader.hasNext()) {
          System.debug('reader getLocalName>>>'+reader.getLocalName());
          if(reader.getLocalName() == 'Data'){
              while(endTagCount <= 4){
                  if(reader.getEventType() == XmlTag.END_ELEMENT){
                      endTagCount++;
                  }
                  if(reader.hasText() && endTagCount == 4){
                      token = reader.getText();  
                  }   
                  reader.next();
              }
          }
          reader.next(); 
        } 
        return token;
    }
    public void createAccount(String contactCompanyName,String contactEmail,String password, String AuthToken){
      
            Account__c objinwiseAccount =  new Account__c();
            if(Schema.sObjectType.Account__c.fields.Name.isCreateable()){
                objinwiseAccount.Name = contactName;
            }    
            //if(Schema.sObjectType.Account__c.fields.User_Name__c.isCreateable()){
            //    objinwiseAccount.User_Name__c = contactEmail;        
            //}    
            //if(Schema.sObjectType.Account__c.fields.Password__c.isCreateable()){
            //    objinwiseAccount.Password__c = password;
            // }   
            if(Schema.sObjectType.Account__c.fields.Token__c.isCreateable()){
                objinwiseAccount.Token__c = AuthToken;
            } 
            if(Schema.sObjectType.Account__c.fields.Default__c.isCreateable()){
                objinwiseAccount.Default__c = true;
            }   
            if(Schema.sObjectType.Account__c.isCreateable()){
                  insert objinwiseAccount;
            }     
      }  */   
    
}