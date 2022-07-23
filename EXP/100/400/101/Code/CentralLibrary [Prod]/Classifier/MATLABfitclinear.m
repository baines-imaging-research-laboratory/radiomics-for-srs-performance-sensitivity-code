classdef MATLABfitclinear < MATLABClassifier & ClassifierWithHyperParameterConstraintFunctions
    %MATLABfitclinear
    %
    % MATLAB Linear Classifier is an concrete class that uses MATLAB's built-in classifier to
    % create a machine learning model. See documentation here:
    % https://www.mathworks.com/help/stats/fitclinear.html
    
    % Primary Author: Salma Dammak
    % Created: Feb 31, 2019
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        sName = "MATLAB Linear Classifier";
        hClassifier = @fitclinear;
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods  (Static = false)
        
        function obj = MATLABfitclinear(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, NameValueArgs)
            %obj = MATLABfitclinear(xClassifierHyperParametersFileNameOrHyperParametersTable, NameValueArgs)
            %
            % SYNTAX:
            %  obj = MATLABfitclinear(chClassifierHyperParametersFileName)
            %  obj = MATLABfitclinear(tHyperParameters)
            %  obj = MATLABfitclinear(__, oHyperParameterOptimizer)
            %
            % DESCRIPTION:
            %  Constructor for MATLABfitclinear
            %
            % INPUT ARGUMENTS:
            %  chClassifierHyperParametersFileName This is a .mat file containing all the
            %       hyperparameter information.
            %       A default settings mat file for this classifier is found under:
            %       BOLT > DefaultInputs > Classifier
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: Salma Dammak
            % Created: Feb 31, 2019
            
            arguments
                xClassifierHyperParametersFileNameOrHyperParametersTable
                % This can be any concrete class inheriting from HyperParameterOptimizer since it
                % won't be used anywhere but to pass an object that can be checked by the parent
                % class which checks for the abstract parent class
                oHyperParameterOptimizer = MATLABMachineLearningHyperParameterOptimizer.empty
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            % Call MATLABClassifier constructor
            c1xVarargin = namedargs2cell(NameValueArgs);
            obj@MATLABClassifier(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, c1xVarargin{:});
            
            % ClassifierWithHyperParameterConstraintFunctions super-class
            % call
            obj@ClassifierWithHyperParameterConstraintFunctions(xClassifierHyperParametersFileNameOrHyperParametersTable);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ClassifierWithHyperParameterConstraintFunctions, ?MATLABBayesianHyperParameterOptimizer})
        
        function fn = GetConditionalVariableFcn(obj)
            % not found in:
            % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCLINEAR.m
            
            fn = function_handle.empty;
        end
        
        function fn = GetXConstraintFcn(obj)
            % not found in:
            % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCLINEAR.m
            
            fn = function_handle.empty;
        end
    end
end