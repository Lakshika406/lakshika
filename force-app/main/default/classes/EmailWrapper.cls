public class EmailWrapper{
	public String recordId;	//' +{!$Record.Id}+'
    public String accountId;
	public String toname;	//' +{!name} + '
	public String email;	//' +{!email} + '
	public String from_email;	//' +{!from_email} + '
	public String reply_to;	//' +{!reply_to} + '
	public boolean saveToInwiseMessagingHistory;
	public boolean createTask;
	public String template_id;	//' +{!template_id} + '
	public String subject;	// '+{!subject}+' 
	public String from_name;	//' +{!from_name} + '
	public String tags;	//[SF1,SF3]
    public Map<String, String> toMap;
    public Error_Logs__c errorLogs;
	
    public EmailWrapper(String recordId, String accountId,Boolean saveTask, Boolean saveMessagingHistory,String email,String replyTo, String toName,String subject, 
                                    String fromName, String fromEmail,String templateId,String tagsLi,Map<String,String> responseMap,Error_Logs__c errorLogs ){
                                        this.recordId = recordId;
                                        this.accountId = accountId;
                                        this.createTask = saveTask;
                                        this.saveToInwiseMessagingHistory = saveMessagingHistory;
                                        this.email = email;
                                        this.reply_to = replyTo;
                                        this.toname = toName;
                                        this.subject = subject;
                                        this.from_name = fromName;
                                        this.from_email = fromEmail;
                                        this.template_id = templateId;
                                        this.tags = tagsLi;
                                        this.toMap = responseMap;
                                        this.errorLogs = errorLogs;
        

    }
}