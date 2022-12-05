function S11a_RemoveInvalidContourPolygons()

chDatabaseRootPath = Constants.S10d_root; % post clean-up
chRootPath = Constants.S11a_root;

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
dNumEmptyStructuresDeleted = 0;

for dPatientIndex=1:length(oDatabase.c1oPatients)
    oPatient = oDatabase.c1oPatients{dPatientIndex};
    
    for dStudyIndex=1:length(oPatient.c1oImagingStudies)
        oStudy = oPatient.c1oImagingStudies{dStudyIndex};
        
        for dVolumeIndex=1:length(oStudy.c1oImageVolumes)
            oImageVolume = oStudy.c1oImageVolumes{dVolumeIndex};
            
            if ~isempty(oImageVolume.oRegionsOfInterest)
                oRois = oImageVolume.oRegionsOfInterest;
                
                for dStructureIndex=1:oRois.GetNumberOfRegionsOfInterest()
                    oStructure = oRois.c1oClosedPolygonStructures{dStructureIndex};
                    
                    if oStructure.GetNumberOfClosedPlanarPolygons() == 0
                        oRois.DeleteClosedPolygonStructure(dStructureIndex);
                        
                        dNumEmptyStructuresDeleted = dNumEmptyStructuresDeleted + 1;
                    end
                end
            end
        end
    end
end

disp('Num deleted: ');
disp(dNumEmptyStructuresDeleted);

% save the database
oDatabase.save(fullfile(chRootPath, Constants.chDatabaseFilename));

end

