classdef DatabaseGroup
    %DatabaseGroup
    %
    % Provides a sub-selection of patients and lesions for use within a
    % given a study. These can be provided for multiple times points
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
        
        vsTimepointLabels (1,:) string
        
        vdPatientIds (:,1) double {mustBeInteger, mustBePositive}
        vdLesionIds (:,1) double {mustBeInteger, mustBePositive}
        
        m2dStudyNumbersForLesionsPerTimepoint (:,:) double {mustBeInteger, mustBePositive} % lesions in rows, timepoints per column
        m2dRoiNumbersForLesionsPerTimepoint (:,:) double {} % lesions in rows, timepoints per column, NaN values ARE accepted (refer to the lesion no longer being visible in scan)
        
        m2sPathsToStudyDirectoryForLesionsPerTimepoint (:,:) string % lesions in rows, timepoints per column
        m2sImageVolumeFilenamesForLesionsPerTimepoint (:,:) string % lesions in rows, timepoints per column
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oDatabaseGroup'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = DatabaseGroup(sIdTag, vdPatientIds, vdLesionIds, sTimepointLabel, vdStudyNumbersForLesionsPerTimepoint, vdRoiNumberForLesionsPerTimepoint, vsPathToStudyDirectoryForLesionsPerTimepoint, vsImageVolumeFilenameForLesionsPerTimepoint)
            arguments
                sIdTag (1,1) string
                vdPatientIds (:,1) double {mustBeInteger, mustBePositive}
                vdLesionIds (:,1) double {mustBeInteger, mustBePositive}
            end
            arguments (Repeating)
                sTimepointLabel (1,1) string
                vdStudyNumbersForLesionsPerTimepoint (:,1) double {mustBeInteger, mustBePositive}
                vdRoiNumberForLesionsPerTimepoint (:,1) double
                vsPathToStudyDirectoryForLesionsPerTimepoint (:,1) string
                vsImageVolumeFilenameForLesionsPerTimepoint (:,1) string
            end
            
            obj.sIdTag = sIdTag;
            
            obj.vsTimepointLabels = [sTimepointLabel{:}];
            
            obj.vdPatientIds = vdPatientIds;
            obj.vdLesionIds = vdLesionIds;
            
            obj.m2dStudyNumbersForLesionsPerTimepoint = [vdStudyNumbersForLesionsPerTimepoint{:}];
            obj.m2dRoiNumbersForLesionsPerTimepoint = [vdRoiNumberForLesionsPerTimepoint{:}];
            
            obj.m2sPathsToStudyDirectoryForLesionsPerTimepoint = [vsPathToStudyDirectoryForLesionsPerTimepoint{:}];
            obj.m2sImageVolumeFilenamesForLesionsPerTimepoint = [vsImageVolumeFilenameForLesionsPerTimepoint{:}];
        end
        
        function dNumSamples = GetNumberOfSamples(obj)
            dNumSamples = length(obj.vdPatientIds);
        end
        
        function sIdTag = GetIdTag(obj)
            sIdTag = obj.sIdTag;
        end
        
        function [vdPatientIds, vdLesionIds] = GetPatientAndLesionsIds(obj)
            vdPatientIds = obj.vdPatientIds;
            vdLesionIds = obj.vdLesionIds;
        end
        
        function vdUniquePatientIds = GetUniquePatientIds(obj)
            vdUniquePatientIds = unique(obj.vdPatientIds);
        end
        
        function [vsStudyDirectoryPaths, vsImageVolumeFilenames, vdStudyNumbers, vdRoiNumbers] = GetImageVolumeAndRegionsOfInterestDataForTimepoint(obj, sTimepointLabel)
            arguments
                obj (1,1) DatabaseGroup
                sTimepointLabel (1,1) string {MustBeValidTimepointLabel(obj, sTimepointLabel)}
            end
            
            dColIndex = obj.GetColumnIndexForTimepointLabel(sTimepointLabel);
            
            vsStudyDirectoryPaths = fullfile(ExperimentManager.GetImageDatabaseRootPath(), obj.m2sPathsToStudyDirectoryForLesionsPerTimepoint(:,dColIndex));
            vsImageVolumeFilenames = obj.m2sImageVolumeFilenamesForLesionsPerTimepoint(:,dColIndex);
            
            vdStudyNumbers = obj.m2dStudyNumbersForLesionsPerTimepoint(:,dColIndex);
            vdRoiNumbers = obj.m2dRoiNumbersForLesionsPerTimepoint(:,dColIndex);
        end
        
        function dSampleIndex = GetSampleIndexForPatientAndLesionId(obj, dPatientId, dLesionId)
            arguments
                obj (1,1) DatabaseGroup
                dPatientId (1,1) double {MustBeValidPatientId(obj, dPatientId)}
                dLesionId (1,1) double {mustBeInteger}
            end
            
            vdSampleIndices = find(obj.vdPatientIds == dPatientId & obj.vdLesionIds == dLesionId);
            
            if ~isscalar(vdSampleIndices)
                error(...
                    'DatabaseGroup:GetSampleIndexForPatientAndLesionId:NoUniqueMatchFound',...
                    'No unique match found.');
            end
            
            dSampleIndex = vdSampleIndices(1);
        end
        
        function vdRoiNumbers = GetRegionOfInterestNumbersForPatientIdAndTimepoint(obj, dPatientId, sTimepointLabel)
            arguments
                obj (1,1) DatabaseGroup
                dPatientId (1,1) double {MustBeValidPatientId(obj, dPatientId)}
                sTimepointLabel (1,1) string {MustBeValidTimepointLabel(obj, sTimepointLabel)}
            end
            
            dColIndex = obj.GetColumnIndexForTimepointLabel(sTimepointLabel);
            
            vdRoiNumbers = obj.m2dRoiNumbersForLesionsPerTimepoint(obj.vdPatientIds==dPatientId, dColIndex);
        end
        
        function Save(obj, chFilePath)
            arguments
                obj (1,1) DatabaseGroup
                chFilePath (1,:) char
            end
            
            FileIOUtils.SaveMatFile(chFilePath, DatabaseGroup.chMatFileVarName, obj);
        end
        
        function oImageVolume = LoadImageVolumeForPatientId(obj, dPatientId, sTimepointLabel, oImageVolumePreProcessing)
            arguments
                obj (1,1) DatabaseGroup
                dPatientId (1,1) double {MustBeValidPatientId(obj, dPatientId)}
                sTimepointLabel (1,1) string {MustBeValidTimepointLabel(obj, sTimepointLabel)}
                oImageVolumePreProcessing (1,1) ImageVolumePreProcessing
            end
                        
            [sStudyDirectoryPath, sImageVolumeFilename] = obj.GetStudyDirectoryPathAndFilenameForPatientIdAndTimepointLabel(dPatientId, sTimepointLabel);
            
            oImageVolume = oImageVolumePreProcessing.LoadImageVolume(sStudyDirectoryPath, sImageVolumeFilename);
        end
        
        function sPath = GetImageVolumePathForPatientId(obj, dPatientId, sTimepointLabel, oImageVolumePreProcessing)
            arguments
                obj (1,1) DatabaseGroup
                dPatientId (1,1) double {MustBeValidPatientId(obj, dPatientId)}
                sTimepointLabel (1,1) string {MustBeValidTimepointLabel(obj, sTimepointLabel)}
                oImageVolumePreProcessing (1,1) ImageVolumePreProcessing
            end
            
            [sStudyDirectoryPath, sImageVolumeFilename] = obj.GetStudyDirectoryPathAndFilenameForPatientIdAndTimepointLabel(dPatientId, sTimepointLabel);
            
            sPath = oImageVolumePreProcessing.GetImageVolumePath(sStudyDirectoryPath, sImageVolumeFilename);
        end
        
        function [sStudyDirectoryPath, sFilename] = GetStudyDirectoryPathAndFilenameForPatientIdAndTimepointLabel(obj, dPatientId, sTimepointLabel)
            arguments
                obj (1,1) DatabaseGroup
                dPatientId (1,1) double {MustBeValidPatientId(obj, dPatientId)}
                sTimepointLabel (1,1) string {MustBeValidTimepointLabel(obj, sTimepointLabel)}
            end
            
            [vsStudyDirectoryPaths, vsImageVolumeFilenames] = obj.GetImageVolumeAndRegionsOfInterestDataForTimepoint(sTimepointLabel);
            
            vdRowsForPatient = find(obj.vdPatientIds == dPatientId);            
            dReferenceRow = vdRowsForPatient(1);
            
            sStudyDirectoryPath = vsStudyDirectoryPaths(dReferenceRow);
            sFilename = vsImageVolumeFilenames(dReferenceRow);
        end
        
        function oImageVolume = LoadImageVolumeAndRegionsOfInterestForPatientId(obj, dPatientId, sTimepointLabel, oImageVolumePreProcessing, oRegionOfInterestPreProcessing)
            arguments
                obj (1,1) DatabaseGroup
                dPatientId (1,1) double {MustBeValidPatientId(obj, dPatientId)}
                sTimepointLabel (1,1) string {MustBeValidTimepointLabel(obj, sTimepointLabel)}
                oImageVolumePreProcessing (1,1) ImageVolumePreProcessing
                oRegionOfInterestPreProcessing (1,1) RegionOfInterestPreProcessing
            end
            
            [vsStudyDirectoryPaths, vsImageVolumeFilenames] = obj.GetImageVolumeAndRegionsOfInterestDataForTimepoint(sTimepointLabel);
            
            vdRowsForPatient = find(obj.vdPatientIds == dPatientId);            
            dReferenceRow = vdRowsForPatient(1);
            
            sStudyDirectoryPath = vsStudyDirectoryPaths(dReferenceRow);
            sImageVolumeFilename = vsImageVolumeFilenames(dReferenceRow);
            
            oImageVolume = oImageVolumePreProcessing.LoadImageVolume(sStudyDirectoryPath, sImageVolumeFilename);
            oRois = oRegionOfInterestPreProcessing.LoadRegionsOfInterest(sStudyDirectoryPath, sImageVolumeFilename);
            
            oImageVolume.SetRegionsOfInterest(oRois);
        end
        
        function oRois = LoadRegionsOfInterestForPatientId(obj, dPatientId, sTimepointLabel, oRegionOfInterestPreProcessing)
            arguments
                obj (1,1) DatabaseGroup
                dPatientId (1,1) double {MustBeValidPatientId(obj, dPatientId)}
                sTimepointLabel (1,1) string {MustBeValidTimepointLabel(obj, sTimepointLabel)}
                oRegionOfInterestPreProcessing (1,1) RegionOfInterestPreProcessing
            end
            
            [vsStudyDirectoryPaths, vsImageVolumeFilenames] = obj.GetImageVolumeAndRegionsOfInterestDataForTimepoint(sTimepointLabel);
            
            vdRowsForPatient = find(obj.vdPatientIds == dPatientId);            
            dReferenceRow = vdRowsForPatient(1);
            
            sStudyDirectoryPath = vsStudyDirectoryPaths(dReferenceRow);
            sImageVolumeFilename = vsImageVolumeFilenames(dReferenceRow);
            
            oRois = oRegionOfInterestPreProcessing.LoadRegionsOfInterest(sStudyDirectoryPath, sImageVolumeFilename);
        end
        
        function SaveRegionsOfInterestForPatientId(obj, oRois, dPatientId, sTimepointLabel, oRegionOfInterestPreProcessing, bForceApplyAllTransforms, varargin)
            arguments
                obj (1,1) DatabaseGroup
                oRois (1,1) RegionsOfInterest
                dPatientId (1,1) double {MustBeValidPatientId(obj, dPatientId)}
                sTimepointLabel (1,1) string {MustBeValidTimepointLabel(obj, sTimepointLabel)}
                oRegionOfInterestPreProcessing (1,1) RegionOfInterestPreProcessing                
                bForceApplyAllTransforms (1,1) logical = true
            end
            arguments (Repeating)
                varargin
            end
            
            [vsStudyDirectoryPaths, vsImageVolumeFilenames] = obj.GetImageVolumeAndRegionsOfInterestDataForTimepoint(sTimepointLabel);
            
            vdRowsForPatient = find(obj.vdPatientIds == dPatientId);            
            dReferenceRow = vdRowsForPatient(1);
            
            sStudyDirectoryPath = vsStudyDirectoryPaths(dReferenceRow);
            sImageVolumeFilename = vsImageVolumeFilenames(dReferenceRow);
            
            bAppend = false; % we're saving into a new file
            
            oRegionOfInterestPreProcessing.SaveRegionsOfInterest(oRois, sStudyDirectoryPath, sImageVolumeFilename, bForceApplyAllTransforms, bAppend, varargin{:});
        end
        
        function SaveImageVolumeForPatientId(obj, oImageVolume, dPatientId, sTimepointLabel, oImageVolumePreProcessing, bForceApplyTransforms, varargin)
            arguments
                obj (1,1) DatabaseGroup
                oImageVolume (1,1) ImageVolume
                dPatientId (1,1) double {MustBeValidPatientId(obj, dPatientId)}
                sTimepointLabel (1,1) string {MustBeValidTimepointLabel(obj, sTimepointLabel)}
                oImageVolumePreProcessing (1,1) ImageVolumePreProcessing
                bForceApplyTransforms (1,1) logical = true
            end
            arguments (Repeating)
                varargin
            end
            
            [vsStudyDirectoryPaths, vsImageVolumeFilenames] = obj.GetImageVolumeAndRegionsOfInterestDataForTimepoint(sTimepointLabel);
            
            vdRowsForPatient = find(obj.vdPatientIds == dPatientId);            
            dReferenceRow = vdRowsForPatient(1);
            
            sStudyDirectoryPath = vsStudyDirectoryPaths(dReferenceRow);
            sImageVolumeFilename = vsImageVolumeFilenames(dReferenceRow);
            
            oImageVolume = copy(oImageVolume);
            oImageVolume.RemoveRegionsOfInterest();
            
            oImageVolumePreProcessing.SaveImageVolumeWithNoContours(oImageVolume, sStudyDirectoryPath, sImageVolumeFilename, bForceApplyTransforms, varargin{:});
        end
        
        function vdLesionIds = GetLesionIdsForPatientId(obj, dPatientId)
            arguments
                obj (1,1) DatabaseGroup
                dPatientId (1,1) double {MustBeValidPatientId(obj, dPatientId)}
            end
            
            vdRowIndices = obj.GetRowIndicesForPatientId(dPatientId);
            
            vdLesionIds = obj.vdLesionIds(vdRowIndices);
        end
        
        function voImageVolumeHandlers = GetImageVolumeHandlers(obj, sTimepointLabel, oIMGPP, oROIPP, sFeatureSource, NameValueArgs)
            arguments
                obj (1,1) DatabaseGroup
                sTimepointLabel (1,1) string {MustBeValidTimepointLabel(obj, sTimepointLabel)}
                oIMGPP (1,1) ImageVolumePreProcessing
                oROIPP (1,1) RegionOfInterestPreProcessing
                sFeatureSource (1,1) string
                NameValueArgs.SetRepresentativeFieldsOfView (1,1) logical = true
            end
            
            dTimepointIndex = obj.GetColumnIndexForTimepointLabel(sTimepointLabel);
            
            vdUniquePatientIds = obj.GetUniquePatientIds();
            dNumPatients = length(vdUniquePatientIds);            
            
            c1oImageVolumeHandlers = cell(1,dNumPatients);
            
            for dPatientIndex=1:dNumPatients
                % Patient ID (Group IDs)
                dPatientId = vdUniquePatientIds(dPatientIndex);
                
                vdRoiNumbers = obj.GetRegionOfInterestNumbersForPatientIdAndTimepoint(dPatientId, sTimepointLabel);
                vdLesionIds = obj.GetLesionIdsForPatientId(dPatientId);
                
                dNumLesionsForPatient = length(vdLesionIds);
                                
                % User Defined Sample Strings
                vsUserDefinedSampleStrings = strings(dNumLesionsForPatient,1);
                
                for dLesionIndex=1:dNumLesionsForPatient
                    vsUserDefinedSampleStrings(dLesionIndex) = ...
                        "Pt. " + num2str(dPatientId) + " Lsn. " + num2str(vdLesionIds(dLesionIndex));
                end
                
                % Image Volume & ROIs Load                
                oImageVolume = obj.LoadImageVolumeForPatientId(dPatientId, sTimepointLabel, oIMGPP);
                
                oROIs = obj.LoadRegionsOfInterestForPatientId(dPatientId, sTimepointLabel, oROIPP);
                oImageVolume.SetRegionsOfInterest(oROIs);
                
                % make the handler!
                
                c1oImageVolumeHandlers{dPatientIndex} = FeatureExtractionImageVolumeHandler(...
                    oImageVolume,...
                    sFeatureSource,...
                    'GroupIds', uint8(dPatientId),...
                    'SubGroupIds', uint8(vdLesionIds),...
                    'UserDefinedSampleStrings', vsUserDefinedSampleStrings,...
                    'SampleOrder', vdRoiNumbers,...
                    'ImageInterpretation', '3D',...
                    'SetRepresentativeFieldsOfView', NameValueArgs.SetRepresentativeFieldsOfView);
                
            end
            
            voImageVolumeHandlers = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oImageVolumeHandlers);
        end
        
        
        function oIVH = CreateImageVolumeHandlers(obj, sTimepointLabel, sIvhTagId, sFeatureSource, oIMGPP, oROIPP, varargin)
            arguments
                obj (1,1) DatabaseGroup
                sTimepointLabel (1,1) string
                sIvhTagId (1,1) string
                sFeatureSource (1,1) string
                oIMGPP (1,1) ImageVolumePreProcessing
                oROIPP (1,1) RegionOfInterestPreProcessing
            end
            arguments (Repeating)
                varargin
            end
            
            vdLabelMatches = find(obj.vsTimepointLabels == sTimepointLabel);
            
            if ~isscalar(vdLabelMatches)
                error(...
                    'DatabaseGroups:CreateImageVolumeHandlers:NoTimepointMatchFound',...
                    'No match for timepoint label found.');
            end
            
            dTimepointIndex = vdLabelMatches(1);
            
            vdPatientIds = obj.vdPatientIds;
            vdUniquePatientIds = unique(vdPatientIds);
            dNumPatients = length(vdUniquePatientIds);
            
            vdLesionIds = obj.vdLesionIds;
            
            sImageDatabaseRootPath = ExperimentManager.GetImageDatabaseRootPath();
            dImageDatabaseRootPathLength = length(char(sImageDatabaseRootPath));
            
            vsStudyPaths = fullfile(sImageDatabaseRootPath, obj.m2sPathsToStudyDirectoryForLesionsPerTimepoint(:,dTimepointIndex));
            vsFileNames = obj.m2sImageVolumeFilenamesForLesionsPerTimepoint(:,dTimepointIndex);
            
            vdAllRoiNumbers = obj.m2dRoiNumbersForLesionsPerTimepoint(:,dTimepointIndex);
            
            sImagePreProcessFolder = oIMGPP.GetImageDatabaseFolder();
            
            chWritePath = char(ExperimentManager.GetImageVolumeHandlersRootPath());
            mkdir(chWritePath, sIvhTagId);
            
            vsHandlerFileNames = strings(dNumPatients,1);
            vsImageVolumeMatFileFromRootPaths = strings(dNumPatients,1);
            vsRegionsOfInterestMatFileFromRootPaths = strings(dNumPatients,1);
            
            for dPatientIndex=1:dNumPatients
                % Patient ID (Group IDs)
                dPatientId = vdUniquePatientIds(dPatientIndex);
                disp(dPatientId);
                
                % Rows in manifest for patient's lesions
                vdPatientRowIndices = find(vdPatientIds == dPatientId);
                dNumLesionsForPatient = length(vdPatientRowIndices);
                
                % Lesion numbers (Sub-group IDs)
                vdPatientLesionNumbers = vdLesionIds(vdPatientRowIndices);
                
                % ROI Numbers (Extraction Order)
                vdRoiNumbers = vdAllRoiNumbers(vdPatientRowIndices);
                                
                % User Defined Sample Strings
                vsUserDefinedSampleStrings = strings(dNumLesionsForPatient,1);
                
                for dLesionIndex=1:dNumLesionsForPatient
                    vsUserDefinedSampleStrings(dLesionIndex) = ...
                        "Pt. " + num2str(dPatientId) + " Lsn. " + num2str(vdPatientLesionNumbers(dLesionIndex));
                end
                
                % Image Volume & ROIs Load                
                oImageVolume = obj.LoadImageVolumeForPatientId(dPatientId, sTimepointLabel, oIMGPP);
                
                oROIs = obj.LoadRegionsOfInterestForPatientId(dPatientId, sTimepointLabel, oROIPP);
                oImageVolume.SetRegionsOfInterest(oROIs);
                
                % get from root paths for IV and ROIs
                chImageVolumeMatFilePath = oImageVolume.GetMatFilePath();
                
                if contains(chImageVolumeMatFilePath, sImageDatabaseRootPath)
                    vsImageVolumeMatFileFromRootPaths(dPatientIndex) = string(chImageVolumeMatFilePath(dImageDatabaseRootPathLength+2 : end));
                else
                    error(...
                        'DatabaseGroup:CreateImageVolumeHandlers:InvalidImageVolumePath',...
                        'The image volume mat file path did not include the Experiment''s ImageDatabaseRootPath.');
                end
                
                
                chRoisMatFilePath = oROIs.GetMatFilePath();
                
                if contains(chRoisMatFilePath, sImageDatabaseRootPath)
                    vsRegionsOfInterestMatFileFromRootPaths(dPatientIndex) = string(chRoisMatFilePath(dImageDatabaseRootPathLength+2 : end));
                else
                    error(...
                        'DatabaseGroup:CreateImageVolumeHandlers:InvalidRoisPath',...
                        'The ROIs mat file path did not include the Experiment''s ImageDatabaseRootPath.');
                end
                
                
                % make the handler!
                
                oImageVolumeHandler = FeatureExtractionImageVolumeHandler(...
                    oImageVolume,...
                    sFeatureSource,...
                    'GroupIds', uint8(dPatientId),...
                    'SubGroupIds', uint8(vdPatientLesionNumbers),...
                    'UserDefinedSampleStrings', vsUserDefinedSampleStrings,...
                    'SampleOrder', vdRoiNumbers,...
                    'ImageInterpretation', '3D');
                
                % save to disk
                chFileName = ['Pt ', StringUtils.num2str_PadWithZeros(dPatientId,3), '.mat'];
                chFilePath = fullfile(...
                    chWritePath,...
                    sIvhTagId,...
                    chFileName);
                
                FileIOUtils.SaveMatFile(...
                    chFilePath,...
                    ImageVolumeHandlers.GetCentralLibraryMatFileVarName(), oImageVolumeHandler,...
                    varargin{:});
                
                vsHandlerFileNames(dPatientIndex) = string(chFileName);
            end
            
            oIVH = ImageVolumeHandlers(sIvhTagId, vsHandlerFileNames, vsImageVolumeMatFileFromRootPaths, vsRegionsOfInterestMatFileFromRootPaths);
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, DatabaseGroup.chMatFileVarName);
        end
        
        function obj = LoadForExperiment(chFilePath)
            
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    
    methods (Access = private, Static = false)
        
        function dColIndex = GetColumnIndexForTimepointLabel(obj, sTimepointLabel)
            
            vdTimepointIndex = find(obj.vsTimepointLabels == sTimepointLabel);
            
            if ~isscalar(vdTimepointIndex)
                error(...
                    'DatabaseGroup:GetColumnIndexForTimepointLabel:NonUniqueMatch',...
                    'No or multiple matches found for timepoint label.');
            end
            
            dColIndex = vdTimepointIndex(1);
        end
        
        function vdRowIndices = GetRowIndicesForPatientId(obj, dPatientId)
            vdRowIndices = find(obj.vdPatientIds == dPatientId);
        end
        
        function MustBeValidPatientId(obj, dPatientId)
            arguments
                obj (1,1) DatabaseGroup
                dPatientId (1,1) double {mustBeInteger}
            end
            
            if isempty(find(obj.vdPatientIds == dPatientId, 1))
                error(...
                    'DatabaseGroup:MustBeValidPatientId:NotInDatabaseGroup',...
                    ['The Patient ID ', num2str(dPatientId), ' was not found within the Database Group.'])
            end
        end
        
        function MustBeValidTimepointLabel(obj, sTimepointLabel)
            arguments
                obj (1,1) DatabaseGroup
                sTimepointLabel (1,1) string {mustBeNonempty}
            end
            
            if isempty(find(obj.vsTimepointLabels == sTimepointLabel, 1))
                error(...
                    'DatabaseGroup:MustBeValidTimepointLabel:NotInDatabaseGroup',...
                    ['The Timepoint Label ', char(s), ' was not found within the Database Group.'])
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

