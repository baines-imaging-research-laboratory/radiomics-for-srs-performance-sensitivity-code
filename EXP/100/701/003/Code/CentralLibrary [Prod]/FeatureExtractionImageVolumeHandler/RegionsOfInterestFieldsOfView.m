classdef RegionsOfInterestFieldsOfView < handle
    %RegionsOfInterestFieldsOfView
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Oct 13, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)
        dNumberOfRegionsOfInterestNumbers
    end
    
    
    properties (Constant = true, GetAccess = public)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract = true)
        RenderFieldOfViewOnAxesByExtractionIndex(obj, hAxes, dRegionOfInterestNumber, NameValueArgs)
        % NameValueArgs.ForceImagingPlaneType
    end
    
    methods (Access = public)
        
        function obj = RegionsOfInterestFieldsOfView(dNumberOfRegionsOfInterestNumbers)
            obj.dNumberOfRegionsOfInterestNumbers = dNumberOfRegionsOfInterestNumbers;
        end
    end
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
           
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