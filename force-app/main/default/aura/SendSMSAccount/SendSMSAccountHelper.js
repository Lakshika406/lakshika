({
    phoneNumberSelectOptions: function(component) {
        var opts = [];
        var inputsel = component.find("phonenumber");
        var action = component.get("c.getPhoneNumberSO");

        action.setParams({
            aid : component.get("v.recordId")
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
    accountFieldsSelectOptions: function(component){
        var opts = [];
        var inputsel = component.find("accountfields");
        var action = component.get("c.getlistOfSelectOptionFieldsAccount");

        action.setParams({
            aid : component.get("v.recordId")
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
    getAccountJson: function(component){
        console.log('getAccountJson call');
        var newvalue = "";
        var jsonstring = "";
        var selectedfieldvalue = "";
        var action = component.get("c.getaccountJSONString");

        action.setParams({
            aid : component.get("v.recordId")
        });
        var smsbody = component.find("smsbody");
        var selectpage = component.find("accountfields");
        var fieldapiname = selectpage.get("v.value");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state----->>',state);
            if(state == "SUCCESS"){
                jsonstring = response.getReturnValue();
                console.log('jsonstring----->>',jsonstring);
                var newResult = JSON.parse(jsonstring);
                selectedfieldvalue = newResult[fieldapiname];
                if(smsbody.get("v.value") == undefined){
                    newvalue = selectedfieldvalue;
                }else{
                    newvalue = (smsbody.get("v.value") + " " + selectedfieldvalue);
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
            accountid : component.get("v.recordId")
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