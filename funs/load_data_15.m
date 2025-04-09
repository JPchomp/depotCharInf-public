model_start= tic;

%% load_data

data_dc = readtable(path,'sheet','db_distcenter');
data_itin = readtable(path,'sheet','db_itineraries');
data_vehs = readtable(path,'sheet','db_trucks');
data_char = readtable(path,'sheet','db_chargers');
%data_dc_ts = readtable(path,'sheet','db_timeseries_dc');

% Starting time of simulation
ts = min(data_itin.time_departure_earliest);

% Ending time of simulation
et = max(data_itin.time_arrival_latest);

% Correction to start and end at 00:00:00 of each day
[tts,eet] = start_end_corrector(ts,et);

% Total time blocks to be created
NDAYS = max(1,ceil(days(eet-tts)));

% Number of time blocks to be created
TB = NDAYS*DAY/TU; 

% Create time blocks
T_SIM = linspace(0,NDAYS*DAY,TB+1);

% Since we can't index at 0, or 1.25
% We create an index vector
T = T_SIM/TU + 1; 

% Create time blocks for a single day
T_SIM_DAY = linspace(0,DAY,DAY/TU + 1); 
T_DAY = T_SIM_DAY/TU + 1; 

% Create days array
D = 1:NDAYS;


%%% Distance matrix of POIs
path2 = "\data\dm-p.xlsx";
dm = readmatrix(path2);
dm = dm/1000; % (m to km)

for d = D

TT{d} = tts + hours(T_SIM_DAY(1:(numel(T_SIM_DAY)-1))) + days(d-1);

end
