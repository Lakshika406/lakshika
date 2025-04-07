public class IncomingWebhooksJSON {

	public String timeStamp;
	public String triggerType;
	public String channelType;
	public String sendId;
	public String groupId;
	public String remarks;
	public String ip;
	public Recipient recipient;

	public class Recipient {
		public String id;
		public String email;
		public String field1;
		public String field2;
		public String field3;
		public String field4;
		public String field5;
		public String field6;
		public String field7;
		public String field8;
		public String field9;
		public String field10;
		public String field11;
		public String field12;
		public String field13;
		public String field14;
		public String field15;
		public String field16;
		public String field17;
		public String field18;
		public String field19;
		public String field20;
		public String field21;
		public String field24;
		public String externalID;
	}

	
	public static IncomingWebhooksJSON parse(String json) {
		return (IncomingWebhooksJSON) System.JSON.deserialize(json, IncomingWebhooksJSON.class);
	}
}