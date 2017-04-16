///+------------------------------------------------------------------+
//|                                                      eurusd5.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

// datetime of the bar
datetime lastBarOpenTime;
int entry_buy = 0;
int entry_sell = 0;
int ticket;
extern int slimpage = 3;

 // indicators variables
 double psar;   
 double adx;
 double adx_plus;
 double adx_minus;     
 double adx_anterior;
 double adx_plus_anterior;
 double adx_minus_anterior;      
 double stoch;
 double signal_stoch;      
 double stoch_anterior;
 double signal_stoch_anterior;    
 double rsi;       
 double atr;
 double val_up;
 double val_down;
 double val_sidewise;
 double tendencia;
 double adx_previous;
 double adx_current;

// flags 
 bool sell_psar = false; 
 bool buy_psar = false;  
 bool rsi_buy  = false; 
 bool rsi_sell = false; 
 bool adx_buy = false; 
 bool adx_sell = false; 
 bool adx_trend = false; 
 bool adx_extreme = false; 
 bool adx_exit = false; 
 bool stoch_cross_buy = false; 
 bool stoch_cross_sell = false; 
 bool stoch_buy = false; 
 bool stoch_sell = false; 
 bool stoch_signal_low = false; 
 bool stoch_signal_high = false; 
 bool atr_high = false; 
 bool atr_normal = false; 
 bool atr_low = false; 

 bool Ans;
 double stop = 0;
 double take = 0;
 double dist_min;


// MMA parameters
extern int MMA_PERIOD = 28;
extern int MMA_MODE_SMA = 3;
// adx parameters
extern double ADX_PERIOD = 14;
// stoch Period parameters
extern double stoch_k_period = 5;
extern double stoch_d_period = 3;
// rsi Period parameters
extern double rsi_period = 14;
// atr parameters 
extern double atr_period = 14;

// rule parammeters
extern double param_signal_low = 30;
extern double param_signal_high = 70;
extern double param_adx_exit = 2;
extern double param_adx_trend = 20;
extern double param_adx_extreme = 40;
extern double rsi_param_buy = 50;
extern double rsi_param_sell = 50;
extern double param_atr_high = 10;
extern double param_atr_normal = 5;
extern double param_atr_low = 5;

extern double umbral_up_side = 0.25;
extern double umbral_low_side = -0.25;

// rule 1
extern double lots_r1 = 1;
extern double stoploss_buy_r1 = 0;

// rule 2
extern double lots_r2 = 1;
extern double stoploss_buy_r2 = 0;

// rule 3
extern double lots_r3 = 1;
extern double stoploss_buy_r3 = 0;

// rule 4
extern double lots_r4 = 1;
extern double stoploss_buy_r4 = 0;

// rule 5
extern double lots_r5 = 1;
extern double stoploss_buy_r5 = 0;

// rule 6
extern double lots_r6 = 1;
extern double stoploss_sell_r6 = 0;

// rule 7
extern double lots_r7 = 1;
extern double stoploss_sell_r7 = 0;

// rule 8
extern double lots_r8 = 1;
extern double stoploss_sell_r8 = 0;

// rule 9
extern double lots_r9 = 1;
extern double stoploss_sell_r9 = 0;

// rule 10
extern double lots_r10 = 1;
extern double stoploss_sell_r10 = 0;

bool prediciones;

//+------------------------------------------------------------------+
//| MathMathExpert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   dist_min = 5*Point*10;
   lastBarOpenTime = Time[0];
   return(0);
  }
//+------------------------------------------------------------------+
//| MathMathExpert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| MathMathExpert start function                                            |
//+------------------------------------------------------------------+
int start()
  {        
       
   
           
// if new bar is created  
datetime thisBarOpenTime = Time[0];
if(thisBarOpenTime != lastBarOpenTime) 
{  
lastBarOpenTime = thisBarOpenTime;  
prediciones = false;

         adx = iADX(NULL,0,ADX_PERIOD,PRICE_HIGH,MODE_MAIN,1);
         adx_plus =iADX(NULL,0,ADX_PERIOD,PRICE_HIGH,MODE_PLUSDI,1);
         adx_minus =iADX(NULL,0,ADX_PERIOD,PRICE_HIGH,MODE_MINUSDI,1);
         adx_anterior = iADX(NULL,0,ADX_PERIOD,PRICE_HIGH,MODE_MAIN,2);
         adx_plus_anterior =iADX(NULL,0,ADX_PERIOD,PRICE_HIGH,MODE_PLUSDI,2);
         adx_minus_anterior =iADX(NULL,0,ADX_PERIOD,PRICE_HIGH,MODE_MINUSDI,2);
        
         stoch = iStochastic(NULL,0,stoch_k_period,stoch_d_period,3,MODE_SMA,0,MODE_MAIN,1);
         signal_stoch = iStochastic(NULL,0,stoch_k_period,stoch_d_period,3,MODE_SMA,0,MODE_SIGNAL,1);
         stoch_anterior = iStochastic(NULL,0,stoch_k_period,stoch_d_period,3,MODE_SMA,0,MODE_MAIN,2);
         signal_stoch_anterior = iStochastic(NULL,0,stoch_k_period,stoch_d_period,3,MODE_SMA,0,MODE_SIGNAL,2);
   
      
       // ADX flags 
      if(adx_plus > adx_minus && adx_plus_anterior < adx_minus_anterior)
      {
         adx_buy = true;
      }
      
      if(adx_plus < adx_minus && adx_plus_anterior > adx_minus_anterior)
      {
         adx_sell = true;
      }
      
       // stoch flags 
      if(stoch > signal_stoch && stoch_anterior < signal_stoch_anterior )
      {
         stoch_cross_buy = true;
      }
      
      if(stoch < signal_stoch && stoch_anterior > signal_stoch_anterior)
      {
         stoch_cross_sell = true;
      }
      
       if(stoch > signal_stoch)
      {
         stoch_buy = true;
      }
      
      if(stoch < signal_stoch)
      {
         stoch_sell = true;
      }
      
      if(signal_stoch < param_signal_low)
      {
         stoch_signal_low = true;
      }
   
      if(signal_stoch > param_signal_high)
      {
         stoch_signal_high = true;
      }

        
      val_up = iCustom(NULL,0,"MAAngle",MMA_MODE_SMA,MMA_PERIOD,4,0.25,1,0,0,1);
      val_down = iCustom(NULL,0,"MAAngle",MMA_MODE_SMA,MMA_PERIOD,4,0.25,1,0,1,1);
      val_sidewise = iCustom(NULL,0,"MAAngle",MMA_MODE_SMA,MMA_PERIOD,4,0.25,1,0,2,1);
      
      adx_previous = iADX(NULL,0,ADX_PERIOD,PRICE_HIGH,MODE_MAIN,2);
      adx_current = iADX(NULL,0,ADX_PERIOD,PRICE_HIGH,MODE_MAIN,1);
      
      psar = iSAR(NULL,0,0.02,0.2,1);
      rsi = iRSI(NULL,0,rsi_period,PRICE_CLOSE,1);
      atr = iATR(NULL,0,atr_period,1)*10000;
      
      
      // MMANGEL FLAGS  
      if (val_up != 0)
       {
          tendencia = val_up;
       }
       
       if (val_down != 0)
        {
          tendencia = val_down;
        }
 
         if (val_sidewise != 0)
         {
          tendencia = val_sidewise;
         }
      
      //  adx flags
     if( (adx_previous - adx_current) > param_adx_exit)
      {
         adx_exit = true;
      }   
      
      if(adx > param_adx_trend)
      {
         adx_trend = true;
      }
      
      if(adx > param_adx_extreme)
      {
         adx_extreme = true;
      }
         
      // psar flags  
      if(psar > Close[0])
      {  
          sell_psar = true;
      }

     if(psar < Close[0])
      {  
          buy_psar = true;
      }

      // rsi flags 
      if(rsi >= rsi_param_buy)
      {
         rsi_buy = true;
      }
      
      if(rsi <= rsi_param_sell)
      {
         rsi_sell = true;
      }   
      
       // atr
       if(atr >= param_atr_high)
      {
         atr_high = true;
      }
      
       if(atr >= param_atr_normal)
      {
         atr_normal = true;
      }
   
      if(atr < param_atr_low)
      {
         atr_low = true;
      }
         
      // ordenes abiertas
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
           
   
   // exit buy 11: stochastis croses in top
   
               if(
               (stoch_cross_sell == true && stoch_signal_high == true) 
               && (entry_buy == 1)
                  )
                   {           
                      for(i=0;i<=OrdersTotal() - 1;i++)
                      {   
                       if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                         { 
                            if (OrderType() == OP_BUY && OrderMagicNumber() != 5 )
                            {   
                               RefreshRates();
                               Ans = OrderClose(OrderTicket(),OrderLots(),Bid,slimpage,Red);
                               if (Ans==false)          
                               {
                                Alert("no se ha podido cerrar");   
                               }
 
                            } 
                         }    
                      }
                   } 
                   
      // exit buy/sell 12:   adx revert when is in a exit state (extreme)
      
               if( 
                  (adx_exit == true) 
                  && (adx_extreme == true) 
                  && (entry_buy == 1 || entry_sell == 1)
                  )
                   {           
                      for(i=0;i<=OrdersTotal() - 1;i++)
                      {   
                       if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                         { 
                           if(OrderMagicNumber() == 5 && OrderMagicNumber() == 10)
                           {
                               RefreshRates();
                               Ans = OrderClose(OrderTicket(),OrderLots(),Bid,slimpage,Red);
                               if (Ans==false)          
                               {
                                Alert("no se ha podido cerrar");   
                               } 
                            }   
                         }    
                      }
                   } 
                   
      // exit buy 13:   psar sell and stoch sell
      
               if( 
                  (sell_psar == true) 
                  && (stoch_sell == true)
                  && (entry_buy == 1)
                  )
                   {           
                      for(i=0;i<=OrdersTotal() - 1;i++)
                      {   
                       if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                         { 
                            if (OrderType() == OP_BUY && OrderMagicNumber() == 5)
                            {   
                               RefreshRates();
                               Ans = OrderClose(OrderTicket(),OrderLots(),Bid,slimpage,Red);
                               if (Ans==false)          
                               {
                                Alert("no se ha podido cerrar");   
                               }
 
                            } 
                         }    
                      }
                   } 
                     
   
       // exit sell 14: psar buy and stoch buy
       
                   if( 
                     (buy_psar == true) 
                     && (stoch_buy == true) 
                     && (entry_buy == 1)
                     )
                   {
                     // close all sell orders
                      for(i=0;i<=OrdersTotal() - 1;i++)
                      {   
                         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                         { 
                         if( OrderType() == OP_SELL && OrderMagicNumber() == 10)
                            {   
                               RefreshRates();
                               Ans = OrderClose(OrderTicket(),OrderLots(),Ask,slimpage,Red);
                               if (Ans==false)          // Got it! :)
                               {
                                Alert("no se ha podido cerrar");    // Exit closing cycle
                               } 
                            } 
                         }                  
                     }
                  } 
                  
         // exit sell 15: stoch croses and stoch signal down
         
                   if( 
                     (stoch_cross_buy == true && stoch_signal_low == true) 
                     && (entry_buy == 1)
                     )
                   {
                     // close all sell orders
                      for(i=0;i<=OrdersTotal() - 1;i++)
                      {   
                         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
                         { 
                         if( OrderType() == OP_SELL && OrderMagicNumber() != 10)
                            {   
                               RefreshRates();
                               Ans = OrderClose(OrderTicket(),OrderLots(),Ask,slimpage,Red);
                               if (Ans==false)          // Got it! :)
                               {
                                Alert("no se ha podido cerrar");    // Exit closing cycle
                               } 
                            } 
                         }                  
                     }
                  }           
                  
       // update the number of orders
             entry_buy = 0;
             entry_sell = 0;
      
           for(i=0;i<=OrdersTotal() - 1;i++)
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

// in hours      
if(Hour() >= 7 && Hour() <= 17)
{

// rule 1: entry buy in crosses stoch and stoch low and trend sidewise
            if( 
               (stoch_cross_buy == true)
               && (stoch_signal_low == true)
               && (tendencia <= umbral_up_side && tendencia >= umbral_low_side)
               && (entry_buy == 0) 
               )       
            {
             if ((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_BUY,lots_r1)) > 0 )
               {     
                     RefreshRates();
                     stop = MathMin((Bid - dist_min),low_swin() - (stoploss_buy_r1*iATR(NULL,0,7,0)));  
                     //take = Bid + (takeprofit_buy*Point*10);
                     //stop = 0;
                     take = 0;
                     ticket=OrderSend(Symbol(),OP_BUY,lots_r1,Ask,slimpage,stop,take,"Rule 1",1,0,Green);  
                     if(ticket<0)
                     {
                        Print("OrderSend failed with error #",GetLastError());
                        return(0);
                      }  
                      else
                      {
                      entry_buy = 1;
                      }  
                }     
            }
            

            
  // reset flags  
  sell_psar = false; 
  buy_psar = false;  
  rsi_buy  = false; 
  rsi_sell = false; 
  adx_buy = false; 
  adx_sell = false; 
  adx_trend = false; 
  adx_extreme = false; 
  adx_exit = false; 
  stoch_cross_buy = false; 
  stoch_cross_sell = false; 
  stoch_buy = false; 
  stoch_sell = false; 
  stoch_signal_low = false; 
  stoch_signal_high = false; 
  atr_high = false; 
  atr_normal = false; 
  atr_low = false;          
            
  
                 
} 
} 
   return(0);   
}

double low_swin()
{
   double low_swin; 
   bool encontrado = false;
   int i = 2;
   while(encontrado == false)
   {   
                if(Low[i] <=  Low[i+1] && Low[i] <=  Low[i-1])
                  { 
                     low_swin = Low[i]; 
                     encontrado = true;
                  }
            i = i + 1;
    }        
   return(low_swin);
}

double high_swin()
{
   double high_swin; 
   bool encontrado = false;
   int i = 2;
   while(encontrado == false)
   {   
                if(High[i] >=  High[i+1] && High[i] >=  High[i-1])
                  { 
                     high_swin = High[i]; 
                     encontrado = true;
                  }
                  
                  i = i + 1;
    }        
   return(high_swin);
}



