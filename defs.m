% Assuming NDAYS, data_dc, data_vehs, and data_char are defined earlier

% define all simulation Times
TIMES = tts + hours(T_SIM);

% Location ID
I = data_dc.id';

% Truck ID
K = data_vehs.id';

% Charger Data
R = data_char.id_charger';
c_r = data_char.power';
C_inf_r = data_char.cost';

% Manual Overrides (for demonstration purposes)
% K = 1:5; % Assuming these are test truck IDs
NDAYS = 3;
D = 1:NDAYS; % Assuming these are test days

% K = OverrideK;
% Itinerary Data
L = cell(NDAYS, length(K));
Itin = cell(NDAYS, length(K));
num_corrs = 0; % Initialize counter for corrections

% Preallocate matrices for efficiency
A = zeros(length(D), length(K));
ori = cell(length(D), length(K));
des = cell(length(D), length(K));

% data_itin = sortrows(data_itin,["truck_id","time_departure_earliest"]);

for d = D
    for k = K
        % Filter itineraries for the current day and truck
        dayFilter = day(data_itin.date) == day(ts + (d - 1));
        truckFilter = data_itin.truck_id == k;
        Itin{d, k} = sortrows(data_itin(dayFilter & truckFilter, :),["time_departure_earliest"]);
        
        % Predefine L to avoid reaccessing each time
        L{d, k} = (1:numel(Itin{d, k}.truck_id))';
        
        % Extract origins and destinations
        ori{d, k} = Itin{d, k}.origin;
        des{d, k} = Itin{d, k}.destination;
    end
end

% Constants for rolling weight
% roll_weight_reg = 350; % kg
% roll_weight_cold = 275; % kg


paramsAnalysis.numLocations = length(I);
paramsAnalysis.numTrucksAvailable = length(K);
paramsAnalysis.numCharTypes = length(R);
paramsAnalysis.NDAYS = NDAYS;
