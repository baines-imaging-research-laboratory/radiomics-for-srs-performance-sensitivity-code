function S10a_CentralLibraryImageVolumeConversionCleanup()

% these files are invalid (seems to be some sort of scout/header file showing slice
% spacing)
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_03_17\MPRAGE_3D_axial\MR.1.3.12.2.1107.5.2.30.26420.30010008031710115409300001517.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_03_17\MPRAGE_3D_coronal\MR.1.3.12.2.1107.5.2.30.26420.30010008031710115409300001874.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\MPRAGE_3D_coronal\MR.1.2.840.113619.2.80.38263785.10264.1213968698.327.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_09_25\MPRAGE_3D_coronal\MR.1.2.840.113619.2.80.973279620.26436.1222330106.2.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient86_290\2009_08_10\T1_SE_axial_Gd\MR.1.2.840.113619.2.244.6945.201092.11009.1249885992.57.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient86_290\2009_08_10\T1_SE_axial_Gd\MR.1.2.840.113619.2.244.6945.201092.11009.1249885992.408.dcm');


% these folders had two series that we're intertwined into one (e.g. each
% slice was repeated, but from different imaging parameters)
rmdir('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_03_17\T2_TSE_axial','s');
rmdir('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_09_25\T2_TSE_axial','s');
rmdir('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T2_TSE_axial','s');

% repeated data (deleting the second copy):

delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.232.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.233.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.234.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.235.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.236.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.237.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.238.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.239.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.240.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.241.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.242.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.243.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.244.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.245.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.246.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.247.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.248.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.249.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.250.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.251.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.252.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.253.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.226.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.227.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.228.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.229.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.230.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\T1_SE_axial_Gd\MR.1.2.840.113619.2.207.6945.201092.8520.1213857541.231.dcm');


% update the database as needed
chDatabaseRootPath = Constants.S09c_root; % don't want to include the small polygon deletion
chRootPath = Constants.S10a_root;

c1chCodeLibraries = {...
    'SRS-RECIST-STUDY [Dev]',...
    'CentralLibrary [Dev]',...
    'Matlab General Utilities'};

chGitLogFilePath = fullfile(chRootPath, Constants.chCodeRepositoryVersionLogFilename);

FileUtilities.addPaths(c1chCodeLibraries);
FileUtilities.logGitCommitHashForPathsAndCheckForMasterBranches(c1chCodeLibraries, chGitLogFilePath);
    
% load database
oDatabase = PatientDatabase.load(fullfile(chDatabaseRootPath, Constants.chDatabaseFilename));

% remove the imaging series deleted above
oDatabase.getPatientByPrimaryId(84).c1oImagingStudies{1}.c1oImagingSeries = oDatabase.getPatientByPrimaryId(84).c1oImagingStudies{1}.c1oImagingSeries(1:5);
oDatabase.getPatientByPrimaryId(84).c1oImagingStudies{2}.c1oImagingSeries = oDatabase.getPatientByPrimaryId(84).c1oImagingStudies{2}.c1oImagingSeries(1:3);
oDatabase.getPatientByPrimaryId(84).c1oImagingStudies{3}.c1oImagingSeries = oDatabase.getPatientByPrimaryId(84).c1oImagingStudies{3}.c1oImagingSeries(1:4);

% save the database
oDatabase.save(fullfile(chRootPath, Constants.chDatabaseFilename));



end

