classdef LabelMapMorphologicalTransform < IndependentImagingObjectTransform
    %LabelMapMorphologicalTransform
    %
    % Computes one of Matlab's morphological transform functions on the
    % boolean masks of a RegionsOfInterest object.
    
    % Primary Author: David DeVries
    % Created: Nov 5, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)        
        vdRegionOfInterestNumbers % which ROIs to apply the transform to
        
        fnFunctionHandle
        c1xFunctionParameters
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
        
        function obj = LabelMapMorphologicalTransform(oCurrentLabelMapRegionsOfInterest, vdRegionOfInterestNumbers, fnFunctionHandle, varargin)
            % obj = LabelMapMorphologicalTransform(oCurrentLabelMapRegionsOfInterest, vdRegionOfInterestNumbers, fnFunctionHandle, varargin)
            % 
            % SYNTAX:
            %  obj = LabelMapMorphologicalTransform(oCurrentLabelMapRegionsOfInterest, 'imdilate', __, __, ...)
            %  obj = LabelMapMorphologicalTransform(__, 'imerode', __, __, ...)
            arguments
                oCurrentLabelMapRegionsOfInterest (1,1) LabelMapRegionsOfInterest
                vdRegionOfInterestNumbers (1,:) double {MustBeValidRegionOfInterestNumbers(oCurrentLabelMapRegionsOfInterest, vdRegionOfInterestNumbers)}
                fnFunctionHandle (1,1) function_handle           
            end
            arguments (Repeating)
                varargin
            end
            
            oCurrentImageVolumeGeometry = oCurrentLabelMapRegionsOfInterest.GetImageVolumeGeometry();
            
            % Super-class constructor
            obj@IndependentImagingObjectTransform(oCurrentImageVolumeGeometry, oCurrentImageVolumeGeometry); % image volume geometry will not be changed
                      
            % validate that the function call would work                       
            m3bDummyMask = randi(2, 3, 4, 5) == 1;
            
            try
                m3bDummyOutputMask = fnFunctionHandle(m3bDummyMask, varargin{:});
            catch e
                error(...
                    'LabelMapMorphologicalTransform:Constructor:NonOperationalFunction',...
                    'The provided function errored when tested.');
            end                    
            
            if ~all(size(m3bDummyMask) == size(m3bDummyOutputMask))
                error(...
                    'LabelMapMorphologicalTransform:Constructor:FunctionChangesMaskDimensions',...
                    'The provided function cannot change the mask dimensions.');
            end
            
            if ~isa(m3bDummyOutputMask, 'logical')
                error(...
                    'LabelMapMorphologicalTransform:Constructor:FunctionChangesMaskDatatype',...
                    'The provided function must output a logical matrix.');
            end
            
            % Set properities
            obj.vdRegionOfInterestNumbers = vdRegionOfInterestNumbers;
            obj.fnFunctionHandle = fnFunctionHandle; 
            obj.c1xFunctionParameters = varargin;
        end
        
        function Apply(obj, oLabelMapRegionsOfInterest)
            oLabelMapRegionsOfInterest.ApplyMorphologicalTransform(...
                obj.vdRegionOfInterestNumbers,...
                obj.fnFunctionHandle,...           
                obj.c1xFunctionParameters{:});
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

