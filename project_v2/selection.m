function [parent1, parent2] = selection(method,population,popsize,population_fitnes,tournament_sample)

if strcmp(method,'tournament')
    
    % select random tournament_sample from the population
    f = 1 + ceil((popsize - 1).*rand(1,tournament_sample));
    
    for i=1:tournament_sample
        
        b(i) = population_fitnes(f(i));
        
    end
    
    [B,IX] = sort(b,'descend');
    
    parent1 = population(IX(1));
    parent2 = population(IX(2));
    
end


if strcmp(method,'random')
    
    % selection of random parents
   
    f = 1 + ceil((popsize - 1).*rand(1,2));
    
    parent1 = population(f(1));
    parent2 = population(f(2));
    
end




    
end