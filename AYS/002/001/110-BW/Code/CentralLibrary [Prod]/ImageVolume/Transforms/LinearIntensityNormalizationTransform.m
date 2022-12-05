classdef LinearIntensityNormalizationTransform < IndependentImagingObjectTransform
    %LinearIntensityNormalizationTransform
    %
    % Todo
    
    % Primary Author: David DeVries
    % Created: July 22, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        dCurrentIntensityValue (1,1) double {mustBeFinite}
        dNewIntensityValue (1,1) double {mustBeFinite}
        chNewImageDataClass(1,:) char
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
    end
    

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ImagingObjectTransform, ?GeometricalImagingObject})
        
        function obj = LinearIntensityNormalizationTransform(oImageVolume, dCurrentIntensityValue, dNewIntensityValue, chNewImageDataClass)
            arguments
                oImageVolume (1,1) ImageVolume
                dCurrentIntensityValue (1,1) double {mustBeFinite}
                dNewIntensityValue (1,1) double {mustBeFinite}
                chNewImageDataClass(1,:) char
            end
            
            % super-class call
            oImageVolumeGeometry = oImageVolume.GetImageVolumeGeometry();
            
            obj@IndependentImagingObjectTransform(oImageVolumeGeometry, oImageVolumeGeometry); % target and post-transform geometry will be equal
            
            % local call
            obj.dCurrentIntensityValue = dCurrentIntensityValue;
            obj.dNewIntensityValue = dNewIntensityValue;
            obj.chNewImageDataClass = chNewImageDataClass;
        end
        
        function Apply(obj, oImagingObject)
            m3dCurrentImageData = double(oImagingObject.GetCurrentImageDataForTransform());
            
            m3dCurrentImageData = m3dCurrentImageData .* (obj.dNewIntensityValue / obj.dCurrentIntensityValue);
            m3dCurrentImageData = cast(m3dCurrentImageData, obj.chNewImageDataClass);
            
            oImagingObject.ApplyImagingObjectIntensityTransform(m3dCurrentImageData);
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

