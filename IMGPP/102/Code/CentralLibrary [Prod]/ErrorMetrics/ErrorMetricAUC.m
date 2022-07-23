classdef ErrorMetricAUC < ErrorMetric
    %ErrorMetricAUC
    %
    % Error metric AUC object for optimization.
    
    % Primary Author: David DeVries
    % Created: August 31, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
    end
                
    properties (Access = protected, Constant = true)
        sName = "AUC"
        
        dMostOptimalValue = 1
        dLeastOptimalValue = 0
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function dErrorMetricValue = Calculate(obj, oGuessResult, NameValueArgs)
            %dErrorMetricValue = Calculate(obj, oGuessResult, NameValueArgs)
            %
            % SYNTAX:
            %  dErrorMetricValue = Calculate(obj, oGuessResult, Name, Value)
            %
            % DESCRIPTION:
            %  Calculates the value of the error metric.
            %
            % INPUT ARGUMENTS:
            %  obj: Error metric object
            %  oGuessResult: Guess result object to calculate the error
            %   metric.
            %  NameValueArgs:
            %   'JournalingOn' - (1,1) logical - Flag to turn off
            %    journalling (default: true)
            %   'SuppressWarnings' - (1,1) logical - Flag to suppress
            %   warnings
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object 
            
            arguments
                obj (1,1) ErrorMetricAUC
                oGuessResult (:,1) ClassificationGuessResult
                NameValueArgs.JournalingOn (1,1) logical = true
                NameValueArgs.SuppressWarnings (1,1) logical = false
            end
            
            varargin = namedargs2cell(NameValueArgs);
            
            dErrorMetricValue = ErrorMetricsCalculator.CalculateAUC(oGuessResult, 'JournalingOn', NameValueArgs.JournalingOn);
        end
    end
    
    methods (Access = public, Static = false)
        
        function obj = ErrorMetricAUC()
            %obj = ErrorMetricAUC
            %
            % SYNTAX:
            %
            % DESCRIPTION:
            %  Constructor for the error metric AUC object
            %
            % INPUT ARGUMENTS:
            %  -
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
        end          
    end
    
    
    methods (Access = public, Static = true) 
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
    end
    
    
    methods (Access = protected)    
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

