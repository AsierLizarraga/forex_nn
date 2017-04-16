function [dataset,names,tsobj,output,cierre_suavizado] = create_technical_indicators(ts,inc_macd,inc_stochosc,inc_tsmovavg,inc_tsmom,inc_rsindex,inc_adline,inc_bollinger,inc_volroc,suavizado,valor_suavizado,horizonte,relativo)
%CREATE_TECHNICAL_INDICATORS Summary of this function goes here
%   Detailed explanation goes here
cierre_suavizado = [];
if suavizado == 1
    sma = tsmovavg(ts, 's',valor_suavizado);
    cierre_suavizado = fts2mat(sma.CIERRE);
end

indice = 1;
dataset = fts2mat(ts.ALTO,1);
names{indice} = 'ALTO';
indice = indice  + 1;

dataset = [dataset fts2mat(ts.BAJO)];
names{indice} = 'BAJO';
indice = indice  + 1;

dataset = [dataset fts2mat(ts.CIERRE)];
names{indice} = 'CIERRE';
indice = indice  + 1;

dataset = [dataset fts2mat(ts.APERTURA)];
names{indice} = 'APERTURA';
indice = indice  + 1;

dataset = [dataset fts2mat(ts.VOLUMEN)];
names{indice} = 'VOLUMEN';
indice = indice  + 1;


%% Indicadores de MACD
if inc_macd == 1
    
    CloseMACD = macd(ts,'CIERRE');
    dataset = [dataset fts2mat(CloseMACD.MACDLine)];
    names{indice} = 'CloseMACD';
    indice = indice  + 1;
    
   [m,n] = size(CloseMACD.MACDLine);
   macd_cierre= fts2mat(CloseMACD.MACDLine);
    for i=2:m
        diff_macd(i,1) =  macd_cierre(i,1)  - macd_cierre(i-1,1);
    end
    names{indice} = 'diff_macd';
    dataset = [dataset diff_macd];
    indice = indice  + 1;
    
end
%% Indicadores osciladores estocasticos
if inc_stochosc == 1
    
    stosc = stochosc(ts, 5, 3, 'e','HighName','ALTO','LowName','BAJO','CloseName','CIERRE');
    dataset = [dataset fts2mat(stosc.SOK)];
    dataset = [dataset fts2mat(stosc.SOD)];
    names{indice} = '%K_stockastic_5';
    indice = indice  + 1;
    names{indice} = '%D_stockastic_K_5_D_3';
    indice = indice  + 1;
    
    [m,n] = size(stosc);
    stock_k = fts2mat(stosc.SOK);
    stock_d = fts2mat(stosc.SOK);
    for i=2:m
        diff_stoch_k(i,1) =  stock_k(i,1)  - stock_k(i-1,1); 
        diff_stoch_d(i,1) =  stock_d(i,1)  - stock_d(i-1,1); 
    end
    
    names{indice} = '%Diff_K_stockastic_5';
    dataset = [dataset diff_stoch_k];
    indice = indice  + 1;
    
    names{indice} = '%Diff_D_stockastic_5';
    dataset = [dataset diff_stoch_d];
    indice = indice  + 1;
    
end

%% Indicadores de momentum

if inc_tsmom == 1
    
    momts = tsmom(ts,5);
    dataset = [dataset fts2mat(momts.CIERRE)];
    names{indice} = 'Momentum_cierre_5';
    indice = indice  + 1;
 
    momts = tsmom(ts,12);
    dataset = [dataset fts2mat(momts.CIERRE)];
    names{indice} = 'Momentum_cierre_12';
    indice = indice  + 1; 


end

%% Indicadores sma y ema

if inc_tsmovavg == 1
    
    sma3 = tsmovavg(ts, 's', 3);
    dataset = [dataset fts2mat(sma3.CIERRE)];
    names{indice} = 'sma_cierre_3';
    indice = indice  + 1;
    
    sma5 = tsmovavg(ts, 's', 5);
    dataset = [dataset fts2mat(sma5.CIERRE)];
    names{indice} = 'sma_cierre_5';
    indice = indice  + 1;
    
    sma25 = tsmovavg(ts, 's', 25);
    dataset = [dataset fts2mat(sma25.CIERRE)];
    names{indice} = 'sma_cierre_25';
    indice = indice  + 1;
    
    sma50 = tsmovavg(ts, 's', 50);
    dataset = [dataset fts2mat(sma50.CIERRE)];
    names{indice} = 'sma_cierre_50';
    indice = indice  + 1;
% 
%     [m,n] = size(sma3);
%     
%     sma50 = fts2mat(sma50.CIERRE);
%     sma25 = fts2mat(sma25.CIERRE);
%     sma5 = fts2mat(sma5.CIERRE);
%     sma3 = fts2mat(sma3.CIERRE);
%     
%     for i=2:m
%         diff_sma3(i,1) =  sma3(i,1)  - sma3(i-1,1); 
%         diff_sma5(i,1) =  sma5(i,1)  - sma5(i-1,1); 
%         diff_sma25(i,1) =  sma25(i,1)  - sma25(i-1,1); 
%         diff_sma50(i,1) =  sma50(i,1)  - sma50(i-1,1);  
%     end
%     
%     names{indice} = 'diff_sma3';
%     dataset = [dataset diff_sma3];
%     indice = indice  + 1;
%     
%     names{indice} = 'diff_sma5';
%     dataset = [dataset diff_sma5];
%     indice = indice  + 1;
%     
%     names{indice} = 'diff_sma25';
%     dataset = [dataset diff_sma25];
%     indice = indice  + 1;
%     
%     names{indice} = 'diff_sma50';
%     dataset = [dataset diff_sma50];
%     indice = indice  + 1;
    
end

%% ADLINE

if inc_adline == 1
    
    adlnts = adline(ts,'HighName','ALTO','LowName','BAJO','CloseName','CIERRE','VolumeName','VOLUMEN');
    dataset = [dataset fts2mat(adlnts.ADLine)];
    names{indice} = 'ADLine';
    indice = indice  + 1;
    
end

%% Volroc

if inc_volroc == 1
    
    vrocts = volroc(ts,5,'VolumeName','VOLUMEN');
    dataset = [dataset fts2mat(vrocts.VolumeROC)];
    names{indice} = 'vrc_5';
    indice = indice  + 1;
    
    vrocts = volroc(ts,12,'VolumeName','VOLUMEN');
    dataset = [dataset fts2mat(vrocts.VolumeROC)];
    names{indice} = 'vrc_12';
    indice = indice  + 1;
     
    
end

%%

if inc_rsindex == 1
    
   rsits3 = rsindex(ts,3,'CloseName','CIERRE');
   dataset = [dataset fts2mat(rsits3.RSI)];
   names{indice} = 'RSI_3';
   indice = indice  + 1;
   
   
   rsits5 = rsindex(ts,5,'CloseName','CIERRE');
   dataset = [dataset fts2mat(rsits5.RSI)];
   names{indice} = 'RSI_5';
   indice = indice  + 1;
   
   rsits14 = rsindex(ts,14,'CloseName','CIERRE');
   dataset = [dataset fts2mat(rsits14.RSI)];
   names{indice} = 'RSI_14';
   indice = indice  + 1;
   
   
   [m,n] = size(rsits3.RSI);
   rsi3 = fts2mat(rsits3.RSI);
   rsi5 = fts2mat(rsits5.RSI);
   rsi14 = fts2mat(rsits14.RSI);
   
    for i=2:m
        diff_rsi3(i,1) =  rsi3(i,1)  - rsi3(i-1,1);
        diff_rsi5(i,1) =  rsi5(i,1)  - rsi5(i-1,1);
        diff_rsi14(i,1) =  rsi14(i,1)  - rsi14(i-1,1);
    end
   
    names{indice} = 'diff_rsi3';
    dataset = [dataset diff_rsi3];
    indice = indice  + 1;
    
    names{indice} = 'diff_rsi5';
    dataset = [dataset diff_rsi5];
    indice = indice  + 1;
    
    names{indice} = 'diff_rsi14';
    dataset = [dataset diff_rsi14];
    indice = indice  + 1;
    

end

%% BOLINGER BANDS

if inc_bollinger == 1
    
   [midfts, upprfts, lowrfts] =  bollinger(ts,10,0,2);
   dataset = [dataset fts2mat(upprfts.CIERRE)];
   names{indice} = 'UP_BOLINGER_10';
   indice = indice  + 1;
   dataset = [dataset fts2mat(lowrfts.CIERRE)];
   names{indice} = 'LOW_BOLINGER_10';
   indice = indice  + 1;


end
% filter the 50 first observation = has nan 
dataset = dataset(51:end,:);
cierre_suavizado = cierre_suavizado(51:end,:);

% obtain the output variable
if suavizado == 0
    output = create_ouput(dataset(:,4),horizonte,relativo);
else
    output = create_ouput(cierre_suavizado,horizonte,relativo);
end

% filter the last record: dont have target
dataset = dataset(1:end - horizonte,:);
cierre_suavizado = cierre_suavizado(1:end - horizonte,:);
tsobj = fints(dataset);


end

