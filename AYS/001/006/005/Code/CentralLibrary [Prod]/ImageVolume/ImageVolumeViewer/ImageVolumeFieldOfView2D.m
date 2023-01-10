classdef ImageVolumeFieldOfView2D < handle
    %ImageVolumeFieldOfView2D
    %
    % See ImageVolumeRenderer.RenderPlaneImageVolumeSlice for critical
    % documentation concern the coordinate system of showing 2D data (e.g.
    % a slice in an anatomical plane)
    
    % Primary Author: David DeVries
    % Created: Sept 9, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
           
    properties (SetAccess = private, GetAccess = public)
        dFieldOfViewHalfHeight_mm % store half height to make math from FOV centre coords more efficient (no divide by 2 needed)
        dAxesAspectRatio % width/height (in pixels)
        vdFieldOfViewCentreCoordinates_mm % in scaled voxel coordinates (e.g. (0,0) is the bottom-right voxel's centre, and then the voxel spacing is used to determine the centre of the other voxels)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
          
    methods (Access = public)
        
        function obj = ImageVolumeFieldOfView2D(varargin)
            %obj = ImageVolume2DFieldOfView(oImageVolume, eImagingPlaneType, hAxes)
            %
            % SYNTAX:
            %  obj = ImageVolumeFieldOfView2D(oRASImageVolume, eImagingPlaneType, hAxes)
            %  obj = ImageVolume2DFieldOfView(vdFieldOfViewCentreCoordinates_mm, dHeight_mm, dWidth_mm)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
                        
            if numel(varargin) ~= 3 && numel(varargin) ~= 4
                error('Construction error');
            else
                if isa(varargin{1}, 'ImageVolume') && isa(varargin{2}, 'ImagingPlaneTypes') && ( isa(varargin{3}, 'matlab.graphics.axis.Axes') || isa(varargin{3}, 'matlab.ui.control.UIAxes') )
                    oRASImageVolume = varargin{1};
                    eImagingPlaneType = varargin{2};
                    hAxes = varargin{3};
                    
                    vdVolumeDimensions_mm = eImagingPlaneType.GetVolumeDimensions_mm(oRASImageVolume);
                    vdVoxelDimensions_mm = eImagingPlaneType.GetVoxelDimensions_mm(oRASImageVolume);
                    
                    obj.vdFieldOfViewCentreCoordinates_mm = (vdVolumeDimensions_mm(1:2) ./ 2) - (vdVoxelDimensions_mm(1:2) ./ 2);
                    
                    vdAxesSize_px = ImageVolumeFieldOfView2D.GetAxesSize_px(hAxes);
                    
                    dWidth_px = vdAxesSize_px(1);
                    dHeight_px = vdAxesSize_px(2);
                    
                    obj.dAxesAspectRatio = dWidth_px / dHeight_px;
                    
                    obj.dFieldOfViewHalfHeight_mm = 0.5 * max(vdVolumeDimensions_mm(1), vdVolumeDimensions_mm(2) / obj.dAxesAspectRatio);
                elseif isa(varargin{1}, 'double') && isa(varargin{2}, 'double') && isa(varargin{3}, 'double')
                    vdFieldOfViewCentreCoordinates_mm = varargin{1};
                    dHeight_mm = varargin{2};
                    dWidth_mm = varargin{3};
                    
                    if numel(varargin) == 4
                        if isa(varargin{4}, 'matlab.graphics.axis.Axes') || isa(varargin{4}, 'matlab.ui.control.UIAxes')                            
                            hAxes = varargin{4};
                            
                            obj.vdFieldOfViewCentreCoordinates_mm = vdFieldOfViewCentreCoordinates_mm;
                            
                            vdAxesSize_px = ImageVolumeFieldOfView2D.GetAxesSize_px(hAxes);
                            
                            dWidth_px = vdAxesSize_px(1);
                            dHeight_px = vdAxesSize_px(2);
                            
                            obj.dAxesAspectRatio = dWidth_px / dHeight_px;
                            
                            obj.dFieldOfViewHalfHeight_mm = 0.5 * max(dHeight_mm, dWidth_mm / obj.dAxesAspectRatio);
                        else                            
                            error('')
                        end
                    else
                        obj.vdFieldOfViewCentreCoordinates_mm = vdFieldOfViewCentreCoordinates_mm;
                        
                        obj.dFieldOfViewHalfHeight_mm = dHeight_mm / 2;
                        obj.dAxesAspectRatio = dWidth_mm / dHeight_mm;
                    end  
                else
                    error('Construction error');
                end
            end
            
            if isempty(obj.vdFieldOfViewCentreCoordinates_mm)
                error('Construction error');
            end
        end
        
        function SetFieldOfView(obj, vdXLimits_mm, vdYLimits_mm)
            dWidth_mm = vdXLimits_mm(2) - vdXLimits_mm(1);
            dHeight_mm = vdYLimits_mm(2) - vdYLimits_mm(1);
                        
            obj.dFieldOfViewHalfHeight_mm = 0.5 * max(dHeight_mm, dWidth_mm / obj.dAxesAspectRatio);
        end 
        
        function FitToAxes(obj, hAxes)
            arguments
                obj
                hAxes (1,1) {ValidationUtils.MustBeAxes(hAxes)}
            end
            
            dCurrentHalfHeight_mm = obj.dFieldOfViewHalfHeight_mm;
            dCurrentHalfWidth_mm = obj.GetFieldOfViewHalfWidth_mm();
            
            vdAxesSize_px = ImageVolumeFieldOfView2D.GetAxesSize_px(hAxes);
            
            dWidth_px = vdAxesSize_px(1);
            dHeight_px = vdAxesSize_px(2);
            
            obj.dAxesAspectRatio = dWidth_px / dHeight_px;
            
            obj.dFieldOfViewHalfHeight_mm = max(dCurrentHalfHeight_mm, dCurrentHalfWidth_mm / obj.dAxesAspectRatio);
        end
        
        function SetFieldOfViewForAxes(obj, hAxes)
            arguments
                obj
                hAxes (1,1) {ValidationUtils.MustBeAxes(hAxes)}
            end
            
            dHalfHeight_mm = obj.dFieldOfViewHalfHeight_mm;
            dHalfWidth_mm = obj.GetFieldOfViewHalfWidth_mm();
            
            vdFOVCentreCoords_mm = obj.vdFieldOfViewCentreCoordinates_mm;
            
            hAxes.YLim = [vdFOVCentreCoords_mm(1) - dHalfHeight_mm, vdFOVCentreCoords_mm(1) + dHalfHeight_mm]; % rows
            hAxes.XLim = [vdFOVCentreCoords_mm(2) - dHalfWidth_mm, vdFOVCentreCoords_mm(2) + dHalfWidth_mm]; % cols
        end
        
        function UpdateForAxesChange(obj, hAxes)
            arguments
                obj
                hAxes (1,1) {ValidationUtils.MustBeAxes(hAxes)}
            end
            
            vdAxesSize_px = obj.GetAxesSize_px(hAxes);
            
            dWidth_px = vdAxesSize_px(1);
            dHeight_px = vdAxesSize_px(2);
            
            obj.dAxesAspectRatio = dWidth_px / dHeight_px;
        end
        
        function ZoomInBy(obj, dZoomBy_mm)
            arguments
                obj
                dZoomBy_mm (1,1) double {mustBePositive(dZoomBy_mm), mustBeFinite(dZoomBy_mm)}
            end
            
            obj.dFieldOfViewHalfHeight_mm = max(0.001, obj.dFieldOfViewHalfHeight_mm - dZoomBy_mm); % min FOV height of 0.001mm
        end
        
        function ZoomOutBy(obj, dZoomBy_mm)
            arguments
                obj
                dZoomBy_mm (1,1) double {mustBePositive(dZoomBy_mm), mustBeFinite(dZoomBy_mm)}
            end
            
            obj.dFieldOfViewHalfHeight_mm = obj.dFieldOfViewHalfHeight_mm + dZoomBy_mm;
        end
        
        function SetFieldOfViewCentreFromPanMouseMovement(obj, vdStartingNormalizedMousePosition, vdCurrentNormalizedMousePosition)
            arguments
                obj
                vdStartingNormalizedMousePosition (1,2) double {mustBeFinite}
                vdCurrentNormalizedMousePosition (1,2) double {mustBeFinite}
            end
            
            dHalfHeight_mm = obj.dFieldOfViewHalfHeight_mm;
            dHalfWidth_mm = obj.GetFieldOfViewHalfWidth_mm();
            
            dHeightShift_mm = (vdStartingNormalizedMousePosition(2) - vdCurrentNormalizedMousePosition(2)) * 2 * dHalfHeight_mm;
            dWidthShift_mm = -(vdStartingNormalizedMousePosition(1) - vdCurrentNormalizedMousePosition(1)) * 2 * dHalfWidth_mm; % reversed since x-axes is flipped
            
            obj.vdFieldOfViewCentreCoordinates_mm = obj.vdFieldOfViewCentreCoordinates_mm + [dHeightShift_mm dWidthShift_mm];            
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % None
    end
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)        
        
        function vdAxesSize_px = GetAxesSize_px(hAxes)
            chUnits = hAxes.Units;
            
            hAxes.Units = 'pixels';
            vdAxesSize_px = hAxes.Position(3:4);
            hAxes.Units = chUnits;
        end
    end
    
    
    methods (Access = private)  
        
        function dFieldOfViewHalfWidth_mm = GetFieldOfViewHalfWidth_mm(obj)
            dFieldOfViewHalfWidth_mm = obj.dFieldOfViewHalfHeight_mm .* obj.dAxesAspectRatio;
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


