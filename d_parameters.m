%% Keep Prices >= 0 for now 
PRICES_BUP = PRICES;
% PRICES = PRICES + abs(min(PRICES));

%% Tuning Params

% Force slow charging infrastructure for X(1,1) > Num Trucks
charging_infra_night = 0;

% Force chargers to be only located in DC
CDC = 1;

% Is night charging only slow powered?
nightChargingLimits = 0;

% Maximum power for each vehicle night charging (only active if above == 1)
NightChargingMaxP = 1080;

%TODO max power charging for each vehicle...

% Limits
E_min = 0.01;% Safety factor for minimum battery charge.
E_sup = 1; % Safety factor for maximum battery charge
E_MaxFastCharging = 1;

% Starting and Ending battery SOCs
StartingBattery = 0.8;
EndingBattery = 0.8;

% GAP
MIPGAP = 0.05;
TimeLimitOpt = 10*60;
TimeLimit = 20*60;

%% Costs for obj function
% Peak Costs
peak_per_location = 7*(length(D)/30);
% Infrastructure prorrate value
prorrate_infra = (length(D)/(10*350));
% Vehicle battery prorrate
prorrate_vehs = (length(D)/(10*350));
% Big cost for reducing a trip Energy Required
% why: 315kwh is max Etrip, 0.0001*315~0.03kwh, that would cost in the objective 100
cICE = 10e5;
% cost for a 15 min delay, should be comparable to the cost of a 180kw
% charger and a peak of 180 kw extra
ref_charger = 2;
c_times = (data_char.cost(ref_charger)*prorrate_infra + peak_per_location*data_char.power(ref_charger))*TU;

%
upperLimTimeExtra = 15; % how many additional minutes we allow the vehicles to purchase
upperLimTimeExtraUnits = upperLimTimeExtra / (TU*60); % X hour / TU = how many units for 1h leeway


% write to params
paramsAnalysis.forceSlowChargersEqualKForNight = charging_infra_night;
paramsAnalysis.forceChargersOnlyAtDC = CDC;
paramsAnalysis.forceNightChargingOnlySlow = nightChargingLimits;
paramsAnalysis.NightChargingMaxPower = NightChargingMaxP*nightChargingLimits;

paramsAnalysis.MinimumSocLevel = E_min;
paramsAnalysis.MaxSocLevel = E_sup;
paramsAnalysis.MaxSocForFastCharging = E_MaxFastCharging;

paramsAnalysis.StartingSocOptimization = StartingBattery;
paramsAnalysis.EndingSocOptimization = EndingBattery;
paramsAnalysis.MipOptGap = MIPGAP;
paramsExperiments.OptMaxTimeSolveMins = TimeLimitOpt;

paramsAnalysis.peak_per_location = peak_per_location;
paramsAnalysis.prorrate_infra = prorrate_infra;
paramsAnalysis.prorrate_vehs = prorrate_vehs;

paramsAnalysis.UpperLimTimeExtra = upperLimTimeExtra;    
paramsAnalysis.UpperLimTimeExtraUnits = upperLimTimeExtraUnits;  