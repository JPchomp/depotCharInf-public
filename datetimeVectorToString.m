function commaSeparatedString = datetimeVectorToString(datetimeVector)
    % Convert datetimes to strings
    stringVector = datestr(datetimeVector, 'dd/mm/yyyy HH:MM:SS');
    
    % Convert character array to cell array of strings
    stringCellArray = cellstr(stringVector);
    
    % Join strings with commas
    commaSeparatedString = strjoin(stringCellArray, ', ');
end