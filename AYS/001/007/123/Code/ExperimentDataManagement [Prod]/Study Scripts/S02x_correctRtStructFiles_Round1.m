function [] = S02x_correctRtStructFiles_Round1()
% 

% % % % % % ROW 2
% % % % % % ** NO ACTION REQUIRED **
% % % % % 
% % % % % % ROW 3
% % % % % delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\RS.1.2.246.352.71.4.550843352655.332766.20140715141005.dcm');
% % % % % 
% % % % % % ROW 4
% % % % % delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient86_290\2009_08_10\rtss_withSOPUIDs_IHope.dcm');
% % % % % movefile(...
% % % % %     'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient86_290\2009_08_10\RT STRUCT\RS.1.2.246.352.71.4.550843352655.332851.20140716120315.dcm',...
% % % % %     'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient86_290\2009_08_10\RS.1.2.246.352.71.4.550843352655.332851.20140716120315.dcm');
% % % % % rmdir('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient86_290\2009_08_10\RT STRUCT');
% % % % % 
% % % % % % ROW 5
% % % % % delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient95_359\2011_06_29\RS.1.2.246.352.71.4.550843352655.333102.20140716212319.dcm');


% ALTER DATABASE

data = load(Constants.databasePath);
database = data.database;

patient = database.findPatientByPrimaryId(86);
imagingStudy = patient.findStudyByStudyNumber(1);

path = 'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC/Patient86_290/2009_08_10';

contours = Contour.createContoursFromRtStructMetadata([path, '/', 'RS.1.2.246.352.71.4.550843352655.332851.20140716120315.dcm']);

rtStructMetadata = dicominfo([path, '/', 'RS.1.2.246.352.71.4.550843352655.332851.20140716120315.dcm']);
rtStructMatch = rtStructMetadata.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID;

numMatches = 0;

for i=1:length(imagingStudy.imagingSeries)
    series = imagingStudy.imagingSeries{i};
    
    entries = dir(series.directoryPath);
    
    firstFileMetadata = dicominfo([series.directoryPath,'/',entries(3).name]);
    
    if strcmp(rtStructMatch, firstFileMetadata.SeriesInstanceUID)
        numMatches = numMatches + 1;
        imagingStudy.imagingSeries{i}.contours = contours;
    end
end

if numMatches == 1
    save(Constants.databasePath, 'database');
else
    error('Correction Failed');
end

end