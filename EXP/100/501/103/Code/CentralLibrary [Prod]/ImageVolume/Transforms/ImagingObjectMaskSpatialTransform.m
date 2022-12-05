classdef ImagingObjectMaskSpatialTransform < IndependentImagingObjectTransform
    %ImagingObjectMaskSpatialTransform
    %
    % Applies a spatial transform to a mask to any given target geometry,
    % using interpolation as specified by the user.
    
    % Primary Author: David DeVries
    % Created: June 21, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)  
        chInterpolationMethod = ''
        
        % for 3D:
        chInterp3DMethod = ''
        
        % for levelsets:
        chInPlaneInterp2DMethod = ''
        chThroughPlaneInterp1DMethod = ''
        dThroughPlaneDimension = [] % 1, 2 or 3 (e.g. if 1, m3xData(x,:,:) gives the slice)
    end    
        
       
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public) % None
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % None
    end
    

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ImagingObjectTransform, ?GeometricalImagingObject})
        
        function obj = ImagingObjectMaskSpatialTransform(oCurrentImagingObject, oTargetImageVolumeGeometry, chInterpMethod, varargin)%chCrossPlane2DInterpolationMethod, chThroughPlane1DLevelSetInterpolationMethod, dThroughPlaneDimension)
            % obj.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, 'interpolate3D')
            % obj.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, 'interpolate3D', chInterp3DMethod)
            % obj.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, 'levelsets')
            % obj.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, 'levelsets', Name, Value)
            %
            % Name, Value:
            % 'InPlaneInterp2DMethod'
            % 'ThroughPlaneInterp1DMethod'
            % 'ThroughPlaneDimension'
            
            
            % obj = ImageObjectMaskTransform(oCurrentImageVolume, oTargetImageVolumeGeometry, chCrossPlane2DInterpolationMethod, chThroughPlane1DLevelSetInterpolationMethod, varargin)
            % 
            % SYNTAX:
            %  obj = ImageObjectMaskTransform(oCurrentImageVolume, oTargetImageVolumeGeometry, chCrossPlane2DInterpolationMethod, chThroughPlane1DLevelSetInterpolationMethod)
            %  obj = ImageObjectMaskTransform(__, __, __, __, dThroughPlaneDimension)
            arguments
                oCurrentImagingObject (1,1) GeometricalImagingObject
                oTargetImageVolumeGeometry (1,1) ImageVolumeGeometry
                chInterpMethod (1,:) char {mustBeMember(chInterpMethod, {'interpolate3D','levelsets'})}
            end
            arguments (Repeating)
                varargin
            end
            
            dNumVarargin = length(varargin);
            
            if strcmp(chInterpMethod, 'interpolate3D')
                if dNumVarargin == 0
                    chInterp3DMethod = 'linear'; % default
                elseif dNumVarargin == 1                               
                    chInterp3DMethod = char(varargin{1});
                    
                    ValidationUtils.MustBeRowVector(chInterp3DMethod);
                else
                    error(...
                        'ImagingObjectMaskSpatialTransform:Constructor:InvalidInterpolate3DParameters',...
                        'See constructor for details.');
                end
            else % levelsets
                % defaults:
                chInPlaneInterp2DMethod = 'linear'; 
                chThroughPlaneInterp1DMethod = 'pchip';
                dThroughPlaneDimension = []; % e.g. determine from geometry
                
                % go through varargin
                if mod(dNumVarargin,2) ~= 0
                    error(...
                        'ImagingObjectMaskSpatialTransform:Constructor:InvalidNumberOfLevelSetParameters',...
                        'See constructor for details.');
                end
                
                for dVarIndex=1:2:dNumVarargin
                    switch varargin{dVarIndex}
                        case 'InPlaneInterp2DMethod'
                            chInPlaneInterp2DMethod = char(varargin{dVarIndex+1});
                            
                            ValidationUtils.MustBeCharString(chInPlaneInterp2DMethod);
                        case 'ThroughPlaneInterp1DMethod'
                            chThroughPlaneInterp1DMethod = char(varargin{dVarIndex+1});
                            
                            ValidationUtils.MustBeCharString(chThroughPlaneInterp1DMethod);                            
                        case 'ThroughPlaneDimension'
                            dThroughPlaneDimension = double(varargin{dVarIndex+1});
                            
                            if ~isempty(dThroughPlaneDimension)
                                mustBeMember(dThroughPlaneDimension, [1,2,3]);
                            end
                        otherwise
                            error(...
                                'ImagingObjectMaskSpatialTransform:Constructor:InvalidParameterName',...
                                ['"', varargin{dVarIndex}, '" is not recognized. See constructor for details.']);
                    end
                end
                
                % if dThroughPlaneDimension not set, try to auto find it
                if isempty(dThroughPlaneDimension)
                    dThroughPlaneDimension = oCurrentImagingObject.GetImageVolumeGeometry().GetThroughPlaneDimensionForMaskLevelSetInterpolation();
                end
                
                % further validation
                ImagingObjectMaskSpatialTransform.ValidateLevelSetInterpolationMethod(chThroughPlaneInterp1DMethod);
            end
            
            % Super-class constructor
            obj@IndependentImagingObjectTransform(oTargetImageVolumeGeometry, oTargetImageVolumeGeometry); % target geometry will be fulfilled by the transform
            
            % Set properities
            obj.chInterpolationMethod = chInterpMethod;
            
            if strcmp(chInterpMethod, 'interpolate3D')
                obj.chInterp3DMethod = chInterp3DMethod;      
            else % levelsets
                obj.chInPlaneInterp2DMethod = chInPlaneInterp2DMethod;
                obj.chThroughPlaneInterp1DMethod = chThroughPlaneInterp1DMethod;
                obj.dThroughPlaneDimension = dThroughPlaneDimension;
            end
        end
        
        function Apply(obj, oImageVolume)
            if strcmp(obj.chInterpolationMethod, 'interpolate3D')
                c1xInterpVarargin = {obj.chInterp3DMethod};
            else
                c1xInterpVarargin = {...
                    obj.chInPlaneInterp2DMethod,...
                    obj.chThroughPlaneInterp1DMethod,...
                    obj.dThroughPlaneDimension};
            end
            
            oImageVolume.ApplyMaskSpatialInterpolation(...
                obj.oTargetImageVolumeGeometry,...           
                obj.chInterpolationMethod,...
                c1xInterpVarargin{:});
        end
    end
    
    
    methods (Access = private, Static = true)
        
        function ValidateLevelSetInterpolationMethod(chThroughPlane1DLevelSetInterpolationMethod)
            if strcmp(chThroughPlane1DLevelSetInterpolationMethod, 'spline')
                warning(...
                    'ImagingObjectMaskSpatialTransform:Constructor:SplineInterpolation',...
                    'It is HIGHLY recommended to NOT use ''spline'' for level set interpolation. Masks are not ideal for the 2nd derivative continuity enforced by spline interpolation. It is recommended to visualized the produced masks to confirm their accuracy.');
            end
        end
        
        function dThroughPlaneDimension = GetDefaultThroughPlaneDimension(oCurrentImagingObject)
            % Get dMaskThroughPlaneSliceDimension from varargin in or the
            % current imaging object
                        
            dThroughPlaneDimension = oCurrentImagingObject.GetImageVolumeGeomtry().GetContouringDimension();
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

