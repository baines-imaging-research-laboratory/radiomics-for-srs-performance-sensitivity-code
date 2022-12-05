function S09b_ViewRadOncImportantImages()

chDatabaseRootPath = Constants.S08b_root;
chRootPath = Constants.S09b_root;

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

oDatabase.quickSelect(37,3,2).openInViewer();
oDatabase.quickSelect(42,1,1).openInViewer();
oDatabase.quickSelect(50,1,1).openInViewer();
oDatabase.quickSelect(54,4,3).openInViewer();
oDatabase.quickSelect(69,2,3).openInViewer();
oDatabase.quickSelect(73,3,2).openInViewer();
oDatabase.quickSelect(73,4,2).openInViewer();
oDatabase.quickSelect(85,1,1).openInViewer();
oDatabase.quickSelect(85,2,2).openInViewer();
oDatabase.quickSelect(89,3,2).openInViewer();
oDatabase.quickSelect(89,4,3).openInViewer();
oDatabase.quickSelect(17,5,2).openInViewer();

end

