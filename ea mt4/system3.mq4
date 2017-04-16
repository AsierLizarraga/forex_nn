#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
 
// min stop loss
double dist_min; 

// SLIMPAGE
double slimpage = 3;

// Trend SMA PARAMETERS 
double fast_ema = 10;
double slow_ema = 20;

// stochastic RULE 1 AND 2  
double param_stoch_k_r1 = 10;
double param_stoch_d_r1 = 6;
double param_slow_r1 = 6;

// RSI RULE 1 AND 2  
double param_rsi_lag_r1 = 14;

// MACD Rule 1
double param_macd_fast_ema_r1 = 12;
double param_macd_slow_ema_r1 = 26;
double param_macd_signal_ema_r1 = 9;

// Params RULE 1
extern double param_rsi_value_r1 = 50;
extern double param_macd_value_r1 = 0;
extern double param_ema_trend_r1 = 1;
extern double param_stoch_trend_r1 = 2;
extern double param_rsi_trend_r1 = 0.5;

extern double trallin_stop_R1 = 1;
extern double stop_loss_R1 = 1;
extern double lots_R1 = 0.1;

// Params RULE 2
extern double param_rsi_value_r2 = 50;
extern double param_macd_value_r2 = 0;
extern double param_ema_trend_r2 = -1;
extern double param_stoch_trend_r2 = -2;
extern double param_rsi_trend_r2 = -0.5;

extern double trallin_stop_R2 = 1;
extern double stop_loss_R2 = 1;
extern double lots_R2 = 0.1;

// R3: exit buy by stoch cross
extern double param_stoch_value_r3 = 80;

// R4: exit sell by stoch cross
extern double param_stoch_value_r4 = 20;

// R5: stop tralling  for buy
extern double param_stoch_r5 = 70;
 
// R6: stop tralling  for sell
extern double param_stoch_r6 = 30;

// tiket flags
int ticket = -1;
double tiket_stop_traling_buy_r1;
double tiket_stop_traling_sell_r2;

// enter positions
int enter_buy_r1 = 0;
int enter_sell_r2 = 0;
datetime lastBarOpenTime;

// TECHNICAL IndicatorShortName

     // EMA ACTUAL 
        double ema_fast_actual;
        double ema_slow_actual;
        
       // stochastic R1
       double stoch_actual_r1;
       double stoch_signal_actual_r1;
       
        //RSI R1
       double rsi_actual_r1;
       
       // MACD R1
       double macd_actual_r1;
       double macd_actual_signal_r1;
       
       
       // tendencia  FAST EMA
       double trend_fast_ema;     
       // tendencia rsi
       double trend_rsi;
       // tendencia stochastico
       double trend_stoch;

// flags

       bool flag_creciente_ema_r1 = false;
       bool flag_stoch_cruce_buy_r1 = false;
       bool flag_rsi_buy_r1 = false;
       bool flag_macd_buy_r1 = false;
       bool flag_decreciente_ema_r2 = false;
       bool flag_stoch_cruce_sell_r2 = false;
       bool flag_rsi_sell_r2 = false;
       bool flag_macd_sell_r2 = false;
       bool flag_stoch_cruce_exit_buy_r3 = false;
       bool flag_stoch_cruce_exit_sell_r4 = false;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   int i;
   dist_min = 5*Point*10;
   lastBarOpenTime = Time[0];
   return(0);
}
  
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
int ticket,i; 
double stop,take;
bool Ans;
int attempt = 0;
enter_buy_r1 = 0;
enter_sell_r2 = 0;
// trading europen hours
if((Hour() >= 0) && (Hour() <= 20))
{

// detect de orders actual 
        for(i=0;i<=OrdersTotal()-1;i++)
               {   
                if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                  { 
                     if (OrderType() == OP_BUY)
                     {   
                       enter_buy_r1 = 1;
                     } 
                     if (OrderType() == OP_SELL)
                     {   
                       enter_sell_r2 = 1;
                     } 
                  }    
               }       
   
// initial data checks
      if(Bars<100)
        {
         Print("bars less than 100");
         return(0);  
        }
        
   // if new bar is created  
   datetime thisBarOpenTime = Time[0];
   if(thisBarOpenTime != lastBarOpenTime) 
   {  
     lastBarOpenTime = thisBarOpenTime;  
     
     // EMA ACTUAL 
         ema_fast_actual = iMA(NULL,0,fast_ema,0,MODE_LWMA,PRICE_CLOSE,0);
         ema_slow_actual = iMA(NULL,0,slow_ema,0,MODE_SMA,PRICE_CLOSE,0);
        
       // stochastic R1
        stoch_actual_r1 = iStochastic(NULL,0,param_stoch_k_r1,param_stoch_d_r1,param_slow_r1,MODE_SMA,1,MODE_MAIN,0);
        stoch_signal_actual_r1 = iStochastic(NULL,0,param_stoch_k_r1,param_stoch_d_r1,param_slow_r1,MODE_SMA,1,MODE_SIGNAL,0);
       
        //RSI R1
         rsi_actual_r1 = iRSI(NULL,0,param_rsi_lag_r1,PRICE_CLOSE,0);
       
       // MACD R1
        macd_actual_r1 = iMACD(NULL,0,param_macd_fast_ema_r1,param_macd_slow_ema_r1,param_macd_signal_ema_r1,PRICE_CLOSE,MODE_MAIN,0);
        macd_actual_signal_r1 = iMACD(NULL,0,param_macd_fast_ema_r1,param_macd_slow_ema_r1,param_macd_signal_ema_r1,PRICE_CLOSE,MODE_SIGNAL,0);
       
       
       // tendencia  FAST EMA
        trend_fast_ema =   (((iMA(NULL,0,fast_ema,0,MODE_LWMA,PRICE_CLOSE,0) - iMA(NULL,0,fast_ema,0,MODE_LWMA,PRICE_CLOSE,1))
                               + (iMA(NULL,0,fast_ema,0,MODE_LWMA,PRICE_CLOSE,1) - iMA(NULL,0,fast_ema,0,MODE_LWMA,PRICE_CLOSE,2))
                               + (iMA(NULL,0,fast_ema,0,MODE_LWMA,PRICE_CLOSE,2) - iMA(NULL,0,fast_ema,0,MODE_LWMA,PRICE_CLOSE,3)))*10000)/3;      
    
       
       // tendencia rsi
        trend_rsi =        ((iRSI(NULL,0,param_rsi_lag_r1,PRICE_CLOSE,0) - iRSI(NULL,0,param_rsi_lag_r1,PRICE_CLOSE,1))
                               + (iRSI(NULL,0,param_rsi_lag_r1,PRICE_CLOSE,1) - iRSI(NULL,0,param_rsi_lag_r1,PRICE_CLOSE,2))
                               + (iRSI(NULL,0,param_rsi_lag_r1,PRICE_CLOSE,2) - iRSI(NULL,0,param_rsi_lag_r1,PRICE_CLOSE,3)))/3;
      
      
       
       // tendencia stochastico
        trend_stoch =     ((iStochastic(NULL,0,param_stoch_k_r1,param_stoch_d_r1,param_slow_r1,MODE_SMA,1,MODE_MAIN,0) - iStochastic(NULL,0,param_stoch_k_r1,param_stoch_d_r1,param_slow_r1,MODE_SMA,1,MODE_MAIN,1)) 
                              + (iStochastic(NULL,0,param_stoch_k_r1,param_stoch_d_r1,param_slow_r1,MODE_SMA,1,MODE_MAIN,1) - iStochastic(NULL,0,param_stoch_k_r1,param_stoch_d_r1,param_slow_r1,MODE_SMA,1,MODE_MAIN,2)) 
                              + (iStochastic(NULL,0,param_stoch_k_r1,param_stoch_d_r1,param_slow_r1,MODE_SMA,1,MODE_MAIN,2) - iStochastic(NULL,0,param_stoch_k_r1,param_stoch_d_r1,param_slow_r1,MODE_SMA,1,MODE_MAIN,3)))/3; 
     
    // Flags  
    
         if( 
            (ema_fast_actual > ema_slow_actual) 
            && (trend_fast_ema > param_ema_trend_r1)
            )
         {
            flag_creciente_ema_r1 = true;
         }    
         
         if( 
            (stoch_actual_r1 > stoch_signal_actual_r1 )
            && (trend_stoch > param_stoch_trend_r1) 
            )
         {
            flag_stoch_cruce_buy_r1 = true;
         }   
         
         if( 
              (rsi_actual_r1 > param_rsi_value_r1)
              && (trend_rsi > param_rsi_trend_r1)
            )
         {
            flag_rsi_buy_r1 = true;
         } 
         
         if( 
            (macd_actual_r1 > param_macd_value_r1) 
            && (macd_actual_r1 > macd_actual_signal_r1)
            )
         {
            flag_macd_buy_r1 = true;
         }
         
        if( 
            (ema_fast_actual < ema_slow_actual) 
            && (trend_fast_ema < param_ema_trend_r2)
            )
         {
            flag_decreciente_ema_r2 = true;
         }    
         
         if( 
            (stoch_actual_r1 < stoch_signal_actual_r1) 
            && (trend_stoch <  param_stoch_trend_r2)
            )
         {
            flag_stoch_cruce_sell_r2 = true;
         }   
         
         if( 
            (rsi_actual_r1 < param_rsi_value_r2)
            && (trend_rsi < param_rsi_trend_r2)
           )
         {
            flag_rsi_sell_r2 = true;
         } 
         
         if( 
            (macd_actual_r1 < param_macd_value_r2) 
            && (macd_actual_r1 < macd_actual_signal_r1) 
            )
         {
            flag_macd_sell_r2 = true;
         }
         
          if( 
            (stoch_actual_r1 < stoch_signal_actual_r1) 
            && (stoch_actual_r1 >=  param_stoch_value_r3) 
            )
         {
            flag_stoch_cruce_exit_buy_r3 = true;
         } 
         
         
         if( 
            (stoch_actual_r1 >  stoch_signal_actual_r1) 
            && (stoch_actual_r1 <=  param_stoch_value_r4)  
            )
         {
            flag_stoch_cruce_exit_sell_r4 = true;
         } 
     
         // entry buy RULE 1: 
         if( 
            (flag_creciente_ema_r1 == true) 
            && (flag_stoch_cruce_buy_r1 == true)
            && (flag_rsi_buy_r1 == true)
            && (flag_macd_buy_r1 == true)
            && (enter_buy_r1 == 0) 
            )
         {
            if (((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_BUY,lots_R1)) >= 0))
               {      
                      RefreshRates();
                      stop = Bid - MathMax(dist_min,(stop_loss_R1*(iATR(NULL,0,14,0))));  
                      take = 0;
                      ticket=OrderSend(Symbol(),OP_BUY,lots_R1,Ask,slimpage,stop,take,"Rule 1",1,0,Green);  
                      if(ticket<0)
                      {
                        Print("OrderSend failed with error #",GetLastError());
                        return(0); 
                      } 
                      else
                      {              
                      }        
               }    
         }
       
      // entry sell RULE 2: 
         if( 
            (flag_decreciente_ema_r2 == true) 
            && (flag_stoch_cruce_sell_r2 == true)
            && (flag_rsi_sell_r2 == true)
            && (flag_macd_sell_r2 == true)
            && (enter_sell_r2 == 0) 
            )
         {
           if (((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_SELL,lots_R2)) >= 0))
               {      
                      RefreshRates();
                      stop = Ask + MathMax(dist_min,(stop_loss_R2*(iATR(NULL,0,14,0))));
                      take = 0;
                      ticket=OrderSend(Symbol(),OP_SELL,lots_R2,Bid,slimpage,stop,take,"Rule 2",2,0,Green);  
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
    
      // RULE 3 exit BUY: 
         if(
            (enter_buy_r1 == 1)
            && (flag_stoch_cruce_exit_buy_r3 == true)
            )
         {
            for(i=0;i<=OrdersTotal() - 1;i++)
               {   
                if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                  { 
                     if (OrderType() == OP_BUY && OrderMagicNumber() == 1)
                     {   
                        RefreshRates();
                        Ans = OrderClose(OrderTicket(),OrderLots(),Bid,slimpage,Red);
                        if (Ans==false)         
                        {
                         Alert("no se ha podido cerrar");    // Exit closing cycle
                        }
                        else
                        {
                        }
                     } 
                  }    
               }
         }
      
         // RULE 4 exit SELL:
          if(
            (enter_sell_r2 == 1)
            && (flag_stoch_cruce_exit_sell_r4 == true) 
            )
         {
            for(i=0;i<=OrdersTotal() - 1;i++)
               {   
                if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                  { 
                  if (OrderType() == OP_SELL && OrderMagicNumber() == 2)
                     {  
                        RefreshRates();
                        Ans = OrderClose(OrderTicket(),OrderLots(),Ask,slimpage,Red);
                        if (Ans==false)         
                        {
                         Alert("no se ha podido cerrar");    // Exit closing cycle
                        }
                        else
                        {
                        }
                     }    
                  }
               }
          }       

         // Rule 5: stop tralling buy
         if(stoch_actual_r1 >= param_stoch_r5) 
         {
           for(i=0;i<=OrdersTotal() - 1;i++)
              {   
                if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                  { 
                     if (OrderType() == OP_BUY)
                     {   
                           tiket_stop_traling_buy_r1 = OrderTicket();
                     } 
                  }    
               }  
         }
         
        // Rule 6: stop tralling sell
         if(stoch_actual_r1 <= param_stoch_r6 ) 
         {           
              for(i=0;i<=OrdersTotal() - 1;i++)
               {   
                if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                  { 
                     if (OrderType() == OP_SELL)
                     {   
                           tiket_stop_traling_sell_r2 = OrderTicket(); 
                     } 
                  }    
               }        
         }
     
    //traling stop  buy
    
       if(tiket_stop_traling_buy_r1 != -1)
        {    
           if(OrderSelect(tiket_stop_traling_buy_r1,SELECT_BY_TICKET) && OrderCloseTime()==0) 
           {    
                if (Close[1] > Open[1])
                {
                double traling_stop_buy = Bid -  MathMax(dist_min,trallin_stop_R1*iATR(NULL,0,14,0));
                RefreshRates();
                OrderModify(tiket_stop_traling_buy_r1,OrderOpenPrice(),traling_stop_buy,0,0); 
                }    
           }     
         } 

     //traling stop  sell

       if(tiket_stop_traling_sell_r2 != -1)
        {    
           if(OrderSelect(tiket_stop_traling_sell_r2,SELECT_BY_TICKET) && OrderCloseTime()==0 ) 
           {     
                 if (Close[1] < Open[1])
                 {  
                 double traling_stop_sell = Ask + MathMax(dist_min,trallin_stop_R2*iATR(NULL,0,14,0));
                 RefreshRates();
                 OrderModify(tiket_stop_traling_sell_r2,OrderOpenPrice(),traling_stop_sell,0,0);
                 } 
           }      
         } 



      //Alert("ema_fast_actual = " + ema_fast_actual);
      //Alert("ema_slow_actual = " + ema_slow_actual);
      //Alert("stoch_actual_r1 = " + stoch_actual_r1);
      //Alert("stoch_signal_actual_r1 = " + stoch_signal_actual_r1);
      //Alert("rsi_actual_r1 = " + rsi_actual_r1);
      //Alert("macd_actual_r1 = " + macd_actual_r1);
      //Alert("macd_actual_signal_r1 = " + macd_actual_signal_r1);
      //Alert("trend_fast_ema = " + trend_fast_ema);
      //Alert("trend_rsi = " + trend_rsi);
      //Alert("trend_stoch = " + trend_stoch);
      
      Alert("flag_creciente_ema_r1 = " + flag_creciente_ema_r1);
      Alert("flag_stoch_cruce_buy_r1 = " + flag_stoch_cruce_buy_r1);
      Alert("flag_rsi_buy_r1 = " + flag_rsi_buy_r1);
      Alert("flag_macd_buy_r1 = " + flag_macd_buy_r1);
      
      //Alert("flag_decreciente_ema_r2 = " + flag_decreciente_ema_r2);
      //Alert("flag_stoch_cruce_sell_r2 = " + flag_stoch_cruce_sell_r2);
      //Alert("flag_rsi_sell_r2 = " + flag_rsi_sell_r2);
      //Alert("flag_macd_sell_r2 = " + flag_macd_sell_r2);
      
      //Alert("flag_stoch_cruce_exit_buy_r3 = " + flag_stoch_cruce_exit_buy_r3);

     // Alert("flag_stoch_cruce_exit_sell_r4 = " + flag_stoch_cruce_exit_sell_r4);
     

       // reset flags
     
       flag_creciente_ema_r1 = false;
       flag_stoch_cruce_buy_r1 = false;
       flag_rsi_buy_r1 = false;
       flag_macd_buy_r1 = false;
       flag_decreciente_ema_r2 = false;
       flag_stoch_cruce_sell_r2 = false;
       flag_rsi_sell_r2 = false;
       flag_macd_sell_r2 = false;
       flag_stoch_cruce_exit_buy_r3 = false;
       flag_stoch_cruce_exit_sell_r4 = false;
   }
   
        
    
     
 } 

   
return(0);
}
  


//int no_esta_buy(int ticket)
//  {   
//  int i;
//  no_esta = 0;
//      for(i=0;i<=max_oper-1;i++)
//        { 
//           if(tiket_stop_traling_buy[i] == ticket)
//           {
//               no_esta = 1;
//               break;
//           }
//         }
//    return(no_esta);       
//  }   
   
   
//int no_esta_sell(int ticket)
//  {   
//      int i;
//      no_esta = 0;
//      for(i=0;i<=max_oper-1;i++)
//       { 
//           if(tiket_stop_traling_sell[i] == ticket)
//           {
//               no_esta = 1;
//               break;
//           }
//        }
//    return(no_esta);          
//   }   





