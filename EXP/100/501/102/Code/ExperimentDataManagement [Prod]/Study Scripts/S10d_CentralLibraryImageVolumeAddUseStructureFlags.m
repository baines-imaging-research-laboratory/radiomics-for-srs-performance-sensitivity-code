function S10d_CentralLibraryImageVolumeAddUseStructureFlags()

chDatabaseRootPath = Constants.S10c_root; % post clean-up
chRootPath = Constants.S10d_root;

c1chCodeLibraries = {...
    'SRS-RECIST-STUDY [Dev]',...
    'CentralLibrary [Dev]',...
    'Matlab General Utilities'};

chGitLogFilePath = fullfile(chRootPath, Constants.chCodeRepositoryVersionLogFilename);

FileUtilities.addPaths(c1chCodeLibraries);
FileUtilities.logGitCommitHashForPathsAndCheckForMasterBranches(c1chCodeLibraries, chGitLogFilePath);
    
% load database
oDatabase = PatientDatabase.load(fullfile(chDatabaseRootPath, Constants.chDatabaseFilename));

% update
oDatabase.Update();

% save the database
oDatabase.save(fullfile(chRootPath, Constants.chDatabaseFilename));

end

