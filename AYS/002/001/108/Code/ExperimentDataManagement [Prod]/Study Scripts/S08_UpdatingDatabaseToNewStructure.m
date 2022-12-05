function [] = S08_UpdatingDatabaseToNewStructure()

chDatabaseRootPath = Constants.S07_root;
chRootPath = Constants.S08_root;

c1chCodeLibraries = {...
    'SRS RECIST Study',...
    'Contour Validation',...
    'Matlab General Utilities'};

chGitLogFilePath = fullfile(chRootPath, Constants.chCodeRepositoryVersionLogFilename);

FileUtilities.addPaths(c1chCodeLibraries);
FileUtilities.logGitCommitHashForPathsAndCheckForMasterBranches(c1chCodeLibraries, chGitLogFilePath);
    
% load database
oDatabase = PatientDatabase.load(fullfile(chDatabaseRootPath, Constants.chDatabaseFilename));

% update database ("update" function for each object is primed)
oDatabase.update

% test the querying

% All data:
oPatientQuery = ClassQuery(...
    ClassSelector('PatientDatabase',@getPatients),...
    {@getPrimaryId, @getSecondaryId, @getAge, @getGender},...
    'ColumnHeaders', {'Prim. ID', 'Sec. Id', 'Age', 'Gender'});

oImagingStudyQuery = ClassQuery(...
    ClassSelector('Patient',@getImagingStudies),...
    {@getStudyNumber, @getImagingDate, @getDirectoryPath},...
    'ColumnHeaders', {'Study #', 'Imaging Date', 'Dir. Path'});

oImagingSeriesQuery = ClassQuery(...
    ClassSelector('ImagingStudy',@getImagingSeries),...
    {...
    @getSeriesNumber, @getDirectoryName, @getDescription, @getContrastDescription...
    @getImageOrientation, @getImagePosition_mm, @getInPlaneResolution_mm,...
    @getInPlaneDimensions, @getSliceThickness_mm, @getSliceSpacing_mm,...
    @getNumberOfSlices, @getDirectoryPath},...
    'ColumnHeaders',...
    {...
    'Series #', 'Dir. Name', 'Description', 'Contrast Description',...
    'Image Orient.', 'Image Position', 'In Plane Res.',...
    'In Plane Dims.', 'Slice Thickness', 'Slice Spacing',...
    'Num. Slices', 'Dir. Path'});

oContourQuery = ClassQuery(...
    ClassSelector('ImagingSeries',@getContours),...
    {...
    @getContourNumber, @getLocationNumber, @getContourName, @getObservationLabel...
    @getInterpretedType, @getFilePath},...
    'ColumnHeaders',...
    {...
    'Contour #', 'Location Num.', 'Name', 'Obs. Label',...
    'Interpreted Type', 'File Path'});

oAllDataQuery = DatabaseQuery(...
    {oPatientQuery, oImagingStudyQuery, oImagingSeriesQuery, oContourQuery},...
    'MinimalRowFilling', true);

% All Data with Contour Validation Results

oContouredImagingSeriesQuery = ClassQuery(...
    ClassSelector('ImagingStudy',@getContouredImagingSeries),...
    {...
    @getSeriesNumber, @getDirectoryName, @getDescription, @getContrastDescription...
    @getImageOrientation, @getImagePosition_mm, @getInPlaneResolution_mm,...
    @getInPlaneDimensions, @getSliceThickness_mm, @getSliceSpacing_mm,...
    @getNumberOfSlices, @getDirectoryPath},...
    'ColumnHeaders',...
    {...
    'Series #', 'Dir. Name', 'Description', 'Contrast Description',...
    'Image Orient.', 'Image Position', 'In Plane Res.',...
    'In Plane Dims.', 'Slice Thickness', 'Slice Spacing',...
    'Num. Slices', 'Dir. Path'});

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
    {oPatientQuery, oImagingStudyQuery, oContouredImagingSeriesQuery, oContourQuery, oContourValidationResultQuery},...
    'MinimalRowFilling', true);

% Tumours:

oTumourQuery = ClassQuery(...
    ClassSelector('Patient',@getTumours),...
    {...
    @getTumourNumber, @getGrossTumourVolume_mm3},...
    'ColumnHeaders',...
    {...
    'Tumour #', 'GTV (mm^3)'});
    
oPatientTumourQuery = DatabaseQuery(...
    {oPatientQuery, oTumourQuery},...
    'MinimalRowFilling', true);

% Treatments:

oTreatmentQuery = ClassQuery(...
    ClassSelector('Patient',@getTreatment),...
    {...
    @getType, @getDose_Gy, @getNumberOfFractions, @getTreatmentDate},...
    'ColumnHeaders',...
    {...
    'Type', 'Dose (Gy)', 'Num. Fractions', 'Date'});
    
oPatientTreatmentQuery = DatabaseQuery(...
    {oPatientQuery, oTreatmentQuery},...
    'MinimalRowFilling', true);

% Diagnosis:

oDiagnosisQuery = ClassQuery(...
    ClassSelector('Patient',@getDiagnosis),...
    {...
    @getPrimarySite, @getDiagnosisDate, @getPrimarySiteHistologyResult},...
    'ColumnHeaders',...
    {...
    'Prim. Site', 'Date', 'Prim. Histology'});
    
oPatientDiagnosisQuery = DatabaseQuery(...
    {oPatientQuery, oDiagnosisQuery},...
    'MinimalRowFilling', true);



% Export the queries to excel

oDatabase.exportQueryToXls(fullfile(chRootPath, 'Test Query.xls'),...
    'All Data', oAllDataQuery,...
    'Contour Validation Data', oContourValidationQuery,...
    'Tumours', oPatientTumourQuery,...
    'Treatments', oPatientTreatmentQuery,...
    'Diagnosis', oPatientDiagnosisQuery);

% save database
oDatabase.save(fullfile(chRootPath, Constants.chDatabaseFilename));

end

