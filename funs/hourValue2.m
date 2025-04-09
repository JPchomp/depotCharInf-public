function output = hourValue2(date,prices)

% Extract the hour of the day from the input date
% considering multidays data. 
hr = hour(date) + (1 + 24 .* floor(days((date) -  date(1))) );

% Look up the value corresponding to the input hour
output = prices(hr);

end