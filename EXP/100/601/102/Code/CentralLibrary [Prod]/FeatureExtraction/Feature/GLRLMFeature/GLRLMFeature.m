classdef (Abstract) GLRLMFeature < Feature
    %GLRLMFeature
    %
    % Functions for all GLRLM based calculations.
    
    % Primary Author: David Devries
    % Created: April 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        chFeaturePrefix = 'F04'
        
        bIsValidFor2DImageVolumes = true
        bIsValidFor3DImageVolumes = true
    end     
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = public, Static = true)
        
        function voFeatures = GetAllFeatures2D()
            % voFeatures = GetAllFeatures2D()
            %
            % SYNTAX:
            % voFeatures = GetAllFeatures2D()
            %
            % DESCRIPTION:
            %  Returns features that can only be applied
            %  to 2D images.
            %
            % INPUT ARGUMENTS:
            %  -
            %
            % OUTPUTS ARGUMENTS:
            %  voFeatures: Vector of feature objects.

            % Primary Author: David Devries
            % Created: April 30, 2019
            
            voFeatures = GLRLMFeature.GetAllFeatures();
        end
        
        function voFeatures = GetAllFeatures3D()
            % voFeatures = GetAllFeatures3D()
            %
            % SYNTAX:
            % voFeatures = GetAllFeatures3D()
            %
            % DESCRIPTION:
            %  Returns features that can only be applied
            %  to 3D images.
            %
            % INPUT ARGUMENTS:
            %  -
            %
            % OUTPUTS ARGUMENTS:
            %  voFeatures: Vector of feature objects.

            % Primary Author: David Devries
            % Created: April 30, 2019
            
            voFeatures = GLRLMFeature.GetAllFeatures();
        end
        
        function voFeatures = GetAllFeatures()
            % voFeatures = GetAllFeatures()
            %
            % SYNTAX:
            % voFeatures = GetAllFeatures()
            %
            % DESCRIPTION:
            %  Returns all features both 2D and 3D.
            %
            % INPUT ARGUMENTS:
            %  -
            %
            % OUTPUTS ARGUMENTS:
            %  voFeatures: Vector of feature objects.

            % Primary Author: David Devries
            % Created: April 30, 2019
            
            chPath = mfilename('fullpath');
            [chPath,~] = FileIOUtils.SeparateFilePathAndFilename(chPath);
            
            voFeatures = Feature.CreateFeatureListFromDirectory(...
                chPath, GLRLMFeature.chFeaturePrefix, F040001_GLRLMShortRunEmphasis);
        end
        
        function m2dGLRLM = CalculateGLRLM(m3xImageData, m3bMask, vdOffsetVector, dFirstBinEdge, dBinSize, dNumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns, bBinOnTheFly, varargin)
            % m2dGLRLM = CalculateGLRLM(m3xImageData, m3bMask, vdOffsetVector, dFirstBinEdge, dBinSize, dNumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns,  bBinOnTheFly, varargin)
            %
            % SYNTAX:
            % m2dGLRLM = CalculateGLRLM(m3xImageData, m3bMask, vdOffsetVector, dFirstBinEdge, dBinSize, dNumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns,  bBinOnTheFly, varargin)
            %
            % DESCRIPTION:
            %  Calculates the GLRLM of the ROI with given parameters.
            %
            % INPUT ARGUMENTS:
            %  m3xImageData: Matrix of imaging data.
            %  m3bMask: Matrix containing the mask that defines the ROI.
            %  dFirstBinEdge: First edge of the bin for gray level quanitization.
            %  dBinSize: Size of each bin.
            %  dNumberOfBins: Number of bins for gray level quantization.
            %  dEqualityThreshold: Equality threshold.
            %  dNumberOfColumns: Number of columns to include in the GLRLM.
            %  bTrimColumns: Trim columns that have no run lengths in said
            %   columns.
            %  bBinOnTheFly: Flag to perform gray level quantization as the images come in to the calculator or beforehand.
            %  varargin: All of the arguments
            %
            % OUTPUTS ARGUMENTS:
            %  m2dGLRLM: Resulting gray level run length matrix.

            % Primary Author: David Devries
            % Created: April 30, 2019
            
            if ~bBinOnTheFly
                if isempty(varargin)
                    error(...
                        'GLRLMFeature:CalculateGLRLM:NoBinnedMatrixGiven',...
                        'If bin-on-the-fly is not used, a binned matrix must be given.');
                end
                
                m3ui64BinnedImageData = varargin{1};
            end
            
            vi32OffsetVector = int32(vdOffsetVector);
            ui64NumberOfBins = uint64(dNumberOfBins);
            
            if bBinOnTheFly
                switch class(m3xImageData)
                    case 'double'
                        m2ui64GLRLM = CalculateGLRLM_BinOnTheFly_double_mex(m3xImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'single'
                        % convert binning params to single so that the
                        % matrix data doesn't need to be cast to a double
                        % (as it is for integers)
                        % I don't think there'll be binning precision required
                        % beyond a single
                        sgFirstBinEdge = single(dFirstBinEdge);
                        sgBinSize = single(dBinSize);
                        
                        m2ui64GLRLM = CalculateGLRLM_BinOnTheFly_single_mex(m3xImageData, m3bMask, vi32OffsetVector, sgFirstBinEdge, sgBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'uint8'
                        m2ui64GLRLM = CalculateGLRLM_BinOnTheFly_uint8_mex(m3xImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'uint16'
                        m2ui64GLRLM = CalculateGLRLM_BinOnTheFly_uint16_mex(m3xImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'uint32'
                        m2ui64GLRLM = CalculateGLRLM_BinOnTheFly_uint32_mex(m3xImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'int8'
                        m2ui64GLRLM = CalculateGLRLM_BinOnTheFly_int8_mex(m3xImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'int16'
                        m2ui64GLRLM = CalculateGLRLM_BinOnTheFly_int16_mex(m3xImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'int32'
                        m2ui64GLRLM = CalculateGLRLM_BinOnTheFly_int32_mex(m3xImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    otherwise
                        error(...
                            'GLRLMFeature:CalculateGLRLM:InvalidDataType',...
                            'Invalid image data type, must be of type single, double, or integer (up to 32-bit).');
                end
            else % binning is pre-computed
                switch class(m3xImageData)
                    case 'double'
                        m2ui64GLRLM = CalculateGLRLM_BinningPreComputed_double_mex(m3xImageData, m3ui64BinnedImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'single'
                        % convert binning params to single so that the
                        % matrix data doesn't need to be cast to a double
                        % (as it is for integers)
                        % I don't think there'll be binning precision required
                        % beyond a single
                        sgFirstBinEdge = single(dFirstBinEdge);
                        sgBinSize = single(dBinSize);
                        
                        m2ui64GLRLM = CalculateGLRLM_BinningPreComputed_single_mex(m3xImageData, m3ui64BinnedImageData, m3bMask, vi32OffsetVector, sgFirstBinEdge, sgBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'uint8'
                        m2ui64GLRLM = CalculateGLRLM_BinningPreComputed_uint8_mex(m3xImageData, m3ui64BinnedImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'uint16'
                        m2ui64GLRLM = CalculateGLRLM_BinningPreComputed_uint16_mex(m3xImageData, m3ui64BinnedImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'uint32'
                        m2ui64GLRLM = CalculateGLRLM_BinningPreComputed_uint32_mex(m3xImageData, m3ui64BinnedImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'int8'
                        m2ui64GLRLM = CalculateGLRLM_BinningPreComputed_int8_mex(m3xImageData, m3ui64BinnedImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'int16'
                        m2ui64GLRLM = CalculateGLRLM_BinningPreComputed_int16_mex(m3xImageData, m3ui64BinnedImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    case 'int32'
                        m2ui64GLRLM = CalculateGLRLM_BinningPreComputed_int32_mex(m3xImageData, m3ui64BinnedImageData, m3bMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins, dEqualityThreshold, dNumberOfColumns, bTrimColumns);
                    otherwise
                        error(...
                            'GLRLMFeature:CalculateGLRLM:InvalidDataType',...
                            'Invalid image data type, must be of type single, double, or integer (up to 32-bit).');
                end
            end
            
            % cast to double for easier use with mathematical formulas
            m2dGLRLM = double(m2ui64GLRLM);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Static = true, Abstract = true)
        dValue = ExtractGLRLMFeature(m2dGLRLM, oFeatureExtractorParameters)
    end

    
    methods (Access = protected)
        
        function vdValues = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            % vdValues = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            %
            % SYNTAX:
            % vdValues = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            %
            % DESCRIPTION:
            %  Protected feature extraction function that calls individual calculators from each GLRLM feature.
            %
            % INPUT ARGUMENTS:
            %  obj: Feature extraction object.
            %  oImageVolumeHandler: Image volume handlerr containing the
            %   image and ROI.
            %  oFeatureExtractionParameters: Object containing the feature
            %   extraction parameters.
            %
            % OUTPUTS ARGUMENTS:
            %  vdValues: Resulting feature values.

            % Primary Author: David Devries
            % Created: April 30, 2019
            
            % if they've already been computed, it'll get the cached
            % versions, otherwise they'll be computed and then cached for
            % later use
            c1m2dGLRLMs = oImageVolumeHandler.GetCurrentRegionOfInterestGLRLMs(oFeatureExtractionParameters);
                            
            dNumGLRLMs = length(c1m2dGLRLMs);
            
            vdValues = zeros(1, dNumGLRLMs);
            
            for dGLRLMIndex=1:dNumGLRLMs
                vdValues(dGLRLMIndex) = obj.ExtractGLRLMFeature(c1m2dGLRLMs{dGLRLMIndex}, oFeatureExtractionParameters); 
            end
        end   
        
        function ValidateFeatureExtractorParametersForImageVolume(obj, oImageVolumeHandler, oFeatureExtractorParameters)
            % ValidateFeatureExtractorParametersForImageVolume(obj, oImageVolumeHandler, oFeatureExtractorParameters)
            %
            % SYNTAX:
            % ValidateFeatureExtractorParametersForImageVolume(obj, oImageVolumeHandler, oFeatureExtractorParameters)
            %
            % DESCRIPTION:
            %  Validates the feature extractor parameters for the current
            %  image volume.
            %
            % INPUT ARGUMENTS:
            %  obj: Feature extraction object.
            %  oImageVolumeHandler: Image volume handlerr containing the
            %   image and ROI.
            %  oFeatureExtractionParameters: Object containing the feature
            %   extraction parameters.
            %
            % OUTPUTS ARGUMENTS:
            %  -

            % Primary Author: David Devries
            % Created: April 30, 2019
            
            vdOffsetNumbers = oFeatureExtractorParameters.GetGLRLMOffsetNumbers();
            
            vdOffsetNumbers(isinf(vdOffsetNumbers)) = []; % Inf is the combination of all offsets, don't care about that for this validation
            
            if oImageVolumeHandler.IsInterpretedAs2DImage() && max(vdOffsetNumbers) > 8
                error(...
                    'GLRLMFeature:ValidateFeatureExtractorParametersForImageVolume:InvalidOffsetFor2DImage',...
                    'GLRLM features do not support 3D feature offsets for image volumes being interpreted as 2D images.');
            end
        end
        
        function vsFeatureNames = GetFeatureNamesForFeatureExtraction(obj, oFeatureExtractorParameters)
            % vsFeatureNames = GetFeatureNamesForFeatureExtraction(obj, oFeatureExtractorParameters)
            %
            % SYNTAX:
            % vsFeatureNames = GetFeatureNamesForFeatureExtraction(obj, oFeatureExtractorParameters)
            %
            % DESCRIPTION:
            %  Retrieves the names of the features that are being extracted
            %  by the user.
            %
            % INPUT ARGUMENTS:
            %  obj: Feature extraction object.
            %  oFeatureExtractionParameters: Object containing the feature
            %   extraction parameters.
            %
            % OUTPUTS ARGUMENTS:
            %  vsFeatureNames: Vector of strings containing the names of
            %   each feature to be extracted.

            % Primary Author: David Devries
            % Created: April 30, 2019
            
            vdOffsetNumbers = oFeatureExtractorParameters.GetGLRLMOffsetNumbers();
            
            vsFeatureNames = strtrim(string(num2str(vdOffsetNumbers')));
            
            vsFeatureNames = strcat(obj.sFeatureName, "_", vsFeatureNames);
                        
            if oFeatureExtractorParameters.GetCombineAllGLRLMOffsets()
                dNumOffsets = length(vdOffsetNumbers)-1;
                                
                vsFeatureNames(end) = strcat(obj.sFeatureName, "_All_", num2str(dNumOffsets), "x");
            end
            
            vsFeatureNames = vsFeatureNames';
        end 
    end
    
        
    methods (Access = protected, Static = true)

        function dNumValues = PreComputeNumberOfFeatures(oFeatureExtractorParameters)
            % dNumValues = PreComputeNumberOfFeatures(oFeatureExtractorParameters)
            %
            % SYNTAX:
            % dNumValues = PreComputeNumberOfFeatures(oFeatureExtractorParameters)
            %
            % DESCRIPTION:
            %  Fetches the number of features that will be extracted by the
            %  user for a given set of extractor parameters.
            %
            % INPUT ARGUMENTS:
            %  oFeatureExtractorParameters: Object containing the feature
            %   extraction parameters.
            %
            % OUTPUTS ARGUMENTS:
            %  dNumValues: Total number of output features.

            % Primary Author: David Devries
            % Created: April 30, 2019
            
            dNumValues = length(oFeatureExtractorParameters.GetGLRLMOffsetNumbers());
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)     
        
        function dValue = ExtractGLRLMFeature_ForUnitTest(obj, m2dGLRLM, oFeatureExtractorParameters)
            % Usage ex.:
            % obj = F040001_?????;
            % obj.ExtractGLRLMFeature_ForUnitTest(m2dGLRLM, oFeatureExtractionParameters)
            
            dValue = obj.ExtractGLRLMFeature(m2dGLRLM, oFeatureExtractorParameters);
        end 
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

