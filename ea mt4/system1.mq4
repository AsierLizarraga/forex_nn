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
extern int max_oper = 1;

// R1 Params: stoploss,takeprofit,lots
extern double stoploss_R1 = 9.9; // 5 a 30 de 1 en 1 
extern double takeprofit_R1 = 16; // 5 a 30 de 1 en 1
extern double lots_R1 = 1; // 0.5 a 5 de 0.5

// R1: value of the macd actual, value of the trend actual and trend short actual, trend long actual,rsi
 extern double param_macd_actual_r1 = -0.9;
 extern double param_trend_macd_actual_r1 = 2.2;
 extern double param_trend_macd_r1 = 9.4;
 extern double param_rsi_actual_r1  = 40;
 extern double param_rsi2_actual_r1 = 79; 
 extern double param_trend_rsi_r1 = 8.1;

 
// flag rule 1 ENTRY buy: MCD + RSI
int enter_rule1 = 0;


// R2 Params EXIT BUY : MCD + RSI
 extern double param_macd_actual_r2 = -5.4;
 extern double param_trend_macd_actual_r2 = -8.5;
 extern double param_trend_macd_r2 = -5.5;
 extern double param_rsi_actual_r2  = 60;
 extern double param_trend_rsi_r2   = -1.7;


 // R3 Params EXIT BUY:  hIGH RSI
 extern double param_rsi_r3 = 85;


// ARRAYS
double macd[100];
double macd_5min[100];
double macd_15min[100];
double rsi[100];
double rsi_5min[100];
double rsi_15min[100];

// indicators param: MaCD Y rsi
extern int rsi_lag = 10;
extern int fast_ema = 12;
extern int slow_ema = 26;
extern int signal = 9;

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
      macd[i] = iMACD(NULL,0,fast_ema,slow_ema,signal,PRICE_CLOSE,MODE_MAIN,i + 1);
      macd_5min[i] = iMACD(NULL,PERIOD_M5,fast_ema,slow_ema,signal,PRICE_CLOSE,MODE_MAIN,i + 1);
      macd_15min[i] = iMACD(NULL,PERIOD_M15,fast_ema,slow_ema,signal,PRICE_CLOSE,MODE_MAIN,i + 1);
      
      // rsi a diferent time frames
      rsi[i] = iRSI(NULL,0,rsi_lag,PRICE_CLOSE,i + 1);
      rsi_5min[i] = iRSI(NULL,PERIOD_M5,rsi_lag,PRICE_CLOSE,i + 1);
      rsi_15min[i] = iRSI(NULL,PERIOD_M15,rsi_lag,PRICE_CLOSE,i + 1);
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
         // tema
         //tema();
         for(i=0;i<=lag_trend - 1;i++)
         { 
               // macd a diferent time frames
               macd[i] = iMACD(NULL,0,fast_ema,slow_ema,signal,PRICE_CLOSE,MODE_MAIN,i + 1);
               macd_5min[i] = iMACD(NULL,PERIOD_M5,fast_ema,slow_ema,signal,PRICE_CLOSE,MODE_MAIN,i + 1);
               macd_15min[i] = iMACD(NULL,PERIOD_M15,fast_ema,slow_ema,signal,PRICE_CLOSE,MODE_MAIN,i + 1);
      
               // rsi a diferent time frames
               rsi[i] = iRSI(NULL,0,rsi_lag,PRICE_CLOSE,i + 1);
               rsi_5min[i] = iRSI(NULL,PERIOD_M5,rsi_lag,PRICE_CLOSE,i + 1);
               rsi_15min[i] = iRSI(NULL,PERIOD_M15,rsi_lag,PRICE_CLOSE,i + 1); 
         } 
         lastBarOpenTime = thisBarOpenTime;      
   
             
         // macd trend and rsi trend
          
            double sum_diff_macd = 0;  
            double sum_diff_macd_5 = 0;
            double sum_diff_macd_15 = 0;    
            double sum_diff_rsi = 0;  
            double sum_diff_rsi_5 = 0;
            double sum_diff_rsi_15 = 0; 
            
            double diff_macd[100];
            double diff_macd_5[100];
            double diff_macd_15[100];
            double diff_rsi[100];
            double diff_rsi_5[100];
            double diff_rsi_15[10];
            
         for(i=0;i<= lag_trend - 1;i++)
            {    
            diff_macd[i] = (macd[i] - macd[i + 1]) * (100000);
            diff_macd_5[i] = (macd_5min[i] - macd_5min[i + 1]) * (100000);
            diff_macd_15[i] = (macd_15min[i] - macd_15min[i + 1]) * (100000);
            
            diff_rsi[i] = (rsi[i] - rsi[i + 1]);
            diff_rsi_5[i] = (rsi_5min[i] - rsi_5min[i + 1]);
            diff_rsi_15[i] = (rsi_15min[i] - rsi_15min[i + 1]);
            
            sum_diff_macd = sum_diff_macd + diff_macd[i];  
            sum_diff_macd_5 = sum_diff_macd_5 + diff_macd_5[i];
            sum_diff_macd_15 = sum_diff_macd_15 + diff_macd_15[i];    
            
            sum_diff_rsi = sum_diff_rsi + diff_rsi[i];  
            sum_diff_rsi_5 = sum_diff_rsi_5 + diff_rsi_5[i];
            sum_diff_rsi_15 = sum_diff_rsi_15 + diff_rsi_15[i];    
            } 
            
            
         double trend_macd = sum_diff_macd/lag_trend;
         double trend_macd_actual = diff_macd[0];
         double macd_actual = macd[0] * (100000);
         double macd_diff_señal = macd_actual - iMACD(NULL,PERIOD_M15,fast_ema,slow_ema,signal,PRICE_CLOSE,MODE_SIGNAL,1);
         
         //Alert("trend_macd = " + trend_macd);
         //Alert("trend_macd_actual = " + trend_macd_actual);
         //Alert("macd_actual = " + macd_actual);
         
         double trend_macd_5min = sum_diff_macd_5/lag_trend;
         double trend_macd_5min_actual = diff_macd_5[0];
         double macd_5min_actual = macd_5min[0] * (100000);
         
         //Alert("trend_macd_5min = " + trend_macd_5min);
         //Alert("trend_macd_5min_actual = " + trend_macd_5min_actual);
         //Alert("macd_5min_actual = " + macd_5min_actual);
         
         double trend_macd_15min = sum_diff_macd_15/lag_trend;
         double trend_macd_15min_actual = diff_macd_15[0];
         double macd_15min_actual = macd_15min[0] * (100000);
         
         //Alert("trend_macd_15min = " + trend_macd_15min);
         //Alert("trend_macd_15min_actual = " + trend_macd_15min_actual);
         //Alert("macd_15min_actual = " + macd_15min_actual);
         
         double trend_rsi = sum_diff_rsi/lag_trend;
         double trend_rsi_actual = diff_rsi[0];
         double rsi_actual = rsi[0];
                   
         //Alert("trend_rsi = " + trend_rsi);
         //Alert("trend_rsi_actual = " + trend_rsi_actual);
         //Alert("rsi_actual = " + rsi_actual);
         
         double trend_rsi_5min = sum_diff_rsi_5/lag_trend;
         double trend_rsi_5min_actual = diff_rsi_5[0];
         double rsi_5min_actual = rsi_5min[0];
         
         //Alert("trend_rsi_5min = " + trend_rsi_5min);
         //Alert("trend_rsi_5min_actual = " + trend_rsi_5min_actual);
         //Alert("rsi_5min_actual = " + rsi_5min_actual);
         
         double trend_rsi_15min = sum_diff_rsi_15/lag_trend;
         double trend_rsi_15min_actual = diff_rsi_15[0];
         double rsi_15min_actual = rsi_15min[0];
         
         //Alert("trend_rsi_15min = " + trend_rsi_15min);
         //Alert("trend_rsi_15min_actual = " + trend_rsi_15min_actual);
         //Alert("rsi_15min_actual = " + rsi_15min_actual);
    
         double atr = iATR(NULL,0,14,0) * 10000;
         Alert("atr = " + atr);     
        
        // Rule 1: 
        
        
         if(
            // valor de MACD
            (macd_actual >= param_macd_actual_r1)
            // incremento de la Macd en la ultima barra
            && (trend_macd_actual >= param_trend_macd_actual_r1)
            // tendencia de la macd 
            && (trend_macd >= param_trend_macd_r1)
            // valor inferiror del rsi
            && (rsi_actual >= param_rsi_actual_r1)
            // valor superiror rsi 
            && (rsi_actual <= param_rsi2_actual_r1) 
            // tendencia deñ rsi
            && (trend_rsi >= param_trend_rsi_r1)
            // numero de ordenes simultaneas
            && (OrdersTotal() < max_oper)
            )
         {    
          //Alert("regla 1 dentro ");
          if (((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_BUY,lots_R1)) >= 0))
               {      
                      RefreshRates();
                      
                      
                      stop = Bid-((stoploss_R1*atr)*Point*10);  
                      take = Bid+((takeprofit_R1*atr)*Point*10);
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
            }
            
   // Exit rules for buy
   
       // RULE 2: 
      
         if((   
            (macd_actual <=  param_macd_actual_r2)
            && (trend_macd_actual <= param_trend_macd_actual_r2) 
            && (trend_macd <= param_trend_macd_r2)
            && (rsi_actual >= param_rsi_actual_r2)
            && (trend_rsi <= param_trend_rsi_r2)) 
            || ((rsi_actual >= param_rsi_r3)))
         {        
               //Alert("regla 2 dentro ");
               // close all buy orders
               for(i=0;i<=OrdersTotal() - 1;i++)
               {   
                if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                  { 
                     if (OrderType() == OP_BUY)
                     {   
                        RefreshRates();
                        Ans = OrderClose(OrderTicket(),OrderLots(),Bid,slimpage,Red);
                        if (Ans==false)          // Got it! :)
                        {
                         //Alert("no se ha podido cerrar");    // Exit closing cycle
                        }
                        else
                        {
                        }
                     } 
                  }    
               }        
     
           } 
           
           
    }       
   
   return(0);
  }
  
  
  int tema()
  {
 
   double Ema_fast[100];
   double EmaOfEma_fast[100];
   double EmaOfEmaOfEma_fast[100];
   double Tema_fast[100];
   
   double Ema_slow[100];
   double EmaOfEma_slow[100];
   double EmaOfEmaOfEma_slow[100];
   double Tema_slow[100];
   int i;
   
   // fast tema
   for (i=0;i<=lag_trend - 1;i++) Ema_fast[i]=iMA(NULL,0,fast_ema,0,MODE_EMA,PRICE_CLOSE,i + 1);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEma_fast[i]=iMAOnArray(Ema_fast,0,fast_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEmaOfEma_fast[i]=iMAOnArray(EmaOfEma_fast,0,fast_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) Tema_fast[i]=3*Ema_fast[i]-3*EmaOfEma_fast[i]+EmaOfEmaOfEma_fast[i];
   
   // slow ema
   for (i=0;i<=lag_trend - 1;i++) Ema_slow[i]=iMA(NULL,0,slow_ema,0,MODE_EMA,PRICE_CLOSE,i + 1);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEma_slow[i]=iMAOnArray(Ema_slow,0,slow_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEmaOfEma_slow[i]=iMAOnArray(EmaOfEma_slow,0,slow_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) Tema_slow[i]=3*Ema_fast[i]-3*EmaOfEma_fast[i]+EmaOfEmaOfEma_fast[i];
   
   for (i=0;i<=lag_trend - 1;i++) macd[i] =  Tema_fast[i] -  Tema_slow[i]; 
   
   
   // fast tema 5 min 
   for (i=0;i<=lag_trend - 1;i++) Ema_fast[i]=iMA(NULL,PERIOD_M5,fast_ema,0,MODE_EMA,PRICE_CLOSE,i + 1);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEma_fast[i]=iMAOnArray(Ema_fast,0,fast_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEmaOfEma_fast[i]=iMAOnArray(EmaOfEma_fast,0,fast_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) Tema_fast[i]=3*Ema_fast[i]-3*EmaOfEma_fast[i]+EmaOfEmaOfEma_fast[i];
   
   // slow ema 5 min
   for (i=0;i<=lag_trend - 1;i++) Ema_slow[i]=iMA(NULL,PERIOD_M5,slow_ema,0,MODE_EMA,PRICE_CLOSE,i + 1);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEma_slow[i]=iMAOnArray(Ema_slow,0,slow_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEmaOfEma_slow[i]=iMAOnArray(EmaOfEma_slow,0,slow_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) Tema_slow[i]=3*Ema_fast[i]-3*EmaOfEma_fast[i]+EmaOfEmaOfEma_fast[i];
   
   for (i=0;i<=lag_trend - 1;i++) macd_5min[i] =  Tema_fast[i] -  Tema_slow[i]; 
   
   
     // fast tema 15 min 
   for (i=0;i<=lag_trend - 1;i++) Ema_fast[i]=iMA(NULL,PERIOD_M15,fast_ema,0,MODE_EMA,PRICE_CLOSE,i + 1);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEma_fast[i]=iMAOnArray(Ema_fast,0,fast_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEmaOfEma_fast[i]=iMAOnArray(EmaOfEma_fast,0,fast_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) Tema_fast[i]=3*Ema_fast[i]-3*EmaOfEma_fast[i]+EmaOfEmaOfEma_fast[i];
   
   // slow ema 15 min
   for (i=0;i<=lag_trend - 1;i++) Ema_slow[i]=iMA(NULL,PERIOD_M15,slow_ema,0,MODE_EMA,PRICE_CLOSE,i + 1);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEma_slow[i]=iMAOnArray(Ema_slow,0,slow_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) EmaOfEmaOfEma_slow[i]=iMAOnArray(EmaOfEma_slow,0,slow_ema,0,MODE_EMA,i);
   for (i=0;i<=lag_trend - 1;i++) Tema_slow[i]=3*Ema_fast[i]-3*EmaOfEma_fast[i]+EmaOfEmaOfEma_fast[i];
   
   for (i=0;i<=lag_trend - 1;i++) macd_15min[i] =  Tema_fast[i] -  Tema_slow[i]; 
             
    return(0);
                         
  }
     
  
  
  