%% Initialization of Optimization Indicator matrices and others.

run efficient_initialization_implementation.m


%% Energy constraints for each trip leg

ticEnergyCtrts = tic();

C_TRIP_ENERGY = [];
for k = K  % Loop through trucks
    for l = 2:maxL  
        
        % Starting Condition (Full Battery)
        if l-1 == 1 % Start only
        C_TRIP_ENERGY = [C_TRIP_ENERGY,[ (ei(k,l-1) ==  StartingBattery * B(k) )]:...
        ['ei is B ' num2str(k) 'Leg#: ' num2str(l)] ];
        else
        end

        C_TRIP_ENERGY = [C_TRIP_ENERGY,[ (ei(k,l-1) + e_charge(k,l-1) - cc(k,l-1)*(1-DV_ICE(k,l-1)) == ej(k,l-1) ) ]:...
            ['Ei(l-1) == ej(l-1) ' num2str(k) 'Leg#: ' num2str(l)] ];
          
        C_TRIP_ENERGY = [C_TRIP_ENERGY,[ (ej(k,l-1)  == ei(k,l) )]:... 
        ['ej+ech==ei ' num2str(k) 'Leg#: ' num2str(l)] ];

        % Periodicity Constraints (1/2 Battery Min)

        if l == maxL % Ending up to end of sim, going one step forward now

        C_TRIP_ENERGY = [C_TRIP_ENERGY,[ (ei(k,l) + e_charge(k,l) - cc(k,l)*(1-DV_ICE(k,l)) == ej(k,l) ) ]:...
            ['Ei(l-1) == ej(l-1) ' num2str(k) 'Leg#: ' num2str(l)] ];

        C_TRIP_ENERGY = [C_TRIP_ENERGY,[ (ej(k,l) + e_charge(k,l+1) >= EndingBattery * B(k) )]:... % final SOC + e_ch(k,lmax)
        ['Periodicity Constraint ' num2str(k) ] ];

        end

    end

 % Safety Limits for any state of charge
 % If this apply to all k, no loop is needed here...TODO

 C_TRIP_ENERGY = [C_TRIP_ENERGY, [(E_min*B(k) <= ej(k,:)' <= E_sup*B(k))]:...
        ['0<ej<B ' num2str(k) ] ];

 C_TRIP_ENERGY = [C_TRIP_ENERGY, [(E_min*B(k) <= ei(k,:)'+ e_charge(k,1:maxL)' <= E_sup*B(k))]:...
        ['0<ei+ech<B ' num2str(k) ] ];

  C_TRIP_ENERGY = [C_TRIP_ENERGY, [(E_min*B(k) <= ei(k,:)' <= E_sup*B(k))]:...
        ['0<ei<B ' num2str(k) ] ];

% e_charge_final would never be more than needed...


% Limits for fast charging maximum charge at nicht and during day
% using the indicator matrices for day change: dayChange

dayChangeInverted = 1 - dayChange;

C_TRIP_ENERGY = [C_TRIP_ENERGY, [(dayChangeInverted(k,:)' .* ei(k,:)' <= E_MaxFastCharging*B(k))]:...
        ['ei<B*FClimit ' num2str(k)] ];

end
ticEnergyCtrts = toc(ticEnergyCtrts);
paramsDiagnostics.timeenergyCtrts = ticEnergyCtrts;

%% Energy Charged Constraint to maintain trip-leg constraints  

% This indicates if a time t can be used by a truck k, during a leg l to
% charge based on t arr and t dep act. Z = 1 means you use that t to
% charge.

% Added + 1 on L to account for last 29-5-24: TODO 
% Means adding also on e_charge and P_real for the last bit
Z_time = binvar(length(T), length(K), maxLplus,'full');

% This will be used in the Big M formulation
% Defines at which intervals I enforce
% Z_TIME_WEIGHTED  = Z_time .* T_SUP;

% Actual power to be delivered (Has leg as a dimension)
P_Real = sdpvar(length(T), length(K), maxLplus,'full');

% % I obtain the maximum available power at each k,l,t (expanded Power w/no leg)
% P_rep = repmat(P,1,1,maxL); ERROR!

% PossiblePower = P_Real.*T_SUP; %size TxKxL, uses the power P per vehicle
% and time, but qis expanded on L and multiplieed by zero if unavialable
% for truck k at l at t. 

M = max(T); % Big M is compared to T in the constraints, so this should be enough for Times
M = 5000;


%% Charged Energy Limited by Z_time blocks
ticEnergyChargedCtrts = tic();

C_CHARGED_ENERGY = [];

% If Z = 1, unrestricted P, otherwise zero power. 
% Z will also be restricted by tarr and tdep
C_CHARGED_ENERGY = [C_CHARGED_ENERGY, (0 <= P_Real <= Z_time.*M.*T_SUP ) :...
['Possible Power leq Big-M available and T_SUP'] ];


% % P_real is the actual charged power at each vehicle at each leg, limited
% % by the possible power, which is limited as per above.
% C_CHARGED_ENERGY = [C_CHARGED_ENERGY, ( 0 <= P_Real <= PossiblePower ) :...
% ['Real Power leq Than Possible power'] ];

% Energy charged at a specific k,l combination. Can be less that the
% summation of P at feasible times.
C_CHARGED_ENERGY = [C_CHARGED_ENERGY, ( e_charge == TU.*squeeze(sum(P_Real,1))  ) :...
['e_charged is less than the real power'] ];
C_CHARGED_ENERGY = [C_CHARGED_ENERGY, ( 0 <= e_charge  ) :...
['e_charged is less than the real power'] ];

% Compatibilize by l with P
C_CHARGED_ENERGY = [C_CHARGED_ENERGY, (sum(P_Real,3) == P ) :...
['Possible Power per Leg leq Power By Choices'] ];

% Compatibilize by l with P
C_CHARGED_ENERGY = [C_CHARGED_ENERGY, (0 <= sum(P_Real,3) ) :...
['Possible Power per Leg leq Power By Choices'] ];

%% 27-7-2024 limit on max charging power

% Extending it to All ts, 
% pow_cap_rep = repmat(pow_cap,1,length(T),maxLplus);
% pow_cap_rep = permute(pow_cap_rep,[2,1,3]);
% 
% C_CHARGED_ENERGY = [C_CHARGED_ENERGY, (0 <= P_Real <= pow_cap_rep ) :...
% ['Possible Power leq Truck Max Capacity'] ];

%% 
% auxiliary matrices for dimensional agreement
repeated_T = repmat(T',1,length(K),maxL);

repeated_tda = repmat(tda,1,1,length(T));
repeated_tda  = permute(repeated_tda ,[3 1 2])  ;

repeated_taa = repmat(taa,1,1,length(T));
repeated_taa  = permute(repeated_taa ,[3 1 2])  ;

% Time of departure for t,k,l should be higher than any time that is on
% same span...
C_CHARGED_ENERGY_2 = [];

C_CHARGED_ENERGY_2 = [C_CHARGED_ENERGY_2, ( repeated_T <= repeated_tda + M *( 1 - Z_time(:,:,1:maxL) )  ) :...
['Auxiliary for charging interval higher bound'] ];

% Changed here where the decision is
C_CHARGED_ENERGY_2 = [C_CHARGED_ENERGY_2, ( repeated_T(:,:,2:(maxL)) >= repeated_taa(:,:,1:(maxL-1)) - M*( 1 - Z_time(:,:,2:(maxL))) ) :...
['Auxiliary for charging interval lower bound'] ];

% I dont go into maxLplus
ticEnergyChargedCtrts = toc(ticEnergyChargedCtrts);
paramsDiagnostics.timeEnergyChargedCtrts = ticEnergyChargedCtrts;

%% Max power dispensed is dependent on charger selection

ticPowerCtrts = tic();

C_POWER = [];

% Auxiliary for multiplication
char_pows_rep = repmat(c_r, length(TIMES),1, length(K) );
char_effs_rep = repmat((1./effs'), length(TIMES),1, length(K) );

% Time of departure after last time of charge, consider sum across al
% chargers for each truck

Y_CHOICE_TIMES_POWERS = Y.*char_pows_rep;

Y_weighted_power = squeeze(sum(Y_CHOICE_TIMES_POWERS,2));

C_POWER = [C_POWER; (0 <= P <= Y_weighted_power)  :...
        ['Power Dispensed LEQ than Charger Choice * Power Max']];


% Add hard limit 
% C_POWER = [C_POWER; (0 <= P <= Y_weighted_power)  :...
        % ['Power Dispensed LEQ than Charger Choice * Power Max']];


% Add here the limitation by truck max charging power

% truck_pows_rep = repmat(t_r, length(TIMES),length(R), 1 );
% Y_CHOICE_TIMES_Trucks_POWERS = Y.*trucks_pows_rep;
%so on so forth

pow_times_effs = char_pows_rep.*char_effs_rep;
Y_temp_weight = Y.*pow_times_effs;
Y_weighted_power_eff = squeeze(sum(Y_temp_weight,2));

%This should be replaced by just P/eff<=P_C
C_POWER = [C_POWER; (P_C == Y_weighted_power_eff)  :...
        ['Power Actually Consumped LEQ than Charger Choice * Power Max * 1/eff']];

if nightChargingLimits == 1

P_NightWeighted = P.*NightIND;

C_POWER = [C_POWER; (0 <= P_NightWeighted <= NightChargingMaxP)  :...
        ['Power Dispensed LEQ than Night Charging Max Power']];

end

ticPowerCtrts = toc(ticPowerCtrts);
paramsDiagnostics.ticPowerCtrts = ticPowerCtrts;

%% must initialize first row of the times of arrival as 0000

ticTimeCtrts = tic();

% disp("Running BET Time Constraints")

% This is just to prevent those legs that are zero from producing
% infeasible in the case you check t(l+1) vs t(l)
IND_K_L = tae>0;

% One to one checks
C_TIMES_BETS = [];

tea = sdpvar(length(K),maxL,'full');
ted = sdpvar(length(K),maxL,'full');

% Tea and ted are extra time allowed in units
C_TIMES_TE = [upperLimTimeExtra >= tea >= 0];
C_TIMES_TE = [C_TIMES_TE ; upperLimTimeExtra >= ted >= 0];
C_TIMES_TE = [C_TIMES_TE ; taa >= 0];
C_TIMES_TE = [C_TIMES_TE ; tda >= 0];

% We multiply all these to prevent taa and tda being limited by zero in
% non-incumbent cases

C_TIMES_BETS = [C_TIMES_BETS ; (IND_K_L.*taa<= IND_K_L.*(tal+tea))  :... % adds leeway here
['Time Arrival Actual <= TAL BET#: ' num2str(k) ]];

C_TIMES_BETS = [C_TIMES_BETS ; (IND_K_L.*taa >= IND_K_L.*(tae-tea))  :... % adds leeway here
['Time Arrival Actual >= TAE BET#: ' num2str(k) ]];

C_TIMES_BETS = [C_TIMES_BETS ; (IND_K_L.*tda >= IND_K_L.*(tde-ted))  :... % adds leeway here
['Time Departure Actual >= TDE BET#: ' num2str(k) ' Leg: ' num2str(l)]];

C_TIMES_BETS = [C_TIMES_BETS ; (IND_K_L.*tda <= IND_K_L.*(tdl+ted))  :... % adds leeway here
['Time Departure Actual <= TDE BET#: ' num2str(k) ' Leg: ' num2str(l)]];


% On the relevant time blocks
% Actual departure time should be higher than previous arrival plus

% unloading/loading
C_TIMES_BETS = [C_TIMES_BETS ; ( IND_K_L(:,2:maxL) .* tda(:,2:maxL) >= IND_K_L(:,2:maxL) .* (taa(:,1:maxL-1) + ttl(:,1:maxL-1) + ttu(:,1:maxL-1)))  :...
['Time Departure Actual >= TAA + TTU/L ' ]];


% On the relevant time blocks
% Actual arrival time should be higher than departure plus travel time
C_TIMES_BETS = [C_TIMES_BETS ; ( IND_K_L.*taa >= IND_K_L.*(tda + tt) ):...
['Time Arrival Actual >= TDEPACT + TT '  ]];


ticTimeCtrts = toc(ticTimeCtrts);
paramsDiagnostics.ticTimeCtrts = ticTimeCtrts;
% disp("Finished Running BET Time Constraints")

%% Constraint on Number of Chargers chosen <= 1

ticChoiceCtrts = tic();

C_CHOICE = [];

ChargeDecision = squeeze(sum(Y,2)); % sum across chargers

% Isnt this just easier to implement over all
C_CHOICE = [C_CHOICE, ( ChargeDecision <= Y_SUP') : ... % This already limits WHEN a truck may charge. 
    ['Constraint on Charging Choice Decision <= Y_SUP ']];

%%

C_CHOICE_2 = [];

ChargeDecisionZ = squeeze(sum(Z_time,3));  %Sum across all legs,

C_CHOICE_2 = [C_CHOICE_2, ( ChargeDecisionZ <= ChargeDecision) : ... % This ensures Z is choosing only 1 slot per l. 
    ['Constraint on Z Charging Variable <= Y (Suspect unnecessary)']];

ticChoiceCtrts = toc(ticChoiceCtrts);
paramsDiagnostics.ticChoiceCtrts = ticChoiceCtrts;

%% Charger Constraints Per Location

ticChargerNumberCtrts = tic();

C_CHARGERS = [];
%make sure for each time t, the total number of charging decisions is less
%than or equal to the number of chargers type r at each location i
% X_LOC is KxT and indicates the location of each truck at t
% for t= T


% First I cannot have charging while clearly traveling.
% this guy will detect k,t combinations with no location
% the implementation needs to cover ALL possible times...
IND_TRAVEL = X_LOC<1;
IND_TRAVEL_REP = repmat(IND_TRAVEL', 1, 1, length(R)); % this is TxKxR
IND_TRAVEL_REP = permute(IND_TRAVEL_REP, [1, 3, 2]); % Permute to get T x R x K
% Weight by actual presence in the location i
Y_TEMP = Y.*IND_TRAVEL_REP;
TotalChargeChoicesAtLocation = squeeze(sum(Y_TEMP,3));
ChargersZeroLimitTravel = zeros(length(T),length(R)) ;
% Sum across vehicles, for each time Interval
C_CHARGERS = [ C_CHARGERS, ( TotalChargeChoicesAtLocation <= ChargersZeroLimitTravel  ) : ...
['Limit Charge Choice to Zero while travelling (should be superfluous)' ]];


if choice == 'opt'

if CDC == 1 %%%%%%%%%%%%%%%%%%%%%%%%%%% Only DC Chargers Allowed

    for i = I

        IND_LOC = X_LOC == i;

        IND_LOC_REP = repmat(IND_LOC', 1, 1, length(R)); % this is T x K x R
        IND_LOC_REP = permute(IND_LOC_REP, [1, 3, 2]);   % Permute to get T x R x K
       
        % Weight by actual presence in the location i
        Y_TEMP = Y.*IND_LOC_REP;
        
        TotalChargeChoicesAtLocation = squeeze(sum(Y_TEMP,3));

        RepeatedChargersAtLoc = repmat(X(i,:),length(T),1);
    
        ChargersUpperLimit = repmat(50,length(T),length(R)) ;

        if i == 1
        % Sum across vehicles, for each time Interval
        C_CHARGERS = [ C_CHARGERS, ( TotalChargeChoicesAtLocation <= RepeatedChargersAtLoc <= ChargersUpperLimit ) : ...
        ['(CDC == 1) Constraint on Number of Chargers Per Location #' num2str(i) ]];

        else

         % All other locations set to zero maximum charger number
        C_CHARGERS = [ C_CHARGERS, ( TotalChargeChoicesAtLocation <= RepeatedChargersAtLoc <= zeros(length(T),length(R)) ) : ...
        ['(CDC == 1) Constraint on Number of Chargers Per Location #' num2str(i) ]];
        end
       
        

    end


else        %%%%%%%%%%%%%%%%%%%%%%%%%%% CDC == 0, chargers outside DC Allowed

for i = I
    % Define the relevant charging times for each k, for each i
    % relevantY = Y_SUP*IND_LOC;

        IND_LOC = X_LOC == i;

        IND_LOC_REP = repmat(IND_LOC', 1, 1, length(R)); % this is TxKxR
        IND_LOC_REP = permute(IND_LOC_REP, [1, 3, 2]); % Permute to get T x R x K
       
        % Weight by actual presence in the location i
        Y_TEMP = Y.*IND_LOC_REP;
    
        TotalChargeChoicesAtLocation = squeeze(sum(Y_TEMP,3));

        RepeatedChargersAtLoc = repmat(X(i,:),length(T),1);
    
        ChargersUpperLimit = repmat(50,length(T),length(R)) ;

        % Sum across vehicles, for each time Interval
        C_CHARGERS = [ C_CHARGERS, ( TotalChargeChoicesAtLocation <= RepeatedChargersAtLoc <= ChargersUpperLimit ) : ...
        ['(CDC == 0) Constraint on Number of Chargers Per Location #: ' num2str(i) ]];

end

end         %%%%%%%%%%%%%%%%%%%%%%%%%%% End CDC Check

else        %%%%%%%%%%%%%%%%%%%%%%%%%%% choice = 'rule'

for i = I
    % Define the relevant charging times for each k, for each i
    % relevantY = Y_SUP*IND_LOC;

        IND_LOC = X_LOC == i;

        IND_LOC_REP = repmat(IND_LOC', 1, 1, length(R)); % this is TxKxR
        IND_LOC_REP = permute(IND_LOC_REP, [1, 3, 2]); % Permute to get T x R x K
       
        % Weight by actual presence in the location i
        Y_TEMP = Y.*IND_LOC_REP;
    
        TotalChargeChoicesAtLocation = squeeze(sum(Y_TEMP,3));

if sum(sum(IND_LOC))>0 % If these are all zero, then the inequality is trivial, and we dont parse it.

        RepeatedChargersAtLoc = repmat(X(i,:),length(T),1);
    
        % Sum across vehicles, for each time Interval
        C_CHARGERS = [ C_CHARGERS, ( TotalChargeChoicesAtLocation <= RepeatedChargersAtLoc ) : ...
        ['Rule Constraint on Number of Chargers Per Location #: ' num2str(i) ]];
else



end


end

end %% End Choice If



if charging_infra_night == 1
        C_CHARGERS = [ C_CHARGERS, ( X(1,1) >= length(K) ) : ...
        ['Force to have slow powered chargers equal to truck number']];
end

ticChargerNumberCtrts = toc(ticChargerNumberCtrts);
paramsDiagnostics.ticChargerNumberCtrts = ticChargerNumberCtrts;


%% Practical Charging Constraint
% to avoid switching on off between trucks
% TODO: When there are multiple chargers of a specific kind, this
% limitation should be relaxed... u-v related to value(X)?

% Also the latter constraint induces sparse charging for every truck,
% which should not be encouraged.
ticPracticalChargingCtrts = tic();



C_CHARGE_PRACTICAL = [];
% Make sure the decisions of charging on all R aggregated are less than
% Y_sup, for each relevant time span

u = sdpvar(length(TIMES)-1,1,length(K),'full'); % 1 used to be length(R)
v = sdpvar(length(TIMES)-1,1,length(K),'full');

rep_u = repmat(u,1,length(R),1);
rep_v = repmat(v,1,length(R),1);
       
C_CHARGE_PRACTICAL= [C_CHARGE_PRACTICAL, ( rep_v <= Y(1:length(TIMES)-1, : , :) - Y(2:length(TIMES) , : , :) <= rep_u ) : ...
    ['Constraint on Practical Charging v<=Y-Y<=u']];

% This forces to either be zero or one
C_CHARGE_PRACTICAL= [C_CHARGE_PRACTICAL, (0 <= u-v <= 1)  : ...
['Constraint on Practical Charging u-v<=1']];

% w = sdpvar(length(TIMES)-1,length(R),length(K)-1,"full");
% q = sdpvar(length(TIMES)-1,length(R),length(K)-1,"full");
% 
% for k = K
%     subK = K(K~=k); % without K
%     Y_CURRENT_DECISION = repmat(Y(1:length(TIMES)-1, : , k),1,1,length(subK));
%     C_CHARGE_PRACTICAL = [C_CHARGE_PRACTICAL, ( w <=  Y_CURRENT_DECISION - Y(2:length(TIMES) , : , subK) <= q ) : ...
%     ['Constraint on Practical Charging v<=Y-Y<=u']];
% end
% 
% % This forces to either be zero or one
% C_CHARGE_PRACTICAL= [C_CHARGE_PRACTICAL, (0 <= q-w <= 1)  : ...
% ['Constraint on Practical Charging u-v<=1']];
ticPracticalChargingCtrts = toc(ticPracticalChargingCtrts);
paramsDiagnostics.ticPracticalChargingCtrts = ticPracticalChargingCtrts;

%% Peak Constraints
ticPeakCtrts = tic();

C_PEAK = [];

% C peak for day for location
cp = sdpvar(length(D),length(I),'full');

% Obtain C Peak for all simulation time for location
cp_max = sdpvar(length(I),1,'full');


    dayIncidenceTime = zeros(1,length(T));
    
    startDate = TIMES(1);
    tday = startDate + days(0:(length(D)-1)); % Creates D dates starting from startDate
    
    % Loop through each day to determine the incidence
    for d = 1:(length(D)-1)
        % Find indices where TIMES is on day d
        indicesOnDay = TIMES >= tday(d) & TIMES < tday(d+1);
        dayIncidenceTime(indicesOnDay) = d;
    end
    
    % Handle the last day separately if TIMES might extend beyond the last tday
    % Assuming TIMES can extend beyond the last defined day in tday
    if any(TIMES >= tday(max(D)))
        dayIncidenceTime(TIMES >= tday(max(D))) = max(D);
    end


for i = I

IND_LOC = (X_LOC == i);

for d = D

   % Indicate wether day is d
   IND_DAY = (dayIncidenceTime == d);
   % repeat for dimension coherence and multiply by location indicator
   IND_D_L = IND_LOC.*repmat(IND_DAY,length(K),1);

   P_C_W = P_C .* IND_D_L';

   P_LOCATION_SUMMED_K = squeeze(sum(P_C_W ,2));

   C_PEAK = [C_PEAK, (0 <= P_LOCATION_SUMMED_K <= repmat(cp(d,i),length(T),1) ) : ...
       ['Constraint on Peak Charging @ Location #' num2str(i) ' Day#' num2str(d)]];

end

   C_PEAK = [C_PEAK, (cp(:,i) <= repmat(cp_max(i),length(D),1) ) : ...
       ['Constraint on Peak Max >= peak day @ Location #' num2str(i)]];

end

ticPeakCtrts = toc(ticPeakCtrts);
paramsDiagnostics.ticPeakCtrts = ticPeakCtrts;

%% Battery restriction to one choice
C_BATT = [];
C_BATT =  (squeeze(sum(W,2))<= 1) : ...
['Constraint on Choice = 1 for battery Size: '];
% 
C_BATT = [];
%% Constraint on DV_ICE for continuous formulation
C_DVICE = (0 <= DV_ICE <= 1) : ...
['Constraint on Reduction of Consumption for specific k,l '];


%% Build Objective
ticObj = tic();

% Peak costs 
c_peak = sum(cp_max(1))*peak_per_location*pf * 7/length(D);

% Infrastructure Costs
c_inf = sum(X*(data_char.cost.*prorrate_infra)) * 7/length(D);

% Charging Costs
c_charging = sum(sum(P_C,2) .* PRICES .* TU) * pM * 7/length(D); % (1./effs)

% Battery Choices Costs
% c_batts = sum(sum(W.*repmat(batt_caps_prices,length(K),1),2))*prorrate_vehs;
c_batts = 0;

% DV_ICE Cost (High)
c_ICE = sum(sum(DV_ICE))*cICE;

% Time extra
ctea = sum(sum(tea))*c_times;
cted = sum(sum(ted))*c_times;

% compile objective
obj =   c_peak +...
        c_inf + ...
        c_charging +...        % c_batts +...
        c_ICE +...
        ctea + cted;


ticObj = toc(ticObj);
paramsDiagnostics.ticObj = ticObj;

%% Solve

art_cons=[];
% art_cons = [(-1000 <= sum(c_peak )  <= 1000)];
% art_cons = [art_cons,(-1000 <=   c_inf  <= 1000)];
% art_cons = [art_cons,(-1000 <=  c_charging  <= 5000)];
% art_cons = [art_cons,(-1000 <=  c_batts  <= 5000)];
% art_cons = [art_cons,(-1000 <=  c_ICE  <= 999999)];

% Initialize the options structure for YALMIP
options = sdpsettings('solver', 'gurobi');

% Set Gurobi-specific options
options.verbose = 1;
GAP = MIPGAP;
options.solver ='gurobi';
options.gurobi.MIPFocus=1;
options.gurobi.MIPGap=GAP;
options.gurobi.MIPGapAbs=GAP;
options.gurobi.TuneTimeLimit = TimeLimitOpt;
options.gurobi.TimeLimit = TimeLimit;
options.savesolverinput = 1;
options.savesolveroutput = 1;

% Combine constraints
constraints = [...
    C_CHARGERS...
    ,C_CHOICE...
    ,C_CHOICE_2...
    ,C_POWER...
    ,C_CHARGED_ENERGY...
    ,C_CHARGED_ENERGY_2... % Z restrictions by tarr etc
    ,C_PEAK...
    ,C_TIMES_BETS...
    % ,C_TIMES_BETS_EXTRA...
    ,C_TIMES_TE...
    ,C_CHARGE_PRACTICAL...
    ,C_TRIP_ENERGY...
    ,C_BATT...
    ,C_DVICE...
    ,art_cons...
    ]; 

% Solve the optimization problem
[sol] = optimize(constraints, obj, options);
%%
% Check the result
if sol.problem == 1
    disp('Infeasible problem');

% zvec = zeros(1,length(variableNames)-3);
% 
% newRows = table(time_at,pf,length(K),[zvec],'VariableNames', variableNames);
% 
% Add the new rows to the existing tableTim

parametersRow = table(E_MaxFastCharging, NightChargingMaxP, StartingBattery,EndingBattery,c_times,E_min,E_sup,MIPGAP);
parametersTable = [parametersTable ; parametersRow];

resultsRow = table(time_at_dcs, pf, K_EXPERIMENT ,0,0,0,0,0);
resultsTable = [resultsTable; resultsRow];

costsRow = table(0,0,0,0,0,0);
costsTable = [costsTable ; costsRow ];

else

    % Solver has found an optimal solution
    disp('Solution found');

% Create a table for the new rows
variableNames = {'Price Mult','Time Slack', 'Peak Factor', 'NTrucks', '60', '180', '360' , '720', '1080' , 'peakCons','peakCosts', 'energyCosts', 'infra_costs','DV_ICE','ctea','cted','c_batts','ObjValue','Gap'};
newRows = table(pM,time_at,pf,length(K),value(X(1,1)),value(X(1,2)),value(X(1,3)),value(X(1,4)),value(X(1,5)),...
    value(cp_max(1)),value(cp_max(1)*peak_per_location)*pf,value(c_charging), value(c_inf),sum(sum(value(DV_ICE))),value(ctea),value(cted),value(c_batts),sol.solveroutput.result.objval,sol.solveroutput.result.mipgap ...
    ,'VariableNames', variableNames);

% Add the new rows to the existing table
aggregatedResultsTable = [aggregatedResultsTable ; newRows];

% Display the updated table
disp(aggregatedResultsTable);

% Update Tables
variableNames = {'MaxFastCharging', 'MaxNightCharging', 'StartingBattery','EndingBattery','c_times','E_min','E_sup','MIPGAP'};
parametersRow = table(E_MaxFastCharging, NightChargingMaxP, StartingBattery,EndingBattery,c_times,E_min,E_sup,MIPGAP,'VariableNames', variableNames);
parametersTable = [parametersTable ; parametersRow];

variableNames = {'Time Slack', 'Peak Factor', 'NTrucks', '60', '180', '360' , '720', '1080' , ...
    'peakCons','peakCost', 'energyCosts', 'infra_costs','ICE','ObjValue','Gap'};
resultsRow = table(time_at_dcs, pf, K_EXPERIMENT ,value(X(1,1)),value(X(1,2)),value(X(1,3)),value(X(1,4)),value(X(1,5)),...
value(cp_max(1)),value(cp_max(1)*peak_per_location)*pf,value(c_charging), value(c_inf),value(sum(sum(DV_ICE))),sol.solveroutput.result.objval,sol.solveroutput.result.mipgap,...
'VariableNames', variableNames);

resultsTable = [resultsTable; resultsRow];

variableNames = {'c_ICE','c_infra','c_batt', 'c_times', 'c_energy' , 'c_peak' };
costsRow = table(value(c_ICE),value(c_inf),value(c_batts), value(c_times), value(c_charging) , value(c_peak),'VariableNames', variableNames);
costsTable = [costsTable ; costsRow ];

paramsDiagnostics.yamipTime = sol.yalmiptime;
paramsDiagnostics.solverTime = sol.solvertime;

end

paramsDiagnostics.mipgap = sol.solveroutput.result.mipgap;

% run efficient_solution_writing_AL.m

% %% This is superceded by the Z variable, using the Big-M approach
% C_TIMES_BETS_EXTRA = [];
% % Generate a times matrix to multiply by the decisions
% Time_rep_matrix = repmat(1:length(TIMES),length(K),1)';
% 
% % We are getting the time (in units) for all those with a +1
% % decision to charge, otherwise it is zero.
% Y_weighted_times = Time_rep_matrix.*squeeze(sum(Y,2));
% 
% Y_NotWeighted_Times = squeeze(sum(Y,2));
% 
% % xtend to match L dimension
% Y_weighted_times_expanded = repmat(Y_weighted_times,1,1,maxL);
% 
% % Similar with non-weighted
% Y_NotWeighted_Times_expanded = repmat(Y_NotWeighted_Times,1,1,maxL);
% 
% % And actually weight by wether at a certain L, the decision should be
% % considered.
% Y_Decisions_atTime_Real = Y_weighted_times_expanded .* T_SUP;
% 
% Y_Decisions_atTime_Real_notWeighted = Y_NotWeighted_Times_expanded .* T_SUP;
% 
% 
% % NEW
% C_TIMES_BETS_EXTRA = [C_TIMES_BETS_EXTRA ; ( Y_Decisions_atTime_Real <= repeated_tda ):...
% ['Time Departure Actual >= Latest Charging Slot Used' ]];
% 
% 
% C_TIMES_BETS_EXTRA = [C_TIMES_BETS_EXTRA ; ( Y_Decisions_atTime_Real(:,:,2:maxL) >= repeated_taa(:,:,1:maxL-1) .* T_SUP(:,:,2:maxL) - 5000*(1-Y_Decisions_atTime_Real_notWeighted(:,:,2:maxL))):...
% ['Time Arrival Actual <= Latest Charging Slot Used ' ]];
% 
% % infeasible here.
% % optimize(C_TIMES_BETS)

% end
