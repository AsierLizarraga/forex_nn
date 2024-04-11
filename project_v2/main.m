
%Initial version of a trading tool based in genetic neural network.
% ACTUALIZACION
%% Parameter of the account
% broker
broker = 'xtb';
% initial deposit
initial_deposit = 5000;
% comision per lot
comision_vol = 0;
%% Parameters for the forex currency
% symbol
symbol = 'EURUSD';
% value of a lot
lot_value = 100000;
% minimun lot
min_lot = 0.1;
% pip decimal
pip = 0.0001;
% leverage 1:100
leverage = 0.01;
% period
period = '5min';
% spread
spread = 1.5;

%% Definition of train and test datasets

% Train period
train_ini = '14-Nov-2011 00:00';
train_fin = '15-Dec-2011 11:05';
train_str = strcat(train_ini,'::',train_fin);
 
% Test period
test_ini = '15-Dec-2011 11:10';
test_fin = '30-Dec-2011 22:00';
test_str = strcat(test_ini,'::',test_fin);

% tendecia: 0 all,1 up,2 down, 3 sidewise
tendencia = 3;
% 1 buy ,2 sell
mode = 1;
% min orders
num_min_orders_train = 50;
num_min_orders_test = 5;
% maximun time that is open a order
max_time = 0.5;
%% Genetic algorithm parameters
% max poulation
population_size = 500;
% prob crossover
prob_cross = 0.6;
descend_cross_over = 0;
% crossover method: one-point,two-point
cross_method = 'one-point';

%selection method: tournament,random
selection_method = 'tournament';
tournament_sample = 125;

% replace_method:Unconditional,Elitism
replace_method = 'Unconditional';
num_parents = 2;

% prob mutation
prob_mutation = 0.01;

% stop_algorithm: iterations
stop_algorithm = 'iterations';
max_iter = 100;

% fitness function: sharpe_ratio,stirlling_ratio,profit
fitness_function = 'profit_loss_sharpe_ratio_x_prof_rate';
%% Neural network parameters

% number of hidden layers of the neural network: 1 or 2
num_hiden_layers = 1;

% number of neuroms in the hidden layers
num_neurons_in_layers = [7];

% output neurons
out_neurom = 1;

%% Tranding strategy parameters
% strategy
strategy = 1;

%% Algorithm start

%% read data
 if strcmp(symbol,'EURUSD') &&  strcmp(period,'5min')
     [ts]  = import_data('C:\Users\Asier\Desktop\Asier\PROYECTO FOREX\project_v2\data\EURUSD5.csv');
     % names = {'APERTURA' 'ALTO' 'BAJO' 'CIERRE' 'VOLUMEN' 'tendencia' 'ema5' 'ema25' 'ema50' 'stoch553' 'stochsignal553' 'rsi14' 'cci14' 'trendema5' 'trendema25' 'trendema50' 'trendrsi14' 'trendstoch553' 'trendcci14'};
     names = {'APERTURA' 'ALTO' 'BAJO' 'CIERRE' 'VOLUMEN' 'tendencia' 'ema5' 'ema25' 'ema50' 'stoch553' 'stochsignal553' 'rsi14' 'cci14' 'rsi3' 'bol10down' 'bol10upper' 'macd12269'};
 end
 
 if strcmp(symbol,'EURUSD') &&  strcmp(period,'1min')
     [ts]  = import_data('C:\Users\Asier\Desktop\Asier\PROYECTO FOREX\project_v2\data\EURUSD1.csv');
     % names = {'APERTURA' 'ALTO' 'BAJO' 'CIERRE' 'VOLUMEN' 'tendencia' 'ema5' 'ema25' 'ema50' 'stoch553' 'stochsignal553' 'rsi14' 'cci14' 'trendema5' 'trendema25' 'trendema50' 'trendrsi14' 'trendstoch553' 'trendcci14'};
     names = {'APERTURA' 'ALTO' 'BAJO' 'CIERRE' 'VOLUMEN' 'tendencia' 'CloseMACD' 'KFastStochastic53' 'DFastStochastic53' 'KFastStochastic103' 'DFastStochastic103' 'EMA3' 'EMA5' 'EMA25' 'EMA50' 'RSI3' 'RSI5' 'RSI25' 'UPBOLINGER10' 'DOWNBOLINGER10'};
 end
 
 
% extract the train and test datasets
train =  ts(train_str);
test =  ts(test_str);
%% Create the data set of techichal indicators

% SET THE NUMBER OF INDICATORS
[n,m] = size(ts);
num_indicators = m - 6;
num_imputs = num_indicators;
% population inizialization
[population] = inicializacion(num_imputs,num_hiden_layers,num_neurons_in_layers,out_neurom,num_indicators,population_size);
dataset = fts2mat(train,1);
dataset_test = fts2mat(test,1);

% obtain the input variables selected
var = select(dataset);
var_test =  select(dataset_test);

% net inizialization
net = feedforwardnet(num_neurons_in_layers);

% trasfer function
if num_hiden_layers == 1
    
    net.layers{1}.transferFcn = 'tansig';
    net.layers{2}.transferFcn = 'tansig';
    
else
    net.layers{1}.transferFcn = 'tansig';
    net.layers{2}.transferFcn = 'tansig';
    net.layers{3}.transferFcn = 'tansig'; 
end

% fitness calculation
for i=1:population_size    
   
    % obtain the predictions of the model in train
    [chro,pred] = prediction(net,population(i),var);
    population(i) = chro;
    % obtain the fitnes for the predictions
    fit = fitnes(pred,dataset,train,initial_deposit,symbol,lot_value,min_lot,pip,leverage,fitness_function,spread,comision_vol,tendencia,num_min_orders_train,mode,max_time);
    
    % save all
    population_fitnes(i) = fit;
    population_measure(i) = fit.fit;

    
end
%Inizialize the iterations
iter = 1;
while (iter <= max_iter)
   
    %population_measure = ((population_measure.*number_train) + (population_measure_test.*number_test)) / (number_train + number_test);
    % creation of the offspring
    size_offspring = 0;
    while(size_offspring < population_size)  
        
        % selection
        [parent1,parent2] =  selection(selection_method,population,population_size,population_measure,tournament_sample);
        
        % crossover
        [child1,child2] = crossover(prob_cross,cross_method,parent1,parent2);
        % reduce the crossover probability
        if descend_cross_over == 1
            
            prob_cross = prob_cross - (prob_cross/max_iter);
            
        end
        
        % mutation
         [child1,child2] = mutation(prob_mutation,child1,child2);
        
         offspring(size_offspring + 1) = child1;
         offspring(size_offspring + 2) = child2;
         
        % add to new offspring
        size_offspring = size_offspring + 2;

    end
    
    % replacement strategy: elitism,undonditional
    [population] = replacement(replace_method,population,offspring,population_measure);

    % fitness calculation of the new population 
    for i=1:population_size  
        
        % obtain the predictions of the model in train
        [chro,pred] = prediction(net,population(i),var);
        population(i) = chro;
        % obtain the fitnes for the predictions
        fit = fitnes(pred,dataset,train,initial_deposit,symbol,lot_value,min_lot,pip,leverage,fitness_function,spread,comision_vol,tendencia,num_min_orders_train,mode,max_time);
        
        % save all
        population_fitnes(i) = fit;
        population_measure(i) = fit.fit;
        
    end
    
% obtain the best performance chromosome and the fitness
[B,IX] = sort(population_measure,'descend');
best(iter) = population(IX(1));

% obtain the predictions of the model in test
[pred_test] = prediction_test(population(IX(1)),var_test);
% obtain the fitnes for the predictions
fit_test = fitnes(pred_test,dataset_test,test,initial_deposit,symbol,lot_value,min_lot,pip,leverage,fitness_function,spread,comision_vol,tendencia,num_min_orders_test,mode,max_time);

best_fitness(iter) = population_fitnes(IX(1));
best_fitness_test(iter) = fit_test;
% save the number of orders and fitnes of each iteration
best_measure(iter) = population_measure(IX(1));
best_measure_test(iter) = fit_test.fit;

% save the population of chromosome AND FITNESS
save(strcat('populations\population_iter_',num2str(iter)),'population');
save(strcat('fitness\fitness_iter_',num2str(iter)),'population_fitnes');

% update the iterartion 
iter = iter  + 1;
    
end


%% save the best chromosome and fitness
save('profile\bests_models_train', 'best');
save('profile\bests_models_fitness_train', 'best_fitness');
save('profile\bests_models_fitness_test', 'best_fitness_test');

% save the evolution 
save('profile\best_measure_train_evo', 'best_measure');
save('profile\best_measure_test_evo', 'best_measure_test');

%% Profiles the best chromososme for each iteration

for i=1:max_iter
    chro = best(i);
    fit_train = best_fitness(i);
    fit_test = best_fitness_test(i);
        
    % profile the chromosome
    profile(chro,fit_train,fit_test,dataset,dataset_test,names,i,initial_deposit,'profile\profile_iter_');

end

% profile all last population
for i=1:population_size
    chro = population(i);
    fit_train = population_fitnes(i);
    
    % obtain the predictions of the model in test
    [pred_test] = prediction_test(chro,var_test);
    % obtain the fitnes for the predictions
    fit_test = fitnes(pred_test,dataset_test,test,initial_deposit,symbol,lot_value,min_lot,pip,leverage,fitness_function,spread,comision_vol,tendencia,num_min_orders_test,mode,max_time);
        
    % profile the chromosome
    profile(chro,fit_train,fit_test,dataset,dataset_test,names,i,initial_deposit,'profile_last_population\profile_number_');

end






