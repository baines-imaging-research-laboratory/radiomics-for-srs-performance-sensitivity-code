classdef ImagingObjectScalarDataSpatialTransform < IndependentImagingObjectTransform
    %ImagingObjectScalarDataSpatialTransform
    %
    % Interpolation of scalar imaging data onto a target image volume
    % geometry
    
    % Primary Author: David DeVries
    % Created: June 21, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        ch3DInterpolationMethod
        dExtrapolationValue
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
        
        function obj = ImagingObjectScalarDataSpatialTransform(oTargetImageVolumeGeometry, ch3DInterpolationMethod, dExtrapolationValue)
            arguments
                oTargetImageVolumeGeometry (1,1) ImageVolumeGeometry
                ch3DInterpolationMethod (1,:) char
                dExtrapolationValue (1,1) double {mustBeFinite, mustBeReal}
            end
            
            % obj = ImagingObjectScalarDataSpatialTransform(oTargetImageVolumeGeometry, ch3DInterpolationMethod, dExtrapolationValue)
            
            oPostTransformImageVolumeGeometry = oTargetImageVolumeGeometry; % this geometry will be achieved, guaranteed
            
            % Super-class Constructor
            obj@IndependentImagingObjectTransform(oTargetImageVolumeGeometry, oPostTransformImageVolumeGeometry);
                
            % Set properities
            obj.ch3DInterpolationMethod = ch3DInterpolationMethod;
            obj.dExtrapolationValue = dExtrapolationValue;
        end
        
        function Apply(obj, oImagingObject)
            oImagingObject.ApplyScalarDataSpatialInterpolation(...
                obj.oTargetImageVolumeGeometry,...        
                obj.ch3DInterpolationMethod,...
                obj.dExtrapolationValue);
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

