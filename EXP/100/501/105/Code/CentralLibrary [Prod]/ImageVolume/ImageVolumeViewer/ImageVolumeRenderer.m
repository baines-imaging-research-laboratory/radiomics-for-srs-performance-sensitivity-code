classdef ImageVolumeRenderer < GeometricalImagingObjectRenderer
    %ImageVolumeRenderer
    
    % Primary Author: David DeVries
    % Created: Sept 7, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
         
    properties (SetAccess = immutable, GetAccess = public)
        oImageVolume
        oRASImageVolume
        oRegionsOfInterestRenderer
    end
    
    properties (SetAccess = private, GetAccess = public)
        % 2D On-Plane Display Options:
        vbDisplayImageVolumeSlice = []
        c1chImageVolumeSliceColourmaps = {}
        
        c1vdImageVolumeSliceDisplayBounds = {}
                
        % 2D On-Plane Rendered objects
        c1hRenderedImageVolumeSliceHandles = {}
        vdRenderedImageVolumeSliceRenderGroupIds = []
        voRenderedImageVolumeSliceImagingPlaneAxes = []
    end
    
    properties (SetAccess = protected, GetAccess = protected)
        vdRegionsOfInterestRendererRenderGroupIdsMap = []
    end
    
    properties (Constant = true, GetAccess = private)
        bDefaultDisplayImageVolumeSlice = true
        chDefaultImageVolumeSliceColourmap = 'gray'
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
          
    methods (Access = public)
        
        function obj = ImageVolumeRenderer(oImageVolume, oRASImageVolume, varargin)
            %obj = ImageVolumeRenderer(oImageVolume, oRASImageVolume, varargin)
            %
            % SYNTAX:
            %  obj = ImageVolumeRenderer(oImageVolume, oRASImageVolume)
            %  obj = ImageVolumeRenderer(__, oRegionsOfInterestRenderer)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            arguments
                oImageVolume (1,1) ImageVolume
                oRASImageVolume (1,1) ImageVolume {ImageVolumeRenderer.ValidateRASImageVolume(oRASImageVolume)}                
            end
            arguments (Repeating)
                varargin
            end
            
            % super-class call
            obj@GeometricalImagingObjectRenderer(oImageVolume);
            
            % validate params
            
            obj.oRASImageVolume = oRASImageVolume;
            obj.oImageVolume = oImageVolume;
            
            if ~isempty(varargin)
                if numel(varargin) == 1
                    oRegionsOfInterestRenderer = varargin{1};
                    
                    ImageVolumeRenderer.ValidateRegionsOfInterestRenderer(oRegionsOfInterestRenderer);
                    
                    obj.oRegionsOfInterestRenderer = oRegionsOfInterestRenderer;
                else
                    error(...
                        'ImageVolumeRenderer:TooManyOptionalParameters',...
                        'Only 1 optional parameter can be given.');
                end
            end
            
            if isempty(obj.oRegionsOfInterestRenderer) && ~isempty(obj.oRASImageVolume.GetRegionsOfInterest())
                obj.oRegionsOfInterestRenderer = obj.oRASImageVolume.GetRegionsOfInterest().GetRenderer();
            end
        end
        
        function oRegionsOfInterestRenderer = GetRegionsOfInterestRenderer(obj)
            oRegionsOfInterestRenderer = obj.oRegionsOfInterestRenderer;
        end
        
        function dRoiRenderGroupId = GetRegionsOfInterestRenderGroupId(obj, dRenderGroupId)
            dRoiRenderGroupId = obj.vdRegionsOfInterestRendererRenderGroupIdsMap(dRenderGroupId);            
        end
        
        function oRASImageVolume = GetRASImageVolume(obj)
            oRASImageVolume = obj.oRASImageVolume;
        end
        
        function oImageVolume = GetImageVolume(obj)
            oImageVolume = obj.oImageVolume;
        end
        
        function dRenderGroupId = CreateRenderGroup(obj)
            % Super-class call
            dRenderGroupId = CreateRenderGroup@GeometricalImagingObjectRenderer(obj);
                        
            % Also have ROI renderer create a render group, save this
            % render group ID in case its different
            if ~isempty(obj.oRegionsOfInterestRenderer)
                dRoiRenderGroupId = obj.oRegionsOfInterestRenderer.CreateRenderGroup();
                
                obj.vdRegionsOfInterestRendererRenderGroupIdsMap = [obj.vdRegionsOfInterestRendererRenderGroupIdsMap, dRoiRenderGroupId];
            end
        end
        
        function RenderOnPlane(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            arguments
                obj
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,:) double
                dRenderGroupId (1,1) {mustBePositive, mustBeInteger} = CreateRenderGroup(obj)                
            end
            
            % render image data
            obj.RenderPlaneImageVolumeSlice(...
                oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices,...
                dRenderGroupId);
                       
            % Regions of Interest
            if ~isempty(obj.oRegionsOfInterestRenderer)
                obj.oRegionsOfInterestRenderer.RenderOnPlane(...
                    oImagingPlaneAxes,...
                    eImagingPlaneType, vdAnatomicalPlaneIndices,...
                    obj.GetRegionsOfInterestRenderGroupId(dRenderGroupId));
            end
            
            % super-class call (do last since we want slice intersections
            % top-most on reneder)
            RenderOnPlane@GeometricalImagingObjectRenderer(obj,...
                oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices,...
                dRenderGroupId);
        end
        
        function RenderPlaneImageVolumeSlice(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            arguments
                obj
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,:) double
                dRenderGroupId (1,1) {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)                
            end
            
            % get slice data
            vdDimensionSelect = eImagingPlaneType.GetRASVolumeDimensionSelect();
            
            [m2xImageData, dRowVoxelSpacing_mm, dColVoxelSpacing_mm] = eImagingPlaneType.GetImageDataSlice(obj.oRASImageVolume, vdAnatomicalPlaneIndices(vdDimensionSelect(3)));
            
            vdDims = size(m2xImageData);
            
            [vdScaledRowCoords_mm, vdScaledColCoords_mm] = GeometricalImagingObjectRenderer.GetScaledVoxelCoordinatesFromVoxelCoordinates(...
                [1,vdDims(1)], [1,vdDims(2)],...
                dRowVoxelSpacing_mm, dColVoxelSpacing_mm);
            
            % plot image data
            hImage = image(...
                oImagingPlaneAxes.GetAxes(),...
                'XData', vdScaledColCoords_mm,...
                'YData', vdScaledRowCoords_mm,...
                'CData', m2xImageData,...
                'CDataMapping','scaled');
            
            % record image handle
            obj.c1hRenderedImageVolumeSliceHandles = [obj.c1hRenderedImageVolumeSliceHandles, {hImage}];
                                   
            % set visibility
            obj.vbDisplayImageVolumeSlice = [obj.vbDisplayImageVolumeSlice, obj.bDefaultDisplayImageVolumeSlice];
            
            % set colormap (image value to colour)
            obj.c1chImageVolumeSliceColourmaps = [obj.c1chImageVolumeSliceColourmaps, {obj.chDefaultImageVolumeSliceColourmap}];
            
            % set min/max of colormap (default given by image volume)
            vdDisplayBounds = obj.oRASImageVolume.GetDefaultImageDisplayBounds();            
            obj.c1vdImageVolumeSliceDisplayBounds = [obj.c1vdImageVolumeSliceDisplayBounds, {vdDisplayBounds}];
            
            % if the ImagingPlaneAxes doesn't yet have a FOV, set it (default set by FOV constructor)      
            if ~oImagingPlaneAxes.IsFieldOfViewSet()
                oFieldOfView = ImageVolumeFieldOfView2D(obj.oRASImageVolume, eImagingPlaneType, oImagingPlaneAxes.GetAxes());
                oImagingPlaneAxes.SetFieldOfView(oFieldOfView);
            end
            
            % record the oImagingPlaneAxes for reference
            obj.voRenderedImageVolumeSliceImagingPlaneAxes = [obj.voRenderedImageVolumeSliceImagingPlaneAxes, oImagingPlaneAxes];
            
            % set Render Group ID
            obj.vdRenderedImageVolumeSliceRenderGroupIds = [obj.vdRenderedImageVolumeSliceRenderGroupIds, dRenderGroupId];
            
            % Update
            obj.UpdateRenderedImageVolumeSlice(length(obj.vdRenderedImageVolumeSliceRenderGroupIds));
        end
        
        function UpdateRenderOnPlaneForNewIndicesByRenderGroupId(obj, hAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            % Update image volume slice
            vdDimensionSelect = eImagingPlaneType.GetRASVolumeDimensionSelect();
            
            m2xImageData = eImagingPlaneType.GetImageData(obj.oRASImageVolume, vdAnatomicalPlaneIndices(vdDimensionSelect(3)));
                        
            for dRenderedIndex=1:length(obj.vdRenderedImageVolumeSliceRenderGroupIds)
                if obj.vdRenderedImageVolumeSliceRenderGroupIds(dRenderIndex) == dRenderGroupId
                    obj.c1hRenderedImageVolumeSliceHandles{dRenderedIndex}.CData = m2xImageData;
                end
            end
            
            % Update regions of interest
            if ~isempty(obj.oRegionsOfInterestRenderer)
                dRoiRenderGroupId = obj.GetRegionsOfInterestRenderGroupId(dRenderGroupId);
                
                obj.oRegionsOfInterestRenderer.DeleteByRenderGroupId(dRoiRenderGroupId);
                obj.oRegionsOfInterestRenderer.RenderOnPlane(hAxes, eImagingPlaneType, vdAnatomicalPlanes);
            end
            
            % Update slice intersections
            for dRenderedIndex=1:length(obj.vdRenderedImageVolumeSliceRenderGroupIds)
                if obj.vdRenderedImageVolumeSliceRenderGroupIds(dRenderIndex) == dRenderGroupId
                    obj.c1hRenderedImageVolumeSliceHandles{dRenderedIndex}.CData = m2xImageData;
                end
            end
        end
        
        function UpdateRenderOnPlaneForAxesSizeChangedByRenderGroupId(obj, dRenderGroupId)
            for dAxisIndex=1:length(obj.vdRenderedImageVolumeSliceRenderGroupIds)
                if obj.vdRenderedImageVolumeSliceRenderGroupIds(dAxisIndex) == dRenderGroupId
                    obj.voRenderedImageVolumeSliceImagingPlaneAxes(dAxisIndex).UpdateAxesWithFieldOfView();
                end
            end
        end
        
        function UpdateRenderedOnPlaneImageVolumeSliceDataByRenderGroupId(obj, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            arguments
                obj
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)}                
            end
            
            m2xImageData = eImagingPlaneType.GetImageDataSliceFromAnatomicalPlaneIndices(obj.oRASImageVolume, vdAnatomicalPlaneIndices);
                        
            for dSliceIndex=1:length(obj.c1hRenderedImageVolumeSliceHandles)
                if dRenderGroupId == obj.vdRenderedImageVolumeSliceRenderGroupIds(dSliceIndex)
                    obj.c1hRenderedImageVolumeSliceHandles{dSliceIndex}.CData = m2xImageData;
                end
            end            
        end
        
        function RenderIn3D(obj, oImaging3DRenderAxes, vdAnatomicalPlaneIndices, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                vdAnatomicalPlaneIndices (1,:) double {mustBeInteger(vdAnatomicalPlaneIndices), mustBeFinite(vdAnatomicalPlaneIndices)}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % Super-class call:
            RenderIn3D@GeometricalImagingObjectRenderer(obj,...
                oImaging3DRenderAxes, vdAnatomicalPlaneIndices,...
                dRenderGroupId);
            
            % Render components
            % - none in this class
            
            % Call RenderIn3D to RegionsOfInterestRenderer
            if ~isempty(obj.oRegionsOfInterestRenderer)
                dRoiRenderGroupId = obj.vdRegionsOfInterestRendererRenderGroupIdsMap(dRenderGroupId);
                
                obj.oRegionsOfInterestRenderer.RenderIn3D(...
                    oImaging3DRenderAxes,...
                    vdAnatomicalPlaneIndices,...
                    dRoiRenderGroupId,...
                    'GeometricalImagingObjectRendererComplete', true);
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function SetImageVolumeSliceFieldOfViewByRenderGroupId(obj, oFieldOfView, dRenderGroupId)
            arguments
                obj
                oFieldOfView (1,1) ImageVolumeFieldOfView2D
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)}
            end
            
            for dImageVolumeSliceIndex=1:length(obj.vdRenderedImageVolumeSliceRenderGroupIds)
                if obj.vdRenderedImageVolumeSliceRenderGroupIds(dImageVolumeSliceIndex) == dRenderGroupId
                    obj.voRenderedImageVolumeSliceImagingPlaneAxes(dImageVolumeSliceIndex).SetFieldOfView(oFieldOfView);
                end
            end
        end
        
        function SetImageVolumeSliceDisplayBoundsByRenderGroupId(obj, vdDisplayBounds, dRenderGroupId)
            arguments
                obj
                vdDisplayBounds (1,2) double {ImageVolumeRenderer.MustBeValidDisplayBounds(vdDisplayBounds)}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)}
            end
            
            obj.c1vdImageVolumeSliceDisplayBounds{obj.vdRenderedImageVolumeSliceRenderGroupIds == dRenderGroupId} = vdDisplayBounds;
        end
        
        function SetAllImageVolumeSliceDisplayBounds(obj, vdDisplayBounds)
            arguments
                obj
                vdDisplayBounds (1,2) double {ImageVolumeRenderer.MustBeValidDisplayBounds(vdDisplayBounds)}
            end
            
            for dImageVolumeSliceIndex=1:length(obj.c1vdImageVolumeSliceDisplayBounds)
                obj.c1vdImageVolumeSliceDisplayBounds{dImageVolumeSliceIndex} = vdDisplayBounds;
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> UPDATERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        function UpdateAll(obj)
            arguments
                obj
            end
            
            obj.UpdateAll3D();
            obj.UpdateAllOnPlane();
        end
        
        function UpdateAll3D(obj)
            arguments
                obj
            end
            
            % super-class call
            UpdateAll3D@GeometricalImagingObjectRenderer(obj);
            
            % local class updaters
            % - none
            
            % propagate to ROI renderer if it exists
            if ~isempty(obj.oRegionsOfInterestRenderer)
                obj.oRegionsOfInterestRenderer.UpdateAll3D();
            end
        end
        
        function UpdateAllOnPlane(obj)
            arguments
                obj
            end
            
            % super-class call
            UpdateAllOnPlane@GeometricalImagingObjectRenderer(obj);
            
            % local class updaters
            obj.UpdateAllRenderedImageVolumeSlices();
            
            % propagate to ROI renderer if it exists
            if ~isempty(obj.oRegionsOfInterestRenderer)
                obj.oRegionsOfInterestRenderer.UpdateAllOnPlane();
            end
        end        
        
        function UpdateAllRenderedImageVolumeSlices(obj)
            arguments
                obj
            end
            
            for dVolumeSliceIndex=1:length(obj.vdRenderedImageVolumeSliceRenderGroupIds)
                obj.UpdateRenderedImageVolumeSlice(dVolumeSliceIndex);
            end
        end
        
        function UpdateRenderedImageVolumeSliceByRenderGroupId(obj, dRenderGroupId)
            arguments
                obj                
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)}
            end
            
            for dVolumeSliceIndex=1:length(obj.vdRenderedImageVolumeSliceRenderGroupIds)
                if obj.vdRenderedImageVolumeSliceRenderGroupIds(dVolumeSliceIndex) == dRenderGroupId
                    obj.UpdateRenderedImageVolumeSlice(dVolumeSliceIndex);
                end
            end
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function MustBeValidDisplayBounds(vdDisplayBounds)
            arguments
                vdDisplayBounds (1,2) double {mustBeFinite}
            end
            
            if vdDisplayBounds(1) >= vdDisplayBounds(2)
                error(...
                    'ImageVolumeRenderer:MustBeValidDisplayBounds:Invalid',...
                    'The display bounds must be strictly increasing in value.');
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function oGeometricalImagingObj = GetGeometricalImagingObject(obj)
            oGeometricalImagingObj = obj.oImageVolume;
        end
        
        function oRASGeometricalImagingObj = GetRASGeometricalImagingObject(obj)
            oRASGeometricalImagingObj = obj.oRASImageVolume;	
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
        
        function ValidateRASImageVolume(oRASImageVolume)
            if ~isscalar(oRASImageVolume) || ~isa(oRASImageVolume, 'ImageVolume')
                error(...
                    'ImageVolumeRenderer:ValidateRASImageVolume:Invalid',...
                    'oRASImageVolume must be scalar of type ImageVolume.');
            end
        end
        
        function RegionsOfInterestRenderer(oRegionsOfInterestRenderer)
            if ~isscalar(oRegionsOfInterestRenderer) || ~isa(oRegionsOfInterestRenderer, 'RegionsOfInterestRenderer')
                error(...
                    'ImageVolumeRenderer:ValidateRegionsOfInterestRenderer:Invalid',...
                    'oRegionsOfInterestRenderer must be scalar of type RegionsOfInterestRenderer.');
            end
        end
    end
    
    
    methods (Access = private)
                
        function UpdateRenderedImageVolumeSlice(obj, dRenderedImageVolumeSliceIndex)
            hImageHandle = obj.c1hRenderedImageVolumeSliceHandles{dRenderedImageVolumeSliceIndex};
            
            hImageHandle.Visible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.vbDisplayImageVolumeSlice(dRenderedImageVolumeSliceIndex));
            hImageHandle.Parent.CLim = obj.c1vdImageVolumeSliceDisplayBounds{dRenderedImageVolumeSliceIndex};
            colormap(hImageHandle.Parent, obj.c1chImageVolumeSliceColourmaps{dRenderedImageVolumeSliceIndex});
            obj.voRenderedImageVolumeSliceImagingPlaneAxes(dRenderedImageVolumeSliceIndex).UpdateAxesWithFieldOfView();
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


