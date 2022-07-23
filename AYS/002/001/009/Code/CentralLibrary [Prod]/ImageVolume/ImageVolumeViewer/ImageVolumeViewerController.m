classdef ImageVolumeViewerController < handle
    %InteractiveDicomViewerController
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Constant = true, GetAccess = private)        
        dFalseMouseClickBuffer_s = 0.25
        
        chLeftMouseClickLabel = 'normal'
        chRightMouseClickLabel = 'alt'
        chCentreMouseClickLabel = 'extend'
    end
    
    properties (SetAccess = private, GetAccess = public)
        % app object
        oApp = []
        
        % class objects
        oImageVolume = []
        oRASImageVolume = [] % image volume transformed to the closest RAW image volume (this is the image volume that will be passed around to the interactive imaging planes)
        
        % renderer
        oImageVolumeRenderer
        d3DRenderGroupId
        
        % ImageVolumeViewerTask
        oImageVolumeViewerTask = []
        
        % current slice/plane indices
        vdAnatomicalPlaneIndices % [sagittal coronal axial] (RAS)
        vdAnatomicalPlaneLimits % [sag low, sag high; cor low, cor high; ax low, ax high] (RAS)
        
        % current ROI (used for knowing which ROI to zoom in on,
        % auto-scroll through)
        dCurrentRegionOfInterestNumber = 1
        
        % hotkeys
        chToggleRegionsOfInterestHotkey = 's'
        chCentreCurrentRegionOfInterestHotkey = 'c'
        chToggleRegionOfInterestZoomHotkey = 'z'
        
        chAutoscrollSagittalHotkey = '1'
        chAutoscrollCoronalHotkey = '2'
        chAutoscrollAxialHotkey = '3'
        
        bControlsPopUpWaitingForHotkeySet = false
        chControlsPopUpHotkeyToSet = []
        
        % UI state flags
        bCtrlKeyPressedDown = false
        
        bLeftMouseButtonDown = false
        bRightMouseButtonDown = false
        bCentreMouseButtonDown = false
                
        % handles to UI elements
        hFigure = []
        hRegionsOfInterestPopUp = []
        hImagePopUp = []
        hImagePopUpDisplayThresholdLeftLine
        hImagePopUpDisplayThresholdRightLine
        
        oImaging3DRenderAxes = []
        
        voInteractiveImagingPlanes = []
        
        voPreviousPlaneFieldOfViews = [] % Sagittal, Coronal, Axial
                
        % Per ROI Rendering Settings
        vbDisplayRegionOfInterest                       = []
        m2dRegionOfInterestRenderColours_rgb            = []
        
        % Imaging Plane Rendering Settings
        vdImageDataDisplayThreshold                     = []
        
        bDisplayImagingPlanesVoxelOverlays              = true
        dImagingPlanesVoxelOverlaysAlpha                = 0.5
        
        bDisplayImagingPlanesVoxelOverlayOutlines       = true
        dImagingPlanesVoxelOverlayOutlinesLineWidth     = 2
        chImagingPlanesVoxelOverlayOutlinesLineStyle    = '-'
        
        bDisplayImagingPlanesSliceIntersections         = true
        dImagingPlanesSliceIntersectionsLineWidth       = 2
        chImagingPlanesSliceIntersectionsLineStyle      = '-'
          
        bDisplayImagingPlanesPolygonOverlays            = false
        bDisplayImagingPlanesPolygonOutlines            = false
        bDisplayImagingPlanesPolygonVertices            = false
        bDisplayImagingPlanesDisabledPolygons           = false
        dImagingPlanesPolygonsLineWidth                 = 2
        chImagingPlanesPolygonsLineStyle                = '-'
        chImagingPlanesPolygonsMarkerSymbol             = 'o'
        dImagingPlanesPolygonsMarkerSize                = 6
        dImagingPlanesPolygonOverlaysAlpha              = 0.5
        
        dDisabledPolygonColourShift                     = 0.3
        chImagingPlanesDisabledPolygonsLineStyle        = ':'
        
        % 3D Rendering Settings
        bAutoUpdatePlanePositions                       = false % true bogs down slice scrolling significantly
        
        bDisplay3DRenderLabels                          = true
        
        bDisplay3DRenderCardinalAxes                    = true
        bDisplay3DRenderCardinalAxesLabels              = true
        bDisplay3DRenderImagingPlanes                   = true
        bDisplay3DRenderImagingPlaneLabels              = false
        bDisplay3DRenderImagingPlaneAlignmentMarkers    = false
        bDisplay3DRenderImageVolumeOutline              = true
        bDisplay3DRenderImageVolumeDimensionsVoxels     = false
        bDisplay3DRenderImageVolumeDimensionsMetric     = false
        bDisplay3DRenderImageVolumeAxes                 = false
        bDisplay3DRenderImageVolumeAxesLabels           = false
        bDisplay3DRenderRepresentativeVoxel             = false
        bDisplay3DRenderRepresentativeVoxelLabels       = false
        bDisplay3DRenderShowRepresentativePatient       = false
        
        bDisplay3DRenderRegionsOfInterestMeshes         = true
        d3DRenderRegionsOfInterestMeshesAlpha           = 0.5
        b3DRenderRegionsOfInterestMeshesShowEdges       = false
        
        bDisplay3DRenderRegionsOfInterestPolygons       = false
        bDisplay3DRenderRegionsOfInterestPolygonOverlays = false
        bDisplay3DRenderRegionsOfInterestPolygonOutlines = false
        bDisplay3DRenderRegionsOfInterestPolygonVertices = false
        d3DRenderRegionsOfInterestPolygonsAlpha         = 0.5
        d3DRenderRegionsOfInterestPolygonsLineWidth     = 2
        ch3DRenderRegionsOfInterestPolygonsLineStyle     = '-'
        ch3DRenderRegionsOfInterestPolygonsMarkerSymbol = 'o'
        d3DRenderRegionsOfInterestPolygonsMarkerSize   = 6
        
        ch3DRenderRegionsOfInterestDisabledPolygonsLineStyle = ':'
        
        bRender3DUseFlatLighting                        = true        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PUBLIC METHODS                            *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function SetNewImageVolume(obj, oImageVolume)
            arguments
                obj (1,1) ImageVolumeViewerController
                oImageVolume (1,1) ImageVolume
            end
            
            if isempty(obj.oImaging3DRenderAxes)
                varargin = {};
            else
                varargin = {'Render3DAxesHandle', obj.oImaging3DRenderAxes.GetAxes()};
            end
            
            obj.Initialize(oImageVolume, obj.voInteractiveImagingPlanes, obj.oApp, varargin{:});
        end
        
        function SetAppVisibility(obj, chVisible)
            arguments
                obj (1,1) ImageVolumeViewerController
                chVisible (1,:) char {mustBeMember(chVisible, {'on','off'})}
            end
            
            obj.hFigure.Visible = chVisible;
        end
    end    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        FROM APP METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = ?matlab.apps.AppBase, Static = true)
        
        function startupFcn(oImageVolumeViewerApp, oImageVolume)
            if isempty(oImageVolume)
                oImageVolumeGeometry = ImageVolumeGeometry(...
                    [3 3 3], [1 0 0], [0 1 0],...
                    [1 1 1], [-1 -1 -1]);
                
                oImageVolume = MATLABImageVolume(zeros(3,3,3), oImageVolumeGeometry);
            end
            
            % Sagittal Plane
            oSagittalInteractiveImagingPlane = InteractiveImagingPlane(...
                oImageVolumeViewerApp.SagittalPlane,...
                ImagingPlaneTypes.Sagittal,...
                'SliceLocationSpinner', oImageVolumeViewerApp.SagittalPanel_SliceSpinner,...
                'SliceLocationSlider', oImageVolumeViewerApp.SagittalPanel_SliceSlider);
            
            % Coronal Plane
            oCoronalInteractiveImagingPlane = InteractiveImagingPlane(...
                oImageVolumeViewerApp.CoronalPlane,...
                ImagingPlaneTypes.Coronal,...
                'SliceLocationSpinner', oImageVolumeViewerApp.CoronalPanel_SliceSpinner,...
                'SliceLocationSlider', oImageVolumeViewerApp.CoronalPanel_SliceSlider);
            
            % Axial Plane
            oAxialInteractiveImagingPlane = InteractiveImagingPlane(...
                oImageVolumeViewerApp.AxialPlane,...
                ImagingPlaneTypes.Axial,...
                'SliceLocationSpinner', oImageVolumeViewerApp.AxialPanel_SliceSpinner,...
                'SliceLocationSlider', oImageVolumeViewerApp.AxialPanel_SliceSlider);
            
            % Interactive Viewer Controller            
            oImageVolumeViewerApp.oImageVolumeViewerController = ImageVolumeViewerController(...
                oImageVolume,...
                [oSagittalInteractiveImagingPlane, oCoronalInteractiveImagingPlane, oAxialInteractiveImagingPlane],...
                oImageVolumeViewerApp,...
                'Render3DAxesHandle', oImageVolumeViewerApp.Render3DAxes);            
                        
            % apply unified re-sizing
            oImageVolumeViewerApp.oImageVolumeViewerController.MainFigureSizeChanged(oImageVolumeViewerApp);            
        end
    end
    
    
    methods (Access = ?matlab.apps.AppBase)        
        
        function MainFigureCloseRequest(obj, oApp)
            if ~isempty(obj.oImageVolumeViewerTask)
                obj.oImageVolumeViewerTask.ImageVolumeViewerCloseRequest();
            end
            
            delete(oApp);
        end
    end
    
    
    methods (Access = ?ImageVolumeViewerTask)
        
        function hFigure = GetFigure(obj)
            hFigure = obj.hFigure;
        end
        
        function oImageVolume = GetImageVolume(obj)
            oImageVolume = obj.oImageVolume;
        end
        
        function oRASImageVolume = GetRASImageVolume(obj)
            oRASImageVolume = obj.oRASImageVolume;
        end
        
        function oRenderer = GetImageVolumeRenderer(obj)
            oRenderer = obj.oImageVolumeRenderer;
        end
    end
    
    
    methods (Access = {?matlab.apps.AppBase, ?ImageVolumeViewerTask})
            
        function SetTask(obj, oImageVolumeViewerTask)
            arguments
                obj (1,1) ImageVolumeViewerController
                oImageVolumeViewerTask (1,1) ImageVolumeViewerTask
            end
            
            obj.oImageVolumeViewerTask = oImageVolumeViewerTask;
        end
        
        function CentreOnRegionOfInterest(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) ImageVolumeViewerController
                dRegionOfInterestNumber (1,1) {MustBeValidRegionOfInterestNumber(obj, dRegionOfInterestNumber)}
            end
            
            obj.dCurrentRegionOfInterestNumber = dRegionOfInterestNumber;
            obj.CentreCurrentRegionOfInterest();
        end
        
        function SetRegionOfInterestVisibility(obj, dRegionOfInterestNumber, bVisible)
            arguments
                obj (1,1) ImageVolumeViewerController
                dRegionOfInterestNumber (1,1) {MustBeValidRegionOfInterestNumber(obj, dRegionOfInterestNumber)}
                bVisible (1,1) logical
            end
            
            obj.vbDisplayRegionOfInterest(dRegionOfInterestNumber) = bVisible;
            
            obj.SetRegionsOfInterestVisibilities();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
            obj.Update3DRenderRegionsOfInterest()
        end
        
        function SetRegionOfInterestColour(obj, dRegionOfInterestNumber, vdColour_rgb)
            arguments
                obj (1,1) ImageVolumeViewerController
                dRegionOfInterestNumber (1,1) {MustBeValidRegionOfInterestNumber(obj, dRegionOfInterestNumber)}
                vdColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdColour_rgb)}
            end
            
            obj.m2dRegionOfInterestRenderColours_rgb(dRegionOfInterestNumber,:) = vdColour_rgb;
            
            obj.SetRegionsOfInterestColours();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
            obj.Update3DRenderRegionsOfInterest();
        end
        
        function SetRegionOfInterestVoxelMaskOverlayVisibility(obj, bVisible)
            arguments
                obj (1,1) ImageVolumeViewerController
                bVisible (1,1) logical
            end
            
            obj.bDisplayImagingPlanesVoxelOverlays = bVisible;
            
            obj.SetOnPlaneRegionsOfInterestVoxelMaskOverlaysVisibility();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
        end
        
        function SetRegionOfInterestVoxelMaskOutlineLineWidth(obj, dLineWidth)
            arguments
                obj (1,1) ImageVolumeViewerController
                dLineWidth (1,1) double {mustBePositive, mustBeFinite}
            end
            
            obj.dImagingPlanesVoxelOverlayOutlinesLineWidth = dLineWidth;
            
            obj.SetOnPlaneRegionsOfInterestOverlaysLineWidth();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
        end
        
        function SetCurrentImageVolumeView(obj, oImageVolumeViewRecord)
            arguments
                obj (1,1) ImageVolumeViewerController
                oImageVolumeViewRecord (1,1) ImageVolumeViewRecord
            end
            
            % set window/level
            obj.vdImageDataDisplayThreshold = oImageVolumeViewRecord.GetImageDataDisplayThreshold();
            obj.UpdateInteractiveImagingPlanesDisplayLimits();
            
            % set slice indices
            vdAnatomicalPlaneIndices = oImageVolumeViewRecord.GetAnatomicalPlaneIndices();
            
            obj.SetSlice(ImagingPlaneTypes.Sagittal, vdAnatomicalPlaneIndices(1));
            obj.SetSlice(ImagingPlaneTypes.Coronal, vdAnatomicalPlaneIndices(2));
            obj.SetSlice(ImagingPlaneTypes.Axial, vdAnatomicalPlaneIndices(3));
            
            % set plane FOVs            
            voAnatomicalFovs2D = oImageVolumeViewRecord.GetAnatomicalPlaneFieldsOfView2D();
            voPlanes = obj.GetInteractiveImagingPlanes();
            
            for dPlaneIndex=1:length(voPlanes)
                voPlanes(dPlaneIndex).SetImageFieldOfView(voAnatomicalFovs2D(voPlanes(dPlaneIndex).GetSliceDimensionSelect()));
                voPlanes(dPlaneIndex).UpdateImageFieldOfView();
            end
        end
        
        function SetImageDataDisplayThreshold(obj, vdImageDataDisplayThreshold)
            arguments
                obj (1,1) ImageVolumeViewerController
                vdImageDataDisplayThreshold (1,2) double {ValidationUtils.MustBeIncreasing(vdImageDataDisplayThreshold)}
            end
            
            % set window/level
            obj.vdImageDataDisplayThreshold = vdImageDataDisplayThreshold;
            obj.UpdateInteractiveImagingPlanesDisplayLimits();
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function oImageVolumeViewRecord = GetCurrentImageVolumeView(obj)
            vdAnatomicalInteractiveImagingPlaneIndices = nan(1,3);            
            voPlanes = obj.GetInteractiveImagingPlanes();
            
            for dPlaneIndex=1:length(voPlanes)
                dAnatomicalIndex = voPlanes(dPlaneIndex).GetSliceDimensionSelect();
                
                if isnan(vdAnatomicalInteractiveImagingPlaneIndices(dAnatomicalIndex))
                    vdAnatomicalInteractiveImagingPlaneIndices(dAnatomicalIndex) = dPlaneIndex;
                else
                    warning(...
                        'ImageVolumeViewerController:GetCurrentImageVolumeView:MultiplePlanesFound',...
                        'Multiple views of the same anatomical planes were found. The view from the first will be used.');
                end
            end
            
            if any(isnan(vdAnatomicalInteractiveImagingPlaneIndices))
                error(...
                    'ImageVolumeViewerController:GetCurrentImageVolumeView:AnatomicalPlaneMissing',...
                    'One or more anatomical planes were not found, and so a complete image volume view cannot be created.');
            end
            
            voAnatomicalPlanesFovs2D = [...
                voPlanes(vdAnatomicalInteractiveImagingPlaneIndices(1)).GetCurrentImageFieldOfView(),...
                voPlanes(vdAnatomicalInteractiveImagingPlaneIndices(2)).GetCurrentImageFieldOfView(),...
                voPlanes(vdAnatomicalInteractiveImagingPlaneIndices(3)).GetCurrentImageFieldOfView()];
            
            oImageVolumeViewRecord = ImageVolumeViewRecord(...
                obj.vdAnatomicalPlaneIndices,...
                voAnatomicalPlanesFovs2D,...
                obj.vdImageDataDisplayThreshold);
        end
        
        
        
        % >>>>>>>>>>>>>>>>>>>> CALLBACKS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        % Slice Index Sliders:
        function SagittalSliceSliderValueChanging(obj, oEvent)
            obj.SetSlice(ImagingPlaneTypes.Sagittal, oEvent.Value);
        end
        
        function CoronalSliceSliderValueChanging(obj, oEvent)
            obj.SetSlice(ImagingPlaneTypes.Coronal, oEvent.Value);
        end
        
        function AxialSliceSliderValueChanging(obj, oEvent)
            obj.SetSlice(ImagingPlaneTypes.Axial, oEvent.Value);
        end
        
        % Slice Index Spinners:
        function SagittalSliceSpinnerValueChanged(obj, oEvent)
            obj.SetSlice(ImagingPlaneTypes.Sagittal, oEvent.Value);
        end
        
        function CoronalSliceSpinnerValueChanged(obj, oEvent)
            obj.SetSlice(ImagingPlaneTypes.Coronal, oEvent.Value);
        end
        
        function AxialSliceSpinnerValueChanged(obj, oEvent)
            obj.SetSlice(ImagingPlaneTypes.Axial, oEvent.Value);
        end
        
        % Mouse Interactions
        function MainFigureWindowScrollWheel(obj, oEvent)
                        
            dVerticalScrollCount = oEvent.VerticalScrollCount;
            
            c1oAxesHandles = obj.GetInteractiveImagingPlanesAxes();
            voInteractivePlanes = obj.GetInteractiveImagingPlanes();
            
            dSelectedIndex = obj.FindAppObjectMouseIsOver(obj.hFigure, c1oAxesHandles);
            
            if dSelectedIndex ~= 0 % is over an axis
                oInteractivePlane = voInteractivePlanes(dSelectedIndex);
                
                if obj.bCtrlKeyPressedDown % zooming
                    if dVerticalScrollCount == 1
                        % zoom out
                        oInteractivePlane.ZoomOut();
                    else
                        % zoom in
                        oInteractivePlane.ZoomIn();
                    end
                    
                    % clear out any cached FOVs (only needed for ROI zoom
                    % toggling)
                    obj.voPreviousPlaneFieldOfViews = [];
                else % slice select
                    if dVerticalScrollCount == 1
                        % slice select down
                        obj.DecrementSlice(oInteractivePlane.GetImagingPlaneType());
                    else
                        % slice select up
                        obj.IncrementSlice(oInteractivePlane.GetImagingPlaneType());
                    end                    
                end
            end
        end
        
        function MainFigureWindowButtonDown(obj, oEvent)
            %[] = figureWindowButtonDown(obj, event)
            
            switch oEvent.Source.SelectionType
                case obj.chLeftMouseClickLabel % window/level
                    obj.bLeftMouseButtonDown = true;
                    
                    pause(obj.dFalseMouseClickBuffer_s); % prevents quick clicks from being registered
                    
                    c1oAxesHandles = obj.GetInteractiveImagingPlanesAxes();
                    voImagingPlanes = obj.GetInteractiveImagingPlanes();
                                        
                    dSelectedIndex = obj.FindAppObjectMouseIsOver(obj.hFigure, c1oAxesHandles);
                    
                    if dSelectedIndex ~= 0                        
                        oInteractivePlane = voImagingPlanes(dSelectedIndex);
                        
                        [eRowImagingPlaneType, eColImagingPlaneType] = oInteractivePlane.GetImagingPlaneType().GetPerpendicularImagingPlaneTypes();
                        
                        eRowInteractivePlaneType = [];
                        eColInteractivePlaneType = [];
                        
                        for dPlaneIndex=1:length(voImagingPlanes)
                            if voImagingPlanes(dPlaneIndex).GetImagingPlaneType() == eRowImagingPlaneType
                                eRowInteractivePlaneType = voImagingPlanes(dPlaneIndex).GetImagingPlaneType();
                            elseif voImagingPlanes(dPlaneIndex).GetImagingPlaneType() == eColImagingPlaneType
                                eColInteractivePlaneType = voImagingPlanes(dPlaneIndex).GetImagingPlaneType();
                            end
                        end
                        
                        dMinImageDataValue = obj.oImageVolume.GetImageDataMinimumValue();
                        dMaxImageDataWindow = obj.oImageVolume.GetImageDataMaximumWindow();
                        
                        vdVoxelDimensions_mm = oInteractivePlane.GetImagingPlaneType.GetVoxelDimensions_mm(obj.oRASImageVolume);
                        
                        while obj.bLeftMouseButtonDown
                            if obj.bCtrlKeyPressedDown
                                [dScaledRowCoord_mm, dScaledColCoord_mm] = oInteractivePlane.GetSliceLocationsFromMouse(obj.hFigure.CurrentPoint);
                                [dRowSliceIndex, dColSliceIndex] = GeometricalImagingObjectRenderer.GetVoxelCoordinatesFromScaledVoxelCoordinates(...
                                    dScaledRowCoord_mm, dScaledColCoord_mm,...
                                    vdVoxelDimensions_mm(1), vdVoxelDimensions_mm(2));
                                
                                if ~isempty(eRowInteractivePlaneType)
                                    obj.SetSlice(eRowInteractivePlaneType, dRowSliceIndex);
                                end
                                
                                if ~isempty(eColInteractivePlaneType)
                                    obj.SetSlice(eColInteractivePlaneType, dColSliceIndex);
                                end
                            else % Window/Level Change
                                [dMin,dMax] = oInteractivePlane.GetThresholdMinMaxFromMouse(obj.hFigure.CurrentPoint, dMinImageDataValue, dMaxImageDataWindow);
                                
                                obj.vdImageDataDisplayThreshold = [dMin dMax];
                                
                                obj.UpdateInteractiveImagingPlanesDisplayLimits();
                            end
                            
                            drawnow;
                        end
                    end
                case obj.chCentreMouseClickLabel % pan view
                    obj.bCentreMouseButtonDown = true;
                    
                    pause(obj.dFalseMouseClickBuffer_s); % prevents quick clicks from being registered
                    
                    % find starting point at slick
                    c1oAxesHandles = obj.GetInteractiveImagingPlanesAxes();
                    voImagingPlanes = obj.GetInteractiveImagingPlanes();
                    
                    dSelectedIndex = obj.FindAppObjectMouseIsOver(obj.hFigure, c1oAxesHandles);
                    
                    vdLastNormalizedPosition = voImagingPlanes(dSelectedIndex).GetNormalizedPositionVectorFromObjectCorner(obj.hFigure.CurrentPoint);
                    
                    while obj.bCentreMouseButtonDown
                        vdCurrentNormalizedPosition = voImagingPlanes(dSelectedIndex).GetNormalizedPositionVectorFromObjectCorner(obj.hFigure.CurrentPoint);
                        
                        voImagingPlanes(dSelectedIndex).SetAndUpdateFieldOfViewFromMouse(...
                            vdLastNormalizedPosition, vdCurrentNormalizedPosition);
                        
                        vdLastNormalizedPosition = vdCurrentNormalizedPosition;
                        
                        drawnow;
                    end
                case obj.chRightMouseClickLabel % this is triggered for right click AND ctrl + left click
                    obj.bRightMouseButtonDown = true;
                    
                    if ~obj.bCtrlKeyPressedDown
                        pause(obj.dFalseMouseClickBuffer_s); % prevents quick clicks from being registered
                    end
                    
                    c1oAxesHandles = obj.GetInteractiveImagingPlanesAxes();
                    voImagingPlanes = obj.GetInteractiveImagingPlanes();
                                        
                    dSelectedIndex = obj.FindAppObjectMouseIsOver(obj.hFigure, c1oAxesHandles);
                    
                    if dSelectedIndex ~= 0
                            
                        oInteractivePlane = voImagingPlanes(dSelectedIndex);
                        
                        [eRowImagingPlaneType, eColImagingPlaneType] = oInteractivePlane.GetImagingPlaneType().GetPerpendicularImagingPlaneTypes();
                        
                        eRowInteractivePlaneType = [];
                        eColInteractivePlaneType = [];
                        
                        for dPlaneIndex=1:length(voImagingPlanes)
                            if voImagingPlanes(dPlaneIndex).GetImagingPlaneType() == eRowImagingPlaneType
                                eRowInteractivePlaneType = voImagingPlanes(dPlaneIndex).GetImagingPlaneType();
                            elseif voImagingPlanes(dPlaneIndex).GetImagingPlaneType() == eColImagingPlaneType
                                eColInteractivePlaneType = voImagingPlanes(dPlaneIndex).GetImagingPlaneType();
                            end
                        end   
                        
                        vdLastNormalizedPosition = voImagingPlanes(dSelectedIndex).GetNormalizedPositionVectorFromObjectCorner(obj.hFigure.CurrentPoint);
                        
                        bStartingCtrlKeyPressedDown = obj.bCtrlKeyPressedDown;
                        
                        vdVoxelDimensions_mm = oInteractivePlane.GetImagingPlaneType.GetVoxelDimensions_mm(obj.oRASImageVolume);
                        
                        while obj.bRightMouseButtonDown && ( bStartingCtrlKeyPressedDown == obj.bCtrlKeyPressedDown )
                            if obj.bCtrlKeyPressedDown
                                [dScaledRowCoord_mm, dScaledColCoord_mm] = oInteractivePlane.GetSliceLocationsFromMouse(obj.hFigure.CurrentPoint);
                                [dRowSliceIndex, dColSliceIndex] = GeometricalImagingObjectRenderer.GetVoxelCoordinatesFromScaledVoxelCoordinates(...
                                    dScaledRowCoord_mm, dScaledColCoord_mm,...
                                    vdVoxelDimensions_mm(1), vdVoxelDimensions_mm(2));
                                
                                if ~isempty(eRowInteractivePlaneType)
                                    obj.SetSlice(eRowInteractivePlaneType, dRowSliceIndex);
                                end
                                
                                if ~isempty(eColInteractivePlaneType)
                                    obj.SetSlice(eColInteractivePlaneType, dColSliceIndex);
                                end
                            else
                                vdCurrentNormalizedPosition = voImagingPlanes(dSelectedIndex).GetNormalizedPositionVectorFromObjectCorner(obj.hFigure.CurrentPoint);
                                
                                voImagingPlanes(dSelectedIndex).SetAndUpdateFieldOfViewFromMouse(...
                                    vdLastNormalizedPosition, vdCurrentNormalizedPosition);
                                
                                vdLastNormalizedPosition = vdCurrentNormalizedPosition;
                            end
                            
                            drawnow;
                        end
                    end
            end
        end
        
        function MainFigureWindowButtonMotion(obj)
            % [] = figureWindowButtonMotion(obj)
        end
        
        function MainFigureWindowButtonUp(obj)
            %[] = figureWindowButtonUp(obj)
            
            drawnow; % needed to interupt click & drag callbacks
            
            obj.bLeftMouseButtonDown = false;
            obj.bRightMouseButtonDown = false;
            obj.bCentreMouseButtonDown = false;
        end
        
        % Keyboard Interactions:
        
        function MainFigureKeyPress(obj, oEvent)
            ckKey = oEvent.Key;
            
            switch ckKey
                case 'control'                    
                    obj.bCtrlKeyPressedDown = true;
            end
        end
        
        function bEventOccurred = MainFigureKeyRelease(obj, oEvent)
            %bEventOccurred = figureKeyRelease(obj, event)
            
            chKey = oEvent.Key;
            bEventOccurred = true;
            
            switch chKey
                case 'control'
                    obj.bCtrlKeyPressedDown = false;
                case obj.chToggleRegionsOfInterestHotkey
                    obj.ToggleRegionsOfInterestVisibility();
                case obj.chCentreCurrentRegionOfInterestHotkey
                    obj.CentreCurrentRegionOfInterest();
                case obj.chToggleRegionOfInterestZoomHotkey
                    obj.ToggleRegionOfInterestZoom();
                case obj.chAutoscrollSagittalHotkey
                    obj.AutoscrollInteractiveImagingPlane(ImagingPlaneTypes.Sagittal);
                case obj.chAutoscrollCoronalHotkey
                    obj.AutoscrollInteractiveImagingPlane(ImagingPlaneTypes.Coronal);
                case obj.chAutoscrollAxialHotkey
                    obj.AutoscrollInteractiveImagingPlane(ImagingPlaneTypes.Axial);
                otherwise
                    if ~isempty(obj.oImageVolumeViewerTask)
                        obj.oImageVolumeViewerTask.ProcessKeyPress(chKey);
                    end
            end
        end
          
        % Figure Size Changed        
        function MainFigureSizeChanged(obj, app)
            
            dPlaneHeaderSpaceHeight_px = 30;
            dPlaneHeaderTrueHeight_px = 50;
            
            dButtonWidth_px = 100;
            dButtonSpacing_px = 3;
            dButtonHeight_px = dPlaneHeaderSpaceHeight_px - 2*dButtonSpacing_px;
            
            dButtonAreaWidth_px = 4*dButtonWidth_px + 5*dButtonSpacing_px;
            
            % Get current figure size
            app.MainFigure.Units = 'pixels';
            
            vdCurrentPosition = app.MainFigure.Position;
            
            dWidth_px = vdCurrentPosition(3);
            dHeight_px = vdCurrentPosition(4);
            
            dWidthPerPlane_px = dWidth_px ./ 2;
            dHeightPerPlane_px = (dHeight_px-2*dPlaneHeaderSpaceHeight_px) ./ 2;
            
            % Resize/Reposition Axes
            app.AxialPlane.Units = 'pixels';
            app.AxialPlane.Position = [...
                dWidthPerPlane_px + 1,...
                dHeightPerPlane_px + dPlaneHeaderSpaceHeight_px + 1,...
                dWidthPerPlane_px,...
                dHeightPerPlane_px];
            
            app.CoronalPlane.Units = 'pixels';
            app.CoronalPlane.Position = [...
                dWidthPerPlane_px + 1,...
                1,...
                dWidthPerPlane_px,...
                dHeightPerPlane_px];
            
            app.SagittalPlane.Units = 'pixels';
            app.SagittalPlane.Position = [...
                1,...
                1,...
                dWidthPerPlane_px,...
                dHeightPerPlane_px];
            
            app.Render3DAxes.Units = 'pixels';
            app.Render3DAxes.Position = [...
                1,...
                dHeightPerPlane_px + dPlaneHeaderSpaceHeight_px + 1,...
                dWidthPerPlane_px,...
                dHeightPerPlane_px];
            
            % Resize/Reposition Header Panels
            app.AxialPanel.Units = 'pixels';
            app.AxialPanel.Position = [...
                dWidthPerPlane_px + 1,...
                2*dHeightPerPlane_px + dPlaneHeaderSpaceHeight_px + 1,...
                dWidthPerPlane_px,...
                dPlaneHeaderTrueHeight_px];
            
            obj.PlanePanelSizeChanged(...
                app.AxialPanel,...
                app.AxialPanel_MaximizeButton, app.AxialPanel_SliceSlider, app.AxialPanel_SliceSpinner,...
                dButtonHeight_px, dButtonSpacing_px);
            
            app.CoronalPanel.Units = 'pixels';
            app.CoronalPanel.Position = [...
                dWidthPerPlane_px + 1,...
                dHeightPerPlane_px + 1,...
                dWidthPerPlane_px,...
                dPlaneHeaderTrueHeight_px];
            
            obj.PlanePanelSizeChanged(...
                app.CoronalPanel,...
                app.CoronalPanel_MaximizeButton, app.CoronalPanel_SliceSlider, app.CoronalPanel_SliceSpinner,...
                dButtonHeight_px, dButtonSpacing_px);
            
            app.SagittalPanel.Units = 'pixels';
            app.SagittalPanel.Position = [...
                1,...
                dHeightPerPlane_px + 1,...
                dWidthPerPlane_px,...
                dPlaneHeaderTrueHeight_px];
            
            obj.PlanePanelSizeChanged(...
                app.SagittalPanel,...
                app.SagittalPanel_MaximizeButton, app.SagittalPanel_SliceSlider, app.SagittalPanel_SliceSpinner,...
                dButtonHeight_px, dButtonSpacing_px);
            
            app.Render3DPanel.Units = 'pixels';
            app.Render3DPanel.Position = [...
                dButtonAreaWidth_px + 1,...
                2*dHeightPerPlane_px + dPlaneHeaderSpaceHeight_px + 1,...
                dWidthPerPlane_px - dButtonAreaWidth_px,...
                dPlaneHeaderTrueHeight_px];
            
            % set render 3D panel
            app.Render3DPanel_MaximizeButton.Position = [...
                dButtonSpacing_px + 1,...
                dButtonSpacing_px + 1,...
                dButtonHeight_px,... % width = height to make a squre button
                dButtonHeight_px];
            
            % Resize/Reposition Buttons
            
            app.ImageButton.Position = [...
                dButtonSpacing_px + 1,...
                2*dHeightPerPlane_px + dPlaneHeaderSpaceHeight_px + dButtonSpacing_px + 1,...
                dButtonWidth_px,...
                dButtonHeight_px];
            
            app.ROIButton.Position = [...
                2*dButtonSpacing_px + dButtonWidth_px + 1,...
                2*dHeightPerPlane_px + dPlaneHeaderSpaceHeight_px + dButtonSpacing_px + 1,...
                dButtonWidth_px,...
                dButtonHeight_px];
            
            app.GeometryButton.Position = [...
                3*dButtonSpacing_px + 2*dButtonWidth_px + 1,...
                2*dHeightPerPlane_px + dPlaneHeaderSpaceHeight_px + dButtonSpacing_px + 1,...
                dButtonWidth_px,...
                dButtonHeight_px];
            
            app.ControlsButton.Position = [...
                4*dButtonSpacing_px + 3*dButtonWidth_px + 1,...
                2*dHeightPerPlane_px + dPlaneHeaderSpaceHeight_px + dButtonSpacing_px + 1,...
                dButtonWidth_px,...
                dButtonHeight_px];
            
            
            % Resize FOVs
            voInteractiveImagingPlanes = obj.GetInteractiveImagingPlanes();
            
            for dIndex=1:length(voInteractiveImagingPlanes)
                voInteractiveImagingPlanes(dIndex).AxesSizeChanged();
            end
            
        end
        
        % >>>>>>>>>>>>>>>>>>> Controls Pop-Up <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function ControlsButtonPushed(obj)
            ImageVolumeViewer_ControlsPopUp(obj);
        end
        
        function ControlsPopUp_startupFcn(obj, hControlsPopUpApp)
            hControlsPopUpApp.oImageVolumeViewerController = obj;
            
            hControlsPopUpApp.HotkeyPromptPanel.Visible = 'off';
            
            hControlsPopUpApp.ToggleROIsHotkeyLabel.Text = obj.chToggleRegionsOfInterestHotkey;
            hControlsPopUpApp.CentreCurrentROIHotkeyLabel.Text = obj.chCentreCurrentRegionOfInterestHotkey;
            hControlsPopUpApp.ToggleROIZoomHotkeyLabel.Text = obj.chToggleRegionOfInterestZoomHotkey;
            
            hControlsPopUpApp.AutoscrollROISagittalHotkeyLabel.Text = obj.chAutoscrollSagittalHotkey;
            hControlsPopUpApp.AutoscrollROICoronalHotkeyLabel.Text = obj.chAutoscrollCoronalHotkey;
            hControlsPopUpApp.AutoscrollROIAxialHotkeyLabel.Text = obj.chAutoscrollAxialHotkey;
        end
        
        function ControlPopUp_HotkeySetButtonPushed(obj, hControlsPopUpApp, chHotkey)
            hControlsPopUpApp.HotkeyPromptPanel.Visible = 'on';
            
            obj.bControlsPopUpWaitingForHotkeySet = true;
            obj.chControlsPopUpHotkeyToSet = chHotkey;
        end
        
        function ControlPopUp_MainFigureWindowKeyPress(obj, hControlsPopUpApp, oEvent)
            chKey = oEvent.Key;
            
            if obj.bControlsPopUpWaitingForHotkeySet && ~strcmp(chKey, 'control')
                hControlsPopUpApp.HotkeyPromptPanel.Visible = 'off';
                
                switch obj.chControlsPopUpHotkeyToSet
                    case 'ToggleRegionsOfInterest'
                        obj.chToggleRegionsOfInterestHotkey = chKey;
                        hControlsPopUpApp.ToggleROIsHotkeyLabel.Text = chKey;
                    case 'CentreCurrentRegionOfInterest'
                        obj.chCentreCurrentRegionOfInterestHotkey = chKey;
                        hControlsPopUpApp.CentreCurrentROIHotkeyLabel.Text = chKey;
                    case 'ToggleRegionOfInterestZoom'
                        obj.chToggleRegionOfInterestZoomHotkey = chKey;
                        hControlsPopUpApp.ToggleROIZoomHotkeyLabel.Text = chKey;
                    case 'AutoscrollSagittal'
                        obj.chAutoscrollSagittalHotkey = chKey;
                        hControlsPopUpApp.AutoscrollROISagittalHotkeyLabel.Text = chKey;
                    case 'AutoscrollCoronal'
                        obj.chAutoscrollCoronalHotkey = chKey;
                        hControlsPopUpApp.AutoscrollROICoronalHotkeyLabel.Text = chKey;
                    case 'AutoscrollAxial'
                        obj.chAutoscrollAxialHotkey = chKey;
                        hControlsPopUpApp.AutoscrollROIAxialHotkeyLabel.Text = chKey;
                end
                
                obj.bControlsPopUpWaitingForHotkeySet = false;
                obj.chControlsPopUpHotkeyToSet = [];
            end   
        end
        
        
        % >>>>>>>>>>>>>>>>> 3D Render Controls <<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function Render3DPanel_MaximizeButtonPushed(obj)
        end
        
        
        %  >>>>>>>>>>>>>>>>>>> Regions of Interest Popup <<<<<<<<<<<<<<<<<<
        
        function ROIButtonPushed(obj)
            ImageVolumeViewer_RegionsOfInterestPopUp(obj);
        end
        
        function RegionsOfInterestPopUp_startupFcn(obj, hAppRoiPopUp)
            % link up the new app with the controller
            hAppRoiPopUp.oImageVolumeViewerController = obj;
            
            oRois = obj.oImageVolume.GetRegionsOfInterest();
            
            if isa(oRois, 'LabelMapRegionsOfInterest')
                % get column headers/data ready
                c1xColumnNames = {'#', 'Show', 'Current', 'Colour [RGB]'};
                c1xColumnWidths = {25, 40, 50, 100};
                c1bColumnEditable = [false, true, true, false];
                                
                vsRoiNames = oRois.GetRegionsOfInterestNames();
                vsRoiLabels = oRois.GetRegionsOfInterestObservationLabels();
                vsRoiTypes = oRois.GetRegionsOfInterestInterpretedTypes();
                vdRoiLabelMapNumbers = oRois.GetRegionsOfInterestLabelMapNumbers();
                
                c1xExtraColumnValues = {};
                
                if ~isempty(vsRoiNames)
                    c1xColumnNames = [c1xColumnNames, {'Name'}];
                    c1xColumnWidths = [c1xColumnWidths, {'auto'}];
                    c1bColumnEditable = [c1bColumnEditable, false];
                    
                    c1xExtraColumnValues = [c1xExtraColumnValues, {vsRoiNames}];
                end
                
                if ~isempty(vsRoiLabels)
                    c1xColumnNames = [c1xColumnNames, {'Label'}];
                    c1xColumnWidths = [c1xColumnWidths, {'auto'}];
                    c1bColumnEditable = [c1bColumnEditable, false];
                    
                    c1xExtraColumnValues = [c1xExtraColumnValues, {vsRoiLabels}];
                end
                
                if ~isempty(vsRoiTypes)
                    c1xColumnNames = [c1xColumnNames, {'Type'}];
                    c1xColumnWidths = [c1xColumnWidths, {'auto'}];
                    c1bColumnEditable = [c1bColumnEditable, false];
                    
                    c1xExtraColumnValues = [c1xExtraColumnValues, {vsRoiTypes}];
                end
                
                if ~isempty(vdRoiLabelMapNumbers)
                    c1xColumnNames = [c1xColumnNames, {'Labelmap #'}];
                    c1xColumnWidths = [c1xColumnWidths, {'auto'}];
                    c1bColumnEditable = [c1bColumnEditable, false];
                    
                    c1xExtraColumnValues = [c1xExtraColumnValues, {vdRoiLabelMapNumbers}];
                end
                
                if isa(oRois, 'RegionsOfInterestFromPolygons')
                    c1xColumnNames = [c1xColumnNames, {'Enabled', '# Polygons Enabled'}];
                    c1xColumnWidths = [c1xColumnWidths, {50, 'auto'}];
                    c1bColumnEditable = [c1bColumnEditable, false, false];
                    
                    vbEnabled = oRois.AreRegionsOfInterestPolygonsEnabled();
                    
                    dNumRois = oRois.GetNumberOfRegionsOfInterest();
                    
                    vsNumEnabledStrings = strings(dNumRois,1);
                    
                    for dRoiIndex=1:dNumRois
                        vbPolyEnabled = oRois.IsPolygonEnabledByRegionOfInterestNumber(dRoiIndex);
                        
                        dNumPolys = length(vbPolyEnabled);
                        dNumEnabled = sum(vbPolyEnabled);
                        
                        vsNumEnabledStrings(dRoiIndex) = string([num2str(dNumEnabled), '/', num2str(dNumPolys)]);
                    end
                    
                    c1xExtraColumnValues = [c1xExtraColumnValues, {vbEnabled, vsNumEnabledStrings}];
                end
                
                % construct table                
                dNumColumns = length(c1xColumnNames);
                dNumRows = oRois.GetNumberOfRegionsOfInterest();
                
                c2xTableData = cell(dNumRows,dNumColumns);
                
                for dRoiNumber=1:dNumRows
                    c2xTableData{dRoiNumber,1} = dRoiNumber;
                    c2xTableData{dRoiNumber,2} = obj.vbDisplayRegionOfInterest(dRoiNumber);
                    c2xTableData{dRoiNumber,3} = ( obj.dCurrentRegionOfInterestNumber == dRoiNumber );
                    c2xTableData{dRoiNumber,4} = ImageVolumeViewerController.RgbToStr(obj.m2dRegionOfInterestRenderColours_rgb(dRoiNumber,:));
                    
                    for dExtraColumnIndex=1:length(c1xExtraColumnValues)
                        xVal = c1xExtraColumnValues{dExtraColumnIndex}(dRoiNumber);
                        
                        if isstring(xVal)
                            xVal = char(xVal);
                        end
                        
                        c2xTableData{dRoiNumber,4+dExtraColumnIndex} = xVal;                        
                    end
                end                
                
                % set the ROI data table
                hAppRoiPopUp.SelectionUITable.Data = c2xTableData;
                hAppRoiPopUp.SelectionUITable.ColumnName = c1xColumnNames;
                hAppRoiPopUp.SelectionUITable.ColumnWidth = c1xColumnWidths;
                hAppRoiPopUp.SelectionUITable.ColumnEditable = c1bColumnEditable;
            else
                hAppRoiPopUp.SelectionUITable.Enable = 'off';
            end
            
            % set the imaging plane display settings
            hAppRoiPopUp.OverlayTransparencySlider.Value = obj.dImagingPlanesVoxelOverlaysAlpha;
            hAppRoiPopUp.LineWidthSlider.Value = obj.dImagingPlanesVoxelOverlayOutlinesLineWidth;
            
            % Voxel mask settings
            hAppRoiPopUp.VoxelOverlayCheckBox.Value = obj.bDisplayImagingPlanesVoxelOverlays;
            hAppRoiPopUp.BorderCheckBox.Value = obj.bDisplayImagingPlanesVoxelOverlayOutlines;
            
            % polygon settings
            if obj.DoRegionsOfInterestHavePolygons()
                chEnable = 'on';
                
                hAppRoiPopUp.ContourPolygonsVoxelOverlayCheckBox.Value = obj.bDisplayImagingPlanesPolygonOverlays;
                hAppRoiPopUp.ContourPolygonsBorderCheckBox.Value = obj.bDisplayImagingPlanesPolygonOutlines;
                hAppRoiPopUp.ContourPolygonsVerticesCheckBox.Value = obj.bDisplayImagingPlanesPolygonVertices;
                hAppRoiPopUp.ContourPolygonsShowDisabledPolygonsCheckBox.Value = obj.bDisplayImagingPlanesDisabledPolygons;
                hAppRoiPopUp.ContourPolygonsShowIn3DRenderCheckBox.Value = obj.bDisplay3DRenderRegionsOfInterestPolygons;
            else
                chEnable = 'off';
                
                hAppRoiPopUp.ContourPolygonsVoxelOverlayCheckBox.Value = false;
                hAppRoiPopUp.ContourPolygonsBorderCheckBox.Value = false;
                hAppRoiPopUp.ContourPolygonsVerticesCheckBox.Value = false;
                hAppRoiPopUp.ContourPolygonsShowDisabledPolygonsCheckBox.Value = false;
                hAppRoiPopUp.ContourPolygonsShowIn3DRenderCheckBox.Value = false;
            end
            
            hAppRoiPopUp.ContourPolygonsVoxelOverlayCheckBox.Enable = chEnable;
            hAppRoiPopUp.ContourPolygonsBorderCheckBox.Enable = chEnable;
            hAppRoiPopUp.ContourPolygonsVerticesCheckBox.Enable = chEnable;
            hAppRoiPopUp.ContourPolygonsShowDisabledPolygonsCheckBox.Enable = chEnable;
            hAppRoiPopUp.ContourPolygonsShowIn3DRenderCheckBox.Enable = chEnable;
            
            % set 3D render settings
            hAppRoiPopUp.Render3DTransparencySlider.Value = obj.d3DRenderRegionsOfInterestMeshesAlpha;
            hAppRoiPopUp.Render3DMeshesCheckBox.Value = obj.bDisplay3DRenderRegionsOfInterestMeshes;
            hAppRoiPopUp.Render3DEdgesCheckBox.Value = obj.b3DRenderRegionsOfInterestMeshesShowEdges;
            hAppRoiPopUp.Render3DShadowsCheckBox.Value = ~obj.bRender3DUseFlatLighting;
            
            % set polygon settings
            
            % set handle for controller
            obj.hRegionsOfInterestPopUp = hAppRoiPopUp.MainFigure;
        end
        
        function RegionsOfInterestPopUp_OverlayTransparencySliderValueChanging(obj, event)
            obj.dImagingPlanesVoxelOverlaysAlpha = event.Value;
            obj.dImagingPlanesPolygonOverlaysAlpha = event.Value;
            
            obj.SetOnPlaneRegionsOfInterestOverlaysAlpha();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
        end
        
        function RegionsOfInterestPopUp_LineWidthSliderValueChanging(obj, event)
            dWidthValue = event.Value;
            
            obj.dImagingPlanesVoxelOverlayOutlinesLineWidth = dWidthValue;
            obj.dImagingPlanesPolygonsLineWidth = dWidthValue;
            
            obj.SetOnPlaneRegionsOfInterestOverlaysLineWidth();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
        end
        
        function RegionsOfInterestPopUp_VoxelOverlayCheckBoxValueChanged(obj, oEvent)
            obj.SetRegionOfInterestVoxelMaskOverlayVisibility(oEvent.Value);
        end
        
        function RegionsOfInterestPopUp_BorderCheckBoxValueChanged(obj, oEvent)
            obj.bDisplayImagingPlanesVoxelOverlayOutlines = oEvent.Value;
            
            obj.SetOnPlaneRegionsOfInterestVoxelMaskOverlayOutlinesVisibility();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
        end
        
        function RegionsOfInterestPopUp_SelectionUITableCellEdit(obj, oEvent)
            vdIndices = oEvent.Indices;
            
            if vdIndices(2) == 2 % Show (T/F)
                dRoiNumber = vdIndices(1);
                bShow = oEvent.NewData;
                
                obj.SetRegionOfInterestVisibility(dRoiNumber, bShow);
            elseif vdIndices(2) == 3 % Current (T/F)
                bSetAsCurrent = oEvent.NewData;
                hTable = oEvent.Source;
                
                if ~bSetAsCurrent % can't set the current to be false, because then which will be the current
                    hTable.Data{vdIndices(1),vdIndices(2)} = true;
                else
                    dCurrentRoiNumber = vdIndices(1);
                    
                    hTable.Data(:,vdIndices(2)) = {false}; % set all to false
                    hTable.Data{dCurrentRoiNumber, vdIndices(2)} = true; % set only the selected to true
                    
                    obj.dCurrentRegionOfInterestNumber = dCurrentRoiNumber;
                end
            end
        end
        
        function RegionsOfInterestPopUp_SelectionUITableCellSelection(obj, oEvent)
            vdIndices = oEvent.Indices;
            
            if vdIndices(2) == 4 % colour column was selected
                dRoiNumber = vdIndices(1);
                
                vdCurrentColour_rgb = obj.m2dRegionOfInterestRenderColours_rgb(dRoiNumber,:);
                
                vdNewColour_rgb = uisetcolor(vdCurrentColour_rgb);
                
                % set windows ordering (uisetcolor changes their order)
                figure(obj.hFigure);
                figure(obj.hRegionsOfInterestPopUp);
                
                hTable = oEvent.Source;
                hTable.Data{vdIndices(1),vdIndices(2)} = ImageVolumeViewerController.RgbToStr(vdNewColour_rgb);
                
                obj.SetRegionOfInterestColour(dRoiNumber, vdNewColour_rgb);
            end
        end
                
        function RegionsOfInterestPopUp_Render3DTransparencySliderValueChanging(obj, oEvent)
            obj.d3DRenderRegionsOfInterestMeshesAlpha = oEvent.Value;
            obj.d3DRenderRegionsOfInterestPolygonsAlpha = oEvent.Value;
            
            obj.Set3DRenderMeshesAlpha();
            obj.Set3DRenderRegionsOfInterestPolygonOverlaysAlpha();
            obj.Update3DRenderRegionsOfInterest();
        end
        
        function RegionsOfInterestPopUp_3DRenderMeshesCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderRegionsOfInterestMeshes = oEvent.Value;
            
            obj.Set3DRenderMeshesVisibility();
            obj.Update3DRenderRegionsOfInterest();
        end
        
        function RegionsOfInterestPopUp_Render3DEdgesCheckBoxValueChanged(obj, oEvent)
            obj.b3DRenderRegionsOfInterestMeshesShowEdges = oEvent.Value;
            
            obj.Set3DRenderMeshesEdgeVisibilities();
            obj.Update3DRenderRegionsOfInterest();
        end
        
        function RegionsOfInterestPopUp_Render3DShadowsCheckBoxValueChanged(obj, oEvent)
            obj.bRender3DUseFlatLighting = ~oEvent.Value;
            
            obj.Set3DRenderLightingStyle();
            obj.Update3DRenderAxes();
        end
        
        function RegionsOfInterestPopUp_PolygonsVoxelOverlayCheckBoxValueChanged(obj, oEvent)
            obj.bDisplayImagingPlanesPolygonOverlays = oEvent.Value;
            obj.bDisplay3DRenderRegionsOfInterestPolygonOverlays = oEvent.Value;
            
            obj.SetOnPlaneRegionsOfInterestPolygonOverlaysAlpha();
            obj.Set3DRenderRegionsOfInterestPolygonOverlaysAlpha();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
            obj.Update3DRenderRegionsOfInterest();
        end
        
        function RegionsOfInterestPopUp_PolygonsBorderCheckBoxValueChanged(obj, oEvent)
            obj.bDisplayImagingPlanesPolygonOutlines = oEvent.Value;
            obj.bDisplay3DRenderRegionsOfInterestPolygonOutlines = oEvent.Value;
            
            obj.SetOnPlaneRegionsOfInterestPolygonsLineStyle();
            obj.Set3DRenderRegionsOfInterestPolygonsLineStyle();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
            obj.Update3DRenderRegionsOfInterest();
        end
        
        function RegionsOfInterestPopUp_PolygonsVerticesCheckBoxValueChanged(obj, oEvent)
            obj.bDisplayImagingPlanesPolygonVertices = oEvent.Value;
            obj.bDisplay3DRenderRegionsOfInterestPolygonVertices = oEvent.Value;
            
            obj.SetOnPlaneRegionsOfInterestPolygonsMarkerSymbol();
            obj.Set3DRenderRegionsOfInterestPolygonsMarkerSymbol();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
            obj.Update3DRenderRegionsOfInterest();
        end
        
        function RegionsOfInterestPopUp_ShowDisabledPolygonsCheckBoxValueChanged(obj, oEvent)
            obj.bDisplayImagingPlanesDisabledPolygons = oEvent.Value;
            
            obj.SetOnPlaneRegionsOfInterestPolygonVisibility();
            obj.Set3DRenderRegionsOfInterestPolygonVisibility();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
            obj.Update3DRenderRegionsOfInterest();
        end
        
        function RegionsOfInterestPopUp_ShowPolygons3DRenderCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderRegionsOfInterestPolygons = oEvent.Value;
            
            obj.Set3DRenderRegionsOfInterestPolygonVisibility();
            obj.Update3DRenderRegionsOfInterest();
        end
        
        % >>>>>>>>>>>>>>>>>>>>>> Geometry Popup <<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function GeometryButtonPushed(obj)
            ImageVolumeViewer_GeometryPopUp(obj);
        end
        
        function GeometryPopUp_startupFcn(obj, hAppGeometryPopUp)
            % link up the new app with the controller
            hAppGeometryPopUp.oImageVolumeViewerController = obj;
            
            c1chPositionTableRowNames = {'Voxel (1,1,1)','Row Axis', 'Column Axis', 'Slice Axis'};
            c1chDimensionsTableRowNames = {'Volume Dimensions', 'Voxel Dimensions'};
            
            % Original image volume goemetry output
            oImageVolumeGeometry = obj.oImageVolume.GetImageVolumeGeometry();
            
            vdFirstVoxel_mm = oImageVolumeGeometry.GetFirstVoxelPosition_mm();
            vdRowUnitVector = oImageVolumeGeometry.GetRowAxisUnitVector();
            vdColUnitVector = oImageVolumeGeometry.GetColumnAxisUnitVector();
            vdSliceUnitVector = oImageVolumeGeometry.GetSliceAxisUnitVector();
            
            c2dPositionTableData = cell(4,3);
            
            c2dPositionTableData{1,1} = vdFirstVoxel_mm(1);
            c2dPositionTableData{1,2} = vdFirstVoxel_mm(2);
            c2dPositionTableData{1,3} = vdFirstVoxel_mm(3);
            
            c2dPositionTableData{2,1} = vdRowUnitVector(1);
            c2dPositionTableData{2,2} = vdRowUnitVector(2);
            c2dPositionTableData{2,3} = vdRowUnitVector(3);
            
            c2dPositionTableData{3,1} = vdColUnitVector(1);
            c2dPositionTableData{3,2} = vdColUnitVector(2);
            c2dPositionTableData{3,3} = vdColUnitVector(3);
            
            c2dPositionTableData{4,1} = vdSliceUnitVector(1);
            c2dPositionTableData{4,2} = vdSliceUnitVector(2);
            c2dPositionTableData{4,3} = vdSliceUnitVector(3);
            
            hAppGeometryPopUp.OriginalGeometryPositionUITable.RowName = c1chPositionTableRowNames;
            hAppGeometryPopUp.OriginalGeometryPositionUITable.Data = c2dPositionTableData;
            
            vdVolumeDimensions = oImageVolumeGeometry.GetVolumeDimensions();
            vdVoxelDimensions_mm = oImageVolumeGeometry.GetVoxelDimensions_mm();
            
            c2dDimensionsTableData = cell(2,3);
            
            c2dDimensionsTableData{1,1} = vdVolumeDimensions(1);
            c2dDimensionsTableData{1,2} = vdVolumeDimensions(2);
            c2dDimensionsTableData{1,3} = vdVolumeDimensions(3);
            
            c2dDimensionsTableData{2,1} = vdVoxelDimensions_mm(1);
            c2dDimensionsTableData{2,2} = vdVoxelDimensions_mm(2);
            c2dDimensionsTableData{2,3} = vdVoxelDimensions_mm(3);
            
            hAppGeometryPopUp.OriginalGeometryDimensionsUITable.RowName = c1chDimensionsTableRowNames;
            hAppGeometryPopUp.OriginalGeometryDimensionsUITable.Data = c2dDimensionsTableData;
            
            % RAS image volume goemetry output
            oRASImageVolumeGeometry = obj.oRASImageVolume.GetImageVolumeGeometry();
            
            vdFirstVoxel_mm = oRASImageVolumeGeometry.GetFirstVoxelPosition_mm();
            vdRowUnitVector = oRASImageVolumeGeometry.GetRowAxisUnitVector();
            vdColUnitVector = oRASImageVolumeGeometry.GetColumnAxisUnitVector();
            vdSliceUnitVector = oRASImageVolumeGeometry.GetSliceAxisUnitVector();
            
            c2dPositionTableData = cell(4,3);
            
            c2dPositionTableData{1,1} = vdFirstVoxel_mm(1);
            c2dPositionTableData{1,2} = vdFirstVoxel_mm(2);
            c2dPositionTableData{1,3} = vdFirstVoxel_mm(3);
            
            c2dPositionTableData{2,1} = vdRowUnitVector(1);
            c2dPositionTableData{2,2} = vdRowUnitVector(2);
            c2dPositionTableData{2,3} = vdRowUnitVector(3);
            
            c2dPositionTableData{3,1} = vdColUnitVector(1);
            c2dPositionTableData{3,2} = vdColUnitVector(2);
            c2dPositionTableData{3,3} = vdColUnitVector(3);
            
            c2dPositionTableData{4,1} = vdSliceUnitVector(1);
            c2dPositionTableData{4,2} = vdSliceUnitVector(2);
            c2dPositionTableData{4,3} = vdSliceUnitVector(3);
            
            hAppGeometryPopUp.RASGeometryPositionUITable.RowName = c1chPositionTableRowNames;
            hAppGeometryPopUp.RASGeometryPositionUITable.Data = c2dPositionTableData;
            
            vdVolumeDimensions = oRASImageVolumeGeometry.GetVolumeDimensions();
            vdVoxelDimensions_mm = oRASImageVolumeGeometry.GetVoxelDimensions_mm();
            
            c2dDimensionsTableData = cell(2,3);
            
            c2dDimensionsTableData{1,1} = vdVolumeDimensions(1);
            c2dDimensionsTableData{1,2} = vdVolumeDimensions(2);
            c2dDimensionsTableData{1,3} = vdVolumeDimensions(3);
            
            c2dDimensionsTableData{2,1} = vdVoxelDimensions_mm(1);
            c2dDimensionsTableData{2,2} = vdVoxelDimensions_mm(2);
            c2dDimensionsTableData{2,3} = vdVoxelDimensions_mm(3);
            
            hAppGeometryPopUp.RASGeometryDimensionsUITable.RowName = c1chDimensionsTableRowNames;
            hAppGeometryPopUp.RASGeometryDimensionsUITable.Data = c2dDimensionsTableData;
            
            % figure out if it's oblique
            vdAngles_deg = ImageVolumeGeometry.GetEulerAnglesAboutCartesianAxesBetweenGeometries(oRASImageVolumeGeometry, ImageVolumeGeometry.GetRASGeometry());
            
            if any(abs(vdAngles_deg) > ImageVolumeGeometry.GetPrecisionBound)
                chVisibleFlag = 'on';
                
                hAppGeometryPopUp.ObliqueWarningXRotationEditField.Value = vdAngles_deg(1);
                hAppGeometryPopUp.ObliqueWarningYRotationEditField.Value = vdAngles_deg(2);
                hAppGeometryPopUp.ObliqueWarningZRotationEditField.Value = vdAngles_deg(3);
            else
                chVisibleFlag = 'off';
            end
            
            hAppGeometryPopUp.ObliqueWarningMarkerLabel1.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningMarkerLabel2.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningMarkerLabel3.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningMarkerLabel4.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningMarkerLabel5.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningMarkerLabel6.Visible = chVisibleFlag;
            
            hAppGeometryPopUp.ObliqueWarningHeaderLabel.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningLineLabel1.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningLineLabel2.Visible = chVisibleFlag;
            
            hAppGeometryPopUp.ObliqueWarningXRotationEditField.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningYRotationEditField.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningZRotationEditField.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningXRotationLabel.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningYRotationLabel.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningZRotationLabel.Visible = chVisibleFlag;
            hAppGeometryPopUp.ObliqueWarningDegreesLabel.Visible = chVisibleFlag;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> Image Popup <<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function ImageButtonPushed(obj)
            ImageVolumeViewer_ImagePopUp(obj);
        end
        
        function ImagePopUp_startupFcn(obj, hAppImagePopUp)
            % link up the new app with the controller
            hAppImagePopUp.oImageVolumeViewerController = obj;
            
            % Set histogram axes display props
            hAppImagePopUp.ImageHistogramUIAxes.XColor = [1 1 1];
            hAppImagePopUp.ImageHistogramUIAxes.YColor = [1 1 1];
            hAppImagePopUp.ImageHistogramUIAxes.Title.Color = [1 1 1];
            hAppImagePopUp.ImageHistogramUIAxes.Toolbar.Visible = 'off';
            
            % Set histogram
            oHistogram = histogram(hAppImagePopUp.ImageHistogramUIAxes, obj.oRASImageVolume.GetImageData(), 100);
            hAppImagePopUp.ImageHistogramUIAxes.XLim = [obj.oRASImageVolume.GetImageDataMinimumValue(), obj.oRASImageVolume.GetImageDataMaximumValue];
                        
            % set histogram y limits to ignore the usual spike on the low
            % or high end
            vdBinValues = oHistogram.Values;
            dYMax = 1.05*max(vdBinValues(5:end-5));
            hAppImagePopUp.ImageHistogramUIAxes.YLim = [0 dYMax];
            
            % draw current window/level on histogram
            vdYLims = hAppImagePopUp.ImageHistogramUIAxes.YLim;
            
            vdWindowLevelLineColour = [1 0 0]; % red
            dWindowLevelLineWidth = 2;
            chWindowLevelLineStyle = '-';
            
            obj.hImagePopUpDisplayThresholdLeftLine = line(...
                hAppImagePopUp.ImageHistogramUIAxes,...
                [obj.vdImageDataDisplayThreshold(1), obj.vdImageDataDisplayThreshold(1)],...
                vdYLims,...
                'Color', vdWindowLevelLineColour,...
                'LineWidth', dWindowLevelLineWidth,...
                'LineStyle', chWindowLevelLineStyle);
            obj.hImagePopUpDisplayThresholdRightLine = line(...
                hAppImagePopUp.ImageHistogramUIAxes,...
                [obj.vdImageDataDisplayThreshold(2), obj.vdImageDataDisplayThreshold(2)],...
                vdYLims,...
                'Color', vdWindowLevelLineColour,...
                'LineWidth', dWindowLevelLineWidth,...
                'LineStyle', chWindowLevelLineStyle);
            
            % Set display parameters
            hAppImagePopUp.DisplayMinimumSpinner.Value = obj.vdImageDataDisplayThreshold(1);
            hAppImagePopUp.DisplayMaximumSpinner.Value = obj.vdImageDataDisplayThreshold(2);
            
            [dWindow, dLevel] = InteractiveImagingPlane.GetWindowLevelFromMinMax(obj.vdImageDataDisplayThreshold(1), obj.vdImageDataDisplayThreshold(2));
            
            hAppImagePopUp.DisplayWindowSpinner.Value = dWindow;
            hAppImagePopUp.DisplayLevelSpinner.Value = dLevel;
            
            hAppImagePopUp.ShowSliceIntersectionsCheckBox.Value = obj.bDisplayImagingPlanesSliceIntersections;
                        
            % Set 3D render parameters            
            hAppImagePopUp.CardinalAxesCheckBox.Value = obj.bDisplay3DRenderCardinalAxes;
            hAppImagePopUp.ImagingPlanesCheckBox.Value = obj. bDisplay3DRenderImagingPlanes;
            hAppImagePopUp.ImageVolumeBoundsCheckBox.Value = obj.bDisplay3DRenderImageVolumeOutline;
            hAppImagePopUp.VolumeCoordinateAxesCheckBox.Value = obj.bDisplay3DRenderImageVolumeAxes;
            hAppImagePopUp.RepresentativeVoxelCheckBox.Value = obj.bDisplay3DRenderRepresentativeVoxel;
            hAppImagePopUp.RepresentativePatientCheckBox.Value = obj.bDisplay3DRenderShowRepresentativePatient;
            
            % 3D render labels visibility
            hAppImagePopUp.LabelsCheckBox.Value = obj.bDisplay3DRenderCardinalAxesLabels;            
            
            if obj.bDisplay3DRenderLabels
                chEnable = 'on';
            else
                chEnable = 'off';
            end
            
            hAppImagePopUp.CardinalAxesLabelsCheckBox.Enable = chEnable;
            hAppImagePopUp.ImagingPlaneLabelsCheckBox.Enable = chEnable;
            hAppImagePopUp.ImagingPlaneAlignmentMarkersCheckBox.Enable = chEnable;
            hAppImagePopUp.VolumeDimensionsVoxelsLabelsCheckBox.Enable = chEnable;
            hAppImagePopUp.VolumeDimensionsMetricLabelsCheckBox.Enable = chEnable;
            hAppImagePopUp.VolumeCoordinateAxesLabelsCheckBox.Enable = chEnable;
            hAppImagePopUp.RepresentativeVoxelLabelsCheckBox.Enable = chEnable;
            
            hAppImagePopUp.CardinalAxesLabelsCheckBox.Value = obj.bDisplay3DRenderCardinalAxesLabels;
            hAppImagePopUp.ImagingPlaneLabelsCheckBox.Value = obj.bDisplay3DRenderImagingPlaneLabels;
            hAppImagePopUp.ImagingPlaneAlignmentMarkersCheckBox.Value = obj.bDisplay3DRenderImagingPlaneAlignmentMarkers;
            hAppImagePopUp.VolumeDimensionsVoxelsLabelsCheckBox.Value = obj.bDisplay3DRenderImageVolumeDimensionsVoxels;
            hAppImagePopUp.VolumeDimensionsMetricLabelsCheckBox.Value = obj.bDisplay3DRenderImageVolumeDimensionsMetric;
            hAppImagePopUp.VolumeCoordinateAxesLabelsCheckBox.Value = obj.bDisplay3DRenderImageVolumeAxesLabels;
            hAppImagePopUp.RepresentativeVoxelLabelsCheckBox.Value = obj.bDisplay3DRenderRepresentativeVoxelLabels;
            
            % set handle for controller
            obj.hImagePopUp = hAppImagePopUp.MainFigure;
        end
        
        function ImagePopUp_DisplayMinimumSpinnerValueChanging(obj, oEvent, oApp)
            dNewMinValue = oEvent.Value;
            
            if ischar(dNewMinValue)
                dNewMinValue = str2double(dNewMinValue);
            end
            
            mustBeFinite(dNewMinValue);
            
            if dNewMinValue > obj.vdImageDataDisplayThreshold(2)
                dNewMinValue = obj.vdImageDataDisplayThreshold(2);
                oEvent.Source.Value = dNewMinValue;
            end
            
            obj.vdImageDataDisplayThreshold(1) = dNewMinValue;
            
            [dNewWindow, dNewLevel] = InteractiveImagingPlane.GetWindowLevelFromMinMax(dNewMinValue, obj.vdImageDataDisplayThreshold(2));
            
            oApp.DisplayWindowSpinner.Value = dNewWindow;
            oApp.DisplayLevelSpinner.Value = dNewLevel;
            
            obj.UpdateInteractiveImagingPlanesDisplayLimits();
            obj.UpdateImagePopUpHistogramDisplayLimits();
        end
        
        function ImagePopUp_DisplayMaximumSpinnerValueChanging(obj, oEvent, oApp)
            dNewMaxValue = oEvent.Value;
            
            if ischar(dNewMaxValue)
                dNewMaxValue = str2double(dNewMaxValue);
            end
            
            mustBeFinite(dNewMaxValue);
            
            if dNewMaxValue < obj.vdImageDataDisplayThreshold(1)
                dNewMaxValue = obj.vdImageDataDisplayThreshold(1);
                oEvent.Source.Value = dNewMaxValue;
            end
            
            obj.vdImageDataDisplayThreshold(2) = dNewMaxValue;
            
            [dNewWindow, dNewLevel] = InteractiveImagingPlane.GetWindowLevelFromMinMax(obj.vdImageDataDisplayThreshold(1), dNewMaxValue);
            
            oApp.DisplayWindowSpinner.Value = dNewWindow;
            oApp.DisplayLevelSpinner.Value = dNewLevel;
            
            obj.UpdateInteractiveImagingPlanesDisplayLimits();
            obj.UpdateImagePopUpHistogramDisplayLimits();
        end
        
        function ImagePopUp_DisplayWindowSpinnerValueChanging(obj, oEvent, oApp)
            dNewWindowValue = oEvent.Value;
            
            if ischar(dNewWindowValue)
                dNewWindowValue = str2double(dNewWindowValue);
            end
            
            mustBeFinite(dNewWindowValue);
            
            if dNewWindowValue < 0
                dNewWindowValue = 0;
                oEvent.Source.Value = dNewWindowValue;
            end
            
            [~, dOldLevelValue] = InteractiveImagingPlane.GetWindowLevelFromMinMax(obj.vdImageDataDisplayThreshold(1), obj.vdImageDataDisplayThreshold(2));
            
            [dNewMin, dNewMax] = InteractiveImagingPlane.GetMinMaxFromWindowLevel(dNewWindowValue, dOldLevelValue);
            
            oApp.DisplayMinimumSpinner.Value = dNewMin;
            oApp.DisplayMaximumSpinner.Value = dNewMax;
            
            obj.vdImageDataDisplayThreshold = [dNewMin, dNewMax];
                        
            obj.UpdateInteractiveImagingPlanesDisplayLimits();
            obj.UpdateImagePopUpHistogramDisplayLimits();
        end
        
        function ImagePopUp_DisplayLevelSpinnerValueChanging(obj, oEvent, oApp)
            dNewLevelValue = oEvent.Value;
            
            if ischar(dNewLevelValue)
                dNewLevelValue = str2double(dNewLevelValue);
            end
            
            mustBeFinite(dNewLevelValue);
            
            [dOldWindowValue, ~] = InteractiveImagingPlane.GetWindowLevelFromMinMax(obj.vdImageDataDisplayThreshold(1), obj.vdImageDataDisplayThreshold(2));
            
            [dNewMin, dNewMax] = InteractiveImagingPlane.GetMinMaxFromWindowLevel(dOldWindowValue, dNewLevelValue);
            
            oApp.DisplayMinimumSpinner.Value = dNewMin;
            oApp.DisplayMaximumSpinner.Value = dNewMax;
            
            obj.vdImageDataDisplayThreshold = [dNewMin, dNewMax];
            
            obj.UpdateInteractiveImagingPlanesDisplayLimits();
            obj.UpdateImagePopUpHistogramDisplayLimits();
        end
        
        function ImagePopUp_ShowSliceIntersectionsCheckBoxValueChanged(obj, oEvent)
            obj.bDisplayImagingPlanesSliceIntersections = oEvent.Value;
            
            obj.oImageVolumeRenderer.SetAllSliceIntersectionVisibilities(obj.bDisplayImagingPlanesSliceIntersections);
            obj.oImageVolumeRenderer.UpdateAllRenderedSliceIntersections();
        end
        
        function ImagePopUp_CardinalAxesCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderCardinalAxes = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end

        function ImagePopUp_ImagingPlanesCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderImagingPlanes = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end

        function ImagePopUp_ImageVolumeBoundsCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderImageVolumeOutline = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end

        function ImagePopUp_VolumeCoordinateAxesCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderImageVolumeAxes = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end

        function ImagePopUp_RepresentativeVoxelCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderRepresentativeVoxel = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end

        function ImagePopUp_RepresentativePatientCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderShowRepresentativePatient = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end

        function ImagePopUp_LabelsCheckBoxValueChanged(obj, oEvent, oApp)
            obj.bDisplay3DRenderLabels = oEvent.Value;
            
            if obj.bDisplay3DRenderLabels
                chEnable = 'on';
            else
                chEnable = 'off';
            end
               
            % enable/diable sub-label checkboxes
            oApp.CardinalAxesLabelsCheckBox.Enable = chEnable;
            oApp.ImagingPlaneLabelsCheckBox.Enable = chEnable;
            oApp.ImagingPlaneAlignmentMarkersCheckBox.Enable = chEnable;
            oApp.VolumeDimensionsVoxelsLabelsCheckBox.Enable = chEnable;
            oApp.VolumeDimensionsMetricLabelsCheckBox.Enable = chEnable;
            oApp.VolumeCoordinateAxesLabelsCheckBox.Enable = chEnable;
            oApp.RepresentativeVoxelLabelsCheckBox.Enable = chEnable;
            
            % Update visibilities              
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end
        
        function ImagePopUp_CardinalAxesLabelsCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderCardinalAxesLabels = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end
        
        function ImagePopUp_ImagingPlaneLabelsCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderImagingPlaneLabels = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end
        
        function ImagePopUp_ImagingPlaneAlignmentMarkersCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderImagingPlaneAlignmentMarkers = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end
        
        function ImagePopUp_VolumeDimensionsVoxelsLabelsCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderImageVolumeDimensionsVoxels = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end
        
        function ImagePopUp_VolumeDimensionsMetricLabelsCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderImageVolumeDimensionsMetric = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end
        
        function ImagePopUp_VolumeCoordinateAxesLabelsCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderImageVolumeAxesLabels = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end
        
        function ImagePopUp_RepresentativeVoxelLabelsCheckBoxValueChanged(obj, oEvent)
            obj.bDisplay3DRenderRepresentativeVoxelLabels = oEvent.Value;
            
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
            obj.UpdateImageVolumeRenderer3DRender();
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)        
        
        function PlanePanelSizeChanged(hPanel, hMaximizeButton, hSliceSlider, hSliceSpinner, dButtonHeight_px, dButtonSpacing_px)
            
            dSpinnerWidth_px = 75;
            
            vdPanelPosition_px = hPanel.Position;
            
            hMaximizeButton.Position = [...
                dButtonSpacing_px + 1,...
                dButtonSpacing_px + 1,...
                dButtonHeight_px,... % width = height to make a squre button
                dButtonHeight_px];
            
            dSliderWidth_px = vdPanelPosition_px(3) - dButtonHeight_px - dSpinnerWidth_px - 8 * dButtonSpacing_px;
            
            hSliceSlider.Position = [...
                dButtonHeight_px + 4*dButtonSpacing_px + 1,...
                dButtonSpacing_px + (dButtonHeight_px/2) + 1,...
                dSliderWidth_px,...
                hSliceSlider.Position(4)];
            
            hSliceSpinner.Position = [...
                dButtonHeight_px + dSliderWidth_px + 7*dButtonSpacing_px + 1,...
                dButtonSpacing_px + 1,...
                dSpinnerWidth_px,...
                dButtonHeight_px];
            
        end
        
        function dSelectedIndex = FindAppObjectMouseIsOver(hFigure, c1oAppObjects)
            %object = findAppObjectMouseIsOver(appObjects)
            
            vdMousePosition = get(0, 'PointerLocation');
            
            dSelectedIndex = 0;
            
            for dObjectIndex=1:length(c1oAppObjects)
                if ImageVolumeViewerController.IsMouseOverAppObject(hFigure, c1oAppObjects{dObjectIndex}, vdMousePosition)
                    dSelectedIndex = dObjectIndex;
                    break;
                end
            end
        end
        
        function bBool = IsMouseOverAppObject(hFigure, oAppObjectHandle, vdMouseAbsolutePosition)
            vdAppAbsolutePosition = hFigure.Position;
            vdObjectRelativePosition = oAppObjectHandle.Position;
            
            objectAbsolutePosition = vdObjectRelativePosition + [vdAppAbsolutePosition(1:2), 0, 0];
            
            bBool = vdMouseAbsolutePosition(1) >= objectAbsolutePosition(1) && vdMouseAbsolutePosition(1) <= (objectAbsolutePosition(1) + objectAbsolutePosition(3)) && vdMouseAbsolutePosition(2) >= objectAbsolutePosition(2) && vdMouseAbsolutePosition(2) <= (objectAbsolutePosition(2) + objectAbsolutePosition(4));
        end
        
        function chStr = RgbToStr(vdRgb)
            chStr = ['[',...
                num2str(round(vdRgb(1),2)), ' ',...
                num2str(round(vdRgb(2),2)), ' ',...
                num2str(round(vdRgb(3),2)), ']'];
        end
    end
    
    
    methods (Access = {?ImageVolumeViewerTask})
        
        function obj = ImageVolumeViewerController(oImageVolume, voInteractiveImagingPlanes, oApp, NameValueArgs)
            arguments
                oImageVolume (1,1) ImageVolume
                voInteractiveImagingPlanes (1,:) InteractiveImagingPlane
                oApp
                NameValueArgs.Render3DAxesHandle
            end
            
            varargin = namedargs2cell(NameValueArgs);
            
            obj.oApp = oApp;
            
            obj.Initialize(oImageVolume, voInteractiveImagingPlanes, oApp, varargin{:});            
        end
        
        function SetImageVolumeRendererDisplayProperities(obj)
            oRoiRenderer = obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer();
            
            % 2D/Imaging Plane Rendering Settings            
            % - Image Volume Properities
            obj.oImageVolumeRenderer.SetAllSliceIntersectionVisibilities(obj.bDisplayImagingPlanesSliceIntersections);
            obj.oImageVolumeRenderer.SetAllSliceIntersectionLineWidths(obj.dImagingPlanesSliceIntersectionsLineWidth);
            obj.oImageVolumeRenderer.SetAllSliceIntersectionLineStyles(obj.chImagingPlanesSliceIntersectionsLineStyle);
            obj.oImageVolumeRenderer.SetAllImageVolumeSliceDisplayBounds(obj.vdImageDataDisplayThreshold);
            
            % - ROI Properities  
            if ~isempty(oRoiRenderer) 
                % set ROI colours
                obj.SetRegionsOfInterestColours();
                
                % region of interest visibility:
                for dRoiIndex=1:obj.oRASImageVolume.GetNumberOfRegionsOfInterest()
                    oRoiRenderer.SetRegionOfInterestVisibility(dRoiIndex, obj.vbDisplayRegionOfInterest(dRoiIndex))                    
                end
                
                oRoiRenderer.SetAllVoxelMaskVisibilities(obj.bDisplayImagingPlanesVoxelOverlays);
                oRoiRenderer.SetAllVoxelMaskAlphas(obj.dImagingPlanesVoxelOverlaysAlpha);
                
                oRoiRenderer.SetAllVoxelMaskOutlineVisibilities(obj.bDisplayImagingPlanesVoxelOverlayOutlines);
                oRoiRenderer.SetAllVoxelMaskOutlineLineWidths(obj.dImagingPlanesVoxelOverlayOutlinesLineWidth);
                oRoiRenderer.SetAllVoxelMaskOutlineLineStyles(obj.chImagingPlanesVoxelOverlayOutlinesLineStyle);
                
                if obj.DoRegionsOfInterestHavePolygons()
                    oRoiRenderer.SetAllPolygonLineWidths(obj.dImagingPlanesPolygonsLineWidth);
                    oRoiRenderer.SetAllPolygonMarkerSizes(obj.dImagingPlanesPolygonsMarkerSize);
                    
                    obj.SetOnPlaneRegionsOfInterestPolygonVisibility();
                    obj.SetOnPlaneRegionsOfInterestPolygonOverlaysAlpha();
                    obj.SetOnPlaneRegionsOfInterestPolygonsLineStyle();
                    obj.SetOnPlaneRegionsOfInterestPolygonsMarkerSymbol();
                end
            end
            
            % 3D Rendering Settings
            obj.SetImageVolumeRenderer3DRenderDisplayProperties();
        end
        
        
        % >>>>>>>>>>>>>>>>>>> VALIDATORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustBeValidRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            MustBeValidRegionOfInterestNumbers(obj.oImageVolume, dRegionOfInterestNumber);
        end
        
        
        % >>>>>>>>>>>>>>>> IMAGE POP-UP HELPERS <<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        function UpdateImagePopUpHistogramDisplayLimits(obj)            
            obj.hImagePopUpDisplayThresholdLeftLine.XData(:) = obj.vdImageDataDisplayThreshold(1);                        
            obj.hImagePopUpDisplayThresholdRightLine.XData(:) = obj.vdImageDataDisplayThreshold(2);            
        end
        
        
        % >>>>>>>>>>>>>>>>>>>> GUI UPDATES <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
       
        function SetImageVolumeRenderer3DRenderDisplayProperties(obj)
            % set label visibility
            if obj.bDisplay3DRenderLabels
                obj.oImageVolumeRenderer.Set3DAxesCartesianLabelsVisibility(obj.bDisplay3DRenderCardinalAxesLabels);
                obj.oImageVolumeRenderer.Set3DAxesAnatomicalLabelsVisibility(obj.bDisplay3DRenderCardinalAxesLabels);
                obj.oImageVolumeRenderer.Set3DAnatomicalPlaneLabelsVisiblity(obj.bDisplay3DRenderImagingPlaneLabels);
                obj.oImageVolumeRenderer.Set3DAnatomicalPlaneAlignmentMarkersVisibility(obj.bDisplay3DRenderImagingPlaneAlignmentMarkers);
                obj.oImageVolumeRenderer.Set3DImageVolumeDimensionsVoxelsVisibility(obj.bDisplay3DRenderImageVolumeDimensionsVoxels);
                obj.oImageVolumeRenderer.Set3DImageVolumeDimensionsMetricVisibility(obj.bDisplay3DRenderImageVolumeDimensionsMetric);
                obj.oImageVolumeRenderer.Set3DImageVolumeCoordinateAxesLabelsVisibility(obj.bDisplay3DRenderImageVolumeAxesLabels);
                obj.oImageVolumeRenderer.Set3DRepresentativeVoxelLabelsVisibility(obj.bDisplay3DRenderRepresentativeVoxelLabels);
            else
                obj.oImageVolumeRenderer.Set3DAxesCartesianLabelsVisibility(false);
                obj.oImageVolumeRenderer.Set3DAxesAnatomicalLabelsVisibility(false);
                obj.oImageVolumeRenderer.Set3DAnatomicalPlaneLabelsVisiblity(false);
                obj.oImageVolumeRenderer.Set3DAnatomicalPlaneAlignmentMarkersVisibility(false);
                obj.oImageVolumeRenderer.Set3DImageVolumeDimensionsVoxelsVisibility(false);
                obj.oImageVolumeRenderer.Set3DImageVolumeDimensionsMetricVisibility(false);
                obj.oImageVolumeRenderer.Set3DImageVolumeCoordinateAxesLabelsVisibility(false);
                obj.oImageVolumeRenderer.Set3DRepresentativeVoxelLabelsVisibility(false);
            end
            
            % set image volume component visibility
            obj.oImageVolumeRenderer.Set3DAxesVisibility(obj.bDisplay3DRenderCardinalAxes);
            obj.oImageVolumeRenderer.Set3DAnatomicalPlanesVisibility(obj.bDisplay3DRenderImagingPlanes);
            obj.oImageVolumeRenderer.Set3DImageVolumeOutlineVisibility(obj.bDisplay3DRenderImageVolumeOutline);
            obj.oImageVolumeRenderer.Set3DImageVolumeCoordinateAxesVisibility(obj.bDisplay3DRenderImageVolumeAxes);
            obj.oImageVolumeRenderer.Set3DRepresentativeVoxelVisibility(obj.bDisplay3DRenderRepresentativeVoxel);
            obj.oImageVolumeRenderer.Set3DRepresentativePatientVisibility(obj.bDisplay3DRenderShowRepresentativePatient);
            
            % - ROI properities 
            oRoiRenderer = obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer();
            
            if ~isempty(oRoiRenderer)
                oRoiRenderer.SetAll3DMeshVisibilities(obj.bDisplay3DRenderRegionsOfInterestMeshes);
                oRoiRenderer.SetAll3DMeshAlphas(obj.d3DRenderRegionsOfInterestMeshesAlpha);
                oRoiRenderer.SetAll3DMeshEdgeVisibilities(obj.b3DRenderRegionsOfInterestMeshesShowEdges);
                oRoiRenderer.SetAllImaging3DRenderAxesLightingStyles(obj.GetRender3DLightingStyle());
                
                if obj.DoRegionsOfInterestHavePolygons()
                    oRoiRenderer.SetAll3DPolygonLineWidths(obj.d3DRenderRegionsOfInterestPolygonsLineWidth);
                    oRoiRenderer.SetAll3DPolygonMarkerSizes(obj.d3DRenderRegionsOfInterestPolygonsMarkerSize);
                    
                    obj.Set3DRenderRegionsOfInterestPolygonVisibility();
                    obj.Set3DRenderRegionsOfInterestPolygonOverlaysAlpha();
                    obj.Set3DRenderRegionsOfInterestPolygonsLineStyle();                    
                    obj.Set3DRenderRegionsOfInterestPolygonsMarkerSymbol();
                end                
            end
        end
        
        function UpdateImageVolumeRenderer3DRender(obj)
            obj.oImageVolumeRenderer.UpdateAll3D();
        end
        
        % >>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function voPlanes = GetInteractiveImagingPlanes(obj)
            voPlanes = obj.voInteractiveImagingPlanes;
        end
        
        function c1oAxesHandles = GetInteractiveImagingPlanesAxes(obj)
            voPlanes = obj.GetInteractiveImagingPlanes();
            dNumPlanes = length(voPlanes);
            c1oAxesHandles = cell(dNumPlanes,1);
            
            for dPlaneIndex=1:dNumPlanes
                c1oAxesHandles{dPlaneIndex} = voPlanes(dPlaneIndex).GetAxes();
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>> CHANGE SLICE INDICES <<<<<<<<<<<<<<<<<<<<<<<
        
        function DecrementSlice(obj, eImagingPlaneType)
            vdDimSelect = eImagingPlaneType.GetRASVolumeDimensionSelect();
            dDimension = vdDimSelect(3);
            
            obj.vdAnatomicalPlaneIndices(dDimension) = max(...
                obj.vdAnatomicalPlaneIndices(dDimension) - 1,...
                obj.vdAnatomicalPlaneLimits(dDimension,1));
            
            obj.UpdateAfterImagingPlaneSliceIndexChange(eImagingPlaneType);
        end
        
        function IncrementSlice(obj, eImagingPlaneType)
            vdDimSelect = eImagingPlaneType.GetRASVolumeDimensionSelect();
            dDimension = vdDimSelect(3);
            
            obj.vdAnatomicalPlaneIndices(dDimension) = min(...
                obj.vdAnatomicalPlaneIndices(dDimension) + 1,...
                obj.vdAnatomicalPlaneLimits(dDimension,2));
            
            obj.UpdateAfterImagingPlaneSliceIndexChange(eImagingPlaneType);
        end
        
        function SetSlice(obj, eImagingPlaneType, dSliceIndex)
            dSliceIndex = round(dSliceIndex);
            
            vdDimSelect = eImagingPlaneType.GetRASVolumeDimensionSelect();
            dDimension = vdDimSelect(3);
            
            obj.vdAnatomicalPlaneIndices(dDimension) = dSliceIndex;
            
            obj.UpdateAfterImagingPlaneSliceIndexChange(eImagingPlaneType);
        end
            
        
        % >>>>>>>>>>>>>>>>>>>>>> VIEW UPDATERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function UpdateAfterImagingPlaneSliceIndexChange(obj, eImagingPlaneType) 
            obj.UpdateInteractiveImagingPlaneSlice(eImagingPlaneType);
            obj.UpdateInteractiveImagingPlaneSliceIntersections(eImagingPlaneType);
            
            if obj.bAutoUpdatePlanePositions
                obj.Update3DRenderAnatomicalPlanePosition(eImagingPlaneType);   
            end
        end
        
        function UpdateInteractiveImagingPlaneSlice(obj, eImagingPlaneType)
            voInteractiveImagingPlanes = obj.GetInteractiveImagingPlanes();
            
            for dPlaneIndex=1:length(voInteractiveImagingPlanes)
                if voInteractiveImagingPlanes(dPlaneIndex).GetImagingPlaneType == eImagingPlaneType
                    voInteractiveImagingPlanes(dPlaneIndex).UpdateImageVolumeSlice(obj.vdAnatomicalPlaneIndices);
                end
            end
        end
        
        function UpdateInteractiveImagingPlaneSliceIntersections(obj, eImagingPlaneType)
            voInteractiveImagingPlanes = obj.GetInteractiveImagingPlanes();
            
            for dPlaneIndex=1:length(voInteractiveImagingPlanes)
                if voInteractiveImagingPlanes(dPlaneIndex).GetImagingPlaneType ~= eImagingPlaneType
                    voInteractiveImagingPlanes(dPlaneIndex).UpdateImageVolumeSliceIntersections(obj.vdAnatomicalPlaneIndices);
                end
            end
        end        
        
        function Update3DRenderAnatomicalPlanePosition(obj, eImagingPlaneType)
            obj.oImageVolumeRenderer.Update3DRenderAnatomicalPlanePositionByRenderGroupIdAndType(eImagingPlaneType, obj.vdAnatomicalPlaneIndices, obj.d3DRenderGroupId);
        end
        
        function UpdateInteractiveImagingPlanesDisplayLimits(obj)
            voInteractiveImagingPlanes = obj.voInteractiveImagingPlanes;
            
            for dPlaneIndex=1:length(voInteractiveImagingPlanes)
                voInteractiveImagingPlanes(dPlaneIndex).SetAndUpdateImageDisplayLimits(obj.vdImageDataDisplayThreshold);
            end
        end
        
        function SetOnPlaneRegionsOfInterestOverlaysAlpha(obj)
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAllVoxelMaskAlphas(obj.dImagingPlanesVoxelOverlaysAlpha);
            
            if obj.DoRegionsOfInterestHavePolygons()
                obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAllPolygonOverlayAlphas(obj.dImagingPlanesPolygonOverlaysAlpha);
            end
        end
        
        function SetOnPlaneRegionsOfInterestOverlaysLineWidth(obj)
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAllVoxelMaskOutlineLineWidths(obj.dImagingPlanesVoxelOverlayOutlinesLineWidth);
            
            if obj.DoRegionsOfInterestHavePolygons()
                obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAllPolygonLineWidths(obj.dImagingPlanesPolygonsLineWidth);
            end
        end
        
        function SetOnPlaneRegionsOfInterestVoxelMaskOverlaysVisibility(obj)
            for dRoiIndex=1:obj.oRASImageVolume.GetNumberOfRegionsOfInterest
                obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetRegionOfInterestVoxelMaskVisibility(dRoiIndex, obj.bDisplayImagingPlanesVoxelOverlays && obj.vbDisplayRegionOfInterest(dRoiIndex));
            end                
        end
        
        function SetOnPlaneRegionsOfInterestVoxelMaskOverlayOutlinesVisibility(obj)
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAllVoxelMaskOutlineVisibilities(obj.bDisplayImagingPlanesVoxelOverlayOutlines);
        end
        
        function SetOnPlaneRegionsOfInterestPolygonOverlaysAlpha(obj)
            if obj.bDisplayImagingPlanesPolygonOverlays
                dAlpha = obj.dImagingPlanesVoxelOverlaysAlpha;
            else
                dAlpha = 0;
            end
            
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAllPolygonOverlayAlphas(dAlpha);
        end
        
        function Set3DRenderRegionsOfInterestPolygonOverlaysAlpha(obj)
            if obj.bDisplay3DRenderRegionsOfInterestPolygonOverlays
                dAlpha = obj.d3DRenderRegionsOfInterestPolygonsAlpha;
            else
                dAlpha = 0;
            end
            
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAll3DPolygonFaceAlphas(dAlpha);
        end
        
        function SetOnPlaneRegionsOfInterestPolygonsLineStyle(obj)
            if obj.bDisplayImagingPlanesPolygonOutlines
                chLineStyle = obj.chImagingPlanesPolygonsLineStyle;
            else
                chLineStyle = 'none';
            end
            
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAllPolygonLineStyles(chLineStyle);
            
            % adjust for disabled vs enabled polygons
            if obj.bDisplayImagingPlanesPolygonOutlines
                for dRoiIndex=1:obj.oRASImageVolume.GetNumberOfRegionsOfInterest()
                    vbEnabled = obj.oRASImageVolume.GetRegionsOfInterest().IsPolygonEnabledByRegionOfInterestNumber(dRoiIndex);
                    
                    for dPolyIndex=1:length(vbEnabled)
                        if ~vbEnabled(dPolyIndex)
                            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetPolygonLineStyle(dRoiIndex, dPolyIndex, obj.chImagingPlanesDisabledPolygonsLineStyle);
                        end
                    end
                end
            end
        end
        
        function Set3DRenderRegionsOfInterestPolygonsLineStyle(obj)
            if obj.bDisplay3DRenderRegionsOfInterestPolygonOutlines
                chLineStyle = obj.ch3DRenderRegionsOfInterestPolygonsLineStyle;
            else
                chLineStyle = 'none';
            end
            
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer.SetAll3DPolygonLineStyles(chLineStyle);
            
            % adjust for disabled vs enabled polygons
            if obj.bDisplay3DRenderRegionsOfInterestPolygonOutlines
                for dRoiIndex=1:obj.oRASImageVolume.GetNumberOfRegionsOfInterest()
                    vbEnabled = obj.oRASImageVolume.GetRegionsOfInterest().IsPolygonEnabledByRegionOfInterestNumber(dRoiIndex);
                    
                    for dPolyIndex=1:length(vbEnabled)
                        if ~vbEnabled(dPolyIndex)
                            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().Set3DPolygonLineStyle(dRoiIndex, dPolyIndex, obj.ch3DRenderRegionsOfInterestDisabledPolygonsLineStyle);
                        end
                    end
                end
            end
        end
        
        function SetOnPlaneRegionsOfInterestPolygonsMarkerSymbol(obj)
            if obj.bDisplayImagingPlanesPolygonVertices
                chMarker = obj.chImagingPlanesPolygonsMarkerSymbol;
            else
                chMarker = 'none';
            end
            
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer.SetAllPolygonMarkerSymbols(chMarker);
        end
        
        function Set3DRenderRegionsOfInterestPolygonsMarkerSymbol(obj)
            if obj.bDisplay3DRenderRegionsOfInterestPolygonVertices
                chMarker = obj.ch3DRenderRegionsOfInterestPolygonsMarkerSymbol;
            else
                chMarker = 'none';
            end
            
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer.SetAll3DPolygonMarkerSymbols(chMarker);
        end
        
        function SetOnPlaneRegionsOfInterestPolygonVisibility(obj)
            if obj.bDisplayImagingPlanesDisabledPolygons
                obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAllPolygonVisibilities(true);
            else
                oRois = obj.oRASImageVolume.GetRegionsOfInterest();
                
                for dRoiIndex=1:oRois.GetNumberOfRegionsOfInterest()
                    vbEnabled = oRois.IsPolygonEnabledByRegionOfInterestNumber(dRoiIndex);
                    
                    obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetRegionOfInterestPerPolygonVisibility(dRoiIndex, vbEnabled);
                end
            end
        end
        
        function Set3DRenderRegionsOfInterestPolygonVisibility(obj)
            if ~obj.bDisplay3DRenderRegionsOfInterestPolygons
                obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAll3DPolygonVisibilities(false);
            else
                if obj.bDisplayImagingPlanesDisabledPolygons()
                    obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAll3DPolygonVisibilities(true);
                else
                    oRois = obj.oRASImageVolume.GetRegionsOfInterest();
                    
                    for dRoiIndex=1:oRois.GetNumberOfRegionsOfInterest()
                        vbEnabled = oRois.IsPolygonEnabledByRegionOfInterestNumber(dRoiIndex);
                        
                        obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetRegionOfInterestPer3DPolygonVisibility(dRoiIndex, vbEnabled);
                    end
                end
            end
        end
        
        function SetRegionsOfInterestVisibilities(obj)
            bHasPolygons = obj.DoRegionsOfInterestHavePolygons();
            
            oRoiRenderer = obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer();
            
            for dRoiIndex=1:obj.oImageVolume.GetNumberOfRegionsOfInterest()
                bRoiVisible = obj.vbDisplayRegionOfInterest(dRoiIndex);
                
                oRoiRenderer.SetRegionOfInterest3DMeshVisibility(...
                    dRoiIndex,...
                    bRoiVisible && obj.bDisplay3DRenderRegionsOfInterestMeshes);
                
                oRoiRenderer.SetRegionOfInterestVoxelMaskOutlineVisibility(...
                    dRoiIndex,...
                    bRoiVisible && obj.bDisplayImagingPlanesVoxelOverlayOutlines);
                
                oRoiRenderer.SetRegionOfInterestVoxelMaskVisibility(...
                    dRoiIndex,...
                    bRoiVisible && obj.bDisplayImagingPlanesVoxelOverlays);
                
                if bHasPolygons
                    oRoiRenderer.SetRegionOfInterest3DPolygonVisibilities(...
                        dRoiIndex,...
                        bRoiVisible && obj.bDisplay3DRenderRegionsOfInterestPolygons);
                    
                    oRoiRenderer.SetRegionOfInterestPolygonVisibilities(...
                        dRoiIndex,...
                        bRoiVisible);
                end
            end
        end
        
        function SetRegionsOfInterestColours(obj)
            for dRoiIndex=1:obj.oImageVolume.GetNumberOfRegionsOfInterest()
                obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer.SetRegionOfInterestColour(...
                    dRoiIndex,...
                    obj.m2dRegionOfInterestRenderColours_rgb(dRoiIndex,:));
            end
            
            if obj.DoRegionsOfInterestHavePolygons()
                for dRoiIndex=1:obj.oRASImageVolume.GetNumberOfRegionsOfInterest()
                    vbEnabled = obj.oRASImageVolume.GetRegionsOfInterest().IsPolygonEnabledByRegionOfInterestNumber(dRoiIndex);
                    
                    if ~all(vbEnabled)
                        vdRoiColour_rgb = obj.m2dRegionOfInterestRenderColours_rgb(dRoiIndex,:);
                        vdDisabledColour_rgb = GeometricalImagingObjectRenderer.ApplyColourShift(vdRoiColour_rgb, obj.dDisabledPolygonColourShift);
                        
                        for dPolyIndex=1:length(vbEnabled)
                            if ~vbEnabled(dPolyIndex)
                                obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer.SetPolygonColour(dRoiIndex, dPolyIndex, vdDisabledColour_rgb);
                                obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer.Set3DPolygonColour(dRoiIndex, dPolyIndex, vdDisabledColour_rgb);
                            end
                        end
                    end
                end
            end
        end
        
        function Set3DRenderMeshesVisibility(obj)
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAll3DMeshVisibilities(obj.bDisplay3DRenderRegionsOfInterestMeshes);
        end
        
        function Set3DRenderMeshesAlpha(obj)
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAll3DMeshAlphas(obj.d3DRenderRegionsOfInterestMeshesAlpha);
        end
        
        function Set3DRenderMeshesEdgeVisibilities(obj)
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().SetAll3DMeshEdgeVisibilities(obj.b3DRenderRegionsOfInterestMeshesShowEdges);
        end
            
        function UpdateOnPlaneRegionsOfInterestOverlays(obj)
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().UpdateAllVoxelMasks();
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().UpdateAllVoxelMaskOutlines();
            
            if obj.DoRegionsOfInterestHavePolygons()
                obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().UpdateAllPolygons();
            end
        end
        
        function Update3DRenderRegionsOfInterest(obj)
            obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().UpdateAll3DMeshes();
            
            if obj.DoRegionsOfInterestHavePolygons()
                obj.oImageVolumeRenderer.GetRegionsOfInterestRenderer().UpdateAll3DPolygons();
            end
        end
        
        function Set3DRenderLightingStyle(obj)
            obj.oImageVolumeRenderer.SetAllImaging3DRenderAxesLightingStyles(obj.GetRender3DLightingStyle());
        end
        
        function Update3DRenderAxes(obj)
            obj.oImageVolumeRenderer.UpdateAllImaging3DRenderAxes();
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>> CALLBACK HELPERS <<<<<<<<<<<<<<<<<<<<<
        
        
        
        function ToggleRegionsOfInterestVisibility(obj)
            if any(obj.vbDisplayRegionOfInterest)
                obj.vbDisplayRegionOfInterest(:) = false;
            else
                obj.vbDisplayRegionOfInterest(:) = true;
            end
            
            obj.SetRegionsOfInterestVisibilities();
            obj.Update3DRenderRegionsOfInterest();
            obj.UpdateOnPlaneRegionsOfInterestOverlays();
        end
        
        function CentreCurrentRegionOfInterest(obj)
            vdRASCentreIndices = obj.oRASImageVolume.GetRegionsOfInterest().GetCentreSliceIndicesByRegionOfInterestNumber(obj.dCurrentRegionOfInterestNumber);
            veImagingPlaneTypes = [...
                ImagingPlaneTypes.Sagittal,...
                ImagingPlaneTypes.Coronal,...
                ImagingPlaneTypes.Axial];
            
            for dPlaneIndex=1:3
                obj.SetSlice(veImagingPlaneTypes(dPlaneIndex), vdRASCentreIndices(dPlaneIndex));
            end
        end
        
        function ToggleRegionOfInterestZoom(obj)
            voInteractiveImagingPlanes = obj.GetInteractiveImagingPlanes();
            dNumPlanes = length(voInteractiveImagingPlanes);
            
            if isempty(obj.voPreviousPlaneFieldOfViews) 
                
                [~,oSagittalFieldOfView] = obj.oRASImageVolume.GetRegionsOfInterest().GetDefaultFieldOfViewForImagingPlaneByRegionOfInterestNumber(obj.dCurrentRegionOfInterestNumber, ImagingPlaneTypes.Sagittal);
                [~,oCoronalFieldOfView] = obj.oRASImageVolume.GetRegionsOfInterest().GetDefaultFieldOfViewForImagingPlaneByRegionOfInterestNumber(obj.dCurrentRegionOfInterestNumber, ImagingPlaneTypes.Coronal);
                [~,oAxialFieldOfView] = obj.oRASImageVolume.GetRegionsOfInterest().GetDefaultFieldOfViewForImagingPlaneByRegionOfInterestNumber(obj.dCurrentRegionOfInterestNumber, ImagingPlaneTypes.Axial);
                                               
                obj.voPreviousPlaneFieldOfViews = repmat(oSagittalFieldOfView, 1, dNumPlanes); % pre-allocate
                
                voNewFieldsOfView = [oSagittalFieldOfView oCoronalFieldOfView oAxialFieldOfView];
                
                for dInteractivePlaneIndex=1:dNumPlanes
                    oInteractiveImagingPlane = voInteractiveImagingPlanes(dInteractivePlaneIndex);
                    
                    obj.voPreviousPlaneFieldOfViews(dInteractivePlaneIndex) = oInteractiveImagingPlane.GetCurrentImageFieldOfView();
                    
                    oInteractiveImagingPlane.SetImageFieldOfView(voNewFieldsOfView(oInteractiveImagingPlane.GetSliceDimensionSelect()));
                    oInteractiveImagingPlane.UpdateImageFieldOfView();
                end
            else
                for dInteractivePlaneIndex=1:dNumPlanes
                    oInteractiveImagingPlane = voInteractiveImagingPlanes(dInteractivePlaneIndex);
                    
                    oInteractiveImagingPlane.SetImageFieldOfView(obj.voPreviousPlaneFieldOfViews(oInteractiveImagingPlane.GetSliceDimensionSelect()));
                    oInteractiveImagingPlane.UpdateImageFieldOfView();
                end
                
                obj.voPreviousPlaneFieldOfViews = [];
            end
        end
        
        function AutoscrollInteractiveImagingPlane(obj, eImagingPlaneType)
            voInteractiveImagingPlanes = obj.GetInteractiveImagingPlanes();
            
            for dPlaneIndex=1:length(voInteractiveImagingPlanes)
                if eImagingPlaneType == voInteractiveImagingPlanes{dPlaneIndex}.GetImagingPlaneType()
                    oInteractiveImagingPlane = voInteractiveImagingPlanes(dPlaneIndex);
                    
                    oRois = obj.oRASImageVolume.GetRegionsOfInterest();
                    
                    [vdRowBounds, vdColBounds, vdSliceBounds] = oRois.GetMinimalBoundsByRegionOfInterestNumber(obj.dCurrentRegionOfInterestNumber);
                    c1vdBoundSelection = {vdRowBounds, vdColBounds, vdSliceBounds};
                    
                    vdScrollBounds = c1vdBoundSelection{oInteractiveImagingPlane.GetSliceDimensionSelect()};
                    
                    for dSliceIndex = vdScrollBounds(1) : vdScrollBounds(2)
                        obj.SetSlice(oInteractiveImagingPlane.GetImagingPlaneType(), dSliceIndex);
                        drawnow;
                    end
                    
                    for dSliceIndex = vdScrollBounds(2) : -1 : vdScrollBounds(1)
                        obj.SetSlice(oInteractiveImagingPlane.GetImagingPlaneType(), dSliceIndex);
                        drawnow;
                    end
                end
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>> MISC <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function chLightingStyle = GetRender3DLightingStyle(obj)
            if obj.bRender3DUseFlatLighting
                chLightingStyle = 'flat';
            else
                chLightingStyle = 'gouraud';
            end
        end
                
        function bBool = DoRegionsOfInterestHavePolygons(obj)
            oRois = obj.oImageVolume.GetRegionsOfInterest();
            
            if isempty(oRois)
                bBool = [];
            else
                bBool = isa(oRois, 'RegionsOfInterestFromPolygons');
            end
        end
        
        function Initialize(obj, oImageVolume, voInteractiveImagingPlanes, oApp, NameValueArgs)
            arguments
                obj (1,1) ImageVolumeViewerController
                oImageVolume (1,1) ImageVolume
                voInteractiveImagingPlanes (1,:) InteractiveImagingPlane
                oApp
                NameValueArgs.Render3DAxesHandle
            end
            
            % set image volume
            obj.oImageVolume = copy(oImageVolume);
            
            obj.oRASImageVolume = copy(oImageVolume);
            obj.oRASImageVolume.ReassignFirstVoxelToAlignWithRASCoordinateSystem();
            
            obj.vdImageDataDisplayThreshold = obj.oRASImageVolume.GetDefaultImageDisplayBounds();
            
            % set ROI render defaults:
            dNumRois = obj.oImageVolume.GetNumberOfRegionsOfInterest;
            
            if dNumRois <= 10 % show all if there's not too many
                obj.vbDisplayRegionOfInterest = true(1, dNumRois);
            else
                obj.vbDisplayRegionOfInterest = false(1, dNumRois);
            end
                
            obj.m2dRegionOfInterestRenderColours_rgb = zeros(dNumRois, 3);
            
            for dRoiIndex=1:dNumRois
                obj.m2dRegionOfInterestRenderColours_rgb(dRoiIndex,:) = obj.oImageVolume.GetRegionsOfInterest().GetDefaultRenderColourByRegionOfInterestNumber_rgb(dRoiIndex);
            end
            
            % set image volume renderer
            obj.oImageVolumeRenderer = ImageVolumeRenderer(obj.oImageVolume, obj.oRASImageVolume);
            obj.d3DRenderGroupId = obj.oImageVolumeRenderer.CreateRenderGroup();
            
            % set default anatomical plane indices
            vdVolumeDimensions = obj.oRASImageVolume.GetVolumeDimensions();
            
            obj.vdAnatomicalPlaneIndices = ceil(vdVolumeDimensions ./ 2);
            obj.vdAnatomicalPlaneLimits = [ones(3,1), vdVolumeDimensions'];
            
            % default FOVs
            obj.voPreviousPlaneFieldOfViews = [];
            
            % set interactive imaging planes            
            for dPlaneIndex=1:length(voInteractiveImagingPlanes)
                voInteractiveImagingPlanes(dPlaneIndex).ClearAxes();
                voInteractiveImagingPlanes(dPlaneIndex).SetImageVolumeRenderer(obj.oImageVolumeRenderer);
                voInteractiveImagingPlanes(dPlaneIndex).Initialize(obj.vdAnatomicalPlaneIndices);
            end
            
            obj.voInteractiveImagingPlanes = voInteractiveImagingPlanes;            
            
            % set some figure handle properities
            obj.hFigure = oApp.MainFigure;
            obj.hFigure.DoubleBuffer = 'off';
            obj.hFigure.Interruptible = 'on';
            obj.hFigure.BusyAction = 'cancel';
            
            if isfield(NameValueArgs, 'Render3DAxesHandle')
                cla(NameValueArgs.Render3DAxesHandle);
                obj.oImaging3DRenderAxes = Imaging3DRenderAxes(NameValueArgs.Render3DAxesHandle); 
            end                 
            
            % prep Render 3D Axes
            if ~isempty(obj.oImaging3DRenderAxes) && obj.oImageVolume.GetNumberOfRegionsOfInterest() <= 10 % if there are many ROIs, 3D render bogs down
                obj.oImageVolumeRenderer.RenderIn3D(obj.oImaging3DRenderAxes, obj.vdAnatomicalPlaneIndices, obj.d3DRenderGroupId);
            end
            
            % update everything that has been rendered
            obj.SetImageVolumeRendererDisplayProperities();
            obj.oImageVolumeRenderer.UpdateAll();
                        
            % Disable ROI button if no ROIS
            if oImageVolume.GetNumberOfRegionsOfInterest() == 0
                oApp.ROIButton.Enable = 'off';
            else
                oApp.ROIButton.Enable = 'on';
            end
        end
    end
end