function [] = S02x_uncontouredSeriesInvestigation(roundNum)
% 

% load database
data = load(Constants.databasePath);
database = data.database;

writePathRoot = Constants.S02_root;

% *************************************************************************
% Find which studies do not have a contoured imaging series

studyIdentifier = ImagingStudyIdentifier.all;
seriesIdentifier = ImagingSeriesIdentifier.contoured;

param = ImagingStudyParameter.numberOfSeries;

[patientIds, studyNumbers, numContouredSeries] = database.getImagingStudyParameter(param, studyIdentifier, seriesIdentifier);

% compile data into spreadsheet
uncontouredSelect = (numContouredSeries == 0);

uncontouredPatientIds = patientIds(uncontouredSelect);
uncontouredStudyNumbers = studyNumbers(uncontouredSelect);

numUncontouredStudies = length(uncontouredPatientIds);

headers = {'Patient Primary ID','Study Date','Path'};

numCols = length(headers);

sheet = cell(numUncontouredStudies+1, numCols);

sheet(1,:) = headers;

for i=1:numUncontouredStudies
    patient = database.findPatientByPrimaryId(uncontouredPatientIds(i));
    study = patient.findStudyByStudyNumber(uncontouredStudyNumbers(i));
    
    sheet{i+1,1} = patient.primaryId;
    sheet{i+1,2} = datestr(study.imagingDate, Constants.dateExportFormat);
    sheet{i+1,3} = study.directoryPath;
end

% write to excel file
filename = ['Imaging Studies Without Contoured Series (Round ', num2str(roundNum), ').xls'];

xlswrite([writePathRoot, '/', filename], sheet);

end