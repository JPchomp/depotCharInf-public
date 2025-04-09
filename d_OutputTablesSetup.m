%% Write the experiment specific results
% Define variable names and types
variableNames = {'Time Slack', 'Peak Factor', 'NTrucks', '60', '180', '360' , '720', '1080' , ...
    'peakCons','peakCost', 'energyCosts', 'infra_costs','ICE','ObjValue','Gap'};

variableTypes = {'double', 'double', 'double','double', 'double', 'double','double', 'double', 'double','double', 'double','double','double','double','double'};

% Create an empty table with specified variable names and types
resultsTable = table('Size', [0 length(variableTypes)], 'VariableTypes', variableTypes, 'VariableNames', variableNames);

%% Write the optimization specific results
% Define variable names and types
variableNames = {'c_ICE','c_infra','c_batt', 'c_times', 'c_energy' , 'c_peak' };
variableTypes = {'double', 'double', 'double','double', 'double', 'double'};

% Create an empty table with specified variable names and types
costsTable = table('Size', [0 length(variableTypes)], 'VariableTypes', variableTypes, 'VariableNames', variableNames);

%% Write the optimization specific results
% Define variable names and types
variableNames = {'MaxFastCharging', 'MaxNightCharging', 'StartingBattery','EndingBattery','c_times','E_min','E_sup','MIPGAP'};
variableTypes = {'double', 'double', 'double','double', 'double','double', 'double', 'double'};

% Create an empty table with specified variable names and types
parametersTable = table('Size', [0 length(variableTypes)], 'VariableTypes', variableTypes, 'VariableNames', variableNames);

%% Table displaying results for multiple runs
variableTypes = {'double','double', 'double', 'double','double', 'double','double', 'double', 'double', 'double', 'double','double', 'double','double','double', 'double','double','double','double'};
variableNames = {'Price Mult','Time Slack', 'Peak Factor', 'NTrucks', '60', '180', '360' , '720', '1080' , 'peakCons','peakCosts', 'energyCosts', 'infra_costs','DV_ICE','ctea','cted','c_batts','ObjValue','Gap'};
aggregatedResultsTable = table('Size', [0 length(variableNames)], 'VariableTypes', variableTypes, 'VariableNames', variableNames);
