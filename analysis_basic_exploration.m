function analysis_basic_exploration(dfw_c)
%% Explore all data (CAVE! MANY, MANY FIGURES!)
for i=1:width(dfw_c)
    figure
    if isnumeric(dfw_c{:,i})
    histogram(dfw_c{:,i},round(height(dfw_c)/5))
    elseif iscategorical(dfw_c{:,i})
    histogram(dfw_c{:,i})
    end
    title(dfw_c.Properties.VariableNames(i))
end
end