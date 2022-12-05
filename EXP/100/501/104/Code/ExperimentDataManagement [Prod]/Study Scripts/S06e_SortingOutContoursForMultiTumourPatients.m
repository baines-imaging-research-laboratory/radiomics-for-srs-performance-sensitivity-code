function [] = S06e_SortingOutContoursForMultiTumourPatients()

% load database
data = load(Constants.databasePath);
database = data.database;


% sort out contours
% errors = {};
% 
% for i=1:length(database.patients)
%     disp(i);
%     error = database.patients{i}.solveForContourLocationNumbersAcrossImagingStudies();
%     
%     if ~isempty(error)
%         errors = [errors, {error}];
%     end
% end

studyId = ImagingStudyIdentifier.all;
seriesId = ImagingSeriesIdentifier.contoured;
contourId = ContourIdentifier.withPolygons;

param = ContourParameter.numberOfPolygons;

[patientIds, studyNumbers, seriesNumbers, contourNumbers, numPolygons] = database.getContourParameter(param, studyId, seriesId, contourId);



end

