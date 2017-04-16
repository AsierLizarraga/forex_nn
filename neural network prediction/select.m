
function [d] = select(dataset)

[m,n] = size(dataset);
d = [];

for i=7:n
    
    d = [d dataset(:,i)];
    
end

end
