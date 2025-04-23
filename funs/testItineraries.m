%% Itin checker.

errs = [];
indices = [];
e3 =[];

min1=[];
min2=[];
min3=[];
min4=[];

for d = D

    for k = K

        extra  = time_dep_lat_units{d,k} - time_dep_ear_units{d,k};
        extra2 = time_arr_lat_units{d,k} - time_arr_ear_units{d,k};
        extra3 = time_arr_lat_units{d,k} - (time_dep_ear_units{d,k} + tim_units_act{d,k});
    
        min1 = min([min1;extra]) ;
        min2 = min([min2;extra2]);
        min3 = min([min3;extra3]);

    
        for l = L{d,k}'

            indices = [indices; d,k,l];

            if l == 1

                test = 500;

            else

                test = time_dep_lat_units{d,k}(l) - time_arr_ear_units{d,k}(l-1);

            end
            min4old = min4;
            min4 = min([min4;test]);

            if test < 0 

                errs = [errs;d,k,l];

               [Itin{d,k}.truck_id(l),...
                             d,k];

               [Itin{d,k}.time_departure_latest(l), ...
                             Itin{d,k}.time_arrival_earliest(l-1)];


            else


            end

        end
    end
end



if size(errs) < 1

    disp('## no itinerary conflicts found')

else

disp('## itinerary conflicts found!!! Check errs')

disp("departure absolute")
min1

disp("arrival absolute")
min2

disp("arrival vs dep+travel")
min3

disp("inter trip latest dep vs earliest arr")
min4

end



journey_cons = cell(length(K),1);
ener = [];
truck = [];
battTrucks = [];
ener_tour = [];

for d = D
    for k = K

        if numel(Itin{d,k})>0
        % This is ad hoc, just to test feasibility
        % I could add the actual definition here (Replace 315 for W*Batts)

        C_c_test{d,k} =  Itin{d,k}.total_consumption_leg_avg;

        % Createtemp Table
        tripData = table(Itin{d,k}.truckService, C_c_test{d,k});
        
        % Group the data by taskNumber and calculate total consumption for each group
        [uniqueTaskNumbers, ~, idx] = unique(tripData.Var1);
        totalConsumption = splitapply(@sum, tripData.Var2, idx);
        
        % Create a mapping between task numbers and total consumption
        taskToConsumptionMap = containers.Map(uniqueTaskNumbers, totalConsumption);
        
         % append to table
        Itin{d,k}.truckServiceConsumption  = cell2mat(values(taskToConsumptionMap, num2cell(tripData.Var1)));

        % store for retrieval of max
        ener = [ener;C_c_test{d,k}];
        truck = [truck;repmat(k,length(Itin{d,k}.truckServiceConsumption),1)];
        battTrucks = [battTrucks; repmat(data_vehs.battery(k),length(Itin{d,k}.truckServiceConsumption),1)];
        ener_tour = [ener_tour;Itin{d,k}.truckServiceConsumption];

     if d == 1
       
        journey_cons{k} = sum(C_c_test{d,k});

     else

         if (journey_cons{k} <= sum(C_c_test{d,k}))

             journey_cons{k} = sum(C_c_test{d,k});

         else
         end
     end

             else
        end

    end
end

fprintf("Max Econs per trip ij %d \n",max(ener))
fprintf("Max Econs per Tour (MaxReqBattery): %d \n", max(ener_tour))
[ta,tb]=min(battTrucks-ener_tour);
fprintf("Most Critical Depletion is truck %d reaching %d kWh \n",truck(tb),ta);
fprintf("Max energy consumption per Day: %d kWh\n",max(cell2mat(journey_cons(:))));



        % (Dis{d,k}) .* ...
        %     ...
        %     (c_c (k) .* ((data_vehs.truck_weight(k)+ ...
        %     ...
        %     315 * energy_density / 1000 ) + ... %edensity in ( kwh/kg )^-1 % Here just assume 
        %     ...
        %     abs(Itin{d,k}.payload_origin.*roll_weight_reg/1000 +...
        %     ...
        %     Itin{d,k}.payload_origin_cold.*roll_weight_cold/1000))...
        %     ...
        %     + 0.87); 