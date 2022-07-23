classdef MATLABfitcsvm < MATLABClassifier & ClassifierWithHyperParameterConstraintFunctions
    %MATLABfitcsvm
    %
    % MATLAB Fitc SVM is an concrete class that uses MATLAB's built-in SVM classifier to create a
    % machine learning model. See documentation here:
    % https://www.mathworks.com/help/stats/fitcsvm.html
    
    % Primary Author: Salma Dammak
    % Created: Feb 31, 2019
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        sName = "MATLAB Support Vector Machine Classifier";
        hClassifier = @fitcsvm;
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Static = false)
    
        function obj = MATLABfitcsvm(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, NameValueArgs)
            %obj = MATLABfitcsvm(xClassifierHyperParametersFileNameOrHyperParametersTable, NameValueArgs)
            %
            % SYNTAX:
            %  obj = MATLABfitcsvm(chClassifierHyperParametersFileName)
            %  obj = MATLABfitcsvm(tHyperParameters)
            %  obj = MATLABfitcsvm(__, oHyperParameterOptimizer)
            %
            % DESCRIPTION:
            %  Constructor for MATLABfitcsvm
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
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************    
    
    methods (Access = {?ClassifierWithHyperParameterConstraintFunctions, ?MATLABBayesianHyperParameterOptimizer})
        
        function fn = GetConditionalVariableFcn(obj)
            fn = @MATLABfitcsvmCVF;
            
            function XTable = MATLABfitcsvmCVF(XTable)
                % adapted from:
                % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCSVM.m
                
                vsVariableNames = string(XTable.Properties.VariableNames);
                
                % PolynomialOrder is irrelevant if KernelFunction~='polynomial'
                if any(vsVariableNames == "PolynomialOrder") && any(vsVariableNames == "KernelFunction")
                    XTable.PolynomialOrder(XTable.KernelFunction ~= 'polynomial') = NaN;
                end
                
                % KernelScale is irrelevant if KernelFunction~='rbf' or 'gaussian'
                if any(vsVariableNames == "KernelScale") && any(vsVariableNames == "KernelFunction")
                    XTable.KernelScale(~ismember(XTable.KernelFunction, {'rbf','gaussian'})) = NaN;
                end
                
                % Developer's note: This section below was in the code from
                % Matlab, not sure how to implement it in this framework
                % though since it uses the "this" call
                % BoxConstraint must be 1 if NumClasses==1 in a fold
                % % % %                 if this.NumClasses==1 && classreg.learning.paramoptim.BayesoptInfo.hasVariables(XTable, {'BoxConstraint'})
                % % % %                     XTable.BoxConstraint(:) = 1;
                % % % %                 end
            end
        end
        
        function fn = GetXConstraintFcn(obj)
            % not found in:
            % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCSVM.m
            
            fn = function_handle.empty;
        end
    end
end