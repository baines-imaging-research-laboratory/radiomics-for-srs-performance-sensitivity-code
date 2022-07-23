classdef MATLABTreeBagger < Classifier & ClassifierWithHyperParameterConstraintFunctions
    %MATLABTreeBagger
    %
    % TODO

    % Primary Author: David DeVries
    % Created: Jan 14, 2021
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    properties (SetAccess = immutable, GetAccess = public)
        sName = "MATLAB Tree Bagger"
    end
    
    properties (SetAccess = private, GetAccess = public)
        oTrainingData (:,:) %LabelledFeatureValues
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = false)
        
        function obj = MATLABTreeBagger(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, NameValueArgs)
            %obj = MATLABTreeBagger(xClassifierHyperParametersFileNameOrHyperParametersTable, NameValueArgs)
            %
            % SYNTAX:
            %  obj = MATLABTreeBagger(chClassifierHyperParametersFileName)
            %  obj = MATLABTreeBagger(tHyperParameters)
            %  obj = MATLABTreeBagger(__, oHyperParameterOptimizer)
            %
            % DESCRIPTION:
            %  Constructor for MATLABTreeBagger
            %
            % INPUT ARGUMENTS:
            %  chClassifierHyperParametersFileName This is a .mat file containing all the 
            %       hyperparameter information.
            %       A default settings mat file for this classifier is found under: 
            %       BOLT > DefaultInputs > Classifier
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments                
                xClassifierHyperParametersFileNameOrHyperParametersTable
                oHyperParameterOptimizer MATLABBayesianHyperParameterOptimizer {ValidationUtils.MustBeEmptyOrScalar} = MATLABBayesianHyperParameterOptimizer.empty
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            % Call MATLABClassifier constructor
            obj@Classifier(xClassifierHyperParametersFileNameOrHyperParametersTable);
            
            % ClassifierWithHyperParameterConstraintFunctions super-class
            % call
            obj@ClassifierWithHyperParameterConstraintFunctions(xClassifierHyperParametersFileNameOrHyperParametersTable);
            
            % local call
            obj.tHyperParameterStates.c1xValueForTrain = obj.tHyperParameterStates.c1xValue;
            
            if ~isempty(oHyperParameterOptimizer)
                obj = OptimizeHyperparameters(obj, oHyperParameterOptimizer, 'JournalingOn', NameValueArgs.JournalingOn);
            end
        end
        
        function obj = Train(obj, oLabelledFeatureValues, NameValueArgs)
            %oTrainedClassifier = Train(obj,oLabelledFeatureValues)
            %
            % SYNTAX:
            % oTrainedClassifier = Train(oClassifier,oLabelledFeatureValues)
            %
            % DESCRIPTION:
            %  Trains a MATLAB classifier on a labelled feature values object
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
                        
            arguments
                obj (1,1) MATLABTreeBagger
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                NameValueArgs.JournalingOn (1,1) logical = true
            end
                        
            % Change labels to integer 0s and 1s
            viChangedLabels = oLabelledFeatureValues.GetChangedLabels(uint8(1),uint8(0));
            
            % Create a name/value array from the hyperparameters table
            dNumTrees = [];
            
            dNumHyperParameters = length(obj.tHyperParameterStates.sName);
            vbPassHyperParameterIntoMatlab = false(dNumHyperParameters,1);
            
            for dHyperParameterIndex=1:dNumHyperParameters
                if obj.tHyperParameterStates.sName(dHyperParameterIndex) == "NumTrees" % the value of "NumTrees" must be passed in separately from the Name-Value arg list. It must also be specified, it can't be left blank
                    vbPassHyperParameterIntoMatlab(dHyperParameterIndex) = false;
                    
                    dNumTrees = obj.tHyperParameterStates.c1xValueForTrain{dHyperParameterIndex};
                elseif obj.tHyperParameterStates.sName(dHyperParameterIndex) == "CategoricalPredictors" % this is handled automagically by the classifier/feature values, so its ignored.
                    vbPassHyperParameterIntoMatlab(dHyperParameterIndex) = false;
                elseif obj.tHyperParameterStates.sName(dHyperParameterIndex) == "PredictorNames" % this is handled automagically by the classifier/feature values, so its ignored.
                    vbPassHyperParameterIntoMatlab(dHyperParameterIndex) = false;
                elseif obj.tHyperParameterStates.sName(dHyperParameterIndex) == "Method"
                    if obj.tHyperParameterStates.c1xValueForTrain{dHyperParameterIndex} ~= "classification"
                        error(...
                            'MATLABTreeBagger:Train:InvalidHyperParameterMethodValue',...
                            'The hyperparameter "Method" must be set to "classification".');
                    end
                else                
                    vbPassHyperParameterIntoMatlab(dHyperParameterIndex) = ~isa(obj.tHyperParameterStates.c1xValueForTrain{dHyperParameterIndex}, 'missing');
                end                
            end
            
            dNumHyperParametersToPassIntoMatlab = sum(vbPassHyperParameterIntoMatlab);
            
            if ~any(vbPassHyperParameterIntoMatlab)
                c1xVararginToPassIntoMatlab = {};
            else
                c1xVararginToPassIntoMatlab = cell(1, 2*dNumHyperParametersToPassIntoMatlab);
                
                vsHyperParameterNamesToPassIntoMatlab = obj.tHyperParameterStates.sName(vbPassHyperParameterIntoMatlab);
                c1xHyperParameterValuesToPassIntoMatlab = obj.tHyperParameterStates.c1xValueForTrain(vbPassHyperParameterIntoMatlab);
                
                for dHyperParameterIndex=1:dNumHyperParametersToPassIntoMatlab
                    c1xVararginToPassIntoMatlab{(2*(dHyperParameterIndex-1))+1} = vsHyperParameterNamesToPassIntoMatlab(dHyperParameterIndex);
                    c1xVararginToPassIntoMatlab{(2*(dHyperParameterIndex-1))+2} = c1xHyperParameterValuesToPassIntoMatlab{dHyperParameterIndex};
                end
            end
            
            % Add categorical predictors if needed
            vbFeatureIsCategorical = oLabelledFeatureValues.IsFeatureCategorical();
            
            if any(vbFeatureIsCategorical)
                c1xVararginToPassIntoMatlab = [c1xVararginToPassIntoMatlab, {'CategoricalPredictors', vbFeatureIsCategorical}];
            end
            
            % Add feature names to be passed in
            vsFeatureNames = oLabelledFeatureValues.GetFeatureNames();
            vsFeatureNames = vsFeatureNames + " (" + string(oLabelledFeatureValues.GetLinkIndexPerFeature) + ")";
            
            c1xVararginToPassIntoMatlab = [c1xVararginToPassIntoMatlab, {'PredictorNames', vsFeatureNames}];
                        
            % Validate "NumTrees" value
            dNumTrees = MATLABTreeBagger.CastAndValidateNumTrees(dNumTrees);
                        
            % Train the classifier by passing off to Matlab
            dtStartTime = datetime(now, 'ConvertFrom', 'datenum');
            obj.oTrainedClassifier = TreeBagger(dNumTrees, oLabelledFeatureValues.GetFeatures(), logical(viChangedLabels), c1xVararginToPassIntoMatlab{:});
            dtEndTime = datetime(now, 'ConvertFrom', 'datenum');
                
            % archive training data
            obj.oTrainingData = oLabelledFeatureValues;
            
            % Journal:
            if Experiment.IsRunning() && NameValueArgs.JournalingOn
                Experiment.StartNewSubSection(strcat("Training Classifier - ", obj.sName));
                
                [bAddEntriesIntoExperimentReport, bSaveObjects, bSaveSummaryFiles] = Experiment.GetJournalingSettings();
                
                if bAddEntriesIntoExperimentReport
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel("Elapsed Time: ", datestr(dtEndTime-dtStartTime, ReportUtils.GetDurationDatestrFormat())));
                    
                    dNumSamples = oLabelledFeatureValues.GetNumberOfSamples();
                    dNumFeatures = oLabelledFeatureValues.GetNumberOfFeatures();
                    
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel("Number of Samples: ", num2str(dNumSamples)));
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel("Number of Features: ", num2str(dNumFeatures)));
                    
                    Experiment.EndCurrentSubSection();
                end
            end
        end
        
        
        function oGuessResult = Guess(obj, oLabelledFeatureValues, NameValueArgs)
            %oGuessingResults = Guess(obj,oLabelledFeatureValues)
            %
            % SYNTAX:
            % oGuessingResults = Guess(oTrainedClassifier,oLabelledFeatureValues)
            %
            % DESCRIPTION:
            %  Based on a trained machine learning model, this function "guesses" the classification
            %  of test samples.
            %
            % INPUT ARGUMENTS:
            %  oClassifier: A *trained* classifier object. Done using Train
            %  oLabelledFeatureValues: This is a labelled feature values object (class in this
            %           library) that contains information about the features and the feature values
            %           themselves. This must only contain the testing (i.e. validation) samples.
            %
            % OUTPUTS ARGUMENTS:
            %  oGuessingResults: output with samples and associated predicted labels and confidences
            
            % Primary Author: Salma Dammak
            % Created: Feb 31, 2019
            % Modified: Dec 12, 2019 - C.Johnson - trap error of number of
            %       features mismatch
            
            arguments
                obj
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                NameValueArgs.JournalingOn (1,1) logical = true
            end
                        
            bOverrideDuplicatedSamplesValidation = false;
            oGuessResult = GuessWithOptionalDuplicatedSamplesValidationOverride(obj, oLabelledFeatureValues, NameValueArgs.JournalingOn, bOverrideDuplicatedSamplesValidation);
        end
        
        function oGuessResults = GuessOnOutOfBagSamples(obj)
            if ~obj.oTrainedClassifier.ComputeOOBPrediction
                error(...
                    'MATLABTreeBagger:GuessOnOutOfBagSamples:InvalidHyperParameters',...
                    'In order to call this function, the hyperparameter "OOBPrediction" must be set to ''on''.');
            end
            
            [~,m2dScores] = obj.oTrainedClassifier.oobPredict;
            vdPositiveLabelConfidences = m2dScores(:,2);
            
            bOverrideDuplicatedSamplesValidation = true;
            oGuessResults = ClassificationGuessResult(obj, obj.oTrainingData, vdPositiveLabelConfidences, bOverrideDuplicatedSamplesValidation);
        end
        
        function vdFeatureImportance = GetFeatureImportanceFromOutOfBagSamples(obj)
            if ~obj.oTrainedClassifier.ComputeOOBPredictorImportance                
                error(...
                    'MATLABTreeBagger:GetFeatureImportanceFromOutOfBagSamples:InvalidHyperParameters',...
                    'In order to call this function, the hyperparameter "OOBPredictorImportance" must be set to ''on'' and the hyperparameter "PredictorSelection" must be set to an appropriate value to allow for importance calculation.');
            end
            
            vdFeatureImportance = obj.oTrainedClassifier.OOBPermutedPredictorDeltaError;
        end
        
        function oHyperParameterOptimizer = GetHyperParameterOptimizer(obj)
            oHyperParameterOptimizer = obj.oHyperParameterOptimizer;
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************    
    
    methods (Access = protected)
        
        function obj = IntializeHyperParameterStatesTable(obj, tHyperParameters)
            obj.tHyperParameterStates = tHyperParameters;
        end
                
        function ValidateHyperParameterStatesForOptimization(obj)
            % do nothing
        end
        
        function obj = SetHyperParameterStatesOptimizableFlag(obj)
            % do nothing
        end
        
        function obj = ImplementationSpecificOptimizeHyperparameters(obj, NameValueArgs)            
            arguments
                obj
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            [obj.oHyperParameterOptimizer, oModel, oHyperparameterOptimizationResults] = obj.oHyperParameterOptimizer.OptimizeParameters(obj, 'JournalingOn', NameValueArgs.JournalingOn);
            
            for dHyperParameterIndex=1:length(obj.tHyperParameterStates.sName)
                if obj.tHyperParameterStates.bOptimize(dHyperParameterIndex)
                    bValueFound = false;
                    
                    % look for value in oModel as property
                    if isprop(oModel, obj.tHyperParameterStates.sName(dHyperParameterIndex)) || ismethod(oModel, obj.tHyperParameterStates.sName(dHyperParameterIndex))
                        obj.tHyperParameterStates.c1xValueForTrain{dHyperParameterIndex} = oModel.(obj.tHyperParameterStates.sName(dHyperParameterIndex));
                        bValueFound = true;
                    else
                        % look for it in the "TreeArguments" cell array
                        c1xTreeArgs = oModel.TreeArguments;
                        
                        for dTreeArgIndex=1:2:length(c1xTreeArgs)
                            if string(c1xTreeArgs{dTreeArgIndex}) == obj.tHyperParameterStates.sName(dHyperParameterIndex)
                                obj.tHyperParameterStates.c1xValueForTrain{dHyperParameterIndex} = c1xTreeArgs{dTreeArgIndex+1};
                                bValueFound = true;
                                break;
                            end
                        end
                    end
                    
                    if ~bValueFound
                        error(...
                            'MATLABTreeBagger:ImplementationSpecificOptimizeHyperparameters:OptimizationVariableNotFoundInModel',...
                            'The optimization variable was not found within the produced optimized model.');
                    end
                end
            end
        end
    end
    
    methods (Access = ?MATLABBayesianHyperParameterOptimizer)
        
        function voOptimizableVariables = GetOptimizableVariables(obj, oLabelledFeatureValues)
            % get what optimizable variables we can from fitctree. Some of
            % these are valid to optimize for the TreeBagger as well
            voOptimizableVariables = hyperparameters('fitctree', oLabelledFeatureValues.GetFeatures(), double(oLabelledFeatureValues.GetChangedLabels(uint8(1),uint8(0))));
            
            % check to see if any of these variables are:
            % 1) In the hyper-parameter table
            % 2) Set to be optimized
            % If both are true, check the domain, variable type, and
            % variable transform column for any updates
            dNumVarsFromFitctree = length(voOptimizableVariables);
            vbKeepVar = false(1, dNumVarsFromFitctree);
            
            vbHyperParameterProcessed = false(length(obj.tHyperParameterStates.sName),1);
            
            for dVarIndex=1:dNumVarsFromFitctree
                oVar = voOptimizableVariables(dVarIndex);
                sVarName = string(oVar.Name);
                
                for dHyperParameterIndex=1:length(obj.tHyperParameterStates.sName)
                    if sVarName == obj.tHyperParameterStates.sName(dHyperParameterIndex)
                        if obj.tHyperParameterStates.bOptimize(dHyperParameterIndex)
                            vbKeepVar(dVarIndex) = true;
                            vbHyperParameterProcessed(dHyperParameterIndex) = true;
                            
                            if ~isempty(obj.tHyperParameterStates.c1xOptimizationDomain{dHyperParameterIndex})
                                xRange = obj.tHyperParameterStates.c1xOptimizationDomain{dHyperParameterIndex};
                                
                                xRange = MATLABTreeBagger.EvaluateAnyFunctionsInHyperParameterRange(xRange, oLabelledFeatureValues);
                            else
                                xRange = oVar.Range;
                            end
                            
                            if "" ~= obj.tHyperParameterStates.sOptimizationVariableType(dHyperParameterIndex)
                                chType = char(obj.tHyperParameterStates.sOptimizationVariableType(dHyperParameterIndex));
                            else
                                chType = oVar.Type;
                            end
                            
                            if "" ~= obj.tHyperParameterStates.sOptimizationVariableTransform(dHyperParameterIndex)
                                chTransform = char(obj.tHyperParameterStates.sOptimizationVariableTransform(dHyperParameterIndex));
                            else
                                chTransform = oVar.Transform;
                            end
                            
                            voOptimizableVariables(dVarIndex) = optimizableVariable(sVarName, xRange, 'Type', chType, 'Transform', chTransform, 'Optimize', true);
                        end
                        
                        break;
                    end
                end
            end
            
            % only keep valid variables and those that were set to be
            % optimized
            voOptimizableVariables = voOptimizableVariables(vbKeepVar);
            
            % add more optimizable variables that are custom specified
            % (e.g. not in fitctree)
            
            for dHyperParameterIndex=1:length(obj.tHyperParameterStates.sName)
                if ~vbHyperParameterProcessed(dHyperParameterIndex) && obj.tHyperParameterStates.bOptimize(dHyperParameterIndex)
                    sVarName = obj.tHyperParameterStates.sName(dHyperParameterIndex);
                    
                    xRange = obj.tHyperParameterStates.c1xOptimizationDomain{dHyperParameterIndex};
                    xRange = MATLABTreeBagger.EvaluateAnyFunctionsInHyperParameterRange(xRange, oLabelledFeatureValues);
                    
                    chType = char(obj.tHyperParameterStates.sOptimizationVariableType(dHyperParameterIndex));
                    chTransform = char(obj.tHyperParameterStates.sOptimizationVariableTransform(dHyperParameterIndex));
                    
                    if isempty(xRange) || isempty(chType) || isempty(chTransform)
                        error(...
                            'MATLABTreeBagger:GetOptimizableVariables:InvalidHyperParameterOptimizationValues',...
                            ['The hyperparameter ', char(sVarName), ' is not also a hyperparameter within fitctree, and therefore default hyperparameter optimization values cannot be found. Please ensure the optimization domain, variable type, and variable transform all specified within the hyperparameter table.']);
                    end
                    
                    voOptimizableVariables = [voOptimizableVariables; optimizableVariable(sVarName, xRange, 'Type', chType, 'Transform', chTransform, 'Optimize', true)];
                end
            end
            
        end
    end
    
    methods (Access = {?ClassifierWithHyperParameterConstraintFunctions, ?MATLABBayesianHyperParameterOptimizer})
        
        function fn = GetConditionalVariableFcn(obj)
            fn = @MATLABTreeBaggerCVF;
            
            function XTable = MATLABTreeBaggerCVF(XTable)
                % none
            end
        end
        
        function fn = GetXConstraintFcn(obj)
            fn = @MATLABTreeBaggerXCF;
            
            function TF = MATLABTreeBaggerXCF(XTable)                
                TF = true(height(XTable),1); % none
            end
        end
    end
    
    
    
    methods (Access = private, Static = true)
        
        function dNumTrees = CastAndValidateNumTrees(dNumTrees)
            arguments
                dNumTrees (1,1) double {mustBeInteger, mustBePositive}
            end            
        end
        
        function xRange = EvaluateAnyFunctionsInHyperParameterRange(xRange, oLabelledFeatureValues)
            if iscell(xRange)
                for dIndex=1:numel(xRange)
                    if isa(xRange{dIndex}, 'function_handle')
                        fn = xRange{dIndex};
                        xRange{dIndex} = fn(oLabelledFeatureValues);
                        xRange = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(xRange);
                    end
                end
            end
        end
    end
    
    
    methods (Access = private)
        
        function oGuessingResults = GuessWithOptionalDuplicatedSamplesValidationOverride(obj, oLabelledFeatureValues, bJournalingOn, bOverrideDuplicatedSamplesValidation)            
            arguments
                obj
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                bJournalingOn (1,1) logical
                bOverrideDuplicatedSamplesValidation (1,1) logical
            end
            
            dtStartTime = datetime(now, 'ConvertFrom', 'datenum');
            [~,m2dScores] = obj.oTrainedClassifier.predict(oLabelledFeatureValues.GetFeatures());
            dtEndTime = datetime(now, 'ConvertFrom', 'datenum');
            
            vdPositiveLabelConfidences = m2dScores(:,2); % Made to only pull confidence of positive label. For the TreeBagger, this is the percent of votes for each sample
            
            if any(isnan(vdPositiveLabelConfidences))
                error(...
                    "MATLABTreeBagger:Guess:NaNConfidences",...
                    "Not sure why this would occur.");
            end
            
            % Modify output to be encapsulated in guess result class
            oGuessingResults = ClassificationGuessResult(obj, oLabelledFeatureValues, vdPositiveLabelConfidences, bOverrideDuplicatedSamplesValidation);
            
            % Journal:
            if Experiment.IsRunning() && bJournalingOn
                Experiment.StartNewSubSection(strcat("Classifier Guess: ", obj.sName));
                
                Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel("Elapsed Time: ", datestr(dtEndTime-dtStartTime, ReportUtils.GetDurationDatestrFormat())));
                
                dNumSamples = oLabelledFeatureValues.GetNumberOfSamples();
                dNumFeatures = oLabelledFeatureValues.GetNumberOfFeatures();
                
                Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel("Number of Samples: ", num2str(dNumSamples)));
                Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel("Number of Features: ", num2str(dNumFeatures)));
                
                Experiment.EndCurrentSubSection();
            end            
        end
    end
    
    
    methods (Access = {?KFoldCrossValidationUtils, ?Classifier})  
        
        function oGuessResult = GuessAllowDuplicatedSamples(obj, oLabelledFeatureValues, NameValueArgs)
            arguments
                obj
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            bOverrideDuplicatedSamplesValidation = true;
            oGuessResult = GuessWithOptionalDuplicatedSamplesValidationOverride(obj, oLabelledFeatureValues, NameValueArgs.JournalingOn, bOverrideDuplicatedSamplesValidation);
        end
                        
    end
    
end