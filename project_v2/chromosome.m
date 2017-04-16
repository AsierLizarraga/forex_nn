classdef chromosome
    %CHROMOSOME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nn_genotype
        phenotype
        norm_params
       
        num_imputs
        num_hiden_layers
        num_neurons_in_layers
        out_neurom
        num_indicators
        number_weight 
        
        
    end
    
    methods
        
        function obj = chromosome(param_num_imputs,param_num_hiden_layers,param_num_neurons_in_layers,param_out_neurom,param_num_indicators)
            % number of inputs
           obj.num_imputs = param_num_imputs;
           % num of hidden layers
           obj.num_hiden_layers = param_num_hiden_layers;
           % num of neuroms
           obj.num_neurons_in_layers = param_num_neurons_in_layers;
           % num of output neuroms
           obj.out_neurom = param_out_neurom;
           % num of indicators
           obj.num_indicators = param_num_indicators;
           
           % calculate the number of weigths
           if param_num_hiden_layers == 1
               
              n =  (param_num_imputs * param_num_neurons_in_layers(1)) +   param_num_neurons_in_layers(1) + (param_num_neurons_in_layers(1) *   param_out_neurom) + param_out_neurom;
              
           end
           
           
           if param_num_hiden_layers == 2
               
              n =  (param_num_imputs * param_num_neurons_in_layers(1)) +   param_num_neurons_in_layers(1)  +    (param_num_neurons_in_layers(2) * param_num_neurons_in_layers(1)) +    param_num_neurons_in_layers(2) + (param_num_neurons_in_layers(2) *   param_out_neurom) + param_out_neurom;
              
           end
           % numper of weights
            obj.number_weight = n;
            
        end
        
        
    end
    
end

