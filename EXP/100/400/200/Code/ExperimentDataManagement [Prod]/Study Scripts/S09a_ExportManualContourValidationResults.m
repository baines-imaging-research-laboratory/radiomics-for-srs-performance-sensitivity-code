function [] = S09a_ExportManualContourValidationResults()

chDatabaseRootPath = Constants.S08b_root;
chRootPath = Constants.S09a_root;

c1chCodeLibraries = {...
    'SRS RECIST Study',...
    'Contour Validation',...
    'Matlab DICOM Support',...
    'Matlab General Utilities',...
    'Basic-MATLAB-DICOM-Viewer'};

chGitLogFilePath = fullfile(chRootPath, Constants.chCodeRepositoryVersionLogFilename);

FileUtilities.addPaths(c1chCodeLibraries);
FileUtilities.logGitCommitHashForPathsAndCheckForMasterBranches(c1chCodeLibraries, chGitLogFilePath);
    
% load database
oDatabase = PatientDatabase.load(fullfile(chDatabaseRootPath, Constants.chDatabaseFilename));


% perform query for all results

oPatientQuery = ClassQuery(...
    ClassSelector('PatientDatabase',@getPatients),...
    {@getPrimaryId}, 'ColumnHeaders', {'Prim. ID'});

oImagingStudyQuery = ClassQuery(...
    ClassSelector('Patient',@getImagingStudies),...
    {@getStudyNumber}, 'ColumnHeaders', {'Study #'});

oImagingSeriesQuery = ClassQuery(...
    ClassSelector('ImagingStudy',@getContouredImagingSeries),...
    {@getSeriesNumber}, 'ColumnHeaders', {'Series #'});

oContourQuery = ClassQuery(...
    ClassSelector('ImagingSeries',@getContours),...
    {@getContourNumber, @getContourName, @getObservationLabel, @getInterpretedType},...
    'ColumnHeaders',...
    {'Contour #', 'Name', 'Obs. Label', 'Interpreted Type'});

oContourValidationResultQuery = ClassQuery(...
    ClassSelector('Contour',@getContourValidationResult),...
    {...
    @getContourGroupNumber, @getCreatedNewContourGroup, @getNotes,...
    @(obj)obj.getDropDownResultsByIndex(1), @(obj)obj.getDropDownResultsByIndex(2),...
    @(obj)obj.getCheckboxResultsByIndex(1), @(obj)obj.getCheckboxResultsByIndex(2),...
    @(obj)obj.getCheckboxResultsByIndex(3), @(obj)obj.getCheckboxResultsByIndex(4),...
    @(obj)obj.getCheckboxResultsByIndex(5), @(obj)obj.getCheckboxResultsByIndex(6),...
    @(obj)obj.getCheckboxResultsByIndex(7), @(obj)obj.getCheckboxResultsByIndex(8)},...
    'ColumnHeaders',...
    {...
    'Contour Group #', 'Created New Group', 'Notes',...
    'Type of Contour', 'Contour Label Interpretation',...
    'Is there a necrotic core?', 'Is the necrotic core contoured?',...
    'Is there edema around the tumour?', 'Inaccurate contour?',...
    'Inaccurate contour label?','Non-Sagittal Acquisition?',...
    'Acquisition not well aligned?','General revisit required?'});

oContourValidationQuery = DatabaseQuery(...
    {oPatientQuery, oImagingStudyQuery, oImagingSeriesQuery, oContourQuery, oContourValidationResultQuery},...
    'MinimalRowFilling', true);

% perform query for all imaging series requiring a revisit

oPatientQuery = ClassQuery(...
    ClassSelector('PatientDatabase',@getPatients),...
    {@getPrimaryId}, 'ColumnHeaders', {'Prim. ID'});

oImagingStudyQuery = ClassQuery(...
    ClassSelector('Patient',@getImagingStudies),...
    {@getStudyNumber}, 'ColumnHeaders', {'Study #'});

oImagingSeriesQuery = ClassQuery(...
    ClassSelector('ImagingStudy',@getContouredImagingSeriesRequiringContourValidationRevisit),...
    {@getSeriesNumber}, 'ColumnHeaders', {'Series #'});

oContourQuery = ClassQuery(...
    ClassSelector('ImagingSeries',@getContours),...
    {@getContourNumber, @getContourName, @getObservationLabel, @getInterpretedType},...
    'ColumnHeaders',...
    {'Contour #', 'Name', 'Obs. Label', 'Interpreted Type'});

oContourValidationResultQuery = ClassQuery(...
    ClassSelector('Contour',@getContourValidationResult),...
    {...
    @getContourGroupNumber, @getCreatedNewContourGroup, @getNotes,...
    @(obj)obj.getDropDownResultsByIndex(1), @(obj)obj.getDropDownResultsByIndex(2),...
    @(obj)obj.getCheckboxResultsByIndex(1), @(obj)obj.getCheckboxResultsByIndex(2),...
    @(obj)obj.getCheckboxResultsByIndex(3), @(obj)obj.getCheckboxResultsByIndex(4),...
    @(obj)obj.getCheckboxResultsByIndex(5), @(obj)obj.getCheckboxResultsByIndex(6),...
    @(obj)obj.getCheckboxResultsByIndex(7), @(obj)obj.getCheckboxResultsByIndex(8)},...
    'ColumnHeaders',...
    {...
    'Contour Group #', 'Created New Group', 'Notes',...
    'Type of Contour', 'Contour Label Interpretation',...
    'Is there a necrotic core?', 'Is the necrotic core contoured?',...
    'Is there edema around the tumour?', 'Inaccurate contour?',...
    'Inaccurate contour label?','Non-Sagittal Acquisition?',...
    'Acquisition not well aligned?','General revisit required?'});

oContourValidationRevisitQuery = DatabaseQuery(...
    {oPatientQuery, oImagingStudyQuery, oImagingSeriesQuery, oContourQuery, oContourValidationResultQuery},...
    'MinimalRowFilling', true);


% Export the queries to excel

oDatabase.exportQueryToXls(fullfile(chRootPath, 'Validation Results.xls'),...
    'All Results', oContourValidationQuery,...
    'Results Requiring Revisit', oContourValidationRevisitQuery);


end

