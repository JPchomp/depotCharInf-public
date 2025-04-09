clc
clear all

%% Define Resolution of Analysis
addpath("./data") 
addpath("./funs")
addpath(genpath("./YALMIP-master"))
yalmip('clear')

input_file_name = "data_itins_A_44_db_RobertCheck_nT_94_at_100_ac_10";
% Load problem data
run a_data_load.m;

% Definitions 
run b_definitions.m

% Grid 
run c_grid_setup.m

% Trucks
run d_vehicle_setup.m

% Optimization and tuning parameters
run d_parameters.m

% Initialize Tables for storing outputs
run d_OutputTablesSetup.m

% Pre-existing infa? 
% "opt", or "rule"
choice = "opt";
paramsAnalysis.typeInfrastructure = choice;

%% String variable for new folder collecting experiments
new_folder = "INFORMS";
paramsAnalysis.storingFolderName = new_folder;

%% Experiment Definitions
K_DESIGN = [2]; % ,50,75,100];

PF_DESIGN = [1]; % ,2];

ts_at_dcs = [15]; %

priceMultipliers = [1,2];


paramsExperiments.costICE = cICE;
paramsExperiments.costExtraTime = c_times;
paramsExperiments.upperTimeUnitDeviation = upperLimTimeExtra;


disp("Analysis Params")
paramsAnalysis

for time_at = ts_at_dcs
time_at_dcs = minutes(time_at);

% We run first only the things affected by the time slack
% Avoids re-running for peak factor changes

% vehicle_setup (itineraries)
run e_vehicle_itin_setup.m

% Test itineraries for coherence in arrival-departure times
run itinTest.m

for K_EXPERIMENT = K_DESIGN

for pf = PF_DESIGN % run here objective
for pM = priceMultipliers     
paramsExperiments.KExperiment = K_EXPERIMENT;
paramsExperiments.timeSlacks = time_at_dcs;
paramsExperiments.peakFactor = pf;
paramsExperiments.energPriceMultiplier = pM;
% ALSO CHECK WHAT YOU CAN SAVE BY PEAK FACTOR!!!

clear('yalmip')

K = 1:K_EXPERIMENT;

disp("Experiment Params")
paramsExperiments

run efficient_implementation_for_experiments.m

exp = sprintf('K_%d_pf_%d_ts_%d_%s',K_EXPERIMENT,pf,time_at,choice);

run efficient_solution_writing_AL.m

end
end
end
end

pathTable = fullfile('./out/tableResults.csv');
writetable(resultsTable,pathTable)

%%


