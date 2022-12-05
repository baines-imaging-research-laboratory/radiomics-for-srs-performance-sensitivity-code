classdef PRToolsKNNC < PRToolsClassifier
    %PRToolsKNNC
    %
    % PRToolsKNNC Classifier computes the K-nearest neighbor classifier for
    % the dataset.
    %
    % We have shifted away from PRTools so this class will act as a guide for future developers 
    % who want to use PRTools.
    
    % Primary Author: Ryan Alfano
    % Created: Nov 21, 2019
    
     
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    properties (SetAccess = immutable, GetAccess = public)
        sName = "PRTools K-Nearest Neighbour";
        hClassifier = [];
        lsValidHyperParameterNames = ["Adaboost","NumNeighbours"]
    end
        
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    methods
        function obj = PRToolsKNNC(chClassifierHyperParametersFileName,oHyperParameterOptimizer)      
            %obj = PRToolsKNNC(chClassifierHyperParametersFileName)
            %
            % SYNTAX:
            %  obj = PRToolsKNNC(chClassifierHyperParametersFileName)
            %
            % DESCRIPTION:
            %  Constructor for PRToolsKNNC, it assigns the mapping and even though it has a path for
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
            obj.hClassifier = @knnc; % This is a PRTools "mapping"
        end
        
        function obj = Train (obj, oLabelledFeatureValues)
            %oTrainedClassifier = Train(obj,oLabelledFeatureValues)
            %
            % SYNTAX:
            % oTrainedClassifier = Train(oClassifier,oLabelledFeatureValues)
            %
            % DESCRIPTION:
            %  Trains a PRTools classifier on a labelled feature values object
            %
            % INPUT ARGUMENTS:
            %  oClassifier: A classifier object
            %  oLabelledFeatureValues: This is a labelled feature values object (class in this 
            %           library) that contains information about the features and the feature values 
            %           themselves. This must only contain the training samples. 
            %
            % OUTPUTS ARGUMENTS:
            %  oTrainedClassifier: input classifier object modified to hold a TrainedClassifier
            %           property that represents the trained model. This is necessary for Guess to 
            %           work. 
            
            % Primary Author: Ryan Alfano
            % Created: Nov 26, 2019
            
            arguments
                obj
                oLabelledFeatureValues (:,:) LabelledFeatureValues
            end
            
            if numel(unique(oLabelledFeatureValues.GetLabels())) ~= 2
                error("PRToolsClassifier:Train:NotTwoLabels","This function is built for binary classification only. "+...
                "The Labelled Feature Values you provide must have eaxctly two unique labels.")            
            end
            
            % Change labels to integer 0s and 1s 
            viChangedLabels = GetChangedLabels(oLabelledFeatureValues, int16(1),int16(0));
            
            % Prep PR tools data set 
            oPRTrainingSet = prdataset(GetFeatures(oLabelledFeatureValues),viChangedLabels);
            
            % Get hyperparameters
            c1xClassifierParameters = obj.GetImplementationSpecificParameters();
            
            iAdaboostParameterIdx = find(cellfun(@(x)strcmp(x,"Adaboost"),obj.tHyperParameterStates{:,'sName'}));
            
            % Check if Adaboost was a possible parameter, and if the user set it to true
            if ~isempty(iAdaboostParameterIdx) && obj.tHyperParameterStates{iAdaboostParameterIdx,'c1xUserInputValue'}{:} == true
                
                % If the classifer is to be combined with Adaboost, call it this way
                [obj.oTrainedClassifier,dNumNeighboursUsed] = adaboostc(oPRTrainingSet,obj.hClassifier(c1xClassifierParameters{:}));
            else
                [obj.oTrainedClassifier,dNumNeighboursUsed] = obj.hClassifier(oPRTrainingSet,c1xClassifierParameters{:});
            end
            
            % Assign the output to the table
            iNumNeighboursIdx = find(cellfun(@(x)strcmp(x,"NumNeighbours"),obj.tHyperParameterStates{:,'sName'}));
            obj.tHyperParameterStates.c1xTrainingResult{iNumNeighboursIdx} = dNumNeighboursUsed;

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
            iNumNeighboursIdx = find(cellfun(@(x)strcmp(x,"NumNeighbours"),obj.tHyperParameterStates{:,'sName'}));
                       
            dNumNeighbours = obj.tHyperParameterStates{iNumNeighboursIdx,'c1xUserInputValue'}{:};
            
            % If number of neighbours is 0 then optimize to the number of
            % neighbours based on the leave-one-out error.
            if dNumNeighbours == 0
                c1xHyperParams = {};
            else 
                c1xHyperParams = {dNumNeighbours};
            end
        end
    end
end