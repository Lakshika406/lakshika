public class SMSWrapper {
    public String smsText;
    public String mobileNumber;
    public String recordId;
    public Boolean saveTask;
    public Boolean saveMessagingHistory;
    public String fromNumber;
    public String accountId;
    
    //public String isSMSSent;
    //public String status;
    //public String rejectReason;
    public Map<String, String> toMap;
    public Error_Logs__c errorLogs;
    
    public SMSWrapper(String smsText, String mobileNumber,String recordId, Boolean saveTask, Boolean saveMessagingHistory, String fromNumber, String accountId, Map<String,String> responseMap,Error_Logs__c errorLogs){ 
        this.smsText = smsText;
        this.mobileNumber = mobileNumber;
        this.recordId = recordId;
        this.saveTask = saveTask;
        this.saveMessagingHistory = saveMessagingHistory;
        this.fromNumber = fromNumber;
        this.accountId = accountId;
        this.toMap = responseMap;
        //this.isSMSSent = isSMSSent;
        //this.status = status;
        //this.rejectReason = rejectReason;
        this.errorLogs = errorLogs;
        
    }

}