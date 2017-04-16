function [offspring] = replacement(replace_method,population,offspring,poulation_measure)

    if strcmp(replace_method,'Elitism')
       [paren1,parent2] = twobestsol(population,poulation_measure);
       
       offspring(1) = paren1;
       offspring(2) = parent2;

    end
    
    
    if strcmp(replace_method,'Unconditional')
        
        
    end
    

end



function [solucion1,solucion2] = twobestsol(population,poulation_measure)

    [Bp,IXp] = sort(poulation_measure,'descend');
        
    solucion1 = population(IXp(1));
    solucion2 = population(IXp(2));
    
end
    
