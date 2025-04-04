/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :     Common class for filter & all related methods
*Modified:   
================================================================
Modified On      Modified By        Purpose  
================================================================
12/01/2016      Kapil Goutam     Modified: -Update phone no check to support (503) 421-5451 format
08/31/2018      Kapil Goutam     Modified: -remove email optout field in setOfStringExcludeLeadFields for both lead & contact
06/20/2024     NLINEAXIS(Kapil Goutam)     Modified:- Added changes for security check 
/******************************************************************************************/
public with sharing class inwiseScheduleSyncObject {
    
    //valid operator - equals, not equal to, Starts WIth, Contains, Does not contains
    public static String FIELD_TYPE_STRING = 'STRING'; 
    public static String FIELD_TYPE_PICKLIST = 'PICKLIST';
    public static String FIELD_TYPE_TEXTAREA = 'TEXTAREA';
    public static String FIELD_TYPE_EMAIL = 'EMAIL';
    public static String FIELD_TYPE_URL = 'URL';
    
    //valid operator - equals, not equal to
    public static String FIELD_TYPE_BOOLEAN = 'BOOLEAN';                         
    
    //valid operator - equals, not equal to, less than,greater than,less or equal,greater or equal
    public static String FIELD_TYPE_DOUBLE = 'DOUBLE';
    public static String FIELD_TYPE_CURRENCY = 'CURRENCY';
    public static String FIELD_TYPE_INTEGER = 'INTEGER';
    
    //valid operator - equals, not equal to, less than,greater than,less or equal,greater or equal
    public static String FIELD_TYPE_DATE = 'DATE';
    public static String FIELD_TYPE_DATETIME = 'DATETIME';
    
    public static String FIELD_TYPE_PHONE = 'PHONE';
    public static String FIELD_TYPE_MULTIPICKLIST = 'MULTIPICKLIST';
    public static String FIELD_TYPE_PERCENT = 'PERCENT';
    
    
    public static Set<String> setOfAcceptableTypeForSOQL = new Set<String>{FIELD_TYPE_STRING,FIELD_TYPE_BOOLEAN,FIELD_TYPE_DOUBLE,FIELD_TYPE_PICKLIST,FIELD_TYPE_EMAIL,FIELD_TYPE_URL,FIELD_TYPE_CURRENCY,FIELD_TYPE_INTEGER,FIELD_TYPE_DATE,FIELD_TYPE_DATETIME,FIELD_TYPE_PHONE,FIELD_TYPE_MULTIPICKLIST,FIELD_TYPE_PERCENT,FIELD_TYPE_TEXTAREA};    
        
        public List<WrapperFilter>  listOfSyncFilters{get;set;}
    private Integer iTotalRows{get;set;}
    public Integer toDeleteRow{get;set;}
    public String sObjectType{get;set;}
    public String sSOQL{get;set;}
    
    public inwiseScheduleSyncObject(String sObjectType, Sync__c objSync) {
        this.sObjectType = sObjectType;
        listOfSyncFilters = new List<WrapperFilter>();
        WrapperFilter objWrapperFilter = new WrapperFilter(sObjectType);
        iTotalRows = 0;
        if(objSync != NULL && objSync.Id != NULL){
            List<Sync_Filter__c> listOfFilters;
            if(Schema.sObjectType.Sync_Filter__c.isAccessible() && Schema.sObjectType.Sync_Filter__c.fields.Field_Api_Name__c.isAccessible() &&
                Schema.sObjectType.Sync_Filter__c.fields.Field_Label__c.isAccessible() && Schema.sObjectType.Sync_Filter__c.fields.Field_Type__c.isAccessible() &&
                Schema.sObjectType.Sync_Filter__c.fields.Sync__c.isAccessible() && Schema.sObjectType.Sync_Filter__c.fields.Operator__c.isAccessible() &&
                Schema.sObjectType.Sync_Filter__c.fields.sObject_Name__c.isAccessible() && Schema.sObjectType.Sync_Filter__c.fields.Value__c.isAccessible()){

                listOfFilters = [Select Id,Name,Field_Api_Name__c, Field_Label__c, Field_Type__c, Sync__c,Operator__c,sObject_Name__c,Value__c from Sync_Filter__c where Sync__c =:objSync.Id and sObject_Name__c=:sObjectType ];                
            }    
            if(!listOfFilters.isEmpty()){
                for(Sync_Filter__c sf:listOfFilters){
                    objWrapperFilter = new WrapperFilter(sObjectType);
                    objWrapperFilter.rowno = ++iTotalRows;
                    objWrapperFilter.objSyncFilter = sf;
                    objWrapperFilter.objSyncFilter.Field_Api_Name__c = encodeForHTML(sf.Field_Api_Name__c) + ':' + encodeForHTML(sf.Field_Type__c);
                    listOfSyncFilters.add(objWrapperFilter);
                }
                if(sObjectType == InwiseConstants.SOBJECT_LEAD){
                    sSOQL = objSync.Leads_SOQL__c;
                }else if(sObjectType == InwiseConstants.SOBJECT_CONTACT){
                    sSOQL = objSync.Contacts_SOQL__c;
                }
            }else{
                sSOQL = '';
                objWrapperFilter.rowno = ++iTotalRows;
                listOfSyncFilters.add(objWrapperFilter);
            }     
        }else{
            sSOQL = '';
            objWrapperFilter.rowno = ++iTotalRows;
            listOfSyncFilters.add(objWrapperFilter);
        } 
        
        
    }
    
    public string encodeForHTML(String input) {
        if (input == null) {
            return null;
        }
        return input.replace('&', '&amp;')
            .replace('<', '&lt;')
            .replace('>', '&gt;')
            .replace('"', '&quot;')
            .replace('"', '&#x27;')
            .replace('/', '&#x2F;');
    }
    public static Set<String> getSetOfExcludedFields(String objectType){
        Set<String> setOfStringExcludeLeadFields;
        if(objectType ==InwiseConstants.SOBJECT_LEAD){
            setOfStringExcludeLeadFields = new Set<String>{'IsConverted','CleanStatus','CompanyDunsNumber','DandbCompany','ConvertedDate','Jigsaw','IsDeleted','EmailBouncedDate','EmailBouncedReason','GeocodeAccuracy','JigsawContactId','LastReferencedDate','LastTransferDate','LastViewedDate','PhotoUrl','SystemModstamp','IsUnreadByOwner'}; 
                }   
        if(objectType ==InwiseConstants.SOBJECT_CONTACT){
            //@todo add different fields for contatc, for now adding the same fields as lead          
            setOfStringExcludeLeadFields = new Set<String>{'IsConverted','CleanStatus','CompanyDunsNumber','DandbCompany','ConvertedDate','Jigsaw','IsDeleted','EmailBouncedDate','EmailBouncedReason','GeocodeAccuracy','JigsawContactId','LastReferencedDate','LastTransferDate','LastViewedDate','PhotoUrl','SystemModstamp','IsUnreadByOwner'}; 
                }
        if(objectType ==InwiseConstants.SOBJECT_ACCOUNT){
            //@todo add different fields for contatc, for now adding the same fields as lead
            setOfStringExcludeLeadFields = new Set<String>{'IsConverted','CleanStatus','CompanyDunsNumber','DandbCompany','ConvertedDate','Jigsaw','IsDeleted','EmailBouncedDate','EmailBouncedReason','GeocodeAccuracy','JigsawContactId','LastReferencedDate','LastTransferDate','LastViewedDate','PhotoUrl','SystemModstamp','IsUnreadByOwner'};
                }
        return   setOfStringExcludeLeadFields;
    }
    public List<SelectOption> listOfSelectOptionFields_Lead {get{
        if(sObjectType != NULL && sObjectType.toUpperCase() == InwiseConstants.SOBJECT_LEAD.toUpperCase()  && listOfSelectOptionFields_Lead == NULL){
            listOfSelectOptionFields_Lead = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_LEAD,setOfAcceptableTypeForSOQL,false);
        }
        return listOfSelectOptionFields_Lead; 
    }set;}
    
    public List<SelectOption> listOfSelectOptionFields_Contact {get{
        if(sObjectType != NULL && sObjectType.toUpperCase() == InwiseConstants.SOBJECT_CONTACT.toUpperCase()  && listOfSelectOptionFields_Contact == NULL){
            listOfSelectOptionFields_Contact = inwiseUtil.getFieldsForQueryFilter(InwiseConstants.SOBJECT_CONTACT,setOfAcceptableTypeForSOQL,false);
        }
        return listOfSelectOptionFields_Contact; 
    }set;}
    
    public PageReference doAddRow(){
        if(!listOfSyncFilters.isEmpty()){
            for(WrapperFilter wf:listOfSyncFilters){
                if(wf.objSyncFilter.Field_Api_Name__c == NULL){
                    String msg = 'Please enter api name '+'(section-'+ sObjectType.toLowerCase() +')' +' for filter row : ' + wf.rowno ;
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error,(msg)));     
                    return NULL; 
                } 
                if(wf.objSyncFilter.Operator__c == NULL){
                    String msg = 'Please enter operator '+ '(section-'+ sObjectType.toLowerCase() +')' +' for filter row : ' + wf.rowno;
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error,(msg)));      
                    return NULL;
                }
            }
        }
        WrapperFilter objWrapperFilter = new WrapperFilter(sObjectType);
        objWrapperFilter.rowno = ++iTotalRows;
        listOfSyncFilters.add(objWrapperFilter);
        return null;
    }
    public PageReference doDeleteRow(){
        integer i=0;
        WrapperFilter objWrapperFilterTemp;
        List<WrapperFilter>  listOfSyncFiltersTemp = new List<WrapperFilter>();
        if(toDeleteRow != NULL){
            for(WrapperFilter wf:listOfSyncFilters){
                if(wf.rowno != toDeleteRow){
                    objWrapperFilterTemp = wf;
                    objWrapperFilterTemp.rowno = ++i;
                    listOfSyncFiltersTemp.add(objWrapperFilterTemp);
                }
            }
            listOfSyncFilters = listOfSyncFiltersTemp;
            iTotalRows = i;  
        }
        return null;
    }
    public String buildSOQL(List<WrapperFilter>  listOfSyncFiltersT ,String sObjectTypeT){
        String soql = '';
        // Check if the object is accessible
        if (Schema.getGlobalDescribe().containsKey(sObjectTypeT) && Schema.getGlobalDescribe().get(sObjectTypeT).getDescribe().isAccessible()) {
            
            if(!listOfSyncFiltersT.isEmpty()){
                soql = 'SELECT Id,Name from ' + sObjectTypeT + ' WHERE ';
                if(sObjectTypeT.toUpperCase() == InwiseConstants.SOBJECT_LEAD.toUpperCase()){
                    soql += ' IsConverted = false AND ';
                }
                for(WrapperFilter w:listOfSyncFiltersT){
                    if(w.objSyncFilter.Field_Api_Name__c != NULL && w.objSyncFilter.Operator__c  != NULL){
                        List<String> listOfStringFieldVsType = w.objSyncFilter.Field_Api_Name__c.split(':');
                        if(listOfStringFieldVsType.size() == 2){
                            String fieldtype = listOfStringFieldVsType.get(1); //.toUpperCase();
                            String fieldapiname = listOfStringFieldVsType.get(0);
                            String fieldvalue = w.objSyncFilter.Value__c;
                            String opname = w.objSyncFilter.Operator__c;
                            soql +=   getWhereClause(fieldtype, fieldapiname, opname,fieldvalue) +  ' ' + w.sAndOr +' ';
                        } 
                    }
                }
            }
        }
        System.debug('BEFORE164::-->>' + soql);
        if(sObjectTypeT.toUpperCase() == InwiseConstants.SOBJECT_CONTACT.toUpperCase() && soql.trim().endsWith('WHERE')){
            soql = soql.substringBeforeLast('WHERE');
        }else{
            soql = soql.substringBeforeLast('AND');
        }
        System.debug('AFTER170::-->>' + soql);
        return soql;
    }
    
    public String getWhereClause(String fieldtype, String fieldapiname, String opname, String fieldvalue){
        String soql = ' '; //' ' + fieldapiname + ' ';
        if(opname != NULL && opname != ''){
            opname = opname.toLowerCase();   //mapOfOperator.get(opname.toLowerCase());
        }
        if(opname == 'equals'){
            if(fieldtype != FIELD_TYPE_PICKLIST && fieldtype != FIELD_TYPE_MULTIPICKLIST){//exclude pikclist because creating filter in different way
                soql += fieldapiname + ' = ';
            }      
        }else if(opname == 'not equal to'){
            if(fieldtype != FIELD_TYPE_PICKLIST && fieldtype != FIELD_TYPE_MULTIPICKLIST){//exclude pikclist because creating filter in different way 
                soql += fieldapiname + ' != ';
            }    
        }else if(opname == 'less than'){
            soql += fieldapiname + ' < ';
        }else if(opname == 'greater than'){
            soql += fieldapiname + ' > ';
        }else if(opname == 'less or equal'){
            soql += fieldapiname + ' <= ';
        }else if(opname == 'greater or equal'){
            soql += fieldapiname + ' >= ';
        }
        //Select Id, Name,Level__c from Contact where Level__c ='Secondary' OR Level__c = 'Tertiary'
        //Select Id, Name,Location__c from Lead where Location__c includes ('India', 'USA')
        //Select Id, Name,Location__c from Lead where Location__c = 'India' OR Location__c = 'USA'
        System.debug('fieldtype::-->>>' + fieldtype + '>>>>' + fieldvalue);
        //Starts With, Contains, Does Not Contain
        if(fieldtype == FIELD_TYPE_STRING || fieldtype == FIELD_TYPE_URL || fieldtype == FIELD_TYPE_EMAIL || fieldtype == FIELD_TYPE_TEXTAREA ||
           fieldtype == FIELD_TYPE_PHONE){
               if(fieldvalue != NULL && fieldvalue.trim() != ''){
                   if(opname == 'starts with'){
                       soql += fieldapiname + ' LIKE \'' +   fieldvalue   + '%\'';
                   }else if(opname == 'contains'){
                       soql += fieldapiname + ' LIKE \'%' +   fieldvalue   + '%\'';     
                   }else if(opname == 'does not contain'){
                       soql += '(NOT '+ fieldapiname + ' LIKE \'%' +   fieldvalue   + '%\')';     
                   }else{
                       soql +=  '\'' +   fieldvalue   + '\'';    
                   }
                   
               }else{
                   soql += ' ' +   NULL   + ' ';
               }
           }else if(fieldtype == FIELD_TYPE_PICKLIST){
               if(fieldvalue != NULL && fieldvalue.trim() != ''){
                   System.debug('fieldvalue218::::::-->>>' + fieldvalue); 
                   List<String> listOfvaluesTemp = fieldvalue.split(',');
                   List<String> listOfvalues = new List<String>();
                   if(!listOfvaluesTemp.isEmpty()){ //removed blank values
                       for(String s:listOfvaluesTemp){
                           if(s.trim() != ''){
                               listOfvalues.add(s.trim());
                           }
                       }
                   }
                   String fieldvaluenew = '';
                   System.debug('listOfvalues::-->>' + listOfvalues);
                   if(!listOfvalues.isEmpty()){
                       if(opname == 'contains' || opname == 'does not contain'  || opname == 'equals' || opname == 'not equal to'){
                           Integer sz=1;
                           fieldvaluenew = '(';
                           for(String s:listOfvalues){
                               if(s.trim() != ''){
                                   fieldvaluenew += fieldapiname + ' = \'' +   s.replace(', ','')   + '\' '  + (listOfvalues.size() == sz ? ' ' : ' OR ');
                                   System.debug('fieldvaluenew::--->>' + fieldvaluenew);
                               }else{
                                   //don't put anything in case of blank
                               }
                               
                               sz++;
                           }  
                           fieldvaluenew += ')'; 
                       } 
                       System.debug('fieldvaluenew::-->>' + fieldvaluenew + '>>>' + opname);
                       if(opname == 'starts with'){ //Level__c like '%Seco%' OR Level__c LIKE '%pri%'
                           Integer sz=1;
                           fieldvaluenew = '(';
                           for(String s:listOfvalues){
                               if(s.trim() != ''){
                                   fieldvaluenew += fieldapiname + ' LIKE\'' +   s.replace(', ','')   + '%\' '  + (listOfvalues.size() == sz ? ' ' : ' OR ');
                               }else{
                                   //don't put anything in case of blank
                               }
                               
                               sz++;
                           }  
                           fieldvaluenew += ')';
                           soql += fieldvaluenew;   
                       }else if(opname == 'contains'){
                           //Level__c ='Secondary' OR Level__c = 'Tertiary'
                           soql += fieldvaluenew;
                       }else if(opname == 'does not contain'){
                           soql += ' (NOT ' + fieldvaluenew + ')';  
                       }else{
                           System.debug('fieldvalue::-->>' + fieldvalue + '>>>>' + fieldvalue.replace(', ', '') + '>>>' + soql);
                           //soql +=  '\'' +   fieldvalue.replace(', ', '')   + '\'';
                           soql += fieldvaluenew;    
                       }
                   }
                   
               }else{
                   soql += ' ' +   NULL   + ' ';
               }
               System.debug('Final SOQL Picklist::-->>' + soql);
           }else if(fieldtype == FIELD_TYPE_MULTIPICKLIST){
               if(fieldvalue != NULL && fieldvalue.trim() != ''){
                   List<String> listOfvaluesTemp = fieldvalue.split(',');
                   List<String> listOfvalues = new List<String>();
                   if(!listOfvaluesTemp.isEmpty()){ //removed blank values
                       for(String s:listOfvaluesTemp){
                           if(s.trim() != ''){
                               listOfvalues.add(s.trim());
                           }
                       }
                   }
                   String fieldvaluenew = '';
                   if(!listOfvalues.isEmpty()){
                       for(String s:listOfvalues){
                           fieldvaluenew += '\'' + s  +'\'' + ',';
                       }
                       fieldvaluenew = '(' + fieldvaluenew.substring(0, fieldvaluenew.length()-1) + ')';
                   }else{
                       fieldvaluenew = fieldvalue;
                   }
                   if(opname == 'contains' || opname == 'equals'){
                       soql += fieldapiname + ' includes '  + fieldvaluenew;     
                   }else if(opname == 'does not contain' || opname == 'not equal to'){
                       soql += fieldapiname + ' excludes '  + fieldvaluenew;     
                   }else{
                       //soql +=  '\'' +   fieldvalue.replace(', ','')   + '\'';    
                       soql +=  '\'' +   fieldvaluenew   + '\'';    
                   }
               }else{
                   soql += ' ' +   NULL   + ' ';
               }
               System.debug('Final SOQL MULTI-Picklist::-->>' + soql);
           }else if(fieldtype == FIELD_TYPE_DATE || fieldtype == FIELD_TYPE_DATETIME){
               if(fieldtype == FIELD_TYPE_DATE){//MM/DD/YYYY
                   if(fieldvalue != NULL && fieldvalue.trim() != ''){
                       List<String> listOfdate =fieldvalue.split('/'); 
                       if(!listOfdate.isEmpty() && listOfdate.size() == 3){
                           Datetime dtnew = Datetime.newInstance(Integer.valueOf(listOfdate.get(2)), Integer.valueOf(listOfdate.get(0)), Integer.valueOf(listOfdate.get(1)), 0, 0, 0);
                           //Date dtnew = Date.newInstance(Integer.valueOf(listOfdate.get(2)), Integer.valueOf(listOfdate.get(0)), Integer.valueOf(listOfdate.get(1)));
                           soql += dtnew.format('yyyy-MM-dd'); 
                           //soql += dtnew.year() + '-' + dtnew.month() + '-' + dtnew.day();
                           
                       }
                   }else{
                       soql += ' ' +   NULL   + ' ';
                   }      
               }else if(fieldtype == FIELD_TYPE_DATETIME){
                   if(fieldvalue != NULL && fieldvalue.trim() != ''){
                       List<String> listOfStringOuter = fieldvalue.split(' ');
                       if(!listOfStringOuter.isEmpty() && listOfStringOuter.size() == 2){
                           List<String> listOfdate =listOfStringOuter.get(0).split('/'); 
                           List<String> listOfTime = listOfStringOuter.get(1).split(':');
                           if(!listOfdate.isEmpty() && !listOfTime.isEmpty() && listOfdate.size() == 3 && listOfTime.size() == 2){
                               Datetime dtnew = Datetime.newInstance(Integer.valueOf(listOfdate.get(2)), Integer.valueOf(listOfdate.get(0)), Integer.valueOf(listOfdate.get(1)), Integer.valueOf(listOfTime.get(0)), Integer.valueOf(listOfTime.get(1)), 0);
                               soql += dtnew.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                               //soql += dtnew.year() + '-' + dtnew.month() + '-' + dtnew.day() + 'T'+dtnew.hour() + ':'  + dtnew.minute() + ':00Z';
                           }
                       }
                   }else{
                       soql += ' ' +   NULL   + ' ';
                   }      
               }
           }else{
               if(fieldvalue != NULL && fieldvalue.trim() != ''){
                   soql +=  fieldvalue;    
               }else{
                   soql += ' ' +   NULL   + ' ';
               }
               
           }
        System.debug('final return328::-->>' + soql); 
        return soql;     
    }
    
    public static boolean validateFieldVsValues(List<WrapperFilter>  listOfSyncFiltersT, String sObjectTypeT){
        boolean isValid = true;
        //integer i=1;
        if(!listOfSyncFiltersT.isEmpty()){
            for(WrapperFilter w:listOfSyncFiltersT){
                if(w.objSyncFilter.Field_Api_Name__c != NULL || (w.objSyncFilter.Value__c  != NULL && !String.isEmpty(w.objSyncFilter.Value__c)) || w.objSyncFilter.Operator__c != NULL){
                    integer i = 0;
                    if(w.objSyncFilter.Field_Api_Name__c != NULL){
                        i++;
                    }
                    if(w.objSyncFilter.Value__c != NULL){
                        i++;
                    }
                    if(w.objSyncFilter.Operator__c != NULL){
                        i++;
                    }
                    if(i< 3){
                        //   apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Something wrong, please check filter for filter (section-'+sObjectTypeT+') row : ' + w.rowno + '. Please delete if any blank filter row')));
                        apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Please choose the operator for all your fitters (section-'+sObjectTypeT+') row : ' + w.rowno + '. Please delete if any blank filter row')));
                        isValid = false;     
                        return isValid;
                    }
                    
                }
                if(w.objSyncFilter.Operator__c != NULL && (w.objSyncFilter.Value__c == NULL || w.objSyncFilter.Value__c.trim() == '' ) && (w.objSyncFilter.Operator__c.toUpperCase() == 'GREATER THAN'  || w.objSyncFilter.Operator__c.toUpperCase() == 'GREATER OR EQUAL' ||w.objSyncFilter.Operator__c.toUpperCase() ==  'LESS THAN'  || w.objSyncFilter.Operator__c.toUpperCase() == 'LESS OR EQUAL' || w.objSyncFilter.Operator__c.toUpperCase() == 'CONTAINS' || w.objSyncFilter.Operator__c.toUpperCase() == 'DOES NOT CONTAIN' || w.objSyncFilter.Operator__c.toUpperCase() == 'STARTS WITH')){
                    apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Something wrong (section-'+sObjectTypeT+'), you can not use null as field value in case of Less Than,Less or Equal,Greater Than,Greater or Equal, Contains, Does Not Contain & Starts With operator. please check filter for filter row : ' + w.rowno)));
                    isValid = false;     
                    return isValid;
                }
                if(w.objSyncFilter.Field_Api_Name__c != NULL && w.objSyncFilter.Value__c  != NULL){
                    List<String> listOfStringFieldVsType = w.objSyncFilter.Field_Api_Name__c.split(':');
                    if(listOfStringFieldVsType.size() == 2){
                        if(listOfStringFieldVsType.get(1).toUpperCase() == FIELD_TYPE_BOOLEAN){
                            if(w.objSyncFilter.Value__c.toUpperCase() != 'TRUE'  &&  w.objSyncFilter.Value__c.toUpperCase() != 'FALSE' ){
                                apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Field  value can be true or false at filter row :' + w.rowno)));
                                isValid = false;
                                return isValid;
                            }
                        }else if(listOfStringFieldVsType.get(1).toUpperCase() == FIELD_TYPE_DOUBLE || listOfStringFieldVsType.get(1).toUpperCase() == FIELD_TYPE_CURRENCY || listOfStringFieldVsType.get(1).toUpperCase() == FIELD_TYPE_INTEGER ||
                                 listOfStringFieldVsType.get(1).toUpperCase() == FIELD_TYPE_PERCENT || listOfStringFieldVsType.get(1).toUpperCase() == FIELD_TYPE_PHONE){
                                     if(w.objSyncFilter.Value__c != NULL && w.objSyncFilter.Value__c.trim() != ''){
                                         try{  
                                             if(listOfStringFieldVsType.get(1).toUpperCase() == FIELD_TYPE_PHONE){//remove format for no like - (503) 421-7800
                                                 String phoneno = w.objSyncFilter.Value__c.replace('(','').replace(')','').replace('-','').replace(' ','');
                                                 Double d = Double.valueOf(phoneno);    
                                             }else{
                                                 Double d = Double.valueOf(w.objSyncFilter.Value__c);    
                                             }
                                             
                                         }catch(Exception ex){
                                             apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Field value is not correct for filter row :' + w.rowno)));
                                             isValid = false;
                                             return isValid;
                                         }
                                     }
                                     
                                 }else if(listOfStringFieldVsType.get(1).toUpperCase() == FIELD_TYPE_DATE){
                                     if(w.objSyncFilter.Value__c != NULL && w.objSyncFilter.Value__c.trim() != ''){
                                         try{
                                             List<String> listOfdate =w.objSyncFilter.Value__c.split('/'); 
                                             if(!listOfdate.isEmpty() && listOfdate.size() == 3){
                                                 Date dtnew = Date.newInstance(Integer.valueOf(listOfdate.get(2)), Integer.valueOf(listOfdate.get(0)), Integer.valueOf(listOfdate.get(1)));
                                             }else{
                                                 apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Field value  should be in MM/DD/YYYY format for filter row :' + w.rowno)));
                                                 isValid = false;
                                                 return isValid;    
                                             }
                                         }catch(Exception ex){
                                             apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Field value  should be in MM/DD/YYYY format for filter row :' + w.rowno)));
                                             isValid = false;
                                             return isValid;
                                         }
                                     }     
                                 }else if(listOfStringFieldVsType.get(1).toUpperCase() == FIELD_TYPE_DATETIME){
                                     if(w.objSyncFilter.Value__c != NULL && w.objSyncFilter.Value__c.trim() != ''){
                                         try{
                                             List<String> listOfStringOuter = w.objSyncFilter.Value__c.split(' ');
                                             if(!listOfStringOuter.isEmpty() && listOfStringOuter.size() == 2){
                                                 List<String> listOfdate =listOfStringOuter.get(0).split('/'); 
                                                 List<String> listOfTime = listOfStringOuter.get(1).split(':');
                                                 if(!listOfdate.isEmpty() && !listOfTime.isEmpty() && listOfdate.size() == 3 && listOfTime.size() == 2){
                                                     Datetime dtnew = Datetime.newInstance(Integer.valueOf(listOfdate.get(2)), Integer.valueOf(listOfdate.get(0)), Integer.valueOf(listOfdate.get(1)), Integer.valueOf(listOfTime.get(0)), Integer.valueOf(listOfTime.get(1)), 0);
                                                 }else{
                                                     apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Field value  should be in MM/DD/YYYY HH:MM (24 hours format Eg-10/20/2016 18:20) format for filter row :' + w.rowno)));
                                                     isValid = false;
                                                     return isValid;
                                                 }
                                             }else{
                                                 apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Field value  should be in MM/DD/YYYY HH:MM (24 hours format Eg-10/20/2016 18:20) format for filter row :' + w.rowno)));
                                                 isValid = false;
                                                 return isValid;
                                             }
                                         }catch(Exception ex){
                                             apexpages.addmessage(new apexpages.message(apexpages.severity.Error,('Field value  should be in MM/DD/YYYY HH:MM (24 hours format Eg-10/20/2016 18:20) format for filter row :' + w.rowno)));
                                             isValid = false;
                                             return isValid;
                                         }
                                     }     
                                 }
                    }
                }
                //i++;
            }
        }    
        return isValid;            
    }
    public boolean validateSOQL(String soqlString){
        boolean isValid = true;
        try{
            String soqlStringLimited =  soqlString + ' LIMIT 1';//to fix 500001 query rows issue
            Database.query(soqlStringLimited);
        }catch(Exception ex){
            isValid = false;
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,ex.getMessage()));
        }
        return isValid;
    }
    
    public class WrapperFilter{
        public integer rowno{get;set;}
        public Sync_Filter__c objSyncFilter{get;set;}
        public String sObjectType {get;set;}
        public String sAndOr{get;set;}
        public WrapperFilter(String sObjectType){
            objSyncFilter = new Sync_Filter__c();
            sAndOr = 'AND';
            this.sObjectType = sObjectType;
        }
    }
}