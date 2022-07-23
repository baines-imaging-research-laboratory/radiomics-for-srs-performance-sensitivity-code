classdef LoopIterationExperimentPortion < handle
    %LoopIterationExperimentPortion
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Dec 19, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
        
    properties (SetAccess = immutable, GetAccess = public)        
        dIterationNumber
        
        bAutoAddEntriesIntoExperimentReport (1,1) logical
        bAutoSaveObjects (1,1) logical
        bAutoSaveSummaryFiles (1,1) logical
        
        chInitialComputationHostComputerName
        dInitialComputationWorkerNumberOrProcessId
        
        chExperimentResultsDirectoryRootPath
        chIterationDirectoryName
        
        chClusterProfileName
        
        chRemotePoolLocalPathMatch
        c1chRemotePoolWorkerHostComputerNames
        c1chRemotePoolLocalPathReplacePerHostForAccessByWorker
        c1chRemotePoolLocalPathReplacePerHostForAccessByLocal
        
        c1chDataPaths
        c1chDataPathLabels
        
        bParentLoopManagerSetToAvoidIterationRecomputationIfResumed
    end
    
    properties (SetAccess = private, GetAccess = public)  
        oCurrentSection
        
        bValuesAddedToReport = false
        bLoopIterationDirectoryMade = false
    end
    
    properties (Constant = true, GetAccess = private)     
        chCurrentSectionVarName = 'oCurrentSection'        
    end
      
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function obj = LoopIterationExperimentPortion(dIterationNumber, oCurrentSection, chExperimentResultsDirectoryRootPath, chIterationDirectoryName, bAutoAddEntriesIntoExperimentReport, bAutoSaveObjects, bAutoSaveSummaryFiles, chInitialComputationHostComputerName, dInitialComputationWorkerNumberOrProcessId, chClusterProfileName, chRemotePoolLocalPathMatch, c1chRemotePoolWorkerHostComputerNames, c1chRemotePoolLocalPathReplacePerHostForAccessByWorker, c1chRemotePoolLocalPathReplacePerHostForAccessByLocal, c1chDataPaths, c1chDataPathLabels, bParentLoopManagerSetToAvoidIterationRecomputationIfResumed)
            arguments
                dIterationNumber (1,1) double {mustBePositive, mustBeInteger}
                oCurrentSection (1,1) ExperimentSubSection
                chExperimentResultsDirectoryRootPath (1,:) char
                chIterationDirectoryName (1,:) char
                bAutoAddEntriesIntoExperimentReport (1,1) logical
                bAutoSaveObjects (1,1) logical
                bAutoSaveSummaryFiles (1,1) logical
                chInitialComputationHostComputerName (1,:) char
                dInitialComputationWorkerNumberOrProcessId (1,1) double {mustBeInteger, mustBeNonnegative}
                chClusterProfileName
                chRemotePoolLocalPathMatch
                c1chRemotePoolWorkerHostComputerNames
                c1chRemotePoolLocalPathReplacePerHostForAccessByWorker
                c1chRemotePoolLocalPathReplacePerHostForAccessByLocal
                c1chDataPaths
                c1chDataPathLabels
                bParentLoopManagerSetToAvoidIterationRecomputationIfResumed (1,1) logical
            end
            
            obj.dIterationNumber = dIterationNumber;    
            
            obj.oCurrentSection = copy(oCurrentSection);
            obj.oCurrentSection.SetIsWithinParfor(true);
            
            obj.chExperimentResultsDirectoryRootPath = chExperimentResultsDirectoryRootPath;
            obj.chIterationDirectoryName = chIterationDirectoryName;
            
            obj.bAutoAddEntriesIntoExperimentReport = bAutoAddEntriesIntoExperimentReport;
            obj.bAutoSaveObjects = bAutoSaveObjects;
            obj.bAutoSaveSummaryFiles = bAutoSaveSummaryFiles;
            
            obj.chInitialComputationHostComputerName = chInitialComputationHostComputerName;
            obj.dInitialComputationWorkerNumberOrProcessId = dInitialComputationWorkerNumberOrProcessId;
            
            obj.chClusterProfileName = chClusterProfileName;
            
            obj.chRemotePoolLocalPathMatch = chRemotePoolLocalPathMatch;
            obj.c1chRemotePoolWorkerHostComputerNames = c1chRemotePoolWorkerHostComputerNames;
            obj.c1chRemotePoolLocalPathReplacePerHostForAccessByWorker = c1chRemotePoolLocalPathReplacePerHostForAccessByWorker;
            obj.c1chRemotePoolLocalPathReplacePerHostForAccessByLocal = c1chRemotePoolLocalPathReplacePerHostForAccessByLocal;
            
            obj.c1chDataPaths = c1chDataPaths;
            obj.c1chDataPathLabels = c1chDataPathLabels;
            
            obj.bParentLoopManagerSetToAvoidIterationRecomputationIfResumed = bParentLoopManagerSetToAvoidIterationRecomputationIfResumed;
        end
        
        function bParentLoopManagerSetToAvoidIterationRecomputationIfResumed = GetParentLoopManagerSetToAvoidIterationRecomputationIfResumed(obj)
            bParentLoopManagerSetToAvoidIterationRecomputationIfResumed = obj.bParentLoopManagerSetToAvoidIterationRecomputationIfResumed;
        end
        
        function dIterationNumber = GetIterationNumber(obj)
            dIterationNumber = obj.dIterationNumber;
        end
        
        function chInitialComputationHostComputerName = GetInitialComputationHostComputerName(obj)
            chInitialComputationHostComputerName = obj.chInitialComputationHostComputerName;
        end
        
        function dInitialComputationWorkerNumberOrProcessId = GetInitialComputationWorkerNumberOrProcessId(obj)
            dInitialComputationWorkerNumberOrProcessId = obj.dInitialComputationWorkerNumberOrProcessId;
        end
        
        function chResultsDirectory = GetResultsDirectoryRootPath(obj)
            chResultsDirectory = fullfile(obj.chExperimentResultsDirectoryRootPath, obj.chIterationDirectoryName);
        end
        
        function oCurrentSection = GetCurrentSection(obj)
            oCurrentSection = obj.oCurrentSection;
        end
        
        function oCurrentSection = GetCurrentSectionForExperimentLoopIterationManager(obj)
            oCurrentSection = obj.oCurrentSection;
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
            c1chDataPathLabels = obj.c1chDataPathLabels;
            c1chDataPaths = obj.c1chDataPaths;
        end
        
        function AddToReport(obj, c1xValues)
            obj.bValuesAddedToReport = true;
            
            obj.oCurrentSection.AddToReport(c1xValues);
        end
        
        function SaveCurrentSectionToDiskIfRequired(obj, oLoopManager)   
            
            if obj.oCurrentSection.WasUsedDuringParforIteration(oLoopManager) || isfolder(fullfile(obj.chExperimentResultsDirectoryRootPath, obj.chIterationDirectoryName))
                obj.CreateIterationDirectoryIfRequired();
                
                FileIOUtils.SaveMatFile(...
                    fullfile(obj.chExperimentResultsDirectoryRootPath, obj.chIterationDirectoryName, oLoopManager.GetCurrentSectionFileName()),...
                    LoopIterationExperimentPortion.chCurrentSectionVarName, obj.oCurrentSection);
            end
        end
    end   
    
    
    methods (Access = public, Static = true)
        
        function oCurrentSection = LoadIterationCurrentSection(chIterationResultsDirectoryPath, chCurrentSectionFileName)
            chFilePath = fullfile(chIterationResultsDirectoryPath, chCurrentSectionFileName);
            
            if isfile(chFilePath)
                oCurrentSection = FileIOUtils.LoadMatFile(chFilePath, LoopIterationExperimentPortion.chCurrentSectionVarName);
            else
                oCurrentSection = ExperimentSubSection.empty;
            end
        end
        
        function ResetGlobalVar()
            global oLoopIterationExperimentPortion;
            oLoopIterationExperimentPortion = [];
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % none
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?Experiment, ?ExperimentLoopIterationManager})
        
        function [bAutoAddEntriesIntoExperimentReport, bAutoSaveObjects, bAutoSaveSummaryFiles] = GetJournalingSettings_protected(obj)
            bAutoAddEntriesIntoExperimentReport = obj.bAutoAddEntriesIntoExperimentReport;
            bAutoSaveObjects = obj.bAutoSaveObjects;
            bAutoSaveSummaryFiles = obj.bAutoSaveSummaryFiles;
        end
    end
    
    
    methods (Access = private, Static = false)
                
        function CreateIterationDirectoryIfRequired(obj)
            % check if results directory has been made or not
            chDirectoryPath = fullfile(obj.chExperimentResultsDirectoryRootPath, obj.chIterationDirectoryName);
            
            if 0 == exist(chDirectoryPath, 'dir')
                mkdir(chDirectoryPath);                
            end
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

