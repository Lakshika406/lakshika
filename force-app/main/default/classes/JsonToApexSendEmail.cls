public class JsonToApexSendEmail {
    public class SendEmail {
        public String email{get;set;}
        public String status{get;set;}
        public String reject_reason{get;set;}
        public String transaction_id{get;set;}
        public String code{get;set;}
      }
    
      
      public static List<SendEmail> parse(String json) {
        return (List<SendEmail>) System.JSON.deserialize(json, List<JsonToApexSendEmail.SendEmail>.class);
      }
}