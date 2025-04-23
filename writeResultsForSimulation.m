disp("Started Writing Outputs to disk")

%% Write overall static path
path_out  = "./out";
path_out  = fullfile(path_out);

% path_out = 'C:\Users\2022336\OneDrive - TU Eindhoven\Github\01-TUE-GTDE\01-ETRUCKS\models\modelValidation4\inputs';
mkdir(fullfile(path_out, new_folder, exp))
path_out  = fullfile(path_out, new_folder, exp);

%%% Delete previous files (MOVE TO SEPARATE FOLDER IF YOU WANT TO STORE!!)
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(path_out)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', path_out);
  uiwait(warndlg(errorMessage));
  return;
end

% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(path_out, '*.xls'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for it = 1 : length(theFiles)
  baseFileName = theFiles(it).name;
  fullFileName = fullfile(path_out,baseFileName);
  fprintf(1, 'Now deleting %s\n', fullFileName);
  delete(fullFileName);
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(path_out, '*.csv'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for it = 1 : length(theFiles)
  baseFileName = theFiles(it).name;
  fullFileName = fullfile(path_out,baseFileName);
  fprintf(1, 'Now deleting %s\n', fullFileName);
  delete(fullFileName);

end
fprintf(1, '\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
fprintf(1, '\n')


%% Definitions to pass the charger values afterwards
clear pow_char_session_extra
clear start_char_session_extra
clear loc_char_session_extra
clear pow_char_session_str_extra
clear start_char_session_str_extra
clear loc_char_session_str_extra

char_locs_rep = repmat(R, length(TIMES),1, length(K) );
Charger_Choice = squeeze(value(sum(Y.*char_locs_rep ,2)));

Time_rep = repmat(T_SIM',1,length(K) );
Time_Choice = Time_rep.*squeeze(value(sum(Y,2)));

% value(P)

for k = K
    for d = D

        pow_char_session{d,k}   =  repmat(cell(1,1), length(L{d,k}),1);
        start_char_session{d,k} =  repmat(cell(1,1), length(L{d,k}),1);
        loc_char_session{d,k}   =  repmat(cell(1,1), length(L{d,k}),1);
        pow_char_session_str{d,k} =  repmat(cell(1,1), length(L{d,k}),1);
        start_char_session_str{d,k} = repmat(cell(1,1), length(L{d,k}),1);
        loc_char_session_str{d,k} = repmat(cell(1,1), length(L{d,k}),1);

    end
        pow_char_session_extra{k}   =  cell(1);
        start_char_session_extra{k} =  cell(1);
        loc_char_session_extra{k}   =  cell(1);
        pow_char_session_str_extra{k} =  cell(1);
        start_char_session_str_extra{k} = cell(1);
        loc_char_session_str_extra{k} = cell(1);
end


%%
for k = K
    for l = 1:lmax(k)


if value(e_charge(k,l))>0          


% These translate into the itin in excel.
        dayItin = dayIncidence(k,l) ;
        legItin = legIncidence(k,l);     

        if l==1 % If this is the first item in the full L matrix (ie l=1, d=1)

        tspan = 1:ceil(value(tda(k,l)));

        else

        tspan = ceil(value(taa(k,l-1))):ceil(value(tda(k,l))); % This could run into troubles potentially????
        % floor on tda?
        end

        pow_char_session{dayItin,k}(legItin)   =   {[pow_char_session{dayItin,k}{legItin}; value(P(tspan,k))]};
        start_char_session{dayItin,k}(legItin) =   {[start_char_session{dayItin,k}{legItin}; Time_Choice(tspan,k)]};
        loc_char_session{dayItin,k}(legItin)   =   {[loc_char_session{dayItin,k}{legItin}; Charger_Choice(tspan,k)]};

        if sum(pow_char_session{dayItin,k}{legItin})>0 %Remove if all entries are zero

        % remove all zero entries
        indicator_zeroes_temp = pow_char_session{dayItin,k}{legItin};
        indexes = indicator_zeroes_temp>0; 

    
        pow_char_session_str{dayItin,k}{legItin} =  doubleVectorToString([pow_char_session{dayItin,k}{legItin}(indexes)]);
        start_char_session_str{dayItin,k}{legItin} = datetimeVectorToString(tts + hours([start_char_session{dayItin,k}{legItin}(indexes)]));
        loc_char_session_str{dayItin,k}{legItin} = intVectorToString([loc_char_session{dayItin,k}{legItin}(indexes)]);

        else

        end


else
end
    end
end

%% dirty addition of final row

for k = K
    for l = lmax(k)+1

        if value(e_charge(k,l))>0   
        dayItin = 1 ;
        legItin = 1; 
%
    tspan = ceil(value(taa(k,l-1))):max(T);
%
pow_char_session_extra{k}(1)   =   {[pow_char_session_extra{k}{1}; value(P(tspan,k))]};
start_char_session_extra{k}(1) =   {[start_char_session_extra{k}{1}; Time_Choice(tspan,k)]};
loc_char_session_extra{k}(1) =   {[loc_char_session_extra{k}{1}; Charger_Choice(tspan,k)]};

if sum(pow_char_session_extra{1}{1})>0 %Remove if all entries are zero

% remove all zero entries
indicator_zeroes_temp = pow_char_session_extra{k}{1};
indexes = indicator_zeroes_temp>0; 

pow_char_session_str_extra{k}{1} =  doubleVectorToString([pow_char_session_extra{k}{1}(indexes)]);
start_char_session_str_extra{k}{1} = datetimeVectorToString(tts + hours([start_char_session_extra{k}{1}(indexes)]));
loc_char_session_str_extra{k}{1} = intVectorToString([loc_char_session_extra{k}{1}(indexes)]);
else

end
        else
        end
    end
end

%% ## efficient Solution Writing
itin_results_for_AL = table();
Itin_out = Itin;

counter = zeros(length(K),1);

for k = K
    for d = D

        if ~isempty(Itin{d,k}) % check for empty itins for some day.

            % fisrt value for indexing
            ls = counter(k) + 1 ; 

            % Update value at counter
            ln = numel(L{d,k}); % total existing legs for d,k
            counter(k) = counter(k) + ln; % update how many were parsed.

            % final value for index 
            lt = counter(k); 

            idx = ls:lt;

            Itin_out{d,k}.e_charged = f_ValueAndTranspose(e_charge(k,idx));

            Itin_out{d,k}.DV_ICE = value(DV_ICE(k,idx))';

            Itin_out{d,k}.soc_i = f_ValueAndTranspose(ei(k,idx));
            Itin_out{d,k}.soc_j = f_ValueAndTranspose(ej(k,idx));
            Itin_out{d,k}.cons = f_ValueAndTranspose(cc(k,idx));

            Itin_out{d,k}.time_dep_act = datetime(tts + TU*hours(f_ValueAndTranspose(tda(k,idx))),'InputFormat','dd-MMM-yyyy HH:mm:ss');
            Itin_out{d,k}.time_arr_act = datetime(tts + TU*hours(f_ValueAndTranspose(taa(k,idx))),'InputFormat','dd-MMM-yyyy HH:mm:ss');

            Itin_out{d,k}.time_departure_latest = datetime(tts + TU*hours(f_ValueAndTranspose(tdl(k,idx))),'InputFormat','dd-MMM-yyyy HH:mm:ss');;
            Itin_out{d,k}.time_arrival_latest = datetime(tts + TU*hours(f_ValueAndTranspose(tal(k,idx))),'InputFormat','dd-MMM-yyyy HH:mm:ss');;

            Itin_out{d,k}.expected_travel_time = minutes(Itin_out{d,k}.time_arr_act - Itin_out{d,k}.time_dep_act);
            Itin_out{d,k}.TransportTime = 60*TU*tim_units_fast{d,k};

            Itin_out{d,k}.LoadingTime = minutes(Itin_out{d,k}.loading_time);
            Itin_out{d,k}.Distance = Dis{d,k};

            Itin_out{d,k}.charge_session_power = pow_char_session_str{d,k}(:); 
            Itin_out{d,k}.charge_session_time = start_char_session_str{d,k}(:);
            Itin_out{d,k}.charge_session_loc = loc_char_session_str{d,k}(:);  

            
            if d == D(end)

               temp_row =  Itin_out{d,k}(end,:);
               temp_row.origin = 0;
               temp_row.destination = 0;

               temp_row.charge_session_power = pow_char_session_str_extra{k};
               temp_row.charge_session_time = start_char_session_str_extra{k};
               temp_row.charge_session_loc = loc_char_session_str_extra{k};
               temp_row.e_charged = value(e_charge(k,maxL+1));
               temp_row.soc_i = temp_row.soc_j; % use the last one
               temp_row.soc_j = temp_row.e_charged + temp_row.soc_j; % update with charge

               Itin_out{d,k} = [Itin_out{d,k} ; temp_row];
            else
            end

            itin_results_for_AL = [itin_results_for_AL; Itin_out{d,k}];

        else
        end
    end
end




% var = sprintf('results_K_%d_D_%d_I_%d_T_%d_%s',length(K),length(D),length(I),length(T_SIM),input_file_name);
var = sprintf('results.xls');
path_out_var = fullfile(path_out, var);

 fullFileName = fullfile(path_out_var);
 fprintf(1, 'Now writing %s\n', fullFileName);

writetable(itin_results_for_AL,path_out_var,'Sheet',"db_itineraries")

%% 2. Charger type and power data
table_char = table();
table_char.id_type = R';
table_char.power = c_r';
table_char.cost  = data_char.cost  ;
table_char.efficiency  = data_char.efficiency;

% additional rows
dummy_row_a = table_char(end,:);
dummy_row_a.id_type = 6;
dummy_row_b = dummy_row_a;
dummy_row_b.id_type = 7;

% compile
table_char = [table_char ;dummy_row_a; dummy_row_b];
writetable(table_char,path_out_var,'Sheet',"db_chargers");

%1. Distribution Center Data
data_dc_out = data_dc;

for r = R
     names = sprintf('num_chars_type_%d',r);
     data_dc_out.(names) = value(X(:,r));
end

% added 6 and 7 for future
for r = 6:7
     names = sprintf('num_chars_type_%d',r);
     data_dc_out.(names) = zeros(size(X(:,5)));
end

%change the name of the columns  for anylogic

data_dc_out.Properties.VariableNames([2 3 4]) = {'description' 'lat' 'lon'};
writetable(data_dc_out,path_out_var,'Sheet',"db_distcenter");


%% Prices Data
% 19-04-2024 added prices as new sheet
PRICES_OUT = table(TIMES',PRICES);
% Added times for robinson reference
PRICES_OUT.Properties.VariableNames = {'Time', 'Price(kWh)'};
% Write to the Excel sheet
writetable(PRICES_OUT, path_out_var, 'Sheet', 'prices');

%% Trucks Data
data_vehs_bis = data_vehs;
batts_new = value(B); % may be shorter than original
lengthB = length(batts_new);
data_vehs_bis.battery(1:lengthB) = batts_new;
%data_vehs_bis.energyDensity = repmat(energy_density,length(K),1);
data_vehs_bis.energyDensity = repmat(energy_density,height(data_vehs),1);
writetable(data_vehs_bis,path_out_var,'Sheet',"db_trucks");

%% Write main Diagnostics

writetable(struct2table(paramsAnalysis), path_out_var,'Sheet',"paramsAnalysis")

writetable(struct2table(paramsExperiments), path_out_var,'Sheet',"paramsExperiments")

writetable(struct2table(paramsDiagnostics), path_out_var,'Sheet',"paramsDiagnostics")

%% Write all the tables of results
% var = sprintf('opt_run_results_K_%d_D_%d_I_%d_T_%d.csv',length(K),length(D),length(I),length(T_DAY));
% path_out_var = fullfile(path_out, var);
% writetable(resultsTable,path_out_var);
writetable(resultsTable, path_out_var,'Sheet',"tableResults")

% var = sprintf('opt_run_parameters_K_%d_D_%d_I_%d_T_%d.csv',length(K),length(D),length(I),length(T_DAY));
% path_out_var = fullfile(path_out, var);
% writetable(parametersTable,path_out_var);
writetable(parametersTable, path_out_var,'Sheet',"tableParams")

% var = sprintf('opt_run_costsResults_K_%d_D_%d_I_%d_T_%d.csv',length(K),length(D),length(I),length(T_DAY));
% path_out_var = fullfile(path_out, var);
% writetable(costsTable,path_out_var);
writetable(costsTable, path_out_var,'Sheet',"tableCosts")


%% Record some key global metrics 
keyGlobalMetrics.totalEnergyUsedkWh = sum(sum(value(P)))*TU;
keyGlobalMetrics.totalEnergyCostEur = value(c_charging);
keyGlobalMetrics.meanPriceEurkWh = mean(PRICES);
keyGlobalMetrics.sdPriceEurkWh = std(PRICES);
keyGlobalMetrics.operationalPriceEurkWh = keyGlobalMetrics.totalEnergyCostEur/keyGlobalMetrics.totalEnergyUsedkWh;
keyGlobalMetrics.totalDistanceDrivenKM = table2array(sum(data_itin(data_itin.truck_id <= paramsExperiments.KExperiment,"DistanceNode")));
keyGlobalMetrics.numVehicles = paramsExperiments.KExperiment;
keyGlobalMetrics.distancePerVehicleKM = keyGlobalMetrics.totalDistanceDrivenKM / keyGlobalMetrics.numVehicles ;
keyGlobalMetrics.distancePerVehicleKMDay = keyGlobalMetrics.distancePerVehicleKM / paramsAnalysis.NDAYS;
keyGlobalMetrics.energyPerVehiclekWh = keyGlobalMetrics.totalEnergyUsedkWh / keyGlobalMetrics.numVehicles;
keyGlobalMetrics.energyPerVehiclekWhDay =  keyGlobalMetrics.energyPerVehiclekWh / paramsAnalysis.NDAYS;

payloads_origin = data_itin(data_itin.truck_id <= paramsExperiments.KExperiment & data_itin.origin == 1,["origin","payload_origin","payload_origin_cold"]);

keyGlobalMetrics.totalColdRolls = sum(payloads_origin.payload_origin_cold);
keyGlobalMetrics.totalDryRolls = sum(payloads_origin.payload_origin);
keyGlobalMetrics.totalColdRollsTON = keyGlobalMetrics.totalColdRolls * 0.275;
keyGlobalMetrics.totalDryRollsTON = keyGlobalMetrics.totalDryRolls * 0.350; 

keyGlobalMetrics.totalChargingTimeHR = sum(squeeze(sum(sum(value(Y)))*TU)); 
keyGlobalMetrics.totalChargeTimebyChargerHR = squeeze(sum(sum(value(Y),1),3))*TU;

writetable(struct2table(keyGlobalMetrics), path_out_var,'Sheet',"macroMetrics")

%% Write the final charger data (only of interest)

    [aa,bb,dd]=findND(value(X));
    results_charger_locations = table();
    
    results_charger_locations.locations= bb;
    results_charger_locations.type = aa;
    results_charger_locations.number = dd; 
    
var = sprintf('charger_loc_type.csv');
path_out_var = fullfile(path_out, var);
writetable(results_charger_locations,path_out_var);

%% Total Values by location
var = sprintf('charger_loc_type_complete.csv');
path_out_var = fullfile(path_out, var);
fprintf(1, 'Now writing %s\n', path_out_var)
writematrix(value(X),path_out_var);

%% Record of Times Used

var = sprintf('times.csv');
path_out_var = fullfile(path_out, var);
fprintf(1, 'Now writing %s\n', path_out_var)
writematrix(datetime(TIMES,'Format','dd-MM-yyyy HH:mm:ss')',path_out_var);

%% Redord of Prices
% Kept only prices here, in the future can have multiple 
% location-dependent curves.
var = sprintf('prices.csv');
path_out_var = fullfile(path_out, var);
fprintf(1, 'Now writing %s\n', path_out_var)
writematrix(PRICES,path_out_var);



