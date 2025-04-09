function allOneString = intVectorToString(a)
allOneString = sprintf('%.0f,' , a);
allOneString = allOneString(1:end-1);% strip final comma
end