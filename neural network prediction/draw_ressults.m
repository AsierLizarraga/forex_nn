
function [valor_original,valor_predicho] = draw_ressults(cierre,predicciones,horizonte,relativo)
%DRAW_RESSULTS Summary of this function goes here
%   Detailed explanation goes here

    [m,n] = size(cierre);
    
    if relativo == 1
        for i=1:m-horizonte
            
            valor_original(i) = cierre(i + horizonte,1);
            valor_predicho(i) = cierre(i,1) + (predicciones(i)/10000);
            
        end
    end
    
    if relativo == 0
        
        for i=1:m-horizonte
            
            valor_original(i) = cierre(i + horizonte,1);
            valor_predicho(i) = predicciones(i);
            
        end
    end
    

end

