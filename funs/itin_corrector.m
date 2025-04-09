function [Itin_corr,flag] = itin_corrector(Itin,home_dc_num)
% input will be a table, we already in the Itin{d,k} cell
% and the home_dc number, given by data_vehs.home_dc_int(k)

H = height(Itin);

%%% check for empty itin!!
if H == 0

    Itin_corr = Itin;
    flag = 0;

else


if Itin.destination(H) == home_dc_num
    Itin_corr = Itin;
    flag = 0;
else
    
    new_row = Itin(H,:);
    new_row.order_n = new_row.order_n + 1;
    new_row.order_sub_n= new_row.order_sub_n + 1;
    new_row.origin = new_row.destination;
    new_row.destination = home_dc_num;

%%% Time stuff: This is very ad-hoc.
%%% if we started keeping accounting on the times
%%% need to rethink this.

%%% Also the payload is repeated, when it could go down to zero
%%% So this should also be revisited

    new_row.time_departure_earliest = new_row.time_arrival_earliest+hours(2);

    new_row.time_departure_latest = new_row.time_arrival_latest+hours(4);

    new_row.time_arrival_earliest = new_row.time_departure_earliest+hours(2);

    new_row.time_arrival_latest = new_row.time_departure_latest+hours(4);

    Itin_corr = [Itin;new_row];

    flag = 1;

end
end







