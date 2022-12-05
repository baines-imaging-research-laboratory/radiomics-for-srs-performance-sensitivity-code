function [] = S06c_UpdateContoursWithImagingSeriesParent()

data = load(Constants.databasePath);
database = data.database;

% update
database.update();

% *****************************************************************
% USED FOLLOWING CODE IN ImagingSeries.update
% % % for i=1:length(obj.contours)
% % %     obj.contours{i}.update(); % Not really needed
% % %     
% % %     obj.contours{i}.parent = obj;
% % % end
% *****************************************************************

% save it back
save(Constants.databasePath, 'database');

end

