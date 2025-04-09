%% grid_setup.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Energy costs by type of charger and time

% price curve obtained from https://www.energiemarktinformatie.nl/beurzen/elektra/
% P = hourValue(TIMES);

% adjust by the efficiency of each charger type
% P = repmat(P',length(R),1)./data_char.efficiency;


%% New approach
prices = readtable(pricesFilename);

% Keep only relevant timeframe
prices = prices( (prices.Datetime_Local_>=tts & prices.Datetime_Local_<=eet+days(1)) ,:);

% keep as array and convert to per kilowatt
prices = prices.Price_EUR_MWhe_/1000;

% keep only Prices as a vector
PRICES = hourValue2(TIMES,prices);

% adjust by the efficiency of each charger type
PRICES2 = repmat(PRICES',length(R),1)./data_char.efficiency;

% store for output
paramsAnalysis.priceAverageEurKwH = mean(PRICES);