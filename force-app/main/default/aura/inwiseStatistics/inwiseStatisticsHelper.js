({
	showMsg : function(component,event,helper) {
		var action = component.get("c.getMsg");
        //var src = event.getSource().getLocalId();
        var at = "inwiseStatistics";
        action.setParams({
            recId : component.get("v.recordId"), 
            actionType : at
        });      
        action.setCallback(this,function(response){
         var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var msg = response.getReturnValue();
                component.set("v.message",msg);
            }
        });	
        $A.enqueueAction(action);
	},
})