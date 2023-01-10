classdef (Abstract) ImagingObjectTransform < matlab.mixin.Heterogeneous & handle
    %ImagingObjectTransform
    %
    % An abstract class at the top of the Transform inheritance structure.
    % This class only contains the target and post transform
    % ImageVolumeGeometry values, such that a final image volume geometry
    % for a series of transforms can be known without calculating the
    % full transforms.
    
    % Primary Author: David DeVries
    % Created: June 21, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        oTargetImageVolumeGeometry = []
        oPostTransformImageVolumeGeometry = []
    end    
        
       
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public) % None        
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function obj = ImagingObjectTransform(oTargetImageVolumeGeometry, oPostTransformImageVolumeGeometry)
            % Validation
            ImagingObjectTransform.ValidateImageVolumeGeometry(oTargetImageVolumeGeometry);
            ImagingObjectTransform.ValidateImageVolumeGeometry(oPostTransformImageVolumeGeometry);            
            
            % Set properities
            obj.oTargetImageVolumeGeometry = oTargetImageVolumeGeometry;
            obj.oPostTransformImageVolumeGeometry = oPostTransformImageVolumeGeometry;
        end
    end

    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ImagingObjectTransform, ?GeometricalImagingObject}, Abstract = true)
        Apply(obj, oImagingObject)
    end
    
    methods (Access = {?GeometricalImagingObject})
        
        function oTargetImageVolumeGeometry = GetTargetImageVolumeGeometry(obj)
            oTargetImageVolumeGeometry = obj.oTargetImageVolumeGeometry;
        end
        
        function oPostTransformImageVolumeGeometry = GetPostTransformImageVolumeGeometry(obj)
            oPostTransformImageVolumeGeometry = obj.oPostTransformImageVolumeGeometry;
        end
    end
    
    methods (Access = private, Static = true)
        
        function ValidateImageVolumeGeometry(oImageVolumeGeometry)
            if ~isscalar(oImageVolumeGeometry) || ~isa(oImageVolumeGeometry, 'ImageVolumeGeometry')
                error(...
                    'ImagingObjectTransform:ValidateImageVolumeGeometry:InvalidType',...
                    'oImageVolumeGeometry must be a scalar of type ImageVolumeGeometry');
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

