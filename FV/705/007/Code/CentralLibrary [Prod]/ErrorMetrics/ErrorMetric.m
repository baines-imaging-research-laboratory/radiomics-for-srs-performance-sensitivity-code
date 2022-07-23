classdef (Abstract) ErrorMetric < matlab.mixin.Heterogeneous
    %ErrorMetric
    %
    % Parent class for the error metric class for optimization.
    
    % Primary Author: David DeVries
    % Created: August 31, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
    end
    
    properties (Access = protected, Constant = true, Abstract = true)
        sName (1,1) string
        
        dMostOptimalValue (1,1) double {mustBeNonNan}
        dLeastOptimalValue (1,1) double {mustBeNonNan}
    end
    
    properties (Access = private, Constant = true, Abstract = false)
        chParameterFileVarName = 'tErrorMetricParameters'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract = true)
        
        dErrorMetricValue = Calculate(obj, oGuessResult, NameValueArgs)
    end
    
    methods (Access = public, Static = false)
        
        function obj = ErrorMetric
            %obj = ErrorMetric
            %
            % SYNTAX:
            % ErrorMetric()
            %
            % DESCRIPTION:
            %  Parent class constructor for ErrorMetric.
            %
            % INPUT ARGUMENTS:
            %  -
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
        end
        
        function dErrorMetricValue = RescaleValueForMinimaOptimization(obj, dErrorMetricValue)
            %dErrorMetricValue = RescaleValueForMinimaOptimization(obj, dErrorMetricValue)
            %
            % SYNTAX:
            % dErrorMetricValue = RescaleValueForMinimaOptimization(obj, dErrorMetricValue)
            %
            % DESCRIPTION:
            %  Rescales the error metric value for a minima optimization.
            %
            % INPUT ARGUMENTS:
            %  obj: Error metrics object.
            %  dErrorMetricValue: Resulting error metric value from the
            %   error metrics calculator.
            %
            % OUTPUTS ARGUMENTS:
            %  dErrorMetricValue: Rescaled error metric value from the
            %   error metrics calculator.
            
            % Primary Author: David DeVries
            % Created: August 31, 2020

            
            arguments
                obj (1,1) ErrorMetric
                dErrorMetricValue (1,1) double {MustBeValidErrorMetricValue(obj, dErrorMetricValue)}
            end
            
            if obj.dMostOptimalValue > obj.dLeastOptimalValue % need to rescale, otherwise no othing
                dErrorMetricValue = obj.dLeastOptimalValue + (obj.dMostOptimalValue - dErrorMetricValue);
            end
        end
        
        function dErrorMetricValue = RescaleValueForMaximaOptimization(obj, dErrorMetricValue)
            %dErrorMetricValue = RescaleValueForMaximaOptimization(obj, dErrorMetricValue)
            %
            % SYNTAX:
            % dErrorMetricValue = RescaleValueForMaximaOptimization(obj, dErrorMetricValue)
            %
            % DESCRIPTION:
            %  Rescales the error metric value for a maxima optimization.
            %
            % INPUT ARGUMENTS:
            %  obj: Error metrics object.
            %  dErrorMetricValue: Resulting error metric value from the
            %   error metrics calculator.
            %
            % OUTPUTS ARGUMENTS:
            %  dErrorMetricValue: Rescaled error metric value from the
            %   error metrics calculator.
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
            
            arguments
                obj (1,1) ErrorMetric
                dErrorMetricValue (1,1) double {MustBeValidErrorMetricValue(obj, dErrorMetricValue)}
            end
            
            if obj.dMostOptimalValue < obj.dLeastOptimalValue % need to rescale, otherwise no othing
                dErrorMetricValue = obj.dLeastOptimalValue - (dErrorMetricValue - obj.dMostOptimalValue);
            end
        end
        
        function sDescription = GetDescriptionStringForMinimaOptimization(obj)
            %sDescription = GetDescriptionStringForMinimaOptimization(obj)
            %
            % SYNTAX:
            % sDescription = GetDescriptionStringForMinimaOptimization(obj)
            %
            % DESCRIPTION:
            %  Retrieves the user made description for the minima
            %  optimization.
            %
            % INPUT ARGUMENTS:
            %  obj: Error metrics object.
            %
            % OUTPUTS ARGUMENTS:
            %  sDescription: Description string.
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
            
            if obj.dMostOptimalValue > obj.dLeastOptimalValue
                if obj.dLeastOptimalValue == 0
                    sDescription = string(num2str(obj.dMostOptimalValue)) + " - " + obj.sName;
                else
                    sDescription = string(num2str(obj.dLeastOptimalValue)) + " + (" + string(num2str(obj.dMostOptimalValue)) + " - " + obj.sName + ")";
                end
            else
                sDescription = obj.sName;
            end
        end
        
        function sDescription = GetDescriptionStringForMaximaOptimization(obj)
            %sDescription = GetDescriptionStringForMaximaOptimization(obj)
            %
            % SYNTAX:
            % sDescription = GetDescriptionStringForMaximaOptimization(obj)
            %
            % DESCRIPTION:
            %  Retrieves the user made description for the maxima
            %  optimization.
            %
            % INPUT ARGUMENTS:
            %  obj: Error metrics object.
            %
            % OUTPUTS ARGUMENTS:
            %  sDescription: Description string.
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
            
            if obj.dMostOptimalValue < obj.dLeastOptimalValue
                if obj.dLeastOptimalValue == 0
                    sDescription = obj.sName + " - " + string(num2str(obj.dMostOptimalValue));
                else
                    sDescription = string(num2str(obj.dLeastOptimalValue)) + " - (" + obj.sName + " - " + string(num2str(obj.dMostOptimalValue)) + ")";
                end
            else
                sDescription = obj.sName;
            end
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = CreateFromParameterFile(chErrorMetricParametersFilePath)
            %obj = CreateFromParameterFile(chErrorMetricParametersFilePath)
            %
            % SYNTAX:
            % obj = CreateFromParameterFile(chErrorMetricParametersFilePath)
            %
            % DESCRIPTION:
            %  Reads in parameters from the external file and creates the
            %  error metrics object.
            %
            % INPUT ARGUMENTS:
            %  chErrorMetricParametersFilePath: Filepath to the parameters file.
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object.
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
            
            arguments
                chErrorMetricParametersFilePath (1,:) char
            end
            
            tParameters = FileIOUtils.LoadMatFile(chErrorMetricParametersFilePath, ErrorMetric.chParameterFileVarName);
            
            vsVarNames = tParameters.sName;
            c1xValues = tParameters.c1xValue;
            
            vdErrorMetricRows = find(vsVarNames == "ErrorMetric");
            
            if ~isscalar(vdErrorMetricRows)
                error(...
                    'ErrorMetric:CreateFromParameterFile:NonUniqueErrorMetricEntry',...
                    'The parameters file should include a single row with a "sName" entry of "ErrorMetric".');
            end
            
            sErrorMetric = string(c1xValues{vdErrorMetricRows(1)});
            ValidationUtils.MustBeScalar(sErrorMetric);
            
            if sErrorMetric == "AUC"
                obj = ErrorMetricAUC();
                
            elseif any(sErrorMetric == ["MCR", "TPR", "TNR", "FPR", "FNR"])
                vdCalculateOptimalThresholdRows = find(vsVarNames == "CalculateOptimalThreshold");
                
                if ~isscalar(vdCalculateOptimalThresholdRows)
                    error(...
                        'ErrorMetric:CreateFromParameterFile:NonUniqueCalculateOptimalThresholdEntry',...
                        'The parameters file should include a single row with a "sName" entry of "CalculateOptimalThreshold".');
                end
                
                bCalculateOptimalThreshold = c1xValues{vdCalculateOptimalThresholdRows(1)};
                ValidationUtils.MustBeScalar(bCalculateOptimalThreshold);
                ValidationUtils.MustBeA(bCalculateOptimalThreshold, 'logical');
                
                if bCalculateOptimalThreshold
                    vdCalculateOptimalThresholdCriteriaRows = find(vsVarNames == "CalculateOptimalThresholdCriteria");
                    
                    if ~isscalar(vdCalculateOptimalThresholdCriteriaRows)
                        error(...
                            'ErrorMetric:CreateFromParameterFile:NonUniqueCalculateOptimalThresholdCriteriaEntry',...
                            'The parameters file should include a single row with a "sName" entry of "CalculateOptimalThresholdCriteria".');
                    end
                    
                    vsCalculateOptimalThresholdCriteria = c1xValues{vdCalculateOptimalThresholdCriteriaRows(1)};
                    ValidationUtils.MustBeRowVector(vsCalculateOptimalThresholdCriteria);
                    ValidationUtils.MustBeA(vsCalculateOptimalThresholdCriteria, 'string');
                    
                    c1xVarargin = {bCalculateOptimalThreshold, vsCalculateOptimalThresholdCriteria};
                else
                    vdUserDefinedConfidenceThresholdRows = find(vsVarNames == "UserDefinedConfidenceThreshold");
                    
                    if ~isscalar(vdUserDefinedConfidenceThresholdRows)
                        error(...
                            'ErrorMetric:CreateFromParameterFile:NonUniqueUserDefinedConfidenceThresholdEntry',...
                            'The parameters file should include a single row with a "sName" entry of "UserDefinedConfidenceThreshold".');
                    end
                    
                    dUserDefinedConfidenceThreshold = c1xValues{vdUserDefinedConfidenceThresholdRows(1)};
                    ValidationUtils.MustBeScalar(dUserDefinedConfidenceThreshold);
                    ValidationUtils.MustBeA(dUserDefinedConfidenceThreshold, 'double');
                    mustBeNonnegative(dUserDefinedConfidenceThreshold);
                    mustBeLessThanOrEqual(dUserDefinedConfidenceThreshold,1);
                    
                    c1xVarargin = {bCalculateOptimalThreshold, dUserDefinedConfidenceThreshold};
                end
                
                switch sErrorMetric
                    case "MCR"
                        fnConstructor = @ErrorMetricMCR;
                    case "TPR"
                        fnConstructor = @ErrorMetricTPR;
                    case "TNR"
                        fnConstructor = @ErrorMetricTNR;
                    case "FPR"
                        fnConstructor = @ErrorMetricFPR;
                    case "FNR"
                        fnConstructor = @ErrorMetricFNR;
                end
                
                obj = fnConstructor(c1xVarargin{:});
            else
                error(...
                    'ErrorMetric:CreateFromParameterFile:InvalidErrorMetricType',...
                    ['The Error Metric value of "', char(sErrorMetric), '" is not recognized.']);
            end
        end
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
        
        function MustBeValidErrorMetricValue(obj, dErrorMetricValue)
            %MustBeValidErrorMetricValue(obj, dErrorMetricValue)
            %
            % SYNTAX:
            % MustBeValidErrorMetricValue(obj, dErrorMetricValue)
            %
            % DESCRIPTION:
            %  Check to ensure the error metric values are valid.
            %
            % INPUT ARGUMENTS:
            %  obj: Error metrics object.
            %  dErrorMetricValue: Resulting error metrics value from the
            %   error metrics calculator.
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Copy of constructed object.
            
            % Primary Author: David DeVries
            % Created: August 31, 2020
            
            arguments
                obj (1,1) ErrorMetric
                dErrorMetricValue (1,1) double {mustBeNonNan}
            end
            
            if dErrorMetricValue < min(obj.dLeastOptimalValue, obj.dMostOptimalValue) || dErrorMetricValue > max(obj.dLeastOptimalValue, obj.dMostOptimalValue)
                error(...
                    'ErrorMetric:MustBeValidErrorMetricValue:Invalid',...
                    'Value must be in the range of the error metric.');
            end
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

