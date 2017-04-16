//+------------------------------------------------------------------+
//|                                                          CCI.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
//----
#property indicator_separate_window 
#property indicator_buffers 2
#property indicator_color1 LightSeaGreen
#property indicator_color2 Red
//---- input parameters

extern int CCIPeriod = 14;
extern double DPeriod = 3;

//---- buffers
double CCIBuffer[];
double RelBuffer[];
double DevBuffer[];
double MovBuffer[];
double buffer_signal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 3 additional buffers are used for counting.
   IndicatorBuffers(5);
   SetIndexBuffer(2, RelBuffer);
   SetIndexBuffer(3, DevBuffer);
   SetIndexBuffer(4, MovBuffer);
//---- indicator lines
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, CCIBuffer);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1,buffer_signal);
  
//----
   if(CCIPeriod <= 0)
       CCIPeriod = 14;
       
//---- name for DataWindow and indicator subwindow label
   short_name="CCI(" + CCIPeriod + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Main");
   SetIndexLabel(1,"Signal");
//----
   int draw_begin1=CCIPeriod;
   int draw_begin2=draw_begin1+DPeriod;
   SetIndexDrawBegin(0, draw_begin1);
   SetIndexDrawBegin(1,draw_begin2);

   return(0);
  }
//+------------------------------------------------------------------+
//| Commodity Channel Index                                          |
//+------------------------------------------------------------------+
int start()
  {
   int    i, k, counted_bars = IndicatorCounted();
   double price, sum, mul; 
   if(CCIPeriod <= 1)
       return(0);
   if(Bars <= CCIPeriod) 
       return(0);
//---- initial zero
   if(counted_bars < 1)
     {
       for(i = 1; i <= CCIPeriod; i++) 
           CCIBuffer[Bars-i] = 0.0;
       for(i = 1; i <= CCIPeriod; i++) 
           DevBuffer[Bars-i] = 0.0;
       for(i = 1; i <= CCIPeriod; i++) 
           MovBuffer[Bars-i] =0.0;
     }
//---- last counted bar will be recounted
   int limit = Bars - counted_bars;
   if(counted_bars > 0) 
       limit++;
//---- moving average
   for(i = 0; i < limit; i++)
       MovBuffer[i] = iMA(NULL, 0, CCIPeriod, 0, MODE_SMA, PRICE_TYPICAL, i);
//---- standard deviations
   i = Bars - CCIPeriod + 1;
   if(counted_bars > CCIPeriod - 1) 
       i = Bars - counted_bars - 1;
   mul = 0.015 / CCIPeriod;
   while(i >= 0)
     {
       sum = 0.0;
       k = i + CCIPeriod - 1;
       while(k >= i)
        {
          price =(High[k] + Low[k] + Close[k]) / 3;
          sum += MathAbs(price - MovBuffer[i]);
          k--;
        }
       DevBuffer[i] = sum*mul;
       i--;
     }
   i = Bars - CCIPeriod + 1;
   if(counted_bars > CCIPeriod - 1) 
       i = Bars - counted_bars - 1;
   while(i >= 0)
     {
       price = (High[i] + Low[i] + Close[i]) / 3;
       RelBuffer[i] = price - MovBuffer[i];
       i--;
     }
//---- cci counting
   i = Bars - CCIPeriod + 1;
   if(counted_bars > CCIPeriod - 1) 
       i = Bars - counted_bars - 1;
   while(i >= 0)
     {
       if(DevBuffer[i] == 0.0) 
           CCIBuffer[i] = 0.0;
       else 
           CCIBuffer[i] = RelBuffer[i] / DevBuffer[i];
       i--;
     }
//----
     i = Bars - CCIPeriod + 1;
   if(counted_bars > CCIPeriod - 1) 
       i = Bars - counted_bars - 1;
   while(i>=0)
     {
      buffer_signal[i]=iMAOnArray(CCIBuffer,0,DPeriod,0,MODE_SMA,i);
      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+

