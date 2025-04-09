%% Solution by Depot/charger
[a,b,c]=findND(value(X));


D_SUB = D(1:2);
R_SUB = R(2);%R(5);
I_SUB = 1;%I(1);


len = length(TT{1});

for d = D_SUB
for r = R_SUB
    A=[];
    max_y = 0;
    figure
    pt = tiledlayout(length(5),1);

for i = I_SUB
    
   % data = sol_chargers.nt{r}(1+(d-1)*(len):(len*d),i);
    data = sol_chargers.pow_char{r}(1+(d-1)*(len):(len*d),i);
    % miss in the missing time slots that were not even in the problem
%     nzs = numel(0:TU:DAY) - numel(data);

%     data = [data;...
%            zeros(nzs,1)];

    A = [A,data];

    max_y = max(max_y,max(data));
    % Plot next series:
    nexttile
    sh = stairs(TT{d},data);
%         ...
%         ts + days(d-1) + ...
%         hours(0:TU:DAY),...
%         data);
    tex = sprintf('DC # %d charger',i);
    title(tex);
    datetick('x','HHPM')
    hold on


bottom = 0; %identify bottom; or use min(sh.YData)
x = [sh.XData(1),repelem(sh.XData(2:end),2)];
y = [repelem(sh.YData(1:end-1),2),sh.YData(end)];
% plot(x,y,'y:') % should match stair plot
% Fill area
fill([x,fliplr(x)],[y,bottom*ones(size(y))], 'b')
ylim([0 inf]) ;
yticks(0:1:max_y);
    
end

       tex = sprintf('Usage of chargers of type %d on day %d',r,d);
       title(pt,tex)
       xlabel(pt,'Time')
       ylabel(pt,'# of chargers in use')
       hold off
              
end
end




