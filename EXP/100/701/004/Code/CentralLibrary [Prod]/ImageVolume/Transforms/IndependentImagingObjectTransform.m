classdef (Abstract) IndependentImagingObjectTransform < ImagingObjectTransform
    %IndependentImagingObjectTransform
    %
    % An IndependentImagingObjectTransform is an ImagingObjectTransform
    % that can be completed using only the GeometricalImagingObject on
    % which the transform is applied. This means the transform can be
    % applied using very little additional pieces of data, such as an
    % ImageVolumeGeometry or morphological operation. This is opposed to a
    % DependentImagingObjectTransform that requires addition
    % GeometricalImagingObjects to be performed.
    % IndependentImagingObjectTransform objects do not need to be applied
    % to a GeometricalImagingObject at the time of addition to the series
    % of transform applied.
    
    % Primary Author: David DeVries
    % Created: May 19, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties % None
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
        
        function obj = IndependentImagingObjectTransform(oTargetImageVolumeGeometry, oPostTransformImageVolumeGeometry)
            % super-class constructor
            obj@ImagingObjectTransform(oTargetImageVolumeGeometry, oPostTransformImageVolumeGeometry);
        end
    end

    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private) % None
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

