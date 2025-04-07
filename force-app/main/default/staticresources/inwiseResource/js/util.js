//method for lightning check
function isLightningExperienceOrSalesforce1() {
	return((typeof sforce != 'undefined') && sforce && (!!sforce.one));
}
//redirect on behalf of classic Or lightning flow
function redirectToURL (toURL){
	if( isLightningExperienceOrSalesforce1() ){ 
			  sforce.one.navigateToURL( toURL , true);
	}else{ 
			  window.location = toURL   ;
	} 
}
//start tour overlay
 $(document).ready(function(){
	  var tourhref = '<a id="tourLink" href="javascript:void(0)" onclick="startTour()">inwise how to help</a>';
	  $(".helpLink").parent().parent().html(tourhref);
});

 function startTour(ishelpOnload) {
	var tour = introJs()
	tour.setOption('tooltipPosition', 'auto');
	tour.setOption('positionPrecedence', ['left', 'right', 'bottom', 'top'])
   // tour.setOption("hintPosition","top-middle");
	tour.setOption('skipLabel','X');
	tour.start();
	if(ishelpOnload){
		  jQuery('.introjs-bullets').before('<br/><div style="text-align:left;"><input id="ChkCloseDontShow" type="checkbox" onclick="toggleshowhelp(this);" checked="checked"/>Show next time</div>');
	}else{
		jQuery('.introjs-bullets').before('<br/><div style="position: relative; font-color:red ; text-align:left;"><input id="ChkCloseDontShow" type="checkbox" onclick="toggleshowhelp(this);"  />Show next time</div>');
	}

}
 function toggleshowhelp(ctrl){
	var checkBoxCtrl = ctrl;
	 jsToggleshowhelp(checkBoxCtrl.checked);
}
function hideTour(){
	$(".introjs-button.introjs-skipbutton").click();
}