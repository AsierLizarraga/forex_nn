%% Parameters for Techinal indicators
inc_macd = 1;           % Moving Average Convergence/Divergence (MACD)
inc_stochosc = 1;       % Stochastic oscillator
inc_tsmovavg  = 1;      % simplean and exponential moving average
inc_tsmom = 0;          % Momentum between times
inc_rsindex = 1;        % Relative Strength Index (RSI)
inc_adline = 0;         % Accumulation/Distribution line
inc_bollinger = 1;      % Time series Bollinger band
inc_volroc  = 0;        % Volume rate of change

%% Files
file_historico = 'EURUSD5_historial.csv';
%% usar suavizado
suavizado = 1;
% 4  corto y 11 largo
valor_suavizado = 2;   
%% output
relativo = 0;
%% horizonte de prediccion
horizonte = 3;
%%
%Neural network parameters
% numero de capas ocultas
num_hiden_layers = 1;
% numero de neuronas minimo y maximo en cada capa
nun_min = 10;
nun_max = 20;
% paso
paso = 2;
%% intentos
int = 3;
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

% create the techical indicators
[dataset,names,tech,output,cierre_suavizado] = create_technical_indicators(ts,inc_macd,inc_stochosc,inc_tsmovavg,inc_tsmom,inc_rsindex,inc_adline,inc_bollinger,inc_volroc,suavizado,valor_suavizado,horizonte,relativo);
% obtain the input variables
var = select(dataset);
[p,ps] = mapminmax(var');
A(isnan(p)) = 0;


for i =1:nun_max
    perform(i) = 99999999999;
end

for i=nun_min:paso:nun_max
    
    for j=1:int
        net = feedforwardnet(i);
        net.trainParam.epochs = 2000;
        % trasfer function
        if num_hiden_layers == 1
            net.layers{1}.transferFcn = 'tansig';
            if relativo == 1
                net.layers{2}.transferFcn = 'tansig';
            else
                net.layers{2}.transferFcn = 'purelin';
            end
        else
            net.layers{1}.transferFcn = 'tansig';
            net.layers{2}.transferFcn = 'tansig';
            if relativo == 1
                net.layers{3}.transferFcn = 'tansig';
            else
                net.layers{3}.transferFcn = 'purelin';
            end
        end
        net = train(net,p,output);
        y = net(p);
        pe(j) = mse(output - y);
    end
    % train
    perform(i) = mean(pe);   
end

[B,IX] = sort(perform);
% 0.0002 = suavizado = 3, horizonte = 1, 0.009 suavizado 3 y horzonte = 3
% 0.001
num_neurons = IX(1);
% test with the last 200 values
test_input =  p(:,end-200:end);
test_output =  output(end-200:end);

net = feedforwardnet(num_neurons);
net.trainParam.epochs = 2000;
% trasfer function
if num_hiden_layers == 1
    net.layers{1}.transferFcn = 'tansig';
    net.layers{2}.transferFcn = 'tansig';
else
    net.layers{1}.transferFcn = 'tansig';
    net.layers{2}.transferFcn = 'tansig';
    net.layers{3}.transferFcn = 'tansig';
end
net = train(net,test_input,test_output);
y = net(test_input);
perform = mse(test_output - y);
%0,0003, 0.0024 horizonte = 3

if suavizado == 0
   [valor_original,valor_predicho] = draw_ressults(dataset(end-200:end,4),y,horizonte,relativo);
else
    [valor_original,valor_predicho] = draw_ressults(dataset(end-200:end,4),y,horizonte,relativo);
end

 figure();
 plot(valor_original,'blue');
 hold on
 plot(valor_predicho,'red');
 
 if suavizado == 1
     hold on
     plot(cierre_suavizado((end-200) + horizonte:end),'green');     
 end
 hold off

save('net_prediction_long', 'net');
save('valor_predicho_long', 'valor_predicho');
save('valor_original', 'valor_original');
 