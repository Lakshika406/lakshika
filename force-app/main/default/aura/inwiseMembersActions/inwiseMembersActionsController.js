({
    doInit : function(component, event, helper) {
        helper.showMsg(component); 
	},
    cancel : function(component, event, helper) {
      $A.get("e.force:closeQuickAction").fire();
   },
    waiting: function(component, event, helper) {
        document.getElementById("Accspinner").style.display = "block";
     },
    doneWaiting: function(component, event, helper) {
       document.getElementById("Accspinner").style.display = "none";
     },    
})