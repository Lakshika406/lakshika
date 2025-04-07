/******************************************************************************************
*Created By:  Kapil Goutam
*Created On: Nov/07/2019
*Purpose :   For new response in FormProperties call
******************************************************************************************/
public with sharing class WrapperFormProperties {
    public class Fields {
        public Integer id{get;set;}
        public String label{get;set;}
    }

    public Integer id{get;set;}
    public Integer dynamic_page_id{get;set;}
    public String create_date{get;set;}
    public String update_date{get;set;}
    public List<Fields> fields{get;set;}


    public static List<WrapperFormProperties> parse(String json) {
        return (List<WrapperFormProperties>) System.JSON.deserialize(json, List<WrapperFormProperties>.class);
    }
}