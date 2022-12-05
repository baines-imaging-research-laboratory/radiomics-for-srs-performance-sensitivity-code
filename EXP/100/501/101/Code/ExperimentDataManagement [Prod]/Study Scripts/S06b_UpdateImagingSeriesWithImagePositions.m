function [] = S06b_UpdateImagingSeriesWithImagePositions()

data = load(Constants.databasePath);
database = data.database;

% update
database.update();

% *****************************************************************
% USED FOLLOWING CODE IN ImagingSeries.update
% % % entries = dir(obj.directoryPath);
% % % metadata = dicominfo([obj.directoryPath,'\',entries(3).name]);
% % %             
% % % obj.imagePosition = metadata.ImagePositionPatient;
% *****************************************************************

% save it back
save(Constants.databasePath, 'database');

end

