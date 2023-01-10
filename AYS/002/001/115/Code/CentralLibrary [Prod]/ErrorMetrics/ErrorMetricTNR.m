classdef ErrorMetricTNR < ErrorMetricWithConfidenceThreshold
    %ErrorMetricTNR
    %
    % Error metric TNR object for optimization.
    
    % Primary Author: David DeVries
    % Created: August 31, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
    end
                
    properties (Access = protected, Constant = true)
        sName = "TNR"
        
        dMostOptimalValue = 1
        dLeastOptimalValue = 0
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
    end
    
    methods (Access = public, Static = false)
        
        function obj = ErrorMetricTNR(bCalculateOptimalThreshold, xThresholdParameter)
            %obj = ErrorMetricTNR(bCalculateOptimalThreshold, xThresholdParameter)
            %
            % SYNTAX:
            %  obj = ErrorMetricTNR(true, vsCalculateOptimalThresholdCriteria)
            %  obj = ErrorMetricTNR(false, dUserDefinedConfidenceThreshold)
            %
            % DESCRIPTION:
            %  Constructor for the error metric TNR object
            %
            % INPUT ARGUMENTS:
            %  bCalculateOptimalThreshold: Flag to find the optimal
            %   threshold instead of using a deefault or user input.
            %  xThresholdParameter: Can be either a vector of strings for
            %   optimal threshold criteria or a double indicating the
            %   threshold cutoff value.
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
            
            arguments
                bCalculateOptimalThreshold (1,1) logical = false
                xThresholdParameter = 0.5
            end
            
            obj@ErrorMetricWithConfidenceThreshold(bCalculateOptimalThreshold, xThresholdParameter);               
        end          
    end
    
    
    methods (Access = public, Static = true) 
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function dErrorMetricValue = CalculateMetricWithThreshold(obj, oGuessResult, dThreshold, NameValueArgs)
            %dErrorMetricValue = CalculateMetricWithThreshold(obj, oGuessResult, dThreshold, NameValueArgs)
            %
            % SYNTAX:
            %  dErrorMetricValue = CalculateMetricWithThreshold(obj, oGuessResult, dThreshold)
            %  dErrorMetricValue = CalculateMetricWithThreshold(obj, oGuessResult, dThreshold, 'JournalingOn', false)
            %
            % DESCRIPTION:
            %  Calculates the value of the error metric at a given threshold.
            %
            % INPUT ARGUMENTS:
            %  obj: Error metric object
            %  oGuessResult: Guess result object to calculate the error
            %   metric.
            %  dThreshold: Cutoff value to assess the TNR.
            %  NameValueArgs:
            %   'JournalingOn' - (1,1) logical - Flag to turn off
            %    journalling (default: true)
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object 
            
            arguments
                obj (1,1) ErrorMetricTNR
                oGuessResult (:,1) ClassificationGuessResult
                dThreshold (1,1) double
                NameValueArgs.JournalingOn (1,1) logical
            end
            
            varargin = namedargs2cell(NameValueArgs);
            
            dErrorMetricValue = ErrorMetricsCalculator.CalculateFalsePositiveRate(oGuessResult, dThreshold, varargin{:});
        end
    end
    
    
    methods (Access = protected, Static = true)      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
      
    methods (Access = private, Static = false)       
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

