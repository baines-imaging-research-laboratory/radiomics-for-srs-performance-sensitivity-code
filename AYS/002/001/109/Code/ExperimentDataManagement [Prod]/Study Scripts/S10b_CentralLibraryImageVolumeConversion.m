function S10b_CentralLibraryImageVolumeConversion()

chDatabaseRootPath = Constants.S10a_root; % post clean-up
chRootPath = Constants.S10b_root;

c1chCodeLibraries = {...
    'SRS-RECIST-STUDY [Dev]',...
    'CentralLibrary [Dev]',...
    'Matlab General Utilities'};

chGitLogFilePath = fullfile(chRootPath, Constants.chCodeRepositoryVersionLogFilename);

FileUtilities.addPaths(c1chCodeLibraries);
FileUtilities.logGitCommitHashForPathsAndCheckForMasterBranches(c1chCodeLibraries, chGitLogFilePath);
    
% load database
oDatabase = PatientDatabase.load(fullfile(chDatabaseRootPath, Constants.chDatabaseFilename));

% within the update function is a function that creates image volume
% objects and ROI objects to replace the existing ImagingSeries and
% Contours
oDatabase.update();

% save the database
oDatabase.save(fullfile(chRootPath, Constants.chDatabaseFilename));

end

