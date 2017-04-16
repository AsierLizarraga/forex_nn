
%Initial version of a trading tool based in genetic neural network.

%% Parameter of the account

% broker
broker = 'xtb';
% initial deposit
initial_deposit = 10000;
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
spread = 5;

%% Definition of train and test datasets

%Train period
train_ini = '01-Mar-2011 14:50';
train_fin = '14-Oct-2011 23:00';
train_str = strcat(train_ini,'::',train_fin);

% Test period
test_ini = '17-Oct-2011 00:00';
test_fin = '30-Dec-2011 23:00';
test_str = strcat(test_ini,'::',test_fin);

% Train period
% train_ini = '14-Nov-2011 03:20';
% train_fin = '23-Nov-2011 09:04';
% train_str = strcat(train_ini,'::',train_fin);
%  
% % Test period
% test_ini = '23-Nov-2011 09:05';
% test_fin = '12-Dec-2011 09:02';
% test_str = strcat(test_ini,'::',test_fin);

%% Genetic algorithm parameters
% max poulation
population_size = 250;

% prob crossover
prob_cross = 0.8;
descend_cross_over = 0;
% crossover method: one-point,two-point
cross_method = 'one-point';

%selection method: tournament,random
selection_method = 'tournament';
tournament_sample = 75;

% replace_method:Unconditional,Elitism
replace_method = 'Elitism';
num_parents = 2;

% prob mutation
prob_mutation = 0.01;

% stop_algorithm: iterations
stop_algorithm = 'iterations';
max_iter = 200;

% fitness function: sharpe_ratio,stirlling_ratio,profit
fitness_function = 'profit_loss_stirlling_ratio';

%% Neural network parameters

% number of hidden layers of the neural network: 1 or 2
num_hiden_layers = 1;

% number of neuroms in the hidden layers
num_neurons_in_layers = [14];

% output neurons
out_neurom = 1;

%% Tranding strategy parameters
% strategy
strategy = 1;

%% Parameters for Techinal indicators

inc_macd = 1;           % Moving Average Convergence/Divergence (MACD)
inc_stochosc = 1;       % Stochastic oscillator
inc_tsmovavg  = 1;      % simplean and exponential moving average
inc_tsmom = 0;          % Momentum between times
inc_rsindex = 1;        % Relative Strength Index (RSI)
inc_adline = 1;         % Accumulation/Distribution line
inc_bollinger = 1;      % Time series Bollinger band
inc_volroc  = 0;        % Volume rate of change


%% Algorithm start

%% read data
if strcmp(symbol,'EURUSD') &&  strcmp(period,'5min')
    [ts]  = import_data('C:\Users\Asier\Desktop\Asier\PROYECTO FOREX\project_v1\data\EURUSD5.csv');
end

if strcmp(symbol,'EURUSD') &&  strcmp(period,'1min')
    [ts]  = import_data_ini('C:\Users\Asier\Desktop\Asier\PROYECTO FOREX\project_v1\data\EURUSD1.csv');
end

if strcmp(symbol,'EURUSD') &&  strcmp(period,'15min')
    [ts]  = import_data_ini('C:\Users\Asier\Desktop\Asier\PROYECTO FOREX\project_v1\data\EURUSD15.csv');
end


% extract the train and test datasets
train =  ts(train_str);
test =  ts(test_str);

%% Create the data set of techichal indicators
[dataset,names,tech] = create_technical_indicators(train,inc_macd,inc_stochosc,inc_tsmovavg,inc_tsmom,inc_rsindex,inc_adline,inc_bollinger,inc_volroc);
% crete test technical indicators
[dataset_test,names,test_fts] = create_technical_indicators(test,inc_macd,inc_stochosc,inc_tsmovavg,inc_tsmom,inc_rsindex,inc_adline,inc_bollinger,inc_volroc);

% SET THE NUMBER OF INDICATORS
[n,m] = size(dataset);
num_indicators = m - 6;
num_imputs = num_indicators;

% population inizialization
[population] = inicializacion(num_imputs,num_hiden_layers,num_neurons_in_layers,out_neurom,num_indicators,population_size);

% net inizialization
net = feedforwardnet(num_neurons_in_layers);

% fitness calculation
for i=1:population_size    
   
    % obtain the predictions of the model in train
    [chro,pred] = prediction(net,population(i),dataset);
    population(i) = chro;
    % obtain the fitnes for the predictions
    fit = fitnes(pred,dataset,tech,initial_deposit,symbol,lot_value,min_lot,pip,leverage,fitness_function,spread,comision_vol);
    
    % save all
    population_fitnes(i) = fit;
    population_measure(i) = fit.fit;
    

end
%Inizialize the iterations
iter = 1;

while (iter <= max_iter)
   
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
        [chro,pred] = prediction(net,population(i),dataset);
        population(i) = chro;
        % obtain the fitnes for the predictions in train
        fit = fitnes(pred,dataset,tech,initial_deposit,symbol,lot_value,min_lot,pip,leverage,fitness_function,spread,comision_vol);
        
        population_fitnes(i) = fit;
        population_measure(i) = fit.fit;

    end
    

% obtain the best performance chromosome and the fitness
[B,IX] = sort(population_measure,'descend');
best(iter) = population(IX(1));
best_fitness(iter) = population_fitnes(IX(1));

% obtain the predictions of the model in test
[pred_test] = prediction_test(net,population(IX(1)),dataset_test);
% obtain the fitnes for the predictions
fit_test = fitnes(pred_test,dataset_test,test_fts,initial_deposit,symbol,lot_value,min_lot,pip,leverage,fitness_function,spread,comision_vol);

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
    [pred_test] = prediction_test(net,chro,dataset_test);
    % obtain the fitnes for the predictions
    fit_test = fitnes(pred_test,dataset_test,test_fts,initial_deposit,symbol,lot_value,min_lot,pip,leverage,fitness_function,spread,comision_vol);
        
    % profile the chromosome
    profile(chro,fit_train,fit_test,dataset,dataset_test,names,i,initial_deposit,'profile_last_population\profile_number_');

end







