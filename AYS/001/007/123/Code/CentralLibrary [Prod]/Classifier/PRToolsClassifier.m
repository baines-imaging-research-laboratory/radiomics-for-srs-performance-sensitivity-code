classdef (Abstract) PRToolsClassifier < Classifier
    %PRToolslassifier
    %
    % PRTools Classifier is an ABSTRACT class (cannot be instantiated) that
    % describes the user interface of any PRTools5 classifier in this
    % library. We have shifted away from PRTools so this class and its subclass 
    % PRToolsSVC will simply act as a guide for future developers who want to 
    % use PRTools.
    
    % Primary Author: Salma Dammak
    % Created: Feb 31, 2019
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    properties (Abstract = true, SetAccess = immutable, GetAccess = public)
        hClassifier 
    end
    
    properties (Constant = true, GetAccess = protected)
        vsHyperParameterStatesTableHeaders = ...
            ["sName",...
            "c1xValue",...
            "bOptimize",...
            "c1xOptimizationDomain",...
            "sModelParameterName",...
            ];
        
        vsHyperParameterStatesTableColumnTypes = ...
            ["string",...
            "cell",...
            "logical",...
            "cell",...
            "string"];
    end
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    methods (Static = false)
        function obj = PRToolsClassifier(chClassifierHyperParametersFileName, oHyperParameterOptimizer)
            %obj = PRToolsClassifier(chClassifierHyperParametersFileName)
            %
            % SYNTAX:
            %  obj = PRToolsClassifier(chClassifierHyperParametersFileName)
            %
            % DESCRIPTION:
            %  Constructor for PRToolsClassifier. The only thing this does for now is check that
            %       PRTools in on the path and call its super class to read the hyperparameters file.
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
                chClassifierHyperParametersFileName
                oHyperParameterOptimizer HyperParameterOptimizer {ValidationUtils.MustBeEmptyOrScalar(oHyperParameterOptimizer)}
            end
            
            obj = obj@Classifier(chClassifierHyperParametersFileName);
            
            % Check that PRTools in on the path and is version PRTools5
            try
                classc; % Calls an arbitrary function from the toolbox (can be replaced by any PRTools function)
            catch oMessage                
                if strcmp(oMessage.identifier,'MATLAB:UndefinedFunction')
                    error('PRToolsClassifier:PRToolsNotOnPath',['It appears that the PRTools toolbox ',...
                        'is not included in your path or that the version on your path does not match ',...
                        'ours. Please add PRTools to your path and make sure it is PRTools5.'])
                end
            end  
            
            if ~isempty(oHyperParameterOptimizer)
                obj = OptimizeHyperparameters(obj,oHyperParameterOptimizer);
            end
            
            % warn the user if a request for optimization was made
            if any(obj.tHyperParameterStates.bOptimize)
                chMsg = strcat('You have requested optimization of a parameter.',...
                        'Currently, parameter optimization for PRTools has not been implemented');
                warning('PRToolsClassifier:OptimizationNotImplemented',chMsg);
            end
            
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
            
            % Primary Author: Salma Dammak
            % Created: Feb 31, 2019
            
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
                obj.oTrainedClassifier = oPRTrainingSet*adaboostc([],obj.hClassifier(c1xClassifierParameters{:}));
            else
                obj.oTrainedClassifier = oPRTrainingSet*obj.hClassifier(c1xClassifierParameters{:});
            end
            
        end
        
        
        function oGuessingResults = Guess(obj, oLabelledFeatureValues)  
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
            
            % Primary Author: Ryan Alfano
            % Created: Nov 28, 2019
            
            arguments
                obj
                oLabelledFeatureValues (:,:) LabelledFeatureValues
            end

            % Test the classifier against the test set and get list of
            % confidences
            prTestSet = prdataset(GetFeatures(oLabelledFeatureValues));
            prResults = prTestSet * obj.oTrainedClassifier; 
            m2dConfidences = +prResults;

            % PRTools gives confidence of being a 1 in second column when given 0s and 1s. In train, we transform the
            % labels to 0s and 1s with positive label being 1 and this makes it so that in Guess 
            % 2nd column = positive label
            vdPositiveLabelConfidences = m2dConfidences(:,2);

            % Modify output to be encapsulated in guess result class
            oGuessingResults = ClassificationGuessResult(obj, oLabelledFeatureValues, vdPositiveLabelConfidences);
       end
    end
    
    % *********************************************************************
    % *                         PROTECTED METHODS                         *
    % *********************************************************************

    methods (Access = protected)
        % OptimizeHyperparameters
        function obj = ImplementationSpecificOptimizeHyperparameters(obj, NameValueArgs)
            arguments
                obj
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            warning('PRToolsClassifier:NoHyperParamterOptimizationForPRTools',...
                'PRTools currently does not allow for any hyperparameter optimization. No hyperparameters were optimized.')
        end
        function obj = IntializeHyperParameterStatesTable(obj,tHyperParametersFromFile)
            dNumRows = size(tHyperParametersFromFile,1);
            dNumColumns = length(obj.vsHyperParameterStatesTableHeaders);
            
            % Initialize empty table
            obj.tHyperParameterStates =  table('Size',[dNumRows dNumColumns],...
                'VariableTypes',obj.vsHyperParameterStatesTableColumnTypes,...
                'VariableNames', obj.vsHyperParameterStatesTableHeaders);
            
            % Get user inputs
            obj.tHyperParameterStates.sName = tHyperParametersFromFile.sName;
            obj.tHyperParameterStates.sModelParameterName = tHyperParametersFromFile.sModelParameterName;
            obj.tHyperParameterStates.c1xUserInputValue = tHyperParametersFromFile.c1xValue;
            obj.tHyperParameterStates.c1xValue = tHyperParametersFromFile.c1xValue;
            obj.tHyperParameterStates.bOptimize = tHyperParametersFromFile.bOptimize;
            obj.tHyperParameterStates.c1xOptimizationDomain = tHyperParametersFromFile.c1xOptimizationDomain;
            obj.tHyperParameterStates.c1xTrainingResult = obj.tHyperParameterStates.c1xValue;
        end
        function ValidateHyperParameterStatesForOptimization(obj)
            warning('PRToolsClassifier:NoHyperParamterOptimizationForPRTools',...
                'PRTools currently does not allow for any hyperparameter optimization. No hyperparameters were optimized.')
        end
        function obj = SetHyperParameterStatesOptimizableFlag(obj)
            warning('PRToolsClassifier:NoHyperParamterOptimizationForPRTools',...
                'PRTools currently does not allow for any hyperparameter optimization. No hyperparameters were optimized.')
        end
        
        function CheckForUnusedParameters(obj)

            % Check that all hyper-parameters in the input table are valid
            % Issue a warning if there are any parameters that are not
            % listed in the array of valid parameters set up in the
            % concrete classes
            for dInd = 1:size(obj.tHyperParameterStates,1)

                if ~ismember(obj.tHyperParameterStates.sName{dInd},obj.lsValidHyperParameterNames)
                    chMsg = strcat('You have requested a hyper-parameter in the input table that is not used by this classifier: ',...
                        obj.tHyperParameterStates.sName{dInd});
                    warning('PRToolsClassifier:UnusedHyperParameter',chMsg);
                end
            end
        end        

        
    end
    
    methods (Access = protected, Abstract = true)
        c1xHyperParams = GetImplementationSpecificParameters(obj) 
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
    end
    
    
    methods (Access = {?KFoldCrossValidationUtils, ?Classifier})
        
        function oGuessingResults = GuessAllowDuplicatedSamples(obj, oLabelledFeatureValues, NameValueArgs)
            arguments
                obj
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            error(...
                'PRToolsClassifier:GuessAllowDuplicatedSamples:Invalid',...
                'This is currently not supported by PRToolsClassifier.');
        end
    end

    methods (Access = {?matlab.unittest.TestCase}, Static = true)

        function oExpectedTrainedClassifier = CreateExpectedTrainedClassifier_ForUnitTest(testCase, chInputFileName)
            % oExpectedTrainedClassifier = CreateExpectedTrainedClassifier_ForUnitTest(testCase, chInputFileName)
            %
            % SYNTAX:
            %  oExpectedTrainedClassifier = CreateExpectedTrainedClassifier_ForUnitTest(testCase, chInputFileName)
            %
            % DESCRIPTION:
            %   Create a trained classifier using a direct call to PRTools
            %   (without going through the functions in BOLT).
            %   For PRTools, the call to training can have the prdataset
            %   external to the call (used in BOLT; i.e. W = A*RANDOMFORESTC([],L,N) )
            %   or embedded in the call (used in this UnitTest W =
            %   RANDOMFORESTC(A,L,N)).
            %   1) hPRToolsMapping(oPRDataSet,c1xInputParameters{:}) 
            %           used by unit tests
            %   2) oPRDataSet*hPRToolsMapping([],c1xInputParameters{:})
            %           used by BOLT
            %       (exception is KNN which requires the dataset to be embedded
            %
            % INPUT ARGUMENTS:
            %  testCase: unit test object
            %
            % OUTPUTS ARGUMENTS:
            %   oExpectedTrainedClassifier: trained classifier object
            %       created using the direct call to PRTools
            
            
            %%%%%% Expected values: From direct call to PRTools training
            
            % set up for direct PRTools call
            % inputs required:
            %       - cell array of parameters
            %           parameters vary dependent on the classifier type
            %       - PRTools dataset object with labels and features
            
            % read and set up parameters specific to each PRTools classifier
            [bAdaboost, hPRToolsMapping, c1xInputParameters] = ...
                PRToolsClassifier.ReadParameters(testCase, chInputFileName);
            
            % Change labels to integer 0s and 1s
            viChangedLabels = GetChangedLabels(testCase.oTrainData, int16(1),int16(0)); %(features, pos, neg)
            
            % Prep PR tools data set
            oPRDataSet = prdataset(GetFeatures(testCase.oTrainData),viChangedLabels);
            
            % train with parameters
            if (bAdaboost)
                
                oExpectedTrainedClassifier = adaboostc(oPRDataSet,hPRToolsMapping(c1xInputParameters{:}));
                
            else       % no Adaboost
                
                oExpectedTrainedClassifier = hPRToolsMapping(oPRDataSet,c1xInputParameters{:});
                
            end
            
        end
        
        function [bAdaboost, hPRToolsMapping, c1xInputParameters] =...
                ReadParameters(testCase, chInputFileName)
            %[bAdaboost, hPRToolsMapping, c1xInputParameters] = ReadParameters(testCase)
            %
            % SYNTAX:
            %  [bAdaboost, hPRToolsMapping, c1xInputParameters] = ReadParameters(testCase)
            %
            % DESCRIPTION:
            %   Each classifier has a unique set of associated parameters.
            %   These parameters are stored in the hyper-parameter table
            %   for the classifier being tested. The file name stored
            %   in the testCase object is loaded and the parameters are 
            %   read in and stored in the cell array used for constructing
            %   the PRTools classifier.
            %
            % INPUT ARGUMENTS:
            %  testCase: unit test object
            %
            % OUTPUTS ARGUMENTS:
            %   bAdaboost : boolean flag indicating whether Adaboost is to
            %       used when constructing the PRTools classifier
            %   hPRToolsMapping : PRTools mapping object for the specified
            %       classifier
            %   c1xInputParameters: cell array of parameters that were read
            %       in from the hyperparameter table for the specified
            %       classifier
            

            
            % read input parameters table
            %   Adaboost - a boolean indicating whether to optimize the 
            %      class specific parameters
            %  The remaining parameters should be specific for the
            %  classifier being tested. There may be parameters that are
            %  not valid (tests include 'BoxConstraint'). If the parameter
            %  does not match the list of valid parameters, it is ignored.
            
            tInputHyperParameters = FileIOUtils.LoadMatFile(...
                chInputFileName, 'tHyperParameters');
            
            bAdaboost = false;
            dAdaboostIdx = find(strcmp(tInputHyperParameters.sName,'Adaboost'));
            if ~isempty(dAdaboostIdx)
                bAdaboost = tInputHyperParameters.c1xValue{dAdaboostIdx};
            end
                        
            % Load the class specific parameters in the cell array and set
            % up the handle for the PRTools classifier.
            % Note: Some classifiers have no parameters.
            switch testCase.chClassifierHandleName
                case 'PRToolsFISHERC'
                    hPRToolsMapping = str2func('fisherc');
                    c1xInputParameters = {};
                case 'PRToolsKNNC'
                    hPRToolsMapping = str2func('knnc');
                    c1xInputParameters = ...
                        PRToolsClassifier.CollectKNNCParameters(tInputHyperParameters, bAdaboost);
                case 'PRToolsLOGLC'
                    hPRToolsMapping = str2func('loglc');
                    c1xInputParameters = {};
                case 'PRToolsNAIVEBC' 
                    hPRToolsMapping = str2func('naivebc');
                    c1xInputParameters = ...
                        PRToolsClassifier.CollectNAIVEBCParameters(tInputHyperParameters, bAdaboost);
                case 'PRToolsRFC'
                    hPRToolsMapping = str2func('randomforestc');
                    c1xInputParameters = ...
                        PRToolsClassifier.CollectRFCParameters(tInputHyperParameters, bAdaboost);
                case 'PRToolsSVC'
                    hPRToolsMapping = str2func('svc');
                    c1xInputParameters =...
                        PRToolsClassifier.CollectSVCParameters(tInputHyperParameters, bAdaboost);
                otherwise
                    hPRToolsMapping = '';
                    c1xInputParameters = {};
            end
           
            
        end
        
        
   
        function c1xInputParameters = CollectKNNCParameters(tInputHyperParameters, bAdaboost)
            %c1xInputParameters = CollectKNNCParameters(tInputHyperParameters)
            %
            % SYNTAX:
            %  c1xInputParameters = CollectKNNCParameters(tInputHyperParameters)
            %
            % DESCRIPTION:
            %   Search for the specific parameters for the knn classifier.
            %   If found, append it into the cell array to be returned.
            %
            % INPUT ARGUMENTS:
            %  tInputHyperParameters: table of hyper-parameters that was
            %   loaded from the input file for the knn classifier.
            %  bAdaboost: flag indicating whether Adaboost is to used in
            %   the construction of the classifier
            %
            % OUTPUTS ARGUMENTS:
            %   c1xInputParameters: cell array of parameters that were read
            %       in from the hyperparameter table for knn.

            % Collect class specific parameters
            dNumNeigboursIdx = find(strcmp(tInputHyperParameters.sName,'NumNeighbours'));
            
            % number of neighbours will optimize to leave-one-out if 0 or
            % empty
            c1xInputParameters = {};
            dParamIdx = 1;
            if ~isempty(dNumNeigboursIdx)
                dNumNeighbours = tInputHyperParameters.c1xValue{dNumNeigboursIdx};
                if dNumNeighbours > 0 
                    c1xInputParameters{dParamIdx} = dNumNeighbours;
                end
            end
        end
       
        function c1xInputParameters = CollectNAIVEBCParameters(tInputHyperParameters, bAdaboost)
            %c1xInputParameters = CollectNAIVEBCParameters(tInputHyperParameters)
            %
            % SYNTAX:
            %  c1xInputParameters = CollectNAIVEBCParameters(tInputHyperParameters)
            %
            % DESCRIPTION:
            %   Search for the specific parameters for the naivebc classifier.
            %   If found, append it into the cell array to be returned.
            %
            % INPUT ARGUMENTS:
            %  tInputHyperParameters: table of hyper-parameters that was
            %   loaded from the input file for the naivebc classifier.
            %  bAdaboost: flag indicating whether Adaboost is to used in
            %   the construction of the classifier
            %
            % OUTPUTS ARGUMENTS:
            %   c1xInputParameters: cell array of parameters that were read
            %       in from the hyperparameter table for naivebc.

            % Collect class specific parameters
            dNumBinsIdx = find(strcmp(tInputHyperParameters.sName,'NumBins'));
            c1xInputParameters = {};
            dParamIdx = 1;
            if ~isempty(dNumBinsIdx)
                dNumBins = tInputHyperParameters.c1xValue{dNumBinsIdx};
                if dNumBins > 0 
                    c1xInputParameters{dParamIdx} = dNumBins;
                end
            end
                    
        end
       
        function c1xInputParameters = CollectSVCParameters(tInputHyperParameters, bAdaboost)
            %c1xInputParameters = CollectSVCParameters(tInputHyperParameters)
            %
            % SYNTAX:
            %  c1xInputParameters = CollectSVCParameters(tInputHyperParameters)
            %
            % DESCRIPTION:
            %   Search for the specific parameters for the svc classifier.
            %   If found, append it into the cell array to be returned.
            %   Specific to the support vector classifier, parameters
            %   'type' and 'order' read in from the table are combined 
            %   using the PRToolsfunction proxm to create the kernel. This
            %   'kernel' is appended to the cell array of input parameters
            %   used to construct the classifier.
            %
            % INPUT ARGUMENTS:
            %  tInputHyperParameters: table of hyper-parameters that was
            %   loaded from the input file for the svc classifier.
            %  bAdaboost: flag indicating whether Adaboost is to used in
            %   the construction of the classifier
            %
            % OUTPUTS ARGUMENTS:
            %   c1xInputParameters: cell array of parameters that were read
            %       in from the hyperparameter table for svc.

            % Collect class specific parameters
            dKernelTypeIdx = find(strcmp(tInputHyperParameters.sName,'KernelType'));
            dKernelOrderIdx = find(strcmp(tInputHyperParameters.sName,'KernelOrder'));
            dCostIdx = find(strcmp(tInputHyperParameters.sName,'Cost'));
            
            fhKernel = [];
            % create Kernel based on type and order read in
            if ~isempty(dKernelTypeIdx) && ~isempty(dKernelOrderIdx)
                chKernelType = tInputHyperParameters.c1xValue{dKernelTypeIdx};
                dKernelOrder = tInputHyperParameters.c1xValue{dKernelOrderIdx};
                fhKernel = proxm(chKernelType,dKernelOrder);
            end
            
            c1xInputParameters = {};
            if ~isempty(fhKernel)
                c1xInputParameters{1} = fhKernel;
                if ~isempty(dCostIdx)
                    c1xInputParameters{2} = tInputHyperParameters.c1xValue{dCostIdx};
                end
            end
                    
        end
        
        function c1xInputParameters = CollectRFCParameters(tInputHyperParameters, bAdaboost)
            %c1xInputParameters = CollectRFCParameters(tInputHyperParameters)
            %
            % SYNTAX:
            %  c1xInputParameters = CollectRFCParameters(tInputHyperParameters)
            %
            % DESCRIPTION:
            %   Search for the specific parameters for the randomforestc classifier.
            %   If found, append it into the cell array to be returned.
            %
            %   In the unit tests for PRTools, we are using the method that
            %   has the dataset embedded in the constructor's input
            %   parameters. (BOLT uses the method with the dataset external
            %   to the classifier constructor call).
            %   Classifiers other than randomforestc use the returned cell
            %   array of input parameters generated by these 'Collection'
            %   functions as is. 
            %   When combined with Adaboost, construction of the
            %   randomforestc classifier requires an empty array in the
            %   first parameter of the cell array representing the dataset
            %   embedded in the Adaboost call.
            %
            % INPUT ARGUMENTS:
            %  tInputHyperParameters: table of hyper-parameters that was
            %   loaded from the input file for the randomforestc classifier.
            %  bAdaboost: flag indicating whether Adaboost is to used in
            %   the construction of the classifier
            %
            % OUTPUTS ARGUMENTS:
            %   c1xInputParameters: cell array of parameters that were read
            %       in from the hyperparameter table for randomforestc.

            % Collect class specific parameters
            dNumDecisionTreesIdx = find(strcmp(tInputHyperParameters.sName,'NumDecisionTrees'));
            dFeatureSubsetSizeIdx = find(strcmp(tInputHyperParameters.sName,'FeatureSubsetSize'));
            
            if ~isempty(dNumDecisionTreesIdx)
                dNumDecisionTrees = tInputHyperParameters.c1xValue{dNumDecisionTreesIdx};
                c1xInputParameters{1} = dNumDecisionTrees;
            else
                c1xInputParameters{1} = [];
            end
            if ~isempty(dFeatureSubsetSizeIdx)
                dSizeFeatureSubset = tInputHyperParameters.c1xValue{dFeatureSubsetSizeIdx};
                c1xInputParameters{2} = dSizeFeatureSubset;
            else
                c1xInputParameters{2} = [];
            end
                    
            if bAdaboost
                % Special handling of input parameters for
                % randomforestc with Adaboost.
                % It requires an empty array in the first cell followed
                % by the parameters from the input table.
                % The dataset used for training and boosting is
                % embedded in the adaboost call.
                c1xInputParameters = {[],c1xInputParameters{1:end}};
            end
                
        end
    end

end