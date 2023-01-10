classdef MATLABfitcdiscr < MATLABClassifier & ClassifierWithHyperParameterConstraintFunctions
    %MATLABfitcdiscr
    %
    % MATLAB Fit Discriminant Analysis Classifier is an concrete class that uses MATLAB's built-in
    % classifier to create machine learning model. See documentation here:
    % https://www.mathworks.com/help/stats/fitcdiscr.html
    
    % Primary Author: Salma Dammak
    % Created: Feb 31, 2019
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        sName = "MATLAB Fit Discriminant Analysis Classifier";
        hClassifier = @fitcdiscr;
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Static = false)
        
        function obj = MATLABfitcdiscr(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, NameValueArgs)
            %obj = MATLABfitcdiscr(xClassifierHyperParametersFileNameOrHyperParametersTable, NameValueArgs)
            %
            % SYNTAX:
            %  obj = MATLABfitcdiscr(chClassifierHyperParametersFileName)
            %  obj = MATLABfitcdiscr(tHyperParameters)
            %  obj = MATLABfitcdiscr(__, oHyperParameterOptimizer)
            %
            % DESCRIPTION:
            %  Constructor for MATLABfitcdiscr
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
            
            % Call MATLABClassifier constructor
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
            fn = @MATLABfitcdiscrCVF;
            
            function XTable = MATLABfitcdiscrCVF(XTable)
                % adapted from:
                % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCDISCR.m
                
                vsVariableNames = string(XTable.Properties.VariableNames);
                   
                % Do not pass Delta if discrim type is a quadratic
                if any(vsVariableNames == "Delta") && any(vsVariableNames == "DiscrimType")
                    XTable.Delta(ismember(XTable.DiscrimType, {'quadratic', ...
                        'diagQuadratic', 'pseudoQuadratic'})) = NaN;
                end
                
                % Gamma must be 0 if discrim type is a quadratic
                if any(vsVariableNames == "Gamma") && any(vsVariableNames == "DiscrimType")
                    XTable.Gamma(ismember(XTable.DiscrimType, {'quadratic', ...
                        'diagQuadratic', 'pseudoQuadratic'})) = 0;
                end
            end
        end
        
        function fn = GetXConstraintFcn(obj)
            % not found in:
            % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCDISCR.m
            
            fn = function_handle.empty;
        end
    end
end