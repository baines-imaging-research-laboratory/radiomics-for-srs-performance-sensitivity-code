function [] = cellArrayHistogram(paramValues)
%[] = cellArrayHistogram(paramValues)

categories = {};
counts = [];

for i=1:length(paramValues)
    val = paramValues{i};
    
    index = findIndexInArray(categories, val);
    
    if isempty(index)
        counts = [counts, 1];
        categories = [categories, {val}];
    else
        counts(index) = counts(index) + 1;
    end
end

histogram('Categories', categories, 'BinCounts', counts);

end

% HELPER FUNCTIONS
function index = findIndexInArray(cellArray, value)
    index = [];

    for i=1:length(cellArray)
        if strcmp(cellArray{i}, value)
            index = i;
            break;
        end
    end
end