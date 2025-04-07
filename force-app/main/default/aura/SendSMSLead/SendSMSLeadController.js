({
    doInIt: function(component, event, helper){
        helper.phoneNumberSelectOptions(component);
        helper.LeadFieldsSelectOptions(component);
        helper.landingPagesSelectOptions(component);
        helper.templatesSelectOptions(component);
    },
    onChangeTemplate: function(component, event, helper){
        var selectpage = component.find("templates");
        var smsbody = component.find("smsbody");
        var newvalue = "";
        if(smsbody.get("v.value") == undefined){
            newvalue = ("#landing_" + selectpage.get("v.value") + "#");
        }else{
            newvalue = (smsbody.get("v.value") + " #landing_" + selectpage.get("v.value") + "#");
        }
        smsbody.set("v.value", newvalue);
    },
    onChangeLandingPage: function(component, event, helper){
        var selectpage = component.find("landingpages");
        var smsbody = component.find("smsbody");
        var newvalue = "";
        if(smsbody.get("v.value") == undefined){
            newvalue = ("#landing_" + selectpage.get("v.value") + "#");
        }else{
            newvalue = (smsbody.get("v.value") + " #landing_" + selectpage.get("v.value") + "#");
        }
        smsbody.set("v.value", newvalue);
    },
    onChangeMergeField: function(component, event, helper){
        helper.getLeadJson(component);
    },
    doSendSMS: function(component,event,helper){
        helper.SendSMS(component);        
    },
})