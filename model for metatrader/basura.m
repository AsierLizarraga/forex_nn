 [dataset,names,tech] = create_technical_indicators(ts,inc_macd,inc_stochosc,inc_tsmovavg,inc_tsmom,inc_rsindex,inc_adline,inc_bollinger,inc_volroc);

        % obtain the input variables selected FOR TEST
        var = select(dataset);
        
        var(1,1) = 1;
        var(1,2) = 1;
        var(1,3) = 1;
        var(1,4) = 1;
        var(1,5) = 1;
        var(1,6) = 1;
        var(1,7) = 1;
        var(1,8) = 1;
        var(1,9) = 1;
        var(1,10) = 1;
        var(1,11) = 1;
        var(1,12) = 1;
        var(1,13) = 1;
        var(1,14) = 1;
        
        % NORMALIZE WITH THE TRAIN PARAMETERS
        p = mapminmax('apply',var',chro.norm_params);
        
        % obtein the prediction of the neural network
        A(isnan(p)) = 0;
        %             disp('muestro el data set');
        %             disp(p);
        pred = sim(net2,p);