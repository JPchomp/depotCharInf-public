function [tts,eet] = start_end_corrector(ts,et)

% start time correction
shour = "00";
smin = "00";
ssec = "00";
sday = int2str(day(ts));
smonth = int2str(month(ts));
syear = int2str(year(ts));

sDateString = sprintf("%s-%s-%s %s:%s:%s",syear,smonth,sday,shour,smin,ssec);
tts = datetime(sDateString,'InputFormat','yyyy-MM-dd HH:mm:ss');


% end time correction
ehour = "23";
emin = "59";
esec = "59";
eday = int2str(day(et));
emonth = int2str(month(et));
eyear = int2str(year(et));

eDateString = sprintf("%s-%s-%s %s:%s:%s",eyear,emonth,eday,ehour,emin,esec);
eet = datetime(eDateString,'InputFormat','yyyy-MM-dd HH:mm:ss');