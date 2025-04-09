data = timetable(TIMES', PRICES);

data.Hour = hour(data.Time);

hourlyAvg = varfun(@mean, data, 'GroupingVariables', 'Hour', 'InputVariables', 'PRICES');

hourlyAvgPrices = hourlyAvg.mean_PRICES

plot(hourlyAvgPrices,'LineWidth',5)