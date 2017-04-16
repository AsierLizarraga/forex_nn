//+------------------------------------------------------------------+
//|                                                  ort_data.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
  
  int handle;
  int length = 20000;
  string nameData = "EURUSD_historial.csv";
  handle = FileOpen(nameData,FILE_CSV|FILE_WRITE,';');
  if(handle < 1)
  {
    Comment("Creation of "+nameData+" failed. Error #", GetLastError());
    return(0);
  }
  FileWrite(handle, "FECHA","APERTURA","ALTO","BAJO","CIERRE","VOLUMEN","tendencia","ema_5","ema_25",
                      "ema_50","stoch_5_5_3","stoch_signal_5_5_3","rsi_14","cci_14","trend_ema_5","trend_ema_25","trend_ema_50","trend_rsi_14",
                      "trend_stoch_5_5_3","trend_cci_14","rsi_3","trend_rsi_3","bolinger_10_down","bolinger_10_upper"); 
            
// heading
  for(int i=length; i>=1; i--)
  {
  
       //double ema_fast_actual = iMA(NULL,0,fast_ema,0,MODE_LWMA,PRICE_CLOSE,0);
       double ema_5 = iMA(NULL,0,5,0,MODE_SMA,PRICE_CLOSE,i);
       double ema_25 = iMA(NULL,0,25,0,MODE_SMA,PRICE_CLOSE,i);
       double ema_50 = iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,i);
       
       // stochastic 
       double stoch_5_5_3 = iStochastic(NULL,0,5,5,3,MODE_SMA,1,MODE_MAIN,i);
       double stoch_signal_5_5_3 = iStochastic(NULL,0,5,5,3,MODE_SMA,1,MODE_SIGNAL,i);
       
       //RSI 
       double rsi_14 = iRSI(NULL,0,14,PRICE_CLOSE,i);
       double rsi_3 = iRSI(NULL,0,3,PRICE_CLOSE,i);
       
       
       // cci
      double cci_14 = iCCI(NULL,0,14,PRICE_TYPICAL,i);
      
      // bolinger bands
      double bolinger_10_down = iBands(NULL,0,10,2,0,PRICE_CLOSE,MODE_LOWER,i);
      double bolinger_10_upper = iBands(NULL,0,10,2,0,PRICE_CLOSE,MODE_UPPER,i);
             
      // MMANGLE: DETECT SIDEWISE
       double val_up = iCustom(NULL,0,"MAAngle",3,24,4,0.25,0,0,0,i);
       double val_down = iCustom(NULL,0,"MAAngle",3,24,4,0.25,0,0,1,i);
       double val_sidewise = iCustom(NULL,0,"MAAngle",3,24,4,0.25,0,0,2,i);

      double tendencia = 0;
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
      
       
      // tendencia EMA
      double trend_ema_5 =          (((iMA(NULL,0,5,0,MODE_SMA,PRICE_CLOSE,i) - iMA(NULL,0,5,0,MODE_SMA,PRICE_CLOSE,i + 1))
                                     + (iMA(NULL,0,5,0,MODE_SMA,PRICE_CLOSE,i + 1) - iMA(NULL,0,5,0,MODE_SMA,PRICE_CLOSE,i + 2))
                                     )*10000)/2;  
  
                                                                   
      double trend_ema_25 =         (((iMA(NULL,0,25,0,MODE_SMA,PRICE_CLOSE,i) - iMA(NULL,0,25,0,MODE_SMA,PRICE_CLOSE,i + 1))
                                     + (iMA(NULL,0,25,0,MODE_SMA,PRICE_CLOSE,i + 1) - iMA(NULL,0,25,0,MODE_SMA,PRICE_CLOSE,i + 2))
                                     )*10000)/2;                                
                                         
      double trend_ema_50 =         (((iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,i) - iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,i + 1))
                                     + (iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,i + 1) - iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,i + 2))
                                     )*10000)/2;                                      
         
       // tendencia rsi
       double trend_rsi_14 =        ((iRSI(NULL,0,14,PRICE_CLOSE,i) - iRSI(NULL,0,14,PRICE_CLOSE,i+1))
                                    + (iRSI(NULL,0,14,PRICE_CLOSE,i + 1) - iRSI(NULL,0,14,PRICE_CLOSE,i+2))
                                    )/2;
                                    
        // tendencia rsi 3
       double trend_rsi_3 =        ((iRSI(NULL,0,3,PRICE_CLOSE,i) - iRSI(NULL,0,3,PRICE_CLOSE,i+1))
                                    + (iRSI(NULL,0,3,PRICE_CLOSE,i + 1) - iRSI(NULL,0,3,PRICE_CLOSE,i+2))
                                    )/2;                            
                                    
      
       // tendencia stochastico
       double trend_stoch_5_5_3 =     ((iStochastic(NULL,0,5,5,3,MODE_SMA,1,MODE_MAIN,i) - iStochastic(NULL,0,5,5,3,MODE_SMA,1,MODE_MAIN,i+1)) 
                                       + (iStochastic(NULL,0,5,5,3,MODE_SMA,1,MODE_MAIN,i+1) - iStochastic(NULL,0,5,5,3,MODE_SMA,1,MODE_MAIN,i+2)) 
                                       )/2; 
     
     
      // tendencia CCI:
      double trend_cci_14 =         ((iCCI(NULL,0,14,PRICE_TYPICAL,i) - iCCI(NULL,0,14,PRICE_TYPICAL,i+1)) 
                                    + (iCCI(NULL,0,14,PRICE_TYPICAL,i+1) - iCCI(NULL,0,14,PRICE_TYPICAL,i+2)) 
                                    )/2; 

  
    FileWrite(handle, TimeToStr(Time[i], TIME_DATE) + " " + TimeToStr(Time[i], TIME_MINUTES),
                      Open[i], High[i], Low[i], Close[i], Volume[i],tendencia,ema_5,ema_25,
                      ema_50,stoch_5_5_3,stoch_signal_5_5_3,rsi_14,cci_14,trend_ema_5,trend_ema_25,trend_ema_50,trend_rsi_14,
                      trend_stoch_5_5_3,trend_cci_14,rsi_3,trend_rsi_3,bolinger_10_down,bolinger_10_upper);
  }

  FileClose(handle);

  
  return(0);
  }
//+------------------------------------------------------------------+
//| MathExpert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| MathExpert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+