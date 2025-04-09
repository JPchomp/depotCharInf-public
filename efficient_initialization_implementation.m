init_time = tic;

%Initial definitions:

lmax = zeros(max(K),1);
lnum = zeros(length(D),length(K));



for d = D
    for k = K
       lmax(k) = lmax(k) + numel(L{d,k});
       lnum(d,k) = numel(L{d,k});
    end
end

maxL = max(lmax(K)); % for indexing, up to maximum index.
% lmax(k) has the individual maximum leg

paramsExperiments.maxL = maxL;
% E_charge goes up to maxL+1, to allwo for the final charging stage.
maxLplus = maxL + 1; % To add the e_charge at the end.

effs = data_char.efficiency;

%% Variables and Parameters for battery sizes
batt_caps = repmat(batt_caps_choices,length(K),1);

% Decision variable which truck which battery.
W = binvar(length(K),length(batt_caps_choices),'full');

% Actual battery used
B = sum(W .* batt_caps,2);

if batt_discrete_choice == 0

% If optimization does not include fleet sizing
B = data_vehs.battery;

else

end


% if power_continuous_choice == 1

%% Variables and Parameters for Max Power Accepted by trucks (Not added yet)
% conn_cap = data_vehs.battery(1:length(K));
% 
% conn_cap_choices = [50,150,300,500,800,1200]; 
% 
% conn_caps = repmat(conn_cap_choices,length(K),1);
% 
% conn_caps_prices = conn_cap_choices; % I have no information on the extra cost of this
% 
% conn_caps_prices = batt_caps_prices(1:length(conn_caps_choices));
% 
% % Max power connection accepted
% G = binvar(length(K),length(conn_cap_choices),'full');
% 
% Q = sum(W .* conn_cap_choices,2);


%% Create matrix with t dep at each index and tarr

tde = zeros(length(K),maxL);
tdl = tde;
tae = tde;
tal = tde;
dayIncidence = tde;
legIncidence = tde;
ttl= tde;
ttu = tde;
cc = tde;
loc = zeros(length(K),maxLplus);

tt = tde;

ei_base = tde;
ej_base = tde;

% decision variable how much charge for each truck at each l
% e_charge = sdpvar(length(K),max(lmax),'full');
% decision variable how much charge for each truck at each l
e_charge = sdpvar(length(K),maxLplus,'full');

% decision variable when to actually depart
tda = sdpvar(length(K),max(lmax),'full');

% decision variable when to actually arrive
taa = sdpvar(length(K),max(lmax),'full');

dayChange = tde;

counter = zeros(length(K),1);


for k = K
    for d = D

        for l = L{d,k}'

            counter(k) = counter(k) + 1; % l total

            tde(k,counter(k)) = time_dep_ear_units{d,k}(l);
            tdl(k,counter(k)) = time_dep_lat_units{d,k}(l);

            tae(k,counter(k)) = time_arr_ear_units{d,k}(l);
            tal(k,counter(k)) = time_arr_lat_units{d,k}(l);

            ttl(k,counter(k)) = Itin{d,k}.loading_time(l)/(60*TU);
            ttu(k,counter(k)) = Itin{d,k}.unloading_time(l)/(60*TU);
            tt(k,counter(k)) = Itin{d,k}.TransportTime(l)/(60*TU);

            cc(k,counter(k)) = Itin{d,k}.total_consumption_leg_avg(l);

            loc(k,counter(k)) = Itin{d,k}.origin(l);

            dayIncidence(k,counter(k)) = d;
            legIncidence(k,counter(k)) = l;

            if d>1
                if counter(k)>2
                    if dayIncidence(k,counter(k)-1) < dayIncidence(k,counter(k))
                        dayChange(k,counter(k)) = 1;
                    end
                end
            end
        end

    end
end

% Complete those k,l combinations that do not exist as staying at home 
loc(loc==0) = 1;


%% Night Times Indicator Matrix

% Extract hours from the TIMES vector
hoursInTimes = hour(TIMES);

% Initialize the vector with zeros
timeFlags = zeros(size(TIMES));

% Set value to 1 for times between 12 AM (0 hours) and 6 AM (6 hours)

timeFlags(hoursInTimes >= 21 & hoursInTimes < 24) = 1;

timeFlags(hoursInTimes >= 0 & hoursInTimes < 6) = 1;

% Night
NightIND = repmat(timeFlags',1, length(K));
DayIND = 1-NightIND;

% Viewing time per leg
% a = squeeze(T_SUP(:,1,:));
% imagesc(a)
%% Maximum time extra

% Alternative using the matrices t**

Y_SUP = zeros(length(K),length(T_SIM));
X_LOC = zeros(length(K),length(T_SIM));
T_SUP = zeros(length(T), length(K), maxLplus );
X_LOC_B = zeros(length(T), length(K), maxLplus );

for k = K

% indicatorMaxItinNum = lmax(k) == maxL;

for l = 1:maxLplus

    if l == 1

        t_min = tts;
        t_max = tts + hours(tdl(k,l))*TU + hours(upperLimTimeExtraUnits * TU); % 

    elseif l>lmax(k) % aded this to allow charging on all subsequent

        t_min = tts + hours(tae(k,lmax(k))) * TU; %- hours(upperLimTimeExtraUnits * TU); % changed this for earliest not latest.
        t_max = max(TIMES)+ hours(TU);    % I add here an extra slot, so that we get the last time included in Y_SUP;

    else

        t_min = tts + hours(tae(k,l-1)) * TU; % - hours(upperLimTimeExtraUnits * TU);
        t_max = tts + hours(tdl(k,l)) * TU + hours(upperLimTimeExtraUnits * TU);

    end

    T_SUB = TIMES(TIMES < t_max & TIMES >= t_min); % Observe strict inequality here
    [~,T_SUB_ITER] = ismember(T_SUB,TIMES);

    % These guys should also consider the possible extra given by ctime and
    % all that!!
    Y_SUP(k,T_SUB_ITER) = 1;
    T_SUP(T_SUB_ITER,k,l) = 1; % Same as above, but also with the LEG dimension.
    X_LOC_B(T_SUB_ITER,k,l) = loc(k,l);

% before assigning check whats already there...TODO
idxReplace = (X_LOC(k,T_SUB_ITER)~=1)  ; % replaces only if zero or DC, conservative. Now replace only if not DC
% We take care of the overlap issue if we denote which are charging
% locations and which are not. If these are terminal we are fine..
% otherwise, no.

% Keep only indeces that dont affect DC
T_SUB_ITER_NEW = T_SUB_ITER(idxReplace);
T_SUB_ITER_NEW = T_SUB_ITER;
% feel free to change those that are not dc..

if l<=lmax(k)
X_LOC(k,T_SUB_ITER_NEW) = loc(k,l);
else
X_LOC(k,T_SUB_ITER_NEW) = 1;
end


end

    % if indicatorMaxItinNum == 1 % If we reached the final itin.
    % 
    % t_min = tts + hours(tal(k,lmax(k)))*TU;
    % t_max = max(TIMES)+ hours(TU); % I add here an extra slot, so that we get the last time included in Y_SUP;
    % 
    % T_SUB = TIMES(TIMES < t_max & TIMES > t_min); % Observe strict inequality here
    % [~,T_SUB_ITER] = ismember(T_SUB,TIMES);
    % 
    % Y_SUP(k,T_SUB_ITER) = 1;
    % T_SUP(T_SUB_ITER,k,lmax(k)) = 1;
    % X_LOC(k,T_SUB_ITER) = 1;
    % 
    % end


end


% WATCH OUT AS THIS IS EXTREMELY GENEROUS FOR X_LOC AND CAUSES ISSUES WITH
% OUTSIDE OF DC!!!!
% X_LOC(X_LOC<1) = 1;

%% 

ei = sdpvar(length(K),max(lmax),'full');
ej = sdpvar(length(K),max(lmax),'full');
DV_ICE = sdpvar(length(K),max(lmax),'full');

Y = binvar(length(TIMES),length(R),length(K),'full');
Y_L = binvar(length(TIMES),length(R),length(K),maxL,'full');
P = sdpvar(length(TIMES),length(K),'full');
P_C = sdpvar(length(TIMES),length(K),'full');


X = sdpvar(length(I),length(R),'full');

%% Switch for pre determined vs non determined infra (rule/norule)
switch choice
    case 'opt'
        disp('Solving with NO Warmstart');
        
    case 'rule'
        disp('Solving with Rule-based solution');
        
        % am running X_RUL
        path3 = "./data/X_RULB.csv";
        X = readmatrix(path3)';
        % X(1,:) = [5,5,5,5,5]*2; Add here the values instead.
        
    otherwise
        disp('Invalid choice. Please select "opt-no-warm", or "rule".');
end

%%
init_time = toc(init_time);
fprintf("Optimization Structures Initialization Time: %d",init_time)
paramsDiagnostics.initTime = init_time;
