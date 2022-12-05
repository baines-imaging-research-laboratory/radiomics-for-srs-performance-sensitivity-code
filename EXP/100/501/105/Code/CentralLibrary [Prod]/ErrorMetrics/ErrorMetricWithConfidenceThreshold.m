classdef (Abstract) ErrorMetricWithConfidenceThreshold < ErrorMetric
    %ErrorMetricWithConfidenceThreshold
    %
    % Parent abstract class for all error metrics equiring a confidence
    % threshold for calculation.
    
    % Primary Author: David DeVries
    % Created: August 31, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        bCalculateOptimalThreshold (1,1) logical
        
        vsCalculateOptimalThresholdCriteria (1,:) string
        dUserDefinedConfidenceThreshold double {ValidationUtils.MustBeEmptyOrScalar}
    end
                
    properties (Access = protected, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function dErrorMetricValue = Calculate(obj, oGuessResult, NameValueArgs)
            %dErrorMetricValue = Calculate(obj, oGuessResult, NameValueArgs)
            %
            % SYNTAX:
            %  dErrorMetricValue = Calculate(obj, oGuessResult, NameValueArgs)
            %  dErrorMetricValue = Calculate(___, ___, 'JournalingOn', false)
            %  dErrorMetricValue = Calculate(___, ___, 'SuppressWarnings', true)
            %
            % DESCRIPTION:
            %  Calls the specific concrrete object functions to calculate the error metric. 
            %
            % INPUT ARGUMENTS:
            %   obj: Constructed object
            %   oGuessResult: A valid guess result object.
            %   NameValueArgs:
            %   'JournalingOn' - (1,1) logical - Flag to turn off
            %    journalling (default: true)
            %   'SuppressWarnings'  - (1,1) logical - Flag to suppress
            %    notifications.
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
            
            arguments
                obj (1,1) ErrorMetricWithConfidenceThreshold
                oGuessResult (:,1) ClassificationGuessResult
                NameValueArgs.JournalingOn (1,1) logical = true
                NameValueArgs.SuppressWarnings (1,1) logical = false
            end
            
            if obj.bCalculateOptimalThreshold
                varargin = namedargs2cell(NameValueArgs);
                
                dThreshold = ErrorMetricsCalculator.CalculateOptimalThreshold(cellstr(obj.vsCalculateOptimalThresholdCriteria), oGuessResult, varargin{:});
            else
                dThreshold = obj.dUserDefinedConfidenceThreshold;
            end
            
            NameValueArgs = rmfield(NameValueArgs, 'SuppressWarnings');
            varargin = namedargs2cell(NameValueArgs);
            
            dErrorMetricValue = obj.CalculateMetricWithThreshold(oGuessResult, dThreshold, varargin{:});
        end
    end
    
    methods (Access = public, Static = false)
        
        function obj = ErrorMetricWithConfidenceThreshold(bCalculateOptimalThreshold, xThresholdParameter)
            %obj = ErrorMetricWithConfidenceThreshold(bCalculateOptimalThreshold, xThresholdParameter)
            %
            % SYNTAX:
            %  obj = ErrorMetricWithConfidenceThreshold(true, vsCalculateOptimalThresholdCriteria)
            %  obj = ErrorMetricWithConfidenceThreshold(false, dUserDefinedConfidenceThreshold)
            %
            % DESCRIPTION:
            %  Validates the xThresholdParameter input based on the flag for calculating optimal threshold. 
            %
            % INPUT ARGUMENTS:
            %  bCalculateOptimalThreshold: Flag for calculating optimal
            %   threshold or not.
            %  xThresholdParameter: Parameter that is either a vector of
            %   strings for optimal criteria or a double indicating the
            %   desired threshold to use.
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
            
            arguments
                bCalculateOptimalThreshold (1,1) logical
                xThresholdParameter
            end
            
            obj.bCalculateOptimalThreshold = bCalculateOptimalThreshold;
            
            if bCalculateOptimalThreshold
                obj.vsCalculateOptimalThresholdCriteria = ErrorMetricWithConfidenceThreshold.ValidateCalculateOptimalThresholdCriteria(xThresholdParameter);
            else
                obj.dUserDefinedConfidenceThreshold = ErrorMetricWithConfidenceThreshold.ValidateUserDefinedConfidenceThreshold(xThresholdParameter);
            end                
        end          
    end
    
    
    methods (Access = public, Static = true) 
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
        
        dErrorMetricValue = CalculateMetricWithThreshold(obj, oGuessResult, dThreshold, NameValueArgs);
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
        
        function vsCalculateOptimalThresholdCriteria = ValidateCalculateOptimalThresholdCriteria(vsCalculateOptimalThresholdCriteria)
            %vsCalculateOptimalThresholdCriteria = ValidateCalculateOptimalThresholdCriteria(vsCalculateOptimalThresholdCriteria)
            %
            % SYNTAX:
            %  vsCalculateOptimalThresholdCriteria = ValidateCalculateOptimalThresholdCriteria(vsCalculateOptimalThresholdCriteria)
            %
            % DESCRIPTION:
            %  Validates the optimal threshold criteria.
            %
            % INPUT ARGUMENTS:
            %  vsCalculateOptimalThresholdCriteria: User defined optimal
            %   threshold criteria.
            %
            % OUTPUTS ARGUMENTS:
            %  vsCalculateOptimalThresholdCriteria: User defined optimal
            %   threshold criteria.
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
            
            arguments
                vsCalculateOptimalThresholdCriteria (1,:) string {mustBeMember(vsCalculateOptimalThresholdCriteria, ["FNR", "FPR", "TNR", "TPR", "MCR", "matlab", "upperleft"])}
            end
        end
        
        function dUserDefinedConfidenceThreshold = ValidateUserDefinedConfidenceThreshold(dUserDefinedConfidenceThreshold)
            %dUserDefinedConfidenceThreshold = ValidateUserDefinedConfidenceThreshold(dUserDefinedConfidenceThreshold)
            %
            % SYNTAX:
            %  dUserDefinedConfidenceThreshold = ValidateUserDefinedConfidenceThreshold(dUserDefinedConfidenceThreshold)
            %
            % DESCRIPTION:
            %  Validates the user-defined threshold.
            %
            % INPUT ARGUMENTS:
            %  dUserDefinedConfidenceThreshold: User defined
            %   threshold.
            %
            % OUTPUTS ARGUMENTS:
            %  dUserDefinedConfidenceThreshold: User defined
            %   threshold.
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
            
            arguments
                dUserDefinedConfidenceThreshold (1,1) double {mustBeNonnegative, mustBeLessThanOrEqual(dUserDefinedConfidenceThreshold, 1)}
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

