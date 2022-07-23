classdef KerasNeuralNetwork < MachineLearningModel
    %KerasNeuralNetwork
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 12, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        sName (1,1) string = "Keras Neural Network"
        
        chPythonScriptFilePath (1,:) char
                
        chAnacondaInstallPath (1,:) char
        chAnacondaEnvironmentName (1,:) char
        
        dBatchSize (1,1) double {mustBePositive, mustBeInteger} = 1
        dNumberOfEpochs (1,1) double {mustBePositive, mustBeInteger} = 1
        
        tHyperParameters (:,3)
        
        fnCustomKerasTrainResultsMatFileProcessingFn function_handle = function_handle.empty
        fnCustomKerasGuessResultsMatFileProcessingFn function_handle = function_handle.empty
    end
    
    properties (SetAccess = private, GetAccess = public)
        oTrainingDataSampleIds (:,1) SampleIds
        chTrainingDataUuid (1,36) char
        
        chTrainedModelFilePath (:,1) char
        
        stCustomTrainResultsProperities struct
    end
                
    properties (Access = private, Constant = true)
        chSetAnacondaSettingsToTestingDefaultsHyperParameterKeyword = 'Set by Testing Anaconda Defaults'
        chSetAnacondaSettingsToExperimentSettingsHyperParameterKeyword = 'Set by Experiment Settings'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = KerasNeuralNetwork(chHyperParameterFilePath)
            %obj = KerasNeuralNetwork(chHyperParameterFilePath)
            %
            % SYNTAX:
            %  obj = KerasNeuralNetwork(chHyperParameterFilePath)
            %
            % DESCRIPTION:
            %  Constructor for GuessResult
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
           
            arguments
                chHyperParameterFilePath (1,:) char
            end
            
            tHyperParameters = FileIOUtils.LoadMatFile(chHyperParameterFilePath, 'tHyperParameters');
            
            bPythonScriptFilePathSet = false;
            bAnacondaInstallPathSet = false;
            bAnacondaEnvironmentNameSet = false;
            bBatchSizeSet = false;
            bNumberOfEpochsSet = false;
            bCustomKerasTrainResultsMatFileProcessingFnSet = false;
            bCustomKerasGuessResultsMatFileProcessingFnSet = false;
            
            for dRowIndex = 1:size(tHyperParameters,1)
                xValue = tHyperParameters.c1xValue{dRowIndex};
                
                switch tHyperParameters.sName(dRowIndex)
                    case "PythonScriptFilePath"
                        obj.chPythonScriptFilePath = FileIOUtils.GetAbsolutePath(xValue);
                        bPythonScriptFilePathSet = true;
                    case "BatchSize"
                        obj.dBatchSize = xValue;
                        bBatchSizeSet = true;
                    case "Epochs"
                        obj.dNumberOfEpochs = xValue;
                        bNumberOfEpochsSet = true;
                    case "AnacondaInstallPath"
                        bAnacondaInstallPathSet = true;
                        
                        switch xValue
                            case KerasNeuralNetwork.chSetAnacondaSettingsToTestingDefaultsHyperParameterKeyword
                                obj.chAnacondaInstallPath = AnacondaDefaults.GetDefaultTestingAnacondaInstallPathAndEnvironmentName();
                            case KerasNeuralNetwork.chSetAnacondaSettingsToExperimentSettingsHyperParameterKeyword
                                if Experiment.IsRunning()                                
                                    obj.chAnacondaInstallPath = Experiment.GetAnacondaInstallPathAndEnvironmentNameSettings();
                                else
                                    error(...
                                        'KerasNeuralNetwork:Constructor:NoExperimentForAnacondaInstallPath',...
                                        'The ''AnacondaInstallPath'' hyperparameter was set to ''Set by Experiment Settings'', but no Experiment is running.');
                                end
                            otherwise                   
                                obj.chAnacondaInstallPath = xValue;
                        end
                        
                    case "AnacondaEnvironmentName"
                        bAnacondaEnvironmentNameSet = true;
                        
                        switch xValue
                            case KerasNeuralNetwork.chSetAnacondaSettingsToTestingDefaultsHyperParameterKeyword
                                [~, obj.chAnacondaEnvironmentName] = AnacondaDefaults.GetDefaultTestingAnacondaInstallPathAndEnvironmentName();
                            case KerasNeuralNetwork.chSetAnacondaSettingsToExperimentSettingsHyperParameterKeyword
                                if Experiment.IsRunning()                                
                                    [~,obj.chAnacondaEnvironmentName] = Experiment.GetAnacondaInstallPathAndEnvironmentNameSettings();
                                else
                                    error(...
                                        'KerasNeuralNetwork:Constructor:NoExperimentForAnacondaEnvironmentName',...
                                        'The ''AnacondaEnvironmentName'' hyperparameter was set to ''Set by Experiment Settings'', but no Experiment is running.');
                                end
                            otherwise                     
                                obj.chAnacondaEnvironmentName = xValue;
                        end
                        
                    case "CustomKerasTrainResultsMatFileProcessingFn"
                        obj.fnCustomKerasTrainResultsMatFileProcessingFn = xValue;
                        bCustomKerasTrainResultsMatFileProcessingFnSet = true;
                    case "CustomKerasGuessResultsMatFileProcessingFn"
                        obj.fnCustomKerasGuessResultsMatFileProcessingFn = xValue;
                        bCustomKerasGuessResultsMatFileProcessingFnSet = true;                        
                end
            end
            
            % properities that must be set:
            %  - AnacondaInstallPath
            %  - AnacondaEnvironmentName
            %  - PythonScriptFilePath
            %  - Batch Size
            %  - Number of epochs
            
            if ~bPythonScriptFilePathSet || ~bAnacondaInstallPathSet || ~bAnacondaEnvironmentNameSet || ~bBatchSizeSet || ~bNumberOfEpochsSet || ~bCustomKerasTrainResultsMatFileProcessingFnSet || ~bCustomKerasGuessResultsMatFileProcessingFnSet
                error(...
                    'KerasNeuralNetwork:Constructor:InvalidHyperParametersFile',....
                    'The fields "PythonScriptFilePath", "AnacondaInstallPath", "AnacondaEnvironmentName", "BatchSize", "Epochs", "CustomKerasTrainResultsMatFileProcessingFn", "CustomKerasGuessResultsMatFileProcessingFn" must be set within the hyperparameters file.');
            end
            
            % set properities
                        
            obj.tHyperParameters = tHyperParameters;
        end  
        
        function xValue = GetHyperParameterValue(obj, sHyperParameterName)
            arguments
                obj
                sHyperParameterName (1,1) string
            end
            
            vsHyperParameterNames = obj.tHyperParameters.sName;
            
            vdMatchIndices = find(vsHyperParameterNames == sHyperParameterName);
            
            if length(vdMatchIndices) == 1
                xValue = obj.tHyperParameters.c1xValue{vdMatchIndices(1)};
            else
                error(...
                    'KerasNeuralNetwork:GetHyperParameterValue:HyperParameterNotFound',...
                    ['No hyper parameter with name "', char(sHyperParameterName), '" was found.']);
            end
        end
        
        function obj = SetCustomTrainResultsProperities(obj, stCustomProperitiesStruct)
            arguments
                obj (1,1) KerasNeuralNetwork
                stCustomProperitiesStruct (1,1) struct
            end
            
            if ~isempty(obj.stCustomTrainResultsProperities)
                error(...
                    'KerasNeuralNetwork:SetCustomTrainingResultsProperities:AlreadySet',...
                    'The CustomTrainingResultsProperities have already been set, and only can be set once.');
            else
                obj.stCustomTrainResultsProperities = stCustomProperitiesStruct;
            end
        end
        
        function stCustomProperitiesStruct = GetCustomTrainResultsProperities(obj)
            arguments
                obj (1,1) KerasNeuralNetwork
            end
            
            stCustomProperitiesStruct = obj.stCustomTrainResultsProperities;
        end
        
        function [obj, oGuessResult] = TrainAndGuess(obj, oTrainingDataSetOrDataGeneratorBuilder, oValidationDataSetOrDataGeneratorBuilder, oTestingDataSetDataOrDataGeneratorBuilder, chTrainedModelFilePath, NameValueArgs)
            % [obj, oGuessResult] = TrainAndGuess(obj, oTrainingDataSetOrDataGeneratorBuilder, oValidationDataSetOrDataGeneratorBuilder, oTestingDataSetDataOrDataGeneratorBuilder, chTrainedModelFilePath, NameValueArgs)
            %
            % SYNTAX:
            %  [obj, oGuessResult] = TrainAndGuess(obj, oTrainingDataSet, oValidationDataSet, oTestingDataSet, bDoesValidationDataSetInformTraining)
            %  [obj, oGuessResult] = TrainAndGuess(obj, oTrainingDataSetDataGeneratorBuilder, oValidationDataSetDataGeneratorBuilder oTestingDataSetDataGeneratorBuilder)
            %  [obj, oGuessResult] = TrainAndGuess(__, __, __, __, chTrainedModelFilePath)
            %  [obj, oGuessResult] = TrainAndGuess(__, __, __, __, Name, Value)
            %  [obj, oGuessResult] = TrainAndGuess(__, __, __, __, __, Name, Value)
            %
            %  Name-Value Pairs:
            %   'DEBUG_TrainingKerasDataGeneratorMatFilePath'
            %   'DEBUG_TestingKerasDataGeneratorMatFilePath'
            %   'DEBUG_KerasHyperParametersMatFilePath'
            %
            % DESCRIPTION:
            %  Constructor for GuessResult
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            %  oGuessResult:
            %   GuessResult object containing the results for the "Guess"
            %   piece of this TrainAndGuess function
            
            arguments
                obj (1,1) KerasNeuralNetwork
                oTrainingDataSetOrDataGeneratorBuilder (1,1) {ValidationUtils.MustBeA(oTrainingDataSetOrDataGeneratorBuilder, ["LabelledMachineLearningDataSet", "PythonLabelledDataGeneratorBuilder"])}
                oValidationDataSetOrDataGeneratorBuilder (1,1) {ValidationUtils.MustBeA(oValidationDataSetOrDataGeneratorBuilder, ["LabelledMachineLearningDataSet", "PythonLabelledDataGeneratorBuilder"])}
                oTestingDataSetDataOrDataGeneratorBuilder (1,1) {ValidationUtils.MustBeA(oTestingDataSetDataOrDataGeneratorBuilder, ["LabelledMachineLearningDataSet", "PythonLabelledDataGeneratorBuilder"])}
                chTrainedModelFilePath (1,:) char = ''
                NameValueArgs.DEBUG_TrainingKerasDataGeneratorMatFilePath (1,:) char = ''
                NameValueArgs.DEBUG_ValidationKerasDataGeneratorMatFilePath (1,:) char = ''
                NameValueArgs.DEBUG_TestingKerasDataGeneratorMatFilePath (1,:) char = ''
                NameValueArgs.DEBUG_KerasHyperParametersMatFilePath (1,:) char = ''
            end
        
            c1xVarargin = namedargs2cell(NameValueArgs);
            
            [obj, oGuessResult] = obj.PerformTrainAndGuess(...
                'TrainAndGuess',...
                'TrainingDataSetOrDataGeneratorBuilder', oTrainingDataSetOrDataGeneratorBuilder,...
                'ValidationDataSetOrDataGeneratorBuilder', oValidationDataSetOrDataGeneratorBuilder,...
                'TestingDataSetOrDataGeneratorBuilder', oTestingDataSetDataOrDataGeneratorBuilder,...
                'TrainedModelFilePath', chTrainedModelFilePath,...
                c1xVarargin{:});            
        end 
        
        function obj = Train(obj, oTrainingDataSetOrDataGeneratorBuilder, oValidationDataSetOrDataGeneratorBuilder, chTrainedModelFilePath, NameValueArgs)
            arguments
                obj (1,1) KerasNeuralNetwork
                oTrainingDataSetOrDataGeneratorBuilder {ValidationUtils.MustBeA(oTrainingDataSetOrDataGeneratorBuilder, ["LabelledMachineLearningDataSet", "PythonLabelledDataGeneratorBuilder"])}
                oValidationDataSetOrDataGeneratorBuilder  {ValidationUtils.MustBeA(oValidationDataSetOrDataGeneratorBuilder, ["LabelledMachineLearningDataSet", "PythonLabelledDataGeneratorBuilder"])}
                chTrainedModelFilePath (1,:) char = ''
                NameValueArgs.DEBUG_TrainingKerasDataGeneratorMatFilePath (1,:) char = ''
                NameValueArgs.DEBUG_ValidationKerasDataGeneratorMatFilePath (1,:) char = ''
                NameValueArgs.DEBUG_KerasHyperParametersMatFilePath (1,:) char = ''
            end
            
            c1xVarargin = namedargs2cell(NameValueArgs);
            
            obj = obj.PerformTrainAndGuess(...
                'Train',...
                'TrainingDataSetOrDataGeneratorBuilder', oTrainingDataSetOrDataGeneratorBuilder,...
                'ValidationDataSetOrDataGeneratorBuilder', oValidationDataSetOrDataGeneratorBuilder,...
                'TrainedModelFilePath', chTrainedModelFilePath,...
                c1xVarargin{:});  
        end 
        
        
        function oGuessResult = Guess(obj, oTestingDataSetOrDataGeneratorBuilder, NameValueArgs)
            arguments
                obj (1,1) KerasNeuralNetwork
                oTestingDataSetOrDataGeneratorBuilder  {ValidationUtils.MustBeA(oTestingDataSetOrDataGeneratorBuilder, ["LabelledMachineLearningDataSet", "PythonLabelledDataGeneratorBuilder"])}
                NameValueArgs.DEBUG_TestingKerasDataGeneratorMatFilePath (1,:) char = ''
                NameValueArgs.DEBUG_KerasHyperParametersMatFilePath (1,:) char = ''
            end
            
            c1xVarargin = namedargs2cell(NameValueArgs);
            
            oGuessResult = obj.PerformTrainAndGuess(...
                'Guess',...
                'TestingDataSetOrDataGeneratorBuilder', oTestingDataSetOrDataGeneratorBuilder,...
                c1xVarargin{:});  
        end 
    end
    
    
    methods (Access = public, Static = true)       
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
    end
    
    
    methods (Access = protected, Static = false)  
    end
    
    
    methods (Access = protected, Static = true)      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Abstract)
    end
    
    
    methods (Access = private, Static = false)    
                
        function obj = ProcessCustomKerasTrainingResultsMatFile(obj, chCustomKerasTrainingResultsMatFilePath)
            if ~isempty(obj.fnCustomKerasTrainResultsMatFileProcessingFn)
                obj = obj.fnCustomKerasTrainResultsMatFileProcessingFn(chCustomKerasTrainingResultsMatFilePath);
            end
        end
        
        function ProcessCustomKerasTestingResultsMatFile(obj, chGuessResultsMatFilePath)
            if ~isempty(obj.fnCustomKerasGuessResultsMatFileProcessingFn)
                obj.fnCustomKerasGuessResultsMatFileProcessingFn(chGuessResultsMatFilePath);
            end
        end
        
        function oGuessResultSampleLabels = ProcessKerasTestingNetworkOutputsMatFile(obj, chPredictedValuesMatFilePath, oTestingDataSet)
            switch class(oTestingDataSet.GetSampleLabels())
                case 'BinaryClassificationSampleLabels'
                    % load from Mat file created by Python
                    [vdPositiveLabelConfidences, vdNegativeLabelConfidences] = FileIOUtils.LoadMatFile(chPredictedValuesMatFilePath, 'vdPositiveLabelConfidences', 'vdNegativeLabelConfidences');
                    
                    % cast to double since these can come out as type single
                    vdPositiveLabelConfidences = double(vdPositiveLabelConfidences);
                    vdNegativeLabelConfidences = double(vdNegativeLabelConfidences);
                    
                    % Make GuessResultSampleLabels object
                    oGuessResultSampleLabels = BinaryClassificationGuessResultSampleLabels(...
                        vdPositiveLabelConfidences, vdNegativeLabelConfidences,...
                        oTestingDataSet.GetSampleLabels().GetPositiveLabel(), oTestingDataSet.GetSampleLabels().GetNegativeLabel());
                otherwise
                    error(...
                        'KerasNeuralNetwork:ProcessKerasTestingNetworkOutputsMatFile:UnsupportedSampleLabelsClass',...
                        'The supplied testing data set has an unsupported SampleLabels type.');
            end
        end
        
        function SaveHyperParametersToFileForPython(obj, chMatFilePath)
            dNumHyperParameters = length(obj.tHyperParameters.sName);
            
            c1xVararginForSaveMatFile = cell(1, 2*dNumHyperParameters);
            
            for dHyperParameterIndex=1:dNumHyperParameters
                c1xVararginForSaveMatFile{2*(dHyperParameterIndex-1)+1} = obj.tHyperParameters.sName(dHyperParameterIndex);
                
                xValue = obj.tHyperParameters.c1xValue{dHyperParameterIndex};
                
                if isa(xValue, 'function_handle') && isempty(xValue) % scipy.io.loadmat errors out if it tries to load a .mat with an empty function_handle saved in it
                    xValue = [];
                end
                
                c1xVararginForSaveMatFile{2*(dHyperParameterIndex-1)+2} = xValue;
            end
            
            FileIOUtils.SaveMatFile(chMatFilePath, c1xVararginForSaveMatFile{:});
        end
        
        function bBool = IsTrained(obj)
            bBool = ~isempty(obj.voDataSetRecordsForTraining);
        end
        
        function varargout = PerformTrainAndGuess(obj, sOperation, NameValueArgs)
            arguments
                obj
                sOperation (1,1) string {mustBeMember(sOperation, ["Train", "Guess", "TrainAndGuess"])}
                NameValueArgs.TrainingDataSetOrDataGeneratorBuilder
                NameValueArgs.ValidationDataSetOrDataGeneratorBuilder
                NameValueArgs.TestingDataSetOrDataGeneratorBuilder
                NameValueArgs.TrainedModelFilePath (1,:) char = ''
                NameValueArgs.DEBUG_TrainingKerasDataGeneratorMatFilePath (1,:) char = ''
                NameValueArgs.DEBUG_ValidationKerasDataGeneratorMatFilePath (1,:) char = ''
                NameValueArgs.DEBUG_TestingKerasDataGeneratorMatFilePath (1,:) char = ''
                NameValueArgs.DEBUG_KerasHyperParametersMatFilePath (1,:) char = ''
            end
                        
            % Set paths according to provided debug paths (e.g. if debug
            % path not provided, set it to a tempfile name
            if isempty(NameValueArgs.DEBUG_TrainingKerasDataGeneratorMatFilePath)
                chTrainingKerasDataGeneratorMatFilePath = [tempname, '.mat'];
            else
                chTrainingKerasDataGeneratorMatFilePath = NameValueArgs.DEBUG_TrainingKerasDataGeneratorMatFilePath;
            end
            
            if isempty(NameValueArgs.DEBUG_ValidationKerasDataGeneratorMatFilePath)
                chValidationKerasDataGeneratorMatFilePath = [tempname, '.mat'];
            else
                chValidationKerasDataGeneratorMatFilePath = NameValueArgs.DEBUG_ValidationKerasDataGeneratorMatFilePath;
            end
            
            if isempty(NameValueArgs.DEBUG_TestingKerasDataGeneratorMatFilePath)
                chTestingKerasDataGeneratorMatFilePath = [tempname, '.mat'];
            else
                chTestingKerasDataGeneratorMatFilePath = NameValueArgs.DEBUG_TestingKerasDataGeneratorMatFilePath;
            end
            
            if isempty(NameValueArgs.DEBUG_KerasHyperParametersMatFilePath)
                chKerasHyperParametersMatFilePath = [tempname, '.mat'];
            else
                chKerasHyperParametersMatFilePath = NameValueArgs.DEBUG_KerasHyperParametersMatFilePath;
            end
                        
            
            % common parameters to Train, Guess, and TrainAndGuess
            c1xPythonParameters = {...
                char(sOperation),...
                num2str(PythonUtils.GetNextPythonRandomSeedNumber()),...
                obj.chPythonScriptFilePath,...
                chKerasHyperParametersMatFilePath};
            
            
            % get some parameters from NameValueArgs
            chTrainedModelFilePath = NameValueArgs.TrainedModelFilePath;
                        
            if isfield(NameValueArgs, 'TrainingDataSetOrDataGeneratorBuilder')
                ValidationUtils.MustBeA(NameValueArgs.TrainingDataSetOrDataGeneratorBuilder, ["LabelledMachineLearningDataSet", "PythonLabelledDataGeneratorBuilder"]);
                
                oTrainingDataSetOrDataGeneratorBuilder = NameValueArgs.TrainingDataSetOrDataGeneratorBuilder;
                
                if isa(oTrainingDataSetOrDataGeneratorBuilder, 'LabelledMachineLearningDataSet')
                    oTrainingDataGeneratorBuilder = LabelledDataGeneratorBuilder(oTrainingDataSetOrDataGeneratorBuilder);
                else
                    oTrainingDataGeneratorBuilder = oTrainingDataSetOrDataGeneratorBuilder;
                end
            else
                oTrainingDataGeneratorBuilder = [];
            end
            
            if isfield(NameValueArgs, 'ValidationDataSetOrDataGeneratorBuilder')
                ValidationUtils.MustBeA(NameValueArgs.ValidationDataSetOrDataGeneratorBuilder, ["LabelledMachineLearningDataSet", "PythonLabelledDataGeneratorBuilder"]);
                
                oValidationDataSetOrDataGeneratorBuilder = NameValueArgs.ValidationDataSetOrDataGeneratorBuilder;
                
                if isa(oValidationDataSetOrDataGeneratorBuilder, 'LabelledMachineLearningDataSet')
                    oValidationDataGeneratorBuilder = LabelledDataGeneratorBuilder(oValidationDataSetOrDataGeneratorBuilder);
                else
                    oValidationDataGeneratorBuilder = oValidationDataSetOrDataGeneratorBuilder;
                end
            else
                oValidationDataGeneratorBuilder = [];
            end
            
            if isfield(NameValueArgs, 'TestingDataSetOrDataGeneratorBuilder')
                ValidationUtils.MustBeA(NameValueArgs.TestingDataSetOrDataGeneratorBuilder, ["LabelledMachineLearningDataSet", "PythonLabelledDataGeneratorBuilder"]);
                
                oTestingDataSetOrDataGeneratorBuilder = NameValueArgs.TestingDataSetOrDataGeneratorBuilder;
                
                if isa(oTestingDataSetOrDataGeneratorBuilder, 'LabelledMachineLearningDataSet')
                    oTestingDataGeneratorBuilder = LabelledDataGeneratorBuilder(oTestingDataSetOrDataGeneratorBuilder);
                else
                    oTestingDataGeneratorBuilder = oTestingDataSetOrDataGeneratorBuilder;
                end
            else
                oTestingDataGeneratorBuilder = [];
            end
            
            
            % Set-up file saving flags
            bSaveTrainingDataGeneratorToDisk = false;
            bSaveValidationDataGeneratorToDisk = false;
            bSaveTestingDataGeneratorToDisk = false;
            bSaveHyperParametersToDisk = false;
                        
            
            % Set-up for training
            if sOperation == "Train" || sOperation == "TrainAndGuess"
                % Training set tasks
                oTrainingDataSet = oTrainingDataGeneratorBuilder.GetMachineLearningDataSet();
                oValidationDataSet = oValidationDataGeneratorBuilder.GetMachineLearningDataSet();
                
                % - validate:
                
                % -- check that the model save path is valid
                if ~isempty(chTrainedModelFilePath)                    
                    if ~exist(FileIOUtils.SeparateFilePathAndFilename(chTrainedModelFilePath), 'dir')
                        error(...
                            'KerasNeuralNetwork:PerformTrainAndGuess:InvalidTrainedModelFilePath',...
                            ['The path ''', chTrainedModelFilePath, ''' does not exist to save the model into.']);
                    end
                elseif sOperation == "Train" % must save the model if we're only training
                    error(...
                        'KerasNeuralNetwork:PerformTrainAndGuess:InvalidTrainedModelFilePath',...
                        'A path to save the model to must be provided when performing a .Train() call');
                end
                
                % -- check that the training set is compatible with the
                %    hyper-parameter optimization data sets
                obj.MustBeValidDataSetForTrain(oTrainingDataSet);
                
                
                % - add training data set to training record of model
                if obj.IsTrained() % if it is already trained, clear out training record
                    obj = obj.ClearTrainingDataSetRecord();
                end
                
                obj = obj.AddDataSetToTrainingRecord(oTrainingDataSet);
                
                
                % validation set tasks:
                % - validate:
                % -- check that the validation set is compatible with the
                %    hyper-parameter optimization and training data sets
                obj.MustBeValidDataSetForValidation(oValidationDataSet);
                
                
                % - add validation data set to validation record of model
                if obj.IsTrained() % if it is already trained, clear out validation record
                    obj = obj.ClearValidationDataSetRecord();
                end
                
                obj = obj.AddDataSetToValidationRecord(oValidationDataSet);
                
                
                % - set properities
                obj.chTrainedModelFilePath = chTrainedModelFilePath;
                
                
                % Set flags to save data to disk for Python
                bSaveTrainingDataGeneratorToDisk = true;
                bSaveValidationDataGeneratorToDisk = true;
                bSaveHyperParametersToDisk = true;
                
                
                % Create training results filename
                chCustomTrainingResultsMatFilePath = [tempname, '.mat'];
                
                
                % add parameters
                c1xPythonParameters = [c1xPythonParameters, {...
                    chTrainingKerasDataGeneratorMatFilePath,...
                    chValidationKerasDataGeneratorMatFilePath,...
                    chTrainedModelFilePath,...
                    chCustomTrainingResultsMatFilePath}];
            end
               
            
            % Set-up for guessing
            if sOperation == "Guess" || sOperation == "TrainAndGuess"
                % testing set tasks
                oTestingSet = oTestingDataGeneratorBuilder.GetMachineLearningDataSet();
                
                % - validate
                % -- check the testing set is compatible with hyper-parameter
                %    optimization and training data sets
                obj.MustBeValidDataSetForGuess(oTestingSet);
                
                % -- if ".Guess()" is called ensure that the model was
                % trained, and if it was, the model was saved to disk
                if sOperation == "Guess"
                    if ~obj.IsTrained()
                        error(...
                            'KerasNeuralNetwork:PerformTrainAndGuess:ModelNotTrained',...
                            'The model must be trained before .Guess() is called.');
                    end
                    
                    if isempty(obj.chTrainedModelFilePath)
                        error(...
                            'KerasNeuralNetwork:PerformTrainAndGuess:KerasModelNotSaved',...
                            'The Keras model was not saved to disk when the training occured. The parameters were therefore not saved, and so .Guess() cannot be called.');
                    end
                end
                
                
                % Set flags to save data to disk for Python
                bSaveTestingDataGeneratorToDisk = true;
                bSaveHyperParametersToDisk = true;
                
                
                % create file paths
                chGuessResultsFilePath = [tempname, '.mat'];
                chCustomTestingResultsFilePath = [tempname, '.mat'];
                
                
                % add parameters
                if sOperation == "Guess"
                    c1xPythonParameters = [c1xPythonParameters, {...
                        obj.chTrainedModelFilePath}];
                end
                
                c1xPythonParameters = [c1xPythonParameters, {...
                    chTestingKerasDataGeneratorMatFilePath,...
                    chGuessResultsFilePath,...
                    chCustomTestingResultsFilePath}];                    
            end
            
            
            % Record that model changed
            obj = obj.ModelChanged();
            
            
            % save files to disk for Python
            if bSaveTrainingDataGeneratorToDisk
                oTrainingDataGeneratorBuilder.SaveToFileForPython(chTrainingKerasDataGeneratorMatFilePath);
            end
            
            if bSaveValidationDataGeneratorToDisk
                oValidationDataGeneratorBuilder.SaveToFileForPython(chValidationKerasDataGeneratorMatFilePath);
            end
            
            if bSaveTestingDataGeneratorToDisk
                oTestingDataGeneratorBuilder.SaveToFileForPython(chTestingKerasDataGeneratorMatFilePath);
            end
            
            if bSaveHyperParametersToDisk
                obj.SaveHyperParametersToFileForPython(chKerasHyperParametersMatFilePath)
            end
            
            
            % call Python code
            bPythonErroredOut = false;
            
            try
                PythonUtils.ExecutePythonScriptInAnacondaEnvironment(...
                    FileIOUtils.GetAbsolutePath('CentralLibraryKerasNeuralNetworkTrainAndGuess.py'),...
                    c1xPythonParameters,...
                    obj.chAnacondaInstallPath, obj.chAnacondaEnvironmentName);
            catch e
                bPythonErroredOut = true;
                oError = e;
            end
            
            
            % post call teardown
            if ~bPythonErroredOut
                varargout = {};
                
                if sOperation == "Train" || sOperation == "TrainAndGuess"
                    if ~isempty(obj.fnCustomKerasTrainResultsMatFileProcessingFn)
                        obj = obj.fnCustomKerasTrainResultsMatFileProcessingFn(obj, chCustomTrainingResultsMatFilePath);
                    end
                    
                    varargout = [varargout, {obj}];
                end
                
                if sOperation == "Guess" || sOperation == "TrainAndGuess"
                    if ~isempty(obj.fnCustomKerasGuessResultsMatFileProcessingFn)
                        obj.fnCustomKerasGuessResultsMatFileProcessingFn(obj, chCustomTestingResultsFilePath);
                    end
                    
                    oTestingDataSet = oTestingDataGeneratorBuilder.GetMachineLearningDataSet();
                    
                    oGuessResultSampleLabels = ProcessKerasTestingNetworkOutputsMatFile(obj, chGuessResultsFilePath, oTestingDataSet);
                    oGuessResult = GuessResult(oTestingDataSet, oGuessResultSampleLabels, obj);
                    
                    varargout = [varargout, {oGuessResult}];
                end
            end
            
            
            % clean-up files
            if bSaveTrainingDataGeneratorToDisk
                FileIOUtils.DeleteFileIfItExists(chTrainingKerasDataGeneratorMatFilePath);
            end
            
            if bSaveValidationDataGeneratorToDisk
                FileIOUtils.DeleteFileIfItExists(chValidationKerasDataGeneratorMatFilePath);
            end
            
            if bSaveTestingDataGeneratorToDisk
                FileIOUtils.DeleteFileIfItExists(chTestingKerasDataGeneratorMatFilePath);
            end
            
            if bSaveHyperParametersToDisk
                FileIOUtils.DeleteFileIfItExists(chKerasHyperParametersMatFilePath);
            end
            
            if sOperation == "Train" || sOperation == "TrainAndGuess"
                FileIOUtils.DeleteFileIfItExists(chCustomTrainingResultsMatFilePath);
            end
            
            if sOperation == "Guess" || sOperation == "TrainAndGuess"
                FileIOUtils.DeleteFileIfItExists(chCustomTestingResultsFilePath);
                FileIOUtils.DeleteFileIfItExists(chGuessResultsFilePath);
            end
            
            
            % rethrow error if it occured
            if bPythonErroredOut
                rethrow(oError);
            end
        end
    end
    
    
    methods (Access = private, Static = true) 
        
        
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)        
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

