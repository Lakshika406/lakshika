({
	doInit : function(component, event, helper) {
        console.log('==doInit=');
        setTimeout(function(){
            		$A.get("e.force:closeQuickAction").fire(); 
		}, 10);
        
 		 var action = component.get('c.getuserLicence'); 
        action.setCallback(this, function(a){
            var state = a.getReturnValue(); // get the response state
            if(state == true) {
             window.open("/apex/inwise__ConversationViewPage?id="+component.get("v.recordId"), "_self");
            }else{
                window.open("/apex/ConversationViewPage?id="+component.get("v.recordId"), "_self");
            }
        });
    	$A.enqueueAction(action);	
	}
    
    
})