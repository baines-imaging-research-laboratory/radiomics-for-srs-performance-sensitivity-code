classdef (Abstract) DependentImagingObjectTransform < ImagingObjectTransform
    %DependentImagingObjectTransform
    %
    % A DependentImagingObjectTransform is an ImagingObjectTransform
    % that can only be completed using additional GeometricalImagingObject
    % objects to the GeometricalImagingObject the transform is being
    % applied to. This would include applying boolean operations to a
    % GeometricalImagingObject with a second GeometricalImagingObject used
    % as the second input.
    % These transform cannot store the addition GeometricalImagingObject
    % objects within the transform objects due to memory constraints when
    % saving/loading. These transforms are therefore immediately applied
    % when added to a GeometricalImagingObject.
    
    % Primary Author: David DeVries
    % Created: May 19, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = private, GetAccess = public)
        c1xDependentInputs = {} % this holds the "dependent" pieces of the transform that are removed after the transform is applied
    end    
        
       
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public) % None        
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract = true)
       
        ApplyWithDependentInputs(obj, oGeometricalImagingObject, varargin)
    end
    
    methods (Access = protected)
        
        function obj = DependentImagingObjectTransform(oTargetImageVolumeGeometry, oPostTransformImageVolumeGeometry, varargin)
            % super-class constructor
            obj@ImagingObjectTransform(oTargetImageVolumeGeometry, oPostTransformImageVolumeGeometry);
            
            % this class
            obj.c1xDependentInputs = varargin;
        end
    end

    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ImagingObjectTransform, ?GeometricalImagingObject})
        
        function Apply(obj, oGeometricalImagingObject)
            arguments
                obj (1,1) DependentImagingObjectTransform
                oGeometricalImagingObject (1,1) GeometricalImagingObject
            end
            
            % turnover control to the concrete sub-class, but pass the
            % sub-class the dependent inputs for use
            obj.ApplyWithDependentInputs(oGeometricalImagingObject, obj.c1xDependentInputs{:}); 
            
            % clear-out the dependent inputs (too large to be stored)
            obj.c1xDependentInputs = {};
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

