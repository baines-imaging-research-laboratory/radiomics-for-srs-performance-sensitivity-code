classdef ImagingObjectFirstVoxelTransform < IndependentImagingObjectTransform
    %ImagingObjectFirstVoxelTransform
    %
    % Given a target image volume geometry, this transform changes which voxel in
    % the GeometricalImagingObject is the "first voxel" (e.g. voxel
    % (1,1,1)). The actual image data is therefore only rotated/flipped and
    % no interpolation is completed. Since the image data is only
    % rotated/flipped, the target image volume geometry is only matched as
    % closely as possible
    
    % Primary Author: David DeVries
    % Created: June 21, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Access = private) % None
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
        
        function obj = ImagingObjectFirstVoxelTransform(oCurrentImageVolumeGeometry, oTargetImageVolumeGeometry)
            % Validate
            ImagingObjectFirstVoxelTransform.ValidateCurrentImageVolumeGeometry(oCurrentImageVolumeGeometry);
            ImagingObjectFirstVoxelTransform.ValidateTargetImageVolumeGeometry(oTargetImageVolumeGeometry);
                        
            % Get geometry after transform (won't be the same as the
            % target, since it'll get as close to the target as possible
            % without having to interpolate)
            [~, oPostTransformImageVolumeGeometry] = oCurrentImageVolumeGeometry.ReassignFirstVoxel([], oTargetImageVolumeGeometry);
            
            % Super-class Constructor
            obj@IndependentImagingObjectTransform(oTargetImageVolumeGeometry, oPostTransformImageVolumeGeometry);
        end
        
        function Apply(obj, oImagingObject)
            oImagingObject.ApplyReassignFirstVoxel(obj.oTargetImageVolumeGeometry);
        end
    end
    
    methods (Access = private, Static = true)
        
        function ValidateCurrentImageVolumeGeometry(oCurrentImageVolumeGeometry)
            if ~isscalar(oCurrentImageVolumeGeometry) || ~isa(oCurrentImageVolumeGeometry, 'ImageVolumeGeometry')
                error(...
                    'ImagingObjectFirstVoxelTransform:ValidateCurrentImageVolumeGeometry:InvalidType',...
                    'oCurrentImageVolumeGeometry must be a scalar of type ImageVolumeGeometry');
            end
        end
        
        function ValidateTargetImageVolumeGeometry(oTargetImageVolumeGeometry)
            if ~isscalar(oTargetImageVolumeGeometry) || ~isa(oTargetImageVolumeGeometry, 'ImageVolumeGeometry')
                error(...
                    'ImagingObjectFirstVoxelTransform:ValidateTargetImageVolumeGeometry:InvalidType',...
                    'oTargetImageVolumeGeometry must be a scalar of type ImageVolumeGeometry');
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

