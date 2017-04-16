
%% Files
file_historico = 'EURUSD5_historial.csv';
%% output
suavizado = 1;
% 4  corto y 11 largo
valor_suavizado = 3;   
%% horizonte de prediccion
horizonte = 500;
%% number of training records
num_train = 4000;
%% arima param
max_p = 5;
max_q = 5;
max_d = 5;

%% Read data
disp('Inicio del entrenamiento');

filename = file_historico;
delimiter = ';';
startRow = 2;
formatSpec = '%s%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');

% read the historicla data
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
    
end

% crete the time series to predict

if suavizado == 1
    if suavizado == 1
        sma = tsmovavg(ts, 's',valor_suavizado);
        ts = sma.CIERRE;
    end
end

ts_train = fts2mat(ts(1:num_train));

for p=1:max_p
    for d=0:max_d
        for q=1:max_q
            Model = arima(p,d,q);
            ModelFit = estimate(Model,ts_train);
            [Y,YMSE] = forecast(ModelFit,horizonte,'Y0',ts_train);
            error(p,d + 1,q) = sum(YMSE);  
        end
    end
end
    
    
min_error = 99999999;

for p=1:max_p
    for d=0:max_d
        for q=1:max_q
           
            if(error(p,d + 1,q)  )  
                
                
                
            end
        end
    end
end






% 
% lower = Y - 1.96*sqrt(YMSE);
% upper = Y + 1.96*sqrt(YMSE);
% 
% figure(1)
% plot(nasdaq,'Color',[.7,.7,.7]);
% hold on
% h1 = plot(1501:2000,lower,'r:','LineWidth',2);
% plot(1501:2000,upper,'r:','LineWidth',2)
% h2 = plot(1501:2000,Y,'k','LineWidth',2);
% legend([h1 h2],'95% Interval','Forecast',...
%     'Location','NorthWest')
% 
% title('NASDAQ Composite Index Forecast')
% hold off











load Data_EquityIdx
nasdaq = Dataset.NASDAQ(1:1500);









