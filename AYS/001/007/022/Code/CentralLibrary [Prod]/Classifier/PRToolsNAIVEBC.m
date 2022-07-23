classdef PRToolsNAIVEBC < PRToolsClassifier
    %PRToolsNAIVEBC
    %
    % PRToolsNAIVEBC Classifier estimates for every class and every feature separately.
    %
    % We have shifted away from PRTools so this class will act as a guide for future developers 
    % who want to use PRTools.
    
    % Primary Author: Ryan Alfano
    % Created: January 28, 2020
    
     
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    properties (SetAccess = immutable, GetAccess = public)
        sName = "PRTools Naive Bayes Classifier";
        hClassifier = [];
        lsValidHyperParameterNames = ["Adaboost","NumBins"]
    end
        
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    methods
        function obj = PRToolsNAIVEBC(chClassifierHyperParametersFileName,oHyperParameterOptimizer)      
            %obj = PRToolsNAIVEBC(chClassifierHyperParametersFileName)
            %
            % SYNTAX:
            %  obj = PRToolsNAIVEBC(chClassifierHyperParametersFileName)
            %
            % DESCRIPTION:
            %  Constructor for PRToolsNAIVEBC, it assigns the mapping and even though it has a path for
            %   optimization now, this is currently not implemented for PRTools.
            %
            % INPUT ARGUMENTS:
            %  chClassifierHyperParametersFileName This is a .mat file containing all the 
            %       hyperparameter information.
            %       A default settings mat file for this classifier is found under: 
            %       BOLT > DefaultInputs > Classifier
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: Ryan Alfano
            % Created: Nov 21, 2019           
            arguments
                chClassifierHyperParametersFileName
                % This can be any concrete class inheriting from HyperParameterOptimizer since it
                % won't be used anywhere but to pass an object that can be checked by the parent
                % class which checks for the abstract parent class. Since we don't have a PRTools
                % optimizer right now we can just use the MATLAB one for validation purposes.
                oHyperParameterOptimizer = MATLABMachineLearningHyperParameterOptimizer.empty
            end
            
            % Call PRToolsClassifier constructor
            obj@PRToolsClassifier(chClassifierHyperParametersFileName, oHyperParameterOptimizer)
            
            % Assign the prtools mapping
            obj.hClassifier = @naivebc; % This is a PRTools "mapping"
        end
    end
    
    % *********************************************************************
    % *                         PROTECTED METHODS                         *
    % *********************************************************************
  
    methods (Access = protected)
        function c1xHyperParams = GetImplementationSpecificParameters(obj) 
            %c1xHyperParams = GetImplementationSpecificParameters(obj)  
            %
            % SYNTAX:
            %  c1xHyperParams = GetImplementationSpecificParameters(obj) 
            %
            % DESCRIPTION:
            %  Grabs hyperparameters for classifier training that are specific
            %  to the PRTools classifier
            %
            % INPUT ARGUMENTS:
            %  obj: Classifier object        
            %
            % OUTPUTS ARGUMENTS:
            %  c1xHyperParams: hyper parameters that are in order of how they
            %  should appear as input to the function (PRTools classifiers are
            %  hardcoded this way)
            
            % Check for unused parameters - warning
            obj.CheckForUnusedParameters();
            
            % set up cell array to hold hyperparameters
            iNumBinsTypeIdx = find(cellfun(@(x)strcmp(x,"NumBins"),obj.tHyperParameterStates{:,'sName'}));
            
            dNumBins = obj.tHyperParameterStates{iNumBinsTypeIdx,'c1xUserInputValue'}{:};
            
            c1xHyperParams = {dNumBins};
        end
    end
end