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
        
        chFunctionName
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
        
        function obj = LabelMapMorphologicalTransform(oCurrentLabelMapRegionsOfInterest, vdRegionOfInterestNumbers, chFunctionName, varargin)
            % obj = LabelMapMorphologicalTransform(oCurrentLabelMapRegionsOfInterest, vdRegionOfInterestNumbers, chFunctionName, varargin)
            % 
            % SYNTAX:
            %  obj = LabelMapMorphologicalTransform(oCurrentLabelMapRegionsOfInterest, 'imdilate', __, __, ...)
            %  obj = LabelMapMorphologicalTransform(__, 'imerode', __, __, ...)
            arguments
                oCurrentLabelMapRegionsOfInterest (1,1) LabelMapRegionsOfInterest
                vdRegionOfInterestNumbers (1,:) double {MustBeValidRegionOfInterestNumbers(oCurrentLabelMapRegionsOfInterest, vdRegionOfInterestNumbers)}
                chFunctionName (1,:) char {LabelMapMorphologicalTransform.MustBeValidFunctionName(chFunctionName)}           
            end
            arguments (Repeating)
                varargin
            end
            
            oCurrentImageVolumeGeometry = oCurrentLabelMapRegionsOfInterest.GetImageVolumeGeometry();
            
            % Super-class constructor
            obj@IndependentImagingObjectTransform(oCurrentImageVolumeGeometry, oCurrentImageVolumeGeometry); % image volume geometry will not be changed
                      
            % validate that the function call would work
            vdDims = oCurrentImageVolumeGeometry.GetVolumeDimensions();
            
            vdDims(vdDims > 5) = 5; % max 5 x 5 x 5
            
            m3bDummyMask = randi(2, vdDims) == 1;
            
            try
                switch chFunctionName
                    case 'imerode'
                        m3bDummyMask = imerode(m3bDummyMask, varargin{:});
                    case 'imdilate'
                        m3bDummyMask = imdilate(m3bDummyMask, varargin{:});
                end
            catch e
                rethrow(e);
            end                    
            
            % Set properities
            obj.vdRegionOfInterestNumbers = vdRegionOfInterestNumbers;
            obj.chFunctionName = chFunctionName; 
            obj.c1xFunctionParameters = varargin;
        end
        
        function Apply(obj, oLabelMapRegionsOfInterest)
            oLabelMapRegionsOfInterest.ApplyMorphologicalTransform(...
                obj.vdRegionOfInterestNumbers,...
                obj.chFunctionName,...           
                obj.c1xFunctionParameters{:});
        end
    end
    
    
    methods (Access = private, Static = true)
        
        function MustBeValidFunctionName(chFunctionName)
            switch chFunctionName
                case 'imerode'
                    
                case 'imdilate'
                    
                otherwise
                    error(...
                        'LabelMapMorphologicalTransform:MustBeValidFunctionName:Invalid',...
                        [chFunctionName, ' is not a supported morphological function.']);
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

