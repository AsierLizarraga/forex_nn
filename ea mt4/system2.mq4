//+------------------------------------------------------------------+
//|                                                  asesor_meta.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern double slimpage = 3;
// datetime of the bar
datetime lastBarOpenTime;

// lag trend. less than 100 
extern  int lag_trend = 3;

// R1 Params: stoploss,takeprofit,lots
extern double takeprofit_R1 = 30; // 5 a 30 de 1 en 1
extern double lots_R1 = 1; // 0.5 a 5 de 0.5

// R1: value of the macd actual, value of the trend actual and trend short actual, trend long actual,rsi
 extern double param_macd_actual_r1 = 0;
 extern double param_trend_macd_r1 = 1;
 extern double param_rsi_actual_r1 = 20;
 extern double param_rsi_2_actual_r1 = 30;
 extern double param_atr_r1 = 1;

// R2 Params: stoploss,takeprofit,lots
extern double takeprofit_R2 = 30; // 5 a 30 de 1 en 1
extern double lots_R2 = 1; // 0.5 a 5 de 0.5

// R2: value of the macd actual, value of the trend actual and trend short actual, trend long actual,rsi
 extern double param_macd_actual_r2 = 0;
 extern double param_trend_macd_r2 = -1;
 extern double param_rsi_actual_r2 = 80;
 extern double param_rsi_2_actual_r2 = 70;
 extern double param_atr_r2 = 1;
 
 // R3: EXIT BUY
 extern double param_stoch_r3 = 70;
 
  // R3: EXIT SELL
 extern double param_stoch_r4 = 30;
 

// ARRAYS
double macd[100];
double diff_macd[100];

//  param: MaCD 
extern int fast_ema = 12;
extern int slow_ema = 26;
extern int signal = 9;
// rsi param
extern int rsi_lag = 3;
// stoch param
extern int k_periods = 6;
extern int d_periods = 3;
extern int slow = 9;

// flags
bool flag_creciente = false; 
bool flag_tendencia_creciente = false;
bool flag_rsi_buy = false;
bool cruce_stoch_buy = false;
bool flag_atr_buy = false;

bool flag_decreciente = false; 
bool flag_tendencia_decreciente = false;
bool flag_rsi_sell = false;
bool cruce_stoch_sell = false;
bool flag_atr_sell = false;


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   int i;
   lastBarOpenTime = Time[0];
   for(i=0;i<=lag_trend - 1;i++)
      { 
      // macd a diferent time frames
      macd[i] = iMACD(NULL,0,fast_ema,slow_ema,signal,PRICE_CLOSE,MODE_MAIN,i);
      }
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
//Alert("Account balance = ",AccountBalance());
int ticket,i; 
double stop,take;
double sum_diff = 0;
bool Ans;

// initial data checks
   if(Bars<100)
     {
      Print("bars less than 100");
      return(0);  
     }
     
   datetime thisBarOpenTime = Time[0];
   // if new bar is created
   if(thisBarOpenTime != lastBarOpenTime) 
   {  
         lastBarOpenTime = thisBarOpenTime;  
         // entry buy   
         if( (flag_creciente == true) && (flag_tendencia_creciente == true)  && (flag_rsi_buy == true) && (cruce_stoch_buy == true) && (flag_atr_buy == true) )
         {
            if (((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_BUY,lots_R1)) >= 0))
               {      
                      RefreshRates();
                      double lowswin = low_swin();
                      stop = lowswin;  
                      take = Bid+(takeprofit_R1*Point*10);
                      ticket=OrderSend(Symbol(),OP_BUY,lots_R1,Ask,slimpage,stop,take);  
                      if(ticket<0)
                     {
                        //Print("OrderSend failed with error #",GetLastError());
                        return(0); 
                      } 
                      else
                      {              
                      }        
               } 
               
                  bool flag_creciente = false; 
                  bool flag_tendencia_creciente = false;
                  bool flag_rsi_buy = false;
                  bool cruce_stoch_buy = false;
                  bool flag_atr_buy = false;
 
         }
         
         if( (flag_decreciente == true) && (flag_tendencia_decreciente == true) && (flag_atr_sell == true) && (flag_rsi_sell == true) && (cruce_stoch_sell == true) )
         {
            if (((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_SELL,lots_R2)) >= 0))
               {      
                      RefreshRates();
                      double highswin = high_swin();
                      stop = highswin;  
                      take = Ask-(takeprofit_R2*Point*10);
                      ticket=OrderSend(Symbol(),OP_SELL,lots_R2,Bid,slimpage,stop,take);  
                      if(ticket<0)
                     {
                        //Print("OrderSend failed with error #",GetLastError());
                        return(0); 
                      } 
                      else
                      {              
                      } 
               }  
         
               bool flag_decreciente = false; 
               bool flag_tendencia_decreciente = false;
               bool flag_rsi_sell = false;
               bool cruce_stoch_sell = false;
               bool flag_atr_sell = false;

         }
   }

      // claculate macd
      for(i=0;i<=lag_trend - 1;i++)
         { 
               // macd a diferent time frames
               macd[i] = iMACD(NULL,0,fast_ema,slow_ema,signal,PRICE_CLOSE,MODE_MAIN,i);
         } 
             
         // macd trend 
         double sum_diff_macd = 0;  
         for(i=0;i<= lag_trend - 1;i++)
            {    
            diff_macd[i] = (macd[i] - macd[i + 1]) * (100000);
            sum_diff_macd = sum_diff_macd + diff_macd[i];     
            } 
            
         double trend_macd = sum_diff_macd/lag_trend;
         double trend_macd_actual = diff_macd[0];
         double macd_actual = macd[0] * (100000);
         
        Alert("trend_macd = " + trend_macd);
        Alert("trend_macd_actual = " + trend_macd_actual);
        Alert("macd_actual = " + macd_actual);
        
        // RSI AND ATR
        double rsi_actual = iRSI(NULL,0,rsi_lag,PRICE_CLOSE,0);
        double atr = iATR(NULL,0,14,0) * 10000;
        Alert("atr = " + atr);
        Alert("rsi_actual = " + rsi_actual);       
        
       // stochastic
       double stoch_actual = iStochastic(NULL,0,k_periods,d_periods,slow,MODE_SMA,1,MODE_MAIN,0);
       double stoch_signal_actual = iStochastic(NULL,0,k_periods,d_periods,slow,MODE_SMA,1,MODE_SIGNAL,0); 
       Alert("stoch_actual = " + stoch_actual);
       Alert("stoch_signal_actual = " + stoch_signal_actual);      
  
        // Rule 1: entry buy
        
         if(
            // CRECIENTE
            (macd_actual > param_macd_actual_r1)
            )
         {    
             flag_creciente = true;     
         }
         
         if(
            // atr volatil buy
            (atr >= param_atr_r1)
            )
         {    
             flag_atr_buy = true;     
         }
         
         
         if(
            // tendencia creciente de la macd 
            (trend_macd >= param_trend_macd_r1)
            )
         {    
             flag_tendencia_creciente = true;     
         }
   
         if(
            // valor inferiror del rsi
            rsi_actual <= param_rsi_actual_r1
            )
         {    
             flag_rsi_buy = true;     
         }
         
         if(   
            // se produce el cruce
            stoch_actual >= stoch_signal_actual
            // se comprueba por segunda vez el rsi
            && rsi_actual <= param_rsi_2_actual_r1  
            )
         {    
             cruce_stoch_buy = true;   
         }
         
        // Rule 2: entry sell   

          if(
            // DECRECIENTE
            (macd_actual < param_macd_actual_r2)
            )
         {    
             flag_decreciente = true;     
         }
         
         if(
            // tendencia decreciente de la macd 
            (trend_macd <= param_trend_macd_r2)
            )
         {    
             flag_tendencia_decreciente = true;     
         }
         
         if(
            // atr volatil sell
            (atr >= param_atr_r2)
            )
         {    
             flag_atr_sell = true;     
         }
         
         
          if(
            // valor superior del rsi
            rsi_actual >= param_rsi_actual_r2
            )
         {    
             flag_rsi_sell = true;     
         }
         
 
         if(
            // se produce el cruce
            stoch_signal_actual >= stoch_actual
            // se comprueba por segunda vez el rsi
            && rsi_actual >= param_rsi_2_actual_r2    
            )
         {    
             cruce_stoch_sell = true;   
         }
         

         // Rule 3: exit buy   
         if(stoch_signal_actual >= param_stoch_r3 || stoch_actual >= param_stoch_r3 ) 
         {
         
            for(i=0;i<=OrdersTotal() - 1;i++)
               {   
                if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                  { 
                     if (OrderType() == OP_BUY)
                     {   
                        RefreshRates();
                        Ans =  OrderModify(OrderTicket(),OrderOpenPrice(),Low[1],OrderTakeProfit(),0);
                        if (Ans==false)          // Got it! :)
                        {
                         Ans = OrderClose(OrderTicket(),OrderLots(),Bid,slimpage,Red);
                        }
                        else
                        {
                        }
                     } 
                  }    
               }        
         }
         
         
        // Rule 4: exit sell 
         
           
         if(stoch_signal_actual <= param_stoch_r4 || stoch_actual <= param_stoch_r4 ) 
         {
            for(i=0;i<=OrdersTotal() - 1;i++)
               {   
                if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                  { 
                     if (OrderType() == OP_SELL)
                     {   
                        RefreshRates();
                        Ans =   OrderModify(OrderTicket(),OrderOpenPrice(),High[1],OrderTakeProfit(),0);
                        if (Ans==false)          // Got it! :)
                        {
                         Ans = OrderClose(OrderTicket(),OrderLots(),Ask,slimpage,Red);
                        }
                        else
                        {
                        }
                     } 
                  }    
               }        
         }
         
         
         
      
   return(0);
  }
  
  double low_swin()
  {
      double swinlow; 
      bool encontrado = false;
      int i=2;
      while(encontrado == false)
      {
           if((Low[i] < Low[i-1]) && (Low[i] < Low[i+1])) 
            {
               swinlow = Low[i];
               encontrado = true;
            }
            
            i = i + 1;
      }
      
   return(swinlow);
  }
  
  
  double high_swin()
  {
      double swinhigh; 
      bool encontrado = false;
      int i=2;
      while(encontrado == false)
      {
           if ((High[i] > High[i-1]) && (High[i] > High[i+1]))
            {
               swinhigh = High[i];
               encontrado = true;
            }
            i = i + 1;
            
      }
      
   return(swinhigh);
  }
  
  
    



