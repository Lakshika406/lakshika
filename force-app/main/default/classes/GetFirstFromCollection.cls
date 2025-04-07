global class GetFirstFromCollection {
@InvocableMethod(label='To check multiple variables')
  global static void convertLeads(List<ConvertLeadActionRequest> requests) {
  
  }
global class ConvertLeadActionRequest {
    @InvocableVariable
    global ID jsonString;

    @InvocableVariable
    global String mobileNumber;

   @InvocableVariable
    global String senderNumber;
   
  }    
}