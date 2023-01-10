classdef TypeCastTransform < IndependentImagingObjectTransform
    %TypeCastTransform
    %
    % This transform casts the underlying datatype of storing image data to
    % a custom datatype. This can help save memory (e.g. using uint8
    % instead of uint16), but possible overflow/underflow rounding could
    % occur.
    
    % Primary Author: David DeVries
    % Created: Mar 4, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)        
        chTypeCastClassName
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
        
        function obj = TypeCastTransform(oCurrentGeometricalImagingObject, chTypeCastClassName)
            % obj = TypeCastTransform(oCurrentGeometricalImagingObject, chTypeCastClassName)
            % 
            % SYNTAX:
            %  obj =
            %  TypeCastTransform(oCurrentGeometricalImagingObject, chTypeCastClassName)
                        
            oCurrentImageVolumeGeometry = oCurrentGeometricalImagingObject.GetImageVolumeGeometry();
            
            % Super-class constructor
            obj@IndependentImagingObjectTransform(oCurrentImageVolumeGeometry, oCurrentImageVolumeGeometry); % image volume geometry will not be changed
                      
            obj.chTypeCastClassName = chTypeCastClassName;
        end
        
        function Apply(obj, oGeometricalImagingObject)
            oGeometricalImagingObject.ApplyTypeCastTransform(...
                obj.chTypeCastClassName);
        end
    end
    
    
    methods (Access = private, Static = true)
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

