classdef order
    %ORDER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        dates
        type
        volumen
        symbol
        price
        stoploss
        label
        
        exit_dates
        exit_price      
        profit
        return_order
        dif_puntos
         
    end
    
    methods
        
        function obj = order(param_id,param_dates,param_type,param_volumen,param_symbol,param_price,param_stoploss,param_label)
                       
            obj.id = param_id;
            obj.dates = param_dates;
     
            obj.type = param_type;
            obj.volumen = param_volumen;
            obj.symbol = param_symbol;
            obj.price = param_price;
            obj.stoploss = param_stoploss;
            obj.label = param_label;

        end
        
        
    end
    
end

