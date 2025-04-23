%% vehicle_itin_setup.m

% Preallocate distance and times columns
Dis = cell(length(D),length(K)); 
tim = cell(length(D),length(K)); 
tim_units = cell(length(D),length(K)); 

for d = D
for k = K

%% Let's use the travel times provided by AH (11-14-2023)
    individual_travel_times = Itin{d,k}.TransportTime/60; % fraction of hour, as now its minutes
 
% Write the times vector to each truck k    
    tim{d,k} = cumsum(individual_travel_times); % fraction of hour.

    % Consumptions are linked to travel times given in this case
    Dis{d,k} = Itin{d,k}.DistanceNode; 
    
% time of travel for each trip leg 

    tim_units_fast{d,k} = round(((individual_travel_times) / TU) * 0.8 , 2);
    tim_units_act{d,k} = round(((individual_travel_times) / TU) , 2);
    tim_units_slow{d,k} = round(((individual_travel_times) / TU) * 1.2 , 2);

temp = [];
end
end

time_dep_ear = cell(length(D),length(K)); 
time_dep_lat = cell(length(D),length(K)); 

for d = D
for k = K

%%%%% TIMES OF DEPARTURE 
% convert to units
% Some resolution is lost here
% We default to the safe side.  
time_dep_ear{d,k} = Itin{d,k}.time_departure_earliest - time_at_dcs ;
time_dep_lat{d,k} = Itin{d,k}.time_departure_latest + time_at_dcs; % removed extra time here
% time_dep_lat{d,k} = Itin{d,k}.time_departure_earliest + minutes(30) + time_at_dcs; 

% convert to units
[~,time_dep_ear_units{d,k}] = ismember(interp1(TIMES,TIMES,time_dep_ear{d,k},'previous'),TIMES);
[~,time_dep_lat_units{d,k}] = ismember(interp1(TIMES,TIMES,time_dep_lat{d,k},'next'),TIMES);

%%%%% TIMES OF ARRIVALS
time_arr_ear{d,k} = Itin{d,k}.time_arrival_earliest - time_at_dcs ;
time_arr_lat{d,k} = Itin{d,k}.time_arrival_latest + time_at_dcs;

% convert to units
[~,time_arr_ear_units{d,k}] = ismember(interp1(TIMES,TIMES,time_arr_ear{d,k},'previous'),TIMES);
[~,time_arr_lat_units{d,k}]=  ismember(interp1(TIMES,TIMES,time_arr_lat{d,k},'next'),TIMES);

% temp = [temp,time_dep_lat{d,k}-
%% Decision Variables for actual times of arrival/departure, considering charging and windows
%REPLACED IN MATRIX FORMULATION
%%%%% Initialize variables of actual departure-arrival times (19-9-23)
% time_dep_act_units{d,k} = sdpvar(length(Itin{d,k}.time_departure_earliest),1,'full');
% time_arr_act_units{d,k} = sdpvar(length(Itin{d,k}.time_departure_earliest),1,'full');

end
end

% clear("data_itin")

    % vec = zeros(length(ori{d,k}),1);

% Retrieve the distance to be performed by each truck and trip leg    
% for it = 1:length(ori{d,k})
%     vec(it) = dm(ori{d,k}(it),des{d,k}(it));
% end

%% Own implementation with travel distance matrix.
% Watch out here with the time constraints from the actual times. 
% Unloading times are useful. 

% % Write the distances vector to each truck k
%     Dis{d,k} = vec;
% % Write the times vector to each truck k    
%     tim{d,k} = cumsum(Dis{d,k}/vel(k)); % fraction of hour.
% % time of travel for each trip leg    (18-9-23)
%     tim_units{d,k} = round( (Dis{d,k}/80) / TU , 2);

% The problem here is that the times calculates with our distance matrix
% were shown to differ significantly with the times provided by AH...
