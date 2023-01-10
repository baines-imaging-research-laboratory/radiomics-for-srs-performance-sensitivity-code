classdef InteractiveImagingPlane < matlab.mixin.Copyable
    %InteractiveImagingPlane
    
    properties (SetAccess = private, GetAccess = public)
        oImagingPlaneAxes
        
        eImagingPlaneType
        dSliceDimensionSelect
        
        oRASImageVolume
        
        oImageVolumeRenderer
        dRenderGroupId
        
        vdSliceIndexBounds
                
        hSliceLocationSlider = []
        hSliceLocationSpinner = []
                
        dZoomHalfStep_mm = 3 % half-step, since this will be from each side        
    end
    
    methods (Access = public)
        
        function obj = InteractiveImagingPlane(hAxes, eImagingPlaneType, NameValueArgs)
            arguments
                hAxes (1,1) {ValidationUtils.MustBeAxes(hAxes)}
                eImagingPlaneType (1,1) ImagingPlaneTypes
                NameValueArgs.SliceLocationSpinner (1,1) matlab.ui.control.Spinner
                NameValueArgs.SliceLocationSlider (1,1) matlab.ui.control.Slider
            end
                        
            obj.oImagingPlaneAxes = ImagingPlaneAxes(hAxes);
            hAxes.Toolbar.Visible = 'off';
            
            obj.eImagingPlaneType = eImagingPlaneType;
            
            vdVolumeDimSelect = eImagingPlaneType.GetRASVolumeDimensionSelect();
            obj.dSliceDimensionSelect = vdVolumeDimSelect(3);
            
            if isfield(NameValueArgs, 'SliceLocationSpinner')
                obj.hSliceLocationSpinner = NameValueArgs.SliceLocationSpinner;
            end
            
            if isfield(NameValueArgs, 'SliceLocationSlider')
                obj.hSliceLocationSlider = NameValueArgs.SliceLocationSlider;
            end
        end
        
        function ClearAxes(obj)
            cla(obj.GetAxes());
        end
        
        function vdSliceIndexBounds = GetSliceIndexBounds(obj)
           vdSliceIndexBounds = obj.vdSliceIndexBounds; 
        end
        
        function dSliceDimensionSelect = GetSliceDimensionSelect(obj)
            dSliceDimensionSelect = obj.dSliceDimensionSelect;
        end
        
        function SetImageVolumeRenderer(obj, oImageVolumeRenderer)
            arguments
                obj
                oImageVolumeRenderer (1,1) ImageVolumeRenderer
            end
            
            obj.oImageVolumeRenderer = oImageVolumeRenderer;
            
            obj.dRenderGroupId = obj.oImageVolumeRenderer.CreateRenderGroup();
            
            obj.vdSliceIndexBounds = obj.eImagingPlaneType.GetVolumeSliceBounds(obj.oImageVolumeRenderer.GetRASImageVolume());
            
            % set slice location limits
            if ~isempty(obj.hSliceLocationSpinner)
                obj.hSliceLocationSpinner.Limits = obj.vdSliceIndexBounds;
                obj.hSliceLocationSpinner.Step = 1;
                obj.hSliceLocationSpinner.RoundFractionalValues = 1;
            end
            
            % set slice location slider limites
            if ~isempty(obj.hSliceLocationSlider)
                obj.hSliceLocationSlider.Limits = obj.vdSliceIndexBounds;
            end
        end
        
        function Initialize(obj, vdAnatomicalPlaneIndices)
            arguments
                obj (1,1) InteractiveImagingPlane
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}                
            end
            
            % get current slice index
            dCurrentSliceIndex = vdAnatomicalPlaneIndices(obj.dSliceDimensionSelect);
            
            % set slice location spinner
            if ~isempty(obj.hSliceLocationSpinner)
                obj.hSliceLocationSpinner.Value = dCurrentSliceIndex;
            end
            
            % set slice location slider
            if ~isempty(obj.hSliceLocationSlider)
                obj.hSliceLocationSlider.Value = dCurrentSliceIndex;
            end
            
            % set FOV
            oFOV = ImageVolumeFieldOfView2D(obj.oImageVolumeRenderer.GetRASImageVolume(), obj.eImagingPlaneType, obj.GetAxes());
            obj.SetImageFieldOfView(oFOV);
            
            % set slice imaging data
            obj.oImageVolumeRenderer.RenderOnPlane(obj.oImagingPlaneAxes, obj.eImagingPlaneType, vdAnatomicalPlaneIndices, obj.dRenderGroupId);            
        end
        
        function UpdateImageVolumeSlice(obj, vdAnatomicalPlaneIndices)
            arguments
                obj
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}                
            end
            
            % we can just call the ImageVolumeRenderer.RenderOnPlane
            % function, it's too slow as it calls "image" again which
            % really bogs down the render time.
            % It's more efficient to swap the CData on the current image
            % handle for both the image data and the mask overlays
            % As for the rendered lines, etc., we'll have to delete the
            % current handles, and then render the new ones.
            
            obj.oImageVolumeRenderer.UpdateRenderedOnPlaneImageVolumeSliceDataByRenderGroupId(obj.eImagingPlaneType, vdAnatomicalPlaneIndices, obj.dRenderGroupId);
            
            
            oRoiRenderer = obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer();
            
            if ~isempty(oRoiRenderer)
                % swap out mask data
                dRoiRenderGroupId = obj.oImageVolumeRenderer.GetRegionsOfInterestRenderGroupId(obj.dRenderGroupId);
                oRoiRenderer.UpdateRenderedOnPlaneMaskObjectsByRenderGroupId(obj.oImagingPlaneAxes, obj.eImagingPlaneType, vdAnatomicalPlaneIndices, dRoiRenderGroupId);
                
                obj.oImageVolumeRenderer.BringSliceIntersectionLinesToTopByRenderGroupId(obj.dRenderGroupId);
            end
            
            % update UI elements
            dSliceIndex = vdAnatomicalPlaneIndices(obj.dSliceDimensionSelect);
            
            if ~isempty(obj.hSliceLocationSlider)
                obj.hSliceLocationSlider.Value = dSliceIndex;
            end
            
            if ~isempty(obj.hSliceLocationSpinner)
                obj.hSliceLocationSpinner.Value = dSliceIndex;
            end
        end
        
        function UpdateImageVolumeSliceIntersections(obj, vdAnatomicalPlaneIndices)
            arguments
                obj
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}                
            end
            
            obj.oImageVolumeRenderer.UpdateRenderedOnPlaneSliceIntersectionsPositionsByRenderGroupId(obj.eImagingPlaneType, vdAnatomicalPlaneIndices, obj.dRenderGroupId);
        end
        
        function UpdateImageFieldOfView(obj)
            arguments
                obj                
            end
            
            obj.oImagingPlaneAxes.UpdateAxesWithFieldOfView();
        end
        
        function SetImageFieldOfView(obj, oFieldOfView)
            arguments
                obj (1,1) InteractiveImagingPlane
                oFieldOfView (1,1) ImageVolumeFieldOfView2D
            end
            
            obj.oImagingPlaneAxes.SetFieldOfView(oFieldOfView);
        end
        
        function oFieldOfView = GetCurrentImageFieldOfView(obj)
            arguments
                obj (1,1) InteractiveImagingPlane
            end
            
            oFieldOfView = obj.oImagingPlaneAxes.GetFieldOfView();
        end
        
        function SetAndUpdateImageDisplayLimits(obj, vdImageDataDisplayThreshold)
            arguments
                obj
                vdImageDataDisplayThreshold (1,2) double {mustBeFinite}                
            end
            
            obj.oImageVolumeRenderer.SetImageVolumeSliceDisplayBoundsByRenderGroupId(vdImageDataDisplayThreshold, obj.dRenderGroupId);
            obj.oImageVolumeRenderer.UpdateRenderedImageVolumeSliceByRenderGroupId(obj.dRenderGroupId);
        end
        
        function SetAndUpdateFieldOfViewFromMouse(obj, vdStartingNormalizedMousePosition, vdCurrentNormalizedMousePosition)
            obj.oImagingPlaneAxes.SetFieldOfViewCentreFromPanMouseMovement(vdStartingNormalizedMousePosition, vdCurrentNormalizedMousePosition);
            obj.UpdateImageFieldOfView();
        end
        
        % Zooming:
        function ZoomIn(obj)
            obj.oImagingPlaneAxes.ZoomInBy(obj.dZoomHalfStep_mm);
            
            obj.UpdateImageFieldOfView();
        end
        
        function ZoomOut(obj)
            obj.oImagingPlaneAxes.ZoomOutBy(obj.dZoomHalfStep_mm);
            
            obj.UpdateImageFieldOfView();
        end
        
        % Axes Size Changed
        function AxesSizeChanged(obj)
            obj.oImageVolumeRenderer.UpdateRenderOnPlaneForAxesSizeChangedByRenderGroupId(obj.dRenderGroupId);
        end
   
        
        %>>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function hAxes = GetAxes(obj)
            hAxes = obj.oImagingPlaneAxes.GetAxes();
        end
        
        function eImagingPlaneType = GetImagingPlaneType(obj)
            eImagingPlaneType = obj.eImagingPlaneType;
        end
        
        function [dMin,dMax] = GetThresholdMinMaxFromMouse(obj, vdMousePosition, dMinImageDataValue, dMaxImageDataWindow)
            vdPosVector = obj.GetNormalizedPositionVectorFromObjectCorner(vdMousePosition);
                        
            vdPosVector(vdPosVector>1) = 1;
            vdPosVector(vdPosVector<0) = 0;
            
            dLevel = vdPosVector(2)*dMaxImageDataWindow + dMinImageDataValue;
            dWindow = vdPosVector(1)*dMaxImageDataWindow;
            
            [dMin, dMax] = obj.GetMinMaxFromWindowLevel(dWindow, dLevel);
        end
        
        function [dRowScaledVoxelCoord_mm, dColScaledVoxelCoord_mm] = GetSliceLocationsFromMouse(obj, vdMousePosition)
            vdPosVector = obj.GetNormalizedPositionVectorFromObjectCorner(vdMousePosition);
            
            vdXLimits = obj.oImagingPlaneAxes.GetAxes().XLim;
            vdYLimits = obj.oImagingPlaneAxes.GetAxes().YLim;
           
            dRowScaledVoxelCoord_mm = ((vdPosVector(2) * (vdYLimits(2) - vdYLimits(1)) + vdYLimits(1) ));
            dColScaledVoxelCoord_mm = (vdXLimits(2) - (vdPosVector(1) * (vdXLimits(2) - vdXLimits(1)) ));            
        end
        
        function vdPosVector = GetNormalizedPositionVectorFromObjectCorner(obj, vdMousePosition)
            % returns position vector [x,y], where [0.5 0.5] is the centre [0 0] is
            % the lower left corner and [1 1] is the upper right corner. >1 is
            % outside the object
            
            vdPosVector = obj.GetNormalizedPositionVectorOfAxes(obj.oImagingPlaneAxes.GetAxes(), vdMousePosition);
        end
    end

    
    methods (Access = {?ImageVolumeViewerController}, Static = true)
        function [dMin, dMax] = GetMinMaxFromWindowLevel(dWindow, dLevel)
            dHalfWindow = dWindow / 2;
            
            dMin = dLevel - dHalfWindow;
            dMax = dLevel + dHalfWindow;
        end
        
        function [dWindow, dLevel] = GetWindowLevelFromMinMax(dMin, dMax)
            dWindow = dMax - dMin;
            
            dLevel = (dMin + dMax) / 2;
        end      
        
        function vdPosVector = GetNormalizedPositionVectorOfAxes(hAxes, vdMousePosition)
            % returns position vector [x,y], where [0.5 0.5] is the centre [0 0] is
            % the lower left corner and [1 1] is the upper right corner. >1 is
            % outside the object
            
            vdPosition = hAxes.Position;
            
            dX = vdPosition(1);
            dY = vdPosition(2);
            dW = vdPosition(3);
            dH = vdPosition(4);
            
            vdPosVector = (vdMousePosition - [dX,dY]) ./ [dW,dH];
        end
    end
end