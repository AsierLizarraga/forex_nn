function [pred] = prediction_test(net,chro,dataset)

            % obtain the input variables selected FOR TEST
            var = select(dataset);
            
            % NORMALIZE WITH THE TRAIN PARAMETERS
            p = mapminmax('apply',var',chro.norm_params);
          
            net2 = chro.phenotype; 
            
            % obtein the prediction of the neural network
            A(isnan(p)) = 0;
%             disp('muestro el data set');
%             disp(p);
            pred = sim(net2,p);
  
end

function [d] = select(dataset)

[m,n] = size(dataset);
d = [];

for i=7:n
    
    d = [d dataset(:,i)];
    
end

end