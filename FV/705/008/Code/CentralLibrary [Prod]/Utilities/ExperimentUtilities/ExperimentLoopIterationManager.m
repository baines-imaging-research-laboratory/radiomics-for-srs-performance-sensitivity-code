classdef ExperimentLoopIterationManager
    %ParallelExperimentManager
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Dec 19, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        dNumberOfIterations
        
        chInitialComputationHostComputerName % the computer name the "main.m" was initially started with
        dInitialComputationWorkerNumberOrProcessId % the worker/process ID the "main.m" was initially started with
        
        chManagerConstructionComputationHostComputerName % the computer name that created the obj
        dManagerConstructionComputationWorkerNumberOrProcessId % the computer name that created the obj
        
        chResultsDirectoryRootPath
        chLoopResultsDirectoryPrefix
        
        oCurrentSection
        chCurrentSectionFileName
                
        bAutoAddEntriesIntoExperimentReport
        bAutoSaveObjects
        bAutoSaveSummaryFiles
        
        chClusterProfileName
        
        chRemotePoolLocalPathMatch
        c1chRemotePoolWorkerHostComputerNames
        c1chRemotePoolLocalPathReplacePerHostForAccessByWorker
        c1chRemotePoolLocalPathReplacePerHostForAccessByLocal
        
        c1chDataPaths
        c1chDataPathLabels
        
        oRandomNumberGenerator
        
        % to support avoid iteration recomputation if experiment is resumed
        bParentSetToAvoidIterationRecomputationIfResumed (1,1) logical
        bAvoidIterationRecomputationIfResumed (1,1) logical
        chIterationCompleteTokenFilename (1,:) char
        vbLoopIterationIsComplete (:,1) logical
        
        % new update:
        
        % post-loop tear-down variables
        bLoopPerformedWithIterationFolders (1,1) logical
        
        vsPathToIterationDirectoryFromLocal (:,1) string
        vsPathToIterationDirectoryFromWorker (:,1) string
        vsExperientSubSectionFilename (:,1) string
        vsIterationCompleteTokenFilename (:,1) string
    end
    
    
    properties (Constant = true, GetAccess = private)
        dNumberOfRandomCharsInTempResultsDirectoryName = 20
        dNumberOfRandomCharsInCurrentSectionFileName = 20
        dNumberOfRandomCharsInIterationCompleteTokenFilename = 20
    end
    
    
    properties (SetAccess = immutable, GetAccess = private)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ExperimentLoopIterationManager(oParent, dNumberOfIterations, bAvoidIterationRecomputationIfResumed)
            arguments
                oParent (1,1) % Experiment or LoopIterationExperimentPortion
                dNumberOfIterations (1,1) double {mustBePositive, mustBeInteger}
                bAvoidIterationRecomputationIfResumed (1,1) logical
            end
            
            obj.chInitialComputationHostComputerName = oParent.GetInitialComputationHostComputerName();
            obj.dInitialComputationWorkerNumberOrProcessId = oParent.GetInitialComputationWorkerNumberOrProcessId();
            
            [chHostComputerName, dWorkerNumberOrProcessId] = Experiment.GetCurrentComputationEnvironmentDetails();
            
            obj.chManagerConstructionComputationHostComputerName = chHostComputerName;
            obj.dManagerConstructionComputationWorkerNumberOrProcessId = dWorkerNumberOrProcessId;
            
            obj.oCurrentSection = copy(oParent.GetCurrentSectionForExperimentLoopIterationManager());
            
            obj.dNumberOfIterations = dNumberOfIterations;
            
            obj.chResultsDirectoryRootPath = oParent.GetResultsDirectoryRootPath();
            obj.chLoopResultsDirectoryPrefix = FileIOUtils.GetRandomFileName(ExperimentLoopIterationManager.dNumberOfRandomCharsInTempResultsDirectoryName);
            obj.chCurrentSectionFileName = [FileIOUtils.GetRandomFileName(ExperimentLoopIterationManager.dNumberOfRandomCharsInCurrentSectionFileName), '.mat'];
            
        	[bAutoAddEntriesIntoExperimentReport, bAutoSaveObjects, bAutoSaveSummaryFiles] = oParent.GetJournalingSettings_protected();
            obj.bAutoAddEntriesIntoExperimentReport = bAutoAddEntriesIntoExperimentReport;
            obj.bAutoSaveObjects = bAutoSaveObjects;
            obj.bAutoSaveSummaryFiles = bAutoSaveSummaryFiles;
            
            chClusterProfileName = oParent.GetClusterProfileName();
            obj.chClusterProfileName = chClusterProfileName;
            
            [chRemotePoolLocalPathMatch, c1chRemotePoolWorkerHostComputerNames, c1chRemotePoolLocalPathReplacePerHostForAccessByWorker, c1chRemotePoolLocalPathReplacePerHostForAccessByLocal] = oParent.GetRemoteWorkersConfiguration();
            
            obj.chRemotePoolLocalPathMatch = chRemotePoolLocalPathMatch;
            obj.c1chRemotePoolWorkerHostComputerNames = c1chRemotePoolWorkerHostComputerNames;
            obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker = c1chRemotePoolLocalPathReplacePerHostForAccessByWorker;
            obj.c1chRemotePoolLocalPathReplacePerHostForAccessByLocal = c1chRemotePoolLocalPathReplacePerHostForAccessByLocal;
            
            [c1chDataPaths, c1chDataPathLabels] = oParent.GetDataPathsAndLabels();
            
            obj.c1chDataPaths = c1chDataPaths;
            obj.c1chDataPathLabels = c1chDataPathLabels;
            
            % Set-up RNG
            obj.oRandomNumberGenerator = RandomNumberGenerator();
            obj.oRandomNumberGenerator.PreLoopSetup(dNumberOfIterations);
            
            % iteration complete token filename
            obj.chIterationCompleteTokenFilename = [FileIOUtils.GetRandomFileName(ExperimentLoopIterationManager.dNumberOfRandomCharsInIterationCompleteTokenFilename), '.tkn'];
            
            % set avoid iteration recomputation
            obj.bAvoidIterationRecomputationIfResumed = bAvoidIterationRecomputationIfResumed;
            
            if isa(oParent, 'LoopIterationExperimentPortion') && (oParent.GetParentLoopManagerSetToAvoidIterationRecomputationIfResumed())
                obj.bParentSetToAvoidIterationRecomputationIfResumed = true;
            end
            
            if obj.bAvoidIterationRecomputationIfResumed
                obj.vbLoopIterationIsComplete = obj.GetLoopIterationIsComplete();
            end
        end
        
        function PerLoopIndexSetup(obj, dIterationNumber)
            arguments
                obj (1,1) ExperimentLoopIterationManager
                dIterationNumber (1,1) double {MustBeValidIterationNumber(obj, dIterationNumber)}
            end
            
            % set RNG
            obj.oRandomNumberGenerator.PerLoopIndexSetup(dIterationNumber);
            
            if obj.PerformIterationsWithLoopIterationExperimentPortions()
                % is within parfor, so make a new global variable that will
                % function as the "Experiment" for the worker and add code
                % path
                
                % this will a global variable local to the WORKER on which the
                % iteration is being performed. It will be used by Experiment
                % for it's calls that usually look for the global oExperiment.
                % oExperiment can't be accessed since it is global only to the
                % MATLAB instance running main.m
                global oLoopIterationExperimentPortion;
                
                if isempty(oLoopIterationExperimentPortion)
                    chHostComputerName = Experiment.GetCurrentComputationEnvironmentDetails();
                    
                    % get directory for on worker
                    chIterationDirectoryName = obj.GetIterationResultsDirectoryName(dIterationNumber);
                    
                    if strcmp(chHostComputerName, obj.chInitialComputationHostComputerName)
                        % we're in a local parfor
                        
                        % addpath uses the same call
                        
                        chResultsDirectoryRootPathOnWorker = obj.chResultsDirectoryRootPath;
                    else
                        % we're in a remote parfor
                        
                        % get current hostname
                        vdIndices = CellArrayUtils.FindExactString(obj.c1chRemotePoolWorkerHostComputerNames, chHostComputerName);
                        
                        if ~isscalar(vdIndices)
                            error(...
                                'ExperimentLoopIterationManager:PerLoopIndexSetup:WorkerComputerNotConfigured',...
                                ['The Experiment is currently attempting to be computed on a computer with the name "', chHostComputerName, '". This computer was not set within the "settings.mat" file for the experiment in the "RemotePoolWorkerHostComputerNames" field, or appeared within that list more than once.']);
                        end
                        
                        chResultsDirectoryRootPathOnWorker = strrep(obj.chResultsDirectoryRootPath, obj.chRemotePoolLocalPathMatch, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker{vdIndices(1)});
                    end
                    
                    % make portion object
                    oLoopIterationExperimentPortion = LoopIterationExperimentPortion(...
                        dIterationNumber,...
                        obj.oCurrentSection,...
                        chResultsDirectoryRootPathOnWorker, chIterationDirectoryName,...
                        obj.bAutoAddEntriesIntoExperimentReport, obj.bAutoSaveObjects, obj.bAutoSaveSummaryFiles,...
                        obj.chInitialComputationHostComputerName, obj.dInitialComputationWorkerNumberOrProcessId,...
                        obj.chClusterProfileName,...
                        obj.chRemotePoolLocalPathMatch, obj.c1chRemotePoolWorkerHostComputerNames, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByLocal,...
                        obj.c1chDataPaths, obj.c1chDataPathLabels,...
                        obj.bAvoidIterationRecomputationIfResumed || obj.bParentSetToAvoidIterationRecomputationIfResumed);
                end
            end
        end
        
        function PerLoopIndexTeardown(obj)
            
            global oLoopIterationExperimentPortion;
            
            if obj.PerformIterationsWithLoopIterationExperimentPortions()
                % is the managed parfor loop
                oLoopIterationExperimentPortion.SaveCurrentSectionToDiskIfRequired(obj); % don't need to if no journalling requests were made
                
                % save completion token for Experiment.Resume
                obj.SaveIterationCompleteTokenToDisk(oLoopIterationExperimentPortion);
                
                % clear global variable on worker
                oLoopIterationExperimentPortion = [];
            else
                % is either not in a parfor (do nothing) or is a nested
                % managed loop within a parfor (again, do nothing)
            end
        end
        
        function PostLoopTeardown(obj)
            % needs to:
            % - clear out global oLoopIterationExperimentPortion to
            %   make sure Experiment doesn't run into it
            % - copy over files from workers (if parfor was done on remote
            %   workers)
            % - compile the journal files saved to disk per iteration
            
            % RNG teardown
            obj.oRandomNumberGenerator.PostLoopTeardown();
            
            % if was set to avoid iteration recomputation, free-up the
            % Experiment to allow another loop this capability
            if obj.bAvoidIterationRecomputationIfResumed
                Experiment.SetAvoidIterationRecomputationIfResumed(false);
            end
            
            % Experiment
            [chHostComputerName, dWorkerNumberOrProcessId] = Experiment.GetCurrentComputationEnvironmentDetails();
            
            if ...
                    (strcmp(chHostComputerName, obj.chInitialComputationHostComputerName) &&...
                    dWorkerNumberOrProcessId == obj.dInitialComputationWorkerNumberOrProcessId) &&...
                    ~obj.bParentSetToAvoidIterationRecomputationIfResumed
                % the execution is back onto which ever computer/worker
                % that originally started it (e.g. no longer within the
                % parfor)
                
                % clear out global variable (if it exists)
                global oLoopIterationExperimentPortion;
                oLoopIterationExperimentPortion = [];
                
                % There are multiple states the files can be at this time:
                % 1) Written on the local disk. This would be because either
                %    the loop was completed using "for" or using "parfor", but
                %    the cluster used was local.
                % 2) Not written on the local disk, but is on remote disks.
                %    This would be because the loop was completed using
                %    "parfor" with a distributed cluster.
                % 3) Not written on the local disk NOR on remote disks. This
                %    would because the loop was completed using "for" or
                %    "parfor", but since no files/journal entries were creating
                %    during the loop, there was never a need to write the
                %    files.
                
                % So what to do here. Here's what we'll do:
                % 1) Check if the files are local. If they're there great. If
                %    not...
                % 2) Check if a parpool exists, and if it does if its not
                %    local. If doesn't exist/is local, we're done, there's no
                %    files written, if there is a distributed parpool, then...
                % 3) Ask for the parpool for it's workers, and check each of
                %    the workers for the files. If they are found on
                %    the workers, great! If not, then there was no
                %    files/journal entries.
                                
                [vdIterationNumbersOnLocal, vsIterationFolderPathsOnLocal, vsExperimentSubSectionFilenamesOnLocal, vsIterationCompleteTokenFilenamesOnLocal, vsWorkerNamesOnLocal] = obj.FindIterationFoldersOnLocal();
                [vdIterationNumbersOnWorkers, vsIterationFolderPathsOnWorkers, vsExperimentSubSectionFilenamesOnWorkers, vsIterationCompleteTokenFilenamesOnWorkers, vsWorkerNamesOnWorkers] = obj.FindIterationFoldersOnWorkers();
                
                vdIterationNumbers = [vdIterationNumbersOnLocal; vdIterationNumbersOnWorkers];
                vsIterationFolderPaths = [vsIterationFolderPathsOnLocal; vsIterationFolderPathsOnWorkers];
                vsExperimentSubSectionFilenames = [vsExperimentSubSectionFilenamesOnLocal; vsExperimentSubSectionFilenamesOnWorkers];
                vsIterationCompleteTokenFilenames = [vsIterationCompleteTokenFilenamesOnLocal; vsIterationCompleteTokenFilenamesOnWorkers];
                vsWorkerNames = [vsWorkerNamesOnLocal; vsWorkerNamesOnWorkers];
                
                vbFromResumedExperiment = false(size(vdIterationNumbers));
                
                if Experiment.IsInResumeMode() && any(obj.vbLoopIterationIsComplete) % ensures that the loop is being resumed from
                    oManagerFromResume = Experiment.GetAvoidIterationRecomputationDataFromExperimentBeingResumed();
                    
                    [vdIterationNumbersOnLocalFromResume, vsIterationFolderPathsOnLocalFromResume, vsExperimentSubSectionFilenamesOnLocalFromResume, vsIterationCompleteTokenFilenamesOnLocalFromResume, vsWorkerNamesOnLocalFromResume] = obj.FindIterationFoldersOnLocalFromResume(oManagerFromResume);
                    [vdIterationNumbersOnWorkersFromResume, vsIterationFolderPathsOnWorkersFromResume, vsExperimentSubSectionFilenamesOnWorkersFromResume, vsIterationCompleteTokenFilenamesOnWorkersFromResume, vsWorkerNamesOnWorkersFromResume] = obj.FindIterationFoldersOnWorkersFromResume(oManagerFromResume);
                    
                    vdIterationNumbers = [vdIterationNumbers; vdIterationNumbersOnLocalFromResume; vdIterationNumbersOnWorkersFromResume];
                    vsIterationFolderPaths = [vsIterationFolderPaths; vsIterationFolderPathsOnLocalFromResume; vsIterationFolderPathsOnWorkersFromResume];
                    vsExperimentSubSectionFilenames = [vsExperimentSubSectionFilenames; vsExperimentSubSectionFilenamesOnLocalFromResume; vsExperimentSubSectionFilenamesOnWorkersFromResume];
                    vsIterationCompleteTokenFilenames = [vsIterationCompleteTokenFilenames; vsIterationCompleteTokenFilenamesOnLocalFromResume; vsIterationCompleteTokenFilenamesOnWorkersFromResume];
                    vsWorkerNames = [vsWorkerNames; vsWorkerNamesOnLocalFromResume; vsWorkerNamesOnWorkersFromResume];
                    
                    vbFromResumedExperiment = [vbFromResumedExperiment; true(size(vdIterationNumbersOnLocalFromResume)); true(size(vdIterationNumbersOnWorkersFromResume))];
                end
                
                if ~isempty(vdIterationNumbers) % need to consolidate all the iteration folders
                    [vdIterationNumbers, vdSortIndices] = sort(vdIterationNumbers, 'ascend');
                    
                    vsIterationFolderPaths = vsIterationFolderPaths(vdSortIndices);
                    vsExperimentSubSectionFilenames = vsExperimentSubSectionFilenames(vdSortIndices);
                    vsIterationCompleteTokenFilenames = vsIterationCompleteTokenFilenames(vdSortIndices);
                    vsWorkerNames = vsWorkerNames(vdSortIndices);
                    
                    vbFromResumedExperiment = vbFromResumedExperiment(vdSortIndices);
                    
                    if length(vdIterationNumbers) ~= obj.dNumberOfIterations || any(vdIterationNumbers ~= (1:obj.dNumberOfIterations)')
                        error(...
                            'ExperimentLoopIterationManager:PostLoopTeardown:NotAllIterationsComplete',...
                            'Not all the iterations were completed, or some iterations were completed multiple times.');
                    end
                    
                    obj.ConsolidateParforIterationDirectories(vsIterationFolderPaths, vsExperimentSubSectionFilenames, vsIterationCompleteTokenFilenames, vsWorkerNames, vbFromResumedExperiment);
                    
                    Experiment.UpdateParpoolIfUsingDCSResourceManager();
                end
            end
        end
        
        function bBool = IterationWasPreviouslyComputed(obj, dIterationNumber)
            arguments
                obj (1,1) ExperimentLoopIterationManager
                dIterationNumber (1,1) double {MustBeValidIterationNumber(obj, dIterationNumber)}
            end
            
            if ~obj.bAvoidIterationRecomputationIfResumed
                error(...
                    'ExperimentLoopIterationManager:IterationWasPreviouslyComputed:NotSupportedIfAvoidIterationRecomputationNotOn',...
                    'This function is only available if the ExperimentLoopIterationManager was produced with ''AvoidIterationRecomputationIfResumed'' set to true.');
            else
                bBool = obj.vbLoopIterationIsComplete(dIterationNumber);
            end
        end
    end
    
    
    methods (Access = public, Static = true)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % none
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = ?ExperimentSubSection)
        
        function oSection = GetCurrentSection(obj)
            oSection = obj.oCurrentSection;
        end
    end
    
    methods (Access = ?LoopIterationExperimentPortion)
        
        function chFileName = GetCurrentSectionFileName(obj)
            chFileName = obj.chCurrentSectionFileName;
        end
    end
    
    methods (Access = private, Static = false)
        
        function bBool = PerformIterationsWithLoopIterationExperimentPortions(obj)
            
            bBool = false;
            
            % If current execution is not on the same computer/process that
            % created this manager, we've just entered a parfor
            % environment, therefore the iteration must be performed with
            % LoopIterationExperimentPortion
            [chHostComputerName, dWorkerNumberOrProcessId] = Experiment.GetCurrentComputationEnvironmentDetails();
            
            if ~(strcmp(chHostComputerName, obj.chManagerConstructionComputationHostComputerName) &&...
                    dWorkerNumberOrProcessId == obj.dManagerConstructionComputationWorkerNumberOrProcessId)
                bBool = true;
            else
                % the only other way to use LoopIterationExperimentPortions
                % is to force the use of them using
                % 'AvoidIterationRecomputationIfResumed' set to true when
                % getting the manager
                
                if obj.bAvoidIterationRecomputationIfResumed
                    bBool = true;
                end
            end
        end
        
        function SaveIterationCompleteTokenToDisk(obj, oLoopIterationExperimentPortion)
            if ~isfolder(oLoopIterationExperimentPortion.GetResultsDirectoryRootPath())
                [chPathToFolder, chFolder] = FileIOUtils.SeparateFilePathAndFilename(oLoopIterationExperimentPortion.GetResultsDirectoryRootPath());
                mkdir(chPathToFolder, chFolder);
            end
            
            fclose(fopen(fullfile(oLoopIterationExperimentPortion.GetResultsDirectoryRootPath(), obj.chIterationCompleteTokenFilename), 'w'));
        end
        
        function ConsolidateParforIterationDirectories(obj, vsIterationFolderPaths, vsExperimentSubSectionFilenames, vsIterationCompleteTokenFilenames, vsWorkerNames, vbFromResumedExperiment)
            chTopLevelSectionResultsDirectoryPath = Experiment.GetResultsDirectory();
            chToPathResultsDirectoryRootToSubSectionPath = obj.oCurrentSection.GetPathToActiveSectionResultsDirectory();
            
            oTopLevelSection = obj.oCurrentSection;
            
            dStartingTopLevelFileNumber = oTopLevelSection.GetCurrentSectionResultsFileNumber();
            dStartingTopLevelSubSectionNumber = oTopLevelSection.GetCurrentSubSectionNumber();
            dStartingTopLevelJournalEntryNumber = oTopLevelSection.GetCurrentJournalEntryNumber();
            
            dTopLevelFileNumber = dStartingTopLevelFileNumber;
            dTopLevelSubSectionNumber = dStartingTopLevelSubSectionNumber;
            
            for dIterationNumber=1:obj.dNumberOfIterations
                sIterationFolderPath = vsIterationFolderPaths(dIterationNumber);
                sExperimentSubSectionFilename = vsExperimentSubSectionFilenames(dIterationNumber);
                sIterationCompleteTokenFilename = vsIterationCompleteTokenFilenames(dIterationNumber);
                sWorkerName = vsWorkerNames(dIterationNumber);
                
                chIterationResultsPath = char(sIterationFolderPath);
                
                % load saved experiment section
                oIterationCurrentSection = LoopIterationExperimentPortion.LoadIterationCurrentSection(chIterationResultsPath, char(sExperimentSubSectionFilename));
                
                if isempty(oIterationCurrentSection)
                    % do nothing, nothing was added to the Experiment
                    % report
                else
                    if sWorkerName == "" %is on local
                        chRemoteWorkerFromLocalPath = '';
                        chRemoteWorkerFromWorkerPath = '';
                        bFileFromRemoteWorker = false;
                    else % is on worker
                        chRemoteWorkerFromLocalPath = chIterationResultsPath;
                        chRemoteWorkerFromWorkerPath = obj.ChangeFromLocalPathToFromWorkerPath(chIterationResultsPath, sWorkerName);
                        bFileFromRemoteWorker = true;
                    end
                    
                    oIterationCurrentSection.PerformPostParforFileAndJournalTeardown(...
                        dStartingTopLevelFileNumber,...
                        chIterationResultsPath,...
                        chTopLevelSectionResultsDirectoryPath,...
                        dTopLevelFileNumber,...
                        dTopLevelSubSectionNumber,...
                        obj.GetIterationResultsDirectoryName(dIterationNumber),...
                        chToPathResultsDirectoryRootToSubSectionPath,...
                        bFileFromRemoteWorker, chRemoteWorkerFromLocalPath, chRemoteWorkerFromWorkerPath,...
                        char(sExperimentSubSectionFilename), char(sIterationCompleteTokenFilename),...
                        vbFromResumedExperiment(dIterationNumber));
                    
                    oTopLevelSection.AddSectionFromIteration(oIterationCurrentSection, dStartingTopLevelSubSectionNumber, dStartingTopLevelJournalEntryNumber);
                    
                    dTopLevelFileNumber = dTopLevelFileNumber + (oIterationCurrentSection.GetCurrentSectionResultsFileNumber() - dStartingTopLevelFileNumber);
                    dTopLevelSubSectionNumber = dTopLevelSubSectionNumber + (oIterationCurrentSection.GetCurrentSubSectionNumber() - dStartingTopLevelSubSectionNumber);
                end
            end
            
            oTopLevelSection.SetCurrentSectionResultsFileNumber(dTopLevelFileNumber);
            oTopLevelSection.SetCurrentSubSectionNumber(dTopLevelSubSectionNumber);
            
            Experiment.SetUpdateCurrentSectionAfterLoopIterationManagerTeardown(oTopLevelSection);
            
            % delete the iteration folders
            for dIterationNumber=1:obj.dNumberOfIterations
                if ~vbFromResumedExperiment(dIterationNumber) % delete the iteration folder                    
                    sIterationFolderPath = vsIterationFolderPaths(dIterationNumber);
                
                    rmdir(sIterationFolderPath, 's');
                end
            end
            
            % check if the results directory is empty (delete if it is)
            if FileIOUtils.IsDirectoryEmpty(chTopLevelSectionResultsDirectoryPath)
                rmdir(chTopLevelSectionResultsDirectoryPath);
            end
        end
        
        
        function ConsolidateFilesAndJournalToParentObject(obj, c1chResultsPaths)
            
            vdPathForIteration = zeros(obj.dNumberOfIterations,1);
            
            for dPathIndex=1:length(c1chResultsPaths)
                voEntries = dir(c1chResultsPaths{dPathIndex});
                
                for dEntry=3:length(voEntries)
                    dIterationNumber = str2double(voEntries(dEntry).name);
                    
                    if vdPathForIteration(dIterationNumber) ~= 0
                        error(...
                            'ExperimentLoopIterationManager:ConsolidateFilesAndJournalToParentObject:SameIterationOnMultipleWorkers',...
                            'The same iteration result folder was found on multiple workers.');
                    end
                    
                    vdPathForIteration(dIterationNumber) = dPathIndex;
                end
            end
            
            for dIteration=1:obj.dNumberOfIterations
                if vdPathForIteration(dIteration) ~= 0
                    chPath = c1chResultsPaths{vdPathForIteration(dIteration)};
                    chPath = fullfile(chPath, obj.GetIterationResultsDirectoryName(dIteration));
                    
                    % process unique results files (e.g. filenames were
                    % autogenerated by the Experiment class)
                    voEntries = dir(fullfile(chPath, ExperimentLoopIterationManager.chUniqueFileNamesFilesDirectory));
                    
                    dNumFiles = length(voEntries)-2;
                    
                    vsFileNames = strings(dNumFiles,1);
                    
                    for dFileIndex=1:dNumFiles
                        vsFileNames = string(voEntries(dFileIndex+2).name);
                    end
                    
                    vsFileNames = sort(vsFileNames, 'ascend');
                    
                    vsOriginalUniqueFileNames = vsFileNames;
                    vsNewUniqueFileNames = strings(size(vsFileNames));
                    
                    for dFileIndex=1:dNumFiles
                        chNewFileName = Experiment.GetUniqueResultsFileName();
                        
                        movefile(...
                            fullfile(chPath, vsFileNames(dFileIndex)),...
                            chNewFileName);
                        
                        vsNewUniqueFileNames(dFileIndex) = string(chNewFileName);
                    end
                    
                    % proces custom results files (e.g. user made custom
                    % file name, but saved to the results directory)
                    
                    voEntries = dir(fullfile(chPath, ExperimentLoopIterationManager.chCustomFileNamesFilesDirectory));
                    
                    for dEntryIndex=3:length(voEntries)
                        movefile(...
                            fullfile(chPath, voEntries(dEntryIndex).name),...
                            fullfile(Experiment.GetResultsDirectory(), voEntries(dEntryIndex).name));
                    end
                    
                    % process journal file
                    c1oEntries = LoopIterationExperimentPortion.LoadJournalEntries(fullfile(chPath, ExperimentLoopIterationManager.chJournalFileName));
                    
                    for dEntryIndex=1:length(c1oEntries)
                        if ischar(c1oEntries{dEntryIndex}) || isstring(c1oEntries{dEntryIndex})
                            sFigPath = string(c1oEntries{dEntryIndex});
                            
                            vdUniqueFileNameMatches = find(sFigPath == vsOriginalUniqueFileNames);
                            
                            if isscalar(vdUniqueFileNameMatches)
                                c1oEntries{dEntryIndex} = vsNewUniqueFileNames(vdUniqueFileNameMatches);
                            else
                                c1oEntries{dEntryIndex} = figureOutHowCustomFileNamesAreDealtWith();
                            end
                        end
                    end
                    
                    Experiment.AddToReport(c1oEntries);
                end
            end
        end
        
        function chLoopResultsDirectoryPrefix = GetLoopResultsDirectoryPrefix(obj)
            chLoopResultsDirectoryPrefix = obj.chLoopResultsDirectoryPrefix;
        end
        
        function chIterationResultsDirectoryName = GetIterationResultsDirectoryName(obj, dIterNum)
            dNumDigits = length(num2str(obj.dNumberOfIterations));
            
            chIterNum = StringUtils.num2str_PadWithZeros(dIterNum, dNumDigits);
            
            chIterationResultsDirectoryName = [obj.chLoopResultsDirectoryPrefix, chIterNum];
        end
        
        function chFromWorkerPath = ChangeFromLocalPathToFromWorkerPath(obj, chFromLocalPath, chWorkerName)
            arguments
                obj (1,1) ExperimentLoopIterationManager
                chFromLocalPath (1,:) char
                chWorkerName (1,:) char
            end
            
            dMatchIndex = 0;
            
            for dSearchIndex = 1:length(obj.c1chRemotePoolWorkerHostComputerNames)
                if strcmp(chWorkerName, obj.c1chRemotePoolWorkerHostComputerNames{dSearchIndex})
                    dMatchIndex = dSearchIndex;
                    break;
                end
            end
            
            if dMatchIndex == 0
                error(...
                    'ExperimentLoopIterationManager:ChangeFromLocalPathToFromWorkerPath:WorkerNameNotFound',...
                    'The provided worker name was not found.');
            end
            
            chFromWorkerPath = strrep(chFromLocalPath, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByLocal{dMatchIndex}, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker{dMatchIndex});
        end
        
        function MustBeValidIterationNumber(obj, dIterNumber)
            arguments
                obj
                dIterNumber (1,1) double {mustBePositive, mustBeInteger}
            end
            
            mustBeLessThanOrEqual(dIterNumber, obj.dNumberOfIterations);
        end
        
        function CopyAndDeleteParallelIterationsResultsDirectoryFromWorker(obj, sWorkerName)
            chWorkerName = char(sWorkerName);
            
            chUsername = getenv('username');
            
            vdIndices = strfind(obj.chCurrentResultsSectionPath, chUsername);
            
            if isempty(vdIndices)
                error(...
                    'ExperimentParallelIterationManager:CopyResultsDirectoryFromWorker:ResultsPathNoUsername',...
                    'The current username was not found within the results directory path, and so files on remote workers cannot be retrieved.');
            end
            
            chLocalPostUsernamePath = obj.chCurrentResultsSectionPath(vdIndices(1) + length(chUsername) : end);
            
            chParallelIterationsFolderPath = fullfile('\\', chWorkerName, chUsername, chLocalPostUsernamePath, obj.chLoopIterationsResultsDirectoryName);
            
            if exist(chParallelIterationsFolderPath, 'dir') ~= 0 % it may not exist if the worker investigated was never used in the parpool OR if no journalling/results files were created
                voEntries = dir(chParallelIterationsFolderPath);
                
                for dEntryIndex=1:length(voEntries)
                    oEntry = voEntries(dEntryIndex);
                    
                    if oEntry.isdir && ~strcmp(oEntry.name, '.') && ~strcmp(oEntry.name, '..')
                        bSuccess = movefile(...
                            fullfile(chParallelIterationsFolderPath, oEntry.name),...
                            fullfile(obj.chCurrentResultsSectionPath, obj.chLoopIterationsResultsDirectoryName, oEntry.name));
                        
                        if ~bSuccess
                            error(...
                                'ExperimentParallelIterationManager:CopyResultsDirectoryFromWorker:CopyFromWorkerFailed',...
                                'The copy from the worker failed.');
                        end
                    end
                end
                
                rmdir(chParallelIterationsFolderPath);
                
                chUpOneLevel = FileIOUtils.SeparateFilePathAndFilename(chParallelIterationsFolderPath);
                rmdir(chUpOneLevel);
                
                chUpOneLevel = FileIOUtils.SeparateFilePathAndFilename(chUpOneLevel);
                rmdir(chUpOneLevel);
            end
        end
        
        function ConsolidateAndDeleteParallelIterationJournalFiles(obj)
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            if 0 ~= exist(fullfile(obj.chCurrentResultsSectionPath, obj.chLoopIterationsResultsDirectoryName),'dir')
                oSection = Section([obj.chManagedLoopName, ' (', obj.chLoopIterationsResultsDirectoryName, ')']);
                
                for dIterationIndex=1:obj.dNumberOfIterations
                    chFilePath = fullfile(obj.chCurrentResultsSectionPath, obj.chLoopIterationsResultsDirectoryName, obj.GetIterationResultsDirectoryName(dIterationIndex), obj.chJournalFileName);
                    
                    if 0 ~= exist(chFilePath, 'file') % only if the file exists
                        oExperimentPortion = LoopIterationExperimentPortion.LoadJournalFile(chFilePath);
                        
                        oExperimentPortion.AddJournalToSection(oSection);
                        
                        delete(chFilePath);
                    end
                end
                
                Experiment.AddToReport(oSection);
            end
        end
        
        function bBool = IsParallelIterationsResultsDirectoryEmpty(obj)
            bBool = true;
            
            chPaths = genpath(fullfile(obj.chCurrentResultsSectionPath, obj.chLoopIterationsResultsDirectoryName));
            c1chPaths = strsplit(chPaths,';');
            
            for dPathIndex=1:length(c1chPaths)
                voEntries = dir(c1chPaths{dPathIndex});
                
                for dEntryIndex=1:length(voEntries)
                    if ~voEntries(dEntryIndex).isdir
                        bBool = false;
                        break;
                    end
                end
            end
        end
        
        function vbIterationIsComplete = GetLoopIterationIsComplete(obj)
            if ~obj.bAvoidIterationRecomputationIfResumed
                vbIterationIsComplete = false(obj.dNumberOfIterations,1);
            else
                if ~Experiment.IsInResumeMode()
                    vbIterationIsComplete = false(obj.dNumberOfIterations,1);
                else
                    [oLoopIterationManagerFromResume, dAvoidIterationRecomputationIfResumedIndexFromResume] = Experiment.GetAvoidIterationRecomputationDataFromExperimentBeingResumed();
                    dCurrentAvoidIterationRecomputationIfResumedIndex = Experiment.GetCurrentAvoidIterationRecomputationIfResumedIndex();
                    
                    if dCurrentAvoidIterationRecomputationIfResumedIndex < dAvoidIterationRecomputationIfResumedIndexFromResume % the experiment being resumed from already completed the entire loop
                        vbIterationIsComplete = true(obj.dNumberOfIterations,1);
                    elseif dCurrentAvoidIterationRecomputationIfResumedIndex > dAvoidIterationRecomputationIfResumedIndexFromResume % the experiment being resumed from never got to this loop, do all the indices
                        vbIterationIsComplete = false(obj.dNumberOfIterations,1);
                    else % the experiment being resumed from was running this loop when it failed. Go in and check which iterations got completed
                        [vdIterationNumbersOnLocalFromResume, vsIterationFolderPathsOnLocalFromResume, vsExperimentSubSectionFilenamesOnLocalFromResume, vsIterationCompleteTokenFilenamesOnLocalFromResume, vsWorkerNamesOnLocalFromResume] = obj.FindIterationFoldersOnLocalFromResume(oLoopIterationManagerFromResume);
                        [vdIterationNumbersOnWorkersFromResume, vsIterationFolderPathsOnWorkersFromResume, vsExperimentSubSectionFilenamesOnWorkersFromResume, vsIterationCompleteTokenFilenamesOnWorkersFromResume, vsWorkerNamesOnWorkersFromResume] = obj.FindIterationFoldersOnWorkersFromResume(oLoopIterationManagerFromResume);
                        
                        vbIterationIsComplete = false(obj.dNumberOfIterations,1);
                        
                        vbIterationIsComplete(vdIterationNumbersOnLocalFromResume) = true;
                        vbIterationIsComplete(vdIterationNumbersOnWorkersFromResume) = true;
                    end
                end
            end
        end
        
        function [vdIterationNumbersOnLocal, vsIterationFolderPathsOnLocal, vsExperimentSubSectionFilenamesOnLocal, vsIterationCompleteTokenFilenamesOnLocal, vsWorkerNamesOnLocal] = FindIterationFoldersOnLocal(obj)
            chResultsRootDirectoryPath = obj.chResultsDirectoryRootPath;
            chIterationFolderPrefix = obj.chLoopResultsDirectoryPrefix;
            chExperimentSubSectionFilename = obj.chCurrentSectionFileName;
            chIterationCompleteTokenFilename = obj.chIterationCompleteTokenFilename;
            
            voEntries = dir(chResultsRootDirectoryPath);
            
            vbIterationFolderFound = false(obj.dNumberOfIterations,1);
            
            vdIterationNumbersOnLocal = (1:obj.dNumberOfIterations)';
            vsIterationFolderPathsOnLocal = strings(obj.dNumberOfIterations,1);
            vsExperimentSubSectionFilenamesOnLocal = strings(obj.dNumberOfIterations,1);
            vsIterationCompleteTokenFilenamesOnLocal = strings(obj.dNumberOfIterations,1);
            vsWorkerNamesOnLocal = strings(obj.dNumberOfIterations,1);
            
            for dEntryIndex=1:length(voEntries)
                oEntry = voEntries(dEntryIndex);
                
                if oEntry.isdir && contains(oEntry.name, chIterationFolderPrefix)
                    chDirName = oEntry.name;
                    
                    dIterationNumber = str2double(chDirName(length(chIterationFolderPrefix)+1 : end));
                    
                    if isfile(fullfile(chResultsRootDirectoryPath, chDirName, chIterationCompleteTokenFilename)) % iteration is complete
                        vbIterationFolderFound(dIterationNumber) = true;
                        
                        vsIterationFolderPathsOnLocal(dIterationNumber) = string(fullfile(chResultsRootDirectoryPath, chDirName));
                        vsExperimentSubSectionFilenamesOnLocal(dIterationNumber) = string(chExperimentSubSectionFilename);
                        vsIterationCompleteTokenFilenamesOnLocal(dIterationNumber) = string(chIterationCompleteTokenFilename);
                        vsWorkerNamesOnLocal(dIterationNumber) = ""; % no worker, it's local!
                    end
                end
            end
            
            vdIterationNumbersOnLocal = vdIterationNumbersOnLocal(vbIterationFolderFound);
            vsIterationFolderPathsOnLocal = vsIterationFolderPathsOnLocal(vbIterationFolderFound);
            vsExperimentSubSectionFilenamesOnLocal = vsExperimentSubSectionFilenamesOnLocal(vbIterationFolderFound);
            vsIterationCompleteTokenFilenamesOnLocal = vsIterationCompleteTokenFilenamesOnLocal(vbIterationFolderFound);
            vsWorkerNamesOnLocal = vsWorkerNamesOnLocal(vbIterationFolderFound);
        end
        
        function [vdIterationNumbersOnWorkers, vsIterationFolderPathsOnWorkers, vsExperimentSubSectionFilenamesOnWorkers, vsIterationCompleteTokenFilenamesOnWorkers, vsWorkerNamesOnWorkers] = FindIterationFoldersOnWorkers(obj)
            chResultsRootDirectoryPath = obj.chResultsDirectoryRootPath;
            chIterationFolderPrefix = obj.chLoopResultsDirectoryPrefix;
            chExperimentSubSectionFilename = obj.chCurrentSectionFileName;
            chIterationCompleteTokenFilename = obj.chIterationCompleteTokenFilename;
            
            chRemotePoolLocalPathMatch = obj.chRemotePoolLocalPathMatch;
            
            vbIterationFolderFound = false(obj.dNumberOfIterations,1);
            
            vdIterationNumbersOnWorkers = (1:obj.dNumberOfIterations)';
            vsIterationFolderPathsOnWorkers = strings(obj.dNumberOfIterations,1);
            vsExperimentSubSectionFilenamesOnWorkers = strings(obj.dNumberOfIterations,1);
            vsIterationCompleteTokenFilenamesOnWorkers = strings(obj.dNumberOfIterations,1);
            vsWorkerNamesOnWorkers = strings(obj.dNumberOfIterations,1);
            
            for dWorkerIndex=1:length(obj.c1chRemotePoolWorkerHostComputerNames)
                chWorkerName = obj.c1chRemotePoolWorkerHostComputerNames{dWorkerIndex};
                
                if contains(chResultsRootDirectoryPath, chRemotePoolLocalPathMatch)
                    chResultsRootDirectoryPathFromLocal = strrep(chResultsRootDirectoryPath, chRemotePoolLocalPathMatch, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByLocal{dWorkerIndex});
                    chResultsRootDirectoryPathFromWorker = strrep(chResultsRootDirectoryPath, chRemotePoolLocalPathMatch, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker{dWorkerIndex});
                    
                    voEntries = dir(chResultsRootDirectoryPathFromLocal);
                    
                    for dEntryIndex=1:length(voEntries)
                        oEntry = voEntries(dEntryIndex);
                        
                        if oEntry.isdir && contains(oEntry.name, chIterationFolderPrefix)
                            chDirName = oEntry.name;
                            
                            dIterationNumber = str2double(chDirName(length(chIterationFolderPrefix)+1 : end));
                            
                            if isfile(fullfile(chResultsRootDirectoryPathFromLocal, chDirName, chIterationCompleteTokenFilename)) % iteration is complete
                                vbIterationFolderFound(dIterationNumber) = true;
                                
                                vsIterationFolderPathsOnWorkers(dIterationNumber) = string(fullfile(chResultsRootDirectoryPathFromLocal, chDirName));
                                vsExperimentSubSectionFilenamesOnWorkers(dIterationNumber) = string(chExperimentSubSectionFilename);
                                vsIterationCompleteTokenFilenamesOnWorkers(dIterationNumber) = string(chIterationCompleteTokenFilename);
                                vsWorkerNamesOnWorkers(dIterationNumber) = string(chWorkerName);
                            end
                        end
                    end
                end
            end
            
            vdIterationNumbersOnWorkers = vdIterationNumbersOnWorkers(vbIterationFolderFound);
            vsIterationFolderPathsOnWorkers = vsIterationFolderPathsOnWorkers(vbIterationFolderFound);
            vsExperimentSubSectionFilenamesOnWorkers = vsExperimentSubSectionFilenamesOnWorkers(vbIterationFolderFound);
            vsIterationCompleteTokenFilenamesOnWorkers = vsIterationCompleteTokenFilenamesOnWorkers(vbIterationFolderFound);
            vsWorkerNamesOnWorkers = vsWorkerNamesOnWorkers(vbIterationFolderFound);
        end
        
        function [vdIterationNumbersOnLocalFromResume, vsIterationFolderPathsOnLocalFromResume, vsExperimentSubSectionFilenamesOnLocalFromResume, vsIterationCompleteTokenFilenamesOnLocalFromResume, vsWorkerNamesOnLocalFromResume] = FindIterationFoldersOnLocalFromResume(obj, oObjFromResume)
            chResultsRootDirectoryPath = oObjFromResume.chResultsDirectoryRootPath;
            chIterationFolderPrefix = oObjFromResume.chLoopResultsDirectoryPrefix;
            chExperimentSubSectionFilename = oObjFromResume.chCurrentSectionFileName;
            chIterationCompleteTokenFilename = oObjFromResume.chIterationCompleteTokenFilename;
            
            voEntries = dir(chResultsRootDirectoryPath);
            
            vbIterationFolderFound = false(obj.dNumberOfIterations,1);
            
            vdIterationNumbersOnLocalFromResume = (1:obj.dNumberOfIterations)';
            vsIterationFolderPathsOnLocalFromResume = strings(obj.dNumberOfIterations,1);
            vsExperimentSubSectionFilenamesOnLocalFromResume = strings(obj.dNumberOfIterations,1);
            vsIterationCompleteTokenFilenamesOnLocalFromResume = strings(obj.dNumberOfIterations,1);
            vsWorkerNamesOnLocalFromResume = strings(obj.dNumberOfIterations,1);
            
            for dEntryIndex=1:length(voEntries)
                oEntry = voEntries(dEntryIndex);
                
                if oEntry.isdir && contains(oEntry.name, chIterationFolderPrefix)
                    chDirName = oEntry.name;
                    
                    dIterationNumber = str2double(chDirName(length(chIterationFolderPrefix)+1 : end));
                    
                    if isfile(fullfile(chResultsRootDirectoryPath, chDirName, chIterationCompleteTokenFilename)) % iteration is complete
                        vbIterationFolderFound(dIterationNumber) = true;
                        
                        vsIterationFolderPathsOnLocalFromResume(dIterationNumber) = string(fullfile(chResultsRootDirectoryPath, chDirName));
                        vsExperimentSubSectionFilenamesOnLocalFromResume(dIterationNumber) = string(chExperimentSubSectionFilename);
                        vsIterationCompleteTokenFilenamesOnLocalFromResume(dIterationNumber) = string(chIterationCompleteTokenFilename);
                        vsWorkerNamesOnLocalFromResume(dIterationNumber) = ""; % no worker, it's local!
                    end
                end
            end
            
            vdIterationNumbersOnLocalFromResume = vdIterationNumbersOnLocalFromResume(vbIterationFolderFound);
            vsIterationFolderPathsOnLocalFromResume = vsIterationFolderPathsOnLocalFromResume(vbIterationFolderFound);
            vsExperimentSubSectionFilenamesOnLocalFromResume = vsExperimentSubSectionFilenamesOnLocalFromResume(vbIterationFolderFound);
            vsIterationCompleteTokenFilenamesOnLocalFromResume = vsIterationCompleteTokenFilenamesOnLocalFromResume(vbIterationFolderFound);
            vsWorkerNamesOnLocalFromResume = vsWorkerNamesOnLocalFromResume(vbIterationFolderFound);
        end
        
        function [vdIterationNumbersOnWorkersFromResume, vsIterationFolderPathsOnWorkersFromResume, vsExperimentSubSectionFilenamesOnWorkersFromResume, vsIterationCompleteTokenFilenamesOnWorkersFromResume, vsWorkerNamesOnWorkersFromResume] = FindIterationFoldersOnWorkersFromResume(obj, oObjFromResume)
            chResultsRootDirectoryPath = oObjFromResume.chResultsDirectoryRootPath;
            chIterationFolderPrefix = oObjFromResume.chLoopResultsDirectoryPrefix;
            chExperimentSubSectionFilename = oObjFromResume.chCurrentSectionFileName;
            chIterationCompleteTokenFilename = oObjFromResume.chIterationCompleteTokenFilename;
            
            chRemotePoolLocalPathMatch = obj.chRemotePoolLocalPathMatch;
            
            vbIterationFolderFound = false(obj.dNumberOfIterations,1);
            
            vdIterationNumbersOnWorkersFromResume = (1:obj.dNumberOfIterations)';
            vsIterationFolderPathsOnWorkersFromResume = strings(obj.dNumberOfIterations,1);
            vsExperimentSubSectionFilenamesOnWorkersFromResume = strings(obj.dNumberOfIterations,1);
            vsIterationCompleteTokenFilenamesOnWorkersFromResume = strings(obj.dNumberOfIterations,1);
            vsWorkerNamesOnWorkersFromResume = strings(obj.dNumberOfIterations,1);
            
            for dWorkerIndex=1:length(obj.c1chRemotePoolWorkerHostComputerNames)
                chWorkerName = obj.c1chRemotePoolWorkerHostComputerNames{dWorkerIndex};
                
                chResultsRootDirectoryPathFromLocal = strrep(chResultsRootDirectoryPath, chRemotePoolLocalPathMatch, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByLocal{dWorkerIndex});
                chResultsRootDirectoryPathFromWorker = strrep(chResultsRootDirectoryPath, chRemotePoolLocalPathMatch, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker{dWorkerIndex});
                
                voEntries = dir(chResultsRootDirectoryPathFromLocal);
                
                for dEntryIndex=1:length(voEntries)
                    oEntry = voEntries(dEntryIndex);
                    
                    if oEntry.isdir && contains(oEntry.name, chIterationFolderPrefix)
                        chDirName = oEntry.name;
                        
                        dIterationNumber = str2double(chDirName(length(chIterationFolderPrefix)+1 : end));
                        
                        if isfile(fullfile(chResultsRootDirectoryPathFromLocal, chDirName, chIterationCompleteTokenFilename)) % iteration is complete
                            vbIterationFolderFound(dIterationNumber) = true;
                            
                            vsIterationFolderPathsOnWorkersFromResume(dIterationNumber) = string(fullfile(chResultsRootDirectoryPathFromLocal, chDirName));
                            vsExperimentSubSectionFilenamesOnWorkersFromResume(dIterationNumber) = string(chExperimentSubSectionFilename);
                            vsIterationCompleteTokenFilenamesOnWorkersFromResume(dIterationNumber) = string(chIterationCompleteTokenFilename);
                            vsWorkerNamesOnWorkersFromResume(dIterationNumber) = string(chWorkerName);
                        end
                    end
                end
            end
            
            vdIterationNumbersOnWorkersFromResume = vdIterationNumbersOnWorkersFromResume(vbIterationFolderFound);
            vsIterationFolderPathsOnWorkersFromResume = vsIterationFolderPathsOnWorkersFromResume(vbIterationFolderFound);
            vsExperimentSubSectionFilenamesOnWorkersFromResume = vsExperimentSubSectionFilenamesOnWorkersFromResume(vbIterationFolderFound);
            vsIterationCompleteTokenFilenamesOnWorkersFromResume = vsIterationCompleteTokenFilenamesOnWorkersFromResume(vbIterationFolderFound);
            vsWorkerNamesOnWorkersFromResume = vsWorkerNamesOnWorkersFromResume(vbIterationFolderFound);
        end
        
    end
    
    methods (Access = private, Static = true)
        
        
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

