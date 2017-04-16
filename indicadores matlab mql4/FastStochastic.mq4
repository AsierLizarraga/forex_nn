//+------------------------------------------------------------------+
//|                                              Fast Stochastic.mq4 |
//|                      Copyright � 2006, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
#include <stdlib.mqh>
//----
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1  20
#property indicator_level2  80
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int KPeriod = 5;
extern int DPeriod = 3;
//---- buffers
double MainBuffer[];
double SignalBuffer[];
double HighesBuffer[];
double LowesBuffer[];
//----
int draw_begin = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(4);
   SetIndexBuffer(2, HighesBuffer);
   SetIndexBuffer(3, LowesBuffer);
//---- indicator lines
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, MainBuffer);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="FastStoch(" + KPeriod + "," + DPeriod + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
   SetIndexLabel(1, "Signal");
//----
   draw_begin = KPeriod + DPeriod;
   SetIndexDrawBegin(0, KPeriod);
   SetIndexDrawBegin(1, draw_begin);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Stochastic oscillator                                            |
//+------------------------------------------------------------------+
int start()
  {
   int    i, k;
   int    counted_bars = IndicatorCounted();
   double price;
//----
   if(Bars <= draw_begin) 
       return(0);
//---- initial zero
   if(counted_bars < 1)
     {
       for(i = 1; i <= KPeriod; i++) 
           MainBuffer[Bars-i] = 0;
       for(i = 1; i <= draw_begin; i++) 
           SignalBuffer[Bars-i] = 0;
     }
//---- minimums counting
   i = Bars - KPeriod;
   if(counted_bars > KPeriod) 
       i = Bars - counted_bars - 1;
   while(i >= 0)
     {
       double min = 1000000;
       k = i + KPeriod - 1;
       while(k >= i)
         {
           price = Low[k];
           if(min > price) 
               min = price;
           k--;
         }
       LowesBuffer[i] = min;
       i--;
     }
//---- maximums counting
   i = Bars - KPeriod;
   if(counted_bars > KPeriod) 
       i = Bars - counted_bars - 1;
   while(i >= 0)
     {
       double max=-1000000;
       k = i + KPeriod - 1;
       while(k >= i)
         {
           price = High[k];
           if(max < price) 
               max = price;
           k--;
         }
       HighesBuffer[i] = max;
       i--;
     }
//---- %K line
   i = Bars - KPeriod;
   if(counted_bars > KPeriod) 
       i = Bars - counted_bars - 1;
   while(i >= 0)
     {  
       if(!CompareDoubles((HighesBuffer[i] - LowesBuffer[i]), 0.0)) 
           MainBuffer[i] = 100*(Close[i] - LowesBuffer[i]) / (HighesBuffer[i] - LowesBuffer[i]);
       i--;
     }
//---- last counted bar will be recounted
   if(counted_bars > 0) 
       counted_bars--;
   int limit = Bars - counted_bars;
//---- signal line is simple movimg average
   for(i = 0; i < limit; i++)
       SignalBuffer[i] = iMAOnArray(MainBuffer, Bars, DPeriod, 0, MODE_SMA, i);
//----
   return(0);
  }
//+------------------------------------------------------------------+