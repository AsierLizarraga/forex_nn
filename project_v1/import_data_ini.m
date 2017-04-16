function [ts] = import_data_ini(file)

%% Initialize variables.
filename = file;
delimiter = ';';
startRow = 2;
formatSpec = '%s%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
raw = [dataArray{:,1:end-1}];
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[2,3,4,5,6]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\.]*)+[\,]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\.]*)*[\,]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers=='.');
                thousandsRegExp = '^\d+?(\.\d{3})*\,{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, '.', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = strrep(numbers, '.', '');
                numbers = strrep(numbers, ',', '.');
                numbers = textscan(numbers, '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [2,3,4,5,6]);
rawCellColumns = raw(:, 1);
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
FECHA = rawCellColumns(:, 1);
APERTURA = cell2mat(rawNumericColumns(:, 1));
ALTO = cell2mat(rawNumericColumns(:, 2));
BAJO = cell2mat(rawNumericColumns(:, 3));
CIERRE = cell2mat(rawNumericColumns(:, 4));
VOLUMEN = cell2mat(rawNumericColumns(:, 5));

data = [APERTURA ALTO BAJO CIERRE VOLUMEN];

% [m,n] = size(FECHA);
% % trasform the date formats
% % for i=1:m
% %     s = char(FECHA(i,1));
% %     [ano remain] = strtok(s,'.');
% %     [mes remain]= strtok(remain,'.');
% %     [token_dia hora]= strtok(remain);
% %     [dia]= strtok(token_dia,'.');
% %     fech{i,1} = strcat(ano,'-',mes,'-',dia,' ',hora);
% % end

% create the finanacial time series
ts = fints(FECHA,data,{'APERTURA' 'ALTO' 'BAJO' 'CIERRE' 'VOLUMEN'});

end



