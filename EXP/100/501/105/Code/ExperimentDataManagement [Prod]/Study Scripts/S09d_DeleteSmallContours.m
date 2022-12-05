function S09d_DeleteSmallContours()

chDatabaseRootPath = Constants.S09c_root;
chRootPath = Constants.S09d_root;

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

% within the update function is a function that delete polygons if they're
% area is <10% of the pixel size
oDatabase.update();

% save the database
oDatabase.save(fullfile(chRootPath, Constants.chDatabaseFilename));

end

