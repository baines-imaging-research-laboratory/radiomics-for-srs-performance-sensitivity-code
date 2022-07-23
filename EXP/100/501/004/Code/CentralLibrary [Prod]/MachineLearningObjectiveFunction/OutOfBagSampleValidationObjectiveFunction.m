classdef OutOfBagSampleValidationObjectiveFunction < MachineLearningObjectiveFunction
    %OutOfBagSampleValidationObjectiveFunction
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Feb. 2, 2021
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        oErrorMetric ErrorMetric {ValidationUtils.MustBeEmptyOrScalar} = ErrorMetricAUC.empty
    end
    
    properties (Constant = true, GetAccess = private)
        chParametersFileVarName = 'tObjectiveFunctionParameters'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
            
    methods (Access = public, Static = false)
        
        function obj = OutOfBagSampleValidationObjectiveFunction(xErrorMetricOrFilePath, varargin)
            %obj = OutOfBagSampleValidationObjectiveFunction(xErrorMetricOrFilePath, varargin)
            %
            % SYNTAX:
            %  obj = OutOfBagSampleValidationObjectiveFunction(oErrorMetric, ...)
            %  obj = OutOfBagSampleValidationObjectiveFunction(chErrorMetricParametersFilePath, ...)
            %  obj = OutOfBagSampleValidationObjectiveFunction(__, chObjectiveFunctionParametersFilePath)
            %  obj = OutOfBagSampleValidationObjectiveFunction(__, bUseForMinimaOptimization)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                xErrorMetricOrFilePath
            end
            arguments (Repeating)
                varargin
            end
            
            if isa(xErrorMetricOrFilePath, 'ErrorMetric')
                oErrorMetric = OutOfBagSampleValidationObjectiveFunction.MustBeValidErroMetricInputParameters_Case1(xErrorMetricOrFilePath);
            else
                chErrorMetricParametersFilePath = OutOfBagSampleValidationObjectiveFunction.MustBeValidErroMetricInputParameters_Case2(xErrorMetricOrFilePath);
                
                oErrorMetric = ErrorMetric.CreateFromParameterFile(chErrorMetricParametersFilePath);
            end
                        
            if ~isnumeric(varargin{1}) && ~islogical(varargin{1})
                chObjectiveFunctionParametersFilePath = OutOfBagSampleValidationObjectiveFunction.MustBeValidVararginInputParameters_Case1(varargin{:});
                
                bUseForMinimaOptimization = OutOfBagSampleValidationObjectiveFunction.LoadParametersFromFile(chObjectiveFunctionParametersFilePath);
            else
                bUseForMinimaOptimization = OutOfBagSampleValidationObjectiveFunction.MustBeValidVararginInputParameters_Case2(varargin{:});
            end
            
            % superclass call
            obj@MachineLearningObjectiveFunction(bUseForMinimaOptimization);
            
            % local call
            obj.oErrorMetric = oErrorMetric;
        end 
        
        function dMostOptimalValue = GetMostOptimalValue(obj)
            dMostOptimalValue = obj.oErrorMetric.GetMostOptimalValue();
        end
        
        function dLeastOptimalValue = GetLeastOptimalValue(obj)
            dLeastOptimalValue = obj.oErrorMetric.GetLeastOptimialValue();
        end
        
        function dObjectiveFunctionValue = Evaluate(obj, oClassifier, oDataSet)
            arguments
                obj (1,1) OutOfBagSampleValidationObjectiveFunction
                oClassifier (1,1) Classifier
                oDataSet (:,:) LabelledFeatureValues
            end             
            
            oTrainedClassifier = oClassifier.Train(oDataSet, 'JournalingOn', false);
            oGuessResult = oTrainedClassifier.GuessOnOutOfBagSamples();
            
            dErrorMetricValue = obj.oErrorMetric.Calculate(oGuessResult, 'JournalingOn', false, 'SuppressWarnings', true);
                        
            if obj.bUseForMinimaOptimization
                dObjectiveFunctionValue = obj.oErrorMetric.RescaleValueForMinimaOptimization(dErrorMetricValue);
            else
                dObjectiveFunctionValue = obj.oErrorMetric.RescaleValueForMaximaOptimization(dErrorMetricValue);
            end
        end
        
        function sString = GetDescriptionString(obj)
            if obj.bUseForMinimaOptimization
                sString = obj.oErrorMetric.GetDescriptionStringForMinimaOptimization();
            else
                sString = obj.oErrorMetric.GetDescriptionStringForMinimaOptimization();
            end
            
            sString = "OOB validation of " + sString;
        end
    end
    
    
    methods (Access = public, Static = true) 
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
       
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
        
        function oErrorMetric = MustBeValidErroMetricInputParameters_Case1(xErrorMetricOrFilePath)
            arguments
                xErrorMetricOrFilePath (1,1) ErrorMetric
            end
            
            oErrorMetric = xErrorMetricOrFilePath;
        end
            
        function chErrorMetricParametersFilePath = MustBeValidErroMetricInputParameters_Case2(xErrorMetricOrFilePath)
            arguments
                xErrorMetricOrFilePath (1,:) char
            end
            
            chErrorMetricParametersFilePath = xErrorMetricOrFilePath;
        end
                        
        function chObjectiveFunctionParametersFilePath = MustBeValidVararginInputParameters_Case1(chObjectiveFunctionParametersFilePath)
            arguments
                chObjectiveFunctionParametersFilePath (1,:) char
            end
        end
        
        function bUseForMinimaOptimization = MustBeValidVararginInputParameters_Case2(bUseForMinimaOptimization)
            arguments
                bUseForMinimaOptimization (1,1) logical
            end
        end
            
        function bUseForMinimaOptimization = LoadParametersFromFile(chObjectiveFunctionParametersFilePath)
            tParameters = FileIOUtils.LoadMatFile(chObjectiveFunctionParametersFilePath, OutOfBagSampleValidationObjectiveFunction.chParametersFileVarName);
            
            vsVarNames = tParameters.sName;
            
            bUseForMinimaOptimization = [];
                        
            for dVarIndex=1:length(vsVarNames)
                xValue = tParameters.c1xValue{dVarIndex};
                
                switch vsVarNames(dVarIndex)
                    case "UseForMinimaOptimization"
                        bUseForMinimaOptimization = xValue;
                    otherwise
                        error(...
                            'OutOfBagSampleValidationObjectiveFunction:LoadParametersFromFile:InvalidVarName',...
                            ['The sName column value of ', char(vsVarNames(dVarIndex)), ' is invalid.']);
                end
            end
            
            bUseForMinimaOptimization = OutOfBagSampleValidationObjectiveFunction.MustBeValidVararginInputParameters_Case2(bUseForMinimaOptimization);
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

