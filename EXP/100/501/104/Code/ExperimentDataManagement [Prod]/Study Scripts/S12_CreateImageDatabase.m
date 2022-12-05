function S12_CreateImageDatabase()

chDatabaseRootPath = Constants.S11a_root;

% % % c1chCodeLibraries = {...
% % %     'SRS-RECIST-STUDY [Dev]',...
% % %     'CentralLibrary [Dev]',...
% % %     'Matlab General Utilities'};
% % %
% % % chGitLogFilePath = fullfile(chRootPath, Constants.chCodeRepositoryVersionLogFilename);
% % %
% % % FileUtilities.addPaths(c1chCodeLibraries);
% % % FileUtilities.logGitCommitHashForPathsAndCheckForMasterBranches(c1chCodeLibraries, chGitLogFilePath);

% load database
oDatabase = PatientDatabase.load(fullfile(chDatabaseRootPath, Constants.chDatabaseFilename));
oNewDatabase = StudyDatabase.Load(fullfile('D:\Users\ddevries\Data\SRS RECIST Study\S12 - Creating Imaging Database', Constants.chDatabaseFilename));

% new database path
chImageDatabasePath = 'D:\Users\ddevries\Data\SRS RECIST Study\Imaging Database';

% update
dNumEmptyStructuresDeleted = 0;

vdFailures = [];

for dPatientIndex=1:length(oDatabase.c1oPatients)
    if all(vdCompleted ~= dPatientIndex)
        disp(dPatientIndex);
        disp(datetime);
        
        bErrorOccurred = false;
        
        try
            oCurrentPatient = oDatabase.c1oPatients{dPatientIndex};
            
            c1oCurrentImagingStudies = oCurrentPatient.c1oImagingStudies;
            dNumStudies = length(c1oCurrentImagingStudies);
            voNewImagingStudies = repmat(DatabaseImagingStudy(1, datetime, 'pre-alloc', 'pre-alloc', DatabaseImageVolume.empty(1,0)),1,dNumStudies);
            
            chStudyPath = c1oCurrentImagingStudies{1}.chDirectoryPath;
            
            [chPatientPath, ~] = FileIOUtils.SeperateFilePathAndFilename(chStudyPath);
            [~, chPatientDirName] = FileIOUtils.SeperateFilePathAndFilename(chPatientPath);
            
            mkdir(chImageDatabasePath, chPatientDirName);
            chImageDatabasePatientPath = fullfile(chImageDatabasePath, chPatientDirName);
            
            for dStudyIndex=1:dNumStudies
                oCurrentStudy = oCurrentPatient.c1oImagingStudies{dStudyIndex};
                
                chStudyPath = oCurrentStudy.chDirectoryPath;
                [~, chStudyDirName] = FileIOUtils.SeperateFilePathAndFilename(chStudyPath);
                
                mkdir(chImageDatabasePatientPath, chStudyDirName);
                chImageDatabaseStudyPath = fullfile(chImageDatabasePatientPath, chStudyDirName);
                
                c1oCurrentImageVolumes = oCurrentStudy.c1oImageVolumes;
                dNumImageVolumes = length(c1oCurrentImageVolumes);
                
                voNewImageVolumes = repmat(DatabaseImageVolume(1, 'pre-alloc', 'pre-alloc', 'pre-alloc', DatabaseRegionOfInterest.empty(1,0)) , 1, dNumImageVolumes);
                
                for dVolumeIndex=1:length(oCurrentStudy.c1oImageVolumes)
                    oImageVolume = oCurrentStudy.c1oImageVolumes{dVolumeIndex};
                    chImageVolumeFilePath = oImageVolume.chFilePath;
                    
                    [chImageVolumeDir,~] = FileIOUtils.SeperateFilePathAndFilename(chImageVolumeFilePath);
                    [~,chImageVolumeDirName] = FileIOUtils.SeperateFilePathAndFilename(chImageVolumeDir);
                    
                    if isempty(oImageVolume.oRegionsOfInterest)
                        oNewImageVolume = DicomImageVolume(oImageVolume.chFilePath);
                        chImageDatabaseImageVolumePath = fullfile(chImageDatabaseStudyPath, [chImageVolumeDirName, '.mat']);
                        
                        voDatabaseRegionsOfInterest = DatabaseRegionOfInterest.empty(1,0);
                        chRawDataRegionsOfInterestFilePath = '';
                    else
                        oNewImageVolume = DicomImageVolume(oImageVolume.chFilePath, oImageVolume.oRegionsOfInterest.chFilePath);
                        
                        chRawDataRegionsOfInterestFilePath = oImageVolume.oRegionsOfInterest.chFilePath;
                        chImageDatabaseImageVolumePath = fullfile(chImageDatabaseStudyPath, [chImageVolumeDirName, ' [Contoured].mat']);
                        
                        dNumRois = oNewImageVolume.GetNumberOfRegionsOfInterest();
                        c1oContourValidationResults = oImageVolume.oRegionsOfInterest.c1oContourValidationResults;
                        
                        if length(c1oContourValidationResults) ~= dNumRois
                            error('Num ROIs to ContourValidationResults mismatch.');
                        end
                        
                        voDatabaseRegionsOfInterest = repmat(DatabaseRegionOfInterest(1, c1oContourValidationResults{1}) , 1, dNumRois);
                        
                        for dRoiIndex=1:dNumRois
                            voDatabaseRegionsOfInterest(dRoiIndex) = DatabaseRegionOfInterest(dRoiIndex, c1oContourValidationResults{dRoiIndex});
                        end
                    end
                    
                    oNewImageVolume.ReassignFirstVoxelToAlignWithRASCoordinateSystem();
                    oNewImageVolume.ForceApplyAllTransforms();
                    
                    oNewImageVolume.Save(chImageDatabaseImageVolumePath);
                    
                    voNewImageVolumes(dVolumeIndex) = DatabaseImageVolume(...
                        dVolumeIndex,...
                        strrep(chImageVolumeDir, '/', filesep), chImageDatabaseImageVolumePath,...
                        strrep(chRawDataRegionsOfInterestFilePath, '/', filesep), voDatabaseRegionsOfInterest);
                end
                
                voNewImagingStudies(dStudyIndex) = DatabaseImagingStudy(...
                    dStudyIndex, oCurrentStudy.dtImagingDate,...
                    strrep(chStudyPath, '/', filesep), chImageDatabaseStudyPath,...
                    voNewImageVolumes);
            end
            
            c1oCurrentTumours = oCurrentPatient.c1oTumours;
            dNumTumours = length(c1oCurrentTumours);
            voNewTumours = repmat(Tumour(1,1),1,dNumTumours);
            
            for dTumourIndex=1:dNumTumours
                voNewTumours(dTumourIndex) = Tumour(dTumourIndex, c1oCurrentTumours{dTumourIndex}.dGrossTumourVolume_mm3);
            end
            
            oPatient = DatabasePatient(...
                oCurrentPatient.dPrimaryId, oCurrentPatient.chSecondaryId,...
                oCurrentPatient.dAge, oCurrentPatient.eGender,...
                oCurrentPatient.oDiagnosis, oCurrentPatient.oTreatment,...
                voNewTumours,...
                voNewImagingStudies);
        catch e
            bErrorOccurred = true;
            disp('**FAILED**');
        end
        
        if ~bErrorOccurred
            FileIOUtils.SaveMatFile(fullfile('D:\Users\ddevries\Data\SRS RECIST Study\S12 - Creating Imaging Database', ['Patient ', num2str(dPatientIndex), '.mat']), 'oPatient', oPatient);
        else
            vdFailures = [vdFailures, dPatientIndex];
        end
    end
end

disp(vdFailures);



end

