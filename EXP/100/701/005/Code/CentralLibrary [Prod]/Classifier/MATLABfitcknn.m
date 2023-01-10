classdef MATLABfitcknn < MATLABClassifier & ClassifierWithHyperParameterConstraintFunctions
    %MATLABfitcknn
    %
    % MATLAB k-Nearest Neighbour is an concrete class that uses MATLAB's built-in classifier to
    % create a machine learning model. See documentation here:
    % https://www.mathworks.com/help/stats/fitcknn.html

    % Primary Author: Salma Dammak
    % Created: Feb 31, 2019
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    properties (SetAccess = immutable, GetAccess = public)
        sName = "MATLAB k-Nearest Neighbour";
        hClassifier = @fitcknn;
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = false)
        
        function obj = MATLABfitcknn(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, NameValueArgs)
            %obj = MATLABfitcknn(xClassifierHyperParametersFileNameOrHyperParametersTable, NameValueArgs)
            %
            % SYNTAX:
            %  obj = MATLABfitcknn(chClassifierHyperParametersFileName)
            %  obj = MATLABfitcknn(tHyperParameters)
            %  obj = MATLABfitcknn(__, oHyperParameterOptimizer)
            %
            % DESCRIPTION:
            %  Constructor for MATLABfitcknn
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
            fn = @MATLABfitcknnCVF;
            
            function XTable = MATLABfitcknnCVF(XTable)
                % adapted from:
                % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCKNN.m
                                
                vsVariableNames = string(XTable.Properties.VariableNames);
                
                % Exponent is irrelevant unless Distance is minkowski
                if any(vsVariableNames == "Exponent") && any(vsVariableNames == "Distance")
                    XTable.Exponent(XTable.Distance ~= 'minkowski') = NaN;
                end
            end
        end
        
        function fn = GetXConstraintFcn(obj)
            % adapted from:
            % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCKNN.m
            fn = @MATLABfitcknnXCF;
            
            function TF = MATLABfitcknnXCF(XTable)
                % When Standardize=true, prohibit seuclidean and mahalanobis, because the
                % result is the same when Standardize=false.
                vsVariableNames = string(XTable.Properties.VariableNames);
                
                if any(vsVariableNames == "Standardize") && any(vsVariableNames == "Distance")
                    TF = ~(XTable.Standardize=='true' & ismember(XTable.Distance, {'seuclidean', 'mahalanobis'}));
                else
                    TF = true(height(XTable),1);
                end
            end
        end
    end
    
    
end