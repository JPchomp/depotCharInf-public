function output = hourValue(date)

% Extract the hour of the day from the input date
hr = hour(date);

% Define an array of values corresponding to each hour of the day
hourValues = [1
0.975908829
0.966820542
0.930755915
0.943739181
0.990839585
1.177077323
1.414310444
1.458453549
1.415175995
1.250360646
1.017022504
0.887911137
0.865551068
0.865551068
0.872763993
1.083597807
1.356462781
1.59982689
1.490190421
1.355020196
1.218407386
1.161064628
1.082804385
].*0.139;

% Look up the value corresponding to the input hour
output = hourValues(hr+1);

end