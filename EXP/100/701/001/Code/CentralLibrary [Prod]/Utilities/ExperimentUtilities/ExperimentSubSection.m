classdef ExperimentSubSection < matlab.mixin.Copyable
    %ExperimentSubSection
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Jan 13, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
        
    properties (SetAccess = immutable, GetAccess = public)        
        chSubSectionName
        
        dParentSubSectionNumber
        dParentMaxNumberOfSubSections
        
        chResultsDirectoryName             
        dMaxNumberOfSubSections = 9999
    end
    
    
    properties (SetAccess = private, GetAccess = public)                
        bIsUsingSubSection = false
        
        bIsWithinParfor = false
        
        dCurrentSectionResultsFileNumber = 0
        dCurrentSubSectionNumber = 0
        
        c1c1oJournalEntries = {{}} % cell array of cell arrays of journal entry items. Each cell array of journal entry items falls before, between, or after each sub-section
                
        voExperimentSubSections = ExperimentSubSection.empty(1,0)
    end
    
    
    properties (Constant = true, GetAccess = private)     
        dMaxSubSectionResultsDirectoryNameLength = 15
                        
        chUniqueResultFileNamePrefix = 'Result'
        dMaxNumberOfUniqueResultsFileNames = 9999
    end
    
    
    properties (SetAccess = immutable, GetAccess = private)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function obj = ExperimentSubSection(chSubSectionName, dParentSubSectionNumber, dParentMaxNumberOfSubSections, NameValueArgs)
            arguments
                chSubSectionName (1,:) char                
                dParentSubSectionNumber (1,1) double
                dParentMaxNumberOfSubSections (1,1) double
                NameValueArgs.MaxNumberOfSubSections (1,1) double {mustBePositive, mustBeInteger}
            end
            
            obj.chSubSectionName = chSubSectionName;
            obj.dParentSubSectionNumber = dParentSubSectionNumber;
            obj.dParentMaxNumberOfSubSections = dParentMaxNumberOfSubSections;
            
            if isfield(NameValueArgs, 'MaxNumberOfSubSections')
                obj.dMaxNumberOfSubSections = NameValueArgs.MaxNumberOfSubSections;
            end
            
            obj.chResultsDirectoryName = obj.CreateDirectoryName(chSubSectionName); 
        end
        
        function bBool = IsUsingSubSection(obj)
            bBool = obj.bIsUsingSubSection;
        end
        
        function UpdateCurrentSectionFileNumber(dNewFileNumber)
            global oExperiment;
            
            oExperiment.oCurrentSection.SetCurrentSectionResultsFileNumber(dNewFileNumber);
        end
        
        function UpdateCurrentSubSectionNumber(dNewSubSectionNumber)
            global oExperiment;
            
            oExperiment.oCurrentSection.SetCurrentSubSectionNumber(dNewSubSectionNumber);
        end
        
        function SetIsWithinParfor(obj, bIsWithinParfor)
            arguments
                obj (1,1) ExperimentSubSection
                bIsWithinParfor (1,1) logical
            end
            
            obj.bIsWithinParfor = bIsWithinParfor;
        end
        
        function SetCurrentSectionResultsFileNumber(obj, dFileNumber)
            arguments
                obj (1,1) ExperimentSubSection
                dFileNumber (1,1) double {mustBeNonnegative, mustBeInteger}
            end
            
            obj.dCurrentSectionResultsFileNumber = dFileNumber;
        end
        
        function SetCurrentSubSectionNumber(obj, dSubSectionNumber)
            arguments
                obj (1,1) ExperimentSubSection
                dSubSectionNumber (1,1) double {mustBeNonnegative, mustBeInteger}
            end
            
            obj.dCurrentSubSectionNumber = dSubSectionNumber;
        end
                
        function AddSectionFromIteration(obj, oIterationCurrentSection, dSubSectionNumberToInsertFrom, dJournalEntryIndexToInsertFrom)
            obj.c1c1oJournalEntries{end} = [...
                obj.c1c1oJournalEntries{end};...
                oIterationCurrentSection.c1c1oJournalEntries{dSubSectionNumberToInsertFrom+1}(dJournalEntryIndexToInsertFrom+1:end)];
            
            if length(oIterationCurrentSection.c1c1oJournalEntries) > dSubSectionNumberToInsertFrom+1            
                obj.c1c1oJournalEntries = [...
                    obj.c1c1oJournalEntries;...
                    oIterationCurrentSection.c1c1oJournalEntries(dSubSectionNumberToInsertFrom+2:end)];
                obj.voExperimentSubSections = [...
                    obj.voExperimentSubSections,...
                    oIterationCurrentSection.voExperimentSubSections(dSubSectionNumberToInsertFrom+1:end)];                    
            end
        end
        
        function StartNewSubSection(obj, chNewSubSectionName, NameValueArgs)
            arguments
                obj (1,1) ExperimentSubSection
                chNewSubSectionName (1,:) char
                NameValueArgs.MaxNumberOfSubSections (1,1) {mustBePositive, mustBeInteger}
            end
            
            c1xNameValueArgs = namedargs2cell(NameValueArgs);
                
            if obj.bIsUsingSubSection                
                obj.voExperimentSubSections(end).StartNewSubSection(chNewSubSectionName,c1xNameValueArgs{:});
            else                
                oNewSubSection = ExperimentSubSection(...
                    chNewSubSectionName,...
                    obj.GetNextSubSectionNumber(),...
                    obj.dMaxNumberOfSubSections,...
                    c1xNameValueArgs{:});
                
                obj.bIsUsingSubSection = true;
                obj.voExperimentSubSections = [obj.voExperimentSubSections, oNewSubSection];
            end
        end
        
        function EndCurrentSubSection(obj, chParentDirectoryPath)
            if ~obj.bIsUsingSubSection
                error(...
                    'ExperimentSubSection:EndCurrentSubSection:NoCurrentSubSection',...
                    'No sub-section exists.');
            else                
                if obj.voExperimentSubSections(end).bIsUsingSubSection
                    obj.voExperimentSubSections(end).EndCurrentSubSection(fullfile(chParentDirectoryPath, obj.chResultsDirectoryName));
                else % the last sub-section within obj was the current sub-section
                    obj.bIsUsingSubSection = false; 
                    
                    if obj.voExperimentSubSections(end).WasUnused(fullfile(chParentDirectoryPath, obj.chResultsDirectoryName)) % the sub-section was unused, so there's no real reason to keep it's directory around, if it exists
                        chUnusedSubSectionResultsDirectoryPath = fullfile(chParentDirectoryPath, obj.chResultsDirectoryName, obj.voExperimentSubSections(end).chResultsDirectoryName);
                        
                        if isfolder(chUnusedSubSectionResultsDirectoryPath) % delete the directory of the sub-section (if it exists)
                            rmdir(chUnusedSubSectionResultsDirectoryPath, 's');
                        end
                    end
                    
                    obj.c1c1oJournalEntries = [obj.c1c1oJournalEntries; {{}}];
                end
            end
        end
        
        function AddToReport(obj, c1oReportItems)
            % change any strings to chars
            for dIndex=1:length(c1oReportItems)
                if isstring(c1oReportItems{dIndex})
                    if isscalar(c1oReportItems{dIndex})
                        c1oReportItems{dIndex} = char(c1oReportItems{dIndex});
                    else
                        error(...
                            'ExperimentSubSection:AddToReport:CannotAddVectorOfStringsToReport',...
                            'Only scalar strings are allowable to add to the report.');
                    end
                end
            end            
            
            if obj.bIsUsingSubSection
                obj.voExperimentSubSections(end).AddToReport(c1oReportItems)
            else
                obj.c1c1oJournalEntries{end} = [obj.c1c1oJournalEntries{end}; c1oReportItems];
            end
        end
        
        function chPath = GetResultsDirectoryPathWithinSubSections(obj)
            if obj.bIsUsingSubSection
                chSubSectionsPath = obj.voExperimentSubSections(end).GetResultsDirectoryPathWithinSubSections();
            else
                chSubSectionsPath = '';
            end
            
            if obj.bIsWithinParfor
                chPath = chSubSectionsPath; % the top-level section does not have a folder
            else
                chPath = fullfile(obj.chResultsDirectoryName, chSubSectionsPath);
            end
        end
        
        function chUniqueFilePath = GetUniqueResultsFileNamePathWithinSubSections(obj)            
            if obj.bIsUsingSubSection
                chUniqueFilePath = obj.voExperimentSubSections(end).GetUniqueResultsFileNamePathWithinSubSections();                
            else
                if obj.dCurrentSectionResultsFileNumber >= ExperimentSubSection.dMaxNumberOfUniqueResultsFileNames
                    error(...
                        'ExperimentSubSection:GetUniqueResultsFileNamePath:TooManyUniqueFileNames',...
                        ['Can only create a maxiumum of ', num2str(ExperimentSubSection.dMaxNumberOfUniqueResultsFileNames), ' unique filenames per sub-section.']);
                end
                
                obj.dCurrentSectionResultsFileNumber = obj.dCurrentSectionResultsFileNumber + 1;
                
                chUniqueFilePath = ExperimentSubSection.CreateUniqueFileName(obj.dCurrentSectionResultsFileNumber);
            end
            
            if ~obj.bIsWithinParfor
                chUniqueFilePath = fullfile(obj.chResultsDirectoryName, chUniqueFilePath);
            end
        end
        
        function c1hReportFigureHandles = AddJournalToReportSection(obj, oJournalSection, chResultsDirectoryRootPath, c1hReportFigureHandles, NameValueArgs)
            arguments
                obj
                oJournalSection
                chResultsDirectoryRootPath
                c1hReportFigureHandles = {}
                NameValueArgs.NoNewJournalSection = false
                NameValueArgs.SubSectionDepth = 0
            end
            
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            if NameValueArgs.NoNewJournalSection
                oSubSection = oJournalSection;
            else
                oSubSection = Section(obj.chSubSectionName);
            end
            
            c1hReportFigureHandles = ExperimentSubSection.AddItemsToReportSection(...
                oSubSection, obj.c1c1oJournalEntries{1},...
                c1hReportFigureHandles, NameValueArgs.SubSectionDepth,...
                chResultsDirectoryRootPath);
                        
            for dSubSectionIndex=1:length(obj.voExperimentSubSections)
                % add nested sub-section journal entries                
                c1hReportFigureHandles = obj.voExperimentSubSections(dSubSectionIndex).AddJournalToReportSection(...
                    oSubSection, chResultsDirectoryRootPath,...
                    c1hReportFigureHandles, 'SubSectionDepth',...
                    NameValueArgs.SubSectionDepth+1);
                
                % add entries after nested sub-sections ended
                if ~isempty(obj.c1c1oJournalEntries{1+dSubSectionIndex})
                    oSubSection.add(Paragraph()); % new line space
                    c1hReportFigureHandles = ExperimentSubSection.AddItemsToReportSection(...
                        oSubSection, obj.c1c1oJournalEntries{1+dSubSectionIndex},...
                        c1hReportFigureHandles, NameValueArgs.SubSectionDepth,...
                        chResultsDirectoryRootPath);            
                end
            end
            
            if ~NameValueArgs.NoNewJournalSection
                if isempty(oSubSection.Content)
                    oSubSection.add(ReportUtils.CreateParagraph('No journal entries created.'));
                end
                
                oJournalSection.add(oSubSection);
            end
        end
        
        function oSection = GetActiveSection(obj)
            if obj.bIsUsingSubSection
                oSection = obj.voExperimentSubSections(end).GetActiveSection();
            else
                oSection = obj;
            end
        end
        
        function SetActiveSection(obj, oSection)
            if obj.bIsUsingSubSection            
                if obj.voExperimentSubSections(end).bIsUsingSubSection
                    obj.voExperimentSubSections(end).SetActiveSection(oSection);
                else
                    obj.voExperimentSubSections(end) = oSection;
                end
            else
                error(...
                    'ExperimentSubSection:SetActiveSection:InvalidState',...
                    'Reached invalid state.');
            end
        end
        
        function PerformPostParforFileAndJournalTeardown(obj, dParentCurrentSectionResultsFileNumber, chFromPath, chToPath, dStartingFileNumber, dStartingSubSectionNumber, chFromPathIterationDirectory, chToPathResultsDirectoryRootToSubSectionPath, bFileFromRemoteWorker, chRemoteWorkerFromLocalPath, chRemoteWorkerFromWorkerPath, chExperimentSubSectionFilename, chIterationCompleteTokenFilename, bIterationFromResume)
            % rename and copy sub-section folders
            for dSubSectionIndex=1:length(obj.voExperimentSubSections)
                oSubSection = obj.voExperimentSubSections(dSubSectionIndex);
                
                chSubSectionDirectory = oSubSection.chResultsDirectoryName;
                
                dNewSectionNumber = oSubSection.dParentSubSectionNumber + dStartingSubSectionNumber;
                
                chNewSubSectionDirectory = oSubSection.CreateDirectoryName(oSubSection.chSubSectionName, 'ParentSubSectionNumberOverride', dNewSectionNumber);
                
                if bIterationFromResume % never want to do destructive actions to an experiment being resumed from
                    if isfolder(fullfile(chFromPath, chSubSectionDirectory))
                        copyfile(...
                            fullfile(chFromPath, chSubSectionDirectory),...
                            fullfile(chToPath, chNewSubSectionDirectory));
                    end
                else
                    if isfolder(fullfile(chFromPath, chSubSectionDirectory))
                        movefile(...
                            fullfile(chFromPath, chSubSectionDirectory),...
                            fullfile(chToPath, chNewSubSectionDirectory));
                    end
                end
                
                oSubSection.UpdateFigureAndLinkPathsInSubSectionJournalEntries(...
                    fullfile(chFromPathIterationDirectory, chSubSectionDirectory),...
                    fullfile(chToPath, chNewSubSectionDirectory));
            end
                        
            % move another other folders/files from top level section directory
            % - if they're from the unique filename process, their file
            %   number may need to be updated
            
            % start by looking for the unique filenames
            
            voEntries = dir(chFromPath);
            voEntries = voEntries(3:end); % reject '.' and '..'
            
            dNumEntries = length(voEntries);
            
            vsFileNames = strings(dNumEntries,1);
            vsFileExtensions = strings(dNumEntries,1);
            vbIsFile = false(dNumEntries,1);
            
            for dEntryIndex=1:dNumEntries
                oEntry = voEntries(dEntryIndex);
                chName = oEntry.name;
                
                if ~oEntry.isdir && (strcmp(chName, chExperimentSubSectionFilename) || strcmp(chName, chIterationCompleteTokenFilename))
                    % do nothing, don't want to copy/move/rename these
                    % files
                elseif oEntry.isdir
                    if bIterationFromResume
                        copyfile(...
                            fullfile(chFromPath, chName),...
                            fullfile(chToPath, chName));
                    else
                        movefile(...
                            fullfile(chFromPath, chName),...
                            fullfile(chToPath, chName));
                    end
                else
                    [chFileName, chFileExtensions] = FileIOUtils.SeparateFilePathExtension(chName);
                    
                    vsFileNames(dEntryIndex) = string(chFileName);
                    vsFileExtensions(dEntryIndex) = string(chFileExtensions);
                    vbIsFile(dEntryIndex) = true;
                end
            end
            
            vsFileNames = vsFileNames(vbIsFile);
            vsFileExtensions = vsFileExtensions(vbIsFile);
            dNumFiles = length(vsFileNames);
            
            for dUniqueFileNameNumber=dParentCurrentSectionResultsFileNumber:obj.dCurrentSectionResultsFileNumber
                sSearchFileName = string(ExperimentSubSection.CreateUniqueFileName(dUniqueFileNameNumber));
                
                dMatchIndex = find(sSearchFileName == vsFileNames,1);
                
                if ~isempty(dMatchIndex)
                    dFileNumberDelta = dUniqueFileNameNumber - dParentCurrentSectionResultsFileNumber;
                    dNewFileNumber = dFileNumberDelta + dStartingFileNumber;
                    chNewFileName = ExperimentSubSection.CreateUniqueFileName(dNewFileNumber);
                    
                    chFileFromPath = fullfile(chFromPath, char(vsFileNames(dMatchIndex) + vsFileExtensions(dMatchIndex)));
                    chFileToPath = fullfile(chToPath, [chNewFileName, char(vsFileExtensions(dMatchIndex))]);
                    
                    if bIterationFromResume
                        copyfile(chFileFromPath, chFileToPath);
                    else
                        movefile(chFileFromPath, chFileToPath);
                    end
                    
                    if bFileFromRemoteWorker
                        chFigurePathInJournalEntries = strrep(chFileFromPath, chRemoteWorkerFromLocalPath, chRemoteWorkerFromWorkerPath);
                    else
                        chFigurePathInJournalEntries = chFileFromPath;
                    end
                    
                    obj.UpdateFigureAndLinkPathsInSectionJournalEntries(chFigurePathInJournalEntries, chFileToPath);
                end
            end
            
            % move over any remaining files
            voEntries = dir(chFromPath);
            
            for dEntryIndex=3:length(voEntries)
                chName = voEntries(dEntryIndex).name;
                
                if ~oEntry.isdir && (strcmp(chName, chExperimentSubSectionFilename) || strcmp(chName, chIterationCompleteTokenFilename))
                    % do nothing, don't want to copy/move/rename these
                    % files
                else
                    if bIterationFromResume
                        copyfile(...
                            fullfile(chFromPath, chName),...
                            fullfile(chToPath, chName));
                    else
                        movefile(...
                            fullfile(chFromPath, chName),...
                            fullfile(chToPath, chName));
                    end
                end
            end            
        end
        
        function bBool = WasUsedDuringParforIteration(obj, oLoopManager)
            oStartingSection = oLoopManager.GetCurrentSection();
            
            bBool = ...
                obj.dCurrentSectionResultsFileNumber ~= oStartingSection.dCurrentSectionResultsFileNumber ||...
                obj.dCurrentSubSectionNumber ~= oStartingSection.dCurrentSubSectionNumber ||...
                ~obj.IsJournalEmpty();
        end
        
        function dCurrentSectionResultsFileNumber = GetCurrentSectionResultsFileNumber(obj)
            dCurrentSectionResultsFileNumber = obj.dCurrentSectionResultsFileNumber;
        end
        
        function dCurrentSubSectionNumber = GetCurrentSubSectionNumber(obj)
            dCurrentSubSectionNumber = obj.dCurrentSubSectionNumber;
        end
        
        function dJournalIndex = GetCurrentJournalEntryNumber(obj)
            dJournalIndex = length(obj.c1c1oJournalEntries{end});
        end
        
        function bBool = IsJournalEmpty(obj)
            bBool = true;
            
            for dIndex=1:length(obj.c1c1oJournalEntries)
                if ~isempty(obj.c1c1oJournalEntries{dIndex})
                    bBool = false;
                    break;
                end
            end
        end
        
        function chPath = GetPathToActiveSectionResultsDirectory(obj)
            if obj.bIsUsingSubSection
                chPath = fullfile(obj.chResultsDirectoryName, obj.voExperimentSubSections(end).GetPathToActiveSectionResultsDirectory());
            else
                chPath = obj.chResultsDirectoryName;
            end
        end
    end   
    
    
    methods (Access = public, Static = true)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            
            for dSubSectionIndex=1:length(obj.voExperimentSubSections)
                cpObj.voExperimentSubSections(dSubSectionIndex) = copy(cpObj.voExperimentSubSections(dSubSectionIndex));
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    
    methods (Access = private, Static = false)
        
        function UpdateFigureAndLinkPathsInSubSectionJournalEntries(obj, chCurrentToSubSectionPath, chNewToSubSectionPath)
            for dJournalSectionIndex=1:length(obj.c1c1oJournalEntries)
                c1oJournalEntries = obj.c1c1oJournalEntries{dJournalSectionIndex};
                
                for dJournalEntryIndex=1:length(c1oJournalEntries)
                    xEntry = c1oJournalEntries{dJournalEntryIndex};
                    
                    if ischar(xEntry)
                        vdIndices = strfind(xEntry, chCurrentToSubSectionPath);
                        
                        if isempty(vdIndices)
                            error(...
                                'ExperimentSubSection:UpdateFigureAndLinkPathsInSubSectionJournalEntries:InvalidFigurePath',...
                                'The expected figure path was not found.');
                        end
                        
                        xNewEntry = [chNewToSubSectionPath, xEntry(vdIndices(1)+length(chCurrentToSubSectionPath) : end)];
                        
                        obj.c1c1oJournalEntries{dJournalSectionIndex}{dJournalEntryIndex} = xNewEntry;
                    elseif isa(xEntry, 'ExperimentReportFileLink')
                        xNewEntry = xEntry.UpdatePath(chCurrentToSubSectionPath, chNewToSubSectionPath);
                        
                        obj.c1c1oJournalEntries{dJournalSectionIndex}{dJournalEntryIndex} = xNewEntry;
                    end
                end
            end
            
            % recurse into sub-sections
            for dSubSectionIndex=1:length(obj.voExperimentSubSections)
                obj.voExperimentSubSections.UpdateFigureAndLinkPathsInSubSectionJournalEntries(chCurrentToSubSectionPath, chNewToSubSectionPath);
            end
        end
        
        function UpdateFigureAndLinkPathsInSectionJournalEntries(obj, chFileFromPath, chFileToPath)
            for dJournalSectionIndex=1:length(obj.c1c1oJournalEntries)
                c1oJournalEntries = obj.c1c1oJournalEntries{dJournalSectionIndex};
                
                for dJournalEntryIndex=1:length(c1oJournalEntries)
                    xEntry = c1oJournalEntries{dJournalEntryIndex};
                    
                    if ischar(xEntry)
                        vdIndices = strfind(xEntry, chFileFromPath);
                        
                        if ~isempty(vdIndices) && vdIndices(1) == 1                            
                            xNewEntry = [chFileToPath, xEntry(length(chFileFromPath)+1 : end)];
                            
                            obj.c1c1oJournalEntries{dJournalSectionIndex}{dJournalEntryIndex} = xNewEntry;
                        end   
                    elseif isa(xEntry, 'ExperimentReportFileLink')
                        xNewEntry = xEntry.UpdatePath(chFileFromPath, chFileToPath);
                        
                        obj.c1c1oJournalEntries{dJournalSectionIndex}{dJournalEntryIndex} = xNewEntry;                        
                    end
                end
            end
        end
        
        function dSubSectionNumber = GetNextSubSectionNumber(obj)
            if obj.dCurrentSubSectionNumber == obj.dMaxNumberOfSubSections
                error(...
                    'ExperimentSubSection:StartNewSubSection:MaxNumberOfSubSectionsReached',...
                    ['The maximum number of sub-sections (', num2str(obj.dMaxNumberOfSubSections), ') has been reached. Use Experiment.StartNewSubSection(''Sub section name'', ''MaxNumberOfSubSections'', X) to customize this limit.']);
            end
            
            obj.dCurrentSubSectionNumber = obj.dCurrentSubSectionNumber + 1;
            dSubSectionNumber = obj.dCurrentSubSectionNumber;
        end
        
        function bBool = WasUnused(obj, chParentDirectoryPath)
            chResultsDirectoryPath = fullfile(chParentDirectoryPath, obj.chResultsDirectoryName);
            
            bBool = ...
                isempty(obj.voExperimentSubSections) &&...
                isscalar(obj.c1c1oJournalEntries) &&...
                isempty(obj.c1c1oJournalEntries{1}) &&...
                (...
                0 == exist(chResultsDirectoryPath, 'dir') || ... % check that no files were ever saved to the results directory (e.g. results directory doesn't exist or it's empty)
                2 == length(chResultsDirectoryPath));
        end
        
        function chDirectoryName = CreateDirectoryName(obj, chSubSectionName, NameValueArgs)
            arguments
                obj
                chSubSectionName
                NameValueArgs.ParentSubSectionNumberOverride
            end
            
            if isfield(NameValueArgs, 'ParentSubSectionNumberOverride')
                dParentSubSectionNumber = NameValueArgs.ParentSubSectionNumberOverride;
            else
                dParentSubSectionNumber = obj.dParentSubSectionNumber;
            end
            
            dMaxNumDigits = length(num2str(obj.dParentMaxNumberOfSubSections));
            
            chSubSectionNumber = num2str(dParentSubSectionNumber);
            chSubSectionNumber = [repmat('0',1,dMaxNumDigits-length(chSubSectionNumber)), chSubSectionNumber];
            
            if isempty(chSubSectionName)
                chDirectoryName = chSubSectionNumber;
            else            
                chDirectoryName = [chSubSectionNumber, ' ', chSubSectionName];
            end
        end
    end
    
    
    methods (Access = private, Static = true)
       
        function chFileName = CreateUniqueFileName(dFileNumber)
            
            dNumDigits = length(num2str(ExperimentSubSection.dMaxNumberOfUniqueResultsFileNames));
            
            chFileNumber = num2str(dFileNumber);
            chFileNumber = [repmat('0',1,dNumDigits-length(chFileNumber)), chFileNumber]; % pad with zeros to have 4 digits (e.g. 0076)
            
            chFileName = [ExperimentSubSection.chUniqueResultFileNamePrefix, ' ', chFileNumber];
        end
        
        function c1hReportFigureHandles = AddItemsToReportSection(oJournalSection, c1xReportGeneratorItems, c1hReportFigureHandles, dSubSectionDepth, chResultsDirectoryRootPath)
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            chMargin = [num2str(dSubSectionDepth*10), 'pt'];
            
            dResultsRootPathLength = length(chResultsDirectoryRootPath);
            
            for dItemIndex=1:length(c1xReportGeneratorItems)
                xItem = c1xReportGeneratorItems{dItemIndex};
                
                if (isrow(xItem) && ischar(xItem)) ||... % string to a figure path
                        (isscalar(xItem) && isstring(xItem))
                    
                    chFigSavePath = char(xItem);
                    
                    hFig = openfig(chFigSavePath, 'invisible');
                    
                    oFig = mlreportgen.report.Figure(hFig);
                    
                    oJournalSection.add(oFig);
                    
                    if length(chFigSavePath) >= dResultsRootPathLength && strcmp(chFigSavePath(1:dResultsRootPathLength), chResultsDirectoryRootPath)
                        %the figure is saved with the results directory, so
                        %just give relative path
                        chFigSavePath = chFigSavePath(dResultsRootPathLength+2:end);
                    end
                                        
                    oLabel = Text(chFigSavePath);
                    oLabel.Italic = true;
                    
                    oParagraph = Paragraph;
                    oParagraph.append(oLabel);
                    oParagraph.OuterLeftMargin = chMargin;
                    
                    oJournalSection.add(oParagraph);
                    c1hReportFigureHandles = [c1hReportFigureHandles; {hFig}];
                elseif isscalar(xItem) && contains(class(xItem), 'mlreportgen.dom.')
                    if isa(xItem, 'mlreportgen.dom.Paragraph')
                        xItem.OuterLeftMargin = chMargin;
                    end
                    
                    oJournalSection.add(xItem);
                elseif isscalar(xItem) && isa(xItem, 'ExperimentReportFileLink')
                    xItem.AddToReportSection(oJournalSection, chMargin, chResultsDirectoryRootPath);
                else
                    error(...
                        'ExperimentSubSection:AddItemsToReportSection:InvalidType',...
                        'Only paths to .fig files or scalar mlreportgen.dom objects may be added to the report.');
                end
            end
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

