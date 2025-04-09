% draw the plot of charging times for trucks

% value(squeeze(sum(P,2)))

ACT = value(P(1:200,:));

POWS = sum(ACT',2)

sz = size(ACT');



tdep = value(tda);
tarr = value(taa);

TB = T;
T = 1:sz(2);


%%
tptMat = zeros(sz);
for k = 1:K
    for l = 1:lmax(k)


        tspan = ceil(tdep(k,l)):floor(tarr(k,l)); % this is transportaiton
        spanload = ceil(tdep(k,l)):(ceil(tdep(k,l)+ttl(k,l)));
        spanuload = ceil(tdep(k,l)):(ceil(tdep(k,l)+ttu(k,l)));

tptMat(k,tspan) = 1; % code tpt
tptMat(k,spanload) = 2; % code load
tptMat(k,spanuload) = 3; % code load

    end
end
%%

toPlot = ACT' + tptMat;

P_MAX = max(max(toPlot));
%%
% Assuming toPlot, T, K, and P_MAX are defined
figure;
hold on;

% Define colors for each activity
colors = [0 0 1; 0 1 0; 1 0 0; 0 1 1]; % Blue for Transport, Green for Charging, Red for Loading, Cyan for Unloading

% Concatenate
for k = 1:K
    for t = 1:200
        % Convert datetime to numeric
        numericTime = datenum(TIMES(t));
        activity = toPlot(k, t);
        
        % Determine color based on activity
        if activity > 60 % Charging
            intensity = activity / P_MAX;
            color = [0 intensity 0]; % Vary green intensity based on charging power
        elseif activity == 1 % Transport
            color = colors(1, :);
        elseif activity == 2 % Loading
            color = colors(2, :);
        elseif activity == 3 % Unloading
            color = colors(3, :);
        else
            continue; % Skip if no activity
        end
        
        % Plot a rectangle for the activity
        % Use in rectangle function
rectangle('Position', [numericTime, k-1, 1, 1], 'FaceColor', color, 'EdgeColor', color);
    end
end


% Set up the plot
xlim([1 200] );
ylim([0 K]);
xlabel('Time');
ylabel('Vehicle');
title('Vehicle Activities Over Time');
set(gca, 'YDir', 'reverse'); % Reverse Y-axis so vehicle 1 is at the bottom
datetick('x','HH:MM'); % Format x-axis ticks as time
hold off;

%% 
% Please avoid all gpt talk. I have to obtain the code in matlab to plot the charging schedules across the vector T for vehicles in K.
% I would like to plot the K vehicles in the y axis, and the time of each activity in the x axis. The activities of the vehicle can be Charging (value > 60),
% Transport (value = 1), loading (value = 2) and unloading (value = 3), and are given in the matrix toPlot. I would like to plot different colours for each activity.
% I want the colour of the charging blocks to be green, with intensity varying depedning on the value of the power relative to the maximum charging power P_MAX.
% Please provide the full code, and make it sutiable for an academic publication.