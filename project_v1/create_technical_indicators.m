function [dataset,names,tsobj] = create_technical_indicators(ts,inc_macd,inc_stochosc,inc_tsmovavg,inc_tsmom,inc_rsindex,inc_adline,inc_bollinger,inc_volroc)
%CREATE_TECHNICAL_INDICATORS Summary of this function goes here
%   Detailed explanation goes here

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
    
    stosc = stochosc(ts, 10, 3, 'e','HighName','ALTO','LowName','BAJO','CloseName','CIERRE');
    dataset = [dataset fts2mat(stosc.SOK)];
    dataset = [dataset fts2mat(stosc.SOD)];
    names{indice} = '%K_stockastic_10';
    indice = indice  + 1;
    names{indice} = '%D_stockastic_K_10_D_3';
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
    
    sma = tsmovavg(ts, 's', 3);
    dataset = [dataset fts2mat(sma.CIERRE)];
    names{indice} = 'sma_cierre_3';
    indice = indice  + 1;
    
    sma = tsmovavg(ts, 's', 5);
    dataset = [dataset fts2mat(sma.CIERRE)];
    names{indice} = 'sma_cierre_5';
    indice = indice  + 1;
    
    sma = tsmovavg(ts, 's', 25);
    dataset = [dataset fts2mat(sma.CIERRE)];
    names{indice} = 'sma_cierre_25';
    indice = indice  + 1;
    
    sma = tsmovavg(ts, 's', 50);
    dataset = [dataset fts2mat(sma.CIERRE)];
    names{indice} = 'sma_cierre_50';
    indice = indice  + 1;

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
    
   rsits = rsindex(ts,3,'CloseName','CIERRE');
   dataset = [dataset fts2mat(rsits.RSI)];
   names{indice} = 'RSI_3';
   indice = indice  + 1;
   
   rsits = rsindex(ts,5,'CloseName','CIERRE');
   dataset = [dataset fts2mat(rsits.RSI)];
   names{indice} = 'RSI_5';
   indice = indice  + 1;
    
   rsits = rsindex(ts,25,'CloseName','CIERRE');
   dataset = [dataset fts2mat(rsits.RSI)];
   names{indice} = 'RSI_25';
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
tsobj = fints(dataset);


end

