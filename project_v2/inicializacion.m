function [population] = inicializacion(num_imputs,num_hiden_layers,num_neurons_in_layers,out_neurom,num_indicators,population_size)
%INICIALIZACION Summary of this function goes here
%   Detailed explanation goes here


for i=1:population_size
    
    % create a chromosome
    chro = chromosome(num_imputs,num_hiden_layers,num_neurons_in_layers,out_neurom,num_indicators);
    
    % inizialate the neural network genotype
    neg = rand(1,chro.number_weight);
    sing = sig(neg);
    chro.nn_genotype = rand(1,chro.number_weight).*(sing.*0.8);
     
    population(i) = chro;
    
end
   
       
end

 
function [sig] = sig(x)

    n = length(x);
    
    for i=1:n
        
       if x(i) > 0.5
           sig(i) = 1;
       else
           sig(i) = -1;
       end
        
    end

end


