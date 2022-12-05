classdef (Abstract) CrossWorkstationSyncer 
    %CrossWorkstationSyncer
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Constant = true, GetAccess = public)
    end
    
    properties (Constant = true, GetAccess = private)        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function CopyCompletedExperimentsToRemoteWorkersByAssetCode(sExperimentRoot, vsExperimentAssetCodes, sRemotePoolLocalPathMatch, vsRemotePoolLocalPathReplacePerHostForAccessByLocal)
            arguments
                sExperimentRoot (1,1) string
                vsExperimentAssetCodes (1,:) string
                sRemotePoolLocalPathMatch (1,1) string
                vsRemotePoolLocalPathReplacePerHostForAccessByLocal (:,1) string
            end
            
            chStartingDir = pwd;
            cd(sExperimentRoot);
            
            for dAssetIndex=1:length(vsExperimentAssetCodes)
                fprintf("Copying " + vsExperimentAssetCodes(dAssetIndex) + "...");
                
                chPathToAssetOnLocal = ExperimentManager.GetPathToExperimentAssetResultsDirectory(vsExperimentAssetCodes(dAssetIndex));
                sPathToAssetOnLocal = fullfile(sExperimentRoot, chPathToAssetOnLocal);
                
                for dWorkerIndex=1:length(vsRemotePoolLocalPathReplacePerHostForAccessByLocal)
                    sPathToAssetOnWorkerFromLocal = strrep(sPathToAssetOnLocal, sRemotePoolLocalPathMatch, vsRemotePoolLocalPathReplacePerHostForAccessByLocal(dWorkerIndex));
                    
                    copyfile(sPathToAssetOnLocal, sPathToAssetOnWorkerFromLocal);
                end
                
                fprintf("done");
                fprintf(newline);
            end
            
            cd(chStartingDir);
        end
        
        function vsItemsCopied = SyncImageDatabaseRoots(chFromImageDatabaseRoot, chToImageDatabaseRoot)
            arguments
                chFromImageDatabaseRoot (1,:) char
                chToImageDatabaseRoot (1,:) char
            end
            
            vsItemsCopied = string.empty;
            
            vsItemsCopied = CrossWorkstationSyncer.SyncImageDatabaseRoots_Recurse(chFromImageDatabaseRoot, chToImageDatabaseRoot, vsItemsCopied, true);    
            
            vsItemsCopied = vsItemsCopied';
        end
        
        function vsItemsCopied = SyncImageVolumeHandlersRoots(chFromImageVolumeHandlersRoot, chToImageVolumeHandlersRoot)
            arguments
                chFromImageVolumeHandlersRoot (1,:) char
                chToImageVolumeHandlersRoot (1,:) char
            end
            
            vsItemsCopied = string.empty;
            
            voFromEntries = dir(chFromImageVolumeHandlersRoot);
            voToEntries = dir(chToImageVolumeHandlersRoot);
            
            [vsFromDirNames, vsFromFileNames] = CrossWorkstationSyncer.GetDirAndFileNamesFromEntries(voFromEntries);
            [vsToDirNames, vsToFileNames] = CrossWorkstationSyncer.GetDirAndFileNamesFromEntries(voToEntries);
            
            % check files
            for dFileIndex=1:length(vsFromFileNames)
                sFromFileName = vsFromFileNames(dFileIndex);
                
                if ~any(sFromFileName == vsToFileNames)
                    copyfile(...
                        fullfile(chFromImageVolumeHandlersRoot, sFromFileName),...
                        fullfile(chToImageVolumeHandlersRoot, sFromFileName));
                    
                    vsItemsCopied(end+1) = fullfile(chFromImageVolumeHandlersRoot, sFromFileName);
                end
            end
            
            % check directories
            for dDirIndex=1:length(vsFromDirNames)
                sFromDirName = vsFromDirNames(dDirIndex);
                                
                if ~any(sFromDirName == vsToDirNames)
                    copyfile(...
                        fullfile(chFromImageVolumeHandlersRoot, sFromDirName),...
                        fullfile(chToImageVolumeHandlersRoot, sFromDirName));
                    
                    vsItemsCopied(end+1) = fullfile(chFromImageVolumeHandlersRoot, sFromDirName);
                end
            end
            
            % return copy record            
            vsItemsCopied = vsItemsCopied';
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
        
        function vsItemsCopied = SyncImageDatabaseRoots_Recurse(chFromImageDatabaseRoot, chToImageDatabaseRoot, vsItemsCopied, bIsTopLevel)
            voFromEntries = dir(chFromImageDatabaseRoot);
            voToEntries = dir(chToImageDatabaseRoot);
            
            [vsFromDirNames, vsFromFileNames] = CrossWorkstationSyncer.GetDirAndFileNamesFromEntries(voFromEntries);
            [vsToDirNames, vsToFileNames] = CrossWorkstationSyncer.GetDirAndFileNamesFromEntries(voToEntries);
            
            % check files
            for dFileIndex=1:length(vsFromFileNames)
                sFromFileName = vsFromFileNames(dFileIndex);
                
                if ~any(sFromFileName == vsToFileNames)
                    copyfile(...
                        fullfile(chFromImageDatabaseRoot, sFromFileName),...
                        fullfile(chToImageDatabaseRoot, sFromFileName));
                    
                    vsItemsCopied(end+1) = fullfile(chFromImageDatabaseRoot, sFromFileName);
                end
            end
            
            % check directories
            for dDirIndex=1:length(vsFromDirNames)
                sFromDirName = vsFromDirNames(dDirIndex);
                
                if bIsTopLevel
                    disp(sFromDirName);
                end
                
                if ~any(sFromDirName == vsToDirNames)
                    copyfile(...
                        fullfile(chFromImageDatabaseRoot, sFromDirName),...
                        fullfile(chToImageDatabaseRoot, sFromDirName));
                    
                    vsItemsCopied(end+1) = fullfile(chFromImageDatabaseRoot, sFromDirName);
                else
                    vsItemsCopied = CrossWorkstationSyncer.SyncImageDatabaseRoots_Recurse(...
                        fullfile(chFromImageDatabaseRoot, sFromDirName),...
                        fullfile(chToImageDatabaseRoot, sFromDirName),...
                        vsItemsCopied,...
                        false);
                end
            end
        end
        
        function [vsDirNames, vsFileNames] = GetDirAndFileNamesFromEntries(voEntries)
            dNumEntries = length(voEntries);
            
            vbIsDir = false(dNumEntries,1);
            vbIsFile = false(dNumEntries,1);
            vsNames = strings(dNumEntries,1);
            
            for dEntryIndex=1:dNumEntries
                oEntry = voEntries(dEntryIndex);
                sName = string(oEntry.name);
                
                if sName ~= "." && sName ~= ".."
                    vbIsDir(dEntryIndex) = oEntry.isdir;
                    vbIsFile(dEntryIndex) = ~oEntry.isdir;
                    vsNames(dEntryIndex) = sName;
                end
            end
            
            vsDirNames = vsNames(vbIsDir);
            vsFileNames = vsNames(vbIsFile);
        end
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)        
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

