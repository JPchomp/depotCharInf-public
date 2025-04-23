%% vehicle_setup.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Truck Characteristics

% Vehicle consumption (kWh per km) 
% c_c = ones(length(data_vehs.cons_per_km),1)* 0.0276; % currently we have
% actual data pre calculated

% Battery capacity of each vehicle (initial)
batt_cap = data_vehs.battery;

% Max power capacity by vehicle
pow_cap = (data_vehs.type=="rigid")*66;
pow_cap = pow_cap + (data_vehs.type=="euro")*260;
pow_cap = pow_cap + (data_vehs.type=="city")*260;

% Decision variable to have extra battery capacity
clear batt_dv;
l_batt = length(data_vehs.battery);
batt_dv = sdpvar(l_batt,1);

vel = data_vehs.av_speed; % also unused

% TODO: the relation consumption per km to battery is determinant
% perform statistical analyses of the miles per leg and 
% requirements overall


energy_density = 1/(0.35); % kg/kWh (eq. to 300Wh/kg)


batt_cap = data_vehs.battery(1:length(K));

batt_caps_choices = [210,315,420,525];
batt_caps_choices = batt_caps_choices(2);

batt_caps_prices = [285000,325000,370000,425000];
batt_caps_prices = batt_caps_prices(1:length(batt_caps_choices ));