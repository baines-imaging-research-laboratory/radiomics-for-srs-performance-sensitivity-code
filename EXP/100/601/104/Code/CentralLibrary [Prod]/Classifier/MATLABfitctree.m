classdef MATLABfitctree < MATLABClassifier & ClassifierWithHyperParameterConstraintFunctions
    %MATLABfitctree
    %
    % MATLAB Decision Tree is an concrete class that uses MATLAB's built-in classifier to
    % create a machine learning model. See documentation here:
    % https://www.mathworks.com/help/stats/fitctree.html
    
    % Primary Author: Salma Dammak
    % Created: Feb 31, 2019
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    properties (SetAccess = immutable, GetAccess = public)
        sName = "MATLAB Decision Tree";
        hClassifier = @fitctree;
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods  (Static = false)
        
        function obj = MATLABfitctree(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, NameValueArgs)
            %obj = MATLABfitctree(xClassifierHyperParametersFileNameOrHyperParametersTable, NameValueArgs)
            %
            % SYNTAX:
            %  obj = MATLABfitctree(chClassifierHyperParametersFileName)
            %  obj = MATLABfitctree(tHyperParameters)
            %  obj = MATLABfitctree(__, oHyperParameterOptimizer)
            %
            % DESCRIPTION:
            %  Constructor for MATLABfitctree
            %
            % INPUT ARGUMENTS:
            %  chClassifierHyperParametersFileName: This is a .mat file containing all the
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
    % *                       PROTECTED METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function obj = SanitizeUserInputs(obj)
            obj = SanitizeUserInputs@MATLABClassifier(obj);
            
            
            % MATLAb has a default called "auto" which doesn't map to a specific parameter option
            % from the hyperparameter options for this classifier. This would prevent the use from
            % knowing exactly what hyperparameters were used, and hence how to replicate the
            % experiment. The code below deals with this dicrepency.
            
            vdIdx = find(arrayfun(@(x)strcmp(x,"AlgorithmForCategorical"),obj.tHyperParameterStates{:,'sName'}));
            if ~isempty(vdIdx)
                % AlgorithmForCategorical parameter indices were identified
                if isempty(obj.tHyperParameterStates.c1xUserInputValue{vdIdx})
                    % if the user did not specify an algorithm, set to 'exact'
                    sMsg = "You did not specify an algorithm for categorical predictor split."...
                        + " This classifier will default to the 'Exact' algorithm instead."...
                        + "\nThis prevents Matlab from assigning the algorithm to 'auto'"...
                        + " which is not recognized when using the Guess function.";
                    chMsg = char(sMsg);
                    warning('MATLABfitctree:UnsupportedParameter',chMsg);
                    obj.tHyperParameterStates.c1xSanitizedUserInputValue{vdIdx} = 'Exact';
                end
            end
            
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ClassifierWithHyperParameterConstraintFunctions, ?MATLABBayesianHyperParameterOptimizer})
        
        function fn = GetConditionalVariableFcn(obj)
            fn = @MATLABfitctreeCVF;
            
            function XTable = MATLABfitctreeCVF(XTable)
                % adapted from:
                % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCTREE.m
                
                vsVariableNames = string(XTable.Properties.VariableNames);
                
                % Always set NumVariablesToSample = NumPredictors. This is
                % here to ensure that single trees will not optimize this
                % parameter, but the parameter will be available for
                % enclosing ensembles to optimize it.
                if any(vsVariableNames == "NumVariablesToSample")
                    error('Under construction');
                    
                    % developer's note: unsure what to do here because of
                    % the "this" call
                    % XTable.NumVariablesToSample(:) = this.NumPredictors;
                end
            end
        end
        
        function fn = GetXConstraintFcn(obj)
            % not found in:
            % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCTREE.m
            
            fn = function_handle.empty;
        end
    end
end