function [tsobj] = import_data(file)
%% Import data from text file.
%% Initialize variables.
filename = file;
delimiter = ';';
startRow = 2;

%% Format string for each line of text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
FECHA = dataArray{:, 1};
APERTURA = dataArray{:, 2};
ALTO = dataArray{:, 3};
BAJO = dataArray{:, 4};
CIERRE = dataArray{:, 5};
VOLUMEN = dataArray{:, 6};
tendencia = dataArray{:, 7};
CloseMACD = dataArray{:, 8};
TRENDSMA5 = dataArray{:, 9};
TRENDSMA25 = dataArray{:, 10};
RSI14 = dataArray{:, 11};
TRENDRSI14 = dataArray{:, 12};
CCI14 = dataArray{:, 13};
TRENDCCI14 = dataArray{:, 14};

[m,n] = size(FECHA);
% trasform the date formats
for i=1:m
    s = char(FECHA(i,1));
    [ano remain] = strtok(s,'.');
    [mes remain]= strtok(remain,'.');
    [token_dia hora]= strtok(remain);
    [dia]= strtok(token_dia,'.');
    fech{i,1} = strcat(ano,'-',mes,'-',dia,' ',hora);
end

data = [APERTURA ALTO BAJO CIERRE VOLUMEN tendencia CloseMACD TRENDSMA5 TRENDSMA25 RSI14 TRENDRSI14 CCI14 TRENDCCI14];
tsobj = fints(fech,data,{'APERTURA' 'ALTO' 'BAJO' 'CIERRE' 'VOLUMEN' 'tendencia' 'CloseMACD' 'TRENDSMA5' 'TRENDSMA25' 'RSI14' 'TRENDRSI14' 'CCI14' 'TRENDCCI14' });

end

