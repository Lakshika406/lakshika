/******************************************************************************************
*Created By	:  NlineAxis
*Created On	:  22-August-2022
*Purpose 	:  Batch Iterator class
Modification Log
----------------
Date              Version   Developer                  Comments
------------------------------------------------------------------------------------
08/22/2022        1.0.0     Shyam Vaishnav             Created
/***********************************************************************************/
global class BatchIterator implements Iterator<String>{
    
	Integer counter				{set; get;}
    List<String> listOfString	{set; get;}
    
    public BatchIterator(List<String> stringList){
        listOfString = stringList;
        counter = 0;
    }
    
    global Boolean hasNext(){
      return counter >= listOfString.size() ? false : true;
    }
	
    global String next(){
        counter++;
        return listOfString[counter-1];
    }
}