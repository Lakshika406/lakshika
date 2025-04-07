/******************************************************************************************
*Created By	:  NlineAxis
*Created On	:  22-August-2022
*Purpose 	:  Batch Iterable class
Modification Log
----------------
Date              Version   Developer                  Comments
------------------------------------------------------------------------------------
08/22/2022        1.0.0     Shyam Vaishnav             Created
/***********************************************************************************/
global class BatchIterable implements Iterable<String>{

    List<String> listOfString	{set; get;}
	
    public BatchIterable(List<String> stringList){
        listOfString = stringList;
    }
	
    global Iterator<String> Iterator(){
        return new BatchIterator(listOfString);
    }
}