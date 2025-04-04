({
    phoneNumberSelectOptions: function(component) {
        var opts = [];
        var inputsel = component.find("phonenumber");
        var action = component.get("c.getPhoneNumberSO");
        action.setParams({
            cid : component.get("v.recordId")
        });
        opts.push({"class": "optionClass", label: "--None--", value: ""});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                for(var i = 0; i < response.getReturnValue().length; i++){
                    var msg = response.getReturnValue()[i];
                    opts.push({"class": "optionClass", label: msg.label, value: msg.value});
                }
                var msg = response.getReturnValue();	
                inputsel.set("v.options", opts);
            }     
        });
        $A.enqueueAction(action);
	},
    contactFieldsSelectOptions: function(component){
    	var opts = [];
        var inputsel = component.find("contactfields");
        var action = component.get("c.getlistOfSelectOptionFieldsContact");
        action.setParams({
          cid : component.get("v.recordId")
      	});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                for(var i = 0; i < response.getReturnValue().length; i++){
                    var msg = response.getReturnValue()[i];
                    opts.push({"class": "optionClass", label: msg.label, value: msg.value});
                }
                var msg = response.getReturnValue();	
                inputsel.set("v.options", opts);
            }     
        });
        $A.enqueueAction(action);
    },
    templatesSelectOptions: function(component){
    	var opts = [];
        var inputsel = component.find("templates");
        var action = component.get("c.getTemplatesList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                for(var i = 0; i < response.getReturnValue().length; i++){
                    var msg = response.getReturnValue()[i];
                    opts.push({"class": "optionClass", label: msg.label, value: msg.value});
                }
                var msg = response.getReturnValue();	
                inputsel.set("v.options", opts);
            }     
        });
        $A.enqueueAction(action);
    },
    landingPagesSelectOptions: function(component){
    	var opts = [];
        var inputsel = component.find("landingpages");
        var action = component.get("c.getLandingPagesList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                for(var i = 0; i < response.getReturnValue().length; i++){
                    var msg = response.getReturnValue()[i];
                    opts.push({"class": "optionClass", label: msg.label, value: msg.value});
                }
                var msg = response.getReturnValue();	
                inputsel.set("v.options", opts);
            }     
        });
        $A.enqueueAction(action);
    },
    getContactJson: function(component){
        var jsonstring = "";
        var selectedfieldvalue = "";
        var newvalue = "";
        var action = component.get("c.getcontactJSONString");
        action.setParams({
            cid : component.get("v.recordId")
        });
        var smsbody = component.find("smsbody");
        var selectpage = component.find("contactfields");
        var fieldapiname = selectpage.get("v.value")
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                jsonstring = response.getReturnValue();
                var newResult = JSON.parse(jsonstring);
                selectedfieldvalue = newResult[fieldapiname];
                if(smsbody.get("v.value") == undefined){
                    newvalue = selectedfieldvalue;
                }else{
                    newvalue = (smsbody.get("v.value") + " " +selectedfieldvalue);
                }
                smsbody.set("v.value",newvalue);
            }     
        });
        $A.enqueueAction(action);
    },
    SendSMS: function(component){
        var smsbody = component.find("smsbody");
        var phoneno = component.find("phonenumber");
        var action = component.get("c.SendSMSAndCreateActivity");
        action.setParams({
            messageBody : smsbody.get("v.value"),
            selectedNumber : phoneno.get("v.value"),
            contactid : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                var msg = response.getReturnValue();
                if(msg == "SUCCESS"){
                	alert("SMS Sent Successfully");
                  	$A.get("e.force:closeQuickAction").fire()    
                }else{
              		alert(msg);      
                }	
            }     
        });
        $A.enqueueAction(action);
	},
})