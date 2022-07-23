classdef SRSRecistStudyConstants
    %SRSRecistStudyConstants
    
    properties (Constant)
        % PATHS
        chImagingDataRoot = 'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC';
        chPatientDataExcelPath = 'D:\Users\ddevries\Data\Working Data\VUMC SRS study\Patient clinical data\Database_Canada_sept2014_ano100.xls'
        
        chStudyDatabaseFilename = 'SRS Patient Database.mat'
        chImagingDatabasePath = 'D:\Users\ddevries\Data\SRS RECIST Study\Imaging Database'
        
        chS01_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S01 - Validation, Repair and Construction of Database'
                
        chS02_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S02 - Series Without Contours Investigation'
        
        chS03_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S03 - Full Database Patient Demographics'
        
        chS04_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S04 - Post-Treatment Imaging Timepoint Analysis';
        
        chS05a_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S05a - Timepoint Patients Demographics (1st Timepoint)'
        chS05b_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S05b - Timepoint Patients Demographics (2nd Timepoint)'
        
        chS07_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S07a - Manual Contour Validation (Round 1)'
        
        chS08_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S08 - Updating Database to New Structure'
        chS08b_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S08b - Removing Retired Property Names'
        
        chS09a_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S09a - Export Manual Contour Validation Results'
        chS09b_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S09b - Export Images for Rad Onc Review'
        chS09c_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S09c - Adding Contour Polygon Numbers'
        chS09d_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S09d - Deleting Small Contours'
        
        chS10a_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S10a - CentralLibrary ImageVolume Conversion Cleanup'
        chS10b_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S10b - CentralLibrary ImageVolume Conversion'
        chS10c_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S10c - CentralLibrary ImageVolume Conversion Legacy Property Removal'
        chS10d_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S10d - CentralLibrary ImageVolume Conversion Add Use Structure Flags'
        
        chS11a_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S11a - Remove Invalid Contour Polygons'
        chS11b_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S11b - Choose Contour Polygons To Use'
        
        chS12a_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S12a - Creating Imaging Database'
        chS12b_root = 'D:\Users\ddevries\Data\SRS RECIST Study\S12b - Creating Imaging Database (Combine Patients)'
        
        
        % DISPLAY CONSTANTS
        chDateExportFormat = 'dd/mm/yyyy';
        
        % LOG FILENAMES
        chCodeRepositoryVersionLogFilename = 'Code Repo Versions.txt';
    end
end

