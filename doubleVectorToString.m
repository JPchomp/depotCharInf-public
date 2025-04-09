function allOneString = doubleVectorToString(a)
allOneString = sprintf('%.2f,' , a);
allOneString = allOneString(1:end-1);% strip final comma
end