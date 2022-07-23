classdef (Abstract) ImageVolume < GeometricalImagingObject
    %ImageVolume
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = protected, GetAccess = public)
        m3xImageData = []
        
        chMatFilePath = ''
        
        dImageDataMinimumValue = []
        dImageDataMaximumValue = []
        
        oRegionsOfInterest RegionsOfInterest {ValidationUtils.MustBeEmptyOrScalar} = MATLABLabelMapRegionsOfInterest.empty
    end
    
    properties (Constant = true, GetAccess = protected)
        chImageDataMatFileVarName = 'm3xImageData'
        chObjMatFileVarName = 'oImageVolume'
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = ImageVolume(oOnDiskImageVolumeGeometry, oRegionsOfInterest, NameValueArgs)
            %obj = ImageVolume(oOnDiskImageVolumeGeometry, varargin)
            %
            % SYNTAX:
            %  obj = ImageVolume(oOnDiskImageVolumeGeometry, oRegionsOfInterest)
            %  obj = ImageVolume(__, __, __, __, vdDisplayMinMax)
            %
            % DESCRIPTION:
            %  Constructor for NewClass
            %
            % INPUT ARGUMENTS:
            %  input1: What input1 is
            %  input2: What input2 is. If input2's description is very, very
            %         long wrap it with tabs to align the second line, and
            %         then the third line will automatically be in line
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                oOnDiskImageVolumeGeometry (1,1) ImageVolumeGeometry
                oRegionsOfInterest RegionsOfInterest {ImageVolume.MustBeValidRegionsOfInterest(oRegionsOfInterest, oOnDiskImageVolumeGeometry)} = MATLABLabelMapRegionsOfInterest.empty
                NameValueArgs.ImageData (:,:,:)
            end
            
            % Super-class constructor
            obj@GeometricalImagingObject(oOnDiskImageVolumeGeometry);
                        
            % Regions-of-Interest (optional)
            if ~isempty(oRegionsOfInterest)
                obj.oRegionsOfInterest = oRegionsOfInterest;
            end
            
            % Image data (optional)
            if isfield(NameValueArgs, 'ImageData')
                ImageVolume.MustBeValidImageData(NameValueArgs.ImageData, oOnDiskImageVolumeGeometry);
                obj.m3xImageData = NameValueArgs.ImageData;
                
                obj.dImageDataMinimumValue = min(obj.m3xImageData(:));
                obj.dImageDataMaximumValue = max(obj.m3xImageData(:));
            end            
        end 
            
        
        
        function hApp = View(obj)
            %hApp = View(obj)
            %
            % SYNTAX:
            %  hApp = obj.View()
            %
            % DESCRIPTION:
            %  Opens the ImageVolume (and possible RegionsOfInterest)
            %  object using the ImageVolumeViewer app. This displays the
            %  ImageVolume AS IS (e.g. with all transformations applied) in
            %  an RAS geometry. The app handle is returned for possible
            %  scripting.
            %
            % INPUT ARGUMENTS:
            %  obj: An ImageVolume object
            %
            % OUTPUTS ARGUMENTS:
            %  hApp: A handle to a ImageVolumeViewer app instance
            
            hApp = ImageVolumeViewer(obj);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>> FILE I/O <<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function LoadVolumeData(obj)
            % only load if m3xImageData is empty
            if isempty(obj.m3xImageData)
                % if there's a Mat file, load up the data from there (this
                % holds a transformed version), if empty, load up from the
                % original image file (Dicom, Nifti, etc.)
                if isempty(obj.chMatFilePath) % from original file (Dicom, Nifti, etc)
                    m3xImageData = obj.LoadOriginalImageData();
                    ImageVolume.MustBeValidImageData(m3xImageData, obj.GetOnDiskImageVolumeGeometry());
                    obj.dCurrentAppliedImagingObjectTransform = 1;
                else % from .mat file
                    [m3xImageData, oImageVolumeFromMatFile] = FileIOUtils.LoadMatFile(...
                        obj.chMatFilePath,...
                        ImageVolume.chImageDataMatFileVarName, ImageVolume.chObjMatFileVarName);
                    
                    obj.dCurrentAppliedImagingObjectTransform = oImageVolumeFromMatFile.dCurrentAppliedImagingObjectTransform;
                                        
                    ImageVolume.MustBeValidImageData(m3xImageData, obj.GetCurrentImageVolumeGeometry());
                end
                
                % set data values and min/max
                obj.m3xImageData = m3xImageData;
                
                obj.dImageDataMinimumValue = double(min(m3xImageData(:))); % doing this once on load allows for quick access by functions that require this many times (e.g. real-time window/level calcs)
                obj.dImageDataMaximumValue = double(max(m3xImageData(:)));                
            end
            
            % call to Regions of Interest load
            if ~isempty(obj.oRegionsOfInterest)
                obj.oRegionsOfInterest.LoadVolumeData();
            end
        end
        
        function UnloadVolumeData(obj)
            obj.m3xImageData = [];
            
            if ~isempty(obj.oRegionsOfInterest)
                obj.oRegionsOfInterest.UnloadVolumeData();
            end
        end
        
        function bVolumeDataIsLoaded = IsVolumeDataLoaded(obj)
            bVolumeDataIsLoaded = ~isempty(obj.m3xImageData);
        end
        
        function Save(obj, chMatFilePath, bForceApplyAllTransforms, varargin)
            arguments
                obj
                chMatFilePath (1,:) char = ''
                bForceApplyAllTransforms (1,1) logical = false
            end
            arguments (Repeating)
                varargin
            end
            
            if isempty(chMatFilePath)
                if isempty(obj.chMatFilePath)
                    error(...
                        'ImageVolume:Save:NotPreviouslySaved',...
                        'The ImageVolume object has not yet been saved, and so .Save cannot be called without any input arguments.');
                else
                    chMatFilePath = obj.chMatFilePath;
                end
            end
            
            obj.LoadVolumeData(); % we're going to have to load the data if we're going to resave it
            
            if ~obj.AreAllTransformsApplied()
                if bForceApplyAllTransforms
                    obj.ForceApplyAllTransforms();
                else
                    warning(...
                        'ImageVolume:Save:NotAllTransformsApplied',...
                        'Not all transforms have been applied to the image data matrix that is being saved to disk. Use obj.ForceApplyAllTransforms() or the bForceApplyAllTransforms flag for this function if you want all transforms to be applied.');                     
                end
            end
            
            [chFilePath,chFilename] = FileIOUtils.SeparateFilePathAndFilename(chMatFilePath);
            [~, chFileExtension] = FileIOUtils.SeparateFilePathExtension(chFilename);
            
            if ~isempty(chFilePath) && exist(chFilePath,'dir') ~= 7
                error(...
                    'ImageVolume:SaveTransformedData:InvalidDirectory',...
                    'The provided directory does not exist.');
            end
            
            if ~strcmp(chFileExtension, '.mat')
                error(...
                    'ImageVolume:SaveTransformedData:InvalidFileType',...
                    'ImageVolumes must be saved to .mat files.');
            end
            
            % clear out file path (doesn't need to be saved to disk; will
            % be set to object in RAM after save)
            obj.chMatFilePath = '';
              
            % get ROI objects
            if ~isempty(obj.oRegionsOfInterest)
                oRoisCache = obj.oRegionsOfInterest;
                obj.oRegionsOfInterest = MATLABLabelMapRegionsOfInterest.empty;
            else
                oRoisCache = [];
            end
            
            % set .mat file path (this is technically temporary, but is
            % useful for functions in ImageVolume subclasses that require
            % this path to be set)
            obj.chMatFilePath = chMatFilePath;
            
            % save
            FileIOUtils.SaveMatFile(chMatFilePath,...
                ImageVolume.chObjMatFileVarName, obj,...
                ImageVolume.chImageDataMatFileVarName, obj.m3xImageData,...
                varargin{:});
            
            % set .mat file path
            obj.chMatFilePath = FileIOUtils.GetAbsolutePath(chMatFilePath);
            
            % set ROIs back
            if ~isempty(oRoisCache)
                obj.oRegionsOfInterest = oRoisCache;
                
                bForceApplyAllTransforms = true;
                bAppend = true;
                
                obj.oRegionsOfInterest.Save(chMatFilePath, bForceApplyAllTransforms, bAppend, varargin{:});
            end
        end
        
        function SetMatFilePath(obj, chNewMatFilePath)
            arguments
                obj (1,1) ImageVolume
                chNewMatFilePath (1,:) char
            end
            
            obj.chMatFilePath = chNewMatFilePath;
        end
        
        % >>>>>>>>>>>>>>>>>>>>> VALIDATORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustHaveRegionsOfInterest(obj)
            arguments
                obj
            end
            
            if isempty(obj.oRegionsOfInterest)
                error(...
                    'ImageVolume:MustHaveRegionsOfInterest:Invalid',...
                    'The ImageVolume object does not have regions of interest associated with it.');
            end
        end
        
        function MustHaveRegionsOfInterestOfClass(obj, chClassname)
            arguments
                obj {MustHaveRegionsOfInterest(obj)}
                chClassname (1,:) char
            end
            
            if ~isa(obj.oRegionsOfInterest, chClassname)
                 error(...
                    'ImageVolume:MustHaveRegionsOfInterestOfClass:Invalid',...
                    ['The ImageVolume object does not have regions of interest of type "', chClassname, '".']);
            end
        end
        
        function MustBeValidRegionOfInterestNumbers(obj, vdRegionOfInterestNumbers)
            arguments
                obj {MustHaveRegionsOfInterest(obj)}
                vdRegionOfInterestNumbers (1,:) double
            end
            
            obj.oRegionsOfInterest.MustBeValidRegionOfInterestNumbers(vdRegionOfInterestNumbers);
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        function m3xImageData = GetImageData(obj)
            obj.ForceApplyAllTransforms();
            
            m3xImageData = obj.m3xImageData;
        end
        
        function m3xCroppedImageData = GetCroppedImageData(obj, vdCropCentreVoxelIndices, vdCropDimensions)
            arguments
                obj
                vdCropCentreVoxelIndices (1,3) double {mustBeFinite}
                vdCropDimensions (1,3) double {mustBeInteger, mustBePositive}
            end
            
            obj.ForceApplyAllTransforms();
            
            m3xCroppedImageData = MatrixUtils.CropMatrixByCentreAndDimensions(obj.m3xImageData, vdCropCentreVoxelIndices, vdCropDimensions);
        end
        
        function dMin = GetImageDataMinimumValue(obj)
            if isempty(obj.dImageDataMinimumValue)
                obj.ForceApplyAllTransforms();
            end
            
            dMin = obj.dImageDataMinimumValue;
        end
        
        function dMax = GetImageDataMaximumValue(obj)            
            if isempty(obj.dImageDataMaximumValue)
                obj.ForceApplyAllTransforms();
            end
            
            dMax = obj.dImageDataMaximumValue;
        end
        
        function dMaxWindow = GetImageDataMaximumWindow(obj)
            dMaxWindow = obj.GetImageDataMaximumValue() - obj.GetImageDataMinimumValue();
        end
        
        function vdDefaultImageDisplayBounds = GetDefaultImageDisplayBounds(obj)
            vdDefaultImageDisplayBounds = [...
                obj.GetImageDataMinimumValue(),...
                obj.GetImageDataMaximumValue()*(2/3)];
            
            if vdDefaultImageDisplayBounds(1) >= vdDefaultImageDisplayBounds(2)
                if obj.GetImageDataMinimumValue() == obj.GetImageDataMaximumValue()
                    vdDefaultImageDisplayBounds = [...
                        obj.GetImageDataMinimumValue(),...
                        obj.GetImageDataMinimumValue()+1];
                else
                    vdDefaultImageDisplayBounds = [...
                        obj.GetImageDataMinimumValue(),...
                        obj.GetImageDataMaximumValue()];
                end
            end
        end
        
        function chMatFilePath = GetMatFilePath(obj)
            chMatFilePath = obj.chMatFilePath;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>> TRANSFORMS <<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function ForceApplyAllTransforms(obj)
            ForceApplyAllTransforms@GeometricalImagingObject(obj);
            
            if ~isempty(obj.oRegionsOfInterest)
                obj.oRegionsOfInterest.ForceApplyAllTransforms();
            end
        end
        
        function RemoveAllTransforms(obj)
            RemoveAllTransforms@GeometricalImagingObject(obj);
            
            obj.m3xImageData = [];
            
            obj.dImageDataMinimumValue = [];
            obj.dImageDataMaximumValue = [];
            
            obj.chMatFilePath = '';
            
            if ~isempty(obj.oRegionsOfInterest)
                obj.oRegionsOfInterest.RemoveAllTransforms();
            end
        end
        
        function InterpolateOntoTargetGeometry(obj, oTargetImageVolumeGeometry, chImageVolume3DInterpolationMethod, dImageVolumeExtrapolationValue, varargin)
            arguments
                obj
                oTargetImageVolumeGeometry (1,1) ImageVolumeGeometry
                chImageVolume3DInterpolationMethod (1,:) char
                dImageVolumeExtrapolationValue (1,1) double
            end
            
            arguments (Repeating)
                varargin
            end
            
            
            % InterpolateOntoTargetGeometry(obj, oTargetImageVolumeGeometry, chImageVolume3DInterpolationMethod, dImageVolumeExtrapolationValue, varargin)
            %
            % SYNTAX:
            %  obj.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, chImageVolume3DInterpolationMethod, dImageVolumeExtrapolationValue)
            %  obj.InterpolateOntoTargetGeometry(__, __, __, chRegionsOfInterestCrossPlane2DInterpolationMethod, chRegionsOfInterestThroughPlane1DLevelSetInterpolationMethod)
            %  obj.InterpolateOntoTargetGeometry(__, __, __, __, __, dRegionsOfInterestCrossPlaneDimensions)
            
            oTransform = ImagingObjectScalarDataSpatialTransform(...
                oTargetImageVolumeGeometry,...
                chImageVolume3DInterpolationMethod, dImageVolumeExtrapolationValue);
            
            obj.AddTransform(oTransform);
            obj.ClearImageDataMinimumAndMaximumValues();
            
            if ~isempty(obj.oRegionsOfInterest)
                obj.oRegionsOfInterest.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, varargin{:});
            end
        end
        
        function InterpolateToIsotropicVoxelResolution(obj, dIsotropicVoxelDimension_mm, chImageVolume3DInterpolationMethod, chImageVolumeExtrapolationValue, varargin)
            arguments
                obj
                dIsotropicVoxelDimension_mm (1,1) double {mustBePositive, mustBeFinite}
                chImageVolume3DInterpolationMethod
                chImageVolumeExtrapolationValue
            end
            arguments (Repeating)
                varargin
            end
            
            oTargetImageVolumeGeometry = obj.GetImageVolumeGeometry().GetMatchedImageVolumeGeometryWithIsotropicVoxels(dIsotropicVoxelDimension_mm);
            
            obj.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, chImageVolume3DInterpolationMethod, chImageVolumeExtrapolationValue, varargin{:});
        end
        
        function InterpolateToNewVoxelResolution(obj, vdNewVoxelDimensions_mm, chImageVolume3DInterpolationMethod, dImageVolumeExtrapolationValue, varargin)
            arguments
                obj
                vdNewVoxelDimensions_mm (1,3) double {mustBePositive, mustBeFinite}
                chImageVolume3DInterpolationMethod (1,:) char
                dImageVolumeExtrapolationValue (1,1) double
            end
            arguments (Repeating)
                varargin
            end
            
            oTargetImageVolumeGeometry = obj.GetImageVolumeGeometry().GetMatchedImageVolumeGeometryWithCustomVoxelDimensions(vdNewVoxelDimensions_mm);
            
            obj.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, chImageVolume3DInterpolationMethod, dImageVolumeExtrapolationValue, varargin{:});
        end
        
        function ReassignFirstVoxel(obj, oTargetImageVolumeGeometry)
            ReassignFirstVoxel@GeometricalImagingObject(obj, oTargetImageVolumeGeometry);
            
            if ~isempty(obj.oRegionsOfInterest)
                obj.oRegionsOfInterest.ReassignFirstVoxel(oTargetImageVolumeGeometry);
            end
        end
        
        function ReassignFirstVoxelToAlignWithRASCoordinateSystem(obj)
            ReassignFirstVoxelToAlignWithRASCoordinateSystem@GeometricalImagingObject(obj);            
        end
        
        function PerformRigidTransform(obj, m2dAffineTransformMatrix)
            arguments
                obj (1,1) ImageVolume
                m2dAffineTransformMatrix (4,4) double
% %                 vdRotations_deg (1,3) double {mustBeFinite} = [0 0 0]
% %                 vdTranslations_mm (1,3) double {mustBeFinite} = [0 0 0]
            end
            
            oTransform = RigidTransform(obj.GetImageVolumeGeometry(), m2dAffineTransformMatrix);
            obj.AddTransform(oTransform);  
            
            if ~isempty(obj.oRegionsOfInterest)
                obj.oRegionsOfInterest.PerformRigidTransform(m2dAffineTransformMatrix);
            end
        end
        
        function MatchHistogramToReferenceImageVolume(obj, oReferenceImageVolume, dNumberOfBins)
            arguments
                obj
                oReferenceImageVolume (1,1) {ValidationUtils.MustBeA(oReferenceImageVolume, 'ImageVolume')}
                dNumberOfBins (1,1) double {mustBeInteger, mustBePositive}
            end
            
            oTransform = IntensityHistogramMatchingTransform(obj, oReferenceImageVolume, dNumberOfBins);
            
            obj.AddTransform(oTransform);
            obj.ClearImageDataMinimumAndMaximumValues();
            
            % nothing to do for regions of interest
        end
        
        function NormalizeIntensityLinearly(obj, dCurrentIntensityValue, dNewIntensityValue, chNewImageDataClass)
            arguments
                obj
                dCurrentIntensityValue (1,1) double {mustBeFinite}
                dNewIntensityValue (1,1) double {mustBeFinite}
                chNewImageDataClass(1,:) char
            end
            
            oTransform = LinearIntensityNormalizationTransform(obj, dCurrentIntensityValue, dNewIntensityValue, chNewImageDataClass);
            
            obj.AddTransform(oTransform);
            obj.ClearImageDataMinimumAndMaximumValues();
            
            % nothing to do for regions of interest
        end
        
        function NormalizeIntensityWithZScoreTransform(obj, dNumberOfStandardDeviations, NameValueArgs)
            arguments
                obj (1,1) ImageVolume
                dNumberOfStandardDeviations (1,1) double {mustBeFinite, mustBePositive}
                NameValueArgs.RegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, NameValueArgs.RegionOfInterestNumber)}
                NameValueArgs.CustomMean (1,1) double {mustBeFinite}
                NameValueArgs.CustomStandardDeviation (1,1) double {mustBeFinite, mustBePositive}
            end
            
            c1xVarargin = namedargs2cell(NameValueArgs);
            oTransform = ZScoreIntensityNormalizationTransform(obj, dNumberOfStandardDeviations, c1xVarargin{:});
            
            obj.AddTransform(oTransform);
            obj.ClearImageDataMinimumAndMaximumValues();
        end
        
        function TransformImageDataWithCustomFunction(obj, fnCustomTransform)
            arguments
                obj (1,1) ImageVolume
                fnCustomTransform function_handle
            end
            
            oTransform = CustomIntensityTransform(obj, fnCustomTransform);
            
            obj.AddTransform(oTransform);
            obj.ClearImageDataMinimumAndMaximumValues();
        end
        
        function CastImageDataToType(obj, chCastClassName)
            arguments
                obj
                chCastClassName (1,:) char {mustBeMember(chCastClassName, {'single', 'double', 'uint8', 'uint16', 'uint32', 'uint64', 'int8', 'int16', 'int32', 'int64'})}
            end
            
            oTransform = TypeCastTransform(obj, chCastClassName);
            
            obj.AddTransform(oTransform);
            
            % nothing to do for regions of interest
        end
        
        function Crop(obj, vdRowBounds, vdColBounds, vdSliceBounds)
            arguments
                obj ImageVolume
                vdRowBounds (1,:) double {MustBeValidCropBounds(obj, vdRowBounds, 1)}
                vdColBounds (1,:) double {MustBeValidCropBounds(obj, vdColBounds, 2)}
                vdSliceBounds (1,:) double {MustBeValidCropBounds(obj, vdSliceBounds, 3)}
            end
            
            oTransform = ImagingObjectCropTransform(obj.GetImageVolumeGeometry(), vdRowBounds, vdColBounds, vdSliceBounds);
            
            obj.AddTransform(oTransform);
            
            if ~isempty(obj.oRegionsOfInterest)
                obj.oRegionsOfInterest.Crop(vdRowBounds, vdColBounds, vdSliceBounds);
            end
        end
        
        % >>>>>>>>>>>>>>>>>> REGIONS OF INTERESTS (ROIs) <<<<<<<<<<<<<<<<<<
           
        function oRegionsOfInterest = GetRegionsOfInterest(obj)
            oRegionsOfInterest = obj.oRegionsOfInterest;
        end
        
        function SetRegionsOfInterest(obj, oRegionsOfInterest)
            ImageVolume.MustBeValidRegionsOfInterest(oRegionsOfInterest, obj.GetImageVolumeGeometry());
            
            obj.oRegionsOfInterest = oRegionsOfInterest;
        end
        
        function RemoveRegionsOfInterest(obj)
            obj.oRegionsOfInterest = MATLABLabelMapRegionsOfInterest.empty;
        end
        
        function dNumRegionsOfInterest = GetNumberOfRegionsOfInterest(obj)
            if ~isempty(obj.oRegionsOfInterest)
                dNumRegionsOfInterest = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            else
                dNumRegionsOfInterest = 0;
            end
        end
                
        function [m3xImageData, m3bMask] = GetMinimallyBoundedImageDataAndMaskByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            [...
                m3bMask,...
                vdRowBounds, vdColBounds, vdSliceBounds] =...
                obj.oRegionsOfInterest.GetMinimallyBoundedMaskByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            m3xFullImageData = obj.GetImageData();
            
            switch class(m3xFullImageData)
                case 'int8'
                    m3xImageData = MatrixSubselection_int8_mex(m3xFullImageData, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'int16'
                    m3xImageData = MatrixSubselection_int16_mex(m3xFullImageData, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'int32'
                    m3xImageData = MatrixSubselection_int32_mex(m3xFullImageData, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'uint8'
                    m3xImageData = MatrixSubselection_uint8_mex(m3xFullImageData, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'uint16'
                    m3xImageData = MatrixSubselection_uint16_mex(m3xFullImageData, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'uint32'
                    m3xImageData = MatrixSubselection_uint32_mex(m3xFullImageData, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'single'
                    m3xImageData = MatrixSubselection_single_mex(m3xFullImageData, vdRowBounds, vdColBounds, vdSliceBounds);
                case 'double'
                    m3xImageData = MatrixSubselection_double_mex(m3xFullImageData, vdRowBounds, vdColBounds, vdSliceBounds);
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function disp(obj)
            if isscalar(obj)
                disp(['Original File Path: ', char(obj.GetOriginalFilePath())]);
                disp(['Mat File Path:      ', char(obj.GetMatFilePath())]);
                disp('Image Volume Geometry:');
                
                dGeometryTab = 2;
                disp(obj.GetImageVolumeGeometry(), dGeometryTab);
                disp(['Number of ROIs: ', num2str(obj.GetNumberOfRegionsOfInterest())]);
            else
                vdDims = size(obj);
                vsDims = string(vdDims);
                
                disp(strjoin(vsDims, "x") + " ImageVolume array");
            end
        end
    end
    
    
    methods (Access = public, Static = true) 
        
        function obj = Load(chMatFilePath)
            % TODO
            arguments
                chMatFilePath (1,:) char {ImageVolume.MustBeValidMatFilePath(chMatFilePath)}
            end
            
            % load obj from file
            obj = FileIOUtils.LoadMatFile(chMatFilePath, ImageVolume.chObjMatFileVarName);
            
            % validate it is of correct class
            if ~isa(obj, 'ImageVolume')
                error(...
                    'ImageVolume:Load:InvalidClassType',...
                    'The oImageVolume object within the file must of type ImageVolume.');
            end
            
            % just in case the file was moved, we'll update the mat file
            % property
            obj.chMatFilePath = FileIOUtils.GetAbsolutePath(chMatFilePath);
            
            % load up ROIs
            if RegionsOfInterest.IsValidMatFilePath(chMatFilePath)
                obj.oRegionsOfInterest = RegionsOfInterest.Load(chMatFilePath);
            end
        end
    end
    
    
    methods (Access = public, Abstract = true)
        chFilePath = GetOriginalFilePath(obj)
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = protected, Abstract = true)
        m3xImageData = LoadOriginalImageData(obj)
    end
    
    
    methods (Access = protected)
                
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@GeometricalImagingObject(obj);
            
            % local call
            cpObj.m3xImageData = obj.m3xImageData;
            cpObj.dImageDataMinimumValue = obj.dImageDataMinimumValue;
            cpObj.dImageDataMaximumValue = obj.dImageDataMaximumValue;
            
            if ~isempty(obj.oRegionsOfInterest)
                cpObj.oRegionsOfInterest = copy(obj.oRegionsOfInterest);
            end
        end
        
        function saveObj = saveobj(obj)
            saveObj = copy(obj);
            
            % clear out m3xImageData (can either get that back from the
            % original file (Dicom, Nifti) or from a Matfile if
            % .Save() was called
            saveObj.UnloadVolumeData();
        end
    end
    
    
    methods (Access = protected, Static = true)
%         function obj = loadobj(s)
%             if isstruct(s)
%                 error('TODO');
%             else
%                 s.m3xImageData = [];
%                 obj = s;
%             end
%         end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
       
    methods (Access = private, Static = true)
                
        function MustBeValidRegionsOfInterest(oRegionsOfInterest, oImageVolumeGeometry)
            arguments
                oRegionsOfInterest RegionsOfInterest {ValidationUtils.MustBeEmptyOrScalar(oRegionsOfInterest)}
                oImageVolumeGeometry (1,1) ImageVolumeGeometry
            end
            
            if ~isempty(oRegionsOfInterest)
                if oRegionsOfInterest.GetImageVolumeGeometry() ~= oImageVolumeGeometry
                    error(...
                        'ImageVolume:MustBeValidRegionsOfInterest:InvalidGeometry',...
                        'The RegionsOfInterest object must have a matching geometry as specified for the ImageVolume.');
                end
            end
        end
        
        function MustBeValidImageData(m3xImageData, oImageVolumeGeometry)
            arguments
                m3xImageData (:,:,:) % {mustBeNumeric, mustBeReal, mustBeFinite} <- These calls are omitted as they are performed in the parent class function implementation and are computationally expensive
                oImageVolumeGeometry (1,1) ImageVolumeGeometry
            end
            
            GeometricalImagingObject.MustBeValidVolumeData(m3xImageData, oImageVolumeGeometry);            
        end
        
        function MustBeValidMatFilePath(chMatFilePath)
            oMatfile = matfile(chMatFilePath);
            
            vsFileEntries = whos(oMatfile);
            
            bImageVolumeFound = false;
            bImageDataFound = false;
            
            for dEntryIndex=1:length(vsFileEntries)
                sEntry = vsFileEntries(dEntryIndex);
                
                % check if entry is image volume object
                if strcmp(sEntry.name, ImageVolume.chObjMatFileVarName)
                    bImageVolumeFound = true;
                end
                
                % check if entry is image volume data
                if strcmp(sEntry.name, ImageVolume.chImageDataMatFileVarName)
                    bImageDataFound = true;
                end
            end
            
            if ~bImageVolumeFound || ~ bImageDataFound
                error(...
                    'ImageVolume:MustBeValidMatFilePath:InvalidMatFile',...
                    ['The given .mat file did not have properities "', ImageVolume.chObjMatFileVarName,'" and "', ImageVolume.chImageDataMatFileVarName, '" required to load an ImageVolume object.']);
            end
        end
    end
    
    
    methods (Access = private)
        
        function ClearImageDataMinimumAndMaximumValues(obj)
            obj.dImageDataMinimumValue = [];
            obj.dImageDataMaximumValue = []; 
        end
    end
    
    
    methods (Access = {?ImagingObjectTransform})        
        
        function m3xImageData = GetCurrentImageDataForTransform(obj)
            if obj.dCurrentAppliedImagingObjectTransform == 1 && isempty(obj.m3xImageData)
                obj.LoadVolumeData();
            end
            
            if isempty(obj.m3xImageData)
                % this state SHOULD never be reached, but this check is
                % here just in case. This state should never be reached,
                % either because 1) it's the first transform, and so the
                % data is loaded above or 2) the it's not the first
                % transform, and so the first transform has been performed
                error(...
                    'ImageVolume:GetCurrentImageDataForTransform:Invalid',...
                    'm3xImageData was empty.');
            end
            
            m3xImageData = obj.m3xImageData;
        end
        
        function ApplyReassignFirstVoxel(obj, oTargetImageVolumeGeometry)
            obj.m3xImageData = obj.GetCurrentImageVolumeGeometry().ReassignFirstVoxel(...
                obj.GetCurrentImageDataForTransform(), oTargetImageVolumeGeometry);            
        end
        
        function ApplyScalarDataSpatialInterpolation(obj, oTargetImageVolumeGeometry, chImageVolume3DInterpolationMethod, dImageVolumeExtrapolationValue) 
            m3xCurrentImageData = obj.GetCurrentImageDataForTransform();
            
            m3dInterpolatedData = obj.GetCurrentImageVolumeGeometry().InterpolateScalarDataMatrixOntoTargetGeometry(...
                m3xCurrentImageData, oTargetImageVolumeGeometry,...
                chImageVolume3DInterpolationMethod, dImageVolumeExtrapolationValue);
            
            if strcmp(chImageVolume3DInterpolationMethod, 'nearest') % can only retain the original class if nearest neighbour is used
                obj.m3xImageData = cast(m3dInterpolatedData, class(m3xCurrentImageData));
            else % otherwise, store as double
                obj.m3xImageData = m3dInterpolatedData;
            end                
            
            obj.dImageDataMinimumValue = double(min(obj.m3xImageData(:)));
            obj.dImageDataMaximumValue = double(max(obj.m3xImageData(:)));            
        end
        
        function ApplyImagingObjectIntensityTransform(obj, m3xNewImageData)
            obj.m3xImageData = m3xNewImageData;
                        
            obj.dImageDataMinimumValue = double(min(obj.m3xImageData(:)));
            obj.dImageDataMaximumValue = double(max(obj.m3xImageData(:)));
        end
        
        function ApplyTypeCastTransform(obj, chTypeCastClassName)
            m3xCurrentImageData = obj.GetCurrentImageDataForTransform();
                        
            xMin = cast(-inf, chTypeCastClassName);
            xMax = cast(inf, chTypeCastClassName);
            
            if any(m3xCurrentImageData(:) < xMin)
                warning(...
                    'ImageVolume:ApplyTypeCastTransform:Underflow',...
                    ['Some values with the current image data fall below the bounds of the type being cast to. These values will be clipped to be ', num2str(xMin), '.']);
                
                obj.dImageDataMinimumValue = double(xMin);
            end
            
            if any(m3xCurrentImageData(:) > xMax)
                warning(...
                    'ImageVolume:ApplyTypeCastTransform:Overflow',...
                    ['Some values with the current image data fall above the bounds of the type being cast to. These values will be clipped to be ', num2str(xMax), '.']);
                
                obj.dImageDataMaximumValue = double(xMax);
            end
            
            obj.m3xImageData = cast(m3xCurrentImageData, chTypeCastClassName);
            
            % this cast to a different type, then back to double is to
            % account for a max/min value being rounded due to the casting,
            % but the min max values in the object must of type double
            obj.dImageDataMinimumValue = double(cast(obj.dImageDataMinimumValue, chTypeCastClassName));
            obj.dImageDataMaximumValue = double(cast(obj.dImageDataMaximumValue, chTypeCastClassName));
        end
        
        function ApplyCrop(obj, m2dCropBounds, oTargetImageVolumeGeometry)
            obj.m3xImageData = obj.m3xImageData(...
                m2dCropBounds(1,1) : m2dCropBounds(1,2),...
                m2dCropBounds(2,1) : m2dCropBounds(2,2),...
                m2dCropBounds(3,1) : m2dCropBounds(3,2));
        end
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)
        
        function m3xImageData = GetImageData_ForUnitTest(obj)
            % this is useful for unit tests to be able to directly see what
            % the current state of m3xImageData, whereas using the public
            % "GetImageData()", performs necessary loading/transforms
            
            m3xImageData = obj.m3xImageData;
        end
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end