function [pred_test] = prediction_test(chro,dataset)
            
% net configuration
% obtain the input variables selected FOR TEST
net2 = chro.phenotype;
pred_test = sim(net2,dataset');

 
end
