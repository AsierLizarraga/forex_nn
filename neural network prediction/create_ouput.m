function [output] = create_ouput(cierre,horizonte,relativo)

[m,n] = size(cierre);

if relativo ==  1
    for i=1:m - horizonte
        output(i) = ( cierre(i + horizonte,1) - cierre(i,1) ) * 10000;
    end
end

if relativo ==  0
    for i=1:m - horizonte
        output(i) = cierre(i + horizonte,1);
    end
end


end

