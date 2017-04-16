function profile(chro,fit_train,fit_test,dataset,dataset_test,names,iter,initial_deposit,direct)


%% 
%inputs variables
 
 name_file = strcat(direct,num2str(iter),'.xls');
 % write in a excell
xlswrite(name_file,names,'INPUT_VARIABLES','A1');
 

 %% 
% obtain the orders
 order_train = fit_train.orders;
 order_test = fit_test.orders;
 
% generate a matrix with the order information
 num = length(order_train);
 
     data_order_train{1,1} = 'id';
     data_order_train{1,2} = 'entry date';
     data_order_train{1,3} = 'type';
     data_order_train{1,4} = 'volumen';
     data_order_train{1,5} = 'symbol';
     data_order_train{1,6} = 'price';
     data_order_train{1,7} = 'stop loss';
     data_order_train{1,8} = 'label';
     data_order_train{1,9} = 'exit date';
     data_order_train{1,10} = 'exit price';
     data_order_train{1,11} = 'profit';
     data_order_train{1,12} = 'return order';
     data_order_train{1,13} = 'dif puntos';
 

 for i=1:num
     
     data_order_train{i + 1,1} = order_train(i).id;
     data_order_train{i + 1,2} = datestr(order_train(i).dates);

     data_order_train{i + 1,3} = order_train(i).type;
     data_order_train{i + 1,4} = order_train(i).volumen;
     data_order_train{i + 1,5} = order_train(i).symbol;
     data_order_train{i + 1,6} = order_train(i).price;
     data_order_train{i + 1,7} = order_train(i).stoploss;
     data_order_train{i + 1,8} = order_train(i).label;
     data_order_train{i + 1,9} = datestr(order_train(i).exit_dates);
   
     data_order_train{i + 1,10} = order_train(i).exit_price;
     data_order_train{i + 1,11} = order_train(i).profit;
     data_order_train{i + 1,12} = order_train(i).return_order;
     data_order_train{i + 1,13} = order_train(i).dif_puntos;

 end
 
 % write in a excell the train orders
xlswrite(name_file,data_order_train,'TRAIN_ORDERS','A1');
 

% generate a matrix with the order information
 num = length(order_test);

     data_order_test{1,1} = 'id';
     data_order_test{1,2} = 'entry date';

     data_order_test{1,3} = 'type';
     data_order_test{1,4} = 'volumen';
     data_order_test{1,5} = 'symbol';
     data_order_test{1,6} = 'price';
     data_order_test{1,7} = 'stop loss';
     data_order_test{1,8} = 'label';
     data_order_test{1,9} = 'exit date';
   
     data_order_test{1,10} = 'exit price';
     data_order_test{1,11} = 'profit';
     data_order_test{1,12} = 'return order';
     data_order_test{1,13} = 'dif puntos';
 

 for i=1:num
     
     data_order_test{i + 1,1} = order_test(i).id;
     data_order_test{i + 1,2} = datestr(order_test(i).dates);
    
     data_order_test{i + 1,3} = order_test(i).type;
     data_order_test{i + 1,4} = order_test(i).volumen;
     data_order_test{i + 1,5} = order_test(i).symbol;
     data_order_test{i + 1,6} = order_test(i).price;
     data_order_test{i + 1,7} = order_test(i).stoploss;
     data_order_test{i + 1,8} = order_test(i).label;
     data_order_test{i + 1,9} = datestr(order_test(i).exit_dates);
     
     data_order_test{i + 1,10} = order_test(i).exit_price;
     data_order_test{i + 1,11} = order_test(i).profit;
     data_order_test{i + 1,12} = order_test(i).return_order;
     data_order_test{i + 1,13} = order_test(i).dif_puntos;
 end
 
 % write in a excell the train orders
xlswrite(name_file,data_order_test,'TEST_ORDERS','A1');
        
%% 
%obtain the stadisticts
 
% generate a matrix with the statdistic information

     data_sta_train{1,1} = 'profit_and_loss';
     data_sta_train{1,2} = fit_train.profit_and_loss;
     
     data_sta_train{2,1} = 'average_return';
     data_sta_train{2,2} = fit_train.average_return;
     
     data_sta_train{3,1} = 'sharpe_ratio';
     data_sta_train{3,2} = fit_train.sharpe_ratio;
     
     data_sta_train{4,1} = 'stirlling_ratio';
     data_sta_train{4,2} = fit_train.stirlling_ratio;
     
     data_sta_train{5,1} = 'num_orders';
     data_sta_train{5,2} = fit_train.num_orders;
     
     data_sta_train{6,1} = 'profit_loss_sharpe_ratio';
     data_sta_train{6,2} = fit_train.profit_loss_sharpe_ratio;
     
     data_sta_train{7,1} = 'profit_loss_stirlling_ratio';
     data_sta_train{7,2} = fit_train.profit_loss_stirlling_ratio;
     
     data_sta_train{8,1} = 'average_profit';
     data_sta_train{8,2} = fit_train.average_profit;
     
     data_sta_train{9,1} = 'profit_loss_sharpe_ratio_x_prof_rate';
     data_sta_train{9,2} = fit_train.profit_loss_sharpe_ratio_x_prof_rate;
     
     data_sta_train{10,1} = 'profit_loss_stirlling__x_prof_rate';
     data_sta_train{10,2} = fit_train.profit_loss_stirlling__x_prof_rate;
     
     data_sta_train{11,1} = 'profit_and_loss_x_prof_rate';
     data_sta_train{11,2} = fit_train.profit_and_loss_x_prof_rate;

     data_sta_train{12,1} = 'initial_deposit';
     data_sta_train{12,2} = initial_deposit;
     
     data_sta_train{13,1} = 'profit_rate';
     data_sta_train{13,2} = fit_train.profit_rate;

 % write in a excell the train estadistics
xlswrite(name_file,data_sta_train,'TRAIN_STAT','A1');


     data_sta_test{1,1} = 'profit_and_loss';
     data_sta_test{1,2} = fit_test.profit_and_loss;
     
     data_sta_test{2,1} = 'average_return';
     data_sta_test{2,2} = fit_test.average_return;
     
     data_sta_test{3,1} = 'sharpe_ratio';
     data_sta_test{3,2} = fit_test.sharpe_ratio;
     
     data_sta_test{4,1} = 'stirlling_ratio';
     data_sta_test{4,2} = fit_test.stirlling_ratio;
     
     data_sta_test{5,1} = 'num_orders';
     data_sta_test{5,2} = fit_test.num_orders;
     
     data_sta_test{6,1} = 'profit_loss_sharpe_ratio';
     data_sta_test{6,2} = fit_test.profit_loss_sharpe_ratio;
     
     data_sta_test{7,1} = 'profit_loss_stirlling_ratio';
     data_sta_test{7,2} = fit_test.profit_loss_stirlling_ratio;
     
     data_sta_test{8,1} = 'average_profit';
     data_sta_test{8,2} = fit_test.average_profit;
     
      data_sta_test{9,1} = 'profit_loss_sharpe_ratio_x_prof_rate';
     data_sta_test{9,2} = fit_test.profit_loss_sharpe_ratio_x_prof_rate;
     
     data_sta_test{10,1} = 'profit_loss_stirlling__x_prof_rate';
     data_sta_test{10,2} = fit_test.profit_loss_stirlling__x_prof_rate;
     
     data_sta_test{11,1} = 'profit_and_loss_x_prof_rate';
     data_sta_test{11,2} = fit_test.profit_and_loss_x_prof_rate;
      

     data_sta_test{12,1} = 'initial_deposit';
     data_sta_test{12,2} = initial_deposit;

     data_sta_test{13,1} = 'profit_rate';
     data_sta_test{13,2} = fit_test.profit_rate;
     

 % write in a excell the train estadistics
xlswrite(name_file,data_sta_test,'TEST_STAT','A1');

%%
%plot acumulative profit with orders

[m,n] = size(dataset);
acum_profit_train = fit_train.acu_profits;
buy_signal_train = fit_train.buy_signals;
sell_signal_train = fit_train.sell_signals;
dates = datestr(dataset(:,1));
Closeprice = dataset(:,4);

tabla = [Closeprice acum_profit_train' buy_signal_train' sell_signal_train'];

 % write in a excell the train estadistics
xlswrite(name_file,tabla,'Acumulative_profit_train','B1');
% 
% % Create figure
% figure1 = figure;
% 
% % Create subplot
% subplot1 = subplot(4,1,1,'Parent',figure1);
% box(subplot1,'on');
% hold(subplot1,'all');
% 
% % Create plot
% plot(Closeprice,'Parent',subplot1,'DisplayName','Closeprice');
% 
% % Create title
% title('Close price');
% 
% % Create subplot
% subplot2 = subplot(4,1,2,'Parent',figure1);
% box(subplot2,'on');
% hold(subplot2,'all');
% 
% % Create title
% title('Acumulative profit');
% 
% % Create plot
% plot(acum_profit_train','Parent',subplot2,'DisplayName','acum_profit_train');
% 
% % Create subplot
% subplot3 = subplot(4,1,3,'Parent',figure1);
% box(subplot3,'on');
% hold(subplot3,'all');
% 
% % Create title
% title('Buy signal');
% 
% % Create plot
% plot(buy_signal_train','Parent',subplot3,'DisplayName','buy_signal_train');
% 
% % Create subplot
% subplot4 = subplot(4,1,4,'Parent',figure1);
% box(subplot4,'on');
% hold(subplot4,'all');
% 
% % Create title
% title('sell signals');
% 
% % Create plot
% plot(sell_signal_train','Parent',subplot4,'DisplayName','sell_signal_train');
% 
% saveas(figure1,strcat('profile\profile_train_iter_',num2str(iter),'.bmp'),'bmp'); %save

acum_profit_train = fit_test.acu_profits;
buy_signal_train = fit_test.buy_signals;
sell_signal_train = fit_test.sell_signals;
dates = datestr(dataset_test(:,1));
Closeprice = dataset_test(:,4);

tabla = [Closeprice acum_profit_train' buy_signal_train' sell_signal_train'];

 % write in a excell the train estadistics
xlswrite(name_file,tabla,'Acumulative_profit_test','B1');
% 
% % Create figure
% figure1 = figure;
% 
% % Create subplot
% subplot1 = subplot(4,1,1,'Parent',figure1);
% box(subplot1,'on');
% hold(subplot1,'all');
% 
% % Create plot
% plot(Closeprice,'Parent',subplot1,'DisplayName','Closeprice');
% 
% % Create title
% title('Close price');
% 
% % Create subplot
% subplot2 = subplot(4,1,2,'Parent',figure1);
% box(subplot2,'on');
% hold(subplot2,'all');
% 
% % Create title
% title('Acumulative profit');
% 
% % Create plot
% plot(acum_profit_train','Parent',subplot2,'DisplayName','acum_profit_train');
% 
% % Create subplot
% subplot3 = subplot(4,1,3,'Parent',figure1);
% box(subplot3,'on');
% hold(subplot3,'all');
% 
% % Create title
% title('Buy signal');
% 
% % Create plot
% plot(buy_signal_train','Parent',subplot3,'DisplayName','buy_signal_train');
% 
% % Create subplot
% subplot4 = subplot(4,1,4,'Parent',figure1);
% box(subplot4,'on');
% hold(subplot4,'all');
% 
% % Create title
% title('sell signals');
% 
% % Create plot
% plot(sell_signal_train','Parent',subplot4,'DisplayName','sell_signal_train');
% 
% saveas(figure1,strcat('profile\profile_test_iter_',num2str(iter),'.bmp'),'bmp'); %save

end

