classdef FeatureExtractionImageVolumeHandler < matlab.mixin.Copyable
    %FeatureExtractionImageVolumeHandler
    %
    % This class is responsible for handling ImageVolumes (w/ contained
    % RegionsOfInterest objects) for FeatureExtraction.
    %
    % You're probably what is meant by "handling". If so, read on:
    % For features to be extracted per ROI for an ImageVolume, a few data
    % and functions need to be available. Which ROI's are going to have
    % features extracted and in which order is the first step. For each of these
    % ROIs, the Group/Sub-Group ID pair and user defined string must be
    % given (these will be used to construct the FeatureValues object
    % containing the extracted feature values). A description of the
    % feature extraction and whether to treat images as 2D or 3D are also
    % stored. The FeatureExtractionImageVolumeHandler also does some nice
    % encapsulation of key functionality. Computationally intensive tasks
    % (e.g. GLCM calc., GLRLM calc., geometric measures) are exposed here,
    % and computed values are cached to avoid re-calculation. The binning
    % of images, and extraction of minimized ROI masks is also exposed and
    % caching is used. Lastly, FeatureExtractionImageVolumeHandler allow
    % for the concept of the "current ROI" to be made. This allows all the
    % above functions to be used for each current ROI, and then the current
    % ROI to be incremented during feature extraction.
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        oRASImageVolume
        
        dCurrentRegionOfInterestExtractionIndex = 1
        
        oRegionsOfInterestRepresentativeFieldsOfView = []
        
        % Cached values for the current ROI having it's features extracted
        % - GLCM Cache:
        bCurrentRegionOfInterestGLCMCacheSet = false
        bCurrentRegionOfInterestBinOnTheFlyGLCM = []
        
        c1m2dCurrentRegionOfInterestCachedGLCMs = {}
        vdCurrentRegionOfInterestCachedGLCMsOffsetNumbers = []
        
        % - GLRLM Cache:
        bCurrentRegionOfInterestGLRLMCacheSet = false
        bCurrentRegionOfInterestBinOnTheFlyGLRLM = []
        
        c1m2dCurrentRegionOfInterestCachedGLRLMs = {}
        vdCurrentRegionOfInterestCachedGLRLMsOffsetNumbers = []
        
        % - Shape & Size Cache:
        bCurrentRegionOfInterestShapeAndSizeCacheSet = false
        
        dCurrentRegionOfInterestCachedPerimeter_mm = []     % 2D
        dCurrentRegionOfInterestCachedArea_mm2 = []         % 2D
        dCurrentRegionOfInterestCachedSurfaceArea_mm2 = []  % 3D
        dCurrentRegionOfInterestCachedVolume_mm3 = []       % 3D
        dCurrentRegionOfInterestCachedMaxDiameter_mm = []   % 2D/3D
        vdCurrentRegionOfInterestCachedRadialLengths_mm = []% 2D/3D
        dCurrentRegionOfInterestRecist_mm = []              % 2D
        dCurrentRegionOfInterestSagittalRecist_mm = []      % 3D
        dCurrentRegionOfInterestCoronalRecist_mm = []       % 3D
        dCurrentRegionOfInterestAxialRecist_mm = []         % 3D
        dCurrentRegionOfInterestPcaLambdaLeast = []         % 3D
        dCurrentRegionOfInterestPcaLambdaMinor = []         % 2D/3D
        dCurrentRegionOfInterestPcaLambdaMajor = []         % 2D/3D
        
        % subsets of original image/roi that are as small as possible
        bCurrentRegionOfInterestImageAndMaskCacheSet = false
        bCurrentRegionOfInterestImageAndMaskCacheSetIsMinimallyBounded = []
        
        vdCurrentRegionOfInterestImageAndMaskCacheMinimalRowBounds = [] % if a subset of the image and mask are stored, these bounds give where in the larger image volume the subset is from
        vdCurrentRegionOfInterestImageAndMaskCacheMinimalColumnBounds = []
        vdCurrentRegionOfInterestImageAndMaskCacheMinimalSliceBounds = []
        
        m3xCurrentRegionOfInterestCachedImage = [] % may be empty even when cache is set in the case where it is more memory efficient to just refer to the entire image volume instead make a copy of a subset
        m3bCurrentRegionOfInterestCachedMask = [] % will always be set when the cache is set. Could either be the full mask or a minimized subset.
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)
        vdExtractionOrderRegionOfInterestNumbers
        
        bIsInterpretedAs2DImage % this is set to true the m3xImageData is 2D (third dimension is 1) and the user wants to interpret this image volume as having a thickness of 0mm. This changes the types of features that can be extracted from the image data.
        
        % Per ImageVolume
        sFeatureSource
        
        % Per Region of Interest/Sample
        viGroupIds (:,1)                 = []
        viSubGroupIds (:,1)              = []
        vsUserDefinedSampleStrings (:,1)  = []
    end
    
    
    properties (Constant = true, GetAccess = public)
        dNumBytesPerBinnedImageVoxel = 4 % uint32
        dMisalignmentFromTargetUnifiedImageVolumeGeometryErrorLimit_deg = 30;
        
        % this ImageVolumeGeometry is the target geometry that all volumes
        % are transformed onto. This allows for all volumes to be aligned
        % in the same way, allowing for easier display, as well as
        % alignment of all feature calculations offset with respect to
        % patient anatomy. This target geometry aligns with the RAS (+x:
        % right, +y: anterior, +z: superier) coordinate system of the
        % CentralLibrary, that is, matrix coordinate axes i = +x = right, j
        % = +y = anterior, k = +z = superior, where a matrix is indexed as
        % m3xMatrix(x,y,z)
        oTargetUnifiedImageVolumeGeometry = ImageVolumeGeometry.GetRASImageVolumeGeometry();
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = FeatureExtractionImageVolumeHandler(oImageVolume, sImageSource, NameValueArgs)
            %obj = FeatureExtractionImageVolumeHandler(oImageVolume, sImageSource, NameValueArgs)
            %
            % SYNTAX:
            %  obj = ImageVolumeHandler(oImageVolume, sImageSource, Name, Value)
            %
            %  Name-Value Pairs:
            %   'GroupIds': (Required) Can be either a single integer or a
            %               list of integers. If a single integer is given,
            %               all regions of interest will be given the same
            %               Group ID. If a list is given, it must be the
            %               same length as the number of ROIs for which
            %               features are being extracted. These  Group IDs
            %               will be assigned to their corresponding ROIs
            %   'SubGroupIds': (Optional) Must be a list of integers the
            %                  same length as the number of ROIs. They will
            %                  be assigned to their corresponding ROIs. If
            %                  no value is given, Sub-Group IDs will be
            %                  automatically assigned from 1 to n for each 
            %                  Group ID, where n is the number each Group
            %                  ID appears. 
            %  'UserDefinedSampleStrings': (Optional) This value can either
            %                              be a single string or an array
            %                              of strings. If a single string
            %                              is given, all ROIs will be given
            %                              the same sample string. If an
            %                              array is given, they will be
            %                              applied to each corresponding
            %                              ROI. If no value is given, the
            %                              sample string will be defaulted
            %                              to "X-Y", where X is the
            %                              sample's Group ID, and Y is the
            %                              Sub-Group ID
            % 'SampleOrder': (Optional) This is a vector of Region of
            %                    Interest numbers (see "RegionsOfInterest")
            %                    that specify in which order the regions of
            %                    interest will have their features
            %                    extracted. This also allows for ROIs
            %                    within the ImageVolume to be excluded from
            %                    having features extracted. **NOTE** This
            %                    vector also determines with
            %                    Group/Sub-Group IDs are linked up with
            %                    each sample. E.g if 'SampleOrder' =
            %                    [4,3,1] and 'GroupIds' = [6,7,8], then ROI
            %                    #4 in the ImageVolume object will be
            %                    assigned Group ID 6, ROI #3 will be ID 7,
            %                    and ROI #1 will be ID 8. ROI #2 will not
            %                    be processed.
            %                    If this value is not specified, the
            %                    default behaviour will be to extract
            %                    features for all ROIs within the
            %                    ImageVolume, in order.
            % 'ImageInterpretation': (Optional) Values: '2D' or '3D'
            %                        This allows for image volume with a
            %                        third (slice) dimension of 1 to be
            %                        interpreted as a 2D image (e.g. with a
            %                        thickness of 0). This effects which
            %                        features can be extracted for the
            %                        image volume. **NOTE** Image volumes
            %                        with a third dimensions >1 CAN ONLY be
            %                        interpreted as a 3D image. If the third
            %                        dimension is 1, the image can be interpretted
            %                        as either 2D or 3D. If no value is
            %                        given the default is to interpret all
            %                        images as 3D.
            %
            %
            % DESCRIPTION:
            %  Constructor for ImageVolumeHandler
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                oImageVolume (1,1) ImageVolume {MustHaveRegionsOfInterest(oImageVolume)}
                sImageSource (1,1) string {mustBeNonempty}
                NameValueArgs.SampleOrder (:,1) double {mustBeInteger, ValidationUtils.MustContainUniqueValues} = []
                NameValueArgs.GroupIds (1,:) {ValidationUtils.MustBeIntegerClass} = int8([])
                NameValueArgs.SubGroupIds (1,:) {ValidationUtils.MustBeIntegerClass} = int8([])
                NameValueArgs.UserDefinedSampleStrings (1,:) string = string([])
                NameValueArgs.ImageInterpretation (1,:) char {mustBeMember(NameValueArgs.ImageInterpretation, {'2D','3D'})} = '3D'
                NameValueArgs.SetRepresentativeFieldsOfView (1,1) logical = true
            end
                        
            % Get name value pair values
            viGroupIds = NameValueArgs.GroupIds;
            viSubGroupIds = NameValueArgs.SubGroupIds;
            vsUserDefinedSampleStrings = NameValueArgs.UserDefinedSampleStrings;
            vdSampleOrderRegionOfInterestNumbers = NameValueArgs.SampleOrder;
            
            switch NameValueArgs.ImageInterpretation
                case '2D'
                    bIsInterpretedAs2DImage = true;
                case '3D'
                    bIsInterpretedAs2DImage = false;
            end
            
            % Validation and setting of empty values
            if isempty(viGroupIds)
                error(...
                    'ImageVolumeHandler:Constructor:GroupIdsMustBeDefinied',...
                    'The name-value pair ''GroupIds'' must be defined.');
            end
            
            oImageVolume = copy(oImageVolume);
            oImageVolume.ReassignFirstVoxelToAlignWithRASCoordinateSystem();
            
            FeatureExtractionImageVolumeHandler.ValidateRASImageVolume(oImageVolume);
            FeatureExtractionImageVolumeHandler.ValidateExtractionOrderRegionOfInterestNumbers(vdSampleOrderRegionOfInterestNumbers, oImageVolume);
            
            if isempty(vdSampleOrderRegionOfInterestNumbers)
                dNumRois = oImageVolume.GetNumberOfRegionsOfInterest();
            else
                dNumRois = length(vdSampleOrderRegionOfInterestNumbers);
            end 
            
            if numel(viGroupIds) == 1
                viGroupIds = repmat(viGroupIds, dNumRois, 1);
            end   
            
            if isempty(viSubGroupIds)
                viUniqueGroupIds = unique(viGroupIds);
                
                vdCurrentSubGroupIdPerGroupId = ones(length(viUniqueGroupIds),1);
                viSubGroupIds = zeros(length(viGroupIds),1);
                
                for dGroupIdIndex=1:length(viGroupIds)
                    dUniqueGroupIdIndex = find(viUniqueGroupIds == viGroupIds(dGroupIdIndex));
                    
                    viSubGroupIds(dGroupIdIndex) = vdCurrentSubGroupIdPerGroupId(dUniqueGroupIdIndex);
                    vdCurrentSubGroupIdPerGroupId(dUniqueGroupIdIndex) = vdCurrentSubGroupIdPerGroupId(dUniqueGroupIdIndex) + 1;
                end
                
                viSubGroupIds = cast(viSubGroupIds, 'like', viGroupIds);
            end        
                        
            if isempty(vsUserDefinedSampleStrings)
                vsUserDefinedSampleStrings = strcat(...
                    strtrim(string(num2str(viGroupIds))),...
                    "-",...
                    strtrim(string(num2str(viSubGroupIds))));
            end
            
            % Set Properities            
            obj.oRASImageVolume = oImageVolume;
            obj.vdExtractionOrderRegionOfInterestNumbers = vdSampleOrderRegionOfInterestNumbers;
            obj.bIsInterpretedAs2DImage = bIsInterpretedAs2DImage;
            
            obj.sFeatureSource = sImageSource;
            
            obj.viGroupIds = viGroupIds;
            obj.viSubGroupIds = viSubGroupIds;
            obj.vsUserDefinedSampleStrings = vsUserDefinedSampleStrings;
            
            if NameValueArgs.SetRepresentativeFieldsOfView
                bWasVolumeDataLoaded = oImageVolume.IsVolumeDataLoaded();
                
                if isa(oImageVolume.GetRegionsOfInterest(), 'LabelMapRegionsOfInterest')
                    if isempty(vdSampleOrderRegionOfInterestNumbers)
                        vdSampleOrderRegionOfInterestNumbers = 1:obj.oRASImageVolume.GetNumberOfRegionsOfInterest();
                    end
                    
                    obj.oRegionsOfInterestRepresentativeFieldsOfView = LabelMapRegionsOfInterestFieldsOfView(oImageVolume, vdSampleOrderRegionOfInterestNumbers);
                elseif isa(oImageVolume.GetRegionsOfInterest(), 'ParametricRegionsOfInterest')
                    obj.oRegionsOfInterestRepresentativeFieldsOfView = ParametricRegionsOfInterestFieldsOfView(oImageVolume);
                else
                    error(...
                        'FeatureExtractionImageVolumeHandler:Constructor:InvalidRegionsOfInterestType',...
                        'The regions of interest objects within oImageVolume must of type "LabelMapRegionsOfInterest" of "ParametricRegionsOfInterest".');
                end
                
                if ~bWasVolumeDataLoaded
                    obj.oRASImageVolume.UnloadVolumeData();
                end
            end
        end
        
        function SetImageDataDisplayThresholdForAllRepresentativeFieldsOfView(obj, vdDisplayThreshold)
            obj.oRegionsOfInterestRepresentativeFieldsOfView.SetImageDataDisplayThresholdForAllRepresentativeFieldsOfView(vdDisplayThreshold);
        end
        
        function SetMatFilePathOfRASImageVolume(obj, chNewMatFilePath)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler
                chNewMatFilePath (1,:) char
            end
            
            obj.oRASImageVolume.SetMatFilePath(chNewMatFilePath);
        end
        
        function SetMatFilePathOfRASRegionsOfInterest(obj, chNewMatFilePath)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler
                chNewMatFilePath (1,:) char
            end
            
            obj.oRASImageVolume.GetRegionsOfInterest().SetMatFilePath(chNewMatFilePath);
        end
        
        function ClearCache(obj)
            % GLCM cache:
            obj.bCurrentRegionOfInterestGLCMCacheSet = false;
            obj.bCurrentRegionOfInterestBinOnTheFlyGLCM = [];
            
            obj.c1m2dCurrentRegionOfInterestCachedGLCMs = {};
            obj.vdCurrentRegionOfInterestCachedGLCMsOffsetNumbers = [];
            
            % GLRLM cache:
            obj.bCurrentRegionOfInterestGLRLMCacheSet = false;
            obj.bCurrentRegionOfInterestBinOnTheFlyGLRLM = [];
            
            obj.c1m2dCurrentRegionOfInterestCachedGLRLMs = {};
            obj.vdCurrentRegionOfInterestCachedGLRLMsOffsetNumbers = [];
            
            % Shape & Size cache:
            obj.bCurrentRegionOfInterestShapeAndSizeCacheSet = false;
            
            obj.dCurrentRegionOfInterestCachedPerimeter_mm = [];
            obj.dCurrentRegionOfInterestCachedArea_mm2 = [];
            obj.dCurrentRegionOfInterestCachedSurfaceArea_mm2 = [];
            obj.dCurrentRegionOfInterestCachedVolume_mm3 = [];
            obj.dCurrentRegionOfInterestCachedMaxDiameter_mm = [];
            obj.vdCurrentRegionOfInterestCachedRadialLengths_mm = [];
            obj.dCurrentRegionOfInterestRecist_mm = [];
            obj.dCurrentRegionOfInterestSagittalRecist_mm = [];
            obj.dCurrentRegionOfInterestCoronalRecist_mm = [];
            obj.dCurrentRegionOfInterestAxialRecist_mm = [];
            obj.dCurrentRegionOfInterestPcaLambdaLeast = [];
            obj.dCurrentRegionOfInterestPcaLambdaMinor = [];
            obj.dCurrentRegionOfInterestPcaLambdaMajor = [];
            
            % Image/Mask cache:
            obj.bCurrentRegionOfInterestImageAndMaskCacheSet = false;
            obj.bCurrentRegionOfInterestImageAndMaskCacheSetIsMinimallyBounded = [];
            
            obj.m3xCurrentRegionOfInterestCachedImage = [];
            obj.m3bCurrentRegionOfInterestCachedMask = [];
            
            obj.vdCurrentRegionOfInterestImageAndMaskCacheMinimalRowBounds = [];
            obj.vdCurrentRegionOfInterestImageAndMaskCacheMinimalColumnBounds = [];
            obj.vdCurrentRegionOfInterestImageAndMaskCacheMinimalSliceBounds = [];
        end
        
        function LoadVolumeData(obj)
            obj.oRASImageVolume.LoadVolumeData();
        end
        
        function UnloadVolumeData(obj)
            obj.oRASImageVolume.UnloadVolumeData();
        end
        
        function MustBeValidExtractionIndex(obj, dExtractionIndex)
            arguments
                obj
                dExtractionIndex (1,1) double {mustBePositive, mustBeInteger}
            end
            
            if dExtractionIndex > obj.GetNumberOfRegionsOfInterest()
                error(...
                    'FeatureExtractionImageVolumeHandler:MustBeValidExtractionIndex:Invalid',...
                    'The extraction index must not be greater than the number of regions of interest within the handler.');
            end
        end
        
        function RenderRepresentativeImageOnAxesByExtractionIndex(obj, hAxes, dExtractionIndex, NameValueArgs)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler
                hAxes (1,1) {ValidationUtils.MustBeAxes}
                dExtractionIndex (1,1) double {MustBeValidExtractionIndex(obj, dExtractionIndex)}
                NameValueArgs.ForceImagingPlaneType ImagingPlaneTypes {ValidationUtils.MustBeEmptyOrScalar} = ImagingPlaneTypes.empty
                NameValueArgs.ShowAllRegionsOfInterest (1,1) logical = true
                NameValueArgs.LineWidth (1,1) double {mustBePositive} = 1
                NameValueArgs.RegionOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [1 0 0] % red
                NameValueArgs.OtherRegionsOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [0 0.4 1] % blue 
                NameValueArgs.SetImageDataDisplayThreshold (1,2) double {mustBeFinite, ValidationUtils.MustBeIncreasing}
            end
            
            oImagePlaneAxes = ImagingPlaneAxes(hAxes);
            
            chCurUnits = hAxes.Units;
            
            hAxes.Units = 'pixels';
            
            vdPosition = hAxes.Position;
            
            oFov = ImageVolumeFieldOfView2D([0 0], vdPosition(4), vdPosition(3));
            oImagePlaneAxes.SetFieldOfView(oFov);
            
            hAxes.Units = chCurUnits;
            
            
            
            if isempty(obj.oRegionsOfInterestRepresentativeFieldsOfView) % hasn't been set yet, so default it
                obj.oRegionsOfInterestRepresentativeFieldsOfView = LabelMapRegionsOfInterestFieldsOfView(obj.oRASImageVolume, obj.vdExtractionOrderRegionOfInterestNumbers);
            end
            
            if isfield(NameValueArgs, 'SetImageDataDisplayThreshold')
                obj.SetImageDataDisplayThresholdForAllRepresentativeFieldsOfView(NameValueArgs.SetImageDataDisplayThreshold);
                NameValueArgs = rmfield(NameValueArgs, 'SetImageDataDisplayThreshold');
            end
            
            varargin = namedargs2cell(NameValueArgs);
            
            obj.oRegionsOfInterestRepresentativeFieldsOfView.RenderFieldOfViewOnAxesByExtractionIndex(...
                oImagePlaneAxes, dExtractionIndex,...
                varargin{:});
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function oRASImageVolume = GetRASImageVolume(obj)
            oRASImageVolume = obj.oRASImageVolume;
        end
        
        function sFeatureSource = GetFeatureSource(obj)
            sFeatureSource = obj.sFeatureSource;
        end
        
        function bIsInterpretedAs2DImage = IsInterpretedAs2DImage(obj)
            bIsInterpretedAs2DImage = obj.bIsInterpretedAs2DImage;
        end
        
        
        % >>>>>>>>>>>>>>>>>> REGIONS OF INTERESTS (ROIs) <<<<<<<<<<<<<<<<<<
        
        function dRoiNumber = GetRegionOfInterestNumberFromExtractionIndex(obj, dRegionOfInterestExtractionIndex)
            if isempty(obj.vdExtractionOrderRegionOfInterestNumbers)
                dRoiNumber = dRegionOfInterestExtractionIndex;
            else
                dRoiNumber = obj.vdExtractionOrderRegionOfInterestNumbers(dRegionOfInterestExtractionIndex);
            end
        end
        
        function vdRoiNumbers = GetRegionOfInterestNumbersInExtractionOrder(obj)
            if isempty(obj.vdExtractionOrderRegionOfInterestNumbers)
                vdRoiNumbers = transpose(1:obj.oRASImageVolume.GetNumberOfRegionsOfInterest());
            else
                vdRoiNumbers = obj.vdExtractionOrderRegionOfInterestNumbers;
            end
        end
        
        function oFieldOfView3D = GetRepresentativeFieldsOfViewForExtractionIndex(obj, dExtractionIndex)
            oFieldOfView3D = obj.oRegionsOfInterestRepresentativeFieldsOfView.GetFieldOfViewByExtractionIndex(dExtractionIndex);
        end
        
        function SetRepresentativeFieldsOfViewForExtractionIndex(obj, dExtractionIndex, oFieldOfView3D)
            obj.oRegionsOfInterestRepresentativeFieldsOfView.SetFieldOfViewByExtractionIndex(dExtractionIndex, oFieldOfView3D);
        end
        
        function ResetCurrentRegionOfInterestExtractionIndex(obj)
            obj.SetCurrentRegionOfInterestExtractionIndex(1);
        end
        
        function IncrementCurrentRegionOfInterestExtractionIndex(obj)
            obj.SetCurrentRegionOfInterestExtractionIndex(...
                obj.dCurrentRegionOfInterestExtractionIndex + 1);
        end
        
        function SetCurrentRegionOfInterestExtractionIndex(obj, dIndex)
            if ~isscalar(dIndex) || ~isa(dIndex, 'double') || round(dIndex) ~= dIndex || dIndex < 1 || dIndex > obj.GetNumberOfRegionsOfInterest()
                error(...
                    'FeatureExtractionImageVolumeHandler:SetCurrentRegionOfInterestExtractionIndex:Invalid',...
                    'The new index must a scalar of type double containing an integer value between 1 and the number of regions of interest (inclusive).');
            end
            
            obj.dCurrentRegionOfInterestExtractionIndex = dIndex;
            obj.ClearCache();
        end
        
        function dNumRegionsOfInterest = GetNumberOfRegionsOfInterest(obj)
            if isempty(obj.vdExtractionOrderRegionOfInterestNumbers)
                dNumRegionsOfInterest = obj.oRASImageVolume.GetNumberOfRegionsOfInterest();
            else
                dNumRegionsOfInterest = length(obj.vdExtractionOrderRegionOfInterestNumbers);
            end
        end
        
        function vdRegionOfInterestNumbers = GetRegionsOfInterestNumbersInOrderOfExtraction(obj)
            dTotalNumRois = obj.oRASImageVolume.GetNumberOfRegionsOfInterest();
            
            if isempty(obj.vdExtractionOrderRegionOfInterestNumbers)
                vdRegionOfInterestNumbers = 1:dTotalNumRois;
            else
                vdRegionOfInterestNumbers = 1:dTotalNumRois;
                vdRegionOfInterestNumbers = vdRegionOfInterestNumbers(obj.vdExtractionOrderRegionOfInterestNumbers);
            end
        end
        
        function dRegionOfInterestNumber = GetRegionOfInterestNumberBySampleIndex(obj, dSampleIndex)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler
                dSampleIndex (1,1) double {MustBeValidSampleIndex(obj, dSampleIndex)}
            end
            
            if isempty(obj.vdExtractionOrderRegionOfInterestNumbers)
                dRegionOfInterestNumber = dSampleIndex;
            else
                dRegionOfInterestNumber = obj.vdExtractionOrderRegionOfInterestNumbers(dSampleIndex);
            end
        end
        
        function [iGroupId, iSubGroupId] = GetGroupAndSubGroupIdBySampleIndex(obj, dSampleIndex)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler
                dSampleIndex (1,1) double {MustBeValidSampleIndex(obj, dSampleIndex)}
            end
            
            iGroupId = obj.viGroupIds(dSampleIndex);
            iSubGroupId = obj.viSubGroupIds(dSampleIndex);
        end
        
        function viGroupIds = GetRegionsOfInterestGroupIds(obj)
            viGroupIds = obj.viGroupIds;
        end
        
        function viSubGroupIds = GetRegionsOfInterestSubGroupIds(obj)
            viSubGroupIds = obj.viSubGroupIds;
        end
        
        function vsUserDefinedSampleStrings = GetRegionsOfInterestUserDefinedSampleStrings(obj)
            vsUserDefinedSampleStrings = obj.vsUserDefinedSampleStrings;
        end
        
        function sUserDefinedSampleString = GetUserDefinedSampleStringByExtractionIndex(obj, dExtractionIndex)
            sUserDefinedSampleString = obj.vsUserDefinedSampleStrings(dExtractionIndex);
        end
        
        function m3xImageData = GetFullImageData(obj)
            m3xImageData = obj.oRASImageVolume.GetImageData();
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> IMAGE/MASK CACHING <<<<<<<<<<<<<<<<<<<<
                
        function [m3xImageData, m3bMask] = GetCurrentRegionOfInterestImageDataAndMask(obj, oFeatureExtractionParameters)
            arguments
                obj
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestImageAndMaskCache(oFeatureExtractionParameters);
                        
            m3bMask = obj.m3bCurrentRegionOfInterestCachedMask;
            
            if ~obj.bCurrentRegionOfInterestImageAndMaskCacheSetIsMinimallyBounded
                m3xImageData = obj.oRASImageVolume.GetImageData();
            else
                m3xImageData = obj.m3xCurrentRegionOfInterestCachedImage;
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>> GLCM CACHING <<<<<<<<<<<<<<<<<<<<<<<
        
        function [c1m2dGLCMs, vdOffsetNumbers] = GetCurrentRegionOfInterestGLCMs(obj, oFeatureExtractionParameters)
            arguments
                obj
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestGLCMCache(oFeatureExtractionParameters);
            
            c1m2dGLCMs = obj.c1m2dCurrentRegionOfInterestCachedGLCMs;
            vdOffsetNumbers = obj.vdCurrentRegionOfInterestCachedGLCMsOffsetNumbers;
            
            if any(vdOffsetNumbers ~= oFeatureExtractionParameters.GetGLCMOffsetNumbers())
                error(...
                    'FeatureExtractionImageVolumeHandler:GetCurrentRegionOfInterestGLCMs:CachedAndRequestedGLCMOffsetsMismatch',...
                    'The cached GLCM offsets do not agree with those requested from the feature extraction parameters.');
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>> GLRLM CACHING <<<<<<<<<<<<<<<<<<<<<<<
        
        function [c1m2dGLRLMs, vdOffsetNumbers] = GetCurrentRegionOfInterestGLRLMs(obj, oFeatureExtractionParameters)
            arguments
                obj
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestGLRLMCache(oFeatureExtractionParameters);
            
            c1m2dGLRLMs = obj.c1m2dCurrentRegionOfInterestCachedGLRLMs;
            vdOffsetNumbers = obj.vdCurrentRegionOfInterestCachedGLRLMsOffsetNumbers;
            
            if any(vdOffsetNumbers ~= oFeatureExtractionParameters.GetGLRLMOffsetNumbers())
                error(...
                    'FeatureExtractionImageVolumeHandler:GetCurrentRegionOfInterestGLRLMs:CachedAndRequestedGLRLMOffsetsMismatch',...
                    'The cached GLRLM offsets do not agree with those requested from the feature extraction parameters.');
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>> SHAPE & SIZE CACHING <<<<<<<<<<<<<<<<<<<<<<<
        
        function dPerimeter_mm = GetCurrentRegionOfInterestPerimeter_mm(obj, oFeatureExtractionParameters)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler {MustBeInterpretedAs2DImage(obj)}
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dPerimeter_mm = obj.dCurrentRegionOfInterestCachedPerimeter_mm;
        end
        
        function dArea_mm2 = GetCurrentRegionOfInterestArea_mm2(obj, oFeatureExtractionParameters)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler {MustBeInterpretedAs2DImage(obj)}
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dArea_mm2 = obj.dCurrentRegionOfInterestCachedArea_mm2;
        end
        
        function dSurfaceArea_mm2 = GetCurrentRegionOfInterestSurfaceArea_mm2(obj, oFeatureExtractionParameters)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler {MustBeInterpretedAs3DImage(obj)}
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dSurfaceArea_mm2 = obj.dCurrentRegionOfInterestCachedSurfaceArea_mm2;
        end
        
        function dVolume_mm3 = GetCurrentRegionOfInterestVolume_mm3(obj, oFeatureExtractionParameters)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler {MustBeInterpretedAs3DImage(obj)}
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dVolume_mm3 = obj.dCurrentRegionOfInterestCachedVolume_mm3;
        end
        
        function dMaxDiameter_mm = GetCurrentRegionOfInterestMaxDiameter_mm(obj, oFeatureExtractionParameters)
            arguments
                obj
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dMaxDiameter_mm = obj.dCurrentRegionOfInterestCachedMaxDiameter_mm;
        end
        
        function vdRadialLengths_mm = GetCurrentRegionOfInterestRadialLengths_mm(obj, oFeatureExtractionParameters)
            arguments
                obj
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            vdRadialLengths_mm = obj.vdCurrentRegionOfInterestCachedRadialLengths_mm;
        end
        
        function dRecist_mm = GetCurrentRegionOfInterestRecist_mm(obj, oFeatureExtractionParameters)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler {MustBeInterpretedAs2DImage(obj)}
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dRecist_mm = obj.dCurrentRegionOfInterestRecist_mm;
        end
        
        function dSagittalRecist_mm = GetCurrentRegionOfInterestSagittalRecist_mm(obj, oFeatureExtractionParameters)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler {MustBeInterpretedAs3DImage(obj)}
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dSagittalRecist_mm = obj.dCurrentRegionOfInterestSagittalRecist_mm;
        end
        
        function dCoronalRecist_mm = GetCurrentRegionOfInterestCoronalRecist_mm(obj, oFeatureExtractionParameters)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler {MustBeInterpretedAs3DImage(obj)}
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dCoronalRecist_mm = obj.dCurrentRegionOfInterestCoronalRecist_mm;
        end
        
        function dAxialRecist_mm = GetCurrentRegionOfInterestAxialRecist_mm(obj, oFeatureExtractionParameters)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler {MustBeInterpretedAs3DImage(obj)}
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dAxialRecist_mm = obj.dCurrentRegionOfInterestAxialRecist_mm;
        end
        
        function dPcaLambdaLeast = GetCurrentRegionOfInterestPrincipalComponentAnalysisLambdaLeast(obj, oFeatureExtractionParameters)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler {MustBeInterpretedAs3DImage(obj)}
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dPcaLambdaLeast = obj.dCurrentRegionOfInterestPcaLambdaLeast;
        end
        
        function dPcaLambdaMinor = GetCurrentRegionOfInterestPrincipalComponentAnalysisLambdaMinor(obj, oFeatureExtractionParameters)
            arguments
                obj
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dPcaLambdaMinor = obj.dCurrentRegionOfInterestPcaLambdaMinor;
        end
        
        function dPcaLambdaMajor = GetCurrentRegionOfInterestPrincipalComponentAnalysisLambdaMajor(obj, oFeatureExtractionParameters)
            arguments
                obj
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
            end
            
            obj.SetCurrentRegionOfInterestShapeAndSizeCache(oFeatureExtractionParameters);
            
            dPcaLambdaMajor = obj.dCurrentRegionOfInterestPcaLambdaMajor;
        end
    end
    
    
    methods (Access = public, Static = true)
         
        function hFig = CreateCollageOfRepresentativeFieldsOfView(voImageVolumeHandlers, vdGridDimensions, NameValueArgs)
            arguments
                voImageVolumeHandlers (1,:) FeatureExtractionImageVolumeHandler
                vdGridDimensions (1,2) double {mustBePositive, mustBeInteger}
                NameValueArgs.DimensionUnits (1,:) char = 'pixels' % one of 'pixels' | 'normalized' | 'inches' | 'centimeters' | 'points' | 'characters'
                NameValueArgs.TileDimensions (1,2) double {mustBePositive, mustBeFinite} = [200, 200] % px
                NameValueArgs.TilePadding (1,1) double {mustBeNonnegative, mustBeFinite} = 2 % px
                NameValueArgs.TileLabelFontSize (1,1) double {mustBePositive, mustBeFinite} = 10 % px
                NameValueArgs.ShowTileLabels (1,1) logical = true
                NameValueArgs.TileLabelSource (1,:) char {mustBeMember(NameValueArgs.TileLabelSource, {'Id','UserDefinedSampleString','Both'})} = 'Id'
                NameValueArgs.ForceImagingPlaneType ImagingPlaneTypes {ValidationUtils.MustBeEmptyOrScalar} = ImagingPlaneTypes.empty
                NameValueArgs.ShowAllRegionsOfInterest (1,1) logical = true
                NameValueArgs.LineWidth (1,1) double {mustBePositive} = 1
                NameValueArgs.RegionOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [1 0 0] % red
                NameValueArgs.OtherRegionsOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [0 0.8 1] % blue        
                NameValueArgs.ExtractionIndicesPerHandler (1,:) cell = {} % cell array of double vectors that contain the extraction indices for each handler
                NameValueArgs.SetImageDataDisplayThreshold (1,2) double {mustBeFinite, ValidationUtils.MustBeIncreasing}
                NameValueArgs.DisplayOrderGroupIds (:,1) double {mustBeInteger}
                NameValueArgs.DisplayOrderSubGroupIds (:,1) double {mustBeInteger}
                NameValueArgs.TilesToHighlight (:,1) logical
                NameValueArgs.HighlightColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [0 1 0] % green
                NameValueArgs.TileOutlineColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [1 1 1] % white
                NameValueArgs.CustomLabels (:,1) string
            end
            
            c1vdExtractionIndicesPerHandler = NameValueArgs.ExtractionIndicesPerHandler;
            
            dNumHandlers = length(voImageVolumeHandlers);
            
            if isempty(c1vdExtractionIndicesPerHandler)
                if isfield(NameValueArgs, 'DisplayOrderGroupIds') && isfield(NameValueArgs, 'DisplayOrderSubGroupIds')
                    dNumRois = length(NameValueArgs.DisplayOrderGroupIds);
                    
                    vdNewHandlerIndices = zeros(1,dNumRois);
                    c1vdExtractionIndicesPerHandler = cell(1,dNumRois);
                    
                    for dRoiIndex=1:dNumRois
                        dGroupId = NameValueArgs.DisplayOrderGroupIds(dRoiIndex);
                        dSubGroupId = NameValueArgs.DisplayOrderSubGroupIds(dRoiIndex);
                        
                        dHandlerIndexMatch = [];
                        dExtractionIndexMatch = [];
                        
                        for dHandlerSearchIndex=1:dNumHandlers
                            oHandler = voImageVolumeHandlers(dHandlerSearchIndex);
                            
                            dMatchIndex = find(oHandler.viGroupIds == dGroupId & oHandler.viSubGroupIds == dSubGroupId);
                            
                            if ~isempty(dMatchIndex)
                                dHandlerIndexMatch = dHandlerSearchIndex;
                                dExtractionIndexMatch = dMatchIndex;
                                
                                break;
                            end
                        end
                        
                        if isempty(dHandlerIndexMatch) || isempty(dExtractionIndexMatch)
                            error(...
                                'FeatureExtractionImageVolumeHandler:CreateCollageOfRepresentativeFieldsOfView:NoMatchForGroupAndSubGroupId',...
                                'No match found in handler list for the given Group and Sub-Group ID.');
                        else
                            vdNewHandlerIndices(dRoiIndex) = dHandlerIndexMatch;
                            c1vdExtractionIndicesPerHandler{dRoiIndex} = dExtractionIndexMatch;
                        end
                    end
                    
                    voImageVolumeHandlers = voImageVolumeHandlers(vdNewHandlerIndices);
                else                
                    dNumRois = 0;
                    
                    c1vdExtractionIndicesPerHandler = cell(1,dNumHandlers);
                    
                    for dHandlerIndex=1:dNumHandlers
                        dNumRois = dNumRois + voImageVolumeHandlers(dHandlerIndex).GetNumberOfRegionsOfInterest();
                        c1vdExtractionIndicesPerHandler{dHandlerIndex} = 1:voImageVolumeHandlers(dHandlerIndex).GetNumberOfRegionsOfInterest();
                    end
                end
            else
                dNumRois = 0;
                
                for dHandlerIndex=1:dNumHandlers
                    dNumRois = dNumRois + length(c1vdExtractionIndicesPerHandler{dHandlerIndex});
                end
            end
            
            
            dNumGridRows = vdGridDimensions(1);
            dNumGridCols = vdGridDimensions(2);
            
            if dNumRois > dNumGridRows * dNumGridCols
                error(...
                    'FeatureExtractionImageVolumeHandler:CreateMontageOfRepresentativeFieldsOfView:InvalidGridSize',...
                    'The given grid size cannot fit the number of images provided.');
            end
            
            dTileHeight = NameValueArgs.TileDimensions(1);
            dTileWidth = NameValueArgs.TileDimensions(2);
            
            dPadding = NameValueArgs.TilePadding;
            
            dFigureWidth = dNumGridCols*(dTileWidth+dPadding) + dPadding;
            dFigureHeight = dNumGridRows*(dTileHeight+dPadding+NameValueArgs.ShowTileLabels*NameValueArgs.TileLabelFontSize) + dPadding;
            
            % create figure to hold the montage
            hFig = figure('Color', [0 0 0],'Resize', 'off');
            
            % set units in figure
            hFig.Units = NameValueArgs.DimensionUnits;
            
            % adjust width and height of figure
            vdCurrentPosition = hFig.Position;
            
            dFigTop = vdCurrentPosition(2) + vdCurrentPosition(4);
            
            vdCurrentPosition(2) = dFigTop - dFigureHeight; 
            vdCurrentPosition(3) = dFigureWidth;
            vdCurrentPosition(4) = dFigureHeight;
            
            hFig.Position = vdCurrentPosition;
            
            % subplot works with normalized units...why me?
            % so everything needs to be divided by the total figure width
            % and height
            
            dNormalizedTileHeight = dTileHeight / dFigureHeight;
            dNormalizedTileWidth = dTileWidth / dFigureWidth;
            
            dNormalizedVerticalPadding = dPadding / dFigureHeight;
            dNormalizedHorizontalPadding = dPadding / dFigureWidth;
            
            dNormalizedVerticalSpaceBetweenTiles = (NameValueArgs.ShowTileLabels*NameValueArgs.TileLabelFontSize + dPadding) / dFigureHeight;
           
            dNormalizedFontSize = NameValueArgs.TileLabelFontSize / dFigureHeight;
                        
            dRowIndex = 1;
            dColIndex = 1;
            
            dHandlerIndex = 1;
            dExtractionIndicesIndex = 1;
            oCurrentHandler = voImageVolumeHandlers(1);
            bVolumeDataWasAlreadyLoaded = oCurrentHandler.GetRASImageVolume().IsVolumeDataLoaded();
            vdExtractionIndices = c1vdExtractionIndicesPerHandler{1};
            
            for dImageIndex=1:dNumRois
                % create sub-plot for image to be rendered in
                dNormalizedAxesBottomLeftX = dNormalizedHorizontalPadding + (dColIndex - 1) * (dNormalizedTileWidth + dNormalizedHorizontalPadding);
                dNormalizedAxesBottomLeftY = 1 - (dNormalizedVerticalPadding + dNormalizedTileHeight) - (dRowIndex - 1) * (dNormalizedTileHeight + dNormalizedVerticalSpaceBetweenTiles);
                
                hAxes = subplot(...
                    'Position', [...
                    dNormalizedAxesBottomLeftX,...
                    dNormalizedAxesBottomLeftY,...
                    dNormalizedTileWidth,...
                    dNormalizedTileHeight]);
                
                % call image volume to do the render
                if isfield(NameValueArgs, 'SetImageDataDisplayThreshold')
                    c1xVarargin = {'SetImageDataDisplayThreshold', NameValueArgs.SetImageDataDisplayThreshold};
                else
                    c1xVarargin = {};
                end
                
                oCurrentHandler.RenderRepresentativeImageOnAxesByExtractionIndex(...
                    hAxes,...
                    vdExtractionIndices(dExtractionIndicesIndex),...
                    'ForceImagingPlaneType', NameValueArgs.ForceImagingPlaneType,...
                    'ShowAllRegionsOfInterest', NameValueArgs.ShowAllRegionsOfInterest,...
                    'LineWidth', NameValueArgs.LineWidth,...
                    'RegionOfInterestColour', NameValueArgs.RegionOfInterestColour,...
                    'OtherRegionsOfInterestColour', NameValueArgs.OtherRegionsOfInterestColour,...
                    c1xVarargin{:});
                
                % change units to pixels
                hAxes.Units = 'pixels';
                
                % turn box on
                axis(hAxes, 'on');
                hAxes.Box = 'on';
                
                if isfield(NameValueArgs, 'TilesToHighlight') && NameValueArgs.TilesToHighlight(dImageIndex)
                    hAxes.XColor = NameValueArgs.HighlightColour;
                    hAxes.YColor = NameValueArgs.HighlightColour;
                else
                    hAxes.XColor = NameValueArgs.TileOutlineColour ;
                    hAxes.YColor = NameValueArgs.TileOutlineColour ;
                end
                
                
                hAxes.LineWidth = 2.5;
                xticks(hAxes, []);
                yticks(hAxes, []);
                
                % render the image label
                if NameValueArgs.ShowTileLabels
                    if isfield(NameValueArgs, 'CustomLabels')
                        chLabel = char(NameValueArgs.CustomLabels(dImageIndex));
                    else
                        if strcmp(NameValueArgs.TileLabelSource, 'Id')
                            iGroupId = oCurrentHandler.viGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                            iSubGroupId = oCurrentHandler.viSubGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                            
                            chLabel = [num2str(iGroupId), '-', num2str(iSubGroupId)];
                        elseif strcmp(NameValueArgs.TileLabelSource, 'UserDefinedSampleString')
                            chLabel = char(oCurrentHandler.vsUserDefinedSampleStrings(vdExtractionIndices(dExtractionIndicesIndex)));
                        else
                            iGroupId = oCurrentHandler.viGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                            iSubGroupId = oCurrentHandler.viSubGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                            
                            chSampleString = char(oCurrentHandler.vsUserDefinedSampleStrings(vdExtractionIndices(dExtractionIndicesIndex)));
                            
                            chLabel = [num2str(iGroupId), '-', num2str(iSubGroupId), ' (', chSampleString, ')'];
                        end
                    end
                    
                    vdAxesPosition = hAxes.Position;
                    dAxesWidth = vdAxesPosition(3);
                    
                    hText = text(...
                        hAxes,...
                        dAxesWidth/2, 0,...
                        chLabel,...
                        'Units', 'pixels',...
                        'Color', [1 1 1],...
                        'Margin', eps,...
                        'FontSize', NameValueArgs.TileLabelFontSize,...
                        'FontUnits', NameValueArgs.DimensionUnits,...
                        'HorizontalAlignment', 'center',...
                        'VerticalAlignment', 'middle');
                    
                    hText.FontUnits = 'pixels';
                    
                    dFontSizePixels = hText.FontSize;
                    
                    vdCurrentTextPosition = hText.Position;
                    vdCurrentTextPosition(2) = (-dFontSizePixels/2) + 1;
                    hText.Position = vdCurrentTextPosition;
                end
                

                % increment handler/extraction index
                if dExtractionIndicesIndex < length(vdExtractionIndices)
                    dExtractionIndicesIndex = dExtractionIndicesIndex + 1;
                elseif dImageIndex ~= dNumRois
                    if ~bVolumeDataWasAlreadyLoaded 
                        oCurrentHandler.GetRASImageVolume().UnloadVolumeData();
                    end
                        
                    dHandlerIndex = dHandlerIndex + 1;
                    oCurrentHandler = voImageVolumeHandlers(dHandlerIndex);
                    bVolumeDataWasAlreadyLoaded = oCurrentHandler.GetRASImageVolume().IsVolumeDataLoaded();
                    vdExtractionIndices = c1vdExtractionIndicesPerHandler{dHandlerIndex};
                    dExtractionIndicesIndex = 1;
                end                    
                
                % increment index in montage grid
                if dColIndex == dNumGridCols % jump to next row
                    dColIndex = 1;
                    dRowIndex = dRowIndex + 1;
                else
                    dColIndex = dColIndex + 1; % run along row left to right
                end
            end
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function dCurrentRoiNumber = GetCurrentRegionOfInterestNumber(obj)
            if isempty(obj.vdExtractionOrderRegionOfInterestNumbers)
                dCurrentRoiNumber = obj.dCurrentRegionOfInterestExtractionIndex;
            else
                dCurrentRoiNumber = obj.vdExtractionOrderRegionOfInterestNumbers(obj.dCurrentRegionOfInterestExtractionIndex);
            end
        end
        
        function [vdRowBounds, vdColumnBounds, vdSliceBounds] = GetCurrentRegionOfInterestMinimalBounds(obj)
            [vdRowBounds, vdColumnBounds, vdSliceBounds] = obj.oRASImageVolume.GetRegionsOfInterest().GetMinimalBoundsByRegionOfInterestNumber(...
                obj.GetCurrentRegionOfInterestNumber());
        end
        
        function saveObj = saveobj(obj)
            saveObj = copy(obj);
            
            % don't want to save all the current cached data
            saveObj.ClearCache();
        end
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            
            % local call
            cpObj.oRASImageVolume = copy(obj.oRASImageVolume);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
        
        function MustBeInterpretedAs2DImage(obj)
            if ~obj.bIsInterpretedAs2DImage
                error(...
                    'FeatureExtractionImageVolumeHandler:MustBeInterpretedAs2DImage:Invalid',...
                    'The FeatureExtractionImageVolumeHandler is being interpreted as a 3D image, but must be set to be interpreting the image as 2D.');
            end
        end
        
        function MustBeInterpretedAs3DImage(obj)
            if obj.bIsInterpretedAs2DImage
                error(...
                    'FeatureExtractionImageVolumeHandler:MustBeInterpretedAs3DImage:Invalid',...
                    'The FeatureExtractionImageVolumeHandler is being interpreted as a 2D image, but must be set to be interpreting the image as 3D.');
            end
        end
        
        function MustBeValidSampleIndex(obj, dSampleIndex)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler
                dSampleIndex (1,1) double {mustBeInteger, mustBePositive}
            end
            
            if dSampleIndex > obj.GetNumberOfRegionsOfInterest()
                error(...
                    'FeatureExtractionImageVolumeHandler:MustBeValidSampleIndex:Invalid',...
                    'The sample index must not exceed to the number of regions of interest.');
            end
        end
        
        function SetCurrentRegionOfInterestImageAndMaskCache(obj, oFeatureExtractionParameters)
            if ~obj.bCurrentRegionOfInterestImageAndMaskCacheSet
                m3bMask = obj.oRASImageVolume.GetRegionsOfInterest().GetMaskByRegionOfInterestNumber(obj.GetCurrentRegionOfInterestNumber());
                
                [vdRowBounds, vdColBounds, vdSliceBounds] = ImageVolumeGeometry.GetMinimalBoundsForMask(m3bMask);
                
                [bStoreSubsetMaskAndImage, bBinOnTheFlyGLCM, bBinOnTheFlyGLRLM] = obj.GetMemoryUsageScheme(oFeatureExtractionParameters, vdRowBounds, vdColBounds, vdSliceBounds);
                
                if bStoreSubsetMaskAndImage
                    obj.m3xCurrentRegionOfInterestCachedImage = FeatureExtractionImageVolumeHandler.GetSubsetOfMatrix(obj.oRASImageVolume.GetImageData(), vdRowBounds, vdColBounds, vdSliceBounds);
                    obj.m3bCurrentRegionOfInterestCachedMask = FeatureExtractionImageVolumeHandler.GetSubsetOfMatrix(m3bMask, vdRowBounds, vdColBounds, vdSliceBounds);
                    
                    obj.bCurrentRegionOfInterestImageAndMaskCacheSetIsMinimallyBounded = true;
                else % store the full mask
                    obj.m3xCurrentRegionOfInterestCachedImage = []; % don't need to store, will get from the ImageVolume object as needed
                    obj.m3bCurrentRegionOfInterestCachedMask = m3bMask;
                    
                    obj.bCurrentRegionOfInterestImageAndMaskCacheSetIsMinimallyBounded = false;
                end
                
                obj.vdCurrentRegionOfInterestImageAndMaskCacheMinimalRowBounds = vdRowBounds;
                obj.vdCurrentRegionOfInterestImageAndMaskCacheMinimalColumnBounds = vdColBounds;
                obj.vdCurrentRegionOfInterestImageAndMaskCacheMinimalSliceBounds = vdSliceBounds;
                
                obj.bCurrentRegionOfInterestBinOnTheFlyGLCM = bBinOnTheFlyGLCM;
                obj.bCurrentRegionOfInterestBinOnTheFlyGLRLM = bBinOnTheFlyGLRLM;
                
                obj.bCurrentRegionOfInterestImageAndMaskCacheSet = true;
            end
        end
        
        function SetCurrentRegionOfInterestShapeAndSizeCache(obj, oFeatureExtractionParameters)
            if ~obj.bCurrentRegionOfInterestShapeAndSizeCacheSet
                obj.SetCurrentRegionOfInterestImageAndMaskCache(oFeatureExtractionParameters);
                
                switch obj.bIsInterpretedAs2DImage
                    case true %2D
                        % calculate through ROI object
                        [dPerimeter_mm, dArea_mm2, dMaxDiameter_mm, vdRadialLengths_mm, dRecist_mm, dPcaLambdaMinor, dPcaLambdaMajor] = ...
                            obj.oRASImageVolume.GetRegionsOfInterest().GetGeometricalMeasurementsByRegionOfInterestNumber(...
                            obj.GetCurrentRegionOfInterestNumber(), '2D',...
                            oFeatureExtractionParameters.GetPerimeterMethod().GetCalculationParameter(),...
                            oFeatureExtractionParameters.GetAreaMethod().GetCalculationParameter(),...
                            oFeatureExtractionParameters.GetShapePrinicipalComponentsPoints().GetCalculationParameter());
                        
                        % set to cache
                        obj.dCurrentRegionOfInterestCachedPerimeter_mm = dPerimeter_mm;
                        obj.dCurrentRegionOfInterestCachedArea_mm2 = dArea_mm2;
                        obj.dCurrentRegionOfInterestCachedMaxDiameter_mm = dMaxDiameter_mm;
                        obj.vdCurrentRegionOfInterestCachedRadialLengths_mm = vdRadialLengths_mm;
                        obj.dCurrentRegionOfInterestRecist_mm = dRecist_mm;
                        obj.dCurrentRegionOfInterestPcaLambdaMinor = dPcaLambdaMinor;
                        obj.dCurrentRegionOfInterestPcaLambdaMajor = dPcaLambdaMajor;
                    otherwise %3D
                        % mesh params
                        eInterpMethod = oFeatureExtractionParameters.GetMeshMaskInterpolationMethod();
                        
                        if eInterpMethod == MeshMaskInterpolationOptions.None
                            c1xMeshVarargin = {eInterpMethod.GetCalculationParameter()};
                        else
                            c1xMeshVarargin = {...
                                eInterpMethod.GetCalculationParameter(),...
                                oFeatureExtractionParameters.GetMeshMaskInterpolationVoxelSizeSource().GetCalculationParameter(),...
                                oFeatureExtractionParameters.GetMeshMaskInterpolationVoxelSizeMultiplier()};
                        end
                        
                        % calculate through ROI object
                        [dSurfaceArea_mm2, dVolume_mm3, dMaxDiameter_mm, vdRadialLengths_mm, dSagittalRecist_mm, dCoronalRecist_mm, dAxialRecist_mm, dPcaLambdaLeast, dPcaLambdaMinor, dPcaLambdaMajor]...
                            = obj.oRASImageVolume.GetRegionsOfInterest().GetGeometricalMeasurementsByRegionOfInterestNumber(...
                            obj.GetCurrentRegionOfInterestNumber(), '3D',...
                            oFeatureExtractionParameters.GetSurfaceAreaMethod().GetCalculationParameter(),...
                            oFeatureExtractionParameters.GetVolumeMethod().GetCalculationParameter(),...
                            oFeatureExtractionParameters.GetShapePrinicipalComponentsPoints().GetCalculationParameter(),...
                            c1xMeshVarargin{:});
                        
                        % set to cache
                        obj.dCurrentRegionOfInterestCachedSurfaceArea_mm2 = dSurfaceArea_mm2;
                        obj.dCurrentRegionOfInterestCachedVolume_mm3 = dVolume_mm3;
                        obj.dCurrentRegionOfInterestCachedMaxDiameter_mm = dMaxDiameter_mm;
                        obj.vdCurrentRegionOfInterestCachedRadialLengths_mm = vdRadialLengths_mm;
                        obj.dCurrentRegionOfInterestSagittalRecist_mm = dSagittalRecist_mm;
                        obj.dCurrentRegionOfInterestCoronalRecist_mm = dCoronalRecist_mm;
                        obj.dCurrentRegionOfInterestAxialRecist_mm = dAxialRecist_mm;
                        obj.dCurrentRegionOfInterestPcaLambdaLeast = dPcaLambdaLeast;
                        obj.dCurrentRegionOfInterestPcaLambdaMinor = dPcaLambdaMinor;
                        obj.dCurrentRegionOfInterestPcaLambdaMajor = dPcaLambdaMajor;
                end
                
                obj.bCurrentRegionOfInterestShapeAndSizeCacheSet = true;
            end
        end
        
        function SetCurrentRegionOfInterestGLCMCache(obj, oFeatureExtractionParameters)
            if ~obj.bCurrentRegionOfInterestGLCMCacheSet
                obj.SetCurrentRegionOfInterestImageAndMaskCache(oFeatureExtractionParameters);
                
                m2dOffsetVectors = oFeatureExtractionParameters.GetGLCMOffsetVectors();
                vdOffsetNumbers = oFeatureExtractionParameters.GetGLCMOffsetNumbers();
                
                vdDims = size(m2dOffsetVectors);
                dNumOffsets = vdDims(1);
                
                % check if any offsets are the exact inverse of any others
                % these GLCMs will be the transposes of one another,
                % allowing us to save time
                vdGLCMIsTransposeOfGLCMAtIndex = zeros(dNumOffsets,1);
                
                for dOffsetIndex=dNumOffsets:-1:1
                    for dSearchIndex=1:dOffsetIndex-1
                        if all(m2dOffsetVectors(dOffsetIndex,:) == -m2dOffsetVectors(dSearchIndex,:))
                            vdGLCMIsTransposeOfGLCMAtIndex(dOffsetIndex) = dSearchIndex;
                            break;
                        end
                    end
                end
                
                bCombineAllGLCMOffsets = oFeatureExtractionParameters.GetCombineAllGLCMOffsets();
                
                c1m2dGLCMs = cell(dNumOffsets+bCombineAllGLCMOffsets,1);
                                
                % if the binned image is empty, there wasn't enough memory
                % space to store the binned image, so we'll have to bin on
                % the fly
                bBinOnTheFly = obj.bCurrentRegionOfInterestBinOnTheFlyGLCM;
                
                bNormalize = oFeatureExtractionParameters.GetGLCMNormalize();
                bSymmetric = oFeatureExtractionParameters.GetGLCMSymmetric();
                
                for dOffsetIndex=1:dNumOffsets % iterate through all offsets (not including combining all)
                    if vdGLCMIsTransposeOfGLCMAtIndex(dOffsetIndex) == 0 % has no transpose to rely on, gotta calculate the GLCM
                        
                        if ~bBinOnTheFly
                            [m3iRegionOfInterestBinnedImage, m3bRegionOfInterestBinnedImageMask] =...
                                obj.GetCurrentRegionOfInterestBinnedImageAndMask(...
                                oFeatureExtractionParameters.GetGLCMFirstBinEdge(), oFeatureExtractionParameters.GetGLCMBinSize(),...
                                oFeatureExtractionParameters.GetGLCMNumberOfBins());
                            
                            c1m2dGLCMs{dOffsetIndex} = GLCMFeature.CalculateGLCM(...
                                m3iRegionOfInterestBinnedImage,...
                                m3bRegionOfInterestBinnedImageMask,...
                                m2dOffsetVectors(dOffsetIndex,:),...
                                oFeatureExtractionParameters.GetGLCMNumberOfBins(),...
                                bSymmetric, bNormalize,...
                                bBinOnTheFly);
                            
                        else % bin-on-the-fly
                            % if there is enough RAM, the returned image
                            % and mask will be as small as possible (e.g.
                            % the boundaries will as close to the mask as
                            % possible). If there isn't enough room for
                            % this, the entire image and mask will be
                            % returned (passed by reference by Matlab's
                            % copy-on-write mechanism)
                            [m3xImage, m3bMask] = obj.GetCurrentRegionOfInterestImageDataAndMask(oFeatureExtractionParameters);
                            
                            c1m2dGLCMs{dOffsetIndex} = GLCMFeature.CalculateGLCM(...
                                m3xImage, m3bMask,...
                                m2dOffsetVectors(dOffsetIndex,:),...
                                oFeatureExtractionParameters.GetGLCMNumberOfBins(),...
                                bSymmetric, bNormalize,...
                                bBinOnTheFly,...
                                'FirstBinEdge', oFeatureExtractionParameters.GetGLCMFirstBinEdge(),...
                                'BinSize', oFeatureExtractionParameters.GetGLCMBinSize());
                        end
                    else % use the transpose of the inverse offset GLCM that has already been computed
                        c1m2dGLCMs{dOffsetIndex} = transpose(c1m2dGLCMs{vdGLCMIsTransposeOfGLCMAtIndex(dOffsetIndex)});
                    end
                end
                
                % check if the user also wants to combine all the GLCMs
                if oFeatureExtractionParameters.GetCombineAllGLCMOffsets()
                    m2dCombinedGLCM = zeros(size(c1m2dGLCMs{1}));
                    
                    for dOffsetIndex=1:dNumOffsets
                        m2dCombinedGLCM = m2dCombinedGLCM + c1m2dGLCMs{dOffsetIndex};
                    end
                    
                    if bNormalize
                        m2dCombinedGLCM = m2dCombinedGLCM ./ sum(m2dCombinedGLCM(:));
                    end
                    
                    c1m2dGLCMs{end} = m2dCombinedGLCM;
                end
                
                % set to the cache
                obj.c1m2dCurrentRegionOfInterestCachedGLCMs = c1m2dGLCMs;
                obj.vdCurrentRegionOfInterestCachedGLCMsOffsetNumbers = vdOffsetNumbers;
                
                obj.bCurrentRegionOfInterestGLCMCacheSet = true;
            end
        end
        
        function SetCurrentRegionOfInterestGLRLMCache(obj, oFeatureExtractionParameters)
            if ~obj.bCurrentRegionOfInterestGLRLMCacheSet
                obj.SetCurrentRegionOfInterestImageAndMaskCache(oFeatureExtractionParameters);
                
                m2dOffsetVectors = oFeatureExtractionParameters.GetGLRLMOffsetVectors();
                vdOffsetNumbers = oFeatureExtractionParameters.GetGLRLMOffsetNumbers();
                
                vdDims = size(m2dOffsetVectors);
                dNumOffsets = vdDims(1);
                
                bCombineAllGLCMOffsets = oFeatureExtractionParameters.GetCombineAllGLRLMOffsets();
                
                c1m2dGLRLMs = cell(dNumOffsets+bCombineAllGLCMOffsets,1);
                                
                % if the binned image is empty, there wasn't enough memory
                % space to store the binned image, so we'll have to bin on
                % the fly
                bBinOnTheFly = obj.bCurrentRegionOfInterestBinOnTheFlyGLRLM;
                
                if ~bBinOnTheFly
                    m3iRegionOfInterestBinnedImage =...
                        obj.GetCurrentRegionOfInterestBinnedImageAndMask(...
                        oFeatureExtractionParameters.GetGLRLMFirstBinEdge(), oFeatureExtractionParameters.GetGLRLMBinSize(),...
                        oFeatureExtractionParameters.GetGLRLMNumberOfBins());
                    
                    c1oExtraParams = {m3iRegionOfInterestBinnedImage};
                else
                    c1oExtraParams = {};
                end
                
                [m3xImage, m3bMask] = obj.GetCurrentRegionOfInterestImageDataAndMask(oFeatureExtractionParameters);
                
                dFirstBinEdge = oFeatureExtractionParameters.GetGLRLMFirstBinEdge();
                dBinSize = oFeatureExtractionParameters.GetGLRLMBinSize();
                dNumBins = oFeatureExtractionParameters.GetGLRLMNumberOfBins();
                dEqualityThreshold = oFeatureExtractionParameters.GetGLRLMRunThreshold();
                
                % computed GLRLMs for each offset
                for dOffsetIndex=1:dNumOffsets % iterate through all offsets (not including combining all)
                    c1m2dGLRLMs{dOffsetIndex} = GLRLMFeature.CalculateGLRLM(...
                        m3xImage, m3bMask,...
                        m2dOffsetVectors(dOffsetIndex,:),...
                        dFirstBinEdge, dBinSize, dNumBins,...
                        dEqualityThreshold,...
                        oFeatureExtractionParameters.GetGLRLMNumberOfColumns(obj), oFeatureExtractionParameters.GetGLRLMTrimNumberOfColumns(),...
                        bBinOnTheFly,...
                        c1oExtraParams{:});
                end
                
                % check if the user also wants to combine all the GLCMs
                if oFeatureExtractionParameters.GetCombineAllGLCMOffsets()
                    if oFeatureExtractionParameters.GetGLRLMTrimNumberOfColumns() % each GLRLM could be a different size
                        % each GLRLM can have a different length (columns that
                        % are all zero are trimmed)
                        dMaxNumColumns = 0;
                        
                        for dOffsetIndex=1:dNumOffsets
                            dMaxNumColumns = max(dMaxNumColumns, size(c1m2dGLRLMs{dOffsetIndex},2));
                        end
                        
                        % combine all GLRLMs
                        m2dCombinedGLRLM = zeros(dNumBins, dMaxNumColumns);
                        
                        for dOffsetIndex=1:dNumOffsets
                            dNumCols = size(c1m2dGLRLMs{dOffsetIndex},2);
                            
                            m2dCombinedGLRLM(:,1:dNumCols) = m2dCombinedGLRLM(:,1:dNumCols) + c1m2dGLRLMs{dOffsetIndex};
                        end
                    else % no columns were trimmed, all GLRLMs will be the same size
                        m2dCombinedGLRLM = zeros(size(c1m2dGLRLMs{1}));
                        
                        for dOffsetIndex=1:dNumOffsets % simply add them all together
                            m2dCombinedGLRLM = m2dCombinedGLRLM + c1m2dGLRLMs{dOffsetIndex};
                        end
                    end
                    
                    % set as last GLRLM
                    c1m2dGLRLMs{end} = m2dCombinedGLRLM;
                end
                
                % set to the cache
                obj.c1m2dCurrentRegionOfInterestCachedGLRLMs = c1m2dGLRLMs;
                obj.vdCurrentRegionOfInterestCachedGLRLMsOffsetNumbers = vdOffsetNumbers;
                
                obj.bCurrentRegionOfInterestGLRLMCacheSet = true;
            end
        end
        
        function [bStoreSubsetMaskAndImage, bBinOnTheFlyGLCM, bBinOnTheFlyGLRLM] = GetMemoryUsageScheme(obj, oFeatureExtractionParameters, vdMinimalRowBounds, vdMinimalColBounds, vdMinimalSliceBounds)
            dNumBytesPerMaskVoxel = FeatureExtractionImageVolumeHandler.GetNumberOfBytesPerMatrixVoxel(true);
            
            dNumRowsMinimal = vdMinimalRowBounds(2) - vdMinimalRowBounds(1) + 1;
            dNumColsMinimal = vdMinimalColBounds(2) - vdMinimalColBounds(1) + 1;
            dNumSlicesMinimal = vdMinimalSliceBounds(2) - vdMinimalSliceBounds(1) + 1;
            
            dNumVoxelsInMinimalMask = dNumRowsMinimal * dNumColsMinimal * dNumSlicesMinimal;
            dNumVoxelsInFullMask = prod(obj.oRASImageVolume.GetImageVolumeGeometry().GetVolumeDimensions());
            
            dAmountOfMemoryFree_Gb = oFeatureExtractionParameters.GetMaxMemoryUsage_Gb();
            
            % figure out 3D mesh memory usage (may need to create a
            % zero-padded interpolated mask matrix)
            d3DMeshMemoryUsage_Gb = 0;
            
            if ~obj.bIsInterpretedAs2DImage
                if strcmp(oFeatureExtractionParameters.GetMeshMaskInterpolationMethod(), MeshMaskInterpolationOptions.None)
                    % no interpolation, just zero-padded
                    dNumVoxelsForMeshMask = prod([dNumRowsMinimal, dNumColsMinimal, dNumSlicesMinimal] + 2);
                else
                    oImageVolumeGeometry = obj.oRASImageVolume.GetImageVolumeGeometry();
                    
                    eVoxelSizeSource = oFeatureExtractionParameters.GetMeshMaskInterpolationVoxelSizeSource();
                    dVoxelSizeMultiplier = oFeatureExtractionParameters.GetMeshMaskInterpolationVoxelSizeMultiplier();
                    
                    if eVoxelSizeSource == MeshMaskInterpolationVoxelSizeSourceOptions.Max
                        dVoxelSize_mm = max(oImageVolumeGeometry.GetVoxelDimensions_mm());
                    else
                        dVoxelSize_mm = min(oImageVolumeGeometry.GetVoxelDimensions_mm());
                    end
                    
                    dVoxelSize_mm = dVoxelSizeMultiplier * dVoxelSize_mm;
                    
                    oTargetImageVolumeGeometry = oImageVolumeGeometry.GetSelectionImageVolumeGeometry(vdMinimalRowBounds + [-1 1], vdMinimalColBounds + [-1 1], vdMinimalSliceBounds + [-1 1]);
                    oTargetImageVolumeGeometry = oTargetImageVolumeGeometry.GetMatchedImageVolumeGeometryWithIsotropicVoxels(dVoxelSize_mm);
                    
                    vdVolumeDimensions = oTargetImageVolumeGeometry.GetVolumeDimensions();
                    
                    dNumVoxelsForMeshMask = prod(vdVolumeDimensions + 2); % plus two for zero-padding
                end
                
                d3DMeshMemoryUsage_Gb = dNumVoxelsForMeshMask * dNumBytesPerMaskVoxel * 1E-9;
            end
            
            dAmountOfMemoryFree_Gb = dAmountOfMemoryFree_Gb - d3DMeshMemoryUsage_Gb; % can't get around this memory usage
            
            % figure out memory for storing the mask (storing mask is
            % mandatory)
            
            dNumBytesPerImageVoxel = FeatureExtractionImageVolumeHandler.GetNumberOfBytesPerMatrixVoxel(obj.oRASImageVolume.GetImageData());
            
            dMemoryForFullMask_Gb = dNumVoxelsInFullMask * dNumBytesPerMaskVoxel * 1E-9; % image doesn't need to be copied, it'll be referred to directly
            dMemoryForSubsetMask_Gb = dNumVoxelsInMinimalMask * (dNumBytesPerMaskVoxel + dNumBytesPerImageVoxel) * 1E-9; % a subset of the mask will be stored as well as a copy of the subset of the image data
            
            dMemoryForMinimalBinnedImage_Gb = dNumVoxelsInMinimalMask * obj.dNumBytesPerBinnedImageVoxel * 1E-9;
            
            if dMemoryForSubsetMask_Gb <= dMemoryForFullMask_Gb % storing the subset of BOTH the mask and image is more memory efficient that storing the full mask (e.g. large volume, small ROI)
                bStoreSubsetMaskAndImage = true;
                
                dAmountOfMemoryFree_Gb = dAmountOfMemoryFree_Gb - dMemoryForSubsetMask_Gb;
                
                % check to store GLCM binned image
                
                if 2*dMemoryForMinimalBinnedImage_Gb <= dAmountOfMemoryFree_Gb
                    bBinOnTheFlyGLCM = false;
                    bBinOnTheFlyGLRLM = false;
                elseif dMemoryForMinimalBinnedImage_Gb <= dAmountOfMemoryFree_Gb
                    bBinOnTheFlyGLCM = false;
                    bBinOnTheFlyGLRLM = true;
                else
                    bBinOnTheFlyGLCM = true;
                    bBinOnTheFlyGLRLM = true;
                end
            else % store the full mask
                if dMemoryForSubsetMask_Gb + 2*dMemoryForMinimalBinnedImage_Gb <= dAmountOfMemoryFree_Gb % we have space for minimal image and binning storage
                    bStoreSubsetMaskAndImage = true;
                    bBinOnTheFlyGLCM = false;
                    bBinOnTheFlyGLRLM = false;
                else
                    bStoreSubsetMaskAndImage = false;
                    
                    dAmountOfMemoryFree_Gb = dAmountOfMemoryFree_Gb - dMemoryForFullMask_Gb;
                    dMemoryForFullBinnedImage_Gb = dNumVoxelsInFullMask .* obj.dNumBytesPerBinnedImageVoxel * 1E-9;
                    
                    if 2*dMemoryForFullBinnedImage_Gb <= dAmountOfMemoryFree_Gb
                        bBinOnTheFlyGLCM = false;
                        bBinOnTheFlyGLRLM = false;
                    elseif dMemoryForFullBinnedImage_Gb <= dAmountOfMemoryFree_Gb
                        bBinOnTheFlyGLCM = false;
                        bBinOnTheFlyGLRLM = true;
                    else
                        bBinOnTheFlyGLCM = true;
                        bBinOnTheFlyGLRLM = true;
                    end
                end
            end
        end
        
        function [m3iBinnedImage, m3bImageMask] = GetCurrentRegionOfInterestBinnedImageAndMask(obj, dFirstBinEdge, dBinSize, dNumberOfBins)
                        
            m3bImageMask = obj.m3bCurrentRegionOfInterestCachedMask;
            
            if obj.bCurrentRegionOfInterestImageAndMaskCacheSetIsMinimallyBounded
                m3xImageData = obj.m3xCurrentRegionOfInterestCachedImage;
            else
                m3xImageData = obj.oRASImageVolume.GetImageData();
            end
            
            vdRowBounds = [1, size(m3xImageData,1)];
            vdColBounds = [1, size(m3xImageData,2)];
            vdSliceBounds = [1, size(m3xImageData,3)];
            
            switch class(m3xImageData)
                case 'int8'
                    m3iBinnedImage = BinImage_int8_To_uint32_mex(m3xImageData, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumberOfBins);
                case 'int16'
                    m3iBinnedImage = BinImage_int16_To_uint32_mex(m3xImageData, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumberOfBins);
                case 'int32'
                    m3iBinnedImage = BinImage_int32_To_uint32_mex(m3xImageData, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumberOfBins);
                case 'uint8'
                    m3iBinnedImage = BinImage_uint8_To_uint32_mex(m3xImageData, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumberOfBins);
                case 'uint16'
                    m3iBinnedImage = BinImage_uint16_To_uint32_mex(m3xImageData, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumberOfBins);
                case 'uint32'
                    m3iBinnedImage = BinImage_uint32_To_uint32_mex(m3xImageData, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumberOfBins);
                case 'single'
                    m3iBinnedImage = BinImage_single_To_uint32_mex(m3xImageData, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumberOfBins);
                case 'double'
                    m3iBinnedImage = BinImage_double_To_uint32_mex(m3xImageData, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumberOfBins);
                otherwise
                    error(...
                        'FeatureExtractionImageVolumeHandler:GetCurrentRegionOfInterestBinnedImageAndMask:InvalidImageClass',...
                        'Only images of types single, double, and integer (up to 32-bit) are supported.');
            end
        end
    end
    
    methods (Access = private, Static = true)
        
        function ValidateImageVolume(oImageVolume)
            if ~isscalar(oImageVolume) || ~isa(oImageVolume, 'ImageVolume')
                error(...
                    'FeatureExtractionImageVolumeHandler:ValidateRASImageVolume:InvalidType',...
                    'The Image Volume must be given as a scalar of type ImageVolume.');
            end
            
            if oImageVolume.GetNumberOfRegionsOfInterest() == 0
                error(...
                    'FeatureExtractionImageVolumeHandler:ValidateRASImageVolume:InvalidNumberOfRegionsOfInterest',...
                    'The Image Volume must have at least one region of interest.');
            end
        end
        
        function ValidateRASImageVolume(oRASImageVolume)
            vdMisalignmentAngles_deg = ImageVolumeGeometry.GetEulerAnglesAboutCartesianAxesBetweenGeometries(oRASImageVolume.GetImageVolumeGeometry(), FeatureExtractionImageVolumeHandler.oTargetUnifiedImageVolumeGeometry);
            
            if any(abs(vdMisalignmentAngles_deg) > FeatureExtractionImageVolumeHandler.dMisalignmentFromTargetUnifiedImageVolumeGeometryErrorLimit_deg)
                error(...
                    'FeatureExtractionImageVolumeHandler:ValidateRASImageVolume:HighlyObliqueImageVolume',...
                    ['The given image volume was acquired in an oblique geometry, deviating by more than ', num2str(FeatureExtractionImageVolumeHandler.dMisalignmentFromTargetUnifiedImageVolumeGeometryErrorLimit_deg), ' degrees, and therefore cannot be processed. Please interpolate the data into an non-oblique volume.']);
            elseif any(abs(vdMisalignmentAngles_deg) > ImageVolumeGeometry.GetPrecisionBound())
                warning(...
                    'FeatureExtractionImageVolumeHandler:ValidateRASImageVolume:MarginallyObliqueImageVolume',...
                    ['The given image volume was acquired with a slightly oblique geometry, deviating by at most ', num2str(max(abs(vdMisalignmentAngles_deg))), ' degrees from the desired acquisition geometry. This image volume can be processed, but care should be taken.']);
            end
        end
        
        function ValidateExtractionOrderRegionOfInterestNumbers(vdExtractionOrderRegionOfInterestNumbers, oImageVolume)
            if isempty(vdExtractionOrderRegionOfInterestNumbers) && isa(vdExtractionOrderRegionOfInterestNumbers, 'double')
                % we're good
            else
                if ~iscolumn(vdExtractionOrderRegionOfInterestNumbers) || ~isa(vdExtractionOrderRegionOfInterestNumbers, 'double')
                    error(...
                        'FeatureExtractionImageVolumeHandler:ValidateExtractionOrderRegionOfInterestNumbers:InvalidType',...
                        'ValidateExtractionOrderRegionOfInterestNumbers must be a column vector of type double.');
                end
                
                dNumRois = oImageVolume.GetNumberOfRegionsOfInterest();
                
                if ...
                        any(vdExtractionOrderRegionOfInterestNumbers < 1) ||...
                        any(vdExtractionOrderRegionOfInterestNumbers > dNumRois) ||...
                        length(vdExtractionOrderRegionOfInterestNumbers) > dNumRois ||...
                        any(round(vdExtractionOrderRegionOfInterestNumbers) ~= vdExtractionOrderRegionOfInterestNumbers)
                    error(...
                        'FeatureExtractionImageVolumeHandler:ValidateExtractionOrderRegionOfInterestNumbers:InvalidValue',...
                        'ValidateExtractionOrderRegionOfInterestNumbers must only contain unique, integer values between 1 and the number of regions of interest within the image volume object.');
                end
            end
        end
        
        function ValidateGroupAndSubGroupIds(viGroupIds, viSubGroupIds, dNumRois)
            m2dSpoofedFeatureValues = zeros(dNumRois,1);
            
            FeatureValues.ValidateGroupAndSubGroupIds(viGroupIds, viSubGroupIds, m2dSpoofedFeatureValues);
        end
        
        function ValidateUserDefinedSampleStrings(vsUserDefinedSampleStrings, dNumRois)
            m2dSpoofedFeatureValues = zeros(dNumRois,1);
            
            FeatureValues.ValidateUserDefinedSampleStrings(vsUserDefinedSampleStrings, m2dSpoofedFeatureValues);
        end
        
        function ValidateIsInterpretedAs2DImage(bIsInterpretedAs2DImage, oImageVolume)
            if ~isscalar(bIsInterpretedAs2DImage) || ~islogical(bIsInterpretedAs2DImage)
                error(...
                    'FeatureExtractionImageVolumeHandler:ValidateIsInterpretedAs2DImage:InvalidType',...
                    'bIsInterpretedAs2DImage must be a scalar value of type logical.');
            end
            
            vdImageVolumeDims = oImageVolume.GetVolumeDimensions();
            
            if all(vdImageVolumeDims ~= 1) && bIsInterpretedAs2DImage
                error(...
                    'FeatureExtractionImageVolumeHandler:ValidateIsInterpretedAs2DImage:InvalidValueForImageVolume',...
                    'Cannot interpret 3D image volumes as 2D images. At least one dimension of the image volume needs to be 1 to interpret as a 2D image.');
            end
        end
        
        function dNumBytesPerVoxel = GetNumberOfBytesPerMatrixVoxel(m3xMatrix)
            switch class(m3xMatrix)
                case 'logical'
                    dNumBytesPerVoxel = 1;
                case 'uint8'
                    dNumBytesPerVoxel = 1;
                case 'uint16'
                    dNumBytesPerVoxel = 2;
                case 'uint32'
                    dNumBytesPerVoxel = 4;
                case 'uint64'
                    dNumBytesPerVoxel = 8;
                case 'int8'
                    dNumBytesPerVoxel = 1;
                case 'int16'
                    dNumBytesPerVoxel = 2;
                case 'int32'
                    dNumBytesPerVoxel = 4;
                case 'int64'
                    dNumBytesPerVoxel = 8;
                case 'single'
                    dNumBytesPerVoxel = 4;
                case 'double'
                    dNumBytesPerVoxel = 8;
                otherwise
                    error(...
                        'FeatureExtractionImageVolumeHandler:GetNumberOfBytesPerMatrixVoxel:CannotDetermine',...
                        ['Cannot determine the number of bytes per voxel for matrix of type ', class(m3xMatrix)]);
            end
        end
        
        function m3xSubset = GetSubsetOfMatrix(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds)
            switch class(m3xMatrix)
                case 'logical'
                    m3xSubset = MatrixSubselection_logical_mex(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'uint8'
                    m3xSubset = MatrixSubselection_uint8_mex(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'uint16'
                    m3xSubset = MatrixSubselection_uint16_mex(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'uint32'
                    m3xSubset = MatrixSubselection_uint32_mex(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'uint64'
                    m3xSubset = MatrixSubselection_uint64_mex(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'int8'
                    m3xSubset = MatrixSubselection_int8_mex(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'int16'
                    m3xSubset = MatrixSubselection_int16_mex(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'int32'
                    m3xSubset = MatrixSubselection_int32_mex(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'int64'
                    m3xSubset = MatrixSubselection_int64_mex(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'single'
                    m3xSubset = MatrixSubselection_single_mex(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'double'
                    m3xSubset = MatrixSubselection_double_mex(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds);
                otherwise
                    error(...
                        'FeatureExtractionImageVolumeHandler:GetSubsetOfMatrixVoxel:InvalidClass',...
                        ['Cannot make a subset selection for matrix of type ', class(m3xMatrix)]);
            end
        end
    end
    
    
    methods (Access = {?Feature, ?FeatureExtractionImageVolumeHandler}, Static = true)
        
        function dNumTotalRois = GetNumberOfRegionsOfInterestForImageVolumeHandlers(voImageVolumeHandlers)
            dNumTotalRois = 0;
            
            for dImageIndex=1:length(voImageVolumeHandlers)
                dNumTotalRois = dNumTotalRois + voImageVolumeHandlers(dImageIndex).GetNumberOfRegionsOfInterest();
            end
        end
        
        function viGroupIds = GetGroupIdsForImageVolumeHandlers(voImageVolumeHandlers)
            dNumTotalRois = FeatureExtractionImageVolumeHandler.GetNumberOfRegionsOfInterestForImageVolumeHandlers(voImageVolumeHandlers);
            
            if dNumTotalRois == 0
                viGroupIds = [];
            else
                chMasterGroupIdClass = class(voImageVolumeHandlers(1).GetRegionsOfInterestGroupIds());
                viGroupIds = zeros(dNumTotalRois, 1, chMasterGroupIdClass);
                
                dInsertIndex = 1;
                
                for dImageIndex = 1:length(voImageVolumeHandlers)
                    viNextGroupIds = voImageVolumeHandlers(dImageIndex).GetRegionsOfInterestGroupIds();
                    
                    if isa(viNextGroupIds, chMasterGroupIdClass)
                        dNumToInsert = length(viNextGroupIds);
                        
                        viGroupIds(dInsertIndex : dInsertIndex + dNumToInsert - 1) = viNextGroupIds;
                        dInsertIndex = dInsertIndex + dNumToInsert;
                    else
                        error(...
                            'FeatureExtactionImageVolumeHandler:GetGroupIdsForImageVolumeHandlers:MismatchedClass',...
                            'All Group IDs across images and ROIs must be of the same class.');
                    end
                end
            end
        end
        
        function viSubGroupIds = GetSubGroupIdsForImageVolumeHandlers(voImageVolumeHandlers)
            dNumTotalRois = FeatureExtractionImageVolumeHandler.GetNumberOfRegionsOfInterestForImageVolumeHandlers(voImageVolumeHandlers);
            
            if dNumTotalRois == 0
                viSubGroupIds = [];
            else
                chMasterGroupSubIdClass = class(voImageVolumeHandlers(1).GetRegionsOfInterestSubGroupIds());
                viSubGroupIds = zeros(dNumTotalRois, 1, chMasterGroupSubIdClass);
                
                dInsertIndex = 1;
                
                for dImageIndex = 1:length(voImageVolumeHandlers)
                    viNextSubGroupIds = voImageVolumeHandlers(dImageIndex).GetRegionsOfInterestSubGroupIds();
                    
                    if isa(viNextSubGroupIds, chMasterGroupSubIdClass)
                        dNumToInsert = length(viNextSubGroupIds);
                        
                        viSubGroupIds(dInsertIndex : dInsertIndex + dNumToInsert - 1) = viNextSubGroupIds;
                        dInsertIndex = dInsertIndex + dNumToInsert;
                    else
                        error(...
                            'FeatureExtactionImageVolumeHandler:GetSubGroupIdsForImageVolumeHandlers:MismatchedClass',...
                            'All Sub-Group IDs across images and ROIs must be of the same class.');
                    end
                end
            end
        end
        
        function vsUserDefinedSampleStrings = GetUserDefinedSampleStringsForImageVolumeHandlers(voImageVolumeHandlers)
            dNumTotalRois = FeatureExtractionImageVolumeHandler.GetNumberOfRegionsOfInterestForImageVolumeHandlers(voImageVolumeHandlers);
            
            if dNumTotalRois == 0
                vsUserDefinedSampleStrings = [];
            else
                chMasterSampleStringClass = class(voImageVolumeHandlers(1).GetRegionsOfInterestUserDefinedSampleStrings());
                vsUserDefinedSampleStrings = strings(dNumTotalRois, 1);
                
                dInsertIndex = 1;
                
                for dImageIndex = 1:length(voImageVolumeHandlers)
                    vsNextSampleStrings = voImageVolumeHandlers(dImageIndex).GetRegionsOfInterestUserDefinedSampleStrings();
                    
                    if isa(vsNextSampleStrings, chMasterSampleStringClass)
                        dNumToInsert = length(vsNextSampleStrings);
                        
                        vsUserDefinedSampleStrings(dInsertIndex : dInsertIndex + dNumToInsert - 1) = vsNextSampleStrings;
                        dInsertIndex = dInsertIndex + dNumToInsert;
                    else
                        error(...
                            'ImageVolume:GetUserDefinedSampleStringsForImagesAndROIs:InvalidDataType',...
                            'All User Defined Samples Strings across images and ROIs must be of the same class.');
                    end
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