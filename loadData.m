model_start= tic;

%% load_data

%% Loading Data and definitions of my problem

filename = input_file_name + '.xlsx';
pricesFilename = 'energy-prices.csv';

Folder = cd;
path = fullfile(Folder, "/data/",filename);

pathPrices = fullfile(Folder, "/data/",pricesFilename);

data_dc = readtable(filename,'sheet','db_distcenter');
data_itin = readtable(filename,'sheet','db_itineraries');
data_vehs = readtable(filename,'sheet','db_trucks');
data_char = readtable(filename,'sheet','db_chargers');
%data_dc_ts = readtable(path,'sheet','db_timeseries_dc');

%%
paramsAnalysis = struct();
paramsExperiment = struct();

TU = 0.15; % time unit == fraction of hour
batt_discrete_choice = 0 ;
power_continuous_choice = 0;

DAY = 24; % Hours of a day

% Starting time of simulation
ts = min(data_itin.time_departure_earliest);

% Ending time of simulation
et = max(data_itin.time_arrival_latest);

% Correction to start and end at 00:00:00 of each day
[tts,eet] = start_end_corrector(ts,et);


% Total Days of Analysis (will default to 00 - 23:59
% WATCH OUT, DEPENDING ON LATEST TIME (Tipically we go on to the next day
% in the last itinerary day, 
if max(2,ceil(days(eet-tts))) == 8
    NDAYS = max(2,ceil(days(eet-tts)))-1;
else
    NDAYS = max(2,ceil(days(eet-tts)));
end

% redefine the ending sim day
eet = tts + days(NDAYS);

% Number of time blocks to be created
TB = (NDAYS+0.5)*DAY/TU;

% Create time blocks
T_SIM = linspace(0,(NDAYS+0.5)*DAY,TB+1);

% Since we can't index at 0, or 1.25
% We create an index vector
T = T_SIM/TU + 1; 

% Create time blocks for a single day
T_SIM_DAY = linspace(0,DAY,DAY/TU + 1); 
T_DAY = T_SIM_DAY/TU + 1; 

% Create days array
D = 1:NDAYS; % because the last day up to 23:59:59


% Override 
D = 1:4;
NDAYS = length(D);


%%% Distance matrix of POIs
path2 = "./data/dm2024.xlsx";
dm = readmatrix(path2);
dm = dm/1000; % (m to km)

% for d = D
% 
% TT{d} = tts + hours(T_SIM_DAY(1:(numel(T_SIM_DAY)-1))) + days(d-1);
% 
% end
%% save for storing
paramsAnalysis.input_file = input_file_name;
paramsAnalysis.TU = TU; % time unit == fraction of hour
paramsAnalysis.batt_discrete_choice = batt_discrete_choice ;
paramsAnalysis.power_continuous_choice = power_continuous_choice;
paramsAnalysis.time_start = tts;
paramsAnalysis.time_end = eet;
paramsAnalysis.NDAYS = NDAYS;

