function [chro,pred] = prediction(net,chro,dataset)

[m,n] = size(dataset');
net = configure(net,dataset',rand(1,n));

% set the weights
setwb(net,chro.nn_genotype')
% obtain predicions
pred = sim(net,dataset');
% set the penotype
chro.phenotype = net;
           

end




