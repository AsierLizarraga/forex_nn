
dataset2 = [1.5 5 ;1.1 6 ;1.4 8];
net = feedforwardnet(2);
net = configure(net,dataset2',rand(1,3));
% trasfer function
net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'tansig';
[m,n] = size(dataset2);
precision = '%0.8f';
%% minmax
ymin = net.inputs{1}.processSettings{2}.ymin;
ymax = net.inputs{1}.processSettings{2}.ymax;

[y,ps2] = mapminmax(dataset2',ymin,ymax);
pred = sim(net,y);


[nn_exp,pre_exp1,pre_exp2,post_exp] = getNeuralNetExpression(net2,1,chro.norm_params);

p = var';

x1 = p(1,1);
x2 = p(2,1);
x3 = p(3,1);
x4 = p(4,1);
x5 = p(5,1);
x6 = p(6,1);
x7 = p(7,1);
x8 = p(8,1);
x9 = p(9,1);
x10 = p(10,1);
x11 = p(11,1);
x12 = p(12,1);
x13 = p(13,1);
x14 = p(14,1);

eval(pre_exp1);
eval(pre_exp2);
output = eval(nn_exp);
eval(post_exp);









%   syms ymax ymin xmin xmax x y
%   solve(y == ((ymax-ymin)*(x-xmin)/(xmax-xmin)) + ymin, x)







