classdef MATLABfitckernel < MATLABClassifier & ClassifierWithHyperParameterConstraintFunctions
    %MATLABfitckernel
    %
    % MATLAB Gaussian kernel Classifier is an concrete class that uses MATLAB's built-in
    % classifier to create machine learning model. See documentation here:
    % https://www.mathworks.com/help/stats/fitckernel.html
    
    % Primary Author: Salma Dammak
    % Created: Feb 31, 2019
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        sName = "MATLAB Gaussian kernel Classifier";
        hClassifier = @fitckernel;
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = false)
        
        function obj = MATLABfitckernel(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, NameValueArgs)
            %obj = MATLABfitckernel(xClassifierHyperParametersFileNameOrHyperParametersTable, NameValueArgs)
            %
            % SYNTAX:
            %  obj = MATLABfitckernel(chClassifierHyperParametersFileName)
            %  obj = MATLABfitckernel(tHyperParameters)
            %  obj = MATLABfitckernel(__, oHyperParameterOptimizer)
            %
            % DESCRIPTION:
            %  Constructor for MATLABfitckernel
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
            % Modified: Oct 3, 2019 - CJ ;
            %           - Set the RandomStream parameter to one generated
            %           by the RandomNumberGenerator class.
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
            
            % Modify the fitckernel's object hyperparameter 'RandomStream'
            % to use a RandStream object defined by our
            % RandomNumberGenerator class
            oRandomNumberGenerator = RandomNumberGenerator();
            oRandStream = oRandomNumberGenerator.GetRandomNumberStream();
            
            % assign random stream to the RandomStream row in the hyperparameter table
            dRow = find(strcmp('RandomStream',obj.tHyperParameterStates.sName));
            obj.tHyperParameterStates.c1xSanitizedUserInputValue(dRow) = {oRandStream};
            
            warning("MATLABfitckernel:SanitizeInputs:RandomStreamInputModified",...
                "The random stream value is being handled by the random "...
                + "number generator class in this library. Your input for this "...
                + "hyperparameter will be discarded.")
            
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ClassifierWithHyperParameterConstraintFunctions, ?MATLABBayesianHyperParameterOptimizer})
        
        function fn = GetConditionalVariableFcn(obj)
            % not found in:
            % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCKERNEL.m
            
            fn = function_handle.empty;
        end
        
        function fn = GetXConstraintFcn(obj)
            % not found in:
            % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCKERNEL.m
            
            fn = function_handle.empty;
        end
    end
end