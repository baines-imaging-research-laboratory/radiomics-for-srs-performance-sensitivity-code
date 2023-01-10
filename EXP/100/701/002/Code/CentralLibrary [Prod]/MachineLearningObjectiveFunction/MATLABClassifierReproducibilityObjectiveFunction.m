classdef MATLABClassifierReproducibilityObjectiveFunction < MachineLearningObjectiveFunction
    %MATLABClassifierReproducibilityObjectiveFunction
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: September 14, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        chLossFunction (1,:) char = 'classiferror'
        chMode (1,:) char = 'average'
        
        dNumFolds (1,1) double {mustBeInteger, mustBePositive} = 5
        
        oStaticCvPartition
    end
    
    properties (SetAccess = private, GetAccess = public)
    end
    
    properties (Constant = true, GetAccess = private)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
            
    methods (Access = public, Static = false)
        
        function obj = MATLABClassifierReproducibilityObjectiveFunction(dNumFolds, bUseForMinimaOptimization, oDataSet)
            %obj = MATLABClassifierReproducibilityObjectiveFunction(dNumFolds, bUseForMinimaOptimization, oDataSet)
            %
            % SYNTAX:
            %  obj = MATLABClassifierReproducibilityObjectiveFunction(dNumFolds, bUseForMinimaOptimization, oDataSet)
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
                dNumFolds (1,1) double {mustBeInteger, mustBePositive}
                bUseForMinimaOptimization (1,1) logical
                oDataSet (:,:) LabelledFeatureValues
            end
                        
            % superclass call
            obj@MachineLearningObjectiveFunction(bUseForMinimaOptimization);
            
            % local call
            obj.dNumFolds = dNumFolds;
            
            obj.oStaticCvPartition = cvpartition(double(oDataSet.GetChangedLabels(int16(1),int16(0))), 'KFold', obj.dNumFolds);
        end 
        
        function dMostOptimalValue = GetMostOptimalValue(obj)
            dMostOptimalValue = 1;
        end
        
        function dLeastOptimalValue = GetLeastOptimalValue(obj)
            dLeastOptimalValue = 0;
        end
        
        function dObjectiveFunctionValue = Evaluate(obj, oClassifier, oDataSet)
            arguments
                obj (1,1) MATLABClassifierReproducibilityObjectiveFunction
                oClassifier (1,1) MATLABClassifier
                oDataSet (:,:) LabelledFeatureValues
            end            
            
            c1xHyperParameterNameValuePairs = oClassifier.GetHyperParametersNameValuePairs();
            
            fnMATLABModelFn = oClassifier.GetClassifierHandle();
            
            oModel = fnMATLABModelFn(...
                    oDataSet.GetFeatures(),...
                    double(oDataSet.GetChangedLabels(int16(1),int16(0))),...
                    c1xHyperParameterNameValuePairs{:},...
                    'CVPartition', obj.oStaticCvPartition);
            
            dObjectiveFunctionValue = kfoldLoss(oModel, 'mode', obj.chMode, 'lossfun', obj.chLossFunction);
            
            if obj.bUseForMinimaOptimization
                % do nothing
            else
                dObjectiveFunctionValue = 1-dObjectiveFunctionValue;
            end
        end
        
        function sString = GetDescriptionString(obj)
            if obj.bUseForMinimaOptimization
                sString = string(obj.chLossFunction);
            else
                sString = "1 - " + string(obj.chLossFunction);
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

