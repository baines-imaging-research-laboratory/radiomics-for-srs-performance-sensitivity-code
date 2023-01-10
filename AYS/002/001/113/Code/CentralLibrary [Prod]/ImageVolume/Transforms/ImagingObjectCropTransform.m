classdef ImagingObjectCropTransform < IndependentImagingObjectTransform
    %ImagingObjectCropTransform
    %
    % Crops the imaging object field of view
    
    % Primary Author: David DeVries
    % Created: June 21, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        m2dCropBounds (3,2) double % rows: dimension, cols: bounds
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
        
        function obj = ImagingObjectCropTransform(oStartingImageVolumeGeometry, vdRowBounds, vdColBounds, vdSliceBounds)
            arguments
                oStartingImageVolumeGeometry (1,1) ImageVolumeGeometry
                vdRowBounds (1,2) double
                vdColBounds (1,2) double
                vdSliceBounds (1,2) double
            end
            
            vdVoxelDims_mm = oStartingImageVolumeGeometry.GetVoxelDimensions_mm();
            vdVolumeDims = oStartingImageVolumeGeometry.GetVolumeDimensions();
            vdFirstVoxelPosition_mm = oStartingImageVolumeGeometry.GetFirstVoxelPosition_mm();
            
            vdRowAxisUnitVector = oStartingImageVolumeGeometry.GetRowAxisUnitVector();
            vdColAxisUnitVector = oStartingImageVolumeGeometry.GetColumnAxisUnitVector();
            vdSliceAxisUnitVector = oStartingImageVolumeGeometry.GetSliceAxisUnitVector();
            
            vdNewVolumeDims = [...
                vdRowBounds(2)-vdRowBounds(1)+1
                vdColBounds(2)-vdColBounds(1)+1
                vdSliceBounds(2)-vdSliceBounds(1)+1];
            
            vdNewFirstVoxelPosition_mm = vdFirstVoxelPosition_mm + ...
                vdRowAxisUnitVector * (vdRowBounds(1)-1) * vdVoxelDims_mm(1) + ...
                vdColAxisUnitVector * (vdColBounds(1)-1) * vdVoxelDims_mm(2) + ...
                vdSliceAxisUnitVector * (vdSliceBounds(1)-1) * vdVoxelDims_mm(3);
            
            c1xVarargin = {};
            
            dAcquisitionDimension = oStartingImageVolumeGeometry.GetAcquisitionDimension();
            
            if ~isempty(dAcquisitionDimension)
                c1xVarargin = {dAcquisitionDimension, oStartingImageVolumeGeometry.GetAcquisitionSliceThickness_mm};
            end
            
            oTargetImageVolumeGeometry = ImageVolumeGeometry(...
                vdNewVolumeDims, vdRowAxisUnitVector, vdColAxisUnitVector,...
                vdVoxelDims_mm, vdNewFirstVoxelPosition_mm,...
                c1xVarargin{:});
                            
            oPostTransformImageVolumeGeometry = oTargetImageVolumeGeometry; % this geometry will be achieved, guaranteed
            
            % Super-class Constructor
            obj@IndependentImagingObjectTransform(oTargetImageVolumeGeometry, oPostTransformImageVolumeGeometry);
                
            % Set properities
            obj.m2dCropBounds = [vdRowBounds; vdColBounds; vdSliceBounds];
        end
        
        function Apply(obj, oImagingObject)
            oImagingObject.ApplyCrop(obj.m2dCropBounds, obj.oTargetImageVolumeGeometry);
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

