public class WhatsappWrapper{
	public String recordId;	//' +{!$Record.Id}+'
	public String content;	// ' +{!content}+' 
	public String template_id;	//' +{!template_id} + '
	public String mobileNumber;	//'+{!mobileNumber}+'
	public boolean saveToInwiseMessagingHistory;
	public boolean createTask;
	public String tags;	//[SF1,SF3]
	public String accountId;	//
	public String media_url;	// ' + {!media_url}+' 
	public boolean async;
	public String template_fields_mapping;	//  [{key: 1,value: field3},{key: 2,value: field5}] 
    public Map<String, String> toMap;
    public Error_Logs__c errorLogs;
	
    public WhatsappWrapper(String templateId, String content,Boolean saveTask, Boolean saveMessagingHistory,String accountId,String mobileNumber, String media_url, 
                                    Boolean async, String templateFieldsMapping,String recordId,String tagsLi,Map<String,String> responseMap,Error_Logs__c errorLogs ){
                                        this.recordId = recordId;
                                        this.accountId = accountId;
                                        this.createTask = saveTask;
                                        this.saveToInwiseMessagingHistory = saveMessagingHistory;
                                        this.content = content;
                                        this.mobileNumber = mobileNumber;
                                        this.media_url = media_url;
                                        this.async = async;
                                        this.template_fields_mapping = templateFieldsMapping;
                                        this.template_id = templateId;
                                        this.tags = tagsLi;
                                        this.toMap = responseMap;
                                        this.errorLogs = errorLogs;
        

    }
	
}