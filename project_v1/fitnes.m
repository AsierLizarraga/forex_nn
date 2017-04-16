classdef fitnes
    %FITNES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        orders
        profit_and_loss
        average_return
        sharpe_ratio
        stirlling_ratio
        num_orders
        fit
        profit_loss_sharpe_ratio
        profit_loss_stirlling_ratio
        average_profit
        
        profit_loss_sharpe_ratio_x_prof_rate
        profit_loss_stirlling__x_prof_rate
        profit_and_loss_x_prof_rate
        profit_rate
        
        acu_profits
        buy_signals
        sell_signals
        
        
    end
    
    methods
       
        function obj =  fitnes(pred,dataset,ts,initial_deposit,symbol,lot_value,min_lot,pip,leverage,fitness_function,spread,comision_vol)

   
            % call estrategy function: create a book the orders
            [ordenes,acu_profits,buy_signals,sell_signals] = estrategia1(pred,ts,dataset,initial_deposit,symbol,lot_value,min_lot,pip,leverage,spread,comision_vol);
            % obtain the orders
            obj.orders = ordenes;
            obj.acu_profits = acu_profits;
            obj.buy_signals = buy_signals;
            obj.sell_signals = sell_signals;
            
            [profit_and_loss,average_return,sharpe_ratio,num_orders,stirlling_ratio,profit_loss_sharpe_ratio,profit_loss_stirlling_ratio,average_profit,profit_loss_sharpe_ratio_x_prof_rate,profit_loss_stirlling__x_prof_rate,profit_and_loss_x_prof_rate,profit_rate] = financial_measures(ordenes,initial_deposit);
            %[profit_loss] = financial_measures(obj.orders);
            
            obj.profit_and_loss = profit_and_loss;
            obj.average_return = average_return;
            obj.sharpe_ratio = sharpe_ratio;
            obj.num_orders = num_orders;
            obj.stirlling_ratio = stirlling_ratio;
            obj.profit_loss_sharpe_ratio = profit_loss_sharpe_ratio;
            obj.profit_loss_stirlling_ratio = profit_loss_stirlling_ratio;
            obj.average_profit = average_profit;
            obj.profit_loss_sharpe_ratio_x_prof_rate = profit_loss_sharpe_ratio_x_prof_rate;
            obj.profit_loss_stirlling__x_prof_rate = profit_loss_stirlling__x_prof_rate;
            obj.profit_and_loss_x_prof_rate = profit_and_loss_x_prof_rate;
            obj.profit_rate = profit_rate;
            
            
            % set the fitness value: sharpe_ratio,stirlling_ratio,profit
            if strcmp(fitness_function,'sharpe_ratio')
                
                obj.fit =  obj.sharpe_ratio;
                
            elseif strcmp(fitness_function,'stirlling_ratio')
                
                obj.fit =  obj.stirlling_ratio;
                
            elseif strcmp(fitness_function,'profit')
                
                obj.fit =  obj.profit_and_loss;
                
            elseif strcmp(fitness_function,'average_return')
                
                obj.fit =  obj.average_return;
                
                
             elseif strcmp(fitness_function,'profit_loss_sharpe_ratio')
                
                obj.fit =  obj.profit_loss_sharpe_ratio;
                
                
             elseif strcmp(fitness_function,'profit_loss_stirlling_ratio')
                
                obj.fit =  obj.profit_loss_stirlling_ratio;  
                
                
            elseif strcmp(fitness_function,'profit_loss_sharpe_ratio_x_prof_rate')
                
                obj.fit =  obj.profit_loss_sharpe_ratio_x_prof_rate;
                   
            elseif strcmp(fitness_function,'profit_loss_stirlling_x_prof_rate')
                
                obj.fit =  obj.profit_loss_stirlling__x_prof_rate;
    
            elseif strcmp(fitness_function,'profit_and_loss_x_prof_rate')
                
                obj.fit =  obj.profit_and_loss_x_prof_rate;
                
                
            end
            
            
        end

    end
    
end


function [profit_and_loss,average_return,sharpe_ratio,num_orders,stirlling_ratio,profit_loss_sharpe_ratio,profit_loss_stirlling_ratio,average_profit,profit_loss_sharpe_ratio_x_prof_rate,profit_loss_stirlling__x_prof_rate,profit_and_loss__x_prof_rate,profit_rate] = financial_measures(orders,initial_deposit)

n = length(orders);

% no ha habido ordenes
if n == 1 && orders(1).id == -1
    
    sharpe_ratio = -1;
    stirlling_ratio = -1;
    num_orders = -1;
    profit_and_loss = -99999999;
    average_return = -1;
    profit_loss_sharpe_ratio = -99999999;
    profit_loss_stirlling_ratio = -99999999;
    average_profit = -99999999;
    profit_rate = 0; 
    profit_loss_sharpe_ratio_x_prof_rate = -99999999;
    profit_loss_stirlling__x_prof_rate = -99999999;
    profit_and_loss__x_prof_rate = 0;
    
else
    
    num_orders = n;
    acumu_profits(1) = initial_deposit;
    acumu_returns(1) = 1;
    
    for i=1:n  
        profits(i) = orders(i).profit;
        returs(i) =  orders(i).return_order;
        acumu_profits(i + 1) = acumu_profits(i) + orders(i).profit;
        acumu_returns(i + 1) = acumu_returns(i) + orders(i).return_order;
        
    end
    
    profit_and_loss = initial_deposit + sum(profits);
    average_return = mean(returs);
    average_profit = mean(profits);
    
    % profit rate
    
    profits_orders = find(profits > 0);
    profit_rate = length(profits_orders)/n;
    profit_and_loss__x_prof_rate = profit_and_loss * profit_rate;
   
    if n <= 25
        
        sharpe_ratio = 0;
        stirlling_ratio = 0;
        profit_loss_sharpe_ratio = 0;
        profit_loss_stirlling_ratio = 0;
        profit_loss_sharpe_ratio_x_prof_rate = profit_loss_sharpe_ratio * profit_rate;
        profit_loss_stirlling__x_prof_rate = profit_loss_stirlling_ratio * profit_rate;
        
    else
        
        sharpe_ratio = average_return/std(returs);
        profit_loss_sharpe_ratio = average_profit/std(profits);
        profit_loss_sharpe_ratio_x_prof_rate = profit_loss_sharpe_ratio * profit_rate;
        
        if negativos(acumu_profits) == 1
            profit_loss_stirlling_ratio = -1;
            profit_loss_stirlling__x_prof_rate = - 1;
        end
        
        if negativos(acumu_profits) == 0
            draw_down = maxdrawdown(acumu_profits);
            profit_loss_stirlling_ratio = average_profit/(draw_down + + 0.1); 
            profit_loss_stirlling__x_prof_rate = profit_loss_stirlling_ratio * profit_rate;
        end
        
        if negativos(acumu_returns) == 1 
            stirlling_ratio = -1; 
        end
         
        if  negativos(acumu_returns) == 0
            draw_down = maxdrawdown(acumu_returns);
            stirlling_ratio = average_return/(draw_down + + 0.1);
            
        end
        
    end
    
end

end

function [neg] = negativos(data)

n = length(data);
neg = 0;

for i=1:n
    
    if data(i) <= 0
        neg = 1;
        break;
    end
end

end

function [orders,acu_profits,buy_signals,sell_signals] = estrategia1(pred,ts,dataset,initial_deposit,symbol,lot_value,min_lot,pip,leverage,spread,comision_vol)

[m,n] = size(pred);
% create a initial order
% create de order
or = order(-1,datestr(dataset(2,1)),'buy',1,symbol,dataset(1,4),-1,'entry buy low');
orders(1) = or;

% Acumulative profits
acu_profits = zeros(1,n);
acu_profits(1) = initial_deposit;

%buy signals
buy_signals = zeros(1,n);

%sell signals
sell_signals = zeros(1,n);

entrado = 0;

%id order
id = 1;
id_insert = 1;

% flags for entry buy rules and entry sell rules
entry_buy = 0;
entry_sell = 0;

% volumen of sell and buy orders
vol_buy = 0;
vol_sell = 0;


buy_order = -1;
sell_order = -1;

free_margin = initial_deposit;

% for each bar
for i=1:n-1
   
    hora = hour(dataset(i+1,1));
   
     % entry buy low
    if (pred(1,i) >= 0 && pred(1,i) < 0.15) && entry_buy == 0 && (hora >= 7 && hora <= 18)
             
        % update de volumen buy
        aux_vol_buy = vol_buy + 1;
        
        % calcualte the margin
        if aux_vol_buy > vol_sell
            
            % calculate the margin
            margin = (lot_value * (aux_vol_buy - vol_sell) * leverage);
            aux_free_margin = free_margin - margin;
            
            % if have margin
            if aux_free_margin > 0;
                
                % update the deposit and the volumen buy
                vol_buy = vol_buy + 1;
                free_margin = free_margin - margin;
                
                % create de order
                or = order(id,datestr(dataset(i+1,1)),'buy',1,symbol,dataset(i,4),-1,'entry buy low');
                % set to 1 the flag for indicate that a buy order is done
                entry_buy = 1;
                buy_order = or;
                id = id + 1;
                buy_signals(i+1) = or.volumen;
                entrado = 1;
            end
            
        else
            
            % update the deposit and the volumen buy
            vol_buy = vol_buy + 1;
            
            % create de order
            or = order(id,datestr(dataset(i+1,1)),'buy',1,symbol,dataset(i,4),-1,'entry buy low');
            
            % set to 1 the flag for indicate that a buy order is done
            entry_buy = 1;
            buy_order = or;
            id = id + 1;
            buy_signals(i+1) = or.volumen;
            entrado = 1;

        end
        
    end
    
    
    % entry buy medium
    if (pred(1,i) >= 0.15 && pred(1,i) < 0.3) && entry_buy == 0 && (hora >= 7 && hora <= 18)
        
        % update de volumen buy
        aux_vol_buy = vol_buy + 2;
        
        % calcualte the margin
        if aux_vol_buy > vol_sell
            
            % calculate the margin
            margin = (lot_value * (aux_vol_buy - vol_sell) * leverage);
            aux_free_margin = free_margin - margin;
            
            % if have margin
            if aux_free_margin > 0;
                
                % update the deposit and the volumen buy
                vol_buy = vol_buy + 2;
                free_margin = free_margin - margin;
                
                % create de order
                or = order(id,datestr(dataset(i+1,1)),'buy',2,symbol,dataset(i,4),-1,'entry buy medium');
                
                % set to 1 the flag for indicate that a buy order is done
                entry_buy = 1;
                buy_order = or;
                id = id + 1;
                buy_signals(i+1) = or.volumen;
                entrado = 1;
      
                
            end
            
        else
            
            % update the deposit and the volumen buy 
            vol_buy = vol_buy + 2;
            
            % create de order
            or = order(id,datestr(dataset(i+1,1)),'buy',2,symbol,dataset(i,4),-1,'entry buy medium');
            
            
            % set to 1 the flag for indicate that a buy order is done
            entry_buy = 1;
            buy_order = or;
            id = id + 1;
            buy_signals(i+1) = or.volumen;
            entrado = 1;
   
            
        end
    end
    
    
    % entry buy high
    if (pred(1,i) >= 0.3 && pred(1,i) < 0.45) && entry_buy == 0 && (hora >= 7 && hora <= 18)
   
         % update de volumen buy
        aux_vol_buy = vol_buy + 3;
        
        % calcualte the margin
        if aux_vol_buy > vol_sell
            
            % calculate the margin
            margin = (lot_value * (aux_vol_buy - vol_sell) * leverage);
            aux_free_margin = free_margin - margin;
            
            % if have margin
            if aux_free_margin > 0;
                
                % update the deposit and the volumen buy
                vol_buy = vol_buy + 3;
                free_margin = free_margin - margin;
                
                % create de order
                or = order(id,datestr(dataset(i+1,1)),'buy',3,symbol,dataset(i,4),-1,'entry buy high');
                
                % set to 1 the flag for indicate that a buy order is done
                entry_buy = 1;
                buy_order = or;
                
                id = id + 1;
                
                buy_signals(i+1) = or.volumen;
                entrado = 1;
                
            end
            
        else
            
            % update the deposit and the volumen buy
            vol_buy = vol_buy + 3;
            
            % create de order
             or = order(id,datestr(dataset(i+1,1)),'buy',3,symbol,dataset(i,4),-1,'entry buy high');

            % set to 1 the flag for indicate that a buy order is done
            entry_buy = 1;
            buy_order = or;
            id = id + 1;
            buy_signals(i+1) = or.volumen;
            entrado = 1;

        end
        
    end
    
    
    % entry sell low
    if (pred(1,i) >= 0.6 && pred(1,i) < 0.75) && entry_sell == 0 && (hora >= 7 && hora <= 18)
        
        % update de volumen sell
        aux_vol_sell = vol_sell + 1;
        
        % calcualte the margin
        if aux_vol_sell  > vol_buy
            
            % calculate the margin
            margin = (lot_value * (aux_vol_sell - vol_buy) * leverage);
            aux_free_margin = free_margin - margin;
            
            % if have margin
            if aux_free_margin > 0;
                
                % update the deposit and the volumen sell
                vol_sell = vol_sell + 1;
                free_margin = free_margin - margin;
                
                % create de order
                or = order(id,datestr(dataset(i+1,1)),'sell',1,symbol,dataset(i,4),-1,'entry sell low');
                
                % set to 1 the flag for indicate that a sell order is done
                entry_sell = 1;
                sell_order = or;
                id = id + 1;
                sell_signals(i+1) = or.volumen;
                entrado = 1;
            end
            
        else
            
            % update the deposit and the volumen sell
            vol_sell = vol_sell + 1;
            
            % create de order
            or = order(id,datestr(dataset(i+1,1)),'sell',1,symbol,dataset(i,4),-1,'entry sell low');
            
            % set to 1 the flag for indicate that a sell order is done
            entry_sell = 1;
            sell_order = or;
            id = id + 1;
            sell_signals(i+1) = or.volumen;
            entrado = 1;
            
        end
    end
    
    
    
    % entry sell medium
    if (pred(1,i) >= 0.75 && pred(1,i) < 0.9) && entry_sell == 0 && (hora >= 7 && hora <= 18)
        
        % update de volumen sell
        aux_vol_sell = vol_sell + 2;
        
        % calcualte the margin
        if aux_vol_sell  > vol_buy
            
            % calculate the margin
            margin = (lot_value * (aux_vol_sell - vol_buy) * leverage);
            aux_free_margin = free_margin - margin;
            
            % if have margin
            if aux_free_margin > 0;
                
                % update the deposit and the volumen sell
                vol_sell = vol_sell + 2;
                free_margin = free_margin - margin;
                
                % create de order
                or = order(id,datestr(dataset(i+1,1)),'sell',2,symbol,dataset(i,4),-1,'entry sell medium');
              
                
                % set to 1 the flag for indicate that a sell order is done
                entry_sell = 1;
                sell_order = or;
                id = id + 1;
                sell_signals(i+1) = or.volumen;
                entrado = 1;
                
                
            end
            
        else
            
            % update the deposit and the volumen sell
            vol_sell = vol_sell + 2;
            
            % create de order
            or =  order(id,datestr(dataset(i+1,1)),'sell',2,symbol,dataset(i,4),-1,'entry sell medium');
            
            
            % set to 1 the flag for indicate that a sell order is done
            entry_sell = 1;
            sell_order = or;
            id = id + 1;
            sell_signals(i+1) = or.volumen;
            entrado = 1;
            
            
        end
        
    end
    
    
    % entry sell high
    if (pred(1,i) > 0.9) && entry_sell == 0 && (hora >= 7 && hora <= 18)
        
        % update de volumen sell
        aux_vol_sell = vol_sell + 3;
        
        % calcualte the margin
        if aux_vol_sell  > vol_buy
            
            % calculate the margin
            margin = (lot_value * (aux_vol_sell - vol_buy) * leverage);
            aux_free_margin = free_margin - margin;
            
            % if have margin
            if aux_free_margin > 0;
                
                % update the deposit and the volumen sell
                vol_sell = vol_sell + 3;
                free_margin = free_margin - margin;
                
                % create de order
                or = order(id,datestr(dataset(i+1,1)),'sell',3,symbol,dataset(i,4),-1,'entry sell high');
                
                
                % set to 1 the flag for indicate that a sell order is done
                entry_sell = 1;
                sell_order = or;
                id = id + 1;
                sell_signals(i+1) = or.volumen;
                entrado = 1;

            end
            
        else
            
            % update the deposit and the volumen sell
            vol_sell = vol_sell + 3;
            
            % create de order
            or = order(id,datestr(dataset(i+1,1)),'sell',3,symbol,dataset(i,4),-1,'entry sell high');
            
            % set to 1 the flag for indicate that a sell order is done
            entry_sell = 1;
            sell_order = or;
            id = id + 1;
            sell_signals(i+1) = or.volumen;
            entrado = 1;

        end
        
    end
    
    % exit buy
    if (pred(1,i) >= 0.6  && entry_buy == 1) || ( entry_buy == 1 && i == n - 1)
        
        or = buy_order;
        entry_buy = 0;
        
        % put the tiem and tehe exit price
        or.exit_dates = datestr(dataset(i+1,1));
      
        or.exit_price = dataset(i,4);
        
        % calculate the pip value
        pip_value = ((lot_value * or.volumen * pip) / or.price);
        
        % obtein the profit
        or.dif_puntos = round(((or.exit_price - or.price) / pip)*10)/10;
        or.profit = (or.dif_puntos - spread)*pip_value  - (or.volumen * comision_vol) ;
        
        or.return_order =(or.exit_price - or.price)/or.price;
        acu_profits(i+1) =  or.profit;
        
        initial_deposit =  initial_deposit + or.profit;
        
        dif = max(vol_sell,vol_buy) - max(vol_sell,vol_buy - or.volumen);
        vol_buy = vol_buy - or.volumen;
        free_margin = free_margin + (dif * lot_value * leverage);
        free_margin = free_margin + or.profit;
        orders(id_insert) = or;
        id_insert = id_insert + 1;
        buy_signals(i+1) = 0;
        entrado = 1;
        
    end
    
    
    % exit sell
    if pred(1,i) < 0.45  && entry_sell == 1 || ( entry_sell == 1 && i == n - 1)
        
        or = sell_order;
        entry_sell = 0;
        
        % put the tiem and tehe exit price
        or.exit_dates = datestr(dataset(i+1,1));
       
        or.exit_price = dataset(i,4);
        
        % calculate the pip value
        pip_value = ((lot_value * or.volumen * pip) / or.price);
        
        % obtein the profit
        or.dif_puntos = round(((or.price - or.exit_price) / pip)*10)/10;
        or.profit = (or.dif_puntos - spread) * pip_value - (or.volumen * comision_vol);
        or.return_order =(or.price - or.exit_price)/or.exit_price;
        acu_profits(i+1) =  or.profit;
        
        initial_deposit =  initial_deposit + or.profit;
        
        dif = max(vol_sell,vol_buy) - max(vol_buy,vol_sell - or.volumen);
        vol_sell = vol_sell - or.volumen;
        free_margin = free_margin + (dif * lot_value * leverage);
        free_margin = free_margin + or.profit;
        orders(id_insert) = or;
        id_insert = id_insert + 1;
        
         sell_signals(i+1) = 0;
         entrado = 1;
        
    end
    
    if entrado == 0
        
         sell_signals(i+1) =  sell_signals(i);
         buy_signals(i+1) =  buy_signals(i);
         
        
    end
    
    entrado = 0;
    
    
    
end


acu_profits = cumsum(acu_profits);



end








