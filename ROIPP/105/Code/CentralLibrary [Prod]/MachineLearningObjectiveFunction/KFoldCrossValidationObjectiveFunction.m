classdef KFoldCrossValidationObjectiveFunction < MachineLearningObjectiveFunction
    %KFoldCrossValidationObjectiveFunction
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: September 2, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        oErrorMetric ErrorMetric {ValidationUtils.MustBeEmptyOrScalar} = ErrorMetricAUC.empty
        
        dNumFolds (1,1) double {mustBeInteger, mustBePositive} = 5
        dNumReps (1,1) double {mustBeInteger, mustBePositive} = 3
        
        bBalanceTrainingSet (1,1) logical = true
        bAllowDuplicatedSamplesInTestingSet (1,1) logical = true
        
        bAccumulatedErrorMetrics (1,1) logical = true
    end
    
    properties (SetAccess = private, GetAccess = public)        
        bUseParallel (1,1) logical = false        
    end
    
    properties (Constant = true, GetAccess = private)
        chParametersFileVarName = 'tObjectiveFunctionParameters'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
            
    methods (Access = public, Static = false)
        
        function obj = KFoldCrossValidationObjectiveFunction(xErrorMetricOrFilePath, varargin)
            %obj = KFoldCrossValidationObjectiveFunction(xErrorMetricOrFilePath, varargin)
            %
            % SYNTAX:
            %  obj = KFoldCrossValidationObjectiveFunction(oErrorMetric, ...)
            %  obj = KFoldCrossValidationObjectiveFunction(chErrorMetricParametersFilePath, ...)
            %  obj = KFoldCrossValidationObjectiveFunction(__, chObjectiveFunctionParametersFilePath)
            %  obj = KFoldCrossValidationObjectiveFunction(__, bUseForMinimaOptimization, dNumFolds, dNumReps, bBalanceTrainingSet, bAllowDuplicatedSamplesInTestingSet, bAccumulatedErrorMetrics, bUseParallel)
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
                oErrorMetric = KFoldCrossValidationObjectiveFunction.MustBeValidErroMetricInputParameters_Case1(xErrorMetricOrFilePath);
            else
                chErrorMetricParametersFilePath = KFoldCrossValidationObjectiveFunction.MustBeValidErroMetricInputParameters_Case2(xErrorMetricOrFilePath);
                
                oErrorMetric = ErrorMetric.CreateFromParameterFile(chErrorMetricParametersFilePath);
            end
                        
            if length(varargin) == 1
                chObjectiveFunctionParametersFilePath = KFoldCrossValidationObjectiveFunction.MustBeValidVararginInputParameters_Case1(varargin{:});
                
                [bUseForMinimaOptimization, dNumFolds, dNumReps, bBalanceTrainingSet, bAllowDuplicatedSamplesInTestingSet, bAccumulatedErrorMetrics, bUseParallel] = KFoldCrossValidationObjectiveFunction.LoadParametersFromFile(chObjectiveFunctionParametersFilePath);
            else
                [bUseForMinimaOptimization, dNumFolds, dNumReps, bBalanceTrainingSet, bAllowDuplicatedSamplesInTestingSet, bAccumulatedErrorMetrics, bUseParallel] = KFoldCrossValidationObjectiveFunction.MustBeValidVararginInputParameters_Case2(varargin{:});
            end
            
            % superclass call
            obj@MachineLearningObjectiveFunction(bUseForMinimaOptimization);
            
            % local call
            obj.oErrorMetric = oErrorMetric;
            
            obj.dNumFolds = dNumFolds;
            obj.dNumReps = dNumReps;
            
            obj.bBalanceTrainingSet = bBalanceTrainingSet;
            obj.bAllowDuplicatedSamplesInTestingSet = bAllowDuplicatedSamplesInTestingSet;
            
            obj.bAccumulatedErrorMetrics = bAccumulatedErrorMetrics;
            
            obj.bUseParallel = bUseParallel;
        end 
        
        function obj = SetUseParallel(obj, bUseParallel)
            arguments
                obj (1,1) KFoldCrossValidationObjectiveFunction
                bUseParallel (1,1) logical
            end
            
            obj.bUseParallel = bUseParallel;
        end
        
        function dMostOptimalValue = GetMostOptimalValue(obj)
            dMostOptimalValue = obj.oErrorMetric.GetMostOptimalValue();
        end
        
        function dLeastOptimalValue = GetLeastOptimalValue(obj)
            dLeastOptimalValue = obj.oErrorMetric.GetLeastOptimialValue();
        end
        
        function dObjectiveFunctionValue = Evaluate(obj, oClassifier, oDataSet)
            arguments
                obj (1,1) KFoldCrossValidationObjectiveFunction
                oClassifier (1,1) Classifier
                oDataSet (:,:) LabelledFeatureValues
            end            
            
            if ~obj.bAllowDuplicatedSamplesInTestingSet
                dErrorMetricValue = KFoldCrossValidationUtils.PerformClassifierCrossValidationForErrorMetrics(...
                    oClassifier, oDataSet, obj.oErrorMetric,...
                    obj.dNumFolds, obj.dNumReps,...
                    obj.bBalanceTrainingSet, obj.bAccumulatedErrorMetrics,...
                    'SuppressWarnings', true,...
                    'UseParallel', obj.bUseParallel);
            else
                dErrorMetricValue = KFoldCrossValidationUtils.PerformClassifierCrossValidationForErrorMetrics_AllowDuplicates(...
                    oClassifier, oDataSet, obj.oErrorMetric,...
                    obj.dNumFolds, obj.dNumReps,...
                    obj.bBalanceTrainingSet, obj.bAccumulatedErrorMetrics,...
                    'SuppressWarnings', true,...
                    'UseParallel', obj.bUseParallel);
            end
            
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
            
            sString = "K-Fold CV of " + sString;
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
        
        function [bUseForMinimaOptimization, dNumFolds, dNumReps, bBalanceTrainingSet, bAllowDuplicatedSamplesInTestingSet, bAccumulatedErrorMetrics, bUseParallel] = MustBeValidVararginInputParameters_Case2(bUseForMinimaOptimization, dNumFolds, dNumReps, bBalanceTrainingSet, bAllowDuplicatedSamplesInTestingSet, bAccumulatedErrorMetrics, bUseParallel)
            arguments
                bUseForMinimaOptimization (1,1) logical
                dNumFolds (1,1) double {mustBeInteger, mustBePositive}
                dNumReps (1,1) double {mustBeInteger, mustBePositive}
                bBalanceTrainingSet (1,1) logical = true
                bAllowDuplicatedSamplesInTestingSet (1,1) logical = true
                bAccumulatedErrorMetrics (1,1) logical = true
                bUseParallel (1,1) logical = false
            end
        end
            
        function [bUseForMinimaOptimization, dNumFolds, dNumReps, bBalanceTrainingSet, bAllowDuplicatedSamplesInTestingSet, bAccumulatedErrorMetrics, bUseParallel] = LoadParametersFromFile(chObjectiveFunctionParametersFilePath)
            tParameters = FileIOUtils.LoadMatFile(chObjectiveFunctionParametersFilePath, KFoldCrossValidationObjectiveFunction.chParametersFileVarName);
            
            vsVarNames = tParameters.sName;
            
            bUseForMinimaOptimization = [];
            dNumFolds = [];
            dNumReps = [];
            bBalanceTrainingSet = [];
            bAllowDuplicatedSamplesInTestingSet = [];
            bAccumulatedErrorMetrics = [];
            bUseParallel= [];
            
            for dVarIndex=1:length(vsVarNames)
                xValue = tParameters.c1xValue{dVarIndex};
                
                switch vsVarNames(dVarIndex)
                    case "UseForMinimaOptimization"
                        bUseForMinimaOptimization = xValue;
                    case "NumFolds"
                        dNumFolds = xValue;
                    case "NumReps"
                        dNumReps = xValue;
                    case "BalanceTrainingSet"
                        bBalanceTrainingSet = xValue;
                    case "AllowDuplicatedSamplesInTestingSet"
                        bAllowDuplicatedSamplesInTestingSet = xValue;
                    case "AccumulatedErrorMetrics"
                        bAccumulatedErrorMetrics = xValue;
                    case "UseParallel"
                        bUseParallel = xValue;
                    otherwise
                        error(...
                            'KFoldCrossValidationObjectiveFunction:LoadParametersFromFile:InvalidVarName',...
                            ['The sName column value of ', char(vsVarNames(dVarIndex)), ' is invalid.']);
                end
            end
            
            [bUseForMinimaOptimization, dNumFolds, dNumReps, bBalanceTrainingSet, bAllowDuplicatedSamplesInTestingSet, bAccumulatedErrorMetrics, bUseParallel] = ...
                KFoldCrossValidationObjectiveFunction.MustBeValidVararginInputParameters_Case2(...
                bUseForMinimaOptimization, dNumFolds, dNumReps, bBalanceTrainingSet, bAllowDuplicatedSamplesInTestingSet, bAccumulatedErrorMetrics, bUseParallel);
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

