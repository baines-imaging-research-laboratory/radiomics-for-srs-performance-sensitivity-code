classdef ImagingPlaneAxes < handle
    %ImagingPlaneAxes
    %
    % DESCRIPTION OF PLANE GEOMETERIES:
    %  The plane descriptions below show the image data matrix
    %  (imagine this being the image display in the figure). An
    %  axes is shown at the top left, as when Matlab displays an
    %  image, this is how it displays the image (use "axis on"
    %  after an imshow command to see this). The "-row", "-col",
    %  "-slice" refer to the dimensions of the 3D matrix of data
    %  contained within an **RAS** ImageVolume object. These also
    %  match with the right/left, ant/post, sup/inf axes for each
    %  plane (-row = -right = left, -col = -ant = post, -slice = -sup = inf).
    %  The reason that these anatomical directions are how they are
    %  for each plane is just their definition. It could be defined
    %  differently, but the definitions used here match 3DSlicer
    %  and ITK-Snap.
    %  Now seeing that all of these planes have negative axes directions with
    %  respect to the image data, both the x and y axis directions
    %  will be reversed, putting the origin at the lower right
    %  corner of the image data. What this then gives us is that
    %  the voxel (1,1,1) within the 3D data matrix will be at
    %  location (0,0) within the 2D axes. With an axial plane as an
    %  example (see far below), voxel (2,1,1) within the 3D data matrix will be at
    %  location (LR,0) on the axes, where LR is the voxel spacing in the
    %  left/right direction. Similarly, voxel (1,2,1) within the 3D
    %  data matrix will be at location (0,AP), where AP is the
    %  voxel spacing in the ant/post direction.
    %
    %  |   *SAGITTAL PLANE*    |   |    *CORONAL PLANE*    |   |    *AXIAL PLANE*
    % -+----> -col             |  -+----> -row             |  -+----> -row
    %  |                 ^ sup |   |                 ^ sup |   |                 ^ ant
    %  |    +--------+   |     |   |    +--------+   |     |   |    +--------+   |
    %  v    |        |   |     |   v    |        |   |     |   v    |        |   |
    %-slice | IMAGE  |   |     | -slice | IMAGE  |   |     | -col   | IMAGE  |   |
    %       |  DATA  |   |     |        |  DATA  |   |     |        |  DATA  |   |
    %       |        |   |     |        |        |   |     |        |        |   |
    %       +--------+   |     |        +--------+   |     |        +--------+   |
    %              (0,0) v inf |               (0,0) v inf |               (0,0) v post
    %     <------------>       |      <------------>       |      <------------>
    %    ant         post      |     right       left      |    right        left
    %
    %
    % *AXIAL EXAMPLE*
    %                     LR (voxel spacing in left/right direction)
    %                  .........
    %                  :       :
    %                  :       :
    %  +-------+-------+-------+ ....
    %  |(3,3,3)|       |(1,3,1)|    :
    %  |   *   |       |       |    : AP (voxel spacing in ant/post direction)
    %  |(2LR,2AP)      |       |    :
    %  +-------+-------+-------+ ....
    %  |       |       |(1,2,1)|  <-- voxel value 3D image matrix coordinate: (row,col,slice) = (right,anterior,superior) for RAS ImageVolume
    %  |       |       |   *   |  <-- voxel centre location
    %  |       |       | (0,AP)|  <-- voxel centre coordinate: (x,y) in figure axes
    %  +-------+-------+-------+
    %  |(3,1,1)|(2,1,1)|(1,1,1)|
    %  |       |   *   |   *   |  ^ +col (in data matrix)
    %  |       | (LR,0)| (0,0) |  | +y   (in figure axes; axis direction flip required)
    %  +-------+-------+-------+  | anterior (since image volume is rAs; +col = anterior)
    %                             |
    %                    <--------+
    %                     +row (in data matrix)
    %                     +x   (in figure axes; axis direction flip required)
    %                     right (since image volume is Ras; +row = right)
    
    % Primary Author: David DeVries
    % Created: Oct 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        oImageVolumeFieldOfView2D = []
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)
       hAxes
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ImagingPlaneAxes(hAxes)
            
            arguments
                hAxes (1,1) {ValidationUtils.MustBeAxes(hAxes)}
            end
            
            ImagingPlaneAxes.PrepareAxesForOnPlaneRender(hAxes);
            obj.hAxes = hAxes;
        end
        
        function bBool = IsFieldOfViewSet(obj)
            arguments
                obj
            end
            
            bBool = ~isempty(obj.oImageVolumeFieldOfView2D);
        end
        
        function SetFieldOfView(obj, oImageVolumeFieldOfView2D)
            arguments
                obj
                oImageVolumeFieldOfView2D (1,1) ImageVolumeFieldOfView2D
            end
            
            obj.oImageVolumeFieldOfView2D = oImageVolumeFieldOfView2D;
            obj.oImageVolumeFieldOfView2D.FitToAxes(obj.hAxes);
        end
        
        function ZoomInBy(obj, dZoomBy_mm)
            arguments
                obj
                dZoomBy_mm (1,1) double {mustBePositive(dZoomBy_mm), mustBeFinite(dZoomBy_mm)}
            end
            
            obj.oImageVolumeFieldOfView2D.ZoomInBy(dZoomBy_mm);
        end
        
        function ZoomOutBy(obj, dZoomBy_mm)
            arguments
                obj
                dZoomBy_mm (1,1) double {mustBePositive(dZoomBy_mm), mustBeFinite(dZoomBy_mm)}
            end
            
            obj.oImageVolumeFieldOfView2D.ZoomOutBy(dZoomBy_mm);
        end
        
        function SetFieldOfViewCentreFromPanMouseMovement(obj, vdStartingNormalizedMousePosition, vdCurrentNormalizedMousePosition)
            arguments
                obj
                vdStartingNormalizedMousePosition (1,2) double {mustBeFinite}
                vdCurrentNormalizedMousePosition (1,2) double {mustBeFinite}
            end
            
            obj.oImageVolumeFieldOfView2D.SetFieldOfViewCentreFromPanMouseMovement(vdStartingNormalizedMousePosition, vdCurrentNormalizedMousePosition);
        end
        
        function UpdateAxesWithFieldOfView(obj)
            obj.oImageVolumeFieldOfView2D.SetFieldOfViewForAxes(obj.hAxes);
        end
        
        function hAxes = GetAxes(obj)
            hAxes = obj.hAxes;
        end
        
        function oFieldOfView = GetFieldOfView(obj)
            oFieldOfView = obj.oImageVolumeFieldOfView2D;
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
    
    methods (Access = private, Static = true)           
        
        function PrepareAxesForOnPlaneRender(h2DAxes)
            h2DAxes.Color = [0 0 0]; % black background
            axis(h2DAxes, 'equal'); % axes spacing must be equal such the XData and YData (which recorded the voxel spacing) can accurately represent that spacing
            axis(h2DAxes, 'off'); % don't need to see the axes (e.g. ticks)
            set(h2DAxes, 'YDir', 'normal'); % such that bottom right corner is (0,0)
            set(h2DAxes, 'XDir', 'reverse'); % such that bottom right corner is (0,0)
            set(h2DAxes, 'NextPlot', 'add'); % allows plotted image/lines to be overlaid
            
            if (isa(h2DAxes, 'matlab.ui.control.UIAxes'))
                h2DAxes.BackgroundColor = [0 0 0]; % black background
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