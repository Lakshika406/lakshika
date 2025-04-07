/******************************************************************************************
*Created By:  NLineAxis
*Created On: Jan/28/2022
*Purpose : Test Code coverage for WrapperFormProperties
******************************************************************************************/
@istest
private class WrapperFormPropertiesTest {

    static testmethod void WrapperFormPropertiesTestMethod(){
    
        WrapperFormProperties listWrap = new WrapperFormProperties();
        listWrap.create_date = 'create test date';
        listWrap.dynamic_page_id = 1234;
        listWrap.id = 1;
        listWrap.update_date = 'update test date';
          
        List<WrapperFormProperties.Fields> listOffields = new List<WrapperFormProperties.Fields>();
        WrapperFormProperties.Fields listOffields1 = new WrapperFormProperties.Fields();
        listOffields1.id = 1234;
        listOffields1.label = 'test string';
        listOffields.add(listOffields1);
        
        listWrap.fields = listOffields;
        String jsonString='[{"action_date":"2016-11-29 09:25:00","contact_id":null,"campaign_id":null,"channel_type":null,"ip":null,"confirmation_date":null,"confirmation_ip":null,"survey_values":{"text98":"972544444444","text99":"lklkl","text100":"kkml@sdfg.com"},"fields_mappings":{"text100":"Email","text99":"Name","text98":"Phone","text-1001":"Send"}}]';
        List<WrapperFormProperties> listOfWrapperFormProperties = WrapperFormProperties.parse(jsonString); 
        
        system.assertEquals(true, listOfWrapperFormProperties.size()> 0);
    }  
}