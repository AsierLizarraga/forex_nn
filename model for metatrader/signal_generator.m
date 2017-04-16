
%% Parameters for Techinal indicators

inc_macd = 1;           % Moving Average Convergence/Divergence (MACD)
inc_stochosc = 1;       % Stochastic oscillator
inc_tsmovavg  = 1;      % simplean and exponential moving average
inc_tsmom = 0;          % Momentum between times
inc_rsindex = 1;        % Relative Strength Index (RSI)
inc_adline = 0;         % Accumulation/Distribution line
inc_bollinger = 1;      % Time series Bollinger band
inc_volroc  = 0;        % Volume rate of change

%% Inizialization
inizialization = 0;
b = 0;
time_stop = 4;
%% Model

model = 'cro_11';
chro = load(model);
chro = chro.cro11;
% create the net
net2 = chro.phenotype;

%% Files 
file_inicilization = 'C:\Users\Asier\AppData\Local\VirtualStore\Program Files (x86)\MetaTrader FLOAT\tester\files\EURUSD_inizialization.csv';
file_bars =  'C:\Users\Asier\AppData\Local\VirtualStore\Program Files (x86)\MetaTrader FLOAT\tester\files\EURUSD_bar.csv';
file_pred =  'C:\Users\Asier\AppData\Local\VirtualStore\Program Files (x86)\MetaTrader FLOAT\tester\files\EURUSD_prediction.csv';
file_pred2 =  'C:\Users\Asier\AppData\Local\VirtualStore\Program Files (x86)\MetaTrader FLOAT\tester\files\EURUSD_prediction2.csv';


%% Read data inizialization for metatrader
disp('Inicializacion de la estrategia EURUSD');
while inizialization == 0
    
    filename = file_inicilization;
    delimiter = ';';
    startRow = 2;
    formatSpec = '%s%f%f%f%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    
    if fileID >= 3
        
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
        fclose(fileID);
        FECHA = dataArray{:, 1};
        APERTURA = dataArray{:, 2};
        ALTO = dataArray{:, 3};
        BAJO = dataArray{:, 4};
        CIERRE = dataArray{:, 5};
        VOLUMEN = dataArray{:, 6};
        data = [APERTURA ALTO BAJO CIERRE VOLUMEN];
        
        [m,n] = size(FECHA);
        % trasform the date formats
        for i=1:m
            s = char(FECHA(i,1));
            [ano remain] = strtok(s,'.');
            [mes remain]= strtok(remain,'.');
            [token_dia hora]= strtok(remain);
            [dia]= strtok(token_dia,'.');
            fech{i,1} = strcat(ano,'-',mes,'-',dia,' ',hora);
        end
        
        % create the finanacial time series
        ts = fints(fech,data,{'APERTURA' 'ALTO' 'BAJO' 'CIERRE' 'VOLUMEN'});
        inizialization = 1;
    
    end
end
   
% read the bar data for metatrader

filename = file_bars;
delimiter = ';';
endRow = 1;
formatSpec = '%s%f%f%f%f%f%[^\n\r]';
    
while(b == 0)
 
    fileID = fopen(filename,'r');
   
    if fileID >= 3
        
        pause(0.01);
        
        % read the var
        dataArray = textscan(fileID, formatSpec, endRow, 'Delimiter', delimiter, 'ReturnOnError', false);
        fclose(fileID);
        FECHA_BAR = dataArray{:, 1};
        APERTURA_BAR = dataArray{:, 2};
        ALTO_BAR = dataArray{:, 3};
        BAJO_BAR = dataArray{:, 4};
        CIERRE_BAR = dataArray{:, 5};
        VOLUMEN_BAR = dataArray{:, 6};
        data_BAR = [APERTURA_BAR ALTO_BAR BAJO_BAR CIERRE_BAR VOLUMEN_BAR];
       
        
        % trasform the date
        s = char(FECHA_BAR(1,1));
        [ano remain] = strtok(s,'.');
        [mes remain]= strtok(remain,'.');
        [token_dia hora]= strtok(remain);
        [dia]= strtok(token_dia,'.');
        
        % create the bar
        fech_bar{1,1} = strcat(ano,'-',mes,'-',dia,' ',hora);
        bar = fints(fech_bar,data_BAR,{'APERTURA' 'ALTO' 'BAJO' 'CIERRE' 'VOLUMEN'});

        % add to the historic    
        ts = [ts;bar];
        % create the techical indicators
        [dataset,names,tech] = create_technical_indicators(ts,inc_macd,inc_stochosc,inc_tsmovavg,inc_tsmom,inc_rsindex,inc_adline,inc_bollinger,inc_volroc);

        % obtain the input variables selected FOR TEST
        var = select(dataset);
        
        % NORMALIZE WITH THE TRAIN PARAMETERS
        p = mapminmax('apply',var',chro.norm_params);
        
        % obtein the prediction of the neural network
        A(isnan(p)) = 0;
        %             disp('muestro el data set');
        %             disp(p);
        pred = sim(net2,p);
        
        % save the prediction
        dlmwrite(file_pred,pred);
        dlmwrite(file_pred2,pred);
        % update ts
        ts = ts(2:end);
        
        % delete the bar file 
        delete(filename);
        % pause
        pause(time_stop);
        % delete
        delete(file_pred);
        
    end
 
end

