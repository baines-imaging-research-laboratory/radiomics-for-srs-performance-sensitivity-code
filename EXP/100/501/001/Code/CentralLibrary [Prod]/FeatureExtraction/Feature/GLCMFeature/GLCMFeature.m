classdef (Abstract) GLCMFeature < Feature
    %GLCMFeature
    %
    % Functions for all GLCM based calculations.
    
    % Primary Author: David Devries
    % Created: April 30, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        chFeaturePrefix = 'F03'
        
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
            
            voFeatures = GLCMFeature.GetAllFeatures();
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
            
            voFeatures = GLCMFeature.GetAllFeatures();
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
                chPath, GLCMFeature.chFeaturePrefix, F030001_GLCMContrast);
        end
        
        function m2dGLCM = CalculateGLCM(m3xImageData, m3bMask, vdOffsetVector, dNumberOfBins, bSymmetric, bNormalize, bBinOnTheFly, varargin)
            % m2dGLCM = CalculateGLCM(m3xImageData, m3bMask, vdOffsetVector, dNumberOfBins, bSymmetric, bNormalize, bBinOnTheFly, varargin)
            %
            % SYNTAX:
            % m2dGLCM = CalculateGLCM(m3xImageData, m3bMask, vdOffsetVector, dNumberOfBins, bSymmetric, bNormalize, bBinOnTheFly, varargin)
            %
            % DESCRIPTION:
            %  Calculates the GLCM of the ROI with given parameters.
            %
            % INPUT ARGUMENTS:
            %  m3xImageData: Matrix of imaging data.
            %  m3bMask: Matrix containing the mask that defines the ROI.
            %  vdOffsetVector: Offset vector for calculating the GLCM.
            %  dNumberOfBins: Number of bins for gray level quantization.
            %  bSymmetric: Flag for a symmetric GLCM.
            %  bNormalize: Flag for a normalized GLCM.
            %  bBinOnTheFly: Flag to perform gray level quantization as the images come in to the calculator or beforehand.
            %  varargin: All of the arguments
            %
            % OUTPUTS ARGUMENTS:
            %  m2dGLCM: Resulting gray level co-occurrence matrix.

            % Primary Author: David Devries
            % Created: April 30, 2019
            
            % need to cast these to the correct type for the Mex functions
            i64OffsetVector = int64(vdOffsetVector);
            ui64NumberOfBins = uint64(dNumberOfBins);
            
            if bBinOnTheFly                
                dFirstBinEdge = [];
                dBinSize = [];
                
                for dVararginIndex=1:2:length(varargin)
                    switch varargin{dVararginIndex}
                        case 'FirstBinEdge'
                            dFirstBinEdge = varargin{dVararginIndex+1};
                        case 'BinSize'
                            dBinSize = varargin{dVararginIndex+1};
                        otherwise
                            error(...
                                'GLCMFeature:CalculateGLCM:InvalidParameter',...
                                ['Invalid parameter name: ', varargin{dVararginIndex}, '. See documentation for usage.']);
                    end
                end
                
                if isempty(dFirstBinEdge) || isempty(dBinSize) || isempty(dNumberOfBins)
                    error(...
                        'GLCMFeature:CalculateGLCM:InvalidParameter',...
                        'In order to bin-on-the-fly the first bin edge, bin size, and number of bins must be specified.');
                end
                
                switch class(m3xImageData)
                    case 'double'
                        m2ui64GLCM = CalculateGLCM_BinOnTheFly_double_mex(m3xImageData, m3bMask, i64OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins);
                    case 'single'
                        % convert binning params to single so that the
                        % matrix data doesn't need to be cast to a double
                        % (as it is for integers)
                        % I don't think there'll be binning precision required
                        % beyond a single
                        sgFirstBinEdge = single(dFirstBinEdge);
                        sgBinSize = single(dBinSize);
                        
                        m2ui64GLCM = CalculateGLCM_BinOnTheFly_single_mex(m3xImageData, m3bMask, i64OffsetVector, sgFirstBinEdge, sgBinSize, ui64NumberOfBins);
                    case 'uint8'
                        m2ui64GLCM = CalculateGLCM_BinOnTheFly_uint8_mex(m3xImageData, m3bMask, i64OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins);
                    case 'uint16'
                        m2ui64GLCM = CalculateGLCM_BinOnTheFly_uint16_mex(m3xImageData, m3bMask, i64OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins);
                    case 'uint32'
                        m2ui64GLCM = CalculateGLCM_BinOnTheFly_uint32_mex(m3xImageData, m3bMask, i64OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins);
                    case 'int8'
                        m2ui64GLCM = CalculateGLCM_BinOnTheFly_int8_mex(m3xImageData, m3bMask, i64OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins);
                    case 'int16'
                        m2ui64GLCM = CalculateGLCM_BinOnTheFly_int16_mex(m3xImageData, m3bMask, i64OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins);
                    case 'int32'
                        m2ui64GLCM = CalculateGLCM_BinOnTheFly_int32_mex(m3xImageData, m3bMask, i64OffsetVector, dFirstBinEdge, dBinSize, ui64NumberOfBins);
                    otherwise
                        error(...
                            'GLCMFeature:CalculateGLCM:InvalidDataType',...
                            'Invalid image data type, must be of type single, double, or integer (up to 32-bit).');
                end
            else
                if isa(m3xImageData, 'uint32')
                    m2ui64GLCM = CalculateGLCM_BinningPreComputed_mex(m3xImageData, m3bMask, i64OffsetVector, ui64NumberOfBins);
                else                
                    error(...
                        'GLCMFeature:CalculateGLCM:InvalidBinnedMatrixDataType',...
                        'A pre-binned matrix must be of type uint32.');
                end
            end
            
            % cast to double to make any arthimetic down the line easier
            m2dGLCM = double(m2ui64GLCM);
            
            % make GLCM symmetric if requested
            if bSymmetric
                m2dGLCM = m2dGLCM + transpose(m2dGLCM);
            end
            
            % normalize GLCM if requested
            if bNormalize
                m2dGLCM = m2dGLCM ./ sum(m2dGLCM(:));
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Static = true, Abstract = true)
        dValue = ExtractGLCMFeature(m2dGLCM, oFeatureExtractorParameters)
    end
    

    methods (Access = protected)
           
        function vdValues = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            % vdValues = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            %
            % SYNTAX:
            % vdValues = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            %
            % DESCRIPTION:
            %  Protected feature extraction function that calls individual calculators from each GLCM feature.
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
            c1m2dGLCMs = oImageVolumeHandler.GetCurrentRegionOfInterestGLCMs(oFeatureExtractionParameters);
                            
            dNumGLCMs = length(c1m2dGLCMs);
            
            vdValues = zeros(1, dNumGLCMs);
            
            for dGLCMIndex=1:dNumGLCMs
                vdValues(dGLCMIndex) = obj.ExtractGLCMFeature(c1m2dGLCMs{dGLCMIndex}, oFeatureExtractionParameters); 
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
            
            vdOffsetNumbers = oFeatureExtractorParameters.GetGLCMOffsetNumbers();
            
            vdOffsetNumbers(isinf(vdOffsetNumbers)) = []; % Inf is the combination of all offsets, don't care about that for this validation
            
            if oImageVolumeHandler.IsInterpretedAs2DImage() && max(vdOffsetNumbers) > 8
                error(...
                    'GLCMFeature:ValidateFeatureExtractorParametersForImageVolume:InvalidOffsetFor2DImage',...
                    'GLCM features do not support 3D feature offsets for image volumes being interpreted as 2D images.');
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
            
            vdOffsetNumbers = oFeatureExtractorParameters.GetGLCMOffsetNumbers();
            
            vsFeatureNames = strtrim(string(num2str(vdOffsetNumbers')));
            
            vsFeatureNames = strcat(obj.sFeatureName, "_", vsFeatureNames);
            
            if oFeatureExtractorParameters.GetGLCMSymmetric()
                vsFeatureNames = strcat(vsFeatureNames, "_", strtrim(string(num2str(oFeatureExtractorParameters.GetOppositeGLCMOffsetNumbers(vdOffsetNumbers')))));
            end
            
            if oFeatureExtractorParameters.GetCombineAllGLCMOffsets()
                dNumOffsets = length(vdOffsetNumbers)-1;
                
                if oFeatureExtractorParameters.GetGLCMSymmetric()
                    dNumOffsets = 2*dNumOffsets;
                end
                
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
            
            dNumValues = length(oFeatureExtractorParameters.GetGLCMOffsetNumbers());
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
        
        function dValue = ExtractGLCMFeature_ForUnitTest(obj, m2dGLCM, oFeatureExtractorParameters)
            % dValue = ExtractGLCMFeature_ForUnitTest(obj, m2dGLCM, oFeatureExtractorParameters)
            %
            % SYNTAX:
            % dValue = ExtractGLCMFeature_ForUnitTest(obj, m2dGLCM, oFeatureExtractorParameters)
            %
            % DESCRIPTION:
            %  Extracts GLCM features for unit test cases.
            %
            % INPUT ARGUMENTS:
            %  obj: Feature extraction object.
            %  m2dGLCM: Gray level co-occurence matrix
            %  oFeatureExtractorParameters: Object containing the feature
            %   extraction parameters.
            %
            % OUTPUTS ARGUMENTS:
            %  dValue: Resulting feature value.
            %
            % Usage ex.:
            % obj = F030001_GLCMContrast;
            % obj.ExtractGLCMFeature_ForUnitTest(m2dGLCM, oFeatureExtractionParameters)
            
            % Primary Author: David Devries
            % Created: April 30, 2019
            
            dValue = obj.ExtractGLCMFeature(m2dGLCM, oFeatureExtractorParameters);
        end       
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)         
    end
end

