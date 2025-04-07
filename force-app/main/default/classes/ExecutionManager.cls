/***********************************************************************************
* Name          :  ExecutionManager

* Description   :  to control trigger execution
                  
* Author        :  Kapil Goutam

Modification Log
----------------
Date            Version     Developer         Comments
------------------------------------------------------------------------------------
05/23/2018    1.0.0     K. Goutam          Created
/***********************************************************************************/
public with sharing class ExecutionManager {
	   public static boolean isNeedToByPass_ContactTrigger = false;
     public static boolean isNeedToByPass_LeadTrigger = false;
}