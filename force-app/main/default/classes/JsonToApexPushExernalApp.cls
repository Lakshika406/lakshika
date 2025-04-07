/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 
*Purpose :    
/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: 22 Feb 2018
*Purpose :  Parse the response when getting Response from PushExternalApp Api

Modification Log
----------------
Date                  Version     Developer                  Comments
------------------------------------------------------------------------------------
05/03/2019            1.0.0       K.Goutam                 Created 

/******************************************************************************************/
public class JsonToApexPushExernalApp {
public class Errors {
        public String external_id;
        public String details;
    }
   

    public String status;
    public Integer processed;
    public List<String> created;
    public List<Errors> errors;
    public List<Errors> conflicts;
    public List<String> updated;

    
    public static JsonToApexPushExernalApp parse(String json) {
      
        return (JsonToApexPushExernalApp) System.JSON.deserialize(json, JsonToApexPushExernalApp.class);
    }
}