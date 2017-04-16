//------------------------------------------------------------------------------------------------+
//                                                                                                |
//                                     SonicR FFCal Panel.mq4                                     |
//                                                                                                |
//------------------------------------------------------------------------------------------------+
#property copyright "Copyright @ 2013 traderathome"
#property link      "email: traderathome@msn.com" 

/*=================================================================================================
Overview, _v3:

This is a special version of the FFCal.mq4 indicator designed especially for the Sonic R. System.
It places a panel on the chart in which are displayed up to four news releases listed on the 
Forex Factory Calendar.  Significant changes are made since the last release.  These changes are
summarized at the bottom of these User Notes.

The time, title and ranking (by color) of the releases are shown.  The time of a releases is 
important because the market frequently holds price moves until after important releases come out.  
The title of the release, and it's ranking by color, is important because the variety of low 
impact releases frequently have no effect on price, whereas the variety of high impact releases 
can trigger a big price move.                   

Of the three impact level events (High, Medium, Low) and Bank Holidays, you have the option to not 
show all but the High Impact events.  The Previous/Forecast data (available on the Forex Factory
Calendar) is not displayed because prices can go either way regardless of specifics released.  it 
is the timing of news that is important, as a market volatility event.  The vertical display and 
the second alert of the original FFCal. mq4 indicator are removed, but one alert remains.

Prioritization of events is fully automated and two more event labels are added to help avoid
surprises.  When two or more events occur simultaneously, only one event of the highest impact
displays unless there are multiple high impact events.  In that case the multple high impact 
events are displayed.  When 2nd, 3rd or 4th events are not scheduled, text noting that appears.  
A current day Bank Holiday will remain displayed in the first label until the Bank Holiday is 
over.  You can show events for any pair on any chart.  For example, you can show  a CNY (China) 
event on a AUDUSD chart.       

You can select a range of TFs for the display of this indicator, so it automatically will not 
display on a chart TF outside that range.  The indicator can be turned on/off without having 
to remove it from the chart, thereby preserving your chart settings. 

Changes from previous release 04-04-2012 to current release 05-01-2012:
01 - Corrected errors in coding of prioritization of previous and current/future events. 
02 - Revised order of External Inputs.

Changes from previous release 05-01-2012 to current release xx-xx-2013: 
01 - Removes outdated .xml files (through previous year) from Experts files.
02 - Saves current files without the chart TF in the file name (reduces current files needed).
03 - Removes all reference to Broker Watermark, which new coding automatically handles.
04 - adds options for sub-window and right side of chart locations.
05 - adds option to not show the panel background.
06 - prefixes background boxes with "z" assuring "on top" display.
                           
                                                                       - Traderathome, 05-20-2013
--------------------------------------------------------------------------------------------------
ACKNOWLEDGEMENTS:

derkwehler and other contributors - the core code of the FFCal indicator,
                                    FFCal_v20 dated 07/07/2009, Copyright @ 2006 derkwehler 
                                    http://www.forexfactory.com/showthread.php?t=19293
                                    email: derkwehler@gmail.com  
                                                                     
=================================================================================================*/	
 
 
//+-----------------------------------------------------------------------------------------------+
//| Indicator Global Inputs                                                                       |
//+-----------------------------------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  CLR_NONE

#define TITLE		0
#define COUNTRY   1
#define DATE		2
#define TIME		3
#define IMPACT		4
#define FORECAST	5
#define PREVIOUS	6

/*-------------------------------------------------------------------------------------------------
Suggested Colors:                    White Charts          Black Charts

FFCal_Title                          Black                 C'180,180,180'
News_Low_Impact                      Green                 C'046,186,046'
News_Medium_Impact                   MediumBlue            C'086,138,235'
News_High_Impact                     Crimson               C'217,000,000'
Bank_Holiday_Color                   DarkOrchid            Orchid
Remarks_Color                        DarkGray              DimGray      
Background_Color_                    White                 Black
-------------------------------------------------------------------------------------------------*/


//global external inputs---------------------------------------------------------------------------
extern string Part_1                          = "Indicator Display Controls:";
extern bool   Indicator_On                    = true;
extern bool   Allow_Panel_In_Subwindow_1      = false; 
extern bool   Allow_Panel_At_Chart_Right      = false;
extern int    Display_Min_TF                  = 1;
extern int    Display_Max_TF                  = 43200;
extern string TF_Choices_1                    = "M1 - H4 =  1, 5, 15, 30, 60, 240";
extern string TF_Choices_2                    = "D  W  M =  1440,  10080,  43200";

extern string __                              = "";
extern string Part_2                          = "Headline Display Settings:";
extern color  FFCal_Title 	                   = C'180,180,180'; 
extern color  Low_Impact_News_Color           = C'046,186,046';
extern bool   Low_Impact_News_On              = true;             
extern color  Medium_Impact_News_Color        = C'086,138,235';
extern bool   Medium_Impact_News_On           = true;       
extern color  High_Impact_News_Color          = C'217,000,000';
extern color  Bank_Holiday_Color              = Orchid;  
extern bool   Bank_Holiday_On                 = true;
extern color  Remarks_Color                   = DimGray;
extern bool   Show_Panel_Background           = true;     
extern color  Background_Color_               = Black; 
extern int	  Alert_Minutes_Before            = 0;	    //Set to "0" for no Alert
extern int	  Offset_Hours	                   = 0;     //Set to "0" to not adjust time/DST settings

extern string ___                             = "";
extern string Part_3                          = "Other Currency News Settings:";
extern bool	  Show_USD_News                   = false; //"true" = USD news on non-USD pair charts 
extern bool	  Show_EUR_News                   = false; 
extern bool	  Show_GBP_News                   = false;
extern bool	  Show_NZD_News                   = false;
extern bool	  Show_JPY_News                   = false;
extern bool	  Show_AUD_News                   = false;
extern bool	  Show_CAD_News                   = false; 
extern bool	  Show_CHF_News                   = false;
extern bool	  Show_CNY_News                   = false;

//global buffers and variables---------------------------------------------------------------------
bool        Deinitialized, skip; 
bool        FLAG_done0, FLAG_done1, FLAG_done2, FLAG_done3; 
bool        FLAG_none0, FLAG_none1, FLAG_none2, FLAG_none3; 
int         BankIdx1,cnr;
color       TxtColorNews;
datetime    newsTime;
double   	ExtMapBuffer0[];     // Contains (minutes until) each news event
int 	      xmlHandle, BoEvent, finalend, end, begin, minsTillNews, tmpMins, idxOfNext, dispMinutes[9];
int         newsIdx, next, nextNewsIdx, dispMins, Days, Hours, Mins;
int         dayStart,monthStart,F1,F2,i,j,k,curY,W,sx,sfx,Box,x1,x2,x3,y1,y2,y3,index;
int         WebUpdateFreq = 240; // 240 Minutes between web updates to not overload FF server
int         TxtSize       = 7;   
int         TitleSpacer   = 7;
int         EventSpacer   = 4; 
int         curX          = 3;       
static int	PrevMinute    = -1;
static bool NeedToGetFile = false;
string 		xmlFileName;
string      xmlSearchName;
string	   sUrl = "http://www.forexfactory.com/ff_calendar_thisweek.xml"; //original
string   	myEvent,mainData[100][7], sData, csvoutput, sinceUntil, TimeStr;
string    	G,pair, cntry1, cntry2, dispTitle[9], dispCountry[9], dispImpact[9],event[4];
string 	   sTags[7] = { "<title>", "<country>", "<date><![CDATA[", "<time><![CDATA[", "<impact><![CDATA[", "<forecast><![CDATA[", "<previous><![CDATA[" };
string 	   eTags[7] = { "</title>", "</country>", "]]></date>", "]]></time>", "]]></impact>", "]]></forecast>", "]]></previous>" };
string      Text_Style = "Arial";     
string      box1    = "z[FFCal] Box1";
string      box2    = "z[FFCal] Box2";
string      News1   = "z[FFCal] News1";
string      News2   = "z[FFCal] News2";
string      News3   = "z[FFCal] News3";
string      News4   = "z[FFCal] News4";
string      Sponsor = "z[FFCal] Sponsor";  

//+-----------------------------------------------------------------------------------------------+
//| Indicator Initialization                                                                      |
//+-----------------------------------------------------------------------------------------------+
int init()
   {
	//Make sure we are connected.  Otherwise exit.   
   //With the first DLL call below, the program will exit (and stop) automatically after one alert. 
   if ( !IsDllsAllowed() ) 
      {
      Alert("SonicR FFCal Headlines: Check 'Allow DLL Imports'");   
      }
      	
	//Management of FFCal.xml Files:
	//Set up a search loop for current year. Find and delete files not of current date.
	xmlFileName = GetXmlFileName();
	//Do current and previous year
	for(k=Year(); k>=Year()-1; k--)
	  {//Do all twelve months of each year		 
	  for(i=12; i>=1; i--)	
	    {
	    if(i==Month()) {dayStart = Day();}
	    else {dayStart = 31;}  
	    for(j=dayStart; j>=1; j--)	  
	      {
	      //Delete all files for this pair ID and period that are not of current date.
	      //Non-current files with and without the TF/period will be deleted.
	      xmlSearchName= (i + "-" + j + "-" + k + "-" + Symbol() + "-" + "FFCal.xml");
	      xmlHandle = FileOpen(xmlSearchName, FILE_BIN|FILE_READ);
	      if(xmlHandle >= 0) //file exists.  A return of -1 means file does not exist.
	        {
	        FileClose(xmlHandle); 
	        FileDelete(xmlSearchName);       
	        }
	      }
	    }
	  }             
         
   Deinitialized = false;

   cnr = 2; if(Allow_Panel_At_Chart_Right) {cnr = 3;}
   
   if(Allow_Panel_In_Subwindow_1 && WindowsTotal( ) > 1){W= 1;}
   else {W= 0;}
    
	SetIndexBuffer(0, ExtMapBuffer0);
   SetIndexStyle(0, DRAW_NONE);		
   IndicatorShortName("FFCal");    
      	  		
	return(0);
   }
   
//+-----------------------------------------------------------------------------------------------+
//| Indicator De-initialization                                                                   |
//+-----------------------------------------------------------------------------------------------+
int deinit()
   {         
   int obj_total= ObjectsTotal();  
   for (i= obj_total; i>=0; i--) {
      string name= ObjectName(i);
      if (StringSubstr(name,0,8)=="z[FFCal]") {ObjectDelete(name);}} 
 	  
	//If xml file exists we need to delete it 
	xmlFileName =GetXmlFileName();
	//File does not exist if FileOpen returns -1 	
	xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_READ|FILE_WRITE);
	if (xmlHandle >= 0)
	   {
		//Since file exists, close and delete it
		FileClose(xmlHandle);		
		FileDelete(xmlFileName);
	   } 
	   
	//Comment(" "); 	     
	return(0);
   }
  
//+-----------------------------------------------------------------------------------------------+
//| Indicator Start                                                                               |
//+-----------------------------------------------------------------------------------------------+  
int start()
   {
   //If Indicator is "Off" or chart is out of range deinitialize only once, not every tick.
   if((!Indicator_On) || ((Period() < Display_Min_TF) || (Period() > Display_Max_TF)))        
      {
      if (!Deinitialized)  {deinit(); Deinitialized = true;} 
      return(0);
      }    
     
   //Otherwise indicator is "On", chart TF is in display range.  Proceed.  
   Deinitialized = false;

   //Check if the XML file exists.  If not, set a flag showing the need to get it.
	xmlFileName = GetXmlFileName();	
	xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_READ);
   //File exists if FileOpen return is >=0 	
	if (xmlHandle >= 0) {FileClose(xmlHandle); NeedToGetFile = false;}
	//File does not exist if FileOpen return is -1 	
	else NeedToGetFile = true;
	
	//----------------------------------------------------------------------------------------------
	//WebUpdates New method: Use global variables so that when put on multiple charts, it 
	//will not update overly often; only first time and every 4 hours	per "WebUpdateFreq".		
  	if (NeedToGetFile || GlobalVariableCheck("LastUpdateTime") == false || 
  		(TimeCurrent() - GlobalVariableGet("LastUpdateTime")) > WebUpdateFreq)
		{	
		GrabWeb(sUrl, sData);		
   	//if time for web update, delete existing file if it exists	
	   xmlFileName = GetXmlFileName();
	   xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_READ|FILE_WRITE);
	   //File exists if FileOpen return >=0. 
	   if (xmlHandle >= 0) {FileClose(xmlHandle); FileDelete(xmlFileName);}	   		

		//Open new XML.  Write the ForexFactory page contents to a .htm file.  Close new XML.
		xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_WRITE);		   
		FileWriteString(xmlHandle, sData, StringLen(sData));
		FileClose(xmlHandle);
		
		//Find the XML end tag to ensure a complete page was downloaded.
		end = StringFind(sData, "</weeklyevents>", 0);
		//End of file tag is not found if return -1 (or, "end <=0" in this case).
		if (!end >= 0) 
		  {
		  Alert("FFCal:   ",Symbol(),"-",Period(),"   .xml download incompete!");
		  return(false);
		  }
		else {GlobalVariableSet("LastUpdateTime", TimeCurrent());} // set global to time of last update			
		}
		
	//----------------------------------------------------------------------------------------------
	//Perform remaining checks once per minute (Refreshing News from XML file)
	if (Minute() == PrevMinute) return (true);
	PrevMinute = Minute();

	//Init the buffer array to zero just in case
	ArrayInitialize(ExtMapBuffer0, 0);
	
	//Open, read and close the XML file
	xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_READ);
	//Avg. file length == ~7K, so 65536 should always read whole file
	sData = FileReadString(xmlHandle, 65536);	
   if (StringLen(sData) < FileSize(xmlHandle)) sData = sData + FileReadString(xmlHandle, FileSize(xmlHandle));		
	if (xmlHandle > 0) FileClose(xmlHandle);

	//Get the currency pair, and split it into the two countries
	pair = Symbol();
	cntry1 = StringSubstr(pair, 0, 3);
	cntry2 = StringSubstr(pair, 3, 3);

	//Clear prioritization data
	BankIdx1   = 0; 
	FLAG_done0 = false; 
   FLAG_done1 = false;  
   FLAG_done2 = false;
   FLAG_done3 = false;
   FLAG_none0 = false;    
   FLAG_none1 = false; 
   FLAG_none2 = false;
   FLAG_none3 = false;  
	for (i=0; i<=9; i++)
	   {
	   dispTitle[i]   = "";
	   dispCountry[i] = "";
	   dispImpact[i] 	= "";
	   dispMinutes[i]	= 0;	
      }

	//Parse the XML file looking for an event to report		
	newsIdx = 0;
	nextNewsIdx = -1;	
	tmpMins = 10080;	// (a week)
	BoEvent = 0;
	while (true)
   	{
		BoEvent = StringFind(sData, "<event>", BoEvent);
		if (BoEvent == -1) break;			
		BoEvent += 7;	
		next = StringFind(sData, "</event>", BoEvent);
		if (next == -1) break;	
		myEvent = StringSubstr(sData, BoEvent, next - BoEvent);
		BoEvent = next;		
		begin = 0;
		skip = false;
		for (i=0; i < 7; i++)
		   {
			mainData[newsIdx][i] = "";
			next = StringFind(myEvent, sTags[i], begin);			
			// Within this event, if tag not found, then it must be missing; skip it
			if (next == -1) continue;
			else
			   {
				// We must have found the sTag okay...
				begin = next + StringLen(sTags[i]);		   	// Advance past the start tag
				end = StringFind(myEvent, eTags[i], begin);	// Find start of end tag
				//Get data between start and end tag
				if (end > begin && end != -1) {mainData[newsIdx][i] = StringSubstr(myEvent, begin, end - begin);}
			   }
		   }//End "for" loop
	
		//Test against filters that define whether we want to skip this particular announcement
      //Look for a Bank Holiday for current day
      
		if ( (Bank_Holiday_On &&  BankIdx1 == 0) &&
			(mainData[newsIdx][IMPACT] == "Holiday") &&			   		   
		   ((cntry1 == mainData[newsIdx][COUNTRY]) || 
		   (cntry2 == mainData[newsIdx][COUNTRY]) ||
		   (Show_USD_News && mainData[newsIdx][COUNTRY] == "USD") || 
			(Show_EUR_News && mainData[newsIdx][COUNTRY] == "EUR") || 
			(Show_GBP_News && mainData[newsIdx][COUNTRY] == "GBP") || 
			(Show_NZD_News && mainData[newsIdx][COUNTRY] == "NZD") || 
			(Show_JPY_News && mainData[newsIdx][COUNTRY] == "JPY") || 
			(Show_AUD_News && mainData[newsIdx][COUNTRY] == "AUD") || 
			(Show_CAD_News && mainData[newsIdx][COUNTRY] == "CAD") || 
			(Show_CHF_News && mainData[newsIdx][COUNTRY] == "CHF") || 
			(Show_CNY_News && mainData[newsIdx][COUNTRY] == "CNY") ))
		   {
		   newsTime = StrToTime(MakeDateTime(mainData[newsIdx][DATE], mainData[newsIdx][TIME]));
			minsTillNews = (newsTime - TimeGMT()) / 60;			
			//Only capture the current day Bank Holiday
			if ((minsTillNews > -1440) && (minsTillNews <= 0)) 
			   {
			   BankIdx1       = 1;			      
			   dispCountry[7] = mainData[newsIdx][COUNTRY];
			   dispMinutes[7] = minsTillNews;
			   dispTitle[7]	=  "Start " + mainData[newsIdx][TITLE];
			   dispImpact[7]  = "Holiday";	
				}			   				   
		   }
		   						
		else if ((cntry1 != mainData[newsIdx][COUNTRY] && cntry2 != mainData[newsIdx][COUNTRY]) &&
			((!Show_USD_News || mainData[newsIdx][COUNTRY] != "USD") && 
			(!Show_EUR_News || mainData[newsIdx][COUNTRY] != "EUR") && 
			(!Show_GBP_News || mainData[newsIdx][COUNTRY] != "GBP") && 
			(!Show_NZD_News || mainData[newsIdx][COUNTRY] != "NZD") && 
			(!Show_JPY_News || mainData[newsIdx][COUNTRY] != "JPY") && 
			(!Show_AUD_News || mainData[newsIdx][COUNTRY] != "AUD") && 
			(!Show_CAD_News || mainData[newsIdx][COUNTRY] != "CAD") && 
			(!Show_CHF_News || mainData[newsIdx][COUNTRY] != "CHF") && 
			(!Show_CNY_News || mainData[newsIdx][COUNTRY] != "CNY")))
			{skip = true;}	
			
		else if ((!Medium_Impact_News_On) && 
		   (mainData[newsIdx][IMPACT] == "Medium"))
		   {skip = true;} 
		   														   
		else if ((!Low_Impact_News_On) && 
		   (mainData[newsIdx][IMPACT] == "Low"))
		   {skip = true;} 
		   
		else if ((!Bank_Holiday_On) &&		
	      (mainData[newsIdx][IMPACT] == "Holiday"))
			{skip = true;}	
			
   	else if ((mainData[newsIdx][TIME] == "All Day" && mainData[newsIdx][TIME] == "") || 
		   (mainData[newsIdx][TIME] == "Tentative" && mainData[newsIdx][TIME] == "")     ||
		  	(mainData[newsIdx][TIME] == ""))
		  	{skip = true;}			  	
		    				  	 				  	 
		//If not skipping this event, then log time to event it into ExtMapBuffer0
		if (!skip)
		   {   
			//If we got this far then we need to calc the minutes until this event
			//First, convert the announcement time to seconds (in GMT)
			newsTime = StrToTime(MakeDateTime(mainData[newsIdx][DATE], mainData[newsIdx][TIME]));			
			// Now calculate the minutes until this announcement (may be negative)
			minsTillNews = (newsTime - TimeGMT()) / 60;
			
         //If this is a Bank Holiday current or past event, skip it by changing time to 2 days back
         if ((StringFind(mainData[newsIdx][TITLE], "Bank Holiday", StringLen(mainData[newsIdx][TITLE])-12) != -1) &&
            (minsTillNews <= 0))
            {
            minsTillNews = minsTillNews - 2880;
            }
            
			//At this point, only events applicable to the pair ID/Symbol are being processed:
			//Find the most recent past event.  Do this by incrementing idxOfNext for each event 
			//with a past time, (i.e. minsTillNews < 0).  When coming upon the first event with 
			//minsTillNews > 0, idxOfNext is not incremented, and therefore continues to be for 
			//the most recent past event.  It does not get incremented again until the absolute 
			//value of the time since this most recent past event exceeds the time to the next
			//future event.
			
			if (minsTillNews < 0 || MathAbs(tmpMins) > minsTillNews)	{idxOfNext = newsIdx; tmpMins	= minsTillNews;}	
						
			//Do alert if user has enabled
			if (Alert_Minutes_Before != 0 && minsTillNews == Alert_Minutes_Before)
				Alert(Alert_Minutes_Before, " minutes until news for ", pair, ": ", mainData[newsIdx][TITLE]);
						
			//ExtMapBuffer0 contains the time UNTIL each announcement (can be negative)
			//e.g. [0] = -372; [1] = 25; [2] = 450; [3] = 1768 (etc.)
			ExtMapBuffer0[newsIdx] = minsTillNews;
			
			newsIdx++;
		   }//End "skip" routine
	   }//End "while" routine
	   
	//----------------------------------------------------------------------------------------------
   //Cycle thru the range of "newsIdx" prioritizing events for display.
	for (i=0; i < newsIdx; i++)
	   {
      //The 1st event to be displayed is either a past event, or an upcoming event, whichever is the
      //most close in time.  If the 1st event is a past event, then look at the three previous past
      //events.  For any of them that occurred at the same time as the 1st event, choose for display
      //the most recent one with a higher impact.  If none have a higher impact, then stay with the
      //1st event.
      
      //Get 4th previous item:
      if (i == idxOfNext-3) 
         {    
			dispTitle[6]	   = mainData[i][TITLE];
			dispCountry[6] 	= mainData[i][COUNTRY];
			dispImpact[6]  	= mainData[i][IMPACT];
			dispMinutes[6] 	= ExtMapBuffer0[i];      
         }      
      //Get 3rd previous item:
      if (i == idxOfNext-2) 
         {      
			dispTitle[5]	   = mainData[i][TITLE];
			dispCountry[5] 	= mainData[i][COUNTRY];
			dispImpact[5]  	= mainData[i][IMPACT];
			dispMinutes[5] 	= ExtMapBuffer0[i];      
         }
      //Get 2nd previous item:   
      if (i == idxOfNext-1) 
         {   
			dispTitle[4]	   = mainData[i][TITLE];
			dispCountry[4] 	= mainData[i][COUNTRY];
			dispImpact[4]  	= mainData[i][IMPACT];
			dispMinutes[4] 	= ExtMapBuffer0[i];      
         }  
      //Get previous/current items:        
      if (i == idxOfNext)  
         {
         dispTitle[0]	   = mainData[i][TITLE];
			dispCountry[0] 	= mainData[i][COUNTRY];
			dispImpact[0]  	= mainData[i][IMPACT];
			dispMinutes[0] 	= ExtMapBuffer0[i];
         //If idxOfNext is a previous event, then compare to 2nd, 3rd and 4th previous events.
         //If none of these three also previous events have the same time and a higher impact,
         //stay with the most recent previous event ([0]):  			         
         if (dispMinutes[0] <= 0) 
            {
	         //if time [0] = [4] and [4] is > impact than [0], then [4] becomes 1st event [0]
	         //In other words, if 2nd previous event back is of higher impact use it:
	         if ((dispMinutes[0] == dispMinutes[4]) &&		
	         ((dispImpact[0] == "Medium" && dispImpact[4] == "High")  ||
			   (dispImpact[0]  == "Low"    && dispImpact[4] == "High")  ||
			   (dispImpact[0]  == "Low"    && dispImpact[4] == "Medium")))
		 	      {		 	   
		   	   dispTitle[0]	= dispTitle[4];
			      dispCountry[0] = dispCountry[4];
			      dispImpact[0]  = dispImpact[4];
			      dispMinutes[0] = dispMinutes[4];
			      }	                                       									
		      //if time [0] = [5] and [5] is > impact than [0], then [5] becomes 1st event [0]
		      //In other words, if 3rd previous event back is of higher impact use it: 
	         else if ((dispMinutes[0] == dispMinutes[5]) &&		
	         ((dispImpact[0] == "Medium" && dispImpact[5] == "High")  ||
			   (dispImpact[0]  == "Low"    && dispImpact[5] == "High")  ||
			   (dispImpact[0]  == "Low"    && dispImpact[5] == "Medium")))
		 	      {		 	   
		      	dispTitle[0]   = dispTitle[5];
			      dispCountry[0] = dispCountry[5];
			      dispImpact[0]  = dispImpact[5];
			      dispMinutes[0] = dispMinutes[5];						   
               }
            //if time [0] = [6] and [6] is  > impact than [0], then [6] becomes 1st event [0]
            //In other words, if 4th previous event back is of higher impact use it:
	         else if ((dispMinutes[0] == dispMinutes[6]) &&		
	         ((dispImpact[0] == "Medium" && dispImpact[6] == "High")  ||
			   (dispImpact[0]  == "Low"    && dispImpact[6] == "High")  ||
			   (dispImpact[0]  == "Low"    && dispImpact[6] == "Medium")))
		 	      {		 	   
		      	dispTitle[0]   = dispTitle[6];
			      dispCountry[0] = dispCountry[6];
			      dispImpact[0]  = dispImpact[6];
			      dispMinutes[0] = dispMinutes[6];						   
               }   					   
            }
         }   
         
		//---------------------------------------------------------------- 	            
      //Now that 1st event[0] is initialized, go thru rest of items, prioritizing.  
		if (i >= idxOfNext+1)  
		   {  
         dispTitle[6]	= mainData[i][TITLE];
			dispCountry[6] = mainData[i][COUNTRY];
			dispImpact[6]  = mainData[i][IMPACT];
			dispMinutes[6] = ExtMapBuffer0[i];
			//If 1st event [0] is not done with prioritization, and         		   
			//if time [i] = [0] and [i] has > impact than [0] then [i] becomes 1st event [0].
	   	//Otherwise, if time [i] > [0] then initialize [i] as 2nd event [1]: 
	   	if (!FLAG_done0) 
	   	   { 
			   if ((dispMinutes[0] == dispMinutes[6]) && 			
	            ((dispImpact[0]  == "Medium" && dispImpact[6] == "High")  ||
			      (dispImpact[0]   == "Low"    && dispImpact[6] == "High")  || 
			      (dispImpact[0]   == "Low"    && dispImpact[6] == "Medium")))
		 	      {
               dispTitle[0]	  = dispTitle[6];
			      dispCountry[0]   = dispCountry[6];
			      dispImpact[0]    = dispImpact[6];
			      dispMinutes[0]   = dispMinutes[6];	 	   		 	   		 	   			
			      }		      
		      else if ((dispMinutes[0] < dispMinutes[6]) ||
		         ((dispMinutes[0] == dispMinutes[6]) && (dispImpact[6] == "High")) )    
		         {
               dispTitle[1]	  = dispTitle[6];
			      dispCountry[1]   = dispCountry[6];
			      dispImpact[1]    = dispImpact[6];
			      dispMinutes[1]   = dispMinutes[6];
			      FLAG_done0 = true;
			      continue;
		         }		         
		      }
		   //If 1st event [0] is done prioritization, but 2nd event [1] is not, and   
			//if time [i] = [1] and [i] has > impact than [1], then [i] becomes 2nd event [1].
			//Otherwise, if time [i] > [1] then intialize [i] as 3rd event [2]: 
         if ((FLAG_done0) && (!FLAG_done1)) 
		      {			 			   	
			   if ((dispMinutes[1] == dispMinutes[6]) && 		
	            ((dispImpact[1]  == "Medium" && dispImpact[6] == "High")  ||
			      (dispImpact[1]   == "Low"    && dispImpact[6] == "High")  || 
			      (dispImpact[1]   == "Low"    && dispImpact[6] == "Medium")))
		 	      {
               dispTitle[1]	   = dispTitle[6];
			      dispCountry[1] 	= dispCountry[6];
			      dispImpact[1]  	= dispImpact[6];
			      dispMinutes[1] 	= dispMinutes[6];	
			      }
			   else if ((dispMinutes[1] < dispMinutes[6]) ||
		         ((dispMinutes[1] == dispMinutes[6]) && (dispImpact[6] == "High")) )  			   		    
			      {
               dispTitle[2]	   = dispTitle[6];
			      dispCountry[2] 	= dispCountry[6];
			      dispImpact[2]  	= dispImpact[6];
			      dispMinutes[2] 	= dispMinutes[6];					      
			      FLAG_done1 = true;
			      continue;
			      }   
			   }
	      //If 1st event [0] and 2nd event [1] are done, but 3rd event [2] is not, and
			//if time [i] = [2] and [i] has > impact than [2], then [i] becomes 3rd event [2].
		   //Otherwise, if time [i] > [2] then intialize [i] as 4th event [3]:  	
         if ((FLAG_done0) && (FLAG_done1) && (!FLAG_done2)) 
		      {						   
			   if ((dispMinutes[2] == dispMinutes[6]) && 		
	            ((dispImpact[2]  == "Medium" && dispImpact[6] == "High")  ||
			      (dispImpact[2]   == "Low"    && dispImpact[6] == "High")  || 
			      (dispImpact[2]   == "Low"    && dispImpact[6] == "Medium")))
		 	      {
               dispTitle[2]	   = dispTitle[6];
			      dispCountry[2] 	= dispCountry[6];
			      dispImpact[2]  	= dispImpact[6];
			      dispMinutes[2] 	= dispMinutes[6];		   			        		 	   		 	   		 	   			
			      }
			   else if ((dispMinutes[2] < dispMinutes[6]) ||
		         ((dispMinutes[2] == dispMinutes[6]) && (dispImpact[6] == "High")) )  			    
			      {
               dispTitle[3]	   = dispTitle[6];
			      dispCountry[3] 	= dispCountry[6];
			      dispImpact[3]  	= dispImpact[6];
			      dispMinutes[3] 	= dispMinutes[6];					      
			      FLAG_done2 = true;
			      continue;
			      }  
			   }
         //If 1st, 2nd, and 3rd events are done, but 4th event [3] is not, and
			//if time [i] = [3] and [i] has > impact than [3], then [i] becomes 4th event [3].
			//Otherwise, prioritizing is finished:  	
         if ((FLAG_done0) && (FLAG_done1) && (FLAG_done2) && (!FLAG_done3)) 
		      {						   
			   if ((dispMinutes[3] == dispMinutes[6])  &&
	            ((dispImpact[3]  == "Medium" && dispImpact[6] == "High")  ||
			      (dispImpact[3]   == "Low"    && dispImpact[6] == "High")  || 
			      (dispImpact[3]   == "Low"    && dispImpact[6] == "Medium")))     	
		 	      {
               dispTitle[3]	   = dispTitle[6];
			      dispCountry[3] 	= dispCountry[6];
			      dispImpact[3]  	= dispImpact[6];
			      dispMinutes[3] 	= dispMinutes[6];  			        		 	   		 	   		 	   			
			      }			      			      		         			      
			   //Otherwise, prioritizing is finished:    
			   else
			      {			     
			      FLAG_done3 = true;
			      } 			      			   			   
			   }
						    			
 			//If all four event items are prioritized, exit loop.	   			   							   			   
		   if ((FLAG_done0) && (FLAG_done1) && (FLAG_done2) && (FLAG_done3)) {break;} 
			}
			  
	   }//End prioritizing "for" loop	
	   
	   //Next, determine if any events are out of sequence in time, or are duplicates in title 
	   //and are within the same 24 hour period.  If so, eliminate the higher event item by
	   //setting the flag to not show the item.
	   //Check 1st and 2nd items.  
		if (((dispTitle[0]==dispTitle[1]) && (dispMinutes[0]+ 1440 > dispMinutes[1])) ||
		   (dispMinutes[0] > dispMinutes[1]))
			{
			{FLAG_none1  = true;}	
			}			 	   	
      //Also check 1st and 3rd, and 2nd and 3rd items. 
		if (((dispTitle[0]==dispTitle[2]) && (dispMinutes[0]+ 1440 > dispMinutes[2])) ||  
			((dispTitle[1]==dispTitle[2]) && (dispMinutes[1]+ 1440 > dispMinutes[2]))  ||
			(dispMinutes[0] > dispMinutes[2]) || (dispMinutes[1] > dispMinutes[2]))
			{
			{FLAG_none2  = true;}	
			} 				     
      //Also check 1st and 4th, and 3rd and 4th items. 
		if (((dispTitle[0]==dispTitle[3]) && (dispMinutes[0]+ 1440 > dispMinutes[3])) ||  
			((dispTitle[2]==dispTitle[3]) && (dispMinutes[2]+ 1440 > dispMinutes[3]))  ||
			(dispMinutes[0] > dispMinutes[3]) || (dispMinutes[2] > dispMinutes[3]))
			{
			{FLAG_none3  = true;}	
			}
			
	   //Check if 1st event[0] is more than half a day old and no 2nd event is scheduled.
	   //If so, eliminate the 1st event[0].	
	   if ((dispMinutes[0] < -720) && (dispMinutes[1] == 0 )) 
			{
			{FLAG_none0  = true;}	
			}
					
		//Be sure no "FLAG_none" remains false if a lower one turned to true
		if (FLAG_none0) 
		   {
		   FLAG_none1  = true;
		   FLAG_none2  = true;
		   FLAG_none3  = true;
		   }
		else if (FLAG_none1) 
		   {
		   FLAG_none2  = true;
		   FLAG_none3  = true;
		   }
		else if (FLAG_none2) 
		   {
		   FLAG_none3  = true;
		   }
	
		//Be sure to "FLAG_none" any with no country tag
		if (dispCountry[0] == "") {FLAG_none0 = true;}
		if (dispCountry[1] == "") {FLAG_none1 = true;}
		if (dispCountry[2] == "") {FLAG_none2 = true;}
		if (dispCountry[3] == "") {FLAG_none3 = true;}
		        
		//Check for current day Bank Holiday.  If there is one, then move all
      //events up one tier and insert the Bank Holiday into 1st event.
      if (BankIdx1 == 1)
		   {      
         dispTitle[3]	   = dispTitle[2];
			dispCountry[3] 	= dispCountry[2];
			dispImpact[3]  	= dispImpact[2];
			dispMinutes[3] 	= dispMinutes[2];
			FLAG_none3        = FLAG_none2;
		  
			dispTitle[2]	   = dispTitle[1];
			dispCountry[2] 	= dispCountry[1];
			dispImpact[2]  	= dispImpact[1];
			dispMinutes[2] 	= dispMinutes[1];
			FLAG_none2        = FLAG_none1;
			     	
         dispTitle[1]	   = dispTitle[0];
			dispCountry[1] 	= dispCountry[0];
			dispImpact[1]  	= dispImpact[0];
			dispMinutes[1] 	= dispMinutes[0];
			FLAG_none1        = FLAG_none0;
			     
         dispTitle[0]	   = dispTitle[7];
			dispCountry[0]    = dispCountry[7];
			dispImpact[0]  	= dispImpact[7];
			dispMinutes[0]    = dispMinutes[7];
			FLAG_none0        = false;
			}
      
	//---------------------------------------------------------------------------------------------
	//Go to subroutine to draw panel background and event labels.					
	OutputToChart();
			
	return (0);
   }
   
//+-----------------------------------------------------------------------------------------------+
//| Subroutine to get the name of the ForexFactory .xml file                                      |
//+-----------------------------------------------------------------------------------------------+    
string GetXmlFileName()
   {
	//return (Month() + "-" + Day() + "-" + Year() + "-" + Symbol() + Period() + "-" + "FFCal.xml");
	return (Month() + "-" + Day() + "-" + Year() + "-" + Symbol() + "-" + "FFCal.xml");
   }

//+-----------------------------------------------------------------------------------------------+
//| Indicator Routine For Normal Display                                                          |
//+-----------------------------------------------------------------------------------------------+  
void OutputToChart()
   {
   //Compose fourth event description line--------------------------------------------------------- 	           
   sinceUntil = "until ";
   dispMins = dispMinutes[3]+1; 
	if (dispMinutes[3] <= 0) {dispMins = dispMins - 1; sinceUntil = "since "; dispMins *= -1;} 	
   if (dispMins < 60) {TimeStr = dispMins + " mins ";}
	else // time is 60 minutes or more
	   {
		Hours = MathRound(dispMins / 60);
	   Mins = dispMins % 60;
	   if (Hours < 24) // less than a day: show hours and minutes 
		   {
			TimeStr = Hours + " hrs " + Mins + " mins ";
		   }
		else // days, hours, and minutes
		  	{
		  	Days = MathRound(Hours / 24);
		 	Hours = Hours % 24;
		  	TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
		  	}
	   }               	
   index = StringFind(TimeStr+sinceUntil+dispCountry[3], "since  mins", 0);  
   TxtColorNews = ImpactToColor(dispImpact[3]);	   		      	
	ObjectDelete(News4);       	
   ObjectCreate(News4, OBJ_LABEL, W, 0, 0);
		if((index != -1) || (FLAG_none3)) 
		   {	        
		   ObjectSetText(News4, "(4)  Additional news events not scheduled", 
		      TxtSize, Text_Style, Remarks_Color);
		   event[4] = "(4)  Additional news events not scheduled";
		   }	           		                		            			            	            		   	   
	   else 
	      {
		   ObjectSetText(News4, TimeStr + sinceUntil + dispCountry[3] + 
		      ": " + dispTitle[3], TxtSize, Text_Style, TxtColorNews);
		   event[4] = TimeStr + sinceUntil + dispCountry[3] + ": " + dispTitle[3];
		   }
             
   //Compose third event description line--------------------------------------------------------- 	           
   sinceUntil = "until ";
   dispMins = dispMinutes[2]+1;
	if (dispMinutes[2] <= 0) {dispMins = dispMins - 1; sinceUntil = "since "; dispMins *= -1;}   	
   if (dispMins < 60) {TimeStr = dispMins + " mins ";}
	else // time is 60 minutes or more
	   {
		Hours = MathRound(dispMins / 60);
	   Mins = dispMins % 60;
	   if (Hours < 24) // less than a day: show hours and minutes 
		   {
			TimeStr = Hours + " hrs " + Mins + " mins ";
		   }
		else // days, hours, and minutes
		  	{
		  	Days = MathRound(Hours / 24);
		 	Hours = Hours % 24;
		  	TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
		  	}
	   }               	
   index = StringFind(TimeStr+sinceUntil+dispCountry[2], "since  mins", 0); 		      	
   TxtColorNews = ImpactToColor(dispImpact[2]);	 	      	
	ObjectDelete(News3);       	
   ObjectCreate(News3, OBJ_LABEL, W, 0, 0);
		if((index != -1) || (FLAG_none2)) 
		   {	        
		   ObjectSetText(News3, "(3)  Additional news events not scheduled", 
		      TxtSize, Text_Style, Remarks_Color);
		   event[3] = "(3)  Additional news events not scheduled";
		   }	           		                		            			            	            		   	   
	   else 
	      {
		   ObjectSetText(News3, TimeStr + sinceUntil + dispCountry[2] + 
		      ": " + dispTitle[2], TxtSize, Text_Style, TxtColorNews);
		   event[3] = TimeStr + sinceUntil + dispCountry[2] + ": " + dispTitle[2];
		   }		   		  
           
	//Compose second event description line-------------------------------------------------------- 	           
   sinceUntil = "until ";
   dispMins = dispMinutes[1]+1;  
	if (dispMinutes[1] <= 0) {dispMins = dispMins - 1; sinceUntil = "since "; dispMins *= -1;} 	
   if (dispMins < 60) {TimeStr = dispMins + " mins ";}
	else // time is 60 minutes or more
	   {
	   Hours = MathRound(dispMins / 60);
	   Mins = dispMins % 60;
	   if (Hours < 24) // less than a day: show hours and minutes 
		   {
		   TimeStr = Hours + " hrs " + Mins + " mins ";
		   }
		else // days, hours, and minutes
		   {
		   Days = MathRound(Hours / 24);
			Hours = Hours % 24;
			TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
		   }
	   }               	
	index = StringFind(TimeStr+sinceUntil+dispCountry[1], "since  mins", 0); 		      	
   TxtColorNews = ImpactToColor(dispImpact[1]);	 	      	
	ObjectDelete(News2);       	
   ObjectCreate(News2, OBJ_LABEL, W, 0, 0);
		if((index != -1) || (FLAG_none1)) 
		   {		       
		   ObjectSetText(News2, "(2)  Additional news events not scheduled", 
		      TxtSize, Text_Style, Remarks_Color);
		   event[2] = "(2)  Additional news events not scheduled";
		   }	           		                		            			            	            		   	   
	   else 
	      {
		   ObjectSetText(News2, TimeStr + sinceUntil + dispCountry[1] + 
		      ": " + dispTitle[1], TxtSize, Text_Style, TxtColorNews);
		   event[2] = TimeStr + sinceUntil + dispCountry[1] + ": " + dispTitle[1];
		   }		  
         
	//Compose first event description line---------------------------------------------------------  
	//If time is 0 or negative, we want to say "xxx mins SINCE ... news event", 
	//else say "UNTIL ... news event"
	sinceUntil = "until ";
	dispMins = dispMinutes[0]+1;  //dispMins "*= -1" = multiply by "-1" 
	if (dispMinutes[0] <= 0) {dispMins = dispMins - 1; sinceUntil = "since "; dispMins *= -1;}	      
	if (dispMins < 60) {TimeStr = dispMins + " mins ";}
	else // time is 60 minutes or more
	   {
		Hours = MathRound(dispMins / 60);
		Mins = dispMins % 60;
		if (Hours < 24) // less than a day: show hours and minutes
		   {
		   TimeStr = Hours + " hrs " + Mins + " mins ";
		   }
		else  // days, hours, and minutes
		   {
		   Days = MathRound(Hours / 24);
			Hours = Hours % 24;
			TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
		   }
	   }	  		         
	index = StringFind(TimeStr+sinceUntil+dispCountry[0], "since  mins", 0); //Comment (index);	
	TxtColorNews = ImpactToColor(dispImpact[0]);	       	   
	ObjectDelete(News1);		         	    
	ObjectCreate(News1, OBJ_LABEL, W, 0, 0);
		if((index != -1) || (FLAG_none0)) 
		   {	      
		   ObjectSetText(News1, "(1)  Additional news events not scheduled", 
		      TxtSize, Text_Style, Remarks_Color);
		   event[1] = "(1)  Additional news events not scheduled";
		   }			                  	         		         	
		else 
		   {
	   	ObjectSetText(News1, TimeStr + sinceUntil + dispCountry[0] + 
	   	   ": " + dispTitle[0], TxtSize, Text_Style, TxtColorNews);
	   	event[1] = TimeStr + sinceUntil + dispCountry[0] + ": " + dispTitle[0];
	   	}

   //Do background---------------------------------------------------------------------------------
   //Set variables.   
   x1 = 0; 
   x2 = 0;               
	y2 = 1;
	
   //Automate Determination of Width of Background
   //Determine the length (x1) of the maximum length event string (i = 1-4)
   for (i=1; i<=4; i++) 
      {
      if(i == 0) {x1 = StringLen(event[i]);}
      else
         {
         if(StringLen(event[i]) > x1)
           {
           x1 = StringLen(event[i]);
           }
         }  
      } 
   if(x1<94) {x2 = 95;}
   else {x2 = x1-94+95;}//x2 = starts where x1 characters stop
   	   
   //Set up for background boxes             
   //Space in Panel is req'd for Watermark if no subwindow exists and the panel is in the
   //main window on the left side, or if a subwindow does exist and the panel is in the
   //subwindow on the left side.
   if((!Allow_Panel_At_Chart_Right) && 
     (WindowsTotal( )==1 || (WindowsTotal( )>1 && Allow_Panel_In_Subwindow_1)))
     {
     //Use larger rectangle Panel & start text higher from bottom
     curY = 18;        
     Box  = 64;//64
     G    = "gg";              
     //block size "gg" requires background #2 to start further right
     x2=x2+46;      
     }
   //No space in Panel is req'd for Watermark if a subwindow exists and the panel is in the
   //main window, or if the panel is in the subwindow, but on the right side.          
   else  
     {
     //Use shorter rectangle Panel & start text lower from bottom  
     curY = 6;       
     Box  = 54;//54
     G    = "ggg"; 
     }
     
   //Draws Background boxes
   if(Show_Panel_Background) {    
   ObjectCreate(box1, OBJ_LABEL, W, 0,0);
   ObjectSetText(box1, G, Box, "Webdings");          
   ObjectSet(box1, OBJPROP_CORNER, cnr);
   ObjectSet(box1, OBJPROP_XDISTANCE, 1);      
   ObjectSet(box1, OBJPROP_YDISTANCE, 1);       
   ObjectSet(box1, OBJPROP_COLOR, Background_Color_);
   ObjectSet(box1, OBJPROP_BACK, false);

   ObjectCreate(box2, OBJ_LABEL, W, 0,0);
   ObjectSetText(box2, G, Box, "Webdings");         
   ObjectSet(box2, OBJPROP_CORNER, cnr);
   ObjectSet(box2, OBJPROP_XDISTANCE, x2);     
   ObjectSet(box2, OBJPROP_YDISTANCE, 1);      
   ObjectSet(box2, OBJPROP_COLOR, Background_Color_);
   ObjectSet(box2, OBJPROP_BACK, false); }

   //Draw Event4
	ObjectSet(News4, OBJPROP_CORNER, cnr);
	ObjectSet(News4, OBJPROP_XDISTANCE, curX);
	ObjectSet(News4, OBJPROP_YDISTANCE, curY); 	   	   	
   curY = curY + TxtSize + EventSpacer;
   
   //Draw Event3
	ObjectSet(News3, OBJPROP_CORNER, cnr);
	ObjectSet(News3, OBJPROP_XDISTANCE, curX);
	ObjectSet(News3, OBJPROP_YDISTANCE, curY); 	   	   	
   curY = curY + TxtSize + EventSpacer; 
       
   //Draw Event2
	ObjectSet(News2, OBJPROP_CORNER, cnr);
   ObjectSet(News2, OBJPROP_XDISTANCE, curX);
	ObjectSet(News2, OBJPROP_YDISTANCE, curY); 	   	   	
   curY = curY + TxtSize + EventSpacer;     
      
   //Draw Event1   
	ObjectSet(News1, OBJPROP_CORNER, cnr);
	ObjectSet(News1, OBJPROP_XDISTANCE, curX );
	ObjectSet(News1, OBJPROP_YDISTANCE, curY);        	
   curY = curY + TxtSize + TitleSpacer;    
      	       
   //Finish with title-----------------------------------------------------------------------------
	ObjectDelete(Sponsor);         	     	         	
	ObjectCreate(Sponsor, OBJ_LABEL, W, 0, 0);
 	ObjectSetText(Sponsor, "SONIC R. SYSTEM  FFCAL HEADLINES:", TxtSize, "Verdana", FFCal_Title);
	ObjectSet(Sponsor, OBJPROP_CORNER, cnr);
	ObjectSet(Sponsor, OBJPROP_XDISTANCE, curX);
	ObjectSet(Sponsor, OBJPROP_YDISTANCE, curY);          
                
	return (0);
   }

//+-----------------------------------------------------------------------------------------------+
//| Indicator Subroutine For Impact Color                                                         |
//+-----------------------------------------------------------------------------------------------+  
double ImpactToColor (string impact)
   {
	if (impact == "High") return (High_Impact_News_Color);
	else {if (impact == "Medium") return (Medium_Impact_News_Color);
	else {if (impact == "Low") return (Low_Impact_News_Color);
	else {if (impact == "Holiday") return (Bank_Holiday_Color); 
	else {return (Remarks_Color);} }}}  
   }

//+-----------------------------------------------------------------------------------------------+
//| Indicator Subroutine For Date/Time                                                            |
//+-----------------------------------------------------------------------------------------------+ 
string MakeDateTime(string strDate, string strTime)
   {
	//Print("Converting Forex Factory Time into Metatrader time..."); //added by MN
	//Converts forexfactory time & date into yyyy.mm.dd hh:mm
	int n1stDash = StringFind(strDate, "-");
	int n2ndDash = StringFind(strDate, "-", n1stDash+1);

	string strMonth = StringSubstr(strDate, 0, 2);
	string strDay = StringSubstr(strDate, 3, 2);
	string strYear = StringSubstr(strDate, 6, 4); 
   //strYear = "20" + strYear;
	
	int nTimeColonPos = StringFind(strTime, ":");
	string strHour = StringSubstr(strTime, 0, nTimeColonPos);
	string strMinute = StringSubstr(strTime, nTimeColonPos+1, 2);
	string strAM_PM = StringSubstr(strTime, StringLen(strTime)-2);

	int nHour24 = StrToInteger(strHour);
	if (strAM_PM == "pm" || strAM_PM == "PM" && nHour24 != 12) {nHour24 += 12;}
	if (strAM_PM == "am" || strAM_PM == "AM" && nHour24 == 12) {nHour24 = 0;}
 	string strHourPad = "";
	if (nHour24 < 10) strHourPad = "0";

	return(StringConcatenate(strYear, ".", strMonth, ".", strDay, " ", strHourPad, nHour24, ":", strMinute));
   }

//=================================================================================================
//===============================   Begin Imported Functions   ====================================
//=================================================================================================
// Main Webscraping function
// ~~~~~~~~~~~~~~~~~~~~~~~~~
// bool GrabWeb(string strUrl, string& strWebPage)
// returns the text of any webpage. Returns false on timeout or other error
// 
// Parsing functions
// ~~~~~~~~~~~~~~~~~
// string GetData(string strWebPage, int nStart, string strLeftTag, string strRightTag, int& nPos)
// obtains the text between two tags found after nStart, and sets nPos to the end of the second tag
//
// void Goto(string strWebPage, int nStart, string strTag, int& nPos)
// Sets nPos to the end of the first tag found after nStart 

bool bWinInetDebug = false;
int  hSession_IEType;
int  hSession_Direct;
int  Internet_Open_Type_Preconfig = 0;
int  Internet_Open_Type_Direct = 1;
int  Internet_Open_Type_Proxy = 3;
int  Buffer_LEN = 80;

#import "wininet.dll"
//Forces the request to be resolved by the origin server, even if a cached copy exists on the proxy.
#define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100 

//Does not add the returned entity to the cache. 
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000 
 
//Forces a download of the requested file, object, or directory listing from the origin server, not from the cache.
#define INTERNET_FLAG_RELOAD            0x80000000 

int InternetOpenA(
	string 	sAgent,
	int		lAccessType,
	string 	sProxyName="",
	string 	sProxyBypass="",
	int 	lFlags=0);

int InternetOpenUrlA(
	int 	hInternetSession,
	string 	sUrl, 
	string 	sHeaders="",
	int 	lHeadersLength=0,
	int 	lFlags=0,
	int 	lContext=0);

int InternetReadFile(
	int 	hFile,
	string 	sBuffer,
	int 	lNumBytesToRead,
	int& 	lNumberOfBytesRead[]);

int InternetCloseHandle(
	int 	hInet);
	
#import

//-------------------------------------------------------------------------------------------------
int hSession(bool Direct)
   {
	string InternetAgent;
	if (hSession_IEType == 0)
	   {
		InternetAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Q312461)";
		hSession_IEType = InternetOpenA(InternetAgent, Internet_Open_Type_Preconfig, "0", "0", 0);
		hSession_Direct = InternetOpenA(InternetAgent, Internet_Open_Type_Direct, "0", "0", 0);
	   }
	if (Direct) {return(hSession_Direct);}
	else {return(hSession_IEType);}
   }

//-------------------------------------------------------------------------------------------------
bool GrabWeb(string strUrl, string& strWebPage)
   {
	int   	hInternet;
	int		iResult;
	int   	lReturn[]	= {1};
	string 	sBuffer		= "                                                                                                                                                                                                                                                               ";	// 255 spaces
	int   	bytes;
	
	hInternet = InternetOpenUrlA(hSession(FALSE), strUrl, "0", 0, 
								INTERNET_FLAG_NO_CACHE_WRITE | 
								INTERNET_FLAG_PRAGMA_NOCACHE | 
								INTERNET_FLAG_RELOAD, 0);
								   
	if (hInternet == 0) return(false);
	Print("Reading URL: " + strUrl);	   //added by MN	
	iResult = InternetReadFile(hInternet, sBuffer, Buffer_LEN, lReturn);
	if (iResult == 0)  return(false);
	bytes = lReturn[0];
	strWebPage = StringSubstr(sBuffer, 0, lReturn[0]);
	
	//If there's more data then keep reading it into the buffer
	while (lReturn[0] != 0)
	   {
		iResult = InternetReadFile(hInternet, sBuffer, Buffer_LEN, lReturn);
		if (lReturn[0]==0) break;
		bytes = bytes + lReturn[0];
		strWebPage = strWebPage + StringSubstr(sBuffer, 0, lReturn[0]);
   	}
	Print("Closing URL web connection");   //added by MN
	iResult = InternetCloseHandle(hInternet);
	if (iResult == 0) return(false);		
	return(true);
   }

//===================================   Timezone Functions   ======================================
#import "kernel32.dll"
int  GetTimeZoneInformation(int& TZInfoArray[]);
#import
#define TIME_ZONE_ID_UNKNOWN   0
#define TIME_ZONE_ID_STANDARD  1
#define TIME_ZONE_ID_DAYLIGHT  2
int TZInfoArray[43];	
datetime TimeGMT() 
   {
	int DST = GetTimeZoneInformation(TZInfoArray);
	if (DST == 1) DST = 3600;
	else DST = 0;
	return( TimeLocal() + DST + (Offset_Hours * 3600) + (TZInfoArray[0] + TZInfoArray[42]) * 60 );
   }

//=================================================================================================
//=================================   End Imported Functions  =====================================
//=================================================================================================

//+-----------------------------------------------------------------------------------------------+
//| Indicator End                                                                                 |                                                        
//+-----------------------------------------------------------------------------------------------+