/******************************************************************************************
*Created By:  Shyam Vaishnav
*Created On:  10/11/2021
*Purpose :    Test class for IncomingWebhooksJSON class
/******************************************************************************************/   
@isTest
private class IncomingWebhooksJSON_Test {
    static testmethod void UnitTest() {

        String sampleJSON = '{"timeStamp":"timeStamp", "triggerType":"triggerType", "channelType":"channelType", "sendId":"sendId", "groupId":"groupId", "remarks":"remarks", "ip":"ip",';
        sampleJSON += ' "recipient": {"id":"id", "email":"email", "field1":"field1", "field2":"field2", "field3":"field3", "field4":"field4", "field5":"field5", "field6":"field6", "field7":"field7",';
        sampleJSON += ' "field8":"field8", "field9":"field9", "field10":"field10", "field11":"field11", "field12":"field12", "field13":"field13", "field14":"field14", "field15":"field15", "field16":"field16",';
        sampleJSON += ' "field17":"field17", "field18":"field18", "field19":"field19", "field20":"field20", "field21":"field21", "field24":"field24", "externalID":"externalID"}}';

        IncomingWebhooksJSON.parse(sampleJSON);

        System.assertNotEquals(sampleJSON, '');
    }
}