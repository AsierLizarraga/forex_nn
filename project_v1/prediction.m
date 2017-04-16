function [chro,pred] = prediction(net,chro,dataset)

            % obtain the input variables selected
            var = select(dataset);
            % normalizo los datos
            [p,ps] = mapminmax(var');
            % set the normalization parameters
            chro.norm_params = ps;
            
            % net configuration
            [m,n] = size(p);
            % le digo a la red los rangos de las variable de entrada y
            % salida
            net = configure(net,p,rand(1,n));
            
            % trasfer function
            if chro.num_hiden_layers == 1
                
                net.layers{1}.transferFcn = 'tansig';
                net.layers{2}.transferFcn = 'tansig';
                
            else
                
                net.layers{1}.transferFcn = 'tansig';
                net.layers{2}.transferFcn = 'tansig';
                net.layers{3}.transferFcn = 'tansig';
                
            end
            
            % set the weights
            setwb(net,chro.nn_genotype')
            
            % obtein the prediction of the neural network
            A(isnan(p)) = 0;
%             disp('muestro el data set');
%             disp(p);
            pred = sim(net,p);
            
            % set the penotype
            chro.phenotype = net;



end

function [d] = select(dataset)

[m,n] = size(dataset);
d = [];

for i=7:n
    
    d = [d dataset(:,i)];
    
end

end