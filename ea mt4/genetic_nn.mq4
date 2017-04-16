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

// entry buy in up trend
extern double entry_buy_trend_up = 0.2;
extern double lots_buy_trend_up = 1;
extern double stoploss_buy_trend_up = 0.5;

// entry buy in down trend
extern double entry_buy_trend_down = 0.1;
extern double lots_buy_trend_down = 1;
extern double stoploss_buy_trend_down = 0.1;

// entry buy sidewise trend
extern double entry_buy_trend_side_wise = 0.1;
extern double lots_buy_trend_side_wise = 1;
extern double stoploss_buy_trend_side_wise = 0.1;


// entry sell in up trend
extern double entry_sell_trend_up = 0.7;
extern double lots_sell_trend_up = 1;
extern double stoploss_sell_trend_up = 0.5;

// entry sell in down trend
extern double entry_sell_trend_down = 0.9;
extern double lots_sell_trend_down = 1;
extern double stoploss_sell_trend_down = 0.5;

// entry sell in side wise trend
extern double entry_sell_trend_side_wise = 0.9;
extern double lots_sell_trend_side_wise = 1;
extern double stoploss_sell_trend_side_wise = 0.5;

// exit buy in trend up
extern double exit_buy_trend_up = 0.95;
// exit buy in trend down
extern double exit_buy_trend_down = 0.7;
// exit buy in trend side wise
extern double exit_buy_trend_side_wise = 0.9;

// exit sell in trend up
extern double exit_sell_trend_up = 0.2;
// exit sell in trend down
extern double exit_sell_trend_down = 0.1;
// exit sell in trend side wise
extern double exit_sell_trend_side_wise = 0.15;

bool Ans;
double stop = 0;
double take = 0;

// input variables
double dist_min;

// input variables
double x1;
double x2;
double x3;
double x4;
double x5;
double x6;
double x7;
double x8;
double x9;
double x10;
double x11;
double x12;
double x13;
double x14;

double output;
double tendencia; 
double pred;
double signal;
double pred_anterior = -1;

double val_up;
double val_down;
double val_sidewise;

double array_pred[3];


bool prediciones;

//+------------------------------------------------------------------+
//| MathMathExpert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   dist_min = 5*Point*10;
   lastBarOpenTime = Time[0];
   
   pred = iCustom(NULL,0,"gen_ind_v1",500,3,0,1);
   array_pred[0] = pred;
   array_pred[1] = iCustom(NULL,0,"gen_ind_v1",500,3,0,2);
   array_pred[2] = iCustom(NULL,0,"gen_ind_v1",500,3,0,3);
   
   signal = (array_pred[0] + array_pred[1] + array_pred[2])/3;

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
     
     // si hay alguna orden
     if(entry_buy == 1 || entry_sell == 1)
     {
     
       // MMANGLE: DETECT THE TREND
        val_up = iCustom(NULL,0,"MAAngle",3,20,4,0.2,0,0,0,1);
        val_down = iCustom(NULL,0,"MAAngle",3,20,4,0.2,0,0,1,1);
        val_sidewise = iCustom(NULL,0,"MAAngle",3,20,4,0.2,0,0,2,1);


      if (val_up != 0)
      {
         tendencia = 1;
      }
      
       if (val_down != 0)
      {
         tendencia = 2;
      }
 
       if (val_sidewise != 0)
      {
         tendencia = 3;
      }
      
         // predictions 
         pred_anterior = pred;

         i=1;
         x1 = iCustom(NULL,0,"MACD",12,26,9,0,i);
         x2 = iCustom(NULL,0,"FastStochastic",5,3,0,i);
         x3 = iCustom(NULL,0,"FastStochastic",5,3,1,i);
         x4 = iCustom(NULL,0,"FastStochastic",10,3,0,i);
         x5 = iCustom(NULL,0,"FastStochastic",10,3,1,i);
         
         x6 = iMA(NULL,0,3,0,MODE_SMA,PRICE_CLOSE,i);
         x7 = iMA(NULL,0,5,0,MODE_SMA,PRICE_CLOSE,i);
         x8 = iMA(NULL,0,25,0,MODE_SMA,PRICE_CLOSE,i);
         x9 = iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,i);
         
         
         x10 = iCustom(NULL,0,"RSI",3,0,i);
         x11 = iCustom(NULL,0,"RSI",5,0,i);
         x12 = iCustom(NULL,0,"RSI",25,0,i);
         x13 = iCustom(NULL,0,"Bands",10,0,2,1,i);  
         x14 = iCustom(NULL,0,"Bands",10,0,2,2,i);
      
         nn_eval_11();

         array_pred[2] = array_pred[1];
         array_pred[1] = array_pred[0];
         array_pred[0] = pred;

         signal = (array_pred[0] + array_pred[1] + array_pred[2])/3;
         

   // exit buy in trend down 
            
               if( (pred_anterior > exit_buy_trend_up && pred <= exit_buy_trend_up) && (entry_buy == 1)  && (tendencia == 1) )
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
                               if (Ans==false)          // Got it! :)
                               {
                                Alert("no se ha podido cerrar");    // Exit closing cycle
                               }
 
                            } 
                         }    
                      }
                   }
            
   // exit buy in trend down 
           
               if( (pred_anterior > exit_buy_trend_down && pred <= exit_buy_trend_down) && (entry_buy == 1)  && (tendencia == 2) )
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
                               if (Ans==false)          // Got it! :)
                               {
                                Alert("no se ha podido cerrar");    // Exit closing cycle
                               }
 
                            } 
                         }    
                      }
                   }        
            
    // exit buy in trend sidewise 
            
               if( (pred_anterior > exit_buy_trend_side_wise && pred <= exit_buy_trend_side_wise) && (entry_buy == 1)  && (tendencia == 3) )
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
                               if (Ans==false)          // Got it! :)
                               {
                                Alert("no se ha podido cerrar");    // Exit closing cycle
                               }
 
                            } 
                         }    
                      }
                   }        
                                   
       // exit sell in trend up 
       
                   if( (pred_anterior < exit_sell_trend_up && pred >= exit_sell_trend_up) && (entry_sell == 1) && (tendencia == 1) )
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
                               if (Ans==false)          // Got it! :)
                               {
                                Alert("no se ha podido cerrar");    // Exit closing cycle
                               } 
                            } 
                         }                  
                     }
                   }     
            
     // exit sell in trend down 
            
                   if ( (pred_anterior < exit_sell_trend_down && pred >= exit_sell_trend_down) && (entry_sell == 1) && (tendencia == 2) )
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
                               if (Ans==false)          // Got it! :)
                               {
                                Alert("no se ha podido cerrar");    // Exit closing cycle
                               } 
                            } 
                         }                  
                     }
                   }            
            
      // exit sell in trend sidewise
               
                   if ( (pred_anterior < exit_sell_trend_side_wise && pred >= exit_sell_trend_side_wise) && (entry_sell == 1) && (tendencia == 3) )
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
             
             prediciones = true;       
     }
     
  
// in hours      
if(Hour() >= 6 && Hour() <= 18)
{

if(prediciones == false)
{
   
     // MMANGLE: DETECT THE TREND
        val_up = iCustom(NULL,0,"MAAngle",3,20,4,0.2,0,0,0,1);
        val_down = iCustom(NULL,0,"MAAngle",3,20,4,0.2,0,0,1,1);
        val_sidewise = iCustom(NULL,0,"MAAngle",3,20,4,0.2,0,0,2,1);


      if (val_up != 0)
      {
         tendencia = 1;
      }
      
       if (val_down != 0)
      {
         tendencia = 2;
      }
 
       if (val_sidewise != 0)
      {
         tendencia = 3;
      }
      
      // predictions 
         pred_anterior = pred;
      
         i=1;
         x1 = iCustom(NULL,0,"MACD",12,26,9,0,i);
         x2 = iCustom(NULL,0,"FastStochastic",5,3,0,i);
         x3 = iCustom(NULL,0,"FastStochastic",5,3,1,i);
         x4 = iCustom(NULL,0,"FastStochastic",10,3,0,i);
         x5 = iCustom(NULL,0,"FastStochastic",10,3,1,i);
         x6 = iMA(NULL,0,3,0,MODE_SMA,PRICE_CLOSE,i);
         x7 = iMA(NULL,0,5,0,MODE_SMA,PRICE_CLOSE,i);
         x8 = iMA(NULL,0,25,0,MODE_SMA,PRICE_CLOSE,i);
         x9 = iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,i);
         x10 = iCustom(NULL,0,"RSI",3,0,i);
         x11 = iCustom(NULL,0,"RSI",5,0,i);
         x12 = iCustom(NULL,0,"RSI",25,0,i);
         x13 = iCustom(NULL,0,"Bands",10,0,2,1,i);  
         x14 = iCustom(NULL,0,"Bands",10,0,2,2,i);
      
         nn_eval_11();
         

         array_pred[2] = array_pred[1];
         array_pred[1] = array_pred[0];
         array_pred[0] = pred;
   
         signal = (array_pred[0] + array_pred[1] + array_pred[2])/3;
         
 
}


// entry buy in trend up

            if( (pred_anterior < entry_buy_trend_up && pred >= entry_buy_trend_up) && (entry_buy == 0) && (tendencia == 1) )        
            {
             if ((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_BUY,lots_buy_trend_up)) > 0 )
               {     
                     RefreshRates();
                     stop = MathMin((Bid - dist_min),low_swin() - (stoploss_buy_trend_up*iATR(NULL,0,7,0)));  
                     //take = Bid + (takeprofit_buy*Point*10);
                     //stop = 0;
                     take = 0;
                     ticket=OrderSend(Symbol(),OP_BUY,lots_buy_trend_up,Ask,slimpage,stop,take,"Rule 1",1,0,Green);  
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
                  
// entry buy in trend down

            if( (pred_anterior < entry_buy_trend_down && pred >= entry_buy_trend_down) && (entry_buy == 0) && (tendencia == 2) )        
            {
             if ((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_BUY,lots_buy_trend_down)) > 0 )
               {     
                     RefreshRates();
                     stop = MathMin((Bid - dist_min),low_swin() - (stoploss_buy_trend_down*iATR(NULL,0,7,0)));  
                     //take = Bid + (takeprofit_buy*Point*10);
                     //stop = 0;
                     take = 0;
                     ticket=OrderSend(Symbol(),OP_BUY,lots_buy_trend_down,Ask,slimpage,stop,take,"Rule 1",1,0,Green);  
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
            
            
  // entry buy in trend sidewise

            if( (pred_anterior < entry_buy_trend_side_wise && pred >= entry_buy_trend_side_wise) && (entry_buy == 0) && (tendencia == 3) )        
            {
             if ((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_BUY,lots_buy_trend_side_wise)) > 0 )
               {     
                     RefreshRates();
                     stop = MathMin ( (Bid - dist_min),low_swin() - (stoploss_buy_trend_side_wise*iATR(NULL,0,7,0)) );  
                     //take = Bid + (takeprofit_buy*Point*10);
                     //stop = 0;
                     take = 0;
                     ticket=OrderSend(Symbol(),OP_BUY,lots_buy_trend_side_wise,Ask,slimpage,stop,take,"Rule 1",1,0,Green);  
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
            
 
// entry sell  trend up

            if( (pred_anterior > entry_sell_trend_up && pred <= entry_sell_trend_up) && (entry_sell == 0) && (tendencia == 1) ) 
            {
              if ((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_SELL,lots_sell_trend_up)) > 0 )
               {
                     RefreshRates();
                     stop = MathMax((Ask + dist_min),high_swin() + (stoploss_sell_trend_up*iATR(NULL,0,14,0)));
                     //take = 0;
                     //stop = 0;
                     ticket=OrderSend(Symbol(),OP_SELL,lots_sell_trend_up,Bid,slimpage,stop,take,"Rule 2",2,0,Green);
                     if(ticket<0)
                     {
                       Print("OrderSend failed with error #",GetLastError());
                       return(0);
                      }  
                        else
                      {
                      entry_sell = 1;
                      }   
                }            
            } 
            
            
// entry sell  trend down
          
            if( (pred_anterior > entry_sell_trend_down && pred <= entry_sell_trend_down) && (entry_sell == 0) &&  (tendencia == 2) ) 
            {
              if ((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_SELL,lots_sell_trend_down)) > 0 )
               {
                     RefreshRates();
                     stop = MathMax((Ask + dist_min),high_swin() + (stoploss_sell_trend_down*iATR(NULL,0,14,0)));
                     //take = 0;
                     //stop = 0;
                     ticket=OrderSend(Symbol(),OP_SELL,lots_sell_trend_down,Bid,slimpage,stop,take,"Rule 2",2,0,Green);
                     if(ticket<0)
                     {
                       Print("OrderSend failed with error #",GetLastError());
                       return(0);
                      }  
                        else
                      {
                      entry_sell = 1;
                      }   
                }            
            } 
              
            
         // entry sell  trend sidewise
         
            if( (pred_anterior > entry_sell_trend_side_wise && pred <= entry_sell_trend_side_wise) && (entry_sell == 0) &&  (tendencia == 3) ) 
            {
              if ((AccountFreeMargin() - AccountFreeMarginCheck(Symbol(),OP_SELL,lots_sell_trend_side_wise)) > 0 )
               {
                     RefreshRates();
                     stop = MathMax((Ask + dist_min),high_swin() + (stoploss_sell_trend_side_wise*iATR(NULL,0,14,0)));
                     //take = 0;
                     //stop = 0;
                     ticket=OrderSend(Symbol(),OP_SELL,lots_sell_trend_side_wise,Bid,slimpage,stop,take,"Rule 2",2,0,Green);
                     if(ticket<0)
                     {
                       Print("OrderSend failed with error #",GetLastError());
                       return(0);
                      }  
                        else
                      {
                      entry_sell = 1;
                      }   
                }            
            }     


// in the hours    
} 
} 
   return(0);   
}
//+------------------------------------------------------------------+


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


void nn_eval_11()
{
  
x14 =(2.00000000)*(x14 -1.37438992)/(0.04954701) -1.00000000;
x13 =(2.00000000)*(x13 -1.37734270)/(0.04797418) -1.00000000;
x12 =(2.00000000)*(x12 -8.73563218)/(77.16515111) -1.00000000;
x11 =(2.00000000)*(x11 -0.00000000)/(100.00000000) -1.00000000;
x10 =(2.00000000)*(x10 -0.00000000)/(100.00000000) -1.00000000;
x9 =(2.00000000)*(x9 -1.37582180)/(0.04795780) -1.00000000;
x8 =(2.00000000)*(x8 -1.37609600)/(0.04787440) -1.00000000;
x7 =(2.00000000)*(x7 -1.37620400)/(0.04811200) -1.00000000;
x6 =(2.00000000)*(x6 -1.37575667)/(0.04861667) -1.00000000;
x5 =(2.00000000)*(x5 -2.32314101)/(95.32422424) -1.00000000;
x4 =(2.00000000)*(x4 -0.00000000)/(100.00000000) -1.00000000;
x3 =(2.00000000)*(x3 -3.64410960)/(93.95124587) -1.00000000;
x2 =(2.00000000)*(x2 -0.00000000)/(100.00000000) -1.00000000;
x1 =(2.00000000)*(x1 +0.00192197)/(0.00439457) -1.00000000;

x14 =(2.00000000)*(x14 +1.00000000)/(2.00000000) -1.00000000;
x13 =(2.00000000)*(x13 +1.00000000)/(2.00000000) -1.00000000;
x12 =(2.00000000)*(x12 +1.00000000)/(2.00000000) -1.00000000;
x11 =(2.00000000)*(x11 +1.00000000)/(2.00000000) -1.00000000;
x10 =(2.00000000)*(x10 +1.00000000)/(2.00000000) -1.00000000;
x9 =(2.00000000)*(x9 +1.00000000)/(2.00000000) -1.00000000;
x8 =(2.00000000)*(x8 +1.00000000)/(2.00000000) -1.00000000;
x7 =(2.00000000)*(x7 +1.00000000)/(2.00000000) -1.00000000;
x6 =(2.00000000)*(x6 +1.00000000)/(2.00000000) -1.00000000;
x5 =(2.00000000)*(x5 +1.00000000)/(2.00000000) -1.00000000;
x4 =(2.00000000)*(x4 +1.00000000)/(2.00000000) -1.00000000;
x3 =(2.00000000)*(x3 +1.00000000)/(2.00000000) -1.00000000;
x2 =(2.00000000)*(x2 +1.00000000)/(2.00000000) -1.00000000;
x1 =(2.00000000)*(x1 +1.00000000)/(2.00000000) -1.00000000;

output = (2/(1+MathExp(-2*((2/(1+MathExp(-2*(x1*(0.527004) + x2*(-0.019911) + x3*(-0.749410) + x4*(0.453871) + x5*(-0.006813) + x6*(-0.054866) + x7*(-0.641618) + x8*(-0.711435) + x9*(0.416331) + x10*(0.585462) + x11*(0.105131) + x12*(0.271018) + x13*(0.330862) + x14*(-0.425244) -1.690419)))-1)*(0.041704) + (2/(1+MathExp(-2*(x1*(0.674795) + x2*(0.134948) + x3*(-0.076732) + x4*(0.664730) + x5*(-0.750451) + x6*(0.310105) + x7*(-0.182932) + x8*(-0.525594) + x9*(0.088431) + x10*(0.447007) + x11*(0.258955) + x12*(-0.648366) + x13*(-0.409320) + x14*(-0.323318) -1.430354)))-1)*(0.515897) + (2/(1+MathExp(-2*(x1*(0.364302) + x2*(-0.621395) + x3*(0.147435) + x4*(-0.612375) + x5*(-0.390344) + x6*(0.395274) + x7*(-0.334798) + x8*(-0.643384) + x9*(0.441852) + x10*(0.124326) + x11*(0.011932) + x12*(0.644070) + x13*(0.460655) + x14*(0.519061) -1.170290)))-1)*(-0.103676) + (2/(1+MathExp(-2*(x1*(-0.547046) + x2*(0.662415) + x3*(-0.193724) + x4*(-0.472864) + x5*(0.651890) + x6*(-0.440815) + x7*(-0.035989) + x8*(0.326103) + x9*(-0.245633) + x10*(-0.560766) + x11*(-0.454448) + x12*(-0.036208) + x13*(-0.451460) + x14*(0.587343) + 0.910226)))-1)*(0.207497) + (2/(1+MathExp(-2*(x1*(-0.479233) + x2*(0.570524) + x3*(0.501957) + x4*(0.226685) + x5*(-0.710672) + x6*(0.337323) + x7*(-0.331900) + x8*(-0.488455) + x9*(0.533772) + x10*(0.342372) + x11*(-0.590529) + x12*(0.273225) + x13*(0.442291) + x14*(0.101446) + 0.650161)))-1)*(0.509841) + (2/(1+MathExp(-2*(x1*(-0.235862) + x2*(-0.187953) + x3*(0.758926) + x4*(0.053720) + x5*(-0.243482) + x6*(-0.347092) + x7*(-0.769875) + x8*(0.197533) + x9*(0.522316) + x10*(0.778544) + x11*(-0.052523) + x12*(-0.702251) + x13*(0.008865) + x14*(-0.035809) + 0.390097)))-1)*(0.465892) + (2/(1+MathExp(-2*(x1*(0.471226) + x2*(-0.616972) + x3*(0.193331) + x4*(-0.001618) + x5*(-0.105257) + x6*(-0.587865) + x7*(0.622111) + x8*(0.069168) + x9*(-0.340188) + x10*(0.082286) + x11*(-0.634813) + x12*(-0.657097) + x13*(0.268320) + x14*(-0.663100) -0.130032)))-1)*(0.726673) + (2/(1+MathExp(-2*(x1*(0.534733) + 










x2*(0.044608) +
 x3*(0.518205) + x4*(0.495710) + x5*(0.230729) + x6*(0.159997) + x7*(0.429640) + x8*(0.544541) + x9*(0.359329) + x10*(0.480601) + x11*(0.592411) + x12*(0.509385) + x13*(-0.406052) + x14*(-0.599978) + 0.130032)))-1)*(0.832810) + (2/(1+MathExp(-2*(x1*(0.533302) + x2*(0.103890) + x3*(0.509514) + x4*(0.102046) + x5*(-0.500357) + x6*(0.420776) + x7*(-0.428323) + x8*(0.232609) + x9*(-0.403646) + x10*(0.657747) + x11*(0.199233) + x12*(0.400387) + x13*(-0.633773) + x14*(0.655808) + 0.390097)))-1)*(0.776986) + (2/(1+MathExp(-2*(x1*(-0.320686) + x2*(0.160656) + x3*(-0.671806) + x4*(-0.368950) + x5*(0.543698) + x6*(0.506078) + x7*(0.355179) + x8*(-0.136199) + x9*(0.488644) + x10*(0.670720) + x11*(0.601672) + x12*(0.030349) + x13*(-0.626331) + x14*(-0.033691) -0.650161)))-1)*(0.378397) + (2/(1+MathExp(-2*(x1*(-0.422517) + x2*(-0.341887) + x3*(-0.868032) + x4*(0.055990) + x5*(0.520045) + x6*(-0.987179) + x7*(-0.080838) + x8*(-0.031125) + x9*(0.247316) + x10*(-0.308188) + x11*(0.430182) + x12*(0.171790) + x13*(-0.281315) + x14*(-0.321199) -0.910226)))-1)*(0.148091) + (2/(1+MathExp(-2*(x1*(-0.009162) + x2*(-0.093025) + x3*(-0.405527) + x4*(-0.589576) + x5*(0.009344) + x6*(-0.177762) + x7*(-0.581071) + x8*(-0.169898) + x9*(0.346571) + x10*(-0.687951) + x11*(-0.460946) + x12*(-0.517165) + x13*(0.598587) + x14*(-0.711973) -1.170290)))-1)*(-0.520390) + (2/(1+MathExp(-2*(x1*(-0.340187) + x2*(0.432393) + x3*(0.324520) + x4*(0.719984) + x5*(0.443154) + x6*(0.572720) + x7*(-0.169916) + x8*(0.437413) + x9*(-0.705372) + x10*(-0.635410) + x11*(0.361291) + x12*(-0.230592) + x13*(0.013670) + x14*(0.318358) -1.430354)))-1)*(0.796888) + (2/(1+MathExp(-2*(x1*(-0.403453) + x2*(-0.168923) + x3*(0.481029) + x4*(-0.516371) + x5*(0.532895) + x6*(0.329430) + x7*(-0.369583) + x8*(0.733617) + x9*(0.455184) + x10*(0.245014) + x11*(-0.238527) + x12*(-0.671229) + x13*(0.570886) + x14*(0.017749) -1.690419)))-1)*(0.580302) + 0.791409)))-1);

pred = ((0.99969077* output) - (0.00000661* output) - (0.99969077*(-1.00000000)) + (0.00000661*1.00000000)) / (2.00000000);
  
}