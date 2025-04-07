public with sharing class inwiseLtngConstants {
    
    public String slds{get;set;}
    public String sldsInput{get;set;}
    public boolean isLightning{get;set;}
    public String sldsCheckbox{get;set;}
    public String sldsButtonSldsButtonNeutral{get;set;}
    public String sldsTableSldsTableBorderedSldsTableStriped{get;set;}
    
    public inwiseLtngConstants(){
        
        slds = '';
        sldsInput  = '';
        sldsCheckbox = '';
        sldsButtonSldsButtonNeutral = '';
        sldsTableSldsTableBorderedSldsTableStriped = ''; 
        
        if(UserInfo.getUiTheme() == 'Theme4d'){
            isLightning = true;
        }
        else {
            isLightning = false;
        }   
        
        if(isLightning || Test.isRunningTest()){
            slds = 'slds';
            sldsInput  = 'slds-input';
            sldsCheckbox = 'slds-checkbox';
            sldsButtonSldsButtonNeutral = 'slds-button slds-button--neutral';
            sldsTableSldsTableBorderedSldsTableStriped = 'slds-table slds-table--bordered slds-table--striped';
        }  
    }
}