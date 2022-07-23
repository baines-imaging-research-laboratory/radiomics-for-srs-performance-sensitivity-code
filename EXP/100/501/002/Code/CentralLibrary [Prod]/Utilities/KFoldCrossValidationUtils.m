classdef (Abstract) KFoldCrossValidationUtils
    %KFoldCrossValidationUtils
    %  
    %  Provides functions to acquire the prediction objects and error
    %  metrics
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Access = private, Constant = true)
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Static = true)
        
        function c2oGuessResults = PerformClassifierCrossValidation(oClassifier, oLabelledFeatureValues, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedGuessResults, NameValueArgs)
            %c2oGuessResults = PerformClassifierCrossValidation(oClassifier, oLabelledFeatureValues, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedGuessResults, NameValueArgs)
            %
            % SYNTAX:
            %  c2oGuessResults = PerformClassifierCrossValidation(oClassifier, oLabelledFeatureValues, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedGuessResults, NameValueArgs)
            %
            % DESCRIPTION:
            %  TODO
            %  
            % INPUT ARGUMENTS:
            %  oClassifier:
            %  oLabelledFeatureValues:
            %  dNumFolds:
            %  dNumReps:
            %  bBalanceTrainingSet:
            %  bAccumulatedGuessResults:
            %  NameValueArgs:
            %
            % OUTPUT ARGUMENTS:
            %  c2oGuessResults: 

            arguments
                oClassifier (1,1) Classifier
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                dNumFolds (1,1) double {mustBeInteger, mustBePositive} = 5
                dNumReps (1,1) double {mustBeInteger, mustBePositive} = 1
                bBalanceTrainingSet (1,1) logical = true
                bAccumulatedGuessResults (1,1) logical = true
                NameValueArgs.SuppressWarnings (1,1) logical = true
                NameValueArgs.UseParallel (1,1) logical = false;
            end
            
            bSuppressWarnings = NameValueArgs.SuppressWarnings;
            bUseParallel = NameValueArgs.UseParallel;
            
            bAllowDuplicates = false;
            
            c2oGuessResults = KFoldCrossValidationUtils.PerformClassifierCrossValidation_Private(oClassifier, oLabelledFeatureValues, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedGuessResults, bSuppressWarnings, bUseParallel, bAllowDuplicates);
        end
        
        function [vdErrorMetricValues, c2oGuessResults] = PerformClassifierCrossValidationForErrorMetrics(oClassifier, oLabelledFeatureValues, voValidationErrorMetrics, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedErrorMetrics, NameValueArgs)
            %[vdErrorMetricValues, c2oGuessResults] = PerformClassifierCrossValidationForErrorMetrics(oClassifier, oLabelledFeatureValues, voValidationErrorMetrics, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedErrorMetrics, NameValueArgs)
            %
            % SYNTAX:
            %  [vdErrorMetricValues, c2oGuessResults] = PerformClassifierCrossValidationForErrorMetrics(oClassifier, oLabelledFeatureValues, voValidationErrorMetrics, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedErrorMetrics, NameValueArgs)
            %
            % DESCRIPTION:
            %  TODO
            %  
            % INPUT ARGUMENTS:
            %  oClassifier: 
            %  oLabelledFeatureValues:
            %  voValidationErrorMetrics:
            %  dNumFolds:
            %  dNumReps:
            %  bBalanceTrainingSet:
            %  bAccumulatedGuessResults:
            %  NameValueArgs:
            %
            % OUTPUT ARGUMENTS:
            %  vdErrorMetricValues:
            %  c2oGuessResults: 

            arguments
                oClassifier (1,1) Classifier
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                voValidationErrorMetrics (1,:) ErrorMetric
                dNumFolds (1,1) double {mustBeInteger, mustBePositive} = 5
                dNumReps (1,1) double {mustBeInteger, mustBePositive} = 1
                bBalanceTrainingSet (1,1) logical = true
                bAccumulatedErrorMetrics (1,1) logical = true
                NameValueArgs.SuppressWarnings (1,1) logical = true
                NameValueArgs.UseParallel (1,1) logical = false
            end
            
            bSuppressWarnings = NameValueArgs.SuppressWarnings;
            bUseParallel = NameValueArgs.UseParallel;
            
            bAllowDuplicates = false;
            
            [vdErrorMetricValues, c2oGuessResults] = KFoldCrossValidationUtils.PerformClassifierCrossValidationForErrorMetrics_Private(oClassifier, oLabelledFeatureValues, voValidationErrorMetrics, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedErrorMetrics, bSuppressWarnings, bUseParallel, bAllowDuplicates);            
        end
    end
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = private, Static = true)
        
        function oGuessResult = PerformFoldIteration(dCurrentFold, oRandomNumberGenerator, oLabelledFeatureValues, oClassifier, c1vdTrainingIndicesPerFold, c1vdTestingIndicesPerFold, bBalanceTrainingSet, bAllowDuplicates, bSuppressWarnings)
            % Manage RNG
            oRandomNumberGenerator.PerLoopIndexSetup(dCurrentFold);
            
            % Create the training and testing partitions
            oTrainingFeatureValues = oLabelledFeatureValues(c1vdTrainingIndicesPerFold{dCurrentFold},:);
            oTestingFeatureValues = oLabelledFeatureValues(c1vdTestingIndicesPerFold{dCurrentFold},:);
            
            % Balance if needed
            if bBalanceTrainingSet
                oTrainingFeatureValues = oTrainingFeatureValues.BalanceLabels('SuppressWarnings', bSuppressWarnings);
            end
            
            % Train the classifier
            oTrainedClassifier = oClassifier.Train(oTrainingFeatureValues, 'JournalingOn', false); % disable journalling
            
            % Perform classification and save in a
            % ClassificationGuessResult object
            if bAllowDuplicates
                oGuessResult = oTrainedClassifier.GuessAllowDuplicatedSamples(oTestingFeatureValues, 'JournalingOn', false); % disable journalling
            else
                oGuessResult = oTrainedClassifier.Guess(oTestingFeatureValues, 'JournalingOn', false); % disable journalling
            end
            
            % Manage RNG
            oRandomNumberGenerator.PerLoopIndexTeardown();
        end
        
        function [vdErrorMetricValues, c2oGuessResults] = PerformClassifierCrossValidationForErrorMetrics_Private(oClassifier, oLabelledFeatureValues, voValidationErrorMetrics, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedErrorMetrics, bSuppressWarnings, bUseParallel, bAllowDuplicates)
            arguments
                oClassifier (1,1) Classifier
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                voValidationErrorMetrics (1,:) ErrorMetric
                dNumFolds (1,1) double {mustBeInteger, mustBePositive}
                dNumReps (1,1) double {mustBeInteger, mustBePositive}
                bBalanceTrainingSet (1,1) logical
                bAccumulatedErrorMetrics (1,1) logical
                bSuppressWarnings (1,1) logical
                bUseParallel (1,1) logical
                bAllowDuplicates (1,1) logical
            end
            
            % get the guess result objects for the k-folder cross
            % validation
            c2oGuessResults = KFoldCrossValidationUtils.PerformClassifierCrossValidation_Private(oClassifier, oLabelledFeatureValues, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedErrorMetrics, bSuppressWarnings, bUseParallel, bAllowDuplicates);
            
            % use the guess results to get the error metric values
            dNumErrorMetrics = length(voValidationErrorMetrics);
            
            vdErrorMetricValues = zeros(dNumErrorMetrics,1);
            
            for dErrorMetricIndex = 1:dNumErrorMetrics
                oErrorMetric = voValidationErrorMetrics(dErrorMetricIndex);
                
                vdErrorMetricValuesAcrossReps = zeros(1,dNumReps);
                
                for dRepIndex=1:dNumReps                
                    if bAccumulatedErrorMetrics
                        vdErrorMetricValuesAcrossReps(dRepIndex) = oErrorMetric.Calculate(c2oGuessResults{1,dRepIndex}, 'JournalingOn', false, 'SuppressWarnings', bSuppressWarnings);
                    else
                        vdErrorMetricValuesAcrossFoldsForRep = zeros(dNumFolds,1);
                        
                        for dFoldIndex=1:dNumFolds
                            vdErrorMetricValuesAcrossFoldsForRep(dFoldIndex) = oErrorMetric.Calculate(c2oGuessResults{dFoldIndex,dRepIndex}, 'JournalingOn', false, 'SuppressWarnings', bSuppressWarnings);
                        end
                        
                        vdErrorMetricValuesAcrossReps(dRepIndex) = mean(vdErrorMetricValuesAcrossFoldsForRep);
                    end
                end
                
                vdErrorMetricValues(dErrorMetricIndex) = mean(vdErrorMetricValuesAcrossReps);
            end
        end
        
        function c2oGuessResults = PerformClassifierCrossValidation_Private(oClassifier, oLabelledFeatureValues, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedGuessResults, bSuppressWarnings, bUseParallel, bAllowDuplicates)
            arguments
                oClassifier (1,1) Classifier
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                dNumFolds (1,1) double {mustBeInteger, mustBePositive}
                dNumReps (1,1) double {mustBeInteger, mustBePositive}
                bBalanceTrainingSet (1,1) logical
                bAccumulatedGuessResults (1,1) logical
                bSuppressWarnings (1,1) logical
                bUseParallel (1,1) logical
                bAllowDuplicates (1,1) logical
            end
            
            % final cell array to fill
            c2oGuessResults = cell(dNumFolds, dNumReps);
            
            % find total number of folds to calculate
            dNumTotalFolds = dNumFolds * dNumReps;
            c1vdTrainingIndicesPerFold = cell(dNumTotalFolds,1);
            c1vdTestingIndicesPerFold = cell(dNumTotalFolds,1);
            
            c1oGuessResultsPerFold = cell(dNumTotalFolds,1);
            
            % find and store the fold partitions for each repetition and
            % lay them out per fold
            dTotalFoldIndex = 1;
            
            for dRepIndex = 1:dNumReps                
                bRepresentativeTestingSets = ~bAccumulatedGuessResults;
                stCrossValidationRowIndices = CrossValidationPartition.CreateFoldedPartition(oLabelledFeatureValues, dNumFolds, bRepresentativeTestingSets);
                
                for dFoldIndex=1:dNumFolds
                    c1vdTrainingIndicesPerFold{dTotalFoldIndex} = stCrossValidationRowIndices(dFoldIndex).TrainingIndices;
                    c1vdTestingIndicesPerFold{dTotalFoldIndex} = stCrossValidationRowIndices(dFoldIndex).TestingIndices;
                    
                    dTotalFoldIndex = dTotalFoldIndex + 1;
                end
            end
            
            % compute all the folds for all reps using one for/parfor loop.
            % This is done instead of nested loops (see algorithm
            % documentation below) such that parfor loop get have maximal
            % performance (e.g. reduced overhead, maximum usage of large
            % numbers of workers)
            if RandomNumberGenerator.IsInitialized()            
                oRandomNumberGenerator = RandomNumberGenerator(); 
            else
                oRandomNumberGenerator = RandomNumberGenerator(7); % is no RNG is setup yet, just make one for the user seeded with lucky number 7
            end
            
            oRandomNumberGenerator.PreLoopSetup(dNumTotalFolds); % Not using the Experiment.GetLoopIterationManager() here. That's a little heavy weight for what we want to do, and would likely diminish the returns. Instead, we guarantee that no Experiment access occurs within here, so only the RNG management is needed
            
            if bUseParallel
                if Experiment.IsRunning()
                    Experiment.StartParallelPool();
                end
                
                parfor dCurrentFold = 1:dNumTotalFolds
                    c1oGuessResultsPerFold{dCurrentFold} = KFoldCrossValidationUtils.PerformFoldIteration(dCurrentFold, oRandomNumberGenerator, oLabelledFeatureValues, oClassifier, c1vdTrainingIndicesPerFold, c1vdTestingIndicesPerFold, bBalanceTrainingSet, bAllowDuplicates, bSuppressWarnings);
                end
            else
                for dCurrentFold = 1:dNumTotalFolds
                    c1oGuessResultsPerFold{dCurrentFold} = KFoldCrossValidationUtils.PerformFoldIteration(dCurrentFold, oRandomNumberGenerator, oLabelledFeatureValues, oClassifier, c1vdTrainingIndicesPerFold, c1vdTestingIndicesPerFold, bBalanceTrainingSet, bAllowDuplicates, bSuppressWarnings);
                end
            end
            
            oRandomNumberGenerator.PostLoopTeardown();
            
            % take the results from all the folds in one vector and
            % transform it into the cell matrix with folds going down rows
            % and reps going across columns
            dTotalFoldIndex = 1;
            
            for dRepIndex = 1:dNumReps                                
                for dFoldIndex=1:dNumFolds
                    c2oGuessResults{dFoldIndex, dRepIndex} = c1oGuessResultsPerFold{dTotalFoldIndex};
                    
                    dTotalFoldIndex = dTotalFoldIndex + 1;
                end
            end
                        
            % ALGORITHM DOCUMENTATION
            % Everything done above is equivalent to this code below which
            % is a bit easier to digest/understand:
            
            % %             c2oGuessResults = cell(dNumFolds,dNumReps);
            % %
            % %             for dCurrentRep = 1:dNumReps
            % %                 bRepresentativeTestingSets = ~bAccumulatedGuessResults;
            % %                 stCrossValidationRowIndices = CrossValidationPartition.CreateFoldedPartition(oLabelledFeatureValues, dNumFolds, bRepresentativeTestingSets);
            % %
            % %                 % Loop across all folds
            % %                 for dCurrentFold = 1:dNumFolds
            % %                     % Create the training and testing partitions
            % %                     oTrainingFeatureValues = oLabelledFeatureValues(stCrossValidationRowIndices(dCurrentFold).TrainingIndices,:);
            % %                     oTestingFeatureValues = oLabelledFeatureValues(stCrossValidationRowIndices(dCurrentFold).TestingIndices,:);
            % %
            % %                     % Balance if needed
            % %                     if bBalanceTrainingSet
            % %                         oTrainingFeatureValues = oTrainingFeatureValues.BalanceLabels('SuppressWarnings', NameValueArgs.SuppressWarnings);
            % %                     end
            % %
            % %                     % Train the classifier
            % %                     oTrainedClassifier = oClassifier.Train(oTrainingFeatureValues, 'JournalingOn', false); % disable journalling
            % %
            % %                     % Perform classification and save in a
            % %                     % ClassificationGuessResult object
            % %                     c2oGuessResults{dCurrentFold, dCurrentRep} = oTrainedClassifier.Guess(oTestingFeatureValues, 'JournalingOn', false); % disable journalling
            % %                 end
            % %             end
            
            % if AccumulatedGuessResults is turned, we want only one guess result per rep (instead one per fold). Using the vertcat of GuessResults to accomplish this 
            if bAccumulatedGuessResults
                for dRepIndex=1:dNumReps
                    c1oGuessResultsToConcatenate = c2oGuessResults(:,dRepIndex);
                    c1oGuessResultsToConcatenate = c1oGuessResultsToConcatenate';
                    
                    c2oGuessResults{1,dRepIndex} = vertcat(c1oGuessResultsToConcatenate{:});
                end
                
                c2oGuessResults = c2oGuessResults(1,:);
            end
        end
    end

    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *       KFoldCrossValidationObjectiveFunction ACCESS                           *
    % *                  (To ONLY be called by 
    % *             KFoldCrossValidationObjectiveFunction)                     *
    % *********************************************************************
    
    methods (Access = ?KFoldCrossValidationObjectiveFunction, Static = true)
        
        function [vdErrorMetricValues, c2oGuessResults] = PerformClassifierCrossValidationForErrorMetrics_AllowDuplicates(oClassifier, oLabelledFeatureValues, voValidationErrorMetrics, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedErrorMetrics, NameValueArgs)
            arguments
                oClassifier (1,1) Classifier
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                voValidationErrorMetrics (1,:) ErrorMetric
                dNumFolds (1,1) double {mustBeInteger, mustBePositive} = 5
                dNumReps (1,1) double {mustBeInteger, mustBePositive} = 1
                bBalanceTrainingSet (1,1) logical = true
                bAccumulatedErrorMetrics (1,1) logical = true
                NameValueArgs.SuppressWarnings (1,1) logical = true
                NameValueArgs.UseParallel (1,1) logical = false
            end
            
            bAllowDuplicates = true;
            
            [vdErrorMetricValues, c2oGuessResults] = KFoldCrossValidationUtils.PerformClassifierCrossValidationForErrorMetrics_Private(oClassifier, oLabelledFeatureValues, voValidationErrorMetrics, dNumFolds, dNumReps, bBalanceTrainingSet, bAccumulatedErrorMetrics, NameValueArgs.SuppressWarnings, NameValueArgs.UseParallel, bAllowDuplicates);            
        end
    end
end

