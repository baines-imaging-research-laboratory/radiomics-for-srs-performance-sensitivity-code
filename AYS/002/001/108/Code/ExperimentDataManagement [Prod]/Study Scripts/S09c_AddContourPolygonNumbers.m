function S09c_AddContourPolygonNumbers()

chDatabaseRootPath = Constants.S08b_root;
chRootPath = Constants.S09c_root;

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

% add polygon numbers
oDatabase.update();

% save the database
oDatabase.save(fullfile(chRootPath, Constants.chDatabaseFilename));

end

