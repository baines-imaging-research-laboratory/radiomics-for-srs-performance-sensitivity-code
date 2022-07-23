classdef LabelMapRegionOfInterestFieldsOfView3D < ImageVolumeViewRecord
    %LabelMapRegionOfInterestFieldsOfView3D
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Oct 13, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        ePreferred2DDisplayImagingPlaneType = ImagingPlaneTypes.Axial
    end    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = LabelMapRegionOfInterestFieldsOfView3D(varargin)
            % obj = LabelMapRegionOfInterestFieldsOfView3D(oImageVolume, dRegionOfInterestNumber)
            % obj = LabelMapRegionOfInterestFieldsOfView3D(__, __, 'RAS', oRASRegionsOfInterest)
            % obj = LabelMapRegionOfInterestFieldsOfView3D(oImageVolumeViewer)
            % obj = LabelMapRegionOfInterestFieldsOfView3D(oImageVolumeViewRecord, ePreferred2DDisplayImagingPlaneType)
            % obj = LabelMapRegionOfInterestFieldsOfView3D(vdAnatomicalPlaneIndices, voAnatomicalPlaneFieldsOfView2D, vdImageDataDisplayThreshold, ePreferred2DDisplayImagingPlaneType)
            
            ePreferred2DDisplayImagingPlaneType = [];
            
            if nargin == 1
                oImageVolumeViewer = varargin{1};
                
                % validate object
                ValidationUtils.MustBeA(oImageVolumeViewer, 'ImageVolumeViewer');
                ValidationUtils.MustBeScalar(oImageVolumeViewer);
                
                % get current ImageVolumeViewRecord
                oCurrentView = oImageVolumeViewer.GetCurrentImageVolumeView();
                
                % get values
                vdAnatomicalPlaneIndices = oCurrentView.GetAnatomicalPlaneIndices();
                vdAnatomicalPlaneFovs2D = oCurrentView.GetAnatomicalPlaneFieldsOfView2D();
                vdImageDataDisplayThreshold = oCurrentView.GetImageDataDisplayThreshold();                
            elseif nargin == 2 || (nargin == 4 && strcmp(char(varargin{3}), 'RAS'))
                if nargin == 2 && isa(varargin{1}, 'ImageVolumeViewRecord')
                    oImageVolumeViewRecord = varargin{1};
                    ePreferred2DDisplayImagingPlaneType = varargin{2};
                    
                    ValidationUtils.MustBeA(oImageVolumeViewRecord, 'ImageVolumeViewRecord');
                    ValidationUtils.MustBeScalar(oImageVolumeViewRecord);
                    
                    ValidationUtils.MustBeA(ePreferred2DDisplayImagingPlaneType, 'ImagingPlaneTypes');
                    ValidationUtils.MustBeScalar(ePreferred2DDisplayImagingPlaneType);
                    
                    vdAnatomicalPlaneIndices = oImageVolumeViewRecord.GetAnatomicalPlaneIndices();
                    vdAnatomicalPlaneFovs2D = oImageVolumeViewRecord.GetAnatomicalPlaneFieldsOfView2D();
                    vdImageDataDisplayThreshold = oImageVolumeViewRecord.GetImageDataDisplayThreshold();
                else
                    oImageVolume = varargin{1};
                    dRegionOfInterestNumber = varargin{2};
                    
                    ValidationUtils.MustBeA(oImageVolume, 'ImageVolume');
                    ValidationUtils.MustBeScalar(oImageVolume);
                    
                    MustBeValidRegionOfInterestNumbers(oImageVolume, dRegionOfInterestNumber);
                    
                    if nargin == 4
                        oRASImageVolume = varargin{4};
                        
                        ValidationUtils.MustBeA(oRASImageVolume, 'ImageVolume');
                        ValidationUtils.MustBeScalar(oRASImageVolume);
                        MustBeRAS(oRASImageVolume);
                    else
                        oRASImageVolume = copy(oImageVolume);
                        oRASImageVolume.ReassignFirstVoxelToAlignWithRASCoordinateSystem();
                    end
                    
                    [dSagittalSliceIndex, oSagittalFieldOfView2D] = oRASImageVolume.GetRegionsOfInterest().GetDefaultFieldOfViewForImagingPlaneByRegionOfInterestNumber(dRegionOfInterestNumber, ImagingPlaneTypes.Sagittal);
                    [dCoronalSliceIndex, oCoronalFieldOfView2D] = oRASImageVolume.GetRegionsOfInterest().GetDefaultFieldOfViewForImagingPlaneByRegionOfInterestNumber(dRegionOfInterestNumber, ImagingPlaneTypes.Coronal);
                    [dAxialSliceIndex, oAxialFieldOfView2D] = oRASImageVolume.GetRegionsOfInterest().GetDefaultFieldOfViewForImagingPlaneByRegionOfInterestNumber(dRegionOfInterestNumber, ImagingPlaneTypes.Axial);
                    
                    vdAnatomicalPlaneIndices = [dSagittalSliceIndex, dCoronalSliceIndex, dAxialSliceIndex];
                    vdAnatomicalPlaneFovs2D = [oSagittalFieldOfView2D, oCoronalFieldOfView2D, oAxialFieldOfView2D];
                    vdImageDataDisplayThreshold = oImageVolume.GetDefaultImageDisplayBounds(); %TODO this linerequires the image to be loaded, lots of time to create handlers if image data isn't loaded
                end
            elseif nargin == 4
                vdAnatomicalPlaneIndices = varargin{1};
                vdAnatomicalPlaneFovs2D = varargin{2};
                vdImageDataDisplayThreshold = varargin{3};
                ePreferred2DDisplayImagingPlaneType = varargin{4};
            else
                error(...
                    'LabelMapRegionOfInterestFieldsOfView3D:Constructor:InvalidParameters',...
                    'See constructor documentation for details.');
            end            
            
            % super-class class
            obj@ImageVolumeViewRecord(vdAnatomicalPlaneIndices, vdAnatomicalPlaneFovs2D, vdImageDataDisplayThreshold);
            
            % set local properities
            if ~isempty(ePreferred2DDisplayImagingPlaneType)
                obj.ePreferred2DDisplayImagingPlaneType = ePreferred2DDisplayImagingPlaneType;
            end
        end
        
        function ePreferred2DDisplayImagingPlaneType = GetPreferred2DDisplayImagingPlaneType(obj)
            ePreferred2DDisplayImagingPlaneType = obj.ePreferred2DDisplayImagingPlaneType;
        end
        
        function RenderFieldOfViewOnAxesByRegionOfInterestNumber(obj, oRASImageVolume, dRegionOfInterestNumber, oImagingPlaneAxes, NameValueArgs)
            arguments
                obj
                oRASImageVolume (1,1) {MustBeRAS}
                dRegionOfInterestNumber (1,1) double
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                NameValueArgs.ForceImagingPlaneType ImagingPlaneTypes {ValidationUtils.MustBeEmptyOrScalar}
                NameValueArgs.ShowAllRegionsOfInterest (1,1) logical = true
                NameValueArgs.LineWidth (1,1) double {mustBePositive} = 1
                NameValueArgs.LineStyle (1,1) string
                NameValueArgs.RegionOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector}
                NameValueArgs.OtherRegionsOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector}
            end
            
            if isfield(NameValueArgs, 'ForceImagingPlaneType') && ~isempty(NameValueArgs.ForceImagingPlaneType)
                eImagingPlaneType = NameValueArgs.ForceImagingPlaneType;
            else
                eImagingPlaneType = obj.ePreferred2DDisplayImagingPlaneType;
            end
            
            switch eImagingPlaneType
                case ImagingPlaneTypes.Sagittal
                    oFieldOfView = obj.voAnatomicalPlaneFieldsOfView2D(1);
                case ImagingPlaneTypes.Coronal
                    oFieldOfView = obj.voAnatomicalPlaneFieldsOfView2D(2);
                case ImagingPlaneTypes.Axial
                    oFieldOfView = obj.voAnatomicalPlaneFieldsOfView2D(3);
            end
            
            % render image data
            oImageVolumeRenderer = ImageVolumeRenderer(oRASImageVolume, oRASImageVolume);
            
            dRenderGroupId = oImageVolumeRenderer.CreateRenderGroup();
            oImageVolumeRenderer.RenderPlaneImageVolumeSlice(...
                oImagingPlaneAxes, eImagingPlaneType,...
                obj.vdAnatomicalPlaneIndices,...
                dRenderGroupId);
            
            oImageVolumeRenderer.SetImageVolumeSliceFieldOfViewByRenderGroupId(oFieldOfView, dRenderGroupId);
            oImageVolumeRenderer.SetImageVolumeSliceDisplayBoundsByRenderGroupId(obj.vdImageDataDisplayThreshold, dRenderGroupId);
            oImageVolumeRenderer.UpdateRenderedImageVolumeSliceByRenderGroupId(dRenderGroupId);
            
            % render ROI mask outline
            dRoiRenderGroupId = oImageVolumeRenderer.GetRegionsOfInterestRenderer().CreateRenderGroup();
            oImageVolumeRenderer.GetRegionsOfInterestRenderer().RenderPlaneMaskOutlineByRegionOfInterestNumber(oImagingPlaneAxes, eImagingPlaneType, obj.vdAnatomicalPlaneIndices, dRegionOfInterestNumber, dRoiRenderGroupId);
            
            oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetRegionOfInterestVoxelMaskOutlineLineWidth(dRegionOfInterestNumber, NameValueArgs.LineWidth);
            
            if isfield(NameValueArgs, 'RegionOfInterestColour')
                oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetRegionOfInterestVoxelMaskOutlineColour(dRegionOfInterestNumber, NameValueArgs.RegionOfInterestColour);
            end
            
            if isfield(NameValueArgs, 'LineStyle')
                oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetRegionOfInterestVoxelMaskOutlineLineStyle(dRegionOfInterestNumber, NameValueArgs.LineStyle);
            end
            
            oImageVolumeRenderer.GetRegionsOfInterestRenderer().UpdateVoxelMaskOutlineByRegionOfInterestNumberAndRenderGroupId(dRegionOfInterestNumber, dRoiRenderGroupId);
            
            % render other ROI mask outlines (if set to do so)
            if NameValueArgs.ShowAllRegionsOfInterest
                for dRoiIndex=1:oImageVolumeRenderer.GetImageVolume().GetNumberOfRegionsOfInterest()
                    if dRoiIndex ~= dRegionOfInterestNumber
                        oImageVolumeRenderer.GetRegionsOfInterestRenderer().RenderPlaneMaskOutlineByRegionOfInterestNumber(oImagingPlaneAxes, eImagingPlaneType, obj.vdAnatomicalPlaneIndices, dRoiIndex, dRoiRenderGroupId);
                        
                        oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetRegionOfInterestVoxelMaskOutlineLineStyle(dRoiIndex, ':');
                        oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetRegionOfInterestVoxelMaskOutlineLineWidth(dRoiIndex, 1.4*NameValueArgs.LineWidth);
                        
                        if isfield(NameValueArgs, 'OtherRegionsOfInterestColour')
                            oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetRegionOfInterestVoxelMaskOutlineColour(dRoiIndex, NameValueArgs.OtherRegionsOfInterestColour);
                        end
                        
                        oImageVolumeRenderer.GetRegionsOfInterestRenderer().UpdateVoxelMaskOutlineByRegionOfInterestNumberAndRenderGroupId(dRoiIndex, dRoiRenderGroupId);
                    end
                end
            end
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
           
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