%% FULL DATABASE

% set-up export columns
categories = enumeration('ExportCategories');

% categories = [...
%     ExportCategories.PrimaryId,...
%     ExportCategories.SecondaryId,...
%     ExportCategories.ImagingSeriesDirectoryName];

columns = cell(length(categories),1);

allImagingStudies = true;
preTreatmentImagingStudy = false;
postTreatmentImagingStudy = false;
onlyContouredSeries = false;
columnGroupPrefix = '';

exportGroup = ExportColumnGroup(categories,...
    allImagingStudies, preTreatmentImagingStudy, postTreatmentImagingStudy, onlyContouredSeries,...
    columnGroupPrefix);

exportGroups = {exportGroup};

ExportColumnGroup.setColumnNumbersForColumnGroups(exportGroups);

% load data
data = load('D:\Users\ddevries\Data\SRS Patient Database.mat');
database = data.database;

writePath = 'D:\Users\ddevries\Data\SRS Patient Database (Full).xls';

database.exportToXls(writePath, exportGroups);


%% Only Pre-Treatment & Post-Treatment Studies

% set-up export columns
categories = enumeration('ExportCategories');

% categories = [...
%     ExportCategories.PrimaryId,...
%     ExportCategories.SecondaryId,...
%     ExportCategories.ImagingSeriesDirectoryName];

columns = cell(length(categories),1);

allImagingStudies = false;
preTreatmentImagingStudy = true;
postTreatmentImagingStudy = true;
onlyContouredSeries = false;
columnGroupPrefix = '';

exportGroup = ExportColumnGroup(categories,...
    allImagingStudies, preTreatmentImagingStudy, postTreatmentImagingStudy, onlyContouredSeries,...
    columnGroupPrefix);

exportGroups = {exportGroup};

ExportColumnGroup.setColumnNumbersForColumnGroups(exportGroups);

% load data
data = load('D:\Users\ddevries\Data\SRS Patient Database.mat');
database = data.database;

writePath = 'D:\Users\ddevries\Data\SRS Patient Database (Pre & Post Treatment).xls';

database.exportToXls(writePath, exportGroups);


%% Only Contoured Series

% set-up export columns
categories = enumeration('ExportCategories');

% categories = [...
%     ExportCategories.PrimaryId,...
%     ExportCategories.SecondaryId,...
%     ExportCategories.ImagingSeriesDirectoryName];

columns = cell(length(categories),1);

allImagingStudies = true;
preTreatmentImagingStudy = false;
postTreatmentImagingStudy = false;
onlyContouredSeries = true;
columnGroupPrefix = '';

exportGroup = ExportColumnGroup(categories,...
    allImagingStudies, preTreatmentImagingStudy, postTreatmentImagingStudy, onlyContouredSeries,...
    columnGroupPrefix);

exportGroups = {exportGroup};

ExportColumnGroup.setColumnNumbersForColumnGroups(exportGroups);

% load data
data = load('D:\Users\ddevries\Data\SRS Patient Database.mat');
database = data.database;

writePath = 'D:\Users\ddevries\Data\SRS Patient Database (Contoured Series).xls';

database.exportToXls(writePath, exportGroups);


%% Only Pre & Post Treatment Studies with only Contoured Series

% set-up export columns
categories = enumeration('ExportCategories');

% categories = [...
%     ExportCategories.PrimaryId,...
%     ExportCategories.SecondaryId,...
%     ExportCategories.ImagingSeriesDirectoryName];

columns = cell(length(categories),1);

allImagingStudies = false;
preTreatmentImagingStudy = true;
postTreatmentImagingStudy = true;
onlyContouredSeries = true;
columnGroupPrefix = '';

exportGroup = ExportColumnGroup(categories,...
    allImagingStudies, preTreatmentImagingStudy, postTreatmentImagingStudy, onlyContouredSeries,...
    columnGroupPrefix);

exportGroups = {exportGroup};

ExportColumnGroup.setColumnNumbersForColumnGroups(exportGroups);

% load data
data = load('D:\Users\ddevries\Data\SRS Patient Database.mat');
database = data.database;

writePath = 'D:\Users\ddevries\Data\SRS Patient Database (Pre & Post Treatment, Only Contoured Series).xls';

database.exportToXls(writePath, exportGroups);