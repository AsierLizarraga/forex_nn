///+------------------------------------------------------------------+
//|                                                      eurusd5.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
// number of var for the inizialization
int length = 50; 
// name of the file with the inizialization data
string nameData = "EURUSD_inizialization.csv";
// name of the file that contain the bar
string barData = "EURUSD_bar.csv";
// datetime of the bar
datetime lastBarOpenTime;
// file with the prediction of matlab
string predData = "EURUSD_prediction.csv";
// variable for check if exists open buy orders
int entry_buy = 0;
// variable for check if exists open sell orders
int entry_sell = 0;
bool recep_pred = True;
int ticket;

extern int stoploss = 30;
extern int takeprofit = 100;
extern int slimpage = 3;
extern int enter_high = 3;
extern int enter_medium = 2;
extern int enter_low = 1;
bool Ans;
double stop = 0;
double take = 0; 



//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   // write the historical data
   write_data_inizialization();
   lastBarOpenTime = Time[0];
   Alert("Inizialization");
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {

   datetime thisBarOpenTime = Time[0];
   // if new bar is created
   if(thisBarOpenTime != lastBarOpenTime) 
   {
      // write the bar
      write_bar();
      lastBarOpenTime = thisBarOpenTime;   
      int handle;
      
      // check if there are buy or sell orders
      entry_buy = 0;
      entry_sell = 0;
     
      for(int i=0;i<=OrdersTotal() - 1;i++)
      {   
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
         { 
            if(OrderType()==OP_BUY)
            {   
               entry_buy = 1;
            }
              if(OrderType()==OP_SELL) 
            {   
               entry_sell = 1; 
            }  
         }  
         else
         Alert("OrderSelect returned the error of ",GetLastError());      
      }
      
      Alert("entry buy ",entry_buy);
      Alert("entry sell ",entry_sell);
      recep_pred = true;
      // wait until the file with the prediction is abailable

      while(recep_pred)
      {   
         
         handle = FileOpen(predData,FILE_CSV|FILE_READ,';');
         if(handle >= 0)
         {  
            
            Sleep(200);
            string s = FileReadString(handle);
            FileFlush(handle); 
            Sleep(100);
            Alert("recive pred ",s);
            double pred = StrToDouble(s);
            Alert("recive pred ",pred);
            FileClose(handle);
            
  
            if ((pred >= 0 && pred < 0.15)&&(entry_buy == 0))               
            {
            
               if (((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_BUY,enter_low)) > 0 ))
               {      
  
                      RefreshRates();
                      //stop = Bid-stoploss*Point;  
                      //take = Bid+takeprofit*Point;
                      ticket=OrderSend(Symbol(),OP_BUY,enter_high,Ask,slimpage,stop,take);
                      Alert("buy high"); 
                      Alert("stop ",stop);
                      Alert("take ",take); 
                      
                     if(ticket<0)
                     {
                        Print("OrderSend failed with error #",GetLastError());
                        return(0);
                        
                      }  
                }     
            }
         
            if ((pred >= 0.15 && pred < 0.3) && (entry_buy == 0))         
            {
               
              if (AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_BUY,enter_medium) > 0) 
               {     
                     RefreshRates();
                     //stop = Bid-stoploss*Point;  
                     //take = Bid+takeprofit*Point;
                     ticket=OrderSend(Symbol(),OP_BUY,enter_medium,Ask,slimpage,stop,take);
                     Alert("buy medium"); 
                     Alert("stop ",stop);
                     Alert("take ",take); 
                     if(ticket<0)
                     {
                        Print("OrderSend failed with error #",GetLastError());
                        return(0);
                      }  
                }     
            }
            
            if ((pred >= 0.3 && pred < 0.45) && (entry_buy == 0))        
            {
                     
             if ((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_BUY,enter_high)) > 0 )
               {     
                     // Bid - (stoploss*Point)
                     // Bid + (takeprofit*Point)
                     
                     RefreshRates();
                     //stop = Bid-stoploss*Point;  
                     //take = Bid+takeprofit*Point;
                     ticket=OrderSend(Symbol(),OP_BUY,enter_low,Ask,slimpage,stop,take);
                     Alert("buy low"); 
                     Alert("stop ",stop);
                     Alert("take ",take); 
                     if(ticket<0)
                     {
                        Print("OrderSend failed with error #",GetLastError());
                        return(0);
                      }  
                }     
            }

             if ((pred >= 0.6 && pred < 0.75) && (entry_sell == 0))     
            {
            
              if ((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_SELL,enter_low)) > 0 )
               {
                     // Ask + (stoploss*Point)
                     // Ask - (takeprofit*Point)

                     RefreshRates();
                     //stop = Ask+stoploss*Point;
                     //take = Ask-takeprofit*Point;
                     ticket=OrderSend(Symbol(),OP_SELL,enter_low,Bid,slimpage,stop,take);
                     Alert("sell low"); 
                     Alert("stop ",stop);
                     Alert("take ",take);
                     
                     if(ticket<0)
                     {
                        Print("OrderSend failed with error #",GetLastError());
                        return(0);
                      }  
                }     
            }
            
            if ((pred >= 0.75 && pred < 0.9) && (entry_sell == 0))  
            {
            
              if ((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_SELL,enter_medium)) > 0 )
               {
               
                     RefreshRates();
                     //stop = Ask+stoploss*Point;
                     //take = Ask-takeprofit*Point;
                     ticket=OrderSend(Symbol(),OP_SELL,enter_medium,Bid,slimpage,stop,take);
                     Alert("sell medium"); 
                     Alert("stop ",stop);
                     Alert("take ",take);
                     if(ticket<0)
                     {
                        Print("OrderSend failed with error #",GetLastError());
                        return(0);
                      }  
                }     
            }
           
            if ((pred > 0.9) && (entry_sell == 0))
             {
              if ((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_SELL,enter_high)) > 0 )
               {     
                     RefreshRates();
                     //stop = Ask+stoploss*Point;
                     //take = Ask-takeprofit*Point;
                     ticket=OrderSend(Symbol(),OP_SELL,enter_high,Bid,slimpage,stop,take);
                     Alert("sell High"); 
                     Alert("stop ",stop);
                     Alert("take ",take);
                     if(ticket<0)
                     {
                        Print("OrderSend failed with error #",GetLastError());
                        return(0);
                      }  
                }     
            }
            
            if ((pred >= 0.6) && (entry_buy == 1))
            {           
               // close all buy orders
               for(i=0;i<=OrdersTotal() - 1;i++)
               {   
                if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                  { 
                     if (OrderType() == OP_BUY)
                     {   
                        RefreshRates();
                        Ans = OrderClose(OrderTicket(),OrderLots(),Bid,slimpage,Red);
                        Alert("exit buy");  
                        if (Ans==false)          // Got it! :)
                        {
                         Alert("no se ha podido cerrar");    // Exit closing cycle
                        }
 
                     } 
                  }    
               }
            }
            
            if ((pred < 0.45) && (entry_sell == 1))
            {
              // close all sell orders
               for(i=0;i<=OrdersTotal() - 1;i++)
               {   
                  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                  { 
                  if( OrderType() == OP_SELL)
                     {   
                        RefreshRates();
                        Ans = OrderClose(OrderTicket(),OrderLots(),Ask,slimpage,Red);
                        Alert("exit sell"); 
                        if (Ans==false)          // Got it! :)
                        {
                         Alert("no se ha podido cerrar");    // Exit closing cycle
                        } 
                     } 
                  }                  
               }
            }
             // close the file 
             recep_pred = false;
     }  
   } 
 }  
   return(0);   
}
//+------------------------------------------------------------------+

void write_data_inizialization()
{
  int handle;
  handle = FileOpen(nameData,FILE_CSV|FILE_WRITE,';');
  if(handle < 1)
  {
    Comment("Creation of "+nameData+" failed. Error #", GetLastError());
    return(0);
  }
  
  FileWrite(handle, "FECHA","APERTURA","ALTO","BAJO","CIERRE","VOLUMEN");   // heading
 
  for(int i=length; i>=1; i--)
  {
    FileWrite(handle, TimeToStr(Time[i], TIME_DATE) + " " + TimeToStr(Time[i], TIME_MINUTES),
                      Open[i], High[i], Low[i], Close[i], Volume[i]);
  }

  FileClose(handle);
  return(0);
}


void write_bar()
{
  int handle;
  handle = FileOpen(barData,FILE_CSV|FILE_WRITE,';');
  if(handle < 1)
  {
    Comment("Creation of "+nameData+" failed. Error #", GetLastError());
    return(0);
  }

  FileWrite(handle, TimeToStr(Time[1], TIME_DATE) + " " + TimeToStr(Time[1], TIME_MINUTES),
           Open[1], High[1], Low[1], Close[1], Volume[1]);

  FileClose(handle);
  return(0);
}


