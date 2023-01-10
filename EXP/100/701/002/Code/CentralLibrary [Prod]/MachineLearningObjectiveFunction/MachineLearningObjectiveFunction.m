classdef (Abstract) MachineLearningObjectiveFunction
    %MachineLearningObjectiveFunction
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: September 2, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        bUseForMinimaOptimization (1,1) logical = true
    end
                
    properties (Access = protected, Constant = true, Abstract = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract = true)
        
        dMostOptimalValue = GetMostOptimalValue(obj)
        
        dLeaststOptimalValue = GetLeastOptimalValue(obj)
        
        dObjectiveFunctionValue = Evaluate(obj, oClassifier, oDataSet)
        
        sString = GetDescriptionString(obj)
    end
    
    methods (Access = public, Static = false)
        
        function obj = MachineLearningObjectiveFunction(bUseForMinimaOptimization)
            %obj = MachineLearningObjectiveFunction(bUseForMinimaOptimization)
            %
            % SYNTAX:
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            obj.bUseForMinimaOptimization = bUseForMinimaOptimization;
        end 
        
        function MustBeValidForMinimaOptimization(obj)
            if ~obj.bUseForMinimaOptimization
                error(...
                    'MachineLearningObjectiveFunction:MustBeValidForMinimaOptimization:Invalid',...
                    'The objective function is set for maxima optimization.');
            end
        end
        
        function MustBeValidForMaximaOptimization(obj)
            if obj.bUseForMinimaOptimization
                error(...
                    'MachineLearningObjectiveFunction:MustBeValidForMaximaOptimization:Invalid',...
                    'The objective function is set for minima optimization.');
            end
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

