classdef (Abstract) Feature < matlab.mixin.Heterogeneous
    %Feature
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public, Abstract = true)
        chFeaturePrefix             (1,3) char
        
        sFeatureName                (1,1) string
        sFeatureDisplayName         (1,1) string
        
        bIsValidFor2DImageVolumes   (1,1) logical
        bIsValidFor3DImageVolumes   (1,1) logical
    end    
        
       
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Sealed = true)
             
        function vdValues = Extract(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            % validate that feature supports 2D/3D interpreted images
            bImageIs2D = oImageVolumeHandler.IsInterpretedAs2DImage();
            
            if bImageIs2D && ~obj.bIsValidFor2DImageVolumes
                error(...
                    'Feature:Extract:Invalid2DImage',...
                    ['The feature ', char(obj.sFeatureName), ' does not support image volumes being interpreted as a 2D image.']);                
            end
            
            if ~bImageIs2D && ~obj.bIsValidFor3DImageVolumes
                error(...
                    'Feature:Extract:Invalid3DImage',...
                    ['The feature ', char(obj.sFeatureName), ' does not support image volumes being interpreted as a 3D image.']);                
            end
            
            % validate the feature parameters are valid for 2D/3D
            % interpreted images
            obj.ValidateFeatureExtractorParametersForImageVolume(oImageVolumeHandler, oFeatureExtractionParameters);
            
            % validation complete, extract feature
            vdValues = obj.ExtractFeature(oImageVolumeHandler, oFeatureExtractionParameters);
        end
        
    end
    
    methods (Access = public, Static = true)
        
        function voFeatures = GetAllFeatures2D()
            voFeatures = [...
                FirstOrderFeature.GetAllFeatures2D(),...
                ShapeAndSizeFeature.GetAllFeatures2D(),...
                GLCMFeature.GetAllFeatures2D(),...
                GLRLMFeature.GetAllFeatures2D()];
        end
        
        function voFeatures = GetAllFeatures3D()
            voFeatures = [...
                FirstOrderFeature.GetAllFeatures3D(),...
                ShapeAndSizeFeature.GetAllFeatures3D(),...
                GLCMFeature.GetAllFeatures3D(),...
                GLRLMFeature.GetAllFeatures3D()];
        end
        
        function voFeatures = GetAllFeatures()
            voFeatures = [...
                FirstOrderFeature.GetAllFeatures(),...
                ShapeAndSizeFeature.GetAllFeatures(),...
                GLCMFeature.GetAllFeatures(),...
                GLRLMFeature.GetAllFeatures()];            
        end
        
        function vsDisplayNames = GetDisplayNamesFromFeatureNames(vsFeatureNames)
            arguments
                vsFeatureNames (1,:) string
            end
            
            voFeatureClasses = Feature.GetAllFeatures();
            dNumClasses = length(voFeatureClasses);
            
            vsFeatureClassesNames = strings(1,dNumClasses);
            
            for dClassIndex=1:dNumClasses
                vsFeatureClassesNames(dClassIndex) = voFeatureClasses(dClassIndex).sFeatureName;
            end
            
            dNumFeatures = length(vsFeatureNames);
            
            vsDisplayNames = strings(1,dNumFeatures);
            
            for dNameIndex=1:dNumFeatures
                chFeatureName = char(vsFeatureNames(dNameIndex));
                
                bIsCentralLibraryFeature = false;
                
                if length(chFeatureName) >= 7                
                    sFeatureClassName = string(chFeatureName(1:7));
                    
                    vdMatchIndices = find(vsFeatureClassesNames == sFeatureClassName);
                    
                    if isscalar(vdMatchIndices)
                        vsDisplayNames(dNameIndex) = voFeatureClasses(vdMatchIndices(1)).sFeatureDisplayName;
                        bIsCentralLibraryFeature = true;
                    end
                end
                
                if ~bIsCentralLibraryFeature
                    vsDisplayNames(dNameIndex) = vsFeatureNames(dNameIndex);
                end
            end            
        end
        
        function oFeature = GetFeatureObjectFromFeatureName(chFeatureName)
            arguments
                chFeatureName (1,:) char
            end
            
            voFeatureClasses = Feature.GetAllFeatures();
            dNumClasses = length(voFeatureClasses);
            
            vsFeatureClassesNames = strings(1,dNumClasses);
            
            for dClassIndex=1:dNumClasses
                vsFeatureClassesNames(dClassIndex) = voFeatureClasses(dClassIndex).sFeatureName;
            end
            
                
                
            bIsCentralLibraryFeature = false;
            
            if length(chFeatureName) >= 7
                sFeatureClassName = string(chFeatureName(1:7));
                
                vdMatchIndices = find(vsFeatureClassesNames == sFeatureClassName);
                
                if isscalar(vdMatchIndices)
                    oFeature = voFeatureClasses(vdMatchIndices(1));
                    bIsCentralLibraryFeature = true;
                end
            end
            
            if ~bIsCentralLibraryFeature
                oFeature = Feature.empty();
            end
        end
        
        function oFeatureValues = ExtractFeaturesForImageVolumeHandlers(voImageVolumeHandlers, voFeatures, oFeatureExtractionParameters, sDescription, dMaxMemoryUsage_Gb)
            %oFeatureValues = ExtractFeaturesForImageVolumeHandlers(voImageVolumeHandlers, voFeatures, oFeatureExtractionParameters, sDescription, dMaxMemoryUsage_Gb)
            %
            % SYNTAX:
            %  oFeatureValues = Feature.ExtractFeaturesForImageVolumeHandlers(voImageVolumeHandlers, voFeatures, oFeatureExtractionParameters, sDescription, dMaxMemoryUsage_Gb)
            %  oFeatureValues = Feature.ExtractFeaturesForImageVolumeHandlers(__, __, __, __, dMaxMemoryUsage_Gb)
            %
            % DESCRIPTION:
            %  Extracts features for all the
            %  FeatureExtractionImageVolumeHandlers and Features provided,
            %  producing a FeatureValues object. The size of the
            %  FeatureValues object will be the number of ROIs across the
            %  FeatureExtractionImageVolumeHandlers by the number of
            %  features (some features produce multiple values (e.g.
            %  GLCM)).
            %
            % INPUT ARGUMENTS:
            %  voImageVolumeHandlers: Row vector of FeatureExtractionImageVolumeHandler
            %                         objects for which features will be
            %                         extracted for each available ROI
            %                         within the handlers. The handlers
            %                         must also be valid among one another,
            %                         that is:
            %                          - have matching feature source
            %                            strings
            %                          - have unique Group/Sub-Group ID
            %                            pairs for each ROI
            %  voFeatures: Row vector of Feature objects to extract. There
            %              cannot be any duplicated features.
            %  oFeatureExtractionParameters: A FeatureExtractionParameters
            %                                object created from a loaded
            %                                .xlsx file
            %  sDescription: A string describing the feature extraction
            %                being performed.
            %  dMaxMemoryUsage_Gb: (Optional, Default: Inf) The maximum
            %                      memory (RAM) to be used during feature
            %                      extraction. This will determine how
            %                      images/masks will be processed (e.g. can
            %                      a binned version of the image be stored
            %                      or will image values be
            %                      "binned-on-the-fly"). Most often there
            %                      is a trade off between computation time
            %                      and memory usage.
            %
            % OUTPUTS ARGUMENTS:
            %  oFeatureValues: A FeatureValues object containing the
            %                  extracted feature values, along with the
            %                  sample and feature metadata (Group/Sub-Group
            %                  IDs, feature extraction record, links back
            %                  to image volumes/ROIs)
            
            
            arguments
                voImageVolumeHandlers           (1,:) FeatureExtractionImageVolumeHandler
                voFeatures                      (1,:) Feature
                oFeatureExtractionParameters    (1,1) FeatureExtractionParameters
                sDescription                    (1,1) string {ValidationUtils.StringMustBeNotBlank(sDescription)}
                dMaxMemoryUsage_Gb              (1,1) double {mustBePositive} = Inf
            end
               
            bUseParfor = false;
            
            oFeatureValues = Feature.ExtractFeaturesForImageVolumeHandlers_Generalized(...
                bUseParfor,...
                voImageVolumeHandlers, voFeatures, oFeatureExtractionParameters,...
                sDescription, dMaxMemoryUsage_Gb);            
        end
        
        function oFeatureValues = ExtractFeaturesForImageVolumeHandlers_Parallel(voImageVolumeHandlers, voFeatures, oFeatureExtractionParameters, sDescription, dMaxMemoryUsage_Gb)
            arguments
                voImageVolumeHandlers           (1,:) FeatureExtractionImageVolumeHandler
                voFeatures                      (1,:) Feature
                oFeatureExtractionParameters    (1,1) FeatureExtractionParameters
                sDescription                    (1,1) string {ValidationUtils.StringMustBeNotBlank(sDescription)}
                dMaxMemoryUsage_Gb              (1,1) double {mustBePositive} = Inf
            end
               
            bUseParfor = true;
            
            oFeatureValues = Feature.ExtractFeaturesForImageVolumeHandlers_Generalized(...
                bUseParfor,...
                voImageVolumeHandlers, voFeatures, oFeatureExtractionParameters,...
                sDescription, dMaxMemoryUsage_Gb);   
        end        
        
        function m2dFeatures = ExtractFeatureMatrix(oImageVolumeHandler, voFeatures, oFeatureExtractionParameters, dMaxMemoryUsage_Gb)
            arguments
                oImageVolumeHandler (1,1) FeatureExtractionImageVolumeHandler
                voFeatures (1,:) Feature
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
                dMaxMemoryUsage_Gb (1,1) double {mustBePositive}
            end
                        
            oFeatureExtractionParameters = oFeatureExtractionParameters.SetMaxMemoryUsage_Gb(dMaxMemoryUsage_Gb);
            dNumTotalFeatures = Feature.PreComputeNumberOfAllFeatures(voFeatures, oFeatureExtractionParameters);
            
            oImageVolumeHandler.ResetCurrentRegionOfInterestExtractionIndex();
            oImageVolumeHandler.LoadVolumeData(); % get the image data from disk into RAM
            
            dNumRois = oImageVolumeHandler.GetNumberOfRegionsOfInterest();
            dNumFeatures = length(voFeatures);
            
            % pre-allocate
            m2dFeatures = zeros(oImageVolumeHandler.GetNumberOfRegionsOfInterest(), dNumTotalFeatures);
            
            for dRoiIndex=1:dNumRois % >>>>>>>>>>>>>>>> LOOP: ROIs <<<<<<<<<
                
                % check that there are enough "true" voxels in the mask
                [~,m3bMask] = oImageVolumeHandler.GetCurrentRegionOfInterestImageDataAndMask(oFeatureExtractionParameters);
                
                dNumVoxels = sum(m3bMask(:));
                
                if dNumVoxels < oFeatureExtractionParameters.GetMinimumNumberOfVoxelsPerMask()
                    error(...
                        'Feature:ExtractFeatureMatrix:TooFewVoxels',...
                        ['The ROI contained ', num2str(dNumVoxels), ' which is below the ', num2str(oFeatureExtractionParameters.GetMinimumNumberOfVoxelsPerMask()), ' limit set.']);
                end
                
                % Extract:
                dInsertColumnIndex = 1;
                
                for dFeatureIndex=1:dNumFeatures % >>>> LOOP: Features <<<<<
                    
                    vdFeatureValuesForFeature = voFeatures(dFeatureIndex).Extract(oImageVolumeHandler, oFeatureExtractionParameters);
                    
                    dNumValues = length(vdFeatureValuesForFeature);
                    
                    % insert into the feature table
                    m2dFeatures(dRoiIndex, dInsertColumnIndex : dInsertColumnIndex + dNumValues - 1) = vdFeatureValuesForFeature;
                    
                    % increment (some features give back multiple
                    % columns of the feature table e.g. each offset for
                    % a GLCM feature)
                    dInsertColumnIndex = dInsertColumnIndex + dNumValues;
                end
                
                if dRoiIndex ~= dNumRois
                    % increment the current ROI (if possible)
                    oImageVolumeHandler.IncrementCurrentRegionOfInterestExtractionIndex();
                end
            end
            
            oImageVolumeHandler.UnloadVolumeData(); % dump the image data from RAM
        end
        
        
    end
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Static = true, Abstract = true)

        ValidateFeatureExtractorParametersForImageVolume(obj, oImage, oFeatureExtractionParameters)
        
        dNumValues = PreComputeNumberOfFeatures(oFeatureExtractionParameters)
        
        vsFeatureNames = GetFeatureNamesForFeatureExtraction(oFeatureExtractionParameters); % Add obj as first argin? - SD
    end
    
    
    methods (Access = protected, Abstract = true)
        
       vdValues = ExtractFeature(obj, oImage, oFeatureExtractorParameters) 
    end
    
    
    methods (Access = protected, Static = true)
        
        function voFeatures = CreateFeatureListFromDirectory(chPath, chFeaturePrefix, oDefaultObj)
            voEntries = dir(chPath);
            dNumEntries = length(voEntries);
            
            dNumFeatures = 0;
            vbUseEntry = false(dNumEntries,1);
            
            for dEntryIndex=1:dNumEntries
                oEntry = voEntries(dEntryIndex);
                
                if ~oEntry.isdir && length(oEntry.name) > 3 && strcmp(oEntry.name(1:3), chFeaturePrefix) && strcmp(oEntry.name(end-1:end), '.m')
                    dNumFeatures = dNumFeatures + 1;
                    vbUseEntry(dEntryIndex) = true;
                end
            end
            
            voFeatures = repmat(oDefaultObj,1,dNumFeatures);
            dInsertIndex = 1;
            
            for dEntryIndex=1:dNumEntries                
                if vbUseEntry(dEntryIndex)
                    voFeatures(dInsertIndex) = eval(voEntries(dEntryIndex).name(1:end-2));
                    dInsertIndex = dInsertIndex + 1;
                end
            end
        end
    end

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
        
        function dNumFeatures = PreComputeNumberOfAllFeatures(voFeatures, oFeatureExtractionParameters)
            dNumFeatures = 0;

            for dFeatureIndex=1:length(voFeatures)
                dNumFeatures = dNumFeatures + voFeatures(dFeatureIndex).PreComputeNumberOfFeatures(oFeatureExtractionParameters);
            end
        end
        
        function vsFeatureNames = GetFeatureNamesForFeatures(voFeatures, oFeatureExtractionParameters, dNumberOfTotalFeatures)
            vsFeatureNames = strings(1, dNumberOfTotalFeatures);
            
            dInsertIndex = 1;
            
            for dFeatureIndex=1:length(voFeatures)
                vsFeatureNamesToInsert = voFeatures(dFeatureIndex).GetFeatureNamesForFeatureExtraction(oFeatureExtractionParameters);
                dNumToInsert = length(vsFeatureNamesToInsert);
                
                vsFeatureNames(dInsertIndex : dInsertIndex + dNumToInsert - 1) =...
                    vsFeatureNamesToInsert;
                
                dInsertIndex = dInsertIndex + dNumToInsert;
            end
        end
        
        function [viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPositiveLabel, iNegativeLabel, oFeatureExtractionRecord] = GetAndValidateSampleAndFeatureMetadata(voImageVolumeHandlers, voFeatures, oFeatureExtractionParameters, sDescription)
                          
            dtStartTest = datetime(now, 'ConvertFrom', 'datenum');
            dtEndTest = datetime(now, 'ConvertFrom', 'datenum');
            
            oFeatureExtractionRecord = ImageVolumeFeatureExtractionRecord(...
                sDescription, voImageVolumeHandlers, oFeatureExtractionParameters,...
                dtStartTest, dtEndTest);                       
            
            dNumTotalFeatures = Feature.PreComputeNumberOfAllFeatures(voFeatures, oFeatureExtractionParameters);
            
            dNumImages = length(voImageVolumeHandlers);
            vdNumOfRoisPerImage = zeros(dNumImages,1);
                        
            % validate images are all tagged to be from the same data
            % source AND add up the total number of ROIs
            for dImageIndex=1:dNumImages
                vdNumOfRoisPerImage(dImageIndex) = voImageVolumeHandlers(dImageIndex).GetNumberOfRegionsOfInterest();
            end
            
            dNumTotalRois = sum(vdNumOfRoisPerImage);
                        
            % Get the Feature Values IDs, strings, feature names
            viGroupIds = FeatureExtractionImageVolumeHandler.GetGroupIdsForImageVolumeHandlers(voImageVolumeHandlers);
            viSubGroupIds = FeatureExtractionImageVolumeHandler.GetSubGroupIdsForImageVolumeHandlers(voImageVolumeHandlers);
            vsUserDefinedSampleStrings = FeatureExtractionImageVolumeHandler.GetUserDefinedSampleStringsForImageVolumeHandlers(voImageVolumeHandlers);
            
            if isa(voImageVolumeHandlers(1), 'LabelledFeatureExtractionImageVolumeHandler')
                viLabels = LabelledFeatureExtractionImageVolumeHandler.GetLabelsForImageVolumeHandlers(voImageVolumeHandlers);
                iPositiveLabel = LabelledFeatureExtractionImageVolumeHandler.GetPositiveLabelForImageVolumeHandlers(voImageVolumeHandlers);
                iNegativeLabel = LabelledFeatureExtractionImageVolumeHandler.GetNegativeLabelForImageVolumeHandlers(voImageVolumeHandlers);
            else
                viLabels = [];
                iPositiveLabel = [];
                iNegativeLabel = [];
            end
            
            vsFeatureNames = Feature.GetFeatureNamesForFeatures(voFeatures, oFeatureExtractionParameters, dNumTotalFeatures);
            
            % Validate create a dummy (Labelled)FeatureValues object to test that it
            % will create a valid object once we do all the calcs
                        
            % spoof the feature table as zeros
            m2dFeatures = zeros(dNumTotalRois, dNumTotalFeatures);
            
            % try creating the FeatureValues objects, they'll error out if
            % invalid
            if isempty(viLabels)
                oDummyFeatureValues = FeatureValuesByValue(...
                    m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames,...
                    'FeatureExtractionRecord', oFeatureExtractionRecord,...
                    'SampleIndicesToFeatureExtractionRecordIndices', (1:numel(viGroupIds))');                
            else
                oDummyLabelledFeatureValues = LabelledFeatureValuesByValue(...
                    m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames,...
                    viLabels, iPositiveLabel, iNegativeLabel,...
                    'FeatureExtractionRecord', oFeatureExtractionRecord,...
                    'SampleIndicesToFeatureExtractionRecordIndices', (1:numel(viGroupIds))');
            end 
        end
        
        function oFeatureValues = CreateFeatureValuesFromExtractionResults(c1m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPositiveLabel, iNegativeLabel, oFeatureExtractionRecord)
            % check for any nans in feature values
            dNumFeatures = length(vsFeatureNames);
            vbValidValuesForAllSamples = true(1,dNumFeatures);
            
            for dFeatureIndex=1:dNumFeatures
                bValidForAllSamples = true;
                
                for dMatrixIndex=1:length(c1m2dFeatures)
                    bHasNan = any(isnan(c1m2dFeatures{dMatrixIndex}(:,dFeatureIndex)));
                    
                    if bHasNan
                        bValidForAllSamples = false;
                        break;
                    end
                end
                
                if ~bValidForAllSamples
                    vbValidValuesForAllSamples(dFeatureIndex) = false;
                end
            end
            
            % - check for any invalid features
            dNumInvalidFeatures = sum(~vbValidValuesForAllSamples);
            
            if dNumInvalidFeatures == dNumFeatures % well there's no real feature values to give back then...let's error!
                error(...
                    'Feature:CreateFeatureValuesFromExtractionResults:AllFeaturesInvalid',...
                    'All features were found to have at least one sample with an invalid value (NaN).');
            elseif dNumInvalidFeatures > 0
                % issue warning
                warning(...
                    'Feature:CreateFeatureValuesFromExtractionResults:InvalidFeaturesRemoved',...
                    [num2str(dNumInvalidFeatures), ' features were found to have at least one sample with an invalid value (NaN). These features have been removed from the produced feature values object.']);
                
                % remove columns for all feature matrices
                for dMatrixIndex=1:length(c1m2dFeatures)
                    c1m2dFeatures{dMatrixIndex} = c1m2dFeatures{dMatrixIndex}(:,vbValidValuesForAllSamples);
                end
                
                % remove feature names
                vsFeatureNames = vsFeatureNames(vbValidValuesForAllSamples);
            end
            
            % construct the feature values object for real
            if isempty(viLabels)
                oFeatureValues = FeatureValuesByValue(...
                    vertcat(c1m2dFeatures{:}),...
                    viGroupIds, viSubGroupIds,...
                    vsUserDefinedSampleStrings,...
                    vsFeatureNames,...
                    'FeatureExtractionRecord', oFeatureExtractionRecord,...
                    'SampleIndicesToFeatureExtractionRecordIndices', (1:numel(viGroupIds))');                
            else
                oFeatureValues = LabelledFeatureValuesByValue(...
                    vertcat(c1m2dFeatures{:}),...
                    viGroupIds, viSubGroupIds,...
                    vsUserDefinedSampleStrings,...
                    vsFeatureNames,...
                    viLabels, iPositiveLabel, iNegativeLabel,...
                    'FeatureExtractionRecord', oFeatureExtractionRecord,...
                    'SampleIndicesToFeatureExtractionRecordIndices', (1:numel(viGroupIds))');                
            end
        end
        
        function oFeatureValues = ExtractFeaturesForImageVolumeHandlers_Generalized(bUseParfor, voImageVolumeHandlers, voFeatures, oFeatureExtractionParameters, sDescription, dMaxMemoryUsage_Gb)
            [viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPositiveLabel, iNegativeLabel, oFeatureExtractionRecord] = ...
                Feature.GetAndValidateSampleAndFeatureMetadata(voImageVolumeHandlers, voFeatures, oFeatureExtractionParameters, sDescription);
                        
            % Looks like we're good to go here:
            %  - Images/ROIs are all able to be loaded/are valid
            %  - Proposed Group/Sub-Groups are good
            %  - Feature Names/Data Source Tags are valid
            % LET'S COMPUTE SOME FEATURES:
            
            dNumImageVolumeHandlers = length(voImageVolumeHandlers);
            c1m2dFeatures = cell(dNumImageVolumeHandlers,1);
            
            % Time loop
            dtStart = datetime(now, 'ConvertFrom', 'datenum');
            
            % Loop manager to provide journaling and random number
            % consistency across for and parfor
            oLoopManager = Experiment.GetLoopIterationManager(dNumImageVolumeHandlers);
                        
            if bUseParfor
                parfor dImageIndex=1:dNumImageVolumeHandlers
                    c1m2dFeatures{dImageIndex} = Feature.ExtractFeaturesForImageVolumeHandlers_PerIteration(...
                        oLoopManager, dImageIndex,...
                        voImageVolumeHandlers(dImageIndex), voFeatures,...
                        oFeatureExtractionParameters, dMaxMemoryUsage_Gb);
                end                
            else
                for dImageIndex=1:dNumImageVolumeHandlers
                    c1m2dFeatures{dImageIndex} = Feature.ExtractFeaturesForImageVolumeHandlers_PerIteration(...
                        oLoopManager, dImageIndex,...
                        voImageVolumeHandlers(dImageIndex), voFeatures,...
                        oFeatureExtractionParameters, dMaxMemoryUsage_Gb);
                end
            end
            
            % Loop manager shut down
            oLoopManager.PostLoopTeardown;
            
            % Loop Timing stop
            dtEnd = datetime(now, 'ConvertFrom', 'datenum');
            
            oFeatureExtractionRecord = ImageVolumeFeatureExtractionRecord(sDescription, voImageVolumeHandlers, oFeatureExtractionParameters, dtStart, dtEnd);
            
            % create the FeatureValues object
            oFeatureValues = Feature.CreateFeatureValuesFromExtractionResults(...
                c1m2dFeatures,...
                viGroupIds, viSubGroupIds,...
                vsUserDefinedSampleStrings,...
                vsFeatureNames,...
                viLabels, iPositiveLabel, iNegativeLabel,...
                oFeatureExtractionRecord);
            
            % journal:
            if Experiment.IsRunning()
                Experiment.StartNewSubSection(strcat("Feature Extraction: ", sDescription));
                
                Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel("Time Elapsed: ", datestr(dtEnd - dtStart, ReportUtils.GetDurationDatestrFormat)));
                
                dNumFeatures = length(voFeatures);
                dNumSamples = oFeatureValues.GetNumberOfSamples();
                
                Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel("Number of Image Volumes: ", num2str(dNumImageVolumeHandlers)));
                Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel("Number of Regions of Interest: ", num2str(dNumSamples)));
                Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel("Number of Features: ", num2str(dNumFeatures)));
                
                Experiment.StartNewSubSection("Features Extracted:");
                                
                for dFeatureIndex=1:length(voFeatures)
                    oParagraph = ReportUtils.CreateParagraphWithBoldLabel([char(voFeatures(dFeatureIndex).sFeatureName), ': '], voFeatures(dFeatureIndex).sFeatureDisplayName);
                                    
                    Experiment.AddToReport(oParagraph);
                end
                
                Experiment.EndCurrentSubSection();
                
                Experiment.EndCurrentSubSection();
            end
        end
        
        function m2dFeatures = ExtractFeaturesForImageVolumeHandlers_PerIteration(oLoopManager, dLoopIndex, oImageVolumeHandler, voFeatures, oFeatureExtractionParameters, dMaxMemoryUsage_Gb)
            
            oLoopManager.PerLoopIndexSetup(dLoopIndex);
            
            m2dFeatures = Feature.ExtractFeatureMatrix(...
                oImageVolumeHandler, voFeatures,...
                oFeatureExtractionParameters, dMaxMemoryUsage_Gb);
            
            oLoopManager.PerLoopIndexTeardown();
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

