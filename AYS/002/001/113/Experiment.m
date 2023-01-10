classdef Experiment < handle
    %Experiment
    %
    % This class will allow experiments to be reproducible TODO
    
    % Primary Author: David DeVries
    % Created: Sep 18, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    
    properties (SetAccess = private, GetAccess = public)
        
        bIsBatchJob = false
        
        bInDebugMode
        bInResumeMode = false
        
        % %         chClusterProfileName = '' % will use the default cluster
        % %         bCreatePool = false
        % %         dPoolSize = [] % max out pool size
        
        
        bEmailReport = false
        
        chEmailSender = ''
        chEmailServer = ''
        chEmailAddress = ''
        
        bShowPDF = true
        
        bAutoAddEntriesIntoExperimentReport = true
        bAutoSaveObjects = true
        bAutoSaveSummaryFiles = true
        
        chAnacondaInstallPath = ''
        chAnacondaEnvironmentName = ''
        
        bCreateLocalParpool (1,1) logical
        dNumberOfLocalWorkers double
        
        bCreateDistributedParpool (1,1) logical
        chClusterProfileName (1,:) char
        bUseDCSResourceManager (1,1) logical
        
        chRemotePoolLocalPathMatch
        c1chRemotePoolWorkerHostComputerNames
        c1chRemotePoolLocalPathReplacePerHostForAccessByWorker
        c1chRemotePoolLocalPathReplacePerHostForAccessByLocal
        
        sDCSResourceManagerConnectionPath (1,1) string
        sDCSResourceManagerRequestId (1,1) string
        sDCSResourceManagerWorkerRequest (1,1) string
        
        dNumberOfDistributedWorkers (1,1) double
        
        
        % initial computing environment
        chInitialComputationHostComputerName
        dInitialComputationWorkerNumberOrProcessId
        
        % paths and such
        chPreExperimentPathCache
        
        chStartingWorkingDirectory
        chNewWorkingDirectory
        
        dtStartingTime
        dtEndingTime
        
        bExperimentSuccessful = false
        
        c1chCodePathsToCopyToNewWorkingDirectory
        
        c1chAllCodePathsToUse
        
        c1chWorkingDirectoryPathsAdded
        c1chCodePathsAdded
        
        chStartingPathCache
        chPathsAdded
        
        c1chDataPathLabels
        c1chDataPaths
        
        % reporting / sections
        oCurrentSection
        
        c1chSectionNames = {}
        
        c1chNestedSubSectionNames = {}
        
        bSectionCurrentlyActive = false
        
        dCurrentSectionNumber = 0
        chCurrentSectionResultsPath
        
        oCurrentReportResultsSection = []
        
        dtCurrentSectionStartTime
        dtLastSectionEndTime
        
        oReport
        c1oReportSections = {}
        c1hReportFigureHandles = {}
        
        % parargraphs that need to be updated after the experiment is
        % finished
        oExperimentStatusParagraph
        oExperimentEndTimeParagraph
        oExperimentElapsedTimeParagraph
        
        vdtSectionStartTimes = datetime.empty
        vdtSectionEndTimes = datetime.empty
        
        oCurrentSectionEndTimeParagraph = []
        oCurrentSectionElapsedTimeParagraph = []
        
        % remote parpool tracking
        bPathsAddedToParpoolWorkers = false
        
        % resume point
        bResumePointActive (1,1) logical = false
        dCurrentRestorePointIndex (1,1) double {mustBeNonnegative, mustBeInteger} = 0
        
        chResumeFromPath (1,:) char
        
        bResumePointWorkspaceSaveOccured (1,1) logical = false
        bResumePointWorkspaceLoadOccured (1,1) logical = false
        
        bResumeModeHasRunCode (1,1) logical = false
        
        % parfor resume
        bAvoidIterationRecomputationIfResumed (1,1) logical = false
        dAvoidIterationRecomputationIfResumedIndex (1,1) double = 0
        
        % DCS Resourse Manager
        bSubmittedDCSResourceManagerRequest (1,1) logical = false
        vbFilesTransferredToWorker (1,:) logical
    end
    
    properties (Access = private, Constant = true)
        c1chCentralLibrarySubfolderBlacklist = {'Tests', 'Demos', 'In Progress', 'Docs'} % any folder with one of these names within a root folder of the CentralLibrary will NOT be copied over for reproduction purposes
        c1chCentralLibaryRootFolderBlacklist = {... % these folders of the centrol library will not be copied, as they are not required to run (e.g. are demos, tests, etc.)
            '.git',...
            'DefaultInputs',...
            'Demos',...
            'Documentation',...
            'Experiment',...
            'Templates',...
            'Tests',...
            'Setup'}
        c1chCentralLibaryRootFileBlacklist = {'.gitignore','.gitignore.txt'}
        
        chBatchJobTokenFileName = 'BatchJob.tkn'
        
        chPathsFilename = 'codepaths.txt' % the filename containing the paths to add (can be relative or absolute)
        chCodeDirectoryName = 'Code'
        chResultsDirectoryName = 'Results'
        chCentralLibraryCodeDirectorySearchPattern = 'CentralLibrary' % this indentifies paths for which to apply the blacklists to for reduced copying overhead
        
        chGitFolderName = '.git'
        chGitBranchesMetadataPath = fullfile('.git','refs','heads')
        chGitCurrentBranchMetadataPath = fullfile('.git','HEAD')
        chGitBranchCommitIdsMetadataPath = fullfile('.git','FETCH_HEAD')
        chGitConfigMetadataPath = fullfile('.git','config')
        
        chCentralLibraryExperimentDirectoryName = 'Experiment'
        
        chMainFileName = 'main.m'
        
        chResultsFileNamePrefix = 'Results Data'
        chResultsFileExtension = '.mat'
        chResultsConsoleOutputFilename = 'Console Output.txt'
        
        chAnacondaEnvironmentPackageListFilename = 'Anaconda Environment Package List.txt'
        
        chDataPathsFilename = 'datapaths.txt'
        
        % Report constants
        chReportFormat = 'pdf'
        chReportFileName = 'Experiment Report.pdf'
        
        % Section constants
        chDefaultSectionName = 'Experiment Section'
        
        dMaxNumberOfSections = 99
        
        % settings
        chExperimentSettingsFilename = 'settings.mat'
        chExperimentSettingsTableVarName = 'tSettings'
        
        % resume point
        chResumePointSaveFolder = 'Resume Points'
        
        chResumePointFilePrefix = 'Resume Point'
        chResumePointWorkspaceFileNameSuffix = 'Workspace.mat'
        chResumePointGlobalVarsFileNameSuffix = 'Global Vars.mat'
        chResumePointRandomNumberGeneratorFileNameSuffix = 'Random Number Generator.mat'
        
        % avoid iteration recomputation if resumed
        chAvoidIterationRecomputationFilename = 'Loop Iteration Manager.mat';
        
        AvoidIterationRecomputationFileLoopIterationManagerVarName = 'oManager'
        AvoidIterationRecomputationFileIndexVarName = 'dAvoidIterationRecomputationIfResumedIndex'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function [sCompletedExperimentPath, bErrored] = Run(NameValueArgs)
            %Run()
            %
            % SYNTAX:
            %  Experiment.Run()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                NameValueArgs.EmailReport (1,1) logical
                NameValueArgs.EmailSender (1,1) string
                NameValueArgs.EmailServer (1,1) string
                NameValueArgs.EmailAddress (1,1) string
                NameValueArgs.AutoAddEntriesIntoExperimentReport (1,1) logical
                NameValueArgs.AutoSaveObjects (1,1) logical
                NameValueArgs.AutoSaveSummaryFiles (1,1) logical
                NameValueArgs.ShowPDF (1,1) logical
                NameValueArgs.AnacondaInstallPath (1,1) string
                NameValueArgs.AnacondaEnvironmentName (1,1) string
                NameValueArgs.CreateLocalParpool (1,1) logical
                NameValueArgs.NumberOfLocalWorkers double
                NameValueArgs.CreateDistributedParpool (1,1) logical
                NameValueArgs.ClusterProfileName (1,1) string
                NameValueArgs.UseDCSResourceManager (1,1) logical
                NameValueArgs.RemotePoolLocalPathMatch (1,1) string
                NameValueArgs.vsRemotePoolWorkerHostComputerNames (1,:) string
                NameValueArgs.vsRemotePoolLocalPathReplacePerHostForAccessByWorker (1,:) string
                NameValueArgs.vsRemotePoolLocalPathReplacePerHostForAccessByLocal (1,:) string
                NameValueArgs.sDCSResourceManagerConnectionPath (1,1) string
                NameValueArgs.sDCSResourceManagerRequestId (1,1) string
                NameValueArgs.sDCSResourceManagerWorkerRequest (1,1) string
                NameValueArgs.dNumberOfDistributedWorkers (1,1) double
            end
            
            bDebug = false;
            bResume = false;
            oExperiment = Experiment(bDebug, bResume, NameValueArgs);
            
            [sCompletedExperimentPath, bErrored] = oExperiment.RunMain();
        end
        
        %         function RunAsJob(NameValueArgs)
        %             arguments
        %                 NameValueArgs.EmailReport (1,1) logical
        %                 NameValueArgs.EmailSender (1,1) string
        %                 NameValueArgs.EmailServer (1,1) string
        %                 NameValueArgs.EmailAddress (1,1) string
        %                 NameValueArgs.AnacondaInstallPath (1,1) string
        %                 NameValueArgs.AnacondaEnvironmentName (1,1) string
        %                 NameValueArgs.CreateLocalParpool (1,1) logical
        %                 NameValueArgs.NumberOfLocalWorkers double
        %                 NameValueArgs.CreateDistributedParpool (1,1) logical
        %                 NameValueArgs.ClusterProfileName (1,1) string
        %                 NameValueArgs.UseDCSResourceManager (1,1) logical
        %                 NameValueArgs.RemotePoolLocalPathMatch (1,1) string
        %                 NameValueArgs.vsRemotePoolWorkerHostComputerNames (1,:) string
        %                 NameValueArgs.vsRemotePoolLocalPathReplacePerHostForAccessByWorker (1,:) string
        %                 NameValueArgs.vsRemotePoolLocalPathReplacePerHostForAccessByLocal (1,:) string
        %                 NameValueArgs.sDCSResourceManagerConnectionPath (1,1) string
        %                 NameValueArgs.sDCSResourceManagerRequestId (1,1) string
        %                 NameValueArgs.sDCSResourceManagerWorkerRequest (1,1) string
        %                 NameValueArgs.dNumberOfDistributedWorkers (1,1) double
        %             end
        %
        %             varargin = namedargs2cell(NameValueArgs);
        %
        %             Experiment.Run('RunAsJob', true, false, varargin{:});
        %         end
        
        function Debug(NameValueArgs)
            %Debug(NameValueArgs)
            %
            % SYNTAX:
            %  Experiment.Debug(Name, Value)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                NameValueArgs.EmailReport (1,1) logical
                NameValueArgs.EmailSender (1,1) string
                NameValueArgs.EmailServer (1,1) string
                NameValueArgs.EmailAddress (1,1) string
                NameValueArgs.AutoAddEntriesIntoExperimentReport (1,1) logical
                NameValueArgs.ShowPDF (1,1) logical
                NameValueArgs.AutoSaveObjects (1,1) logical
                NameValueArgs.AutoSaveSummaryFiles (1,1) logical
                NameValueArgs.AnacondaInstallPath (1,1) string
                NameValueArgs.AnacondaEnvironmentName (1,1) string
                NameValueArgs.CreateLocalParpool (1,1) logical
                NameValueArgs.NumberOfLocalWorkers double
                NameValueArgs.CreateDistributedParpool (1,1) logical
                NameValueArgs.ClusterProfileName (1,1) string
                NameValueArgs.UseDCSResourceManager (1,1) logical
                NameValueArgs.RemotePoolLocalPathMatch (1,1) string
                NameValueArgs.RemotePoolWorkerHostComputerNames (1,:) string
                NameValueArgs.RemotePoolLocalPathReplacePerHostForAccessByWorker (1,:) string
                NameValueArgs.RemotePoolLocalPathReplacePerHostForAccessByLocal (1,:) string
                NameValueArgs.DCSResourceManagerConnectionPath (1,1) string
                NameValueArgs.DCSResourceManagerRequestId (1,1) string
                NameValueArgs.DCSResourceManagerWorkerRequest (1,1) string
                NameValueArgs.NumberOfDistributedWorkers (1,1) double
            end
            
            bDebug = true;
            bResume = false;
            oExperiment = Experiment(bDebug, bResume, NameValueArgs);
            
            oExperiment.RunMain();
        end
        
        function Resume(chResumeFromPath, NameValueArgs)
            %Resume(chResumeFromPath, NameValueArgs)
            %
            % SYNTAX:
            %  Experiment.Resume(chResumeFromPath, Name, Value)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                chResumeFromPath (1,:) char
                NameValueArgs.EmailReport (1,1) logical
                NameValueArgs.EmailSender (1,1) string
                NameValueArgs.EmailServer (1,1) string
                NameValueArgs.EmailAddress (1,1) string
                NameValueArgs.AutoAddEntriesIntoExperimentReport (1,1) logical
                NameValueArgs.ShowPDF (1,1) logical
                NameValueArgs.AutoSaveObjects (1,1) logical
                NameValueArgs.AutoSaveSummaryFiles (1,1) logical
                NameValueArgs.AnacondaInstallPath (1,1) string
                NameValueArgs.AnacondaEnvironmentName (1,1) string
                NameValueArgs.CreateLocalParpool (1,1) logical
                NameValueArgs.NumberOfLocalWorkers double
                NameValueArgs.CreateDistributedParpool (1,1) logical
                NameValueArgs.ClusterProfileName (1,1) string
                NameValueArgs.UseDCSResourceManager (1,1) logical
                NameValueArgs.RemotePoolLocalPathMatch (1,1) string
                NameValueArgs.RemotePoolWorkerHostComputerNames (1,:) string
                NameValueArgs.RemotePoolLocalPathReplacePerHostForAccessByWorker (1,:) string
                NameValueArgs.RemotePoolLocalPathReplacePerHostForAccessByLocal (1,:) string
                NameValueArgs.DCSResourceManagerConnectionPath (1,1) string
                NameValueArgs.DCSResourceManagerRequestId (1,1) string
                NameValueArgs.DCSResourceManagerWorkerRequest (1,1) string
                NameValueArgs.NumberOfDistributedWorkers (1,1) double
            end
            
            bDebug = false;
            bResume = true;
            oExperiment = Experiment(bDebug, bResume, NameValueArgs);
            
            oExperiment.chResumeFromPath = chResumeFromPath;
            
            oExperiment.RunMain();
        end
        
        function DebugResume(chResumeFromPath, NameValueArgs)
            %DebugResume(chResumeFromPath, NameValueArgs)
            %
            % SYNTAX:
            %  Experiment.DebugResume(chResumeFromPath, Name Value)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                chResumeFromPath (1,:) char
                NameValueArgs.EmailReport (1,1) logical
                NameValueArgs.EmailSender (1,1) string
                NameValueArgs.EmailServer (1,1) string
                NameValueArgs.EmailAddress (1,1) string
                NameValueArgs.AutoAddEntriesIntoExperimentReport (1,1) logical
                NameValueArgs.ShowPDF (1,1) string
                NameValueArgs.AutoSaveObjects (1,1) logical
                NameValueArgs.AutoSaveSummaryFiles (1,1) logical
                NameValueArgs.AnacondaInstallPath (1,1) string
                NameValueArgs.AnacondaEnvironmentName (1,1) string
                NameValueArgs.CreateLocalParpool (1,1) logical
                NameValueArgs.NumberOfLocalWorkers double
                NameValueArgs.CreateDistributedParpool (1,1) logical
                NameValueArgs.ClusterProfileName (1,1) string
                NameValueArgs.UseDCSResourceManager (1,1) logical
                NameValueArgs.RemotePoolLocalPathMatch (1,1) string
                NameValueArgs.RemotePoolWorkerHostComputerNames (1,:) string
                NameValueArgs.RemotePoolLocalPathReplacePerHostForAccessByWorker (1,:) string
                NameValueArgs.RemotePoolLocalPathReplacePerHostForAccessByLocal (1,:) string
                NameValueArgs.DCSResourceManagerConnectionPath (1,1) string
                NameValueArgs.DCSResourceManagerRequestId (1,1) string
                NameValueArgs.DCSResourceManagerWorkerRequest (1,1) string
                NameValueArgs.NumberOfDistributedWorkers (1,1) double
            end
            
            bDebug = true;
            bResume = true;
            oExperiment = Experiment(bDebug, bResume, NameValueArgs);
            
            oExperiment.chResumeFromPath = chResumeFromPath;
            
            oExperiment.RunMain();
        end
        
        function Reset()
            global oExperiment;
            global oLoopIterationExperimentPortion;
            
            oExperiment = [];
            oLoopIterationExperimentPortion = [];
            
            RandomNumberGenerator.Reset();
        end
        
        function RemoveAllExperimentInstancesFromPathExceptCurrentDirectory()
            c1chExperimentPaths = which('Experiment','-all');            
            chCurrentDirPath = pwd;
            
            for dPathIndex=1:length(c1chExperimentPaths)
                chExperimentDirPath = FileIOUtils.SeparateFilePathAndFilename(c1chExperimentPaths{dPathIndex});
                
                if ~strcmp(chExperimentDirPath, chCurrentDirPath)
                    rmpath(chExperimentDirPath);
                end
            end
        end
        
        function RunExperimentsAsBatchJobs()
            vsExperimentPaths = GetExperimentDirectories();
            dNumExperiments = length(vsExperimentPaths);
            
            dNumCharsInExpNum = length(num2str(dNumExperiments));
            
            disp('Running Experiments as Batch Jobs');
            disp(' ');
            disp('Experiments to Run:');
            
            for dExperimentIndex=1:dNumExperiments
                chExpNum = num2str(dExperimentIndex);
                chExpNum = [repmat('0', 1, dNumCharsInExpNum-length(chExpNum)), chExpNum];
                
                disp([' ', chExpNum, ': ', char(vsExperimentPaths(dExperimentIndex))]);
            end
            
            disp(' ');            
            
            stDataFromFile = load(...
                Experiment.chExperimentSettingsFilename,...
                Experiment.chExperimentSettingsTableVarName);
            tSettingsFromFile = stDataFromFile.(Experiment.chExperimentSettingsTableVarName);
            
            stSettingsFromFile = struct;
            
            for dRowIndex=1:size(tSettingsFromFile,1)
                if ~isempty(tSettingsFromFile.chVarName{dRowIndex}) && ~strcmp(tSettingsFromFile.chVarName{dRowIndex}(1:2), '>>')
                    stSettingsFromFile.(tSettingsFromFile.chVarName{dRowIndex}) = tSettingsFromFile.c1xVarValue{dRowIndex};
                end
            end
            
            % copy over experiments to each worker
            fprintf('Copying over experiment folders to worker hosts...');
            
            dNumWorkerHosts = length(stSettingsFromFile.RemotePoolWorkerHostComputerNames);
            
            for dExperimentIndex=1:dNumExperiments
                sLocalExperimentPath = vsExperimentPaths(dExperimentIndex);
                
                for dHostIndex=1:dNumWorkerHosts
                    sWorkerPathFromLocal = strrep(sLocalExperimentPath, stSettingsFromFile.RemotePoolLocalPathMatch, stSettingsFromFile.RemotePoolLocalPathReplacePerHostForAccessByLocal{dHostIndex});
                    
                    copyfile(sLocalExperimentPath, sWorkerPathFromLocal);
                    
                    % change datapaths.txt paths to work on each worker
                    c1chDataPathLines = {};
                    
                    oFile = fopen(fullfile(sLocalExperimentPath, Experiment.chDataPathsFilename));
                    
                    chLine = fgetl(oFile);
                    
                    dLineIndex = 1;
                    
                    while ischar(chLine)
                        chLine = strrep(chLine, stSettingsFromFile.RemotePoolLocalPathMatch, stSettingsFromFile.RemotePoolLocalPathReplacePerHostForAccessByWorker{dHostIndex});
                        
                        c1chDataPathLines{dLineIndex} = chLine;
                        
                        dLineIndex = dLineIndex + 1;
                        chLine = fgetl(oFile);
                    end
                    
                    fclose(oFile);
                    
                    delete(fullfile(sWorkerPathFromLocal, Experiment.chDataPathsFilename));
                                        
                    oFile = fopen(fullfile(sWorkerPathFromLocal, Experiment.chDataPathsFilename), 'w');
                    
                    for dWriteLineIndex=1:length(c1chDataPathLines)
                        fwrite(oFile, c1chDataPathLines{dWriteLineIndex});
                        
                        if dWriteLineIndex ~= length(c1chDataPathLines)
                            fwrite(oFile, newline);
                        end
                    end
                    
                    fclose(oFile);                    
                    
                    % change codepaths.txt paths to work on each worker
                    c1chCodePathLines = {};
                    
                    oFile = fopen(fullfile(sLocalExperimentPath, Experiment.chPathsFilename));
                    
                    chLine = fgetl(oFile);
                    
                    dLineIndex = 1;
                    
                    while ischar(chLine)
                        chLine = strrep(chLine, stSettingsFromFile.RemotePoolLocalPathMatch, stSettingsFromFile.RemotePoolLocalPathReplacePerHostForAccessByWorker{dHostIndex});
                        
                        c1chCodePathLines{dLineIndex} = chLine;
                        
                        dLineIndex = dLineIndex + 1;
                        chLine = fgetl(oFile);
                    end
                    
                    fclose(oFile);
                    
                    delete(fullfile(sWorkerPathFromLocal, Experiment.chPathsFilename));
                    
                    oFile = fopen(fullfile(sWorkerPathFromLocal, Experiment.chPathsFilename), 'w');
                    
                    for dWriteLineIndex=1:length(c1chCodePathLines)
                        fwrite(oFile, c1chCodePathLines{dWriteLineIndex});
                        
                        if dWriteLineIndex ~= length(c1chCodePathLines)
                            fwrite(oFile, newline);
                        end
                    end
                    
                    fclose(oFile);
                    
                    % create a "BatchJob.tkn" file
                    oFile = fopen(fullfile(sWorkerPathFromLocal, Experiment.chBatchJobTokenFileName), 'w');
                    fclose(oFile);
                end
            end
            
            fprintf('done');
            fprintf(newline);
            
            % copy over code repos            
            fprintf('Copying over code folders to worker hosts...');
            
            chText = fileread(Experiment.chPathsFilename);
            c1chLines = regexp(chText, '\r\n|\r|\n', 'split');
            
            dNumLines = length(c1chLines);
            c1chCodePaths = cell(dNumLines,1);
            dNumCodePaths = 0; % some lines could be blank etc.
            
            for dLineIndex=1:dNumLines
                chTrimmedLine = strtrim(c1chLines{dLineIndex});
                
                if ~isempty(chTrimmedLine) % if not empty, let's see what we have
                    if exist(chTrimmedLine, 'dir') ~= 7
                        error(...
                            'Experiment:RunExperimentsAsBatchJobs:InvalidPath',...
                            ['The path ', StringUtils.MakePathStringValidForPrinting(chTrimmedLine), ' does not exist.']);
                    else % it exists, so let's add it
                        dNumCodePaths = dNumCodePaths + 1;
                        c1chCodePaths{dNumCodePaths} = chTrimmedLine;
                    end
                end
            end
            
            % - trim c1chCodePaths to only be as long as needed:
            c1chCodePaths = c1chCodePaths(1:dNumCodePaths);
            c1chDirsToCopy = c1chCodePaths;
            
            for dHostIndex=1:dNumWorkerHosts
                for dDirIndex=1:length(c1chDirsToCopy)
                    chCodeRepoOnWorkerFromLocalPath = strrep(c1chDirsToCopy{dDirIndex}, stSettingsFromFile.RemotePoolLocalPathMatch, stSettingsFromFile.RemotePoolLocalPathReplacePerHostForAccessByLocal{dHostIndex});
                    
                    if isfolder(chCodeRepoOnWorkerFromLocalPath)
                        rmdir(chCodeRepoOnWorkerFromLocalPath, 's');
                    end
                    
                    [~, chDirName] = Experiment.SeparateFilePathAndLastItem(c1chDirsToCopy{dDirIndex});
                    
                    if contains(chDirName, Experiment.chCentralLibraryCodeDirectorySearchPattern) % we're copying the central library, so a special copy is used to avoid blacklisted folders (e.g. tests, demos, etc.)
                        Experiment.CopyCentralLibraryDirectory(...
                            c1chDirsToCopy{dDirIndex},...
                            chCodeRepoOnWorkerFromLocalPath);
                    else % not the CentralLibrary, so just copy the whole folder
                        Experiment.CopyCodeDirectory(...
                            c1chDirsToCopy{dDirIndex},...
                            chCodeRepoOnWorkerFromLocalPath);
                    end
                    
                    % copy over only essential .git files such that the
                    % experiment journal can record the git data
                    % get branch name
                    if isfolder(fullfile(c1chDirsToCopy{dDirIndex}, Experiment.chGitFolderName)) % is controlled by git                    
                        % find the active branch name
                        chText = fileread(fullfile(c1chDirsToCopy{dDirIndex}, Experiment.chGitCurrentBranchMetadataPath));
                        
                        vdIndices = strfind(chText, '/');
                        chBranchName = chText(vdIndices(end)+1 : end - 1); % end -1 to remove new line char.
                        
                        % copy over the needed files
                        mkdir(fullfile(chCodeRepoOnWorkerFromLocalPath, Experiment.chGitFolderName));
                        mkdir(fullfile(chCodeRepoOnWorkerFromLocalPath, Experiment.chGitBranchesMetadataPath));
                        
                        copyfile(...
                            fullfile(c1chDirsToCopy{dDirIndex}, Experiment.chGitCurrentBranchMetadataPath),...
                            fullfile(chCodeRepoOnWorkerFromLocalPath, Experiment.chGitCurrentBranchMetadataPath));
                        
                        copyfile(...
                            fullfile(c1chDirsToCopy{dDirIndex}, Experiment.chGitBranchesMetadataPath, chBranchName),...
                            fullfile(chCodeRepoOnWorkerFromLocalPath, Experiment.chGitBranchesMetadataPath, chBranchName));
                        
                        copyfile(...
                            fullfile(c1chDirsToCopy{dDirIndex}, Experiment.chGitConfigMetadataPath),...
                            fullfile(chCodeRepoOnWorkerFromLocalPath, Experiment.chGitConfigMetadataPath));
                    end
                end
            end
            
            fprintf('done');
            fprintf(newline);
            fprintf(newline);
            
            % see if workers are ready/how many are ready
                        
            if stSettingsFromFile.UseDCSResourceManager
                DCSResourceManager.Connect(stSettingsFromFile.DCSResourceManagerConnectionPath);
                
                c1xInputVarargin = Experiment.ParseDCSResourceManagerRequestSettings(string(stSettingsFromFile.DCSResourceManagerWorkerRequest));
                DCSResourceManager.RequestWorkers(stSettingsFromFile.DCSResourceManagerRequestId, c1xInputVarargin{:});
                
                dNumOfWorkers = DCSResourceManager.WaitForRequestedWorkersToBeAvailable();
            else                
                if isempty(stSettingsFromFile.NumberOfDistributedWorkers)
                    oCluster = parcluster(stSettingsFromFile.ClusterProfileName);
                    dNumOfWorkers = oCluster.NumWorkers;
                else
                    dNumOfWorkers = stSettingsFromFile.NumberOfDistributedWorkers;
                end
            end
            
            % submit jobs as needed
            
            disp('Running experiments:');
            
            c1oCompletedJobs = cell(dNumExperiments,1);
            c1oRunningJobs = cell(dNumOfWorkers,1);
            vdJobsSubmitIndices = zeros(dNumOfWorkers,1);
            dNumExperimentsComplete = 0;
            
            dJobSubmitIndex = 1;
            
            while dNumExperimentsComplete < dNumExperiments
                for dJobIndex=1:dNumOfWorkers
                    if ~isempty(c1oRunningJobs{dJobIndex})
                        if ~strcmp(c1oRunningJobs{dJobIndex}.State, 'running')
                            % job complete
                            dNumExperimentsComplete = dNumExperimentsComplete + 1;
                            c1oRunningJobs{dJobIndex} = [];
                            
                            disp([' Exp. ', StringUtils.num2str_PadWithZeros(vdJobsSubmitIndices(dJobIndex), dNumCharsInExpNum), ' Complete (', num2str(dNumExperimentsComplete), '/', num2str(dNumExperiments), ' Complete)']);
                        end
                    end
                    
                    if isempty(c1oRunningJobs{dJobIndex}) && dJobSubmitIndex <= dNumExperiments
                        fprintf([' Submitting Exp. ', StringUtils.num2str_PadWithZeros(dJobSubmitIndex, dNumCharsInExpNum), '...']); 
                                                
                        c1oRunningJobs{dJobIndex} = batch(...
                            parcluster(stSettingsFromFile.ClusterProfileName),...
                            @RunBatchJob,...
                            2, {vsExperimentPaths(dJobSubmitIndex), stSettingsFromFile},...
                            'AutoAddClientPath', false, 'AutoAttachFiles', false);
                        vdJobsSubmitIndices(dJobIndex) = dJobSubmitIndex;
                        c1oCompletedJobs{dJobSubmitIndex} = c1oRunningJobs{dJobIndex};
                        
                        fprintf(['done (', num2str(dJobSubmitIndex), '/', num2str(dNumExperiments), ' Submitted)']);
                        fprintf(newline);
                        
                        dJobSubmitIndex = dJobSubmitIndex + 1;
                    end
                end
                
                if dNumExperimentsComplete < dNumExperiments
                    pause(15); % don't need to be constantly checking if a job is complete, wait between requests
                end
            end
            
            fprintf(newline);
            
            % copy completed experiments over from workers
            
            fprintf('Moving completed experiments from worker hosts to local machine...');
            
            vbExperimentErrored = false(dNumExperiments, 1);
            vsExperimentResultDirs = strings(dNumExperiments, 1);
                        
            for dExpIndex=1:dNumExperiments
                oJob = c1oCompletedJobs{dExpIndex};
                
                chHostName = oJob.Tasks.Worker.Host;
                chHostName = chHostName(1:end-1); % remove trailing '.'
                
                dWorkerIndex = find(stSettingsFromFile.RemotePoolWorkerHostComputerNames == string(chHostName));
                
                sExperimentPath = vsExperimentPaths(dExpIndex);
                
                oTask = oJob.findTask;
                c1xOutputs = oTask.OutputArguments;
                sCompletedExperimentPathOnWorkerFromWorker = c1xOutputs{1};
                vbExperimentErrored(dExpIndex) = c1xOutputs{2};
                
                sCompletedExperimentPathOnWorkerFromLocal = strrep(sCompletedExperimentPathOnWorkerFromWorker, stSettingsFromFile.RemotePoolLocalPathReplacePerHostForAccessByWorker(dWorkerIndex), stSettingsFromFile.RemotePoolLocalPathReplacePerHostForAccessByLocal(dWorkerIndex));
                
                sCompletedExperimentPathOnLocal = strrep(sCompletedExperimentPathOnWorkerFromWorker, stSettingsFromFile.RemotePoolLocalPathReplacePerHostForAccessByWorker(dWorkerIndex), stSettingsFromFile.RemotePoolLocalPathMatch);
                
                movefile(sCompletedExperimentPathOnWorkerFromLocal, sCompletedExperimentPathOnLocal);
                
                vsExperimentResultDirs(dExpIndex) = sCompletedExperimentPathOnLocal;
                
                % delete batch job token
                delete(fullfile(sCompletedExperimentPathOnLocal, Experiment.chBatchJobTokenFileName));
                
                % delete job from DCS
                oJob.delete;
            end
                        
            fprintf('done');
            fprintf(newline);
            
            % delete experiment and code folders
            
            fprintf('Removing experiment and code folders from worker hosts...');
            
            dNumWorkerHosts = length(stSettingsFromFile.RemotePoolWorkerHostComputerNames);
            
            % - delete experiment folders
            for dExperimentIndex=1:dNumExperiments
                sLocalExperimentPath = vsExperimentPaths(dExperimentIndex);
                
                for dHostIndex=1:dNumWorkerHosts
                    sWorkerPathFromLocal = strrep(sLocalExperimentPath, stSettingsFromFile.RemotePoolLocalPathMatch, stSettingsFromFile.RemotePoolLocalPathReplacePerHostForAccessByLocal{dHostIndex});
                    
                    rmdir(sWorkerPathFromLocal, 's');
                end
            end
            
            % - delete code folders
            for dHostIndex=1:dNumWorkerHosts
                for dDirIndex=1:length(c1chDirsToCopy)
                    chCodeRepoOnWorkerFromLocalPath = strrep(c1chDirsToCopy{dDirIndex}, stSettingsFromFile.RemotePoolLocalPathMatch, stSettingsFromFile.RemotePoolLocalPathReplacePerHostForAccessByLocal{dHostIndex});
                    
                    rmdir(chCodeRepoOnWorkerFromLocalPath, 's');
                end
            end
            
            fprintf('done');
            fprintf(newline);
            
            disp(' ');
            disp('Experiment Completion Status:');
            
            for dExperimentIndex=1:dNumExperiments
                chExpNum = num2str(dExperimentIndex);
                chExpNum = [repmat('0', 1, dNumCharsInExpNum-length(chExpNum)), chExpNum];
                
                if vbExperimentErrored(dExperimentIndex)
                    chErrorTag = char(hex2dec('2716'));
                else
                    chErrorTag = char(hex2dec('2714'));
                end
                
                disp([' ', chErrorTag, ' ', chExpNum, ': ', char(vsExperimentResultDirs(dExperimentIndex))]);
            end
        end
        
        function AddCentralLibraryToPathLite(chCentralLibraryDir)
        %Experiment.AddCentralLibraryToPathLite(chPathToCopyOfCentralLibrary)
        % INPUTS: 
        %    chCentralLibraryDir: the path to your local copy of the central library
        %       e.g. d:\users\yourusername\CentralLibrary
        % This function was developed to allow for adding the central library code to access 
        % auto-complete, and to allow for the command command line use of the library prior to 
        % running Experiment.Run(). The latter requires that only the experiment of interest 
        % has an Experiment.m file it in and a general addpath to the library causes multiple to be 
        % added, which then requires removing it from the path. In addition to omitting the 
        % Experiment.m files in the library the function omits other files not used in experiment 
        % writing such as tests ande demos, making the addpath quicker.
        
        arguments
            chCentralLibraryDir (1,:) char
        end
       
        chPathsToAdd = Experiment.GetCentralLibraryDirectoryPathsToAdd(chCentralLibraryDir);
        addpath(chPathsToAdd)
        
        end
        % >>>>>>>>>>>>>>> DURING EXPERIMENT <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function bBool = IsInInitialComputationEnvironment()
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:IsInInitialComputationEnvironment:NoExperiment',...
                    'No experiment is currently running. Use Experiment.Run() to start an experiment.');
            else
                bBool = ~Experiment.IsInParallelComputing();
            end
        end
        
        function oManager = GetLoopIterationManager(dNumIterations, NameValueArgs)
            arguments
                dNumIterations (1,1) double {mustBePositive, mustBeInteger}
                NameValueArgs.AvoidIterationRecomputationIfResumed (1,1) logical = false
            end
            
            global oExperiment;
            global oLoopIterationExperimentPortion;
            
            if ~Experiment.IsRunning()
                % only provide the random number generation management
                % piece
                try
                    oManager = RandomNumberGenerator();
                catch e
                    oManager = RandomNumberGenerator(7);
                end
                
                oManager.PreLoopSetup(dNumIterations);
            else
                if ~ParallelComputingUtils.IsInParallelComputing()
                    oExperiment.EnsureSpecifiedParpoolIsRunning();
                else
                    if NameValueArgs.AvoidIterationRecomputationIfResumed
                        error(...
                            'Experiment:GetLoopIterationManager:CannotAvoidIterationRecomputionInParfor',...
                            'The name-value pair "AvoidIterationRecomputationIfResumed" cannot be set to true within a parallel computing environment.');
                    end
                end
                
                if isempty(oLoopIterationExperimentPortion)
                    oParent = oExperiment;
                    
                    if NameValueArgs.AvoidIterationRecomputationIfResumed
                        if oParent.bAvoidIterationRecomputationIfResumed
                            error(...
                                'Experiment:GetLoopIterationManager:CannotNestAvoidingIterationRecompution',...
                                'Cannot nest multiple loops with the LoopIterationManager set with "AvoidIterationRecomputationIfResumed" to true.');
                        end
                        
                        oParent.bAvoidIterationRecomputationIfResumed = true;
                        oParent.dAvoidIterationRecomputationIfResumedIndex = oParent.dAvoidIterationRecomputationIfResumedIndex + 1;
                    end
                else
                    oParent = oLoopIterationExperimentPortion;
                    
                    if NameValueArgs.AvoidIterationRecomputationIfResumed
                        error(...
                            'Experiment:GetLoopIterationManager:CannotAvoidIterationRecomputionWithinLoopIterationExperimentPortion',...
                            'The name-value pair "AvoidIterationRecomputationIfResumed" cannot be set to true when the Experiment manager is LoopIterationExperimentPortion (e.g. within a parallel computing environment).');
                    end
                end
                
                oManager = ExperimentLoopIterationManager(oParent, dNumIterations, NameValueArgs.AvoidIterationRecomputationIfResumed);
                
                if NameValueArgs.AvoidIterationRecomputationIfResumed
                    chSavePath = fullfile(...
                        oParent.GetResumePointRootPath(),...
                        Experiment.chAvoidIterationRecomputationFilename);
                    
                    FileIOUtils.SaveMatFile(...
                        chSavePath,...
                        Experiment.AvoidIterationRecomputationFileLoopIterationManagerVarName, oManager,...
                        Experiment.AvoidIterationRecomputationFileIndexVarName, oParent.dAvoidIterationRecomputationIfResumedIndex);
                end
            end
        end
        
        function chResultsFilePath = GetResultsDirectory()
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:GetResultsDirectory:NoExperiment',...
                    'No experiment is currently running. Use Experiment.Run() to start an experiment.');
            else
                if Experiment.IsInParallelComputing && ~Experiment.IsRunningManagedLoopIteration()
                    Experiment.ThrowNoParallelIterationManagerFoundError();
                else
                    oManager = Experiment.GetCurrentExperimentManager();
                    
                    chResultsFilePath = oManager.GetCurrentSection().GetResultsDirectoryPathWithinSubSections();
                    chResultsFilePath = fullfile(oManager.GetResultsDirectoryRootPath(), chResultsFilePath);
                    
                    Experiment.MakeDirIfRequired(chResultsFilePath);
                end
            end
        end
        
        function [bAutoAddEntriesIntoExperimentReport, bAutoSaveObjects, bAutoSaveSummaryFiles] = GetJournalingSettings()
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:GetJournalingSettings:NoExperiment',...
                    'No experiment is currently running. Use Experiment.Run() to start an experiment.');
            else
                if Experiment.IsInParallelComputing && ~Experiment.IsRunningManagedLoopIteration()
                    Experiment.ThrowNoParallelIterationManagerFoundError();
                else
                    oManager = Experiment.GetCurrentExperimentManager();
                    
                    [bAutoAddEntriesIntoExperimentReport, bAutoSaveObjects, bAutoSaveSummaryFiles] = oManager.GetJournalingSettings_protected();
                end
            end
        end
        
        function bIsRunning = IsRunning()
            global oExperiment;
            global oLoopIterationExperimentPortion;
            
            bIsRunning = ~isempty(oExperiment) || ~isempty(oLoopIterationExperimentPortion);
        end
        
        function bIsInDebugMode = IsInDebugMode()
            global oExperiment;
            
            if Experiment.IsRunning()
                bIsInDebugMode = oExperiment.bInDebugMode;
            else
                bIsInDebugMode = false;
            end
        end
        
        function bIsInResumeMode = IsInResumeMode()
            global oExperiment;
            
            if Experiment.IsRunning()
                bIsInResumeMode = oExperiment.bInResumeMode;
            else
                bIsInResumeMode = false;
            end
        end
        
        function bIsBatchJob = IsBatchJob()
            global oExperiment;
            
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:IsBatchJob:NoExperiment',...
                    'No experiment is currently running. Use Experiment.Run() to start an experiment.');
            else
                bIsBatchJob = oExperiment.bIsBatchJob;
            end
        end
        
        function chUniqueFilePath = GetUniqueResultsFileNamePath()
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:GetResultsFileName:NoExperiment',...
                    'No experiment is currently running. Use Experiment.Run() to start an experiment.');
            else
                if Experiment.IsInParallelComputing && ~Experiment.IsRunningManagedLoopIteration()
                    Experiment.ThrowNoParallelIterationManagerFoundError();
                else
                    oManager = Experiment.GetCurrentExperimentManager();
                    
                    chUniqueFilePath = oManager.GetCurrentSection().GetUniqueResultsFileNamePathWithinSubSections();
                    chUniqueFilePath = fullfile(oManager.GetResultsDirectoryRootPath(), chUniqueFilePath);
                    
                    [chDir,~] = Experiment.SeparateFilePathAndLastItem(chUniqueFilePath);
                    Experiment.MakeDirIfRequired(chDir);
                end
            end
        end
        
        function chDataPath = GetDataPath(chDataPathLabel)
            global oExperiment;
            global oLoopIterationExperimentPortion;
            
            if ~Experiment.IsRunning % there's no experiment running, but since users can run main.m without running experiment, we'll just read datapaths.txt on the fly from the current directory and see what we can get
                [c1chDataPathLabels, c1chDataPaths] = Experiment.LoadDataPathsFile();
            else % experiment is already running, so look in the loaded data paths
                if Experiment.IsInParallelComputing && ~Experiment.IsRunningManagedLoopIteration()
                    Experiment.ThrowNoParallelIterationManagerFoundError();
                else
                    if Experiment.IsRunningManagedLoopIteration()
                        [c1chDataPaths, c1chDataPathLabels] = oLoopIterationExperimentPortion.GetDataPathsAndLabels();
                    else
                        [c1chDataPaths, c1chDataPathLabels] = oExperiment.GetDataPathsAndLabels();
                    end
                end
            end
            
            chDataPath = '';
            
            for dSearchIndex=1:length(c1chDataPathLabels)
                if strcmp(c1chDataPathLabels{dSearchIndex}, chDataPathLabel) % have a match!
                    chDataPath = c1chDataPaths{dSearchIndex};
                end
            end
            
            if isempty(chDataPath)
                error(...
                    'Experiment:GetDataPath:NoMatchFound',...
                    ['No data path with label "', chDataPathLabel, '" found.']);
            end
        end
        
        function [chAnacondaInstallPath, chAnacondaEnvironmentName] = GetAnacondaInstallPathAndEnvironmentNameSettings()
            global oExperiment;
            
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:GetAnacondaInstallPathAndEnvironmentNameSettings:NoExperiment',...
                    'No experiment is currently running. Use Experiment.Run() to start an experiment.');
            else
                chAnacondaInstallPath = oExperiment.chAnacondaInstallPath;
                chAnacondaEnvironmentName = oExperiment.chAnacondaEnvironmentName;
            end
        end
        
        function StartNewSection(chSectionName)
            arguments
                chSectionName (1,:) char
            end
            
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            global oExperiment;
            
            if ~Experiment.IsRunning()
                % do nothing...will allow this so that main.m will stay
                % runnable even if Experiment is not managing
            else
                if Experiment.IsInParallelComputing && ~Experiment.IsRunningManagedLoopIteration()
                    Experiment.ThrowNoParallelIterationManagerFoundError();
                else
                    if Experiment.IsRunningManagedLoopIteration()
                        warning(...
                            'Experiment:StartNewSection:InvalidInParallelIteration',...
                            'A new section cannot be ended or begun within a parallel iteration.');
                    else
                        if oExperiment.bSectionCurrentlyActive
                            oExperiment.FinalizeSection();
                        end
                        
                        oExperiment.InitializeSection(chSectionName);
                        
                        fprintf(newline);
                        fprintf(newline);
                        fprintf(repmat('*',1,100));
                        fprintf(newline);
                        fprintf(newline);
                        fprintf(['Experiment Section: ', chSectionName]);
                        fprintf(newline);
                        fprintf(['  Start Time: ', datestr(oExperiment.dtCurrentSectionStartTime, 'mmm dd, yyyy HH:MM:SS')]);
                        fprintf(newline);
                        fprintf(newline);
                        fprintf(repmat('*',1,100));
                        fprintf(newline);
                        fprintf(newline);
                    end
                end
            end
        end
        
        function EndCurrentSection()
            global oExperiment;
            
            if ~Experiment.IsRunning()
                % do nothing...will allow this so that main.m will stay
                % runnable even if Experiment is not managing
            else
                if Experiment.IsInParallelComputing && ~Experiment.IsRunningManagedLoopIteration()
                    Experiment.ThrowNoParallelIterationManagerFoundError();
                else
                    if Experiment.IsRunningManagedLoopIteration()
                        warning(...
                            'Experiment:EndCurrentSection:InvalidInParallelIteration',...
                            'A new section cannot be ended or begun within a parallel iteration.');
                    else
                        if isempty(oExperiment.bSectionCurrentlyActive)
                            % just warn:
                            warning('There is no current section running. No action will be performed.');
                        else
                            oExperiment.FinalizeSection();
                            oExperiment.oCurrentReportResultsSection = [];
                            oExperiment.dtLastSectionEndTime = datetime(now, 'ConvertFrom', 'datenum');
                            oExperiment.bSectionCurrentlyActive = false;
                        end
                    end
                end
            end
        end
        
        function StartNewSubSection(chSubSectionName, NameValueArgs)
            arguments
                chSubSectionName (1,:) char
                NameValueArgs.MaxNumberOfSubSections (1,1) double {mustBePositive, mustBeInteger}
            end
            
            if ~Experiment.IsRunning()
                % do nothing
            else
                c1xNameValueArgs = namedargs2cell(NameValueArgs);
                
                Experiment.GetCurrentExperimentSection().StartNewSubSection(chSubSectionName, c1xNameValueArgs{:});
            end
        end
        
        function EndCurrentSubSection()
            if ~Experiment.IsRunning()
                % do nothing
            else
                oManager = Experiment.GetCurrentExperimentManager();
                
                Experiment.GetCurrentExperimentSection().EndCurrentSubSection(oManager.GetResultsDirectoryRootPath());
            end
        end
        
        function AddToReport(c1xReportGeneratorItems)
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:AddToReport:NoExperimentRunning',...
                    'No experiment is currently running. Use Experiment.Run() to start an experiment.');
            else
                if ParallelComputingUtils.IsInParallelComputing && ~Experiment.IsRunningManagedLoopIteration()
                    Experiment.ThrowNoParallelIterationManagerFoundError();
                else
                    if ~iscell(c1xReportGeneratorItems)
                        c1xReportGeneratorItems = {c1xReportGeneratorItems};
                    end
                    
                    Experiment.GetCurrentExperimentSection().AddToReport(c1xReportGeneratorItems);
                end
            end
        end
        
        function StartParallelPool()
            global oExperiment;
            
            if ~Experiment.IsRunning()
                % don't really need to do anything, but we'll be nice and
                % start a parpool here
                parpool();
            else
                if ~ParallelComputingUtils.IsInParallelComputing()
                    oExperiment.EnsureSpecifiedParpoolIsRunning();
                end
            end
        end
        
        
        % >>>>>>>>>>>>>>>>> RESUME CALLS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function ResumePointSetup()
            % validation
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'Experiment:ResumePointSetup:InvalidParallelComputing',...
                    'Cannot setup resume point in a parallel computing environment.');
            end
            
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:ResumePointSetup:NoExperimentRunning',...
                    'No Experiment is running.');
            end
            
            Experiment.CallMustBeFromMainFile();
            
            oExperiment = Experiment.GetCurrentExperimentManager();
            
            if oExperiment.bResumePointActive
                error(...
                    'Experiment:ResumePointSetup:ResumePointAlreadyActive',...
                    'A resume point is already active and resume points cannot be nested. Use "Experiment.ResumePointTeardown()" before calling "Experiment.ResumePointSetup()" again.');
            end
            
            % perform setup
            oExperiment.bResumePointActive = true;
            oExperiment.dCurrentRestorePointIndex = oExperiment.dCurrentRestorePointIndex + 1;
        end
        
        function ResumePointTeardown(NameValueArgs)
            arguments
                NameValueArgs.DeletePreviousResumePoints (1,1) logical = false
            end
            
            % validation
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'Experiment:ResumePointTeardown:InvalidParallelComputing',...
                    'Cannot setup resume point in a parallel computing environment.');
            end
            
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:ResumePointTeardown:NoExperimentRunning',...
                    'No Experiment is running.');
            end
            
            Experiment.CallMustBeFromMainFile();
            
            oExperiment = Experiment.GetCurrentExperimentManager();
            
            if ~oExperiment.bResumePointActive
                error(...
                    'Experiment:ResumePointTeardown:ResumePointNotActive',...
                    'A resume point is not active and so a teardown cannot be performed. Use "Experiment.ResumePointSetup()" before calling "Experiment.ResumePointTeardown()".');
            end
            
            % perform setup
            bSaveOccured = oExperiment.bResumePointWorkspaceSaveOccured;
            
            if bSaveOccured
                chGlobalVarsFilePath = oExperiment.GetResumePointGlobalVarsSavePath();
                chRandomNumberGeneratorFilePath = oExperiment.GetResumePointRandomNumberGeneratorSavePath();
                
                if NameValueArgs.DeletePreviousResumePoints
                    for dResumePointIndex=1:oExperiment.dCurrentRestorePointIndex-1
                        chRootPath = oExperiment.chNewWorkingDirectory;
                        chFolderName = Experiment.chResumePointSaveFolder;
                        
                        chWorkspaceFilename = Experiment.CreateResumePointWorkspaceFilename(dResumePointIndex);
                        chGlobalVarsFilename = Experiment.CreateResumePointGlobalVarsFilename(dResumePointIndex);
                        chRandomNumberGeneratorFilename = Experiment.CreateResumePointRandomNumberGeneratorFilename(dResumePointIndex);
                        
                        FileIOUtils.DeleteFileIfItExists(fullfile(chRootPath, chFolderName, chWorkspaceFilename));
                        FileIOUtils.DeleteFileIfItExists(fullfile(chRootPath, chFolderName, chGlobalVarsFilename));
                        FileIOUtils.DeleteFileIfItExists(fullfile(chRootPath, chFolderName, chRandomNumberGeneratorFilename));
                    end
                end
            end
            
            if oExperiment.bResumePointWorkspaceLoadOccured
                % save the experiment before loading the globals
                oExperimentForResume = oExperiment;
                
                % load globals
                stLoadedVars = load(oExperimentForResume.GetResumePointGlobalVarsLoadPath());
                
                c1chGlobalVarNames = fields(stLoadedVars);
                
                for dGlobalIndex=1:length(c1chGlobalVarNames)
                    clear(c1chGlobalVarNames{dGlobalIndex}); % prevents warnings
                    eval(['global ', c1chGlobalVarNames{dGlobalIndex}, ';']);
                    eval([c1chGlobalVarNames{dGlobalIndex}, ' = stLoadedVars.', c1chGlobalVarNames{dGlobalIndex}, ';']);
                end
                
                % the Experiment object that was used for the original
                % experiment (that errored and is now being resumed), is
                % now in the global "oExperiment". This good, minus that it
                % no longer knows that it is a different working directory,
                % different code, etc., and that it is being resumed. The
                % two experiments therefore need to be merged:
                oExperimentForResume.oCurrentSection = oExperiment.oCurrentSection;
                oExperimentForResume.c1chSectionNames = oExperiment.c1chSectionNames;
                oExperimentForResume.c1chNestedSubSectionNames = oExperiment.c1chNestedSubSectionNames;
                oExperimentForResume.bSectionCurrentlyActive = oExperiment.bSectionCurrentlyActive;
                oExperimentForResume.dCurrentSectionNumber = oExperiment.dCurrentSectionNumber;
                oExperimentForResume.chCurrentSectionResultsPath = oExperiment.chCurrentSectionResultsPath;
                oExperimentForResume.oCurrentReportResultsSection = oExperiment.oCurrentReportResultsSection;
                oExperimentForResume.dtCurrentSectionStartTime = oExperiment.dtCurrentSectionStartTime;
                oExperimentForResume.dtLastSectionEndTime = oExperiment.dtLastSectionEndTime;
                oExperimentForResume.c1hReportFigureHandles = oExperiment.c1hReportFigureHandles;
                oExperimentForResume.vdtSectionStartTimes = oExperiment.vdtSectionStartTimes;
                oExperimentForResume.vdtSectionEndTimes = oExperiment.vdtSectionEndTimes;
                
                if oExperimentForResume.bInDebugMode
                    c1oReportSectionsFromExperimentForResume = oExperimentForResume.c1oReportSections(1:3);
                else
                    c1oReportSectionsFromExperimentForResume = oExperimentForResume.c1oReportSections(1:2);
                end
                
                if oExperiment.bInDebugMode
                    c1oReportSectionsFromExperiment = oExperiment.c1oReportSections(4:end);
                else
                    c1oReportSectionsFromExperiment = oExperiment.c1oReportSections(3:end);
                end
                
                oExperimentForResume.c1oReportSections = [c1oReportSectionsFromExperimentForResume; c1oReportSectionsFromExperiment];
                
                oExperiment = oExperimentForResume;
                
                % restore RNG
                RandomNumberGenerator.RestoreState(oExperiment.GetResumePointRandomNumberGeneratorLoadPath());
            end
            
            oExperiment.bResumePointActive = false;
            oExperiment.bResumePointWorkspaceSaveOccured = false;
            oExperiment.bResumePointWorkspaceLoadOccured = false;
            
            % save globals and RNG if a saved occured
            if bSaveOccured
                % globals
                vstGlobalVars = whos('global');
                
                dNumGlobalVars = length(vstGlobalVars);
                c1xSaveMatVarargin = cell(1,dNumGlobalVars);
                
                for dGlobalIndex=1:dNumGlobalVars
                    clear(vstGlobalVars(dGlobalIndex).name); % prevents warnings
                    eval(['global ', vstGlobalVars(dGlobalIndex).name, ';']);
                    
                    c1xSaveMatVarargin{dGlobalIndex} = vstGlobalVars(dGlobalIndex).name;
                end
                
                save(chGlobalVarsFilePath, c1xSaveMatVarargin{:});
                
                % RNG
                RandomNumberGenerator.SaveState(chRandomNumberGeneratorFilePath);
            end
        end
        
        function bRunCodeInIfStatement = ResumePointRunCode()
            % validation
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'Experiment:ResumePointIfCondition:InvalidParallelComputing',...
                    'Cannot setup resume point in a parallel computing environment.');
            end
            
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:ResumePointIfCondition:NoExperimentRunning',...
                    'No Experiment is running.');
            end
            
            Experiment.CallMustBeFromMainFile();
            
            oExperiment = Experiment.GetCurrentExperimentManager();
            
            if ~oExperiment.bResumePointActive
                error(...
                    'Experiment:ResumePointIfCondition:ResumePointNotActice',...
                    'A resume point is not active. Use "Experiment.ResumePointSetup()" before calling "if Experiment.ResumePointRunCode()"');
            end
            
            % perform if statement
            
            %  If the Experiment is not being resumed (e.g.
            %  Experiment.Resume() was not called), this statement should
            %  just return true. The code inside the if statement will then
            %  run as it should.
            %  If the Experiment is being resumed, it's a bit more
            %  complicated...
            %   1)
            
            if ~oExperiment.bInResumeMode
                bRunCodeInIfStatement = true;
            else
                if oExperiment.WasCurrentResumePointSaved()
                    bRunCodeInIfStatement = false;
                else
                    bRunCodeInIfStatement = true;
                end
            end
            
            % if we're running code for the first time and we're in
            % "resume" mode, mark it in the report
            if oExperiment.bInResumeMode && bRunCodeInIfStatement && ~oExperiment.bResumeModeHasRunCode
                oExperiment.c1oReportSections{end}.add(ReportUtils.CreateParagraphWithBoldLabel(repmat('-',1,125),''));
                oExperiment.c1oReportSections{end}.add(ReportUtils.CreateParagraphWithBoldLabel('Resumed experiment now executing main.m',''));
                oExperiment.c1oReportSections{end}.add(ReportUtils.CreateParagraph('Previous report entries were from the experiment being resumed from'));
                oExperiment.c1oReportSections{end}.add(ReportUtils.CreateParagraphWithBoldLabel(repmat('-',1,125),''));
                
                oExperiment.bResumeModeHasRunCode = true;
            end
        end
        
        function bSaveWorkspace = ResumePointSaveWorkspace()
            % validation
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'Experiment:ResumePointSavedWorkspace:InvalidParallelComputing',...
                    'Cannot use resume points in a parallel computing environment.');
            end
            
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:ResumePointSaveWorkspace:NoExperimentRunning',...
                    'No Experiment is running.');
            end
            
            Experiment.CallMustBeFromMainFile();
            
            oExperiment = Experiment.GetCurrentExperimentManager();
            
            if ~oExperiment.bResumePointActive
                error(...
                    'Experiment:ResumePointSaveWorkspace:ResumePointNotActice',...
                    'A resume point is not active. Use "Experiment.ResumePointSetup()" before calling "if Experiment.ResumePointSaveOrLoadWorkspace()"');
            end
            
            % calculate boolean
            if ~oExperiment.bInResumeMode
                bSaveWorkspace = true;
            else
                if oExperiment.WasCurrentResumePointSaved()
                    bSaveWorkspace = false;
                else
                    bSaveWorkspace = true;
                end
            end
        end
        
        function bLoadWorkspace = ResumePointLoadWorkspace()
            % validation
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'Experiment:ResumePointLoadWorkspace:InvalidParallelComputing',...
                    'Cannot use resume points in a parallel computing environment.');
            end
            
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:ResumePointLoadWorkspace:NoExperimentRunning',...
                    'No Experiment is running.');
            end
            
            Experiment.CallMustBeFromMainFile();
            
            oExperiment = Experiment.GetCurrentExperimentManager();
            
            if ~oExperiment.bResumePointActive
                error(...
                    'Experiment:ResumePointLoadWorkspace:ResumePointNotActice',...
                    'A resume point is not active. Use "Experiment.ResumePointSetup()" before calling "if Experiment.ResumePointSaveOrLoadWorkspace()"');
            end
            
            % calculate boolean
            if ~oExperiment.bInResumeMode
                bLoadWorkspace = false;
            else
                [~, bCanLoad] = oExperiment.WasCurrentResumePointSaved();
                
                if bCanLoad
                    bLoadWorkspace = true;
                else
                    bLoadWorkspace = false;
                end
            end
        end
        
        function chSavePath = GetResumePointWorkspaceSavePath()
            % validation
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'Experiment:GetResumePointWorkspaceSavePath:InvalidParallelComputing',...
                    'Cannot use resume points in a parallel computing environment.');
            end
            
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:GetResumePointWorkspaceSavePath:NoExperimentRunning',...
                    'No Experiment is running.');
            end
            
            Experiment.CallMustBeFromMainFile();
            
            oExperiment = Experiment.GetCurrentExperimentManager();
            
            if ~oExperiment.bResumePointActive
                error(...
                    'Experiment:GetResumePointWorkspaceSavePath:ResumePointNotActice',...
                    'A resume point is not active. Use "Experiment.ResumePointSetup()" before calling "Experiment.GetResumePointWorkspaceSavePath()"');
            end
            
            % get path
            chSavePath = oExperiment.GetCurrentResumePointSavePath();
            oExperiment.bResumePointWorkspaceSaveOccured = true;
        end
        
        function chLoadPath = GetResumePointWorkspaceLoadPath()
            % validation
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'Experiment:GetResumePointWorkspaceLoadPath:InvalidParallelComputing',...
                    'Cannot use resume points in a parallel computing environment.');
            end
            
            if ~Experiment.IsRunning()
                error(...
                    'Experiment:GetResumePointWorkspaceLoadPath:NoExperimentRunning',...
                    'No Experiment is running.');
            end
            
            Experiment.CallMustBeFromMainFile();
            
            oExperiment = Experiment.GetCurrentExperimentManager();
            
            if ~oExperiment.bResumePointActive
                error(...
                    'Experiment:GetResumePointWorkspaceLoadPath:ResumePointNotActice',...
                    'A resume point is not active. Use "Experiment.ResumePointSetup()" before calling "Experiment.GetResumePointWorkspaceLoadPath()"');
            end
            
            % get path
            chLoadPath = oExperiment.GetCurrentResumePointLoadPath();
            oExperiment.bResumePointWorkspaceLoadOccured = true;
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract) % DELETE IF UNUSED
    end
    
    
    methods (Access = protected, Static = false) % DELETE IF UNUSED
    end
    
    
    methods (Access = protected, Static = true) % DELETE IF UNUSED
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = ?ExperimentLoopIterationManager)
        
        function [bAutoAddEntriesIntoExperimentReport, bAutoSaveObjects, bAutoSaveSummaryFiles] = GetJournalingSettings_protected(obj)
            bAutoAddEntriesIntoExperimentReport = obj.bAutoAddEntriesIntoExperimentReport;
            bAutoSaveObjects = obj.bAutoSaveObjects;
            bAutoSaveSummaryFiles = obj.bAutoSaveSummaryFiles;
        end
        
        function oSection = GetCurrentSectionForExperimentLoopIterationManager(obj)
            oSection = obj.GetCurrentSection().GetActiveSection();
        end
        
        function SetCurrentSectionForExperimentLoopIterationManager(obj, oSection)
            oCurrentSection = obj.GetCurrentSection();
            
            if oCurrentSection.IsUsingSubSection
                oCurrentSection.SetActiveSection(oSection);
            else
                obj.oCurrentSection = oSection;
            end
        end
        
        function chDirectory = GetResultsDirectoryRootPath(obj)
            chDirectory = fullfile(obj.chNewWorkingDirectory, Experiment.chResultsDirectoryName);
        end
        
        function chInitialComputationHostComputerName = GetInitialComputationHostComputerName(obj)
            chInitialComputationHostComputerName = obj.chInitialComputationHostComputerName;
        end
        
        function dInitialComputationWorkerNumberOrProcessId = GetInitialComputationWorkerNumberOrProcessId(obj)
            dInitialComputationWorkerNumberOrProcessId = obj.dInitialComputationWorkerNumberOrProcessId;
        end
        
        function chClusterProfileName = GetClusterProfileName(obj)
            chClusterProfileName = obj.chClusterProfileName;
        end
        
        function [chRemotePoolLocalPathMatch, c1chRemotePoolWorkerHostComputerNames, c1chRemotePoolLocalPathReplacePerHostForAccessByWorker, c1chRemotePoolLocalPathReplacePerHostForAccessByLocal] = GetRemoteWorkersConfiguration(obj)
            chRemotePoolLocalPathMatch = obj.chRemotePoolLocalPathMatch;
            c1chRemotePoolWorkerHostComputerNames = obj.c1chRemotePoolWorkerHostComputerNames;
            c1chRemotePoolLocalPathReplacePerHostForAccessByWorker = obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker;
            c1chRemotePoolLocalPathReplacePerHostForAccessByLocal = obj.c1chRemotePoolLocalPathReplacePerHostForAccessByLocal;
        end
        
        function [c1chDataPaths, c1chDataPathLabels] = GetDataPathsAndLabels(obj)
            c1chDataPaths = obj.c1chDataPaths;
            c1chDataPathLabels = obj.c1chDataPathLabels;
        end
    end
    
    
    methods (Access = {?ExperimentLoopIterationManager, ?Experiment}, Static = true)
        
        function UpdateParpoolIfUsingDCSResourceManager()
            global oExperiment;
                        
            if oExperiment.bCreateDistributedParpool && oExperiment.bUseDCSResourceManager
                oExperiment.EnsureSpecifiedParpoolIsRunning();
            end
        end
        
        function SetAvoidIterationRecomputationIfResumed(bAvoidIterationRecomputationIfResumed)
            arguments
                bAvoidIterationRecomputationIfResumed (1,1) logical
            end
            
            global oExperiment;
            
            oExperiment.bAvoidIterationRecomputationIfResumed = bAvoidIterationRecomputationIfResumed;
        end
        
        function SetUpdateCurrentSectionAfterLoopIterationManagerTeardown(oUpdatedCurrentSection)
            global oExperiment;
            
            oExperiment.SetCurrentSectionForExperimentLoopIterationManager(oUpdatedCurrentSection);
        end
        
        function [chHostComputerName, dWorkerNumberOrProcessId] = GetCurrentComputationEnvironmentDetails()
            oTask = getCurrentTask();
            chHostComputerName = char(ComputingEnvironmentUtils.GetCurrentComputerName());
            
            if isempty(oTask) % we're running locally and NOT as a batch
                dWorkerNumberOrProcessId = 0;
            else
                oWorker = oTask.Worker;
                
                if isa(oWorker, 'parallel.cluster.MJSWorker') % don't have access to process ID, extract the worker number from the worker name
                    chWorkerName = oWorker.Name;
                    chWorkerStringTag = '_worker';
                    
                    dWorkerIndex = strfind(chWorkerName, chWorkerStringTag);
                    
                    if ~isscalar(dWorkerIndex) || isnan(str2double(chWorkerName(dWorkerIndex+length(chWorkerStringTag) : end)))
                        error(...
                            'Experiment:GetCurrentComputationEnvironmentDetails:InvalidWorkerNameFormat',...
                            'Worker names must be specified as "<HOSTNAME>._workerXX"');
                    end
                    
                    dWorkerNumberOrProcessId = str2double(chWorkerName(dWorkerIndex+length(chWorkerStringTag) : end));
                elseif isa(oWorker, 'parallel.cluster.CJSWorker') % easy, pick off the process ID
                    dWorkerNumberOrProcessId = oWorker.ProcessId;
                else
                    error(...
                        'Experiment:GetCurrentComputationEnvironmentDetails:InvalidWorkerType',...
                        'Worker must be of type parallel.cluster.MJSWorker or parallel.cluster.CJSWorker');
                end
            end
        end
        
        function [oLoopIterationManagerFromResume, dAvoidIterationRecomputationIfResumedIndexFromResume] = GetAvoidIterationRecomputationDataFromExperimentBeingResumed()
            global oExperiment;
            
            chLoadPath = fullfile(...
                oExperiment.chResumeFromPath,...
                Experiment.chResumePointSaveFolder,...
                Experiment.chAvoidIterationRecomputationFilename);
            
            if ~isfile(chLoadPath)
                error(...
                    'Experiment:GetAvoidIterationRecomputationDataFromExperimentBeingResumed:NoResumePointDataSaved',...
                    'The experiment being resumed from does not have a resume point data folder.');
            else
                [oLoopIterationManagerFromResume, dAvoidIterationRecomputationIfResumedIndexFromResume] = FileIOUtils.LoadMatFile(...
                    chLoadPath,...
                    Experiment.AvoidIterationRecomputationFileLoopIterationManagerVarName,...
                    Experiment.AvoidIterationRecomputationFileIndexVarName);
            end
        end
        
        function dCurrentAvoidIterationRecomputationIfResumedIndex = GetCurrentAvoidIterationRecomputationIfResumedIndex()
            global oExperiment;
            
            dCurrentAvoidIterationRecomputationIfResumedIndex = oExperiment.dAvoidIterationRecomputationIfResumedIndex;
        end
    end
    
    
    
    methods (Access = private)
        
        function obj = Experiment(bDebug, bResume, NameValueArgs)
            global oLoopIterationExperimentPortion;
            oLoopIterationExperimentPortion = [];
            
            obj.bInDebugMode = bDebug;
            obj.bInResumeMode = bResume;
            obj.chStartingWorkingDirectory = pwd;
            
            % prepare directories/paths:
            obj.ValidateStartingWorkingDirectory();
            obj.LoadAndSetExperimentSettingsFile(NameValueArgs);
        end
        
        function [sCompletedExperimentPath, bErrored] = RunMain(obj)
            
            % make global obj
            global oExperiment;
            oExperiment = obj;
            
            % variable to hold error
            oError = [];
            bResultsDirectoryExists = false;
            bReportStarted = false;
            bPathsAdded = false;
            sCompletedExperimentPath = "";
            bErrored = logical.empty;
            
            try                
                % start it up
                obj.dtStartingTime = datetime(now, 'ConvertFrom', 'datenum');
                obj.dtLastSectionEndTime = obj.dtStartingTime;
                
                % prepare directories/paths:
                obj.CreateNewWorkingDirectory();
                sCompletedExperimentPath = string(obj.chNewWorkingDirectory);
                
                obj.PrepareWorkingDirectory();
                bResultsDirectoryExists = true;
                
                fprintf('Removing/adding paths...');
                
                if obj.bInDebugMode
                    fprintf('SKIPPED FOR DEBUG');
                else
                    obj.chPreExperimentPathCache = path;
                    obj.RemoveAllCodeFromPath();
                    obj.AddAllCodeToPath();
                    bPathsAdded = true;
                    fprintf('Done');
                end
                
                % record initial computing environment
                obj.SetInitialComputationEnvironment();
                
                if isfile(Experiment.chBatchJobTokenFileName) % is batch job token exists, mark it as running as such
                    obj.bIsBatchJob = true;
                end
                
                fprintf(newline);
                
                % stash path (check to see if it's changed at all by the end of
                % the experiment)
                obj.chStartingPathCache = path;
                
                obj.InitializeReport();
                bReportStarted = true;
                
                obj.TurnOnConsoleOutputTracking();
                
                try
                    % set up the random number generator to make it repeatable
                    RandomNumberGenerator.Reset('SuppressWarnings');
                    
                    dSeed = 7; % lucky number 7, just seeding numbers for ground-breaking research
                    oRandNumGen = RandomNumberGenerator(dSeed); % seed is required!
                catch e
                    warning(...
                        'The class "RandomNumberGenerator" from the CentralLibrary was not found. MATLAB''s rng will be set instead. Replication of results not guaranteed.');
                    
                    dSeed = 7;
                    rng(dSeed);
                end
                
                if ispc
                    try
                        % set up the Python random seed counter to be
                        % reproducible. This doesn't actually call any Python
                        % code, but rather sets the counter in PythonUtils,
                        % from which seeds can be extracted in a reproducible
                        % way, which are then passed on to Python calls as
                        % needed by the user
                        PythonUtils.ResetPythonRandomSeedNumber();
                    catch e
                        warning(...
                            'The class "PythonUtils" from the CentralLibrary was not found. Control of Python random numbers is therefore not possible.');
                    end
                end
                
                % run experiment
                fprintf('Running main.m...');
                fprintf(newline);
                fprintf(newline);
                fprintf(newline);
                fprintf(repmat('*',1,100));
                fprintf(newline);
                fprintf(newline);
                fprintf(newline);
                
                % *********************************************************
                % *********************************************************
                run('main.m');
                % *********************************************************
                % *********************************************************
            catch e
                oError = e;
            end
            
            fprintf(newline);
            fprintf(newline);
            fprintf(newline);
            fprintf(repmat('*',1,100));
            fprintf(newline);
            fprintf(newline);
            fprintf(newline);
            
            % shut it down
              
            % - covert code folders to .zip if not in debug mode
            if ~obj.bInDebugMode
                try
                    voEntries = dir(fullfile(obj.chNewWorkingDirectory, Experiment.chCodeDirectoryName));
                    voEntries = voEntries(3:end);
                    dNumEntries = length(voEntries);
                    vsEntryPaths = strings(dNumEntries,1);
                    
                    for dEntryIndex=1:dNumEntries
                        vsEntryPaths(dEntryIndex) = fullfile(obj.chNewWorkingDirectory, Experiment.chCodeDirectoryName, voEntries(dEntryIndex).name);
                    end
                    
                    zip(fullfile(obj.chNewWorkingDirectory, [Experiment.chCodeDirectoryName, '.zip']), vsEntryPaths);
                    rmdir(fullfile(obj.chNewWorkingDirectory, Experiment.chCodeDirectoryName), 's');
                catch e
                end
            end
            
            % - delete copied files on remote workers if needed
            if isempty(oError) && obj.bCreateDistributedParpool 
                try
                    disp('Deleting files from remote workers...');
                    
                    % remove paths from workers
                    bResetWorkingDirectory = true;
                    Experiment.AdjustPathsOnParforWorkers(true, false, false, obj.chNewWorkingDirectory, obj.chRemotePoolLocalPathMatch, obj.c1chRemotePoolWorkerHostComputerNames, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker, bResetWorkingDirectory);
                    
                    % shut down pool
                    if obj.bUseDCSResourceManager
                        DCSResourceManager.ResetTimeout();
                    end
                    
                    oPool = ParallelComputingUtils.GetCurrentParpool();
                    
                    if ~isempty(oPool)
                        delete(oPool);
                    end
                    
                    % delete files
                    for dWorkerIndex=1:length(obj.c1chRemotePoolWorkerHostComputerNames)
                        if obj.vbFilesTransferredToWorker(dWorkerIndex)
                            chDirPath = strrep(obj.chNewWorkingDirectory, obj.chRemotePoolLocalPathMatch, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByLocal{dWorkerIndex});
                            
                            rmdir(chDirPath, 's');
                        end
                    end
                    
                    disp('Deleting files from remote workers...done');
                    disp(' ');
                catch e
                    warning('Deleting files from remote workers failed.');
                end
            end
            
            
            
            obj.dtEndingTime = datetime(now, 'ConvertFrom', 'datenum');
            obj.bExperimentSuccessful = isempty(oError);
            
            if bReportStarted
                try
                    obj.FinalizeReport(oError);
                catch e
                    % do nothing if report failed
                end
            end
            
            if isempty(oError) && isfolder(fullfile(obj.chNewWorkingDirectory, Experiment.chResumePointSaveFolder)) % delete the resume points, since no errors occured
                rmdir(fullfile(obj.chNewWorkingDirectory, Experiment.chResumePointSaveFolder), 's');
            end
            
            if isempty(oError)
                fprintf('Experiment Complete:');
                fprintf(newline)
                
                
                fprintf(['             Start: ', datestr(obj.dtStartingTime, 'mmm dd, yyyy HH:MM:SS')]);
                fprintf(newline)
                fprintf(['               End: ', datestr(obj.dtEndingTime, 'mmm dd, yyyy HH:MM:SS')]);
                fprintf(newline)
                
                dtDiff = obj.dtEndingTime - obj.dtStartingTime;
                fprintf(['      Time Elapsed: ', datestr(dtDiff, 'HH:MM:SS')]);
                fprintf(newline);
                chNewDir = obj.chNewWorkingDirectory;
                fprintf(['  Output Directory: ', StringUtils.MakePathStringValidForPrinting(chNewDir)]);
                fprintf(newline);
            else
                fprintf(newline)
                fprintf('Experiment Failed:');
                fprintf(newline)
                fprintf(['             Start: ', datestr(obj.dtStartingTime, 'mmm dd, yyyy HH:MM:SS')]);
                fprintf(newline)
                fprintf(['          Error At: ', datestr(obj.dtEndingTime, 'mmm dd, yyyy HH:MM:SS')]);
                fprintf(newline);
                chNewDir = obj.chNewWorkingDirectory;
                
                if isempty(chNewDir)
                    chNewDir = 'Not Created';
                end
                
                fprintf(['  Output Directory: ', strrep(chNewDir, '\', '\\')]);
                fprintf(newline);
            end
            
            
            chPathAfter = path;
            
            if bPathsAdded && ~strcmp(chPathAfter, obj.chStartingPathCache)
                fprintf(newline);
                warning('The MATLAB search path was found to have changed while running main.m. Adding paths in main.m should be avoided, with all paths to be added being specified in addpaths.txt. Not doing so no longer guarantees that all required code to re-run the experiment will be copied.');
            end
            
            % if an error occurred in main.m, rethrow at the end
            if ~isempty(oError)
                fprintf(newline);
                fprintf('Experiment Error:');
                fprintf(newline);
                fprintf(newline);
            end
            
            % turn off journaling
            obj.TurnOffConsoleOutputTracking();
            
            if ~isempty(oError) && bResultsDirectoryExists
                % append error to the console output file
                chText = getReport(oError, 'extended', 'hyperlinks', 'off');
                chText = strrep(chText, char(10), [char(10) char(13)]);
                
                oFileId = fopen(fullfile(obj.GetResultsDirectoryRootPath(), Experiment.chResultsConsoleOutputFilename), 'a'); % appending
                fprintf(oFileId, strrep(chText,'\','\\'));
                fclose(oFileId);
            end
            
            oExperiment = [];
            
            if bPathsAdded && ~obj.bInDebugMode
                path(obj.chPreExperimentPathCache);
            end
            
            if obj.bEmailReport
                try
                    setpref('Internet', 'E_mail', obj.chEmailSender);
                    setpref('Internet', 'SMTP_Server', obj.chEmailServer);
                    
                    if isempty(oError)
                        chSuccessFailMessage = 'Experiment Successfully Completed';
                    else
                        chSuccessFailMessage = 'Experiment Failed';
                    end
                    
                    [~,chExperimentName] = obj.SeparateFilePathAndLastItem(obj.chStartingWorkingDirectory);
                    
                    chSubjectLine = [chSuccessFailMessage, ' [', chExperimentName, ']'];
                    
                    chEmailBody = 'The experiment report is attached.';
                    
                    sendmail(...
                        obj.chEmailAddress,...
                        chSubjectLine,...
                        chEmailBody,...
                        fullfile(obj.chNewWorkingDirectory, obj.chResultsDirectoryName, obj.chReportFileName));
                catch e
                    warning(...
                        'Experiment:RunMain:EmailReportNotSent',...
                        'Email settings incorrect.');
                end
            end
            
            bErrored = ~isempty(oError);
            
            if ~isempty(oError) && ~obj.bIsBatchJob % don't want to start throwing errors if it's a batch job, as we want the path to the produced results directory to be returned
                rethrow(oError);
            end
        end
        
        function TurnOnConsoleOutputTracking(obj)
            diary(fullfile(obj.GetResultsDirectoryRootPath(), Experiment.chResultsConsoleOutputFilename));
        end
        
        function TurnOffConsoleOutputTracking(obj)
            diary('off');
        end
        
        function InitializeReport(obj)
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            obj.oReport = Report(fullfile(obj.chNewWorkingDirectory, obj.chResultsDirectoryName, obj.chReportFileName), obj.chReportFormat);
            
            [~,chExperimentName] = Experiment.SeparateFilePathAndLastItem(obj.chStartingWorkingDirectory);
            
            oMasterSection1 = Section('Experiment Summary');
            oMasterSection1.Numbered = false;
            
            oMasterSection1.add(Experiment.MakeParagraphWithBoldLabel('Experiment Name: ', chExperimentName));
            
            oExperimentStatus = Experiment.MakeParagraphWithBoldLabel('Experiment Status: ', '');
            oMasterSection1.add(oExperimentStatus);
            obj.oExperimentStatusParagraph = oExperimentStatus;
            
            oMasterSection1.add(Experiment.MakeLinkParagraphWithBoldLabel('Experiment Directory: ', obj.chStartingWorkingDirectory, obj.chStartingWorkingDirectory));
            oMasterSection1.add(Experiment.MakeLinkParagraphWithBoldLabel('Results Directory: ', obj.chNewWorkingDirectory, obj.chNewWorkingDirectory));
            
            oMasterSection1.add(Experiment.MakeParagraphWithBoldLabel('Start Time: ', datestr(obj.dtStartingTime, 'mmm dd, yyyy HH:MM:SS')));
            
            oExperimentEndTime = Experiment.MakeParagraphWithBoldLabel('End Time: ', '');
            oMasterSection1.add(oExperimentEndTime); % we'll slot that in after
            
            oExperimentElapsedTime = Experiment.MakeParagraphWithBoldLabel('Elapsed Time: ', '');
            oMasterSection1.add(oExperimentElapsedTime);
            
            obj.oExperimentEndTimeParagraph = oExperimentEndTime;
            obj.oExperimentElapsedTimeParagraph = oExperimentElapsedTime;
            
            if obj.bInResumeMode
                oSpacer = Experiment.MakeParagraphWithBoldLabel('','');
                oMasterSection1.add(oSpacer);
                oMasterSection1.add(oSpacer);
                
                oExperimentResumedWarning = Experiment.MakeParagraphWithBoldLabel('EXPERIMENT RESUMED FROM PREVIOUS RUN!','');
                oMasterSection1.add(oExperimentResumedWarning);
                
                oExperimentResumedPath = Experiment.MakeLinkParagraphWithBoldLabel('Experiment Resumed From: ', obj.chResumeFromPath, obj.chResumeFromPath);
                oMasterSection1.add(oExperimentResumedPath);
            end
            
            oMasterSection2 = Section('Experiment Materials');
            oMasterSection2.Numbered = false;
            
            oSect1 = Section('Computation Environment Summary');
            oSect1.Numbered = false;
            
            oSect1.add(Experiment.MakeParagraphWithBoldLabel('MATLAB Version: ', version));
            oSect1.add(Experiment.MakeParagraphWithBoldLabel('Operating System: ', system_dependent('getos')));
            
            if ispc
                oSect1.add(Experiment.MakeParagraphWithBoldLabel('Windows Version: ', system_dependent('getwinsys')));
            end
            
            oSect1.add(Experiment.MakeParagraphWithBoldLabel('Computer Name: ', ComputingEnvironmentUtils.GetCurrentComputerName()));
            oSect1.add(Experiment.MakeParagraphWithBoldLabel('User: ', ComputingEnvironmentUtils.GetCurrentUsername()));
            
            oSect2 = Section('Code Library Summary');
            oSect2.Numbered = false;
            chIndentMargin = '20px';
            
            for dCodePathIndex=1:length(obj.c1chAllCodePathsToUse)
                chPath = obj.c1chAllCodePathsToUse{dCodePathIndex};
                [~, chDirName] = Experiment.SeparateFilePathAndLastItem(chPath);
                
                oCodeName = Paragraph(chDirName);
                oCodeName.Bold = true;
                
                oSect2.add(oCodeName);
                
                oPath = Experiment.MakeLinkParagraphWithBoldLabel('Path: ', chPath, chPath);
                oPath.OuterLeftMargin = chIndentMargin;
                oSect2.add(oPath);
                
                % check if .git exists
                if exist(fullfile(chPath, Experiment.chGitFolderName), 'dir') ~= 7 % doesn't exist
                    oNotice = Paragraph('Not under Git source control');
                    oNotice.OuterLeftMargin = chIndentMargin;
                    oSect2.add(oNotice)
                else
                    % get current branch name
                    [chRepoName, chBranchName, chCommitId, chGithubRepoRemoteUrl] = Experiment.GetGitMetadata(chPath);
                    
                    oRepo = Experiment.MakeLinkParagraphWithBoldLabel('Git Repo: ', chRepoName, chGithubRepoRemoteUrl);
                    oRepo.OuterLeftMargin = chIndentMargin;
                    oSect2.add(oRepo);
                    
                    chBranchUrl = [chGithubRepoRemoteUrl, '/tree/', chBranchName];
                    oBranch = Experiment.MakeLinkParagraphWithBoldLabel('Git Branch: ', chBranchName, chBranchUrl);
                    oBranch.OuterLeftMargin = chIndentMargin;
                    oSect2.add(oBranch);
                    
                    chCommitUrl = [chGithubRepoRemoteUrl, '/commit/', chCommitId];
                    oCommitId = Experiment.MakeLinkParagraphWithBoldLabel('Git Commit ID: ', chCommitId, chCommitUrl);
                    oCommitId.OuterLeftMargin = chIndentMargin;
                    oSect2.add(oCommitId);
                end
            end
            
            oSect3 = Section('Data Paths Summary');
            oSect3.Numbered = false;
            chIndentMargin = '20px';
            
            for dDataPathIndex=1:length(obj.c1chDataPathLabels)
                oPathLabel = Paragraph(obj.c1chDataPathLabels{dDataPathIndex});
                oPathLabel.Bold = true;
                
                oSect3.add(oPathLabel);
                
                oPath = Experiment.MakeLinkParagraphWithBoldLabel('Path: ', obj.c1chDataPaths{dDataPathIndex}, obj.c1chDataPaths{dDataPathIndex});
                oPath.OuterLeftMargin = chIndentMargin;
                oSect3.add(oPath);
            end
            
            oMasterSection2.add(oSect1);
            oMasterSection2.add(oSect2);
            oMasterSection2.add(oSect3);
            
            % IF Python settings are set, dump those in as well
            if ~isempty(obj.chAnacondaInstallPath) && ~isempty(obj.chAnacondaInstallPath)
                oSect4 = Section('Python/Anaconda Environment Summary');
                oSect4.Numbered = false;
                
                % - create dump file containing the package list for the
                % environment
                chPackageListFilePath = fullfile(obj.chNewWorkingDirectory, obj.chResultsDirectoryName, Experiment.chAnacondaEnvironmentPackageListFilename);
                chCondaCommand = ['list --export > "', chPackageListFilePath, '"'];
                PythonUtils.ExecuteCondaCommandInAnacondaEnvironment(chCondaCommand, obj.chAnacondaInstallPath, obj.chAnacondaEnvironmentName);
                
                chPackageFileText = fileread(chPackageListFilePath);
                chPythonVersionMatchString = 'python=';
                
                vdPythonVersionMatches = strfind(chPackageFileText, [newline, chPythonVersionMatchString]);
                
                if length(vdPythonVersionMatches) ~= 1
                    error(...
                        'Experiment:InitializeReport:NoPythonVersionFound',...
                        ['No Python version record in : ', chPackageListFilePath]);
                else
                    dPythonVersionMatchIndex = vdPythonVersionMatches(1);
                    
                    vdEqualMatches = strfind(chPackageFileText, '=');
                    
                    vdAfterPythonVersion = vdEqualMatches(vdEqualMatches > dPythonVersionMatchIndex);
                    
                    dEndIndex = vdAfterPythonVersion(2)-1;
                    
                    dStartIndex = dPythonVersionMatchIndex + length(chPythonVersionMatchString) + 1;
                    
                    chPythonVersion = chPackageFileText(dStartIndex:dEndIndex);
                end
                
                oSect4.add(Experiment.MakeLinkParagraphWithBoldLabel('Anaconda Install Path: ', obj.chAnacondaInstallPath, obj.chAnacondaInstallPath));
                oSect4.add(Experiment.MakeParagraphWithBoldLabel('Anaconda Environment Name: ', obj.chAnacondaEnvironmentName));
                oSect4.add(Experiment.MakeParagraphWithBoldLabel('Python Version: ', chPythonVersion));
                oSect4.add(Experiment.MakeLinkParagraphWithBoldLabel('Anaconda Environment Package List: ', chPackageListFilePath, chPackageListFilePath));
                
                oMasterSection2.add(oSect4);
            end
            
            
            % add debug warning if needed
            if obj.bInDebugMode
                oMasterSectionDebug = Section('EXPERIMENT PERFORMED IN DEBUG MODE');
                oMasterSectionDebug.Numbered = false;
                
                oMasterSectionDebug.add(Experiment.MakeParagraphWithBoldLabel('THE RESULTS PRODUCED BY THIS EXPERIMENT CANNOT BE USED FOR SCIENTIFIC PURPOSES AS THEY ARE NOT NECESSARILY REPRODUCIBLE', ''));
                
                oMasterSectionDebug.add(Experiment.MakeParagraphWithBoldLabel('', ''));
                oMasterSectionDebug.add(Experiment.MakeParagraphWithBoldLabel('Since the experiment was run in debug mode:', ''));
                oMasterSectionDebug.add(Experiment.MakeParagraphWithBoldLabel(' - No Experiment directory was created.', ''));
                oMasterSectionDebug.add(Experiment.MakeParagraphWithBoldLabel(' - The "Results" directory was created within the current working directory.', ''));
                oMasterSectionDebug.add(Experiment.MakeParagraphWithBoldLabel(' - No copies of code within codepaths.txt were created.', ''));
                oMasterSectionDebug.add(Experiment.MakeParagraphWithBoldLabel(' - No paths were added/removed from the current path.', ''));
                
                % add sections to list
                obj.c1oReportSections = {oMasterSectionDebug; oMasterSection1; oMasterSection2};
            else
                % add sections to list
                obj.c1oReportSections = {oMasterSection1; oMasterSection2};
            end
            
        end
        
        function FinalizeReport(obj, oError)
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            % finalize the last section
            if ~isempty(obj.oCurrentReportResultsSection)
                obj.FinalizeSection();
            end
            
            % adjust the end time, elapsed time, experiment status
            % paragraphs
            if obj.bExperimentSuccessful
                chStatus = 'Complete';
            else
                chStatus = 'Errored';
            end
            
            obj.oExperimentStatusParagraph.append(Text(chStatus));
            obj.oExperimentEndTimeParagraph.append(Text(datestr(obj.dtEndingTime, 'mmm dd, yyyy HH:MM:SS')));
            obj.oExperimentElapsedTimeParagraph.append(Text(datestr(obj.dtEndingTime - obj.dtStartingTime, 'HH:MM:SS')));
            
            % add the sections to the report
            for dSectionIndex=1:length(obj.c1oReportSections)
                obj.oReport.add(obj.c1oReportSections{dSectionIndex});
            end
            
            % delete figures, as they've been added now
            for dFigureIndex=1:length(obj.c1hReportFigureHandles)
                close(obj.c1hReportFigureHandles{dFigureIndex});
            end
            
            % if there's an error, append to the end of the report
            if ~isempty(oError)
                chErrorReport = getReport(oError, 'extended', 'hyperlinks', 'off');
                chErrorReport = strrep(chErrorReport, char(10), [char(10) char(13)]);
                
                vdLinkStart = strfind(chErrorReport, '<a');
                
                if isempty(vdLinkStart) % no hyperlink
                    oPreLinkText = Text(chErrorReport);
                    oPostLinkText = Text('');
                    oLink = Text('');
                else
                    vdLinkStartClosing = strfind(chErrorReport, '">');
                    
                    vdLinkEnd = strfind(chErrorReport, '</a>');
                    
                    vdHrefIndices = strfind(chErrorReport,'href="');
                    vdQuotationMarks = strfind(chErrorReport, '"');
                    
                    dHrefQuotationMarkIndex = find(vdQuotationMarks == vdHrefIndices(1)+5);
                    dHrefEnd = vdQuotationMarks(dHrefQuotationMarkIndex+1);
                    
                    %                 oLink = ExternalLink(...
                    %                     chErrorReport(vdHrefIndices(1)+6 : dHrefEnd-1),...
                    %                     chErrorReport(vdLinkStartClosing+2 : vdLinkEnd - 1));
                    oLink = Text(chErrorReport(vdLinkStartClosing+2 : vdLinkEnd - 1));
                    
                    oPreLinkText = Text(chErrorReport(1:vdLinkStart-1));
                    oPostLinkText = Text(chErrorReport(vdLinkEnd+4 : end));
                end
                
                oPreLinkText.WhiteSpace = 'preserve';
                oPostLinkText.WhiteSpace = 'preserve';
                
                oSection = Section('Error Message');
                oSection.Numbered = false;
                
                oParagraph = Paragraph;
                
                oParagraph.append(oPreLinkText);
                oParagraph.append(oLink);
                oParagraph.append(oPostLinkText);
                
                oParagraph.Color = '#ff0000';
                oParagraph.WhiteSpace = 'preserve';
                
                oFontStyle = FontFamily('Courier');
                
                oParagraph.Style = [oParagraph.Style, {oFontStyle}];
                
                oSection.add(oParagraph);
                obj.oReport.add(oSection);
            end
            
            % close the report
            close(obj.oReport);
            
            if ~obj.bIsBatchJob && obj.bShowPDF
                rptview(obj.oReport);
            end
        end
        
        function SetInitialComputationEnvironment(obj)
            [chHostComputerName, dWorkerNumberOrProcessId] = Experiment.GetCurrentComputationEnvironmentDetails();
            
            obj.chInitialComputationHostComputerName = chHostComputerName;
            obj.dInitialComputationWorkerNumberOrProcessId = dWorkerNumberOrProcessId;
        end
        
        function ValidateStartingWorkingDirectory(obj)
            % Validate that:
            % - addpaths.txt exists
            % - the directory "Code" does not exist OR the directory "CODE"
            %   does not contain any folders that are named the same as the
            %   folders in addpaths.txt (unless of course addpaths.txt is
            %   pointing at "CODE")
            
            fprintf('Validating Experiment...');
            
            % unzip code if needed
            if isfile(fullfile(obj.chStartingWorkingDirectory, [Experiment.chCodeDirectoryName, '.zip']))
                unzip(fullfile(obj.chStartingWorkingDirectory, [Experiment.chCodeDirectoryName, '.zip']), fullfile(obj.chStartingWorkingDirectory, Experiment.chCodeDirectoryName));
                delete(fullfile(obj.chStartingWorkingDirectory, [Experiment.chCodeDirectoryName, '.zip']));
            end
            
            % check that THIS file (Experiment.m) is in the root of the
            % working directory
            chCurrentFilePath = mfilename('fullpath');
            
            [chPathToFile,~] = Experiment.SeparateFilePathAndLastItem(chCurrentFilePath);
            
            if ~strcmp(chPathToFile, obj.chStartingWorkingDirectory)
                error(...
                    'Experiment:ValidateStartingWorkingDirectory:InvalidExperimentFileLocation',...
                    'The current "Experiment" class being used is not in the current working directory. Please alter the search path or change your current working directory to change this. Use "which(''Experiment'', ''-all'')" to investigate which Experiment.m file is being used currently, or use "Experiment.RemoveAllExperimentInstancesFromPathExceptCurrentDirectory()" to remove conflicting instances of Experiment.m from your current path.');
            end
            
            % check if addpaths.txt exists
            chAddpathsPath = fullfile(obj.chStartingWorkingDirectory, obj.chPathsFilename);
            
            if exist(chAddpathsPath, 'file') ~= 2
                error(...
                    'Experiment:ValidateStartingWorkingDirectory:NoAddpathsFile',...
                    'To run an experiment, an addpaths.txt file must exist in the current working directory.');
            end
            
            % read in addpaths.txt
            % validate that paths exist, and compile them into a cell array
            chText = fileread(chAddpathsPath);
            c1chLines = regexp(chText, '\r\n|\r|\n', 'split');
            
            dNumLines = length(c1chLines);
            c1chCodePaths = cell(dNumLines,1);
            dNumCodePaths = 0; % some lines could be blank etc.
            
            for dLineIndex=1:dNumLines
                chTrimmedLine = strtrim(c1chLines{dLineIndex});
                
                if ~isempty(chTrimmedLine) % if not empty, let's see what we have
                    if exist(chTrimmedLine, 'dir') ~= 7
                        error(...
                            'Experiment:ValidateStartingWorkingDirectory:InvalidPath',...
                            ['The path ', StringUtils.MakePathStringValidForPrinting(chTrimmedLine), ' does not exist.']);
                    else % it exists, so let's add it
                        dNumCodePaths = dNumCodePaths + 1;
                        c1chCodePaths{dNumCodePaths} = chTrimmedLine;
                    end
                end
            end
            
            % - trim c1chCodePaths to only be as long as needed:
            c1chCodePaths = c1chCodePaths(1:dNumCodePaths);
            
            % - make sure their unique
            vsPaths = string(c1chCodePaths);
            
            if length(vsPaths) ~= length(unique(vsPaths))
                error(...
                    'Experiment:ValidateStartingWorkingDirectory:DuplicatedFolderName',...
                    'addpaths.txt may only contain paths with unique ending directory names.');
            end
            
            % save to obj
            obj.c1chAllCodePathsToUse = c1chCodePaths;
            
            % check if the working directory has a "Code" directory in it.
            % If it doesn't, that means this is a first time experiment.
            % Easy, no validation needed.
            % If it does...there's two possiblities:
            % 1) This is still a first time experiment, but the user just
            %    has a folder named "Code". No biggie. We'll just want to
            %    check that any folder in addpaths.txt either: a) does
            %    share a name with any folder in "Code"; or b) if does
            %    share a name with any folder in "Code" it is actually just
            %    pointing to that same folder. Otherwise, error.
            % 2) This is repeated experiment, and so all the directories in
            %    addpaths.txt should be pointing to the "Code" folder in
            %    the working directory. Just validate that that this is the
            %    case
            
            
            
            chCodeDirectoryPath = fullfile(obj.chStartingWorkingDirectory, obj.chCodeDirectoryName);
            
            if exist(chCodeDirectoryPath, 'dir') == 7 % "Code" directory does exist
                % if some paths in c1chCodePaths don't need to be copied,
                % they should be removed from the cell array
                vbNeedToCopyCodeDirectory = true(size(c1chCodePaths));
                
                % get the directory names in "Code"
                voEntries = dir(chCodeDirectoryPath);
                dNumEntries = length(voEntries) - 2; % -2 beacuse we don't need . and ..
                
                c1chCurrentCodeSubDirectoryNames = cell(dNumEntries,1);
                dNumDirectoryNames = 0;
                
                for dEntryIndex=1:dNumEntries
                    if voEntries(dEntryIndex + 2).isdir
                        dNumDirectoryNames = dNumDirectoryNames + 1;
                        c1chCurrentCodeSubDirectoryNames{dNumDirectoryNames} = voEntries(dEntryIndex + 2).name;
                    end
                end
                
                % - trim to be as long as needed
                c1chCurrentCodeSubDirectoryNames = c1chCurrentCodeSubDirectoryNames(1:dNumDirectoryNames);
                
                % compare each of the directory names in addpaths.txt to
                % these current "Code" subdirectories. They either can't appear in the
                % current "Code" subdirectories or have to be the same path
                
                for dAddPathIndex=1:length(c1chCodePaths)
                    [chAddPathFolderPath, chAddPathFolderName] = obj.SeparateFilePathAndLastItem(c1chCodePaths{dAddPathIndex});
                    dCurrentCodeSubDirectoryIndex = [];
                    
                    for dSubDirectorySearchIndex=1:length(c1chCurrentCodeSubDirectoryNames)
                        if strcmp(chAddPathFolderName, c1chCurrentCodeSubDirectoryNames{dSubDirectorySearchIndex}) % we have a match!
                            dCurrentCodeSubDirectoryIndex = dSubDirectorySearchIndex;
                            break;
                        end
                    end
                    
                    if ~isempty(dCurrentCodeSubDirectoryIndex) % there was a match, so let's make sure it's the same path
                        if ~strcmp(chAddPathFolderPath, obj.chCodeDirectoryName)
                            error(...
                                'Experiment:ValidateStartingWorkingDirectory:CodeDirectoryConflict',...
                                ['The directory "Code" within the working directory already contains the directory "', chAddPathFolderName, '" which is also attempted to be added by addpaths.txt. Please remove one of these directories.']);
                        else % the directory in addpaths.txt is already in "Code", so after the working directory is copied, it won't need to be copied again
                            vbNeedToCopyCodeDirectory(dAddPathIndex) = false;
                        end
                    end
                end
                
                % keep on paths required to be copied
                c1chCodePaths = c1chCodePaths(vbNeedToCopyCodeDirectory);
            end
            
            % set the paths to copy
            obj.c1chCodePathsToCopyToNewWorkingDirectory = c1chCodePaths;
            
            % load up data paths
            [c1chDataPathLabels, c1chDataPaths] = Experiment.LoadDataPathsFile();
            
            obj.c1chDataPathLabels = c1chDataPathLabels;
            obj.c1chDataPaths = c1chDataPaths;
            
            fprintf('Done');
            fprintf(newline);
        end
        
        function LoadAndSetExperimentSettingsFile(obj, NameValueArgs)
            if exist(fullfile(obj.chStartingWorkingDirectory, obj.chExperimentSettingsFilename), 'file') == 2
                try
                    stDataFromFile = load(...
                        fullfile(obj.chStartingWorkingDirectory, obj.chExperimentSettingsFilename),...
                        obj.chExperimentSettingsTableVarName);
                    tSettingsFromFile = stDataFromFile.(obj.chExperimentSettingsTableVarName);
                    
                    stSettingsFromFile = struct;
                    
                    for dRowIndex=1:size(tSettingsFromFile,1)
                        if ~isempty(tSettingsFromFile.chVarName{dRowIndex}) && ~strcmp(tSettingsFromFile.chVarName{dRowIndex}(1:2), '>>')
                            stSettingsFromFile.(tSettingsFromFile.chVarName{dRowIndex}) = tSettingsFromFile.c1xVarValue{dRowIndex};
                        end
                    end
                catch e
                    warning(...
                        'Experiment:LoadAndSetExperimentSettingsFile:InvalidFile',...
                        'The settings file was invalid, and so ignored.');
                    
                    stSettingsFromFile = struct;
                end
            else
                stSettingsFromFile = struct;
            end
            
            % set values (priority to those passed in to call, then
            % settings files, then the default already in the obj)
            
            % >> Email Settings
            if isfield(NameValueArgs, 'EmailReport')
                obj.bEmailReport = NameValueArgs.EmailReport;
            elseif isfield(stSettingsFromFile, 'EmailReport')
                obj.bEmailReport = stSettingsFromFile.EmailReport;
            end
            
            if isfield(NameValueArgs, 'EmailSender')
                obj.chEmailSender = char(NameValueArgs.EmailSender);
            elseif isfield(stSettingsFromFile, 'EmailSender')
                obj.chEmailSender = char(stSettingsFromFile.EmailSender);
            end
            
            if isfield(NameValueArgs, 'EmailServer')
                obj.chEmailServer = char(NameValueArgs.EmailServer);
            elseif isfield(stSettingsFromFile, 'EmailServer')
                obj.chEmailServer = char(stSettingsFromFile.EmailServer);
            end
            
            if isfield(NameValueArgs, 'EmailAddress')
                obj.chEmailAddress = char(NameValueArgs.EmailAddress);
            elseif isfield(stSettingsFromFile, 'EmailAddress')
                obj.chEmailAddress = char(stSettingsFromFile.EmailAddress);
            end
            
            % >> Journaling Settings
                        
            if isfield(NameValueArgs, 'ShowPDF')
                obj.bShowPDF = NameValueArgs.ShowPDF;
            elseif isfield(stSettingsFromFile, 'ShowPDF')
                obj.bShowPDF = stSettingsFromFile.ShowPDF;
            end
            
            if isfield(NameValueArgs, 'AutoAddEntriesIntoExperimentReport')
                obj.bAutoAddEntriesIntoExperimentReport = NameValueArgs.AutoAddEntriesIntoExperimentReport;
            elseif isfield(stSettingsFromFile, 'AutoAddEntriesIntoExperimentReport')
                obj.bAutoAddEntriesIntoExperimentReport = stSettingsFromFile.AutoAddEntriesIntoExperimentReport;
            end
            
            if isfield(NameValueArgs, 'AutoSaveObjects')
                obj.bAutoSaveObjects = NameValueArgs.AutoSaveObjects;
            elseif isfield(stSettingsFromFile, 'AutoSaveObjects')
                obj.bAutoSaveObjects = stSettingsFromFile.AutoSaveObjects;
            end
                      
            if isfield(NameValueArgs, 'AutoSaveSummaryFiles')
                obj.bAutoSaveSummaryFiles = NameValueArgs.AutoSaveSummaryFiles;
            elseif isfield(stSettingsFromFile, 'AutoSaveSummaryFiles')
                obj.bAutoSaveSummaryFiles = stSettingsFromFile.AutoSaveSummaryFiles;
            end
            
            % >> Anaconda Settings
            if isfield(NameValueArgs, 'AnacondaInstallPath')
                obj.chAnacondaInstallPath = char(NameValueArgs.AnacondaInstallPath);
            elseif isfield(stSettingsFromFile, 'AnacondaInstallPath')
                obj.chAnacondaInstallPath = char(stSettingsFromFile.AnacondaInstallPath);
            end
            
            if isfield(NameValueArgs, 'AnacondaEnvironmentName')
                obj.chAnacondaEnvironmentName = char(NameValueArgs.AnacondaEnvironmentName);
            elseif isfield(stSettingsFromFile, 'AnacondaEnvironmentName')
                obj.chAnacondaEnvironmentName = char(stSettingsFromFile.AnacondaEnvironmentName);
            end
            
            % >> Local Parpool Settings
            if isfield(NameValueArgs, 'CreateLocalParpool')
                obj.bCreateLocalParpool = NameValueArgs.CreateLocalParpool;
            elseif isfield(stSettingsFromFile, 'CreateLocalParpool')
                obj.bCreateLocalParpool = stSettingsFromFile.CreateLocalParpool;
            end
            
            if isfield(NameValueArgs, 'NumberOfLocalWorkers')
                obj.dNumberOfLocalWorkers = NameValueArgs.NumberOfLocalWorkers;
            elseif isfield(stSettingsFromFile, 'NumberOfLocalWorkers')
                obj.dNumberOfLocalWorkers = stSettingsFromFile.NumberOfLocalWorkers;
            end
            
            % >> Distributed Parpool General Settings
            if isfield(NameValueArgs, 'CreateDistributedParpool')
                obj.bCreateDistributedParpool = NameValueArgs.CreateDistributedParpool;
            elseif isfield(stSettingsFromFile, 'CreateDistributedParpool')
                obj.bCreateDistributedParpool = stSettingsFromFile.CreateDistributedParpool;
            end
            
            if isfield(NameValueArgs, 'ClusterProfileName')
                obj.chClusterProfileName = char(NameValueArgs.ClusterProfileName);
            elseif isfield(stSettingsFromFile, 'ClusterProfileName')
                obj.chClusterProfileName = char(stSettingsFromFile.ClusterProfileName);
            end
            
            if isfield(NameValueArgs, 'UseDCSResourceManager')
                obj.bUseDCSResourceManager = NameValueArgs.UseDCSResourceManager;
            elseif isfield(stSettingsFromFile, 'UseDCSResourceManager')
                obj.bUseDCSResourceManager = stSettingsFromFile.UseDCSResourceManager;
            end
            
            if isfield(NameValueArgs, 'RemotePoolLocalPathMatch')
                obj.chRemotePoolLocalPathMatch = char(NameValueArgs.RemotePoolLocalPathMatch);
            elseif isfield(stSettingsFromFile, 'RemotePoolLocalPathMatch')
                obj.chRemotePoolLocalPathMatch = char(stSettingsFromFile.RemotePoolLocalPathMatch);
            end
            
            if isfield(NameValueArgs, 'RemotePoolWorkerHostComputerNames')
                obj.c1chRemotePoolWorkerHostComputerNames = cellstr(NameValueArgs.RemotePoolWorkerHostComputerNames);
            elseif isfield(stSettingsFromFile, 'RemotePoolWorkerHostComputerNames')
                obj.c1chRemotePoolWorkerHostComputerNames = cellstr(stSettingsFromFile.RemotePoolWorkerHostComputerNames);
            end
            
            if isfield(NameValueArgs, 'RemotePoolLocalPathReplacePerHostForAccessByWorker')
                obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker = cellstr(NameValueArgs.RemotePoolLocalPathReplacePerHostForAccessByWorker);
            elseif isfield(stSettingsFromFile, 'RemotePoolLocalPathReplacePerHostForAccessByWorker')
                obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker = cellstr(stSettingsFromFile.RemotePoolLocalPathReplacePerHostForAccessByWorker);
            end
            
            if isfield(NameValueArgs, 'RemotePoolLocalPathReplacePerHostForAccessByLocal')
                obj.c1chRemotePoolLocalPathReplacePerHostForAccessByLocal = cellstr(NameValueArgs.RemotePoolLocalPathReplacePerHostForAccessByLocal);
            elseif isfield(stSettingsFromFile, 'RemotePoolLocalPathReplacePerHostForAccessByLocal')
                obj.c1chRemotePoolLocalPathReplacePerHostForAccessByLocal = cellstr(stSettingsFromFile.RemotePoolLocalPathReplacePerHostForAccessByLocal);
            end
            
            % >> Distributed Parpool with Manager Settings
            if isfield(NameValueArgs, 'DCSResourceManagerConnectionPath')
                obj.sDCSResourceManagerConnectionPath = NameValueArgs.DCSResourceManagerConnectionPath;
            elseif isfield(stSettingsFromFile, 'DCSResourceManagerConnectionPath')
                obj.sDCSResourceManagerConnectionPath = stSettingsFromFile.DCSResourceManagerConnectionPath;
            end
            
            if isfield(NameValueArgs, 'DCSResourceManagerRequestId')
                obj.sDCSResourceManagerRequestId = NameValueArgs.DCSResourceManagerRequestId;
            elseif isfield(stSettingsFromFile, 'DCSResourceManagerRequestId')
                obj.sDCSResourceManagerRequestId = stSettingsFromFile.DCSResourceManagerRequestId;
            end
            
            if isfield(NameValueArgs, 'DCSResourceManagerWorkerRequest')
                obj.sDCSResourceManagerWorkerRequest = NameValueArgs.DCSResourceManagerWorkerRequest;
            elseif isfield(stSettingsFromFile, 'DCSResourceManagerWorkerRequest')
                obj.sDCSResourceManagerWorkerRequest = stSettingsFromFile.DCSResourceManagerWorkerRequest;
            end
            
            % >> Distributed Parpool without Manager Settings
            if isfield(NameValueArgs, 'NumberOfDistributedWorkers')
                obj.dNumberOfDistributedWorkers = NameValueArgs.NumberOfDistributedWorkers;
            elseif isfield(stSettingsFromFile, 'NumberOfDistributedWorkers')
                obj.dNumberOfDistributedWorkers = stSettingsFromFile.NumberOfDistributedWorkers;
            end
            
            
            if ~isempty(obj.c1chRemotePoolWorkerHostComputerNames)
                obj.vbFilesTransferredToWorker = false(size(obj.c1chRemotePoolWorkerHostComputerNames));
            end
            
            
            % Validate
            if ~ispc && obj.bCreateDistributedParpool
                error(...
                    'Experiment:LoadAndSetExperimentSettingsFile:NoDistributedParpoolIfNotOnWindows',...
                    'Use of a distributed parpool on a non-Windows computer is not currently supported.');
            end
            
            if ~ispc && (~isempty(obj.chAnacondaInstallPath) || ~isempty(obj.chAnacondaEnvironmentName))
                error(...
                    'Experiment:LoadAndSetExperimentSettingsFile:NoAnacondaSupportIfNotOnWindows',...
                    'Use of Anaconda/Python on a non-Windows computer is not currently supported.');                
            end
        end
        
        function CreateNewWorkingDirectory(obj)
            fprintf('Creating experiment directory...');
            
            [chPath, chLastItem] = obj.SeparateFilePathAndLastItem(obj.chStartingWorkingDirectory);
            
            chNewFolderName = [chLastItem, datestr(obj.dtStartingTime, ' [yyyy-mm-dd_HH.MM.SS]')];
            
            chNewWorkingDirectory = fullfile(chPath, chNewFolderName);
            
            if exist(chNewWorkingDirectory, 'dir') == 7
                error(...
                    'Experiment:CreateNewWorkingDirectory:DirectoryAlreadyExists',...
                    ['The proposed experiment working directory (', chNewWorkingDirectory, ') already exists.']);
            end
            
            if obj.bInDebugMode
                obj.chNewWorkingDirectory = obj.chStartingWorkingDirectory; % in debug point it at the current folder it's in
            else
                obj.chNewWorkingDirectory = chNewWorkingDirectory;
                mkdir(chNewWorkingDirectory);
            end
            
            
            fprintf('Done');
            fprintf(newline);
        end
        
        function PrepareWorkingDirectory(obj)
            % need to:
            % - copy over starting working directory (except "Results"
            %   folder, if it exists)
            % - make "Code" folder if needed
            % - copy over add code directories in addpaths.txt that aren't
            %   already in "Code"
            % - make empty "Result" folder
            % - produce updated "addpaths.txt"
            
            
            % copy over current working directory, except "Results" folder
            % if it exists
            fprintf('Copying experiment folder...');
            
            if ~obj.bInDebugMode
                voEntries = dir(obj.chStartingWorkingDirectory);
                
                for dEntryIndex=3:length(voEntries)
                    chName = voEntries(dEntryIndex).name;
                    
                    if ~strcmp(chName, obj.chResultsDirectoryName) % don't copy "Results" folder
                        copyfile(...
                            fullfile(obj.chStartingWorkingDirectory, chName),...
                            fullfile(obj.chNewWorkingDirectory, chName));
                    end
                end
                
                fprintf('Done');
            else
                fprintf('SKIPPED FOR DEBUG');
            end
            
            fprintf(newline);
            fprintf('Copying code...');
            
            if ~obj.bInDebugMode
                % make "Code" folder if needed
                chNewCodeDirectoryPath = fullfile(obj.chNewWorkingDirectory, obj.chCodeDirectoryName);
                
                if exist(chNewCodeDirectoryPath, 'dir') ~= 7
                    mkdir(chNewCodeDirectoryPath);
                end
                
                % copy over directories specified in addpaths.txt that weren't
                % already in "Code" (if that existed in the starting working
                % directory)
                
                c1chDirsToCopy = obj.c1chCodePathsToCopyToNewWorkingDirectory;
                
                for dDirIndex=1:length(c1chDirsToCopy)
                    [~, chDirName] = Experiment.SeparateFilePathAndLastItem(c1chDirsToCopy{dDirIndex});
                    
                    if contains(chDirName, obj.chCentralLibraryCodeDirectorySearchPattern) % we're copying the central library, so a special copy is used to avoid blacklisted folders (e.g. tests, demos, etc.)
                        Experiment.CopyCentralLibraryDirectory(...
                            c1chDirsToCopy{dDirIndex},...
                            fullfile(obj.chNewWorkingDirectory, Experiment.chCodeDirectoryName, chDirName));
                    else % not the CentralLibrary, so just copy the whole folder
                        Experiment.CopyCodeDirectory(...
                            c1chDirsToCopy{dDirIndex},...
                            fullfile(obj.chNewWorkingDirectory, Experiment.chCodeDirectoryName, chDirName));
                    end
                end
                
                fprintf('Done');
            else
                fprintf('SKIPPED FOR DEBUG');
            end
            fprintf(newline);
            
            
            % make "Results" folder
            mkdir(fullfile(obj.chNewWorkingDirectory, obj.chResultsDirectoryName));
            
            if ~obj.bInDebugMode
                % make updated "codepaths.txt"
                xFileId = fopen(fullfile(obj.chNewWorkingDirectory, obj.chPathsFilename), 'w');
                
                for dPathIndex=1:length(obj.c1chAllCodePathsToUse)
                    chFullPath = obj.c1chAllCodePathsToUse{dPathIndex};
                    
                    [~,chFolderName] = Experiment.SeparateFilePathAndLastItem(chFullPath);
                    chPrintPath = fullfile(Experiment.chCodeDirectoryName, chFolderName);
                    
                    fprintf(xFileId, strrep(chPrintPath,'\','\\'));
                    fprintf(xFileId, '\r\n');
                end
                
                fclose(xFileId);
            end
        end
        
        function AddAllCodeToPath(obj)
                       
            warning ('off','all');
            
            % get current working directory paths (to get subfolders)
            chWorkingDirectoryPaths = genpath(obj.chStartingWorkingDirectory);
            
            % get code directory paths from codepaths.txt
            dNumCodePaths = length(obj.c1chAllCodePathsToUse);
            
            c1chCodePaths = cell(dNumCodePaths,1);
            
            for dPathIndex=1:dNumCodePaths
                [~, chDirName] = Experiment.SeparateFilePathAndLastItem(obj.c1chAllCodePathsToUse{dPathIndex});
                
                if contains(chDirName, obj.chCentralLibraryCodeDirectorySearchPattern) % remove the Experiment class folder from the any Central Library additions
                    c1chCodePaths{dPathIndex} = Experiment.GetCentralLibraryDirectoryPathsToAdd(obj.c1chAllCodePathsToUse{dPathIndex});
                else
                    c1chCodePaths{dPathIndex} = Experiment.GetCodeDirectoryPathsToAdd(obj.c1chAllCodePathsToUse{dPathIndex});
                end
            end
            
            % concatenate all of these paths to add
            dTotalPathStringLength = length(chWorkingDirectoryPaths);
            
            for dDirectoryIndex=1:dNumCodePaths
                dTotalPathStringLength = dTotalPathStringLength + length(c1chCodePaths{dDirectoryIndex});
            end
            
            chPathsToAdd = blanks(dTotalPathStringLength);
            
            chPathsToAdd(1:length(chWorkingDirectoryPaths)) = chWorkingDirectoryPaths;
            
            dInsertIndex = length(chWorkingDirectoryPaths) + 1;
            
            for dDirectoryIndex=1:dNumCodePaths
                dLengthToInsert = length(c1chCodePaths{dDirectoryIndex});
                
                chPathsToAdd(dInsertIndex:dInsertIndex+dLengthToInsert-1) = c1chCodePaths{dDirectoryIndex};
                
                dInsertIndex = dInsertIndex + dLengthToInsert;
            end
            
            % add all the paths in one shot
            addpath(chPathsToAdd);
            obj.chPathsAdded = chPathsToAdd;
            
            obj.c1chWorkingDirectoryPathsAdded = strsplit(chWorkingDirectoryPaths,';');
            obj.c1chWorkingDirectoryPathsAdded = obj.c1chWorkingDirectoryPathsAdded(1:end-1);
            
            obj.c1chCodePathsAdded = c1chCodePaths;
            
            warning ('on','all');
        end
        
        function FinalizeSection(obj)
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            while obj.oCurrentSection.IsUsingSubSection() % end sub-sections first
                obj.oCurrentSection.EndCurrentSubSection(obj.GetResultsDirectoryRootPath());
            end
            
            dtEndTime = datetime(now, 'ConvertFrom', 'datenum');
            dtDiff = dtEndTime - obj.dtCurrentSectionStartTime;
            
            obj.oCurrentSectionEndTimeParagraph.append(Text(datestr(dtEndTime, 'mmm dd, yyyy HH:MM:SS')));
            obj.oCurrentSectionElapsedTimeParagraph.append(Text(datestr(dtDiff, 'HH:MM:SS')));
            
            oJournalSection = Section('Journal');
            
            c1hReportSectionFigureHandles = obj.oCurrentSection.AddJournalToReportSection(...
                oJournalSection,...
                obj.GetResultsDirectoryRootPath(),...
                'NoNewJournalSection', true);
            
            obj.c1hReportFigureHandles = [obj.c1hReportFigureHandles; c1hReportSectionFigureHandles];
            obj.oCurrentReportResultsSection.add(oJournalSection);
            
            % add to list of sections
            obj.c1oReportSections = [obj.c1oReportSections; {obj.oCurrentReportResultsSection}];
        end
        
        function InitializeSection(obj, chSectionName, varargin)
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            % Experiment management
            obj.dCurrentSectionNumber = obj.dCurrentSectionNumber + 1;
            
            if obj.dCurrentSectionNumber > Experiment.dMaxNumberOfSections
                error(...
                    'Experiment:InitializeSection:TooManySections',...
                    ['Cannot have more than ', num2str(Experiment.dMaxNumberOfSections), ' sections.']);
            end
            
            obj.c1chSectionNames = [obj.c1chSectionNames; chSectionName];
            
            obj.oCurrentSection = ExperimentSubSection(chSectionName, obj.dCurrentSectionNumber, Experiment.dMaxNumberOfSections);
            obj.bSectionCurrentlyActive = true;
            
            % journalling
            if isempty(varargin)
                obj.dtCurrentSectionStartTime = datetime(now, 'ConvertFrom', 'datenum');
            else
                obj.dtCurrentSectionStartTime = varargin{1};
            end
            
            obj.oCurrentReportResultsSection = Section(chSectionName);
            
            oSectionSummary = Section('Summary');
            
            oSectionSummary.add(Experiment.MakeParagraphWithBoldLabel('Start Time: ', datestr(obj.dtCurrentSectionStartTime, 'mmm dd, yyyy HH:MM:SS')));
            
            oSectionEndTime = Experiment.MakeParagraphWithBoldLabel('End Time: ', '');
            oSectionSummary.add(oSectionEndTime);
            obj.oCurrentSectionEndTimeParagraph = oSectionEndTime;
            
            oSectionElapsedTime = Experiment.MakeParagraphWithBoldLabel('Elapsed Time: ', '');
            oSectionSummary.add(oSectionElapsedTime);
            obj.oCurrentSectionElapsedTimeParagraph = oSectionElapsedTime;
            
            obj.oCurrentReportResultsSection.add(oSectionSummary);
        end
        
        function InitializeDefaultSection(obj)
            % if there's no section running, create a default one
            obj.InitializeSection(Experiment.chDefaultSectionName, obj.dtLastSectionEndTime);
        end
        
        function SubmitDCSResourceManagerRequestIfRequired(obj)
            DCSResourceManager.Connect(obj.sDCSResourceManagerConnectionPath, 'Verbose', false);
                        
            % parse user request
            c1xInputVarargin = Experiment.ParseDCSResourceManagerRequestSettings(obj.sDCSResourceManagerWorkerRequest);
                        
            if ~obj.bSubmittedDCSResourceManagerRequest || isempty(ParallelComputingUtils.GetCurrentParpool())
                DCSResourceManager.RequestWorkers(obj.sDCSResourceManagerRequestId, c1xInputVarargin{:});
                obj.bSubmittedDCSResourceManagerRequest = true;
            end
        end
        
        function EnsureSpecifiedParpoolIsRunning(obj)
            c1xParpoolVarargin = {'AutoAddClientPath', false, 'AttachedFiles', {}};
            
            if obj.bCreateDistributedParpool || obj.bCreateLocalParpool % user wants some kind of parpool
                
                oPool = ParallelComputingUtils.GetCurrentParpool();
                
                if obj.bCreateLocalParpool
                    
                    if isempty(oPool)
                        bCreatePool = true; % no pool so create it!
                    else
                        if isa(oPool.Cluster, 'parallel.cluster.Local') % is a local pool
                            if isempty(obj.dNumberOfLocalWorkers) % the user wants the maximum number of workers
                                if oPool.NumWorkers < oPool.Cluster.NumWorkers % the current pool is underutilizing the local cores, so delete the current one a create a new one
                                    delete(oPool);
                                    bCreatePool = true;
                                else
                                    bCreatePool = false; % the current pool is fully utilizing the local workers, no need to change
                                end
                            else % the user specified the number of workers to use
                                if oPool.NumWorkers == obj.dNumberOfLocalWorkers % the current pool's number of workers match the number requested, no change needed
                                    bCreatePool = false;
                                else % the current's pools number of workers doesn't match those requested, delete it and the request to make a need one
                                    delete(oPool);
                                    bCreatePool = true;
                                end
                            end
                        else % is not a local pool, delete, request a new one
                            delete(oPool);
                            bCreatePool = true;
                        end
                    end
                    
                    if bCreatePool
                        if isempty(obj.dNumberOfLocalWorkers)
                            parpool('local', c1xParpoolVarargin{:});
                        else
                            parpool('local', obj.dNumberOfLocalWorkers, c1xParpoolVarargin{:});
                        end
                        
                        obj.bPathsAddedToParpoolWorkers = false;
                    end
                    
                else % is using a DCS pool
                    
                    if obj.bUseDCSResourceManager
                        
                        % let the DCSResourceManager handle it
                        obj.SubmitDCSResourceManagerRequestIfRequired();
                        
                        [oPool, bCreatedPool] = DCSResourceManager.GetRequestedPoolWhenAvailable();
                        
                        if bCreatedPool
                            obj.bPathsAddedToParpoolWorkers = false;
                        end
                        
%                         if bCreatedPool
%                             oPool.addAttachedFiles({'Experiment.m'});
%                         else
%                             oPool.updateAttachedFiles();
%                         end
                            
                    else % not using a DCS Resource Manager
                        
                        if isempty(oPool)
                            bCreatePool = true; % no pool so create it!
                        else
                            chCurrentClusterProfile = oPool.Cluster.Profile;
                            
                            if ~strcmp(chCurrentClusterProfile, obj.chClusterProfileName) % incorrect profile name for current pool, delete it and create new pool
                                delete(oPool);
                                bCreatePool = true;
                            else % current pool is from the correct profile, need to check if it has the correct number of workers
                                if obj.dNumberOfDistributedWorkers == oPool.NumWorkers % correct number of workers, don't create new pool
                                    bCreatePool = false;
                                else % incorrect number of workers, delete current pool and create new pool
                                    delete(oPool);
                                    bCreatePool = true;
                                end
                            end
                        end
                        
                        if bCreatePool
                            parpool(obj.chClusterProfileName, obj.dNumberOfDistributedWorkers, c1xParpoolVarargin{:});
                            obj.bPathsAddedToParpoolWorkers = false;
                        end
                    end
                end
                
                obj.AddPathsToParpoolWorkersIfNeeded();
            end
        end
        
        function chPath = GetCurrentSectionResultsPath(obj)
            if ~obj.bSectionCurrentlyActive
                obj.InitializeDefaultSection();
            end
            
            chPath = obj.chCurrentSectionResultsPath;
        end
        
        function oSection = GetCurrentSection(obj)
            if ~obj.bSectionCurrentlyActive
                obj.InitializeDefaultSection();
            end
            
            oSection = obj.oCurrentSection;
        end
        
        function AddPathsToParpoolWorkersIfNeeded(obj)            
            if obj.bCreateLocalParpool
                if ~obj.bPathsAddedToParpoolWorkers
                    disp('Configuring parpool for experiment...');
                    % 1) Change the working directory of each worker to the
                    %    new experiment working directory. Add all
                    %    directories/sub-directories of new experiment working
                    %    directory to path except for Results
                    bRemoveAllPathsFromWorkers = true;
                    bChangeWorkingDirectoryAndAddPaths = true;
                    bResetGlobalVars = true;
                    
                    Experiment.AdjustPathsOnParforWorkers(...
                        bRemoveAllPathsFromWorkers, bChangeWorkingDirectoryAndAddPaths, bResetGlobalVars,...
                        obj.chNewWorkingDirectory, '', {}, {});
                    
                    obj.bPathsAddedToParpoolWorkers = true;
            
                    disp('Parpool successfully configured for experiment');
                else
                    % nothing to do
                end
            else % remote
                if ~obj.bPathsAddedToParpoolWorkers
                    disp('Configuring parpool for experiment...');
                    % 1) Find the host names of the computers the workers are
                    %    running on
                    bRemoveAllPathsFromWorkers = false;
                    bChangeWorkingDirectoryAndAddPaths = false;
                    bResetGlobalVars = false;
                    
                    vsWorkerHostComputerNames = Experiment.AdjustPathsOnParforWorkers(...
                        bRemoveAllPathsFromWorkers, bChangeWorkingDirectoryAndAddPaths, bResetGlobalVars,...
                        '', '', {}, {});
                    
                    % 2) Copy the new Experiment working directory to each of
                    %    the workers computer (local to do the lifting)
                    
                    vsWorkerHostComputerNamesToCopyCodeTo = unique(vsWorkerHostComputerNames);
                    chExperimentRootPath = obj.chNewWorkingDirectory;
                    
                    c1chWorkingDirectoryPathsAdded = obj.c1chWorkingDirectoryPathsAdded;
                    c1chCodePathsAdded = obj.c1chCodePathsAdded;
                    
                    % loop through each worker
                    disp('CentralLibrary: Copying experiment directory and code to remote workers');
                    
                    for dWorkerIndex=1:length(vsWorkerHostComputerNamesToCopyCodeTo)
                        chWorkerHostComputerName = char(vsWorkerHostComputerNamesToCopyCodeTo(dWorkerIndex));
                        
                        vdIndices = CellArrayUtils.FindExactString(obj.c1chRemotePoolWorkerHostComputerNames, chWorkerHostComputerName);
                        
                        if ~isscalar(vdIndices)
                            error(...
                                'Experiment:CreateParPoolAndAddPaths:WorkerHostNotConfigured',...
                                'The requested worker host computer name was not found (or was found multiple times) in the configuration settings.');
                        end
                        
                        if ~obj.vbFilesTransferredToWorker(vdIndices(1))
                            chExperimentRootPathOnWorkerFromLocal = strrep(chExperimentRootPath, obj.chRemotePoolLocalPathMatch, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByLocal{vdIndices(1)});
                            chNewCodeDirectoryPath = fullfile(chExperimentRootPathOnWorkerFromLocal, Experiment.chCodeDirectoryName);
                            
                            chNewExperimentRootPathOnLocal = obj.chNewWorkingDirectory;
                            
                            voEntries = dir(chNewExperimentRootPathOnLocal);
                            
                            vsExperimentRootPathFileCopyBlacklist = [...
                                string(obj.chDataPathsFilename),...
                                string(obj.chPathsFilename),...
                                string(obj.chExperimentSettingsFilename)];
                            
                            disp(['  Transferring files to ', chWorkerHostComputerName, ' via ', chExperimentRootPathOnWorkerFromLocal]);
                            
                            for dEntryIndex=3:length(voEntries)
                                oEntry = voEntries(dEntryIndex);
                                
                                if oEntry.isdir
                                    if ~strcmp(oEntry.name, Experiment.chResultsDirectoryName) % don't need to copy the results over
                                        try
                                            copyfile(...
                                                fullfile(chNewExperimentRootPathOnLocal, oEntry.name),...
                                                fullfile(chExperimentRootPathOnWorkerFromLocal, oEntry.name));
                                        catch e
                                            error(...
                                                'Experiment:SetParPoolAndAddPaths:FileCopyError',...
                                                ['Error copying file ', StringUtils.MakePathStringValidForPrinting(fullfile(chNewExperimentRootPathOnLocal, oEntry.name)), ' to ', StringUtils.MakePathStringValidForPrinting(fullfile(chExperimentRootPathOnWorkerFromLocal, oEntry.name))]);
                                        end
                                    end
                                else % is file
                                    chName = oEntry.name;
                                    sName = string(chName);
                                    
                                    if all(vsExperimentRootPathFileCopyBlacklist ~= sName) % not on blacklist
                                        copyfile(...
                                            fullfile(chNewExperimentRootPathOnLocal, chName),...
                                            fullfile(chExperimentRootPathOnWorkerFromLocal, chName));
                                    end
                                end
                            end
                            
                            obj.vbFilesTransferredToWorker(vdIndices(1)) = true;
                        end
                    end
                    
                    % 3) Change the working directory of each worker to the
                    %    new experiment working directory. Add all
                    %    directories/sub-directories of new experiment working
                    %    directory to path.
                    bRemoveAllPathsFromWorkers = true;
                    bChangeWorkingDirectoryAndAddPaths = true;
                    bResetGlobalVars = true;
                    
                    Experiment.AdjustPathsOnParforWorkers(...
                        bRemoveAllPathsFromWorkers, bChangeWorkingDirectoryAndAddPaths, bResetGlobalVars,...
                        obj.chNewWorkingDirectory, obj.chRemotePoolLocalPathMatch, obj.c1chRemotePoolWorkerHostComputerNames, obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker);
                    
                    obj.bPathsAddedToParpoolWorkers = true;
                    
                    disp('Parpool successfully configured for experiment');
                end
            end
        end
        
        function [bWasSaved, bCanLoad] = WasCurrentResumePointSaved(obj)
            voEntries = dir(fullfile(obj.chResumeFromPath, Experiment.chResumePointSaveFolder));
            
            dMaxResumePointNumber = 0;
            
            bCanLoad = false;
            
            for dEntryIndex=1:length(voEntries)
                oEntry = voEntries(dEntryIndex);
                
                if ~oEntry.isdir
                    chFilename = oEntry.name;
                    
                    if contains(chFilename, Experiment.chResumePointWorkspaceFileNameSuffix)
                        dPrefixIndex = strfind(chFilename, Experiment.chResumePointFilePrefix);
                        dSuffixIndex = strfind(chFilename, Experiment.chResumePointWorkspaceFileNameSuffix);
                        
                        chNumStr = chFilename(dPrefixIndex+length(Experiment.chResumePointFilePrefix) : dSuffixIndex-1);
                        dResumePointNumber = str2double(chNumStr);
                        
                        dMaxResumePointNumber = max(dMaxResumePointNumber, dResumePointNumber);
                        
                        if dResumePointNumber == obj.dCurrentRestorePointIndex
                            bCanLoad = true;
                        end
                    end
                end
            end
            
            bWasSaved = obj.dCurrentRestorePointIndex <= dMaxResumePointNumber;
        end
        
        function chLoadPath = GetCurrentResumePointLoadPath(obj)
            chRootPath = obj.chResumeFromPath;
            chFolderName = Experiment.chResumePointSaveFolder;
            chFilename = Experiment.CreateResumePointWorkspaceFilename(obj.dCurrentRestorePointIndex);
            
            chLoadPath = fullfile(chRootPath, chFolderName, chFilename);
        end
        
        function chResumePointRoot = GetResumePointRootPath(obj)
            chRootPath = obj.chNewWorkingDirectory;
            chFolderName = Experiment.chResumePointSaveFolder;
            
            FileIOUtils.MkdirIfItDoesNotExist(chRootPath, chFolderName);
            
            chResumePointRoot = fullfile(chRootPath, chFolderName);
        end
        
        function chSavePath = GetCurrentResumePointWorkspaceSavePath(obj)
            chRootPath = obj.GetResumePointRootPath();
            chFilename = Experiment.CreateResumePointWorkspaceFilename(obj.dCurrentRestorePointIndex);
            
            chSavePath = fullfile(chRootPath, chFilename);
        end
        
        function chSavePath = GetResumePointGlobalVarsSavePath(obj)
            chRootPath = obj.GetResumePointRootPath();
            chFilename = Experiment.CreateResumePointGlobalVarsFilename(obj.dCurrentRestorePointIndex);
            
            chSavePath = fullfile(chRootPath, chFilename);
        end
        
        function chLoadPath = GetResumePointGlobalVarsLoadPath(obj)
            chRootPath = obj.chResumeFromPath;
            chFolderName = Experiment.chResumePointSaveFolder;
            chFilename = Experiment.CreateResumePointGlobalVarsFilename(obj.dCurrentRestorePointIndex);
            
            chLoadPath = fullfile(chRootPath, chFolderName, chFilename);
        end
        
        function chSavePath = GetResumePointRandomNumberGeneratorSavePath(obj)
            chRootPath = obj.GetResumePointRootPath();
            chFilename = Experiment.CreateResumePointRandomNumberGeneratorFilename(obj.dCurrentRestorePointIndex);
            
            chSavePath = fullfile(chRootPath, chFilename);
        end
        
        function chLoadPath = GetResumePointRandomNumberGeneratorLoadPath(obj)
            chRootPath = obj.chResumeFromPath;
            chFolderName = Experiment.chResumePointSaveFolder;
            chFilename = Experiment.CreateResumePointRandomNumberGeneratorFilename(obj.dCurrentRestorePointIndex);
            
            chLoadPath = fullfile(chRootPath, chFolderName, chFilename);
        end
    end
    
    
    methods (Access = private, Static = true)
        
        function c1xInputVarargin = ParseDCSResourceManagerRequestSettings(sDCSResourceManagerWorkerRequest)
            sAmapMinus = "As many as possible minus";
            
            if contains(sDCSResourceManagerWorkerRequest, sAmapMinus)
                chDCSResourceManagerWorkerRequest = char(sDCSResourceManagerWorkerRequest);
                
                vdIndices = strfind(chDCSResourceManagerWorkerRequest, sAmapMinus);
                
                dNumWorkers = str2double(chDCSResourceManagerWorkerRequest(vdIndices(1) + length(char(sAmapMinus)) : end));
                
                if isnan(dNumWorkers)
                    error(...
                        'Experiment:ParseDCSResourceManagerRequestSettings:InvalidAsManyAsPossibleMinus',...
                        '"As many as possible minus n" not specified correctly.');
                end
                
                c1xInputVarargin = {'AsManyAsPossibleMinus', dNumWorkers};
            elseif sDCSResourceManagerWorkerRequest == "As many as possible"
                c1xInputVarargin = {'AsManyAsPossible'};
            elseif ~isnan(str2double(sDCSResourceManagerWorkerRequest))
                c1xInputVarargin = {str2double(sDCSResourceManagerWorkerRequest)};
            else
                error(...
                    'Experiment:ParseDCSResourceManagerRequestSettings:InvalidDCSResourceManagerWorkerRequest',...
                    'See Experiment settings documentation.');
            end
        end
        
        function chFilename = CreateResumePointWorkspaceFilename(dResumePointIndex)
            chFilename = [Experiment.chResumePointFilePrefix, ' ', num2str(dResumePointIndex), ' ', Experiment.chResumePointWorkspaceFileNameSuffix];
        end
        
        function chFilename = CreateResumePointGlobalVarsFilename(dResumePointIndex)
            chFilename = [Experiment.chResumePointFilePrefix, ' ', num2str(dResumePointIndex), ' ', Experiment.chResumePointGlobalVarsFileNameSuffix];
        end
        
        function chFilename = CreateResumePointRandomNumberGeneratorFilename(dResumePointIndex)
            chFilename = [Experiment.chResumePointFilePrefix, ' ', num2str(dResumePointIndex), ' ', Experiment.chResumePointRandomNumberGeneratorFileNameSuffix];
        end
        
        function RemoveAllCodeFromPath()
            if ispc
                chSplitChar = ';';
            else
                chSplitChar = ':';
            end
            
            chAllPaths = path;
            
            c1chPaths = strsplit(chAllPaths, chSplitChar);
            
            chPathsToRemove = blanks(length(chAllPaths));
            dInsertIndex = 1;
            
            chMatlabRoot = matlabroot;
            dRootLength = length(chMatlabRoot);
            
            for dPathIndex=1:length(c1chPaths)
                if length(c1chPaths{dPathIndex}) < dRootLength || ~strcmp(chMatlabRoot, c1chPaths{dPathIndex}(1:dRootLength))
                    chPath = c1chPaths{dPathIndex};
                    dPathLength = length(chPath);
                    
                    chPathsToRemove(dInsertIndex : dInsertIndex + dPathLength - 1) = chPath;
                    chPathsToRemove(dInsertIndex + dPathLength) = chSplitChar;
                    dInsertIndex = dInsertIndex + dPathLength + 1;
                else
                    % we've hit Matlab code, so we can stop checking for
                    % the sake of time
                    break;
                end
            end
            
            % trim and remove
            chPathsToRemove = chPathsToRemove(1:dInsertIndex-1);
            
            rmpath(chPathsToRemove);
        end
        
        function c1chFilePaths = GetFilePathsForFolderPaths(c1chFolderPaths)
            dNumFolders = length(c1chFolderPaths);
            c1c1chFilePathsPerFolder = cell(dNumFolders,1);
            
            dNumFiles = 0;
            
            for dFolderIndex=1:dNumFolders
                voEntries = dir(c1chFolderPaths{dFolderIndex});
                dNumEntries = length(voEntries);
                
                c1chPaths = cell(dNumEntries,1);
                vbIsFile = false(dNumEntries,1);
                
                for dEntryIndex=1:dNumEntries
                    if ~voEntries(dEntryIndex).isdir
                        c1chPaths{dEntryIndex} = fullfile(c1chFolderPaths{dFolderIndex}, voEntries(dEntryIndex).name);
                        vbIsFile(dEntryIndex) = true;
                    end
                end
                
                c1c1chFilePathsPerFolder{dFolderIndex} = c1chPaths(vbIsFile);
                dNumFiles = dNumFiles + sum(vbIsFile);
            end
            
            c1chFilePaths = cell(dNumFiles,1);
            
            dInsertIndex = 1;
            
            for dFolderIndex=1:dNumFolders
                dNumToInsert = length(c1c1chFilePathsPerFolder{dFolderIndex});
                
                c1chFilePaths(dInsertIndex : dInsertIndex + dNumToInsert - 1) = c1c1chFilePathsPerFolder{dFolderIndex};
                dInsertIndex = dInsertIndex + dNumToInsert;
            end
        end
        
        function oCurrentSection = GetCurrentExperimentSection()
            oManager = Experiment.GetCurrentExperimentManager();
            
            oCurrentSection = oManager.GetCurrentSection();
        end
        
        function oCurrentExperimentManager = GetCurrentExperimentManager()
            global oExperiment;
            global oLoopIterationExperimentPortion;
            
            if Experiment.IsRunningManagedLoopIteration()
                oCurrentExperimentManager = oLoopIterationExperimentPortion;
            else
                oCurrentExperimentManager = oExperiment;
            end
        end
        
        function bBool = IsRunningManagedLoopIteration()
            global oLoopIterationExperimentPortion;
            
            bBool = ~isempty(oLoopIterationExperimentPortion);
        end
        
        function [chPath, chLastItem] = SeparateFilePathAndLastItem(chFilePath)
            vdIndices = strfind(chFilePath, filesep);
            
            if isempty(vdIndices)
                chPath = '';
                chLastItem = chFilePath;
            else
                chPath = chFilePath(1:(vdIndices(end)-1));
                chLastItem = chFilePath((vdIndices(end)+1):end);
            end
        end
        
        function CopyCodeDirectory(chSourceDirPath, chDestDirPath)
            mkdir(chDestDirPath);
            
            voEntries = dir(chSourceDirPath);
            
            for dEntryIndex=3:length(voEntries) % ignore '.' and '..'
                oEntry = voEntries(dEntryIndex);
                
                if ~strcmp(oEntry.name, Experiment.chGitFolderName) % ignore .git folders
                    % copy any files not in directories
                    copyfile(...
                        fullfile(chSourceDirPath, oEntry.name),...
                        fullfile(chDestDirPath, oEntry.name));
                end
            end
        end
        
        function chPathsToAdd = GetCodeDirectoryPathsToAdd(chDirPath)
            dMaxPathsToAddLength = length(genpath(chDirPath));
            
            chPathsToAdd = blanks(dMaxPathsToAddLength);
            
            dDirPathLength = length(chDirPath);
            
            chPathsToAdd(1:dDirPathLength) = chDirPath;
            chPathsToAdd(dDirPathLength+1) = ';';
            dPathsToAddInsertIndex = dDirPathLength + 1 + 1;
            
            voEntries = dir(chDirPath);
            
            for dEntryIndex=3:length(voEntries) % ignore '.' and '..'
                oEntry = voEntries(dEntryIndex);
                
                if oEntry.isdir && ~strcmp(oEntry.name, Experiment.chGitFolderName) % ignore .git folders
                    [chPathsToAdd, dPathsToAddInsertIndex] = Experiment.GetCodeDirectoryPathsToAdd_Recursive(...
                        fullfile(chDirPath, oEntry.name),....
                        chPathsToAdd, dPathsToAddInsertIndex);
                end
            end
            
            chPathsToAdd = chPathsToAdd(1:dPathsToAddInsertIndex-1);
        end
        
        function [chPathsToAdd, dPathsToAddInsertIndex] = GetCodeDirectoryPathsToAdd_Recursive(chDirPath, chPathsToAdd, dPathsToAddInsertIndex)
            dDirPathLength = length(chDirPath);
            
            chPathsToAdd(dPathsToAddInsertIndex:dPathsToAddInsertIndex+dDirPathLength-1) = chDirPath;
            chPathsToAdd(dPathsToAddInsertIndex+dDirPathLength) = ';';
            dPathsToAddInsertIndex = dPathsToAddInsertIndex + dDirPathLength + 1;
            
            voEntries = dir(chDirPath);
            
            for dEntryIndex=3:length(voEntries) % ignore '.' and '..'
                oEntry = voEntries(dEntryIndex);
                
                if oEntry.isdir && ~strcmp(oEntry.name, Experiment.chGitFolderName) % ignore .git folders
                    [chPathsToAdd, dPathsToAddInsertIndex] = Experiment.GetCodeDirectoryPathsToAdd_Recursive(...
                        fullfile(chDirPath, oEntry.name),....
                        chPathsToAdd, dPathsToAddInsertIndex);
                end
            end
        end
        
        function CopyCentralLibraryDirectory(chSourceDirPath, chDestDirPath)
            % make folder
            mkdir(chDestDirPath);
            
            % copy, obeying the blacklists
            
            voEntries = dir(chSourceDirPath);
            
            for dEntryIndex=3:length(voEntries) % ignore '.' and '..'
                oEntry = voEntries(dEntryIndex);
                
                if ~oEntry.isdir
                    bOnFileBlacklist = false;
                    
                    chName = oEntry.name;
                    
                    for dBlacklistIndex=1:length(Experiment.c1chCentralLibaryRootFileBlacklist)
                        if strcmp(Experiment.c1chCentralLibaryRootFileBlacklist{dBlacklistIndex}, chName)
                            bOnFileBlacklist = true;
                            break;
                        end
                    end
                    
                    if ~bOnFileBlacklist
                        % copy any files not in directories
                        copyfile(...
                            fullfile(chSourceDirPath, oEntry.name),...
                            fullfile(chDestDirPath, oEntry.name));
                    end
                else
                    % is directory, so we need to check if directory is on
                    % the blacklist
                    chName = oEntry.name;
                    
                    bOnBlacklist = false;
                    
                    for dBlacklistIndex=1:length(Experiment.c1chCentralLibaryRootFolderBlacklist)
                        if strcmp(chName, Experiment.c1chCentralLibaryRootFolderBlacklist{dBlacklistIndex})
                            bOnBlacklist = true;
                            break;
                        end
                    end
                    
                    % only copy if not on blacklish
                    if ~bOnBlacklist
                        Experiment.CopyCentralLibrarySubDirectory_Recursive(...
                            fullfile(chSourceDirPath, chName),...
                            fullfile(chDestDirPath, chName));
                    end
                end
            end
        end
        
        function CopyCentralLibrarySubDirectory_Recursive(chSourceDirPath, chDestDirPath)
            voEntries = dir(chSourceDirPath);
            
            mkdir(chDestDirPath);
            
            for dEntryIndex=3:length(voEntries) % ignore '.' and '..'
                oEntry = voEntries(dEntryIndex);
                chName = oEntry.name;
                
                if ~oEntry.isdir
                    % copy any files not in directories
                    copyfile(...
                        fullfile(chSourceDirPath, chName),...
                        fullfile(chDestDirPath, chName));
                else
                    % is directory, so we need to check if directory is on
                    % the sub directory blacklist
                    bOnBlacklist = false;
                    
                    for dBlacklistIndex=1:length(Experiment.c1chCentralLibrarySubfolderBlacklist)
                        if strcmp(chName, Experiment.c1chCentralLibrarySubfolderBlacklist{dBlacklistIndex})
                            bOnBlacklist = true;
                            break;
                        end
                    end
                    
                    % only copy if not on blacklish
                    if ~bOnBlacklist
                        Experiment.CopyCentralLibrarySubDirectory_Recursive(...
                            fullfile(chSourceDirPath, chName),...
                            fullfile(chDestDirPath, chName));
                    end
                end
            end
        end
        
        function chPathsToAdd = GetCentralLibraryDirectoryPathsToAdd(chDirPath)
            dMaxLength = length(genpath(chDirPath));
            
            chPathsToAdd = blanks(dMaxLength);
            chPathsToAdd(1:length(chDirPath)) = chDirPath;
            chPathsToAdd(length(chDirPath)+1) = ';';
            
            dPathsToAddInsertIndex = length(chDirPath) + 1 + 1;
            
            % copy, obeying the blacklists
            
            voEntries = dir(chDirPath);
            
            for dEntryIndex=3:length(voEntries) % ignore '.' and '..'
                oEntry = voEntries(dEntryIndex);
                
                if oEntry.isdir
                    % is directory, so we need to check if directory is on
                    % the blacklist
                    chName = oEntry.name;
                    
                    bOnBlacklist = false;
                    
                    for dBlacklistIndex=1:length(Experiment.c1chCentralLibaryRootFolderBlacklist)
                        if strcmp(chName, Experiment.c1chCentralLibaryRootFolderBlacklist{dBlacklistIndex})
                            bOnBlacklist = true;
                            break;
                        end
                    end
                    
                    % only copy if not on blacklish
                    if ~bOnBlacklist
                        [chPathsToAdd, dPathsToAddInsertIndex] = Experiment.GetCentralLibrarySubDirectoryPathsToAdd_Recursive(...
                            fullfile(chDirPath, chName),...
                            chPathsToAdd, dPathsToAddInsertIndex);
                    end
                end
            end
            
            % trim allocated paths
            chPathsToAdd = chPathsToAdd(1:dPathsToAddInsertIndex-1);
        end
        
        function [chPathsToAdd, dPathsToAddInsertIndex] = GetCentralLibrarySubDirectoryPathsToAdd_Recursive(chDirPath, chPathsToAdd, dPathsToAddInsertIndex)
            voEntries = dir(chDirPath);
            
            dLengthCurrentDir = length(chDirPath);
            chPathsToAdd(dPathsToAddInsertIndex:dPathsToAddInsertIndex+dLengthCurrentDir-1) = chDirPath;
            chPathsToAdd(dPathsToAddInsertIndex+dLengthCurrentDir) = ';';
            
            dPathsToAddInsertIndex = dPathsToAddInsertIndex + dLengthCurrentDir + 1;
            
            for dEntryIndex=3:length(voEntries) % ignore '.' and '..'
                oEntry = voEntries(dEntryIndex);
                chName = oEntry.name;
                
                if oEntry.isdir
                    % is directory, so we need to check if directory is on
                    % the sub directory blacklist
                    bOnBlacklist = false;
                    
                    for dBlacklistIndex=1:length(Experiment.c1chCentralLibrarySubfolderBlacklist)
                        if strcmp(chName, Experiment.c1chCentralLibrarySubfolderBlacklist{dBlacklistIndex})
                            bOnBlacklist = true;
                            break;
                        end
                    end
                    
                    % only copy if not on blacklish
                    if ~bOnBlacklist
                        [chPathsToAdd, dPathsToAddInsertIndex] = Experiment.GetCentralLibrarySubDirectoryPathsToAdd_Recursive(...
                            fullfile(chDirPath, chName),...
                            chPathsToAdd, dPathsToAddInsertIndex);
                    end
                end
            end
        end
        
        function [c1chDataPathLabels, c1chDataPaths] = LoadDataPathsFile()
            global oExperiment;
            
            if isempty(oExperiment) % if no experiment is running, just look in current working directory for file
                chLoadPath = pwd;
            else
                chLoadPath = oExperiment.chStartingWorkingDirectory;
            end
            
            chFilePath = fullfile(chLoadPath, Experiment.chDataPathsFilename);
            
            if exist(chFilePath, 'file') == 0
                error(...
                    'Experiment:LoadDataPathsFile:FileNoFound',...
                    ['No file named "', Experiment.chDataPathsFilename, '" found in the current working directory.']);
            end
            
            chText = fileread(chFilePath);
            c1chLines = regexp(chText, '\r\n|\r|\n', 'split');
            dNumLines = length(c1chLines);
            
            c1chDataPathLabels = cell(dNumLines,1);
            c1chDataPaths = cell(dNumLines,1);
            
            dNumPaths = 0;
            
            for dLineIndex=1:dNumLines
                chLine = c1chLines{dLineIndex};
                
                chLine = strtrim(chLine);
                
                if ~isempty(chLine) % make sure it's not just a blank line
                    vdColonIndices = strfind(chLine, ':');
                    dNumColons = length(vdColonIndices);
                    
                    % check for correct format
                    if dNumColons ~= 1 && dNumColons ~= 2
                        error(...
                            'Experiment:LoadDataPathsFile:IncorrectFileFormat',...
                            ['Each line in ', Experiment.chDataPathsFilename, ' must consist of the format "Label : path"']);
                    end
                    
                    % get label from line
                    chLabel = strtrim(chLine(1:vdColonIndices(1)-1));
                    chPath = strtrim(chLine(vdColonIndices(1)+1:end));
                    
                    % check if path exists
                    if exist(chPath, 'dir') == 0 && exist(chPath, 'file') == 0
                        warning(...
                            ['The path "', StringUtils.MakePathStringValidForPrinting(chPath), '" could not be found.']);
                    end
                    
                    % check if label was already in the file
                    bLabelFound = false;
                    
                    for dLabelIndex=1:dNumPaths
                        if strcmp(c1chDataPathLabels{dLabelIndex}, chLabel)
                            bLabelFound = true;
                            break;
                        end
                    end
                    
                    if bLabelFound
                        error(...
                            'Experiment:LoadDataPathsFile:DuplicateLabel',...
                            ['The label "', chLabel, '" was found more than once in ', Experiment.chDataPathsFilename, '.']);
                    end
                    
                    % add the path and label
                    dNumPaths = dNumPaths + 1;
                    c1chDataPathLabels{dNumPaths} = chLabel;
                    c1chDataPaths{dNumPaths} = chPath;
                end
            end
            
            c1chDataPathLabels = c1chDataPathLabels(1:dNumPaths);
            c1chDataPaths = c1chDataPaths(1:dNumPaths);
        end
        
        function oParagraph = MakeParagraphWithBoldLabel(chLabel, chText)
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            oLabel = Text(chLabel);
            oLabel.Bold = true;
            
            oText = Text(chText);
            
            oParagraph = Paragraph();
            
            oParagraph.append(oLabel);
            oParagraph.append(oText);
        end
        
        function oParagraph = MakeLinkParagraphWithBoldLabel(chLabel, chText, chLink)
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            oLabel = Text(chLabel);
            oLabel.Bold = true;
            
            oLink = ExternalLink(chLink, chText);
            
            oParagraph = Paragraph();
            
            oParagraph.append(oLabel);
            oParagraph.append(oLink);
        end
        
        function [chRepoName, chBranchName, chCommitId, chGithubRepoRemoteUrl] = GetGitMetadata(chRepoPath)
            % get branch name
            chText = fileread(fullfile(chRepoPath, Experiment.chGitCurrentBranchMetadataPath));
            
            vdIndices = strfind(chText, '/');
            chBranchName = chText(vdIndices(end)+1 : end - 1); % end -1 to remove new line char.
            
            % get commit number
            c2chMetadata = readcell(fullfile(chRepoPath, Experiment.chGitBranchCommitIdsMetadataPath), "FileType", "text", 'Delimiter', '\t');
            
            chCommitId = '';
            
            for dBranchIndex=1:size(c2chMetadata,1)
                if contains(c2chMetadata{dBranchIndex,3}, ['''', chBranchName, ''''])
                    chCommitId = c2chMetadata{dBranchIndex,1};
                    break
                end
            end
            
            if isempty(chCommitId)
                error(...
                    'Experiment:GetGitMetadata:BranchCommitIdNotFound',...
                    'The branch was not found in the commit id list.');
            end
            
            % URL/Repo name
            chText = fileread(fullfile(chRepoPath, Experiment.chGitConfigMetadataPath));
            c1chLines = regexp(chText, '\r\n|\r|\n', 'split');
            
            chGithubRepoRemoteUrl = '';
            chRepoName = '';
            
            for dLineIndex=1:length(c1chLines)
                if strcmp(c1chLines{dLineIndex}, '[remote "origin"]')
                    chNextLine = strtrim(c1chLines{dLineIndex+1});
                    
                    if strcmp(chNextLine(1:5), 'url =')
                        chGithubRepoRemoteUrl = strtrim(chNextLine(6:end));
                        
                        % remove .git
                        chGithubRepoRemoteUrl = chGithubRepoRemoteUrl(1:end-4);
                        
                        % find repo name:
                        vdSlashIndices = strfind(chGithubRepoRemoteUrl, '/');
                        
                        chRepoName = chGithubRepoRemoteUrl(vdSlashIndices(end)+1 : end);
                    end
                    
                    break;
                end
            end
        end
                
        function ThrowNoParallelIterationManagerFoundError()
            error(...
                'Experiment:ThrowNoParallelIterationManagerFoundError:NoParallelIterationManagerFound',...
                'The Experiment class cannot be used within a parfor loop without using the ExperimentParallelIterationManager.');
        end
        
        function bBool = IsInParallelComputing()
            global oExperiment;
            global oLoopIterationExperimentPortion;
            
            [chHostComputerName, dWorkerNumberOrProcessId] = Experiment.GetCurrentComputationEnvironmentDetails();
            
            if ~isempty(oLoopIterationExperimentPortion)
                chInitialHostComputerName = oLoopIterationExperimentPortion.GetInitialComputationHostComputerName();
                dInitialWorkerNumberOrProcessId = oLoopIterationExperimentPortion.GetInitialComputationWorkerNumberOrProcessId();
            else
                chInitialHostComputerName = oExperiment.chInitialComputationHostComputerName;
                dInitialWorkerNumberOrProcessId = oExperiment.dInitialComputationWorkerNumberOrProcessId;
            end
            
            bBool = ~strcmp(chHostComputerName, chInitialHostComputerName) || dWorkerNumberOrProcessId ~= dInitialWorkerNumberOrProcessId;
        end
        
        function MakeDirIfRequired(chDirPath)
            if 0 == exist(chDirPath, 'dir')
                mkdir(chDirPath);
            end
        end
        
        function [vsWorkerHostComputerNames, vdWorkerNumbers] = AdjustPathsOnParforWorkers(bRemoveAllPathsFromWorkers, bChangeWorkingDirectoryAndAddPaths, bResetGlobalVars, chNewWorkingDirectoryOnLocal, chPathPortionToReplaceOnWorkers, c1chWorkerComputerNames, c1chNewPathPortionPerWorkerComputerName, bResetWorkingDirectory)
            arguments
                bRemoveAllPathsFromWorkers
                bChangeWorkingDirectoryAndAddPaths
                bResetGlobalVars
                chNewWorkingDirectoryOnLocal
                chPathPortionToReplaceOnWorkers
                c1chWorkerComputerNames
                c1chNewPathPortionPerWorkerComputerName
                bResetWorkingDirectory = false
            end
            
            
            oPool = gcp('nocreate');
            dNumWorkers = oPool.NumWorkers;
            
            vsWorkerHostComputerNames = strings(dNumWorkers,1);
            vdWorkerNumbers = zeros(dNumWorkers,1);
            
            if bChangeWorkingDirectoryAndAddPaths
                disp('CentralLibrary: Adding code paths for each worker');
            end
            
            parfor dCurrentWorkerIndex=1:dNumWorkers
                % SET COMPUTER/WORKER
                oTask = getCurrentTask();
                chHostComputerName = char(java.net.InetAddress.getLocalHost.getHostName);
                
                dWorkerNumberOrProcessId = 0;
                
                chWorkerDisplayString = '';
                
                if isempty(oTask) % we're running locally and NOT as a batch
                    dWorkerNumberOrProcessId = 0;
                    
                    chWorkerDisplayString = [chHostComputerName ' (local)'];
                else
                    oWorker = oTask.Worker;
                    
                    if isa(oWorker, 'parallel.cluster.MJSWorker') % don't have access to process ID, extract the worker number from the worker name
                        chWorkerName = oWorker.Name;
                        chWorkerStringTag = '_worker';
                        
                        dWorkerIndex = strfind(chWorkerName, chWorkerStringTag);
                        
                        if ~isscalar(dWorkerIndex) || isnan(str2double(chWorkerName(dWorkerIndex+length(chWorkerStringTag) : end)))
                            error(...
                                'Experiment:AdjustPathsOnParforWorkers:InvalidWorkerNameFormat',...
                                'Worker names must be specified as "<HOSTNAME>._workerXX"');
                        end
                        
                        dWorkerNumberOrProcessId = str2double(chWorkerName(dWorkerIndex+length(chWorkerStringTag) : end));
                        
                        chWorkerDisplayString = [chHostComputerName, ' (# ', num2str(dWorkerNumberOrProcessId), ')'];
                    elseif isa(oWorker, 'parallel.cluster.CJSWorker') % easy, pick off the process ID
                        dWorkerNumberOrProcessId = oWorker.ProcessId;
                        
                        chWorkerDisplayString = [chHostComputerName, ' (PID ', num2str(dWorkerNumberOrProcessId), ')'];
                    else
                        error(...
                            'Experiment:AdjustPathsOnParforWorkers:InvalidWorkerType',...
                            'Worker must be of type parallel.cluster.MJSWorker or parallel.cluster.CJSWorker');
                    end
                end
                
                vsWorkerHostComputerNames(dCurrentWorkerIndex) = string(chHostComputerName);
                vdWorkerNumbers(dCurrentWorkerIndex) = dWorkerNumberOrProcessId;
                
                % REMOVE ALL PATHS (EXCEPT FOR MATLAB PATHS)
                if bRemoveAllPathsFromWorkers
                    if ispc
                        chSplitChar = ';';
                    else
                        chSplitChar = ':';
                    end
                    
                    chAllPaths = path;
                    
                    c1chPaths = strsplit(chAllPaths, chSplitChar);
                    
                    chPathsToRemove = blanks(length(chAllPaths));
                    dInsertIndex = 1;
                    
                    chMatlabRoot = matlabroot;
                    dRootLength = length(chMatlabRoot);
                    
                    for dPathIndex=1:length(c1chPaths)
                        if length(c1chPaths{dPathIndex}) < dRootLength || ~strcmp(chMatlabRoot, c1chPaths{dPathIndex}(1:dRootLength))
                            chPath = c1chPaths{dPathIndex};
                            dPathLength = length(chPath);
                            
                            chPathsToRemove(dInsertIndex : dInsertIndex + dPathLength - 1) = chPath;
                            chPathsToRemove(dInsertIndex + dPathLength) = chSplitChar;
                            dInsertIndex = dInsertIndex + dPathLength + 1;
                        else
                            % we've hit Matlab code, so we can stop checking for
                            % the sake of time
                            break;
                        end
                    end
                    
                    % trim and remove
                    chPathsToRemove = chPathsToRemove(1:dInsertIndex-1);
                    
                    rmpath(chPathsToRemove);
                end
                
                % RESET WORKING DIRECTORY
                if bResetWorkingDirectory
                    cd(matlabroot);
                end
                
                % CHANGE WORKING DIRECTORY
                if bChangeWorkingDirectoryAndAddPaths
                    chCodeDisplayPath = '';
                    
                    if isempty(chPathPortionToReplaceOnWorkers)
                        cd(chNewWorkingDirectoryOnLocal);
                        addpath(genpath(chNewWorkingDirectoryOnLocal));
                        
                        chCodeDisplayPath = chNewWorkingDirectoryOnLocal;
                    else
                        dNumNames = length(c1chWorkerComputerNames);
                        vbMatch = false(dNumNames,1);
                        
                        for dSearchIndex=1:dNumNames
                            if strcmp(c1chWorkerComputerNames{dSearchIndex}, chHostComputerName)
                                vbMatch(dSearchIndex) = true;
                            end
                        end
                        
                        vdIndices = find(vbMatch);
                        
                        if ~isscalar(vdIndices)
                            error(...
                                'Experiment:AdjustPathsOnParforWorkers:WorkerHostNotConfigured',...
                                'The requested worker host computer name was not found (or was found multiple times) in the configuration settings.');
                        end
                        
                        chWorkingDirectoryOnWorker = strrep(chNewWorkingDirectoryOnLocal, chPathPortionToReplaceOnWorkers, c1chNewPathPortionPerWorkerComputerName{vdIndices(1)});
                        
                        cd(chWorkingDirectoryOnWorker);
                        addpath(genpath(chWorkingDirectoryOnWorker));
                        
                        chCodeDisplayPath = chWorkingDirectoryOnWorker;
                    end
                    
                    disp(['  Worker ', num2str(dCurrentWorkerIndex), ': ', chWorkerDisplayString, ' [', chCodeDisplayPath, ']']);
                end
                
                if bResetGlobalVars
                    % reset global vars
                    LoopIterationExperimentPortion.ResetGlobalVar();
                end
            end
            
            vsWorkerComputerNamesAndNumbers = vsWorkerHostComputerNames + "." + string(vdWorkerNumbers);
            
            if length(vsWorkerComputerNamesAndNumbers) ~= length(unique(vsWorkerComputerNamesAndNumbers))
                error(...
                    'Experiment:AdjustPathsOnParforWorkers:NotAllWorkersSampled',...
                    'Not all the workers were accessed during the parfor run.');
            end
            
        end
        
        function CallMustBeFromMainFile()
            vstStack = dbstack;
            bInvalid = false;
            
            if length(vstStack) < 4
                bInvalid = true;
            else
                %all calls but the first must be from within Experiment.m
                for dStackIndex=1:length(vstStack)-4
                    if ~strcmp(vstStack(dStackIndex).file, 'Experiment.m')
                        bInvalid = true;
                        break;
                    end
                end
                
                % the first three calls must be the standard flow through
                % the Experiment class
                if ~strcmp(vstStack(end).file, 'Experiment.m')
                    bInvalid = true;
                end
                
                if ~strcmp(vstStack(end-1).file, 'Experiment.m') && ~strcmp(vstStack(end-1).name, 'RunMain')
                    bInvalid = true;
                end
                
                if ~strcmp(vstStack(end-2).file, 'run.m') && ~strcmp(vstStack(end-2).name, 'run')
                    bInvalid = true;
                end
                
                % the first call must be from main.m and the "main" function
                if ~strcmp(vstStack(end-3).file, 'main.m') && ~strcmp(vstStack(end-3).name, 'main')
                    bInvalid = true;
                end
            end
            
            % throw error if needed
            if bInvalid
                error(...
                    'Experiment:CallMustBeFromMainFile:CallNotFromMain',...
                    'The call to the Experiment class was not from main.m or was from a sub-function in main.m.');
            end
        end
        
        function RunBatchJob(sLocalExperimentPath, stSettings)
            sComputerName = string(java.net.InetAddress.getLocalHost.getHostName);
            
            dHostIndex = find(stSettings.RemotePoolWorkerHostComputerNames == sComputerName);
            
            sExperimentPath = strrep(sLocalExperimentPath, stSettings.RemotePoolLocalPathMatch, stSettings.RemotePoolLocalPathReplacePerHostForAccessByWorker(dHostIndex));
            
            cd(sExperimentPath);
            
            which('Experiment');
            
            Experiment.Run();
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