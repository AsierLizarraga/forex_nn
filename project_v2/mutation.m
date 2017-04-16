function  [child1,child2] = mutation(prob_mutation,child1,child2)
%MUTATION Summary of this function goes here
%   Detailed explanation goes here


% mutation for the nn genotype of the child 1

sol = binornd(1,prob_mutation,1,child1.number_weight);
x = rand(1,child1.number_weight);
[sig] = signo(x);
sol = sol.* (0.1.*sig);

aux = child1.nn_genotype + sol;
child1.nn_genotype = corect_nn(aux);

% mutation for the nn genotype of the child 1

sol = binornd(1,prob_mutation,1,child2.number_weight);
x = rand(1,child2.number_weight);
[sig] = signo(x);
sol = sol.* (0.1.*sig);

aux = child2.nn_genotype + sol;
child2.nn_genotype = corect_nn(aux);



end


function [sig] = signo(x)

    n = length(x);
    
    for i=1:n
        
       if x(i) > 0.5
           sig(i) = 1;
       else
           sig(i) = -1;
       end
        
    end

end

function [sig] = corect_nn(x)

    n = length(x);
    
    for i=1:n
        
       if x(i) < -0.8
           
           sig(i) = -0.8;
           
       elseif x(i) > 0.8
           
           sig(i) = 0.8;
           
       else
           
           sig(i) = x(i);

       end
        
    end

end













