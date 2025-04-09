function displayChargingInfo(P, Y, X_LOC, Y_SUP,Y_weghted_power, timeRange, vehicleIndex)
    % Validate input dimensions and types if necessary

    % Extract the relevant data based on inputs
    P_values = value(P(timeRange, vehicleIndex));
    Y_sum = value(sum(Y(timeRange, :, vehicleIndex), 2));
    X_LOC_slice = X_LOC(vehicleIndex, timeRange)';
    Y_SUP_slice = Y_SUP(vehicleIndex, timeRange)';
    TimeIndices = timeRange';
    Y_WEIGHTEDPOWER = value(Y_weghted_power(timeRange, vehicleIndex));

    % Display the extracted data
[ P_values  ,  Y_sum, X_LOC_slice,Y_SUP_slice,Y_WEIGHTEDPOWER ,TimeIndices]
end

% Check ties consistency
%[value(tdl(kk,2:maxL));value(tae(kk,1:maxL-1))+value(ttl(kk,1:maxL-1)+ttu(kk,1:maxL-1)); IND_K_L(kk,2:maxL)]