function [offspring1,offspring2] = crossover(prob_cross,cross_method,parent1,parent2)

if strcmp(cross_method,'one-point') 
    
    sol = binornd(1,prob_cross,1,1);
    
    if( sol == 1)

    
        corte = round(rand(1,1) * parent1.number_weight);
             
         
        for i=1:corte
           
            offspring1_nn(i) = parent1.nn_genotype(i);
            offspring2_nn(i) = parent2.nn_genotype(i);
            
        end

        for i=corte + 1:parent1.number_weight
           
             offspring1_nn(i) = parent2.nn_genotype(i);
             offspring2_nn(i) = parent1.nn_genotype(i);
            
            
        end
        
        offspring1 = parent1;
        offspring2 = parent2;
        
        
        offspring1.nn_genotype = offspring1_nn;
        offspring2.nn_genotype = offspring2_nn;
   
    else
        
         offspring1 = parent1;
         offspring2 = parent2;
        
        
    end
    
end


end

