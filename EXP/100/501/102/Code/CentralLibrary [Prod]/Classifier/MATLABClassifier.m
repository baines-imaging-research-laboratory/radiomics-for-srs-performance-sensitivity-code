classdef (Abstract) MATLABClassifier < Classifier
    %MATLABClassifier
    %
    % MATLAB Classifier is an ABSTRACT class (cannot be instantiated) that
    % describes the user interface of any MATLAB classifier in this
    % library. It also provides validation functions for some of the
    % methods and properties within its subclasses.Note that all
    % classifiers at this point only work with labelled data.
    
    % HACK: SPECIAL CASE for fitcdiscr parameters
    % SEE FUNCTION UpdateParametersAfterOptimization
    %   Input parameters 'FillCoeffs' and 'SaveMemory' must
    %   be string values 'on' or 'off'. The model returns
    %   boolean values 0 or 1. These must be converted to
    %   strings or the Train function will crash.
    
    
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
            ["sName","sNameInModel",...
            "c1xUserInputValue","bOptimize","c1xOptimizationDomain",...
            "c1xSanitizedUserInputValue",...
            "bOptimizable",...
            ...
            "bOptimized","c1xOptimizationLowLevelResultFromModel",...
            "bOptimizationLowLevelResultFromModelExists",...
            "c1xOptimizationHighLevelResultFromModel",...
            "bOptimizationHighLevelResultFromModelExists",...
            "c1xOptimizationResult",...
            "bOptimizationResultExists",...
            ...
            "c1xTrainingInputValue",...
            "c1xTrainingLowLevelResultFromModel",...
            "bTrainingLowLevelResultFromModelExists",...
            "c1xTrainingHighLevelResultFromModel",...
            "bTrainingHighLevelResultFromModelExists",...
            "c1xTrainingResult",...
            "bTrainingResultExists"];
        
        vsHyperParameterStatesTableColumnTypes = ...
            ["string","string",...
            "cell","logical","cell",...
            "cell",...
            "logical",...
            ...
            "logical","cell",...
            "logical",...
            "cell",...
            "logical",...
            "cell",...
            "logical",...
            ...
            "cell",...
            "cell",...
            "logical",...
            "cell",...
            "logical",...
            "cell",...
            "logical"];
    end
    
    properties (Constant = true, GetAccess = private)
        sExperimentJournalingObjVarName = "oClassifier"
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = false)
        
        function obj = MATLABClassifier(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, NameValueArgs)
            %obj = MATLABClassifier(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, NameValueArgs)
            %
            % SYNTAX:
            %  obj = MATLABClassifier(chClassifierHyperParametersFileName, oHyperParameterOptimizer)
            %  obj = MATLABClassifier(tHyperParameters, oHyperParameterOptimizer)
            %  obj = MATLABClassifier(__, __, Name, Value)
            %
            % DESCRIPTION:
            %  Constructor for MATLABClassifier
            %
            % INPUT ARGUMENTS:
            %  chClassifierHyperParametersFileName This is a .mat file containing all the
            %       hyperparameter information.
            %       A default settings mat file for this classifier is found under:
            %       BOLT > DefaultInputs > Classifier
            %  tHyperParameters: a table of hyperparameters. This should be
            %   the same table as would be loaded from a
            %   hyper-parameter.mat file
            %  oHyperParameterOptimizer: A HyperParameterOptimizer object
            %                            that is used for optimization. If
            %                            it is passed as empty,
            %                            hyperparameters optimization will
            %                            not occur.
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: Salma Dammak
            % Created: Feb 31, 2019
            
            arguments
                xClassifierHyperParametersFileNameOrHyperParametersTable
                oHyperParameterOptimizer HyperParameterOptimizer {ValidationUtils.MustBeEmptyOrScalar(oHyperParameterOptimizer)}
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            
            % Call superclass constructor to open the hyperparameters file, do some error checking
            % and add it as a property to the object.
            obj = obj@Classifier(xClassifierHyperParametersFileNameOrHyperParametersTable);
             
            
            obj = SanitizeUserInputs(obj);
            
            if ~isempty(oHyperParameterOptimizer)
                obj = OptimizeHyperparameters(obj, oHyperParameterOptimizer, 'JournalingOn', NameValueArgs.JournalingOn);
            elseif isempty(oHyperParameterOptimizer) && any(obj.tHyperParameterStates.bOptimize)
                warning("MATLABClassifier:SetOptimizeFlagTrueNoOptimizer",...
                    "You set one or more bOptimize flags to true for the parameters you specified but "...
                    +"did not give an optimizer to the constructor. No parameters were optimized.")
            end
            
            obj = SetHyperParameterStatesTrainingInputValue(obj);
            
            % Journal:
            if Experiment.IsRunning() && NameValueArgs.JournalingOn
                Experiment.StartNewSubSection("Constructing Classifier - " + obj.sName);
                
                [bAddEntriesIntoExperimentReport, bSaveObjects, bSaveSummaryFiles] = Experiment.GetJournalingSettings();
                
                if bSaveObjects
                    sObjectFilePath = fullfile(Experiment.GetResultsDirectory(), "Journalled Variables.mat");
                    
                    FileIOUtils.SaveMatFile(sObjectFilePath, MATLABClassifier.sExperimentJournalingObjVarName, obj);
                    
                    Experiment.AddToReport(ReportUtils.CreateLinkToMatFileWithVarNames("Classifier object saved to: ", sObjectFilePath, "Classifier Object", MATLABClassifier.sExperimentJournalingObjVarName));
                end
                
                if bSaveSummaryFiles
                    sSummaryPdfFilePath = fullfile(Experiment.GetResultsDirectory, "Journalled Summary.pdf");
                    
                    oSummaryPdf = ReportUtils.InitializePDF(sSummaryPdfFilePath);
                    
                    dNumHyperParameters = size(obj.tHyperParameterStates,1);
                    
                    for dHyperParameterIndex=1:dNumHyperParameters
                        chLabel = obj.tHyperParameterStates.sName(dHyperParameterIndex) + ": ";
                        
                        xValue = obj.tHyperParameterStates.c1xTrainingInputValue{dHyperParameterIndex};
                        
                        if (ischar(xValue) && isrow(xValue)) || (isstring(xValue) && isscalar(xValue))
                            if ischar(xValue)
                                chValue = ['''', xValue, ''''];
                            else
                                chValue = ['"', char(xValue), '"'];
                            end
                        elseif isrow(xValue) && (isnumeric(xValue) || islogical(xValue))
                            chValue = num2str(xValue);
                        elseif isempty(xValue)
                            chValue = '[ ]';
                        else
                            chValue = class(xValue);
                        end
                        
                        if obj.tHyperParameterStates.bOptimized(dHyperParameterIndex)
                            chValue = [chValue, '  *'];
                        end
                        
                        oSummaryPdf.add(ReportUtils.CreateParagraphWithBoldLabel(chLabel, chValue));
                    end
                    
                    oSummaryPdf.add(ReportUtils.CreateParagraphWithBoldLabel('* - Set by hyperparameter optimization',''));
                    
                    oSummaryPdf.close();
                    
                    Experiment.AddToReport(ReportUtils.CreateLinkToFile("Classifier construction summary saved to: ", sSummaryPdfFilePath));
                end
                
                Experiment.EndCurrentSubSection();
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
            %  NameValueArgs: This is an optional parameter pair.
            %           Allowable pairs:  'JournalingOn',true   (default)  OR 'JournalingOn',false
            %           This parameter is only used if the Experiment class is used to run
            %           a script using this method. It is used for controlling whether information
            %           about the method is automatically logged in the experiment output PDF.
            %           We recommend that you don't turn it off unless you want to skip logging information.

            %
            % OUTPUTS ARGUMENTS:
            %  oTrainedClassifier: input classifier object modified to hold a TrainedClassifier
            %           property that represents the trained model. This is necessary for Guess to
            %           work.
            
            % Primary Author: Salma Dammak
            % Created: 2019
            
            arguments
                obj
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            if numel(unique(oLabelledFeatureValues.GetLabels())) ~= 2
                error("MATLABClassifier:Train:NotTwoLabels","This function is built for binary classification only. "+...
                    "The Labelled Feature Values you provide must have eaxctly two unique labels.")
            end
            
            % Change labels to integer 0s and 1s
            viChangedLabels = oLabelledFeatureValues.GetChangedLabels(int16(1),int16(0)); % (positive,negative)
            
            % Set categorical variables
            vbIsCategorical = oLabelledFeatureValues.IsFeatureCategorical();
            
            dCategoricalPredictorsIndex = find(obj.tHyperParameterStates.sName == "CategoricalPredictors");
            
            if ~isempty(dCategoricalPredictorsIndex)            
                obj.tHyperParameterStates.c1xTrainingInputValue{dCategoricalPredictorsIndex} = find(vbIsCategorical);
            elseif any(vbIsCategorical)
                warning(...
                    'MATLABClassifier:Train:CategoricalPredictorsCouldNotBeSet',...
                    'The training set passed contains one or more features that are marked as categorical, but this could not be indicated to the classifier as the hyper-parameter "CategoricalPredictors" was not in the hyper-parameter list provided to the classifier on construction. Please add this hyper-parameter, but leave its value as ''[]''.');
            end
            
            % Create a name/value array from the hyperparameters table
            dNumberOfFilledInParameters = sum(cellfun(@(c) ~isempty(c),obj.tHyperParameterStates.c1xTrainingInputValue));
            c1xParameters = cell(1,2*dNumberOfFilledInParameters);
            dParametersCounter = 1;
            
            for dRow = 1:size(obj.tHyperParameterStates,1)
                if ~isempty(obj.tHyperParameterStates.c1xTrainingInputValue{dRow})
                    c1xParameters{dParametersCounter} = obj.tHyperParameterStates.sName{dRow};
                    c1xParameters{dParametersCounter + 1} = obj.tHyperParameterStates.c1xTrainingInputValue{dRow};
                    dParametersCounter = dParametersCounter + 2;
                end
            end
            
            dtStartTime = datetime(now, 'ConvertFrom', 'datenum');
            obj.oTrainedClassifier = obj.hClassifier(oLabelledFeatureValues.GetFeatures(),double(viChangedLabels),c1xParameters{:},'ClassNames',[0 1]);
            dtEndTime = datetime(now, 'ConvertFrom', 'datenum');
            
            obj = SetHyperParameterStatesColumnsWithModelValues(obj, obj.oTrainedClassifier, "Training");
            ValidateHyperParameterStatesAfterTraining(obj);
            
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
        
        
        function oGuessingResults = Guess(obj, oLabelledFeatureValues, NameValueArgs)
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
            bRemoveNaNConfidenceResults = false;
            
            oGuessingResults = obj.Guess_OptionalDuplicatedSamplesValidationOverrideAndNaNRemoval(oLabelledFeatureValues, NameValueArgs.JournalingOn, bOverrideDuplicatedSamplesValidation, bRemoveNaNConfidenceResults);            
        end
        
        
        
        
        %%>>>>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        function oHyperParameterOptimizer = GetHyperParameterOptimizer(obj)
            %oHyperParameterOptimizer = GetHyperParameterOptimizer(obj)
            %
            % SYNTAX:
            %  oHyperParameterOptimizer = obj.GetHyperParameterOptimizer()
            %
            % DESCRIPTION:
            %  Returns the hyper-parameter optimizer used to optimize the
            %  classifer's hyper-parameters. Use this function to access
            %  information about the hyper-parameter optimization process
            %
            % INPUT ARGUMENTS:
            %  obj: Classifier object
            %
            % OUTPUTS ARGUMENTS:
            %  oHyperParameterOptimizer:
            %   HyperParameterOptimizer object or empty (if no
            %   hyper-parameter optimization was performed
            
            oHyperParameterOptimizer = obj.oHyperParameterOptimizer;
        end 
        
        function tHyperParameters = GetHyperParametersFromUserInput(obj)   
            %tHyperParameters = GetHyperParametersFromUserInput(obj)  
            %
            % SYNTAX:
            %  tHyperParameters = obj.GetHyperParametersFromUserInput()  
            %
            % DESCRIPTION:
            %  Returns the hyper-parameter table that was provided to the
            %  classifier object constructor by the user. This can be used
            %  for auditing how a classifier object was constructed, or for
            %  constructing a new classifier object with similiar/identical
            %  hyper-parameters.
            %
            % INPUT ARGUMENTS:
            %  obj: Classifier object
            %
            % OUTPUTS ARGUMENTS:
            %  tHyperParameters:
            %   Table containing the hyper-parameter names, values,
            %   optimization settings, and names within MATLab objects
            
            arguments
                obj (1,1) MATLABClassifier
            end            
            
            vsTableVarNames = string(obj.tHyperParameterStates.Properties.VariableNames);
            
            vdColumnsToSelect = [
                find(vsTableVarNames == "sName")
                find(vsTableVarNames == "c1xUserInputValue")
                find(vsTableVarNames == "bOptimize")
                find(vsTableVarNames == "c1xOptimizationDomain")
                find(vsTableVarNames == "sNameInModel")];
            
            tHyperParameters = obj.tHyperParameterStates(:,vdColumnsToSelect);
            tHyperParameters.Properties.VariableNames = ["sName", "c1xValue", "bOptimize", "c1xOptimizationDomain", "sModelParameterName"];            
        end
        
        function tHyperParameters = GetHyperParametersForTraining(obj)
            %tHyperParameters = GetHyperParametersForTraining(obj)  
            %
            % SYNTAX:
            %  tHyperParameters = obj.GetHyperParametersForTraining()  
            %
            % DESCRIPTION:
            %  Returns a table containing the names of the hyper-parameters
            %  and the value for each as it was/will be passed into the MATLab
            %  function at training time. If hyper-parameter
            %  optimization wasn't performed, these values will match what the
            %  user provided at construction (though some minor necessary
            %  sanitation may have been performed). If hyper-parameter
            %  optimization was performed, these values will be a
            %  combination of user provided values from construction (e.g.
            %  the hyper-parameters that were not optimized), and the
            %  results from hyper-parameter optimization (e.g. the
            %  "optimal" value for the hyper-parameters that were
            %  optimized).
            %  Hyper-parameters with empty values represent
            %  hyper-parameters that were not assigned values by the user
            %  or hyper-parameter optimization. MATLab will assign default
            %  values for these hyper-parameters when obj.Train is called.
            %  Use obj.GetHyperParameterAfterTraining to observe these
            %  default values.
            %
            % INPUT ARGUMENTS:
            %  obj: Classifier object
            %
            % OUTPUTS ARGUMENTS:
            %  tHyperParameters:
            %   Table containing the hyper-parameter names and values
            
            arguments
                obj (1,1) MATLABClassifier
            end
            
            vsTableVarNames = string(obj.tHyperParameterStates.Properties.VariableNames);
            
            vdColumnsToSelect = [
                find(vsTableVarNames == "sName")
                find(vsTableVarNames == "c1xTrainingInputValue")];
            
            tHyperParameters = obj.tHyperParameterStates(:,vdColumnsToSelect);
            tHyperParameters.Properties.VariableNames = ["sName", "c1xValue"];  
        end
        
        function tHyperParameters = GetHyperParametersAfterTraining(obj)
            %tHyperParameters = GetHyperParametersAfterTraining(obj)  
            %
            % SYNTAX:
            %  tHyperParameters = obj.GetHyperParametersAfterTraining()  
            %
            % DESCRIPTION:
            %  Returns a table containing the names of the hyper-parameters
            %  and the value for each as it is/was used in the trained
            %  classifier. If you're wondering what the value of the
            %  hyper-parameters are for a classifier that you're using to
            %  predict/guess with, this function gives you those values.
            %  The classifier object must be trainied for this function to
            %  be called.
            %
            % INPUT ARGUMENTS:
            %  obj: Classifier object
            %
            % OUTPUTS ARGUMENTS:
            %  tHyperParameters:
            %   Table containing the hyper-parameter names and values
            
            arguments
                obj (1,1) MATLABClassifier {MustBeTrained(obj)}
            end
            
            vsTableVarNames = string(obj.tHyperParameterStates.Properties.VariableNames);
            
            vdColumnsToSelect = [
                find(vsTableVarNames == "sName")
                find(vsTableVarNames == "c1xTrainingResult")];
            
            tHyperParameters = obj.tHyperParameterStates(:,vdColumnsToSelect);
            tHyperParameters.Properties.VariableNames = ["sName", "c1xValue"];              
        end

    end % methods
    
    
    
    % *********************************************************************
    % *                         PROTECTED METHODS                         *
    % *********************************************************************
    
    methods (Access = {?MATLABClassifier, ?HyperParameterOptimizer,...
            ?MATLABClassifierReproducibilityObjectiveFunction})
        
        function hClassifierHandle = GetClassifierHandle(obj)
            %hClassifierHandle = GetClassifierHandle(obj)
            %
            % SYNTAX:
            %  hClassifierHandle = GetClassifierHandle(obj)
            %
            % DESCRIPTION:
            %  A function to get the stored function handle for the Classifier
            %
            % INPUT ARGUMENTS:
            %  obj: the Classifier object
            %
            % OUTPUTS ARGUMENTS:
            %  hClassifierHandle: returns the property hClassifier which
            %           holds the stored function handle for the classifier
            
            % Primary Author: Carol Johnson
            % Created: Sep 24, 2019
            
            hClassifierHandle = obj.hClassifier;
        end
        
        function vsNames = GetHyperParameterStatesNames(obj)
            vsNames = obj.tHyperParameterStates.sName;
        end
        
        function vbOptimize = GetHyperParameterStatesOptimize(obj)
            vbOptimize = obj.tHyperParameterStates.bOptimize;
        end
        
        function c1xOptimizationDomain = GetHyperParameterStatesOptimizationDomain(obj)
            c1xOptimizationDomain = obj.tHyperParameterStates.c1xOptimizationDomain;
        end
        
        function c1xValues = GetHyperParameterStatesSantizedUserInputValues(obj)
            c1xValues = obj.tHyperParameterStates.c1xSanitizedUserInputValue;
        end   
    end
    
    
    methods (Access = protected)
        function obj = SetHyperParameterStatesOptimizableFlag(obj)
            
            try
                % get hyperparameters for the optimizing function
                % All we need from this call is the list of optimizable
                % hyperparameters for the classifier. However, to get that
                % we are forced to give it data and labels. Here were are
                % using dummy data [1] and [1] to give us the information
                % we need since all we need is a list of names.
                voOptimizeableHyperParams = hyperparameters(func2str(obj.hClassifier),[1],[1]);
                
            catch
                % MATLAB errors out on the hyperparameters() call if given an unoptimizable classifier,
                % in that case, we want to catch that error and just not
                % set any "bOptimizable" flags to true.
                voOptimizeableHyperParams = [];
            end
            
            
            vbOptimizable = false(size(obj.tHyperParameterStates,1),1);
            
            for dOptimizeableHyperParamIndex=1:length(voOptimizeableHyperParams)
                oOptimizeableHyperParam = voOptimizeableHyperParams(dOptimizeableHyperParamIndex);
                chHyperParameterName = oOptimizeableHyperParam.Name;
                dIdx = find(arrayfun(@(x)strcmp(x,chHyperParameterName),obj.tHyperParameterStates{:,'sName'}));
                
                if isempty(dIdx)
                    error("MATLABClassifier:SetHyperParameterStatesOptimizableFlag:OptimizableParameterNotInInputTable",...
                        "An optimizable hyperparameter is not listed in the "...
                        + "hyperparameters table you input. The hyperparameter is "...
                        + chHyperParameterName + ". Please add it to the table "...
                        + "and try again. Note that this error often occurs when you input the "...
                        + "incorrect hyper-parameters table for the classifier you are building.");
                end
                
                vbOptimizable(dIdx) = true;
            end
            
            obj.tHyperParameterStates.bOptimizable = vbOptimizable;
        end
        
        % Optimize hyperparameters
        function obj = ImplementationSpecificOptimizeHyperparameters(obj, NameValueArgs)
            %obj = ImplementationSpecificOptimizeHyperparameters(obj, NameValueArgs)
            %
            % SYNTAX:
            %  obj = ImplementationSpecificOptimizeHyperparameters(obj)
            %
            % DESCRIPTION:
            %  This function is called by the Classifier super class
            %  constructor. Based on the type of classifier that was created
            %  (eg. MATLABfitcknn), the OptimizeParameters function for
            %  that classifier is called.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Class object
            %
            % Primary Author: Carol Johnson
            % Created: March  2019
            % Modified: Sept 2019 ; C.Johnson; Updated documentation
            
            arguments
                obj
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            ValidateHyperParameterStatesForOptimization(obj)
            
            % Optimize the parameters using the specific functions for type
            % of MATLAB classifier that was created. (eg. MATLABfitcknn)
            [obj.oHyperParameterOptimizer, oModel, oHyperparameterOptimizationResults] = obj.oHyperParameterOptimizer.OptimizeParameters(obj, 'JournalingOn', NameValueArgs.JournalingOn);
            
            % After optimization, get the optimized values and store these
            % in the classifier object.
            obj = obj.SetHyperParameterStatesOptimizationColumns(oModel, oHyperparameterOptimizationResults);
            
            % Validate
            ValidateHyperParameterStatesAfterOptimization(obj);
        end
        
        function obj = IntializeHyperParameterStatesTable(obj,tHyperParametersFromFile)
            
            % Additional Validation
            if ~any(string(tHyperParametersFromFile.Properties.VariableNames) == "sModelParameterName") || ~isa(tHyperParametersFromFile.sModelParameterName,'string') 
                error("MATLABClassifier:IntializeHyperParameterStatesTable:InvalidTable",... 
                    "The sModelParameterName column in tHyperParameters must exist and be of string type.") 
            end 
            
            dNumRows = size(tHyperParametersFromFile,1);
            dNumColumns = length(obj.vsHyperParameterStatesTableHeaders);
            
            % Initialize empty table
            obj.tHyperParameterStates =  table('Size',[dNumRows dNumColumns],...
                'VariableTypes',obj.vsHyperParameterStatesTableColumnTypes,...
                'VariableNames', obj.vsHyperParameterStatesTableHeaders);
            
            % Get user inputs
            obj.tHyperParameterStates.sName = tHyperParametersFromFile.sName;
            obj.tHyperParameterStates.sNameInModel = tHyperParametersFromFile.sModelParameterName;
            obj.tHyperParameterStates.c1xUserInputValue = tHyperParametersFromFile.c1xValue;
            obj.tHyperParameterStates.bOptimize = tHyperParametersFromFile.bOptimize;
            obj.tHyperParameterStates.c1xOptimizationDomain = tHyperParametersFromFile.c1xOptimizationDomain;
        end
        
        function obj = SanitizeUserInputs(obj)
            obj.tHyperParameterStates.c1xSanitizedUserInputValue = obj.tHyperParameterStates.c1xUserInputValue;
            
            % For classifiers that require a score transform, check if the user set anything, and if
            % not, set to logit. The score transform affects how the confidences that come out of
            % Guess should be interpreted, and logit is the transform that makes the most sense in our
            % applications which is why we override whatever default MATLAB has to Logit. However, if
            % the user specifically wants to modify this, they can at their own risk.
            
            % Identify where the ScoreTransform parameter index is in the list of parameters, if there is one
            vdIdx = find(arrayfun(@(x)strcmp(x,"ScoreTransform"),obj.tHyperParameterStates{:,'sName'}));
            
            % If the parameter exists, and only exists once, proceed
            if ~isempty(vdIdx) && (length(vdIdx) == 1)
                
                % If no transform was defined, set logit and send warning,otherwise, leave as-is
                if isempty(obj.tHyperParameterStates.c1xUserInputValue{vdIdx})
                    % if the user did not specify a transform, set to
                    % 'logit'
                    warning('MATLABClassifier:Constructor:UnsupportedParameter',...
                        "You did not specify a Score Transform which is " ...
                        + "necessary to convert scores into complimentary confidences. "...
                        + "This classifier will default to the 'logit' transform instead." );
                    obj.tHyperParameterStates.c1xSanitizedUserInputValue{vdIdx} = 'logit';
                end
                
                % Error out if more than one score transform was set
            elseif ~isempty(vdIdx) && (length(vdIdx) ~= 1)
                sMsg = "The ScoreTransform hyperparameter appears more than once in the parameter "...
                    +"template. This is not allowed. Remove duplicates and try again.";
                chMsg = char(sMsg);
                error('MATLABClassifier:Constructor:UnsupportedParameter', chMsg);
            end
        end
        
        function ValidateHyperParameterStatesForOptimization(obj)
            vbOptimizable = obj.tHyperParameterStates.bOptimizable;
            vbOptimize = obj.tHyperParameterStates.bOptimize;
            
            if all(obj.tHyperParameterStates.bOptimizable == 0)
                error("MATLABClassifier:ValidateHyperParameterStatesForOptimization",...
                    "The classifier you chose does not have any optimizable hyperparameters but you input an optimizer in the classifier consructor call and/or set some flags to optimize. Please read MATLAB documentation and try again.")
                
            elseif all(obj.tHyperParameterStates.bOptimize == 0)
                error("MATLABClassifier:ValidateHyperParameterStatesForOptimization",...
                    "None of the bOptimize flags were set to true even though you gave an optimization object in construction of this classifier. "...
                    +"Either remove the optimization object or set some flags to true.");
                
            elseif  any(vbOptimize == 1 & vbOptimizable == 0)
                error("MATLABClassifier:ValidateHyperParameterStatesForOptimization",...
                    "One or more of the hyperparameters you set to optimize is not optimizable.");
            end
        end
        
        function obj = ValidateHyperParameterStatesAfterOptimization(obj)
            c1xSanitizedUserInputValue = obj.tHyperParameterStates.c1xSanitizedUserInputValue;
            vbOptimize = obj.tHyperParameterStates.bOptimize;
            vbOptimized = obj.tHyperParameterStates.bOptimized;
            vbOptimizationResultExists = obj.tHyperParameterStates.bOptimizationResultExists;
            c1xOptimizationResult = obj.tHyperParameterStates.c1xOptimizationResult;
            
            bUserSetValueChangedUnexpectantly = 0;
            
            for iRowInTable = 1:size(obj.tHyperParameterStates)
                % If bOptimized is 0 AND, c1xUserSant is NOT empty, AND
                % c1xOptResults != c1xUserSant then warning
                if (vbOptimized(iRowInTable) == 0)...
                        && (~isempty(c1xSanitizedUserInputValue{iRowInTable})...
                        && ~isequal(c1xOptimizationResult{iRowInTable}, c1xSanitizedUserInputValue{iRowInTable}))
                    bUserSetValueChangedUnexpectantly = 1;
                    break;
                end
            end
            
            if any(vbOptimize == 0 & vbOptimized == 1)
                error("MATLABClassifier:ValidateHyperParameterStatesForOptimization:NotRequestedOptimizeOptimized",...
                    "One of the hyperparameters you did not request to optimize was optimized by MATLAB. This is strange behaviour on the part of MATLAB and deeper investigation is required to figure out how to stop it.")
            elseif any (vbOptimize == 1 & vbOptimized == 0)
                warning("MATLABClassifier:ValidateHyperParameterStatesForOptimization:RequestedToOptimizeNotOptimized",...
                    "One or more of the hyperparameters you requested to optimize was not optimized by MATLAB. "...
                    +"One of the cases in which this occurs is if one parameter was optimized in a way that makes another parameter irrelavent or fixed "...
                    +"an example of this is if Kernel is optimized, then PolynomialOrder becomes irrelavent unless the kernel chosen was a polynomial. "...
                    +"Another reason this might happen is due to a bigger issue in MATLAB code where it ignored the instructions to optimize, this will need further investigation on your part.");
            elseif any(~vbOptimizationResultExists)
                error("MATLABClassifier:ValidateHyperParameterStatesForOptimization:OneOrMoreParametersYouSpecifiedDoesNotExist",...
                    "One or more of the parameters you listed in the table was not found in the post-optimization model. "....
                    +"Common reasons for this are spelling mistakes in hyperparameter names, using a hyperparameter input table that doesn't match "...
                    +"the classifier, and using a version on MATLAB incompatible with the version of BOLT.");
            elseif bUserSetValueChangedUnexpectantly
                warning("MATLABClassifier:ValidateHyperParameterStatesForOptimization:UserSetValueChangedUnexpectantly",...
                    "One or more of that values you set in the model was changed after optimization even though you did not "...
                    +"request for it to be optimized. The first parameter encountered that did that is "...
                    + obj.tHyperParameterStates.sName(iRowInTable)+".")
            end
        end
        
        function ValidateHyperParameterStatesAfterTraining(obj)
            c1xTrainingInputValue = obj.tHyperParameterStates.c1xTrainingInputValue;
            c1xTrainingResult = obj.tHyperParameterStates.c1xTrainingResult;
            vbTrainingResultExists = obj.tHyperParameterStates.bTrainingResultExists;
            
            if any(vbTrainingResultExists == 0)
                error("MATLABClassifier:ValidateHyperParameterStatesAfterTraining:UserSetValueChangedUnexpectantly",...
                    "One or more of the parameters you listed in the table was not found in the post-training model. "....
                    +"Common reasons for this are spelling mistakes in hyperparameter names, using a hyperparameter input table that doesn't match "...
                    +"the classifier, and using a version on MATLAB incompatible with the version of this library.");
            end
            
            for dRowIntable = 1:size(obj.tHyperParameterStates,1)
                
                % Assign the values to compare to new variables for easy readability
                xTrainingInput = c1xTrainingInputValue{dRowIntable};
                xTrainingResult = c1xTrainingResult{dRowIntable};
                
                % Sometimes MATLAB changes the capitalization of input (e.g. pseudolinear -->
                % pseudoLinear). This is a trivial change that we don't want to result in a warning,
                % by changing the inputs to lower case, we can ensure that the warning check doesn't
                % trip up on capitalization differences.
                if (ischar(xTrainingInput) && ischar(xTrainingResult))
                    xTrainingInput = lower(xTrainingInput);
                    xTrainingResult = lower(xTrainingResult);
                end
                
                % If the input value changed from what the user specified and the user did specify a value
                if ~isequal(xTrainingInput,xTrainingResult) && ~isempty(xTrainingInput)
                    warning("MATLABClassifier:ValidateHyperParameterStatesAfterTraining:UserSetValueChangedUnexpectantly",...
                        "One of the values you set in the model was changed after training. "...
                        + "This is uexpected behaviour and it is recommended you investigate it. "...
                        + "The parameter that changed is " + obj.tHyperParameterStates.sName{dRowIntable} + ".");
                end
            end
        end
        function obj = SetHyperParameterStatesColumnsWithModelValues(obj, oMatlabClassifierModel, sOptimizationOrTraining)
            % set column names based on optimization or training
            switch sOptimizationOrTraining
                case "Optimization"
                    sLowLevelResultColumnName = "c1xOptimizationLowLevelResultFromModel";
                    sLowLevelResultExistsColumnName = "bOptimizationLowLevelResultFromModelExists";
                    sHighLevelResultColumnName = "c1xOptimizationHighLevelResultFromModel";
                    sHighLevelResultExistsColumnName = "bOptimizationHighLevelResultFromModelExists";
                    sResultColumnName = "c1xOptimizationResult";
                    sResultExistsColumnName = "bOptimizationResultExists";
                case "Training"
                    sLowLevelResultColumnName = "c1xTrainingLowLevelResultFromModel";
                    sLowLevelResultExistsColumnName = "bTrainingLowLevelResultFromModelExists";
                    sHighLevelResultColumnName = "c1xTrainingHighLevelResultFromModel";
                    sHighLevelResultExistsColumnName = "bTrainingHighLevelResultFromModelExists";
                    sResultColumnName = "c1xTrainingResult";
                    sResultExistsColumnName = "bTrainingResultExists";
                otherwise
                    error(...
                        'MATLABClassifier:SetHyperParameterStatesColumnsWithModelValues:InvalidOptimizationOrTrainingFlag',...
                        'sOptimizationOrTraining must be "Optimization" or "Training".');
            end
            
            % loop through each row/hyperparameter
            for dTableRowIndex=1:size(obj.tHyperParameterStates,1)
                
                % for each hyper parameter, get the stored model value
                sModelParameterName = obj.tHyperParameterStates.sNameInModel(dTableRowIndex);
                
                % get values from Matlab model object
                [bLowLevelParamFound, c1xLowLevelValue] = ...
                    MATLABClassifier.GetHyperParameterValueFromMATLABClassifierModel(oMatlabClassifierModel,...
                    sModelParameterName, "LowLevel" );
                [bHighLevelParamFound, c1xHighLevelValue] = ...
                    MATLABClassifier.GetHyperParameterValueFromMATLABClassifierModel(oMatlabClassifierModel,...
                    sModelParameterName, "HighLevel" );
                
                % set values and whether they existed into the column names
                % provided
                if bLowLevelParamFound
                    obj.tHyperParameterStates.(sLowLevelResultColumnName){dTableRowIndex} = c1xLowLevelValue;
                end
                
                obj.tHyperParameterStates.(sLowLevelResultExistsColumnName)(dTableRowIndex) = bLowLevelParamFound;
                
                if bHighLevelParamFound
                    obj.tHyperParameterStates.(sHighLevelResultColumnName){dTableRowIndex} = c1xHighLevelValue;
                end
                
                obj.tHyperParameterStates.(sHighLevelResultExistsColumnName)(dTableRowIndex) = bHighLevelParamFound;
                
                % determine if the value was found
                bParamWasValueFoundInModel = bLowLevelParamFound || bHighLevelParamFound;
                obj.tHyperParameterStates.(sResultExistsColumnName)(dTableRowIndex) = bParamWasValueFoundInModel;
                
                % result is low level value if it exists, high level
                % otherwise
                if bLowLevelParamFound
                    obj.tHyperParameterStates.(sResultColumnName){dTableRowIndex} = c1xLowLevelValue;
                elseif bHighLevelParamFound
                    obj.tHyperParameterStates.(sResultColumnName){dTableRowIndex} = c1xHighLevelValue;
                end
            end
            
        end % function
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = ?MATLABClassifierReproducibilityObjectiveFunction)
        
        function c1xNameValuePairs = GetHyperParametersNameValuePairs(obj)
            
            vsNames = obj.GetHyperParameterStatesNames();
            c1xSantizedUserInputValues = obj.GetHyperParameterStatesSantizedUserInputValues();
            
            % The number of locked down params will be the parameters that:
            % are set to not optimize AND that are non-empty
            dNumLockedDownParams = sum(cellfun(@(c) ~isempty(c),c1xSantizedUserInputValues));
            
            c1xNameValuePairs = cell(1,dNumLockedDownParams);
            dLockDownIndexCounter = 1;
            
            dNumHyperParameters = length(vsNames);
            
            % loop through all hyperparameters in the classifer
            for dRow = 1:dNumHyperParameters
                sParamName = vsNames(dRow);
                
                if ~isempty(c1xSantizedUserInputValues{dRow})
                    c1xNameValuePairs{dLockDownIndexCounter} = sParamName;
                    c1xNameValuePairs{dLockDownIndexCounter+1} = c1xSantizedUserInputValues{dRow};
                    
                    dLockDownIndexCounter = dLockDownIndexCounter + 2;
                end
            end
        end
    end
    
    
    methods (Access = {?KFoldCrossValidationUtils, ?Classifier})
        
        function oGuessingResults = GuessAllowDuplicatedSamples(obj, oLabelledFeatureValues, NameValueArgs)
            arguments
                obj
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            bOverrideDuplicatedSamplesValidation = true;
            bRemoveNaNConfidenceValues = true;
            
            oGuessingResults = obj.Guess_OptionalDuplicatedSamplesValidationOverrideAndNaNRemoval(oLabelledFeatureValues, NameValueArgs.JournalingOn, bOverrideDuplicatedSamplesValidation, bRemoveNaNConfidenceValues); 
        end
    end
    
    
    methods (Access = private)
        
        function oGuessingResults = Guess_OptionalDuplicatedSamplesValidationOverrideAndNaNRemoval(obj, oLabelledFeatureValues, bJournalingOn, bOverrideDuplicatedSamplesValidation, bRemoveNaNConfidences)
                        
            arguments
                obj
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                bJournalingOn (1,1) logical
                bOverrideDuplicatedSamplesValidation (1,1) logical
                bRemoveNaNConfidences (1,1) logical = false
            end
            
            dtStartTime = datetime(now, 'ConvertFrom', 'datenum');
            [~,m2dScores] = predict(obj.oTrainedClassifier, oLabelledFeatureValues.GetFeatures());
            dtEndTime = datetime(now, 'ConvertFrom', 'datenum');
            
            if bRemoveNaNConfidences            
                vbIsNan = isnan(m2dScores(:,1));
                
                if all(vbIsNan)
                    error("MATLABClassifier:Guess_OptionalDuplicatedSamplesValidationOverrideAndNaNRemoval:AllNaNConfidences",...
                        "The confidences the classifier produced all NaNs. "+...
                        "This is often caused by not standardizing feature values and passing them to "+...
                        "a classifier that needs them to be standardized.");
                end
                
                if any(vbIsNan)
                    warning("MATLABClassifier:Guess_OptionalDuplicatedSamplesValidationOverrideAndNaNRemoval:NaNConfidencesRemoved",...
                        "NaN confidence values were found and so were removed since bRemoveNaNConfidences was set to true.");
                end
                
                m2dScores = m2dScores(~vbIsNan,:);
                oLabelledFeatureValues = oLabelledFeatureValues(~vbIsNan,:);
            end
            
            vdPositiveLabelConfidences = m2dScores(:,2); % Made to only pull confidence of positive label
            
            if any(isnan(vdPositiveLabelConfidences))
                error("MATLABClassifier:Guess:NaNConfidences",...
                    "The confidences the classifier produced contain at least one NaN. "+...
                    "This is often caused by not standardizing feature values and passing them to "+...
                    "a classifier that needs them to be standardized.");
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
        
        function obj = SetHyperParameterStatesTrainingInputValue(obj)
            
            vbOptimize = obj.tHyperParameterStates.bOptimize;
            vbOptimized = obj.tHyperParameterStates.bOptimized;
            c1xOptimizationResult = obj.tHyperParameterStates.c1xOptimizationResult;
            
            obj.tHyperParameterStates.c1xTrainingInputValue = obj.tHyperParameterStates.c1xSanitizedUserInputValue;
            
            % The only time we want to pick up the optimization result is if the user asked to opimize it and it as indeed optimized
            vbIndexForUseableOptimizationResults = (vbOptimize == 1 & vbOptimized == 1);
            
            obj.tHyperParameterStates.c1xTrainingInputValue(vbIndexForUseableOptimizationResults)...
                = c1xOptimizationResult(vbIndexForUseableOptimizationResults);
            
        end
        
        function obj = SetHyperParameterStatesOptimizationColumns(obj, oMATLABClassifierModel, oHyperparameterOptimizationResults)
            % set the low level, high level, and result value and exists
            % column based upon the values with the MATLAB classifier model
            % object
            obj = SetHyperParameterStatesColumnsWithModelValues(obj, oMATLABClassifierModel, "Optimization");
            
            % Set the table bOptimized column by initializing all to false
            % and then using oHyperparameterOptimizationResults to figure
            % out with hyperparameters were optimized (set to true)
            obj.tHyperParameterStates.bOptimized = false(size(obj.tHyperParameterStates,1),1);
            
            voOptimizeableHyperParams = oHyperparameterOptimizationResults.VariableDescriptions;
            
            for dHyperParamIndex = 1: size(voOptimizeableHyperParams,1)
                if voOptimizeableHyperParams(dHyperParamIndex).Optimize % was the hyperparameter optimized?
                    % if it was optimized, let's search for the variable
                    % name in the tHyperParameterStates
                    dIdxTable = find(strcmp(obj.tHyperParameterStates.sName,...
                        voOptimizeableHyperParams(dHyperParamIndex).Name));
                    
                    if isempty(dIdxTable)
                        error(...
                            'MATLABClassifier:SetHyperParameterStatesOptimizationColumns:OptimizedHyperParameterNotFoundInTable',...
                            ['The optimized hyperparameter "', voOptimizeableHyperParams.Name, '" was not found within the hyperparameter table within the MATLABClassifier object. This means that a hyperparameter exists within MATLAB''s classifier that was not in the list of hyperparameters set by the user, and yet was somehow still optimized. This would be very strange behaviour for MATLAB to take, so an investigation into why this occuring is recommended.']);
                    else
                        obj.tHyperParameterStates.bOptimized(dIdxTable) = true;
                    end
                end
            end
        end
        
        function MustBeTrained(obj)
            if isempty(obj.oTrainedClassifier)
                error(...
                    'MATLABClassifier:MustBeTrained:Invalid',...
                    'The classifier is not yet trained.');
            end
        end
    end
    
    
    methods (Access = private, Static = true)
        
        %%>>>>>>>>>>>>>>>
        function [bParamFound, c1xModelValue] = GetHyperParameterValueFromMATLABClassifierModel(oModel, sModelParamName, sModelLevel)
            
            %   NOTE:   High level parameters reflect the values that were
            %           determined by the current sample set (if model was
            %           created using a tuning set, the high level 
            %           parameters reflect ideal values for the tuning set).
            %           The low-level parameters are then carried forward
            %           for the next stage (which may be training) high 
            %           level parameters reflect the values that were
            %           determined by the current sample set (if model was
            %           created using a tuning set, the high level
            %           parameters reflect ideal values for the tuning set).
            %           The low-level parameters are then carried forward
            %           for the next stage (which may be training).
            %
            %       Eg. differing inputs for fitcnb classifier, parameter Kernel
            %               User Input            Low Level               High Level
            %          --------------------|--------------------------|---------------------
            %                 []           |      'normal'            |  ['normal','normal']
            %       ['normal',' triangle'] |  ['normal',' triangle']  |  ['normal',' triangle']
            %            ['triangle']      |      'triangle'          |  ['triangle',' triangle']
            %             
            %
            
            c1xModelValue = {};
            bParamFound = false;
            
            % search the fields at the requested level
            if strcmp(sModelLevel,"LowLevel")
                c1sFieldNames = fieldnames(oModel.ModelParameters);
            elseif strcmp(sModelLevel,"HighLevel")
                c1sFieldNames = fieldnames(oModel);
            end
            
            vsFields = find(strcmp(c1sFieldNames,sModelParamName));
            
            for dIndex = 1:size(vsFields,1)
                if strcmp(string(c1sFieldNames(vsFields(dIndex))),sModelParamName)
                    if strcmp(sModelLevel,"LowLevel")
                        c1xModelValue = oModel.ModelParameters.(sModelParamName);
                    elseif strcmp(sModelLevel,"HighLevel")
                        c1xModelValue = oModel.(sModelParamName);
                    end
                    
                    bParamFound = true;
                end
            end
        end
        
        
    end     % methods
    
    
    methods (Access = {?MATLABBayesianHyperParameterOptimizer,?MATLABClassifier})
        
        function voOptimizableVariables = GetOptimizableVariables(obj, oLabelledFeatureValues)
            voOptimizableVariables = hyperparameters(char(obj.hClassifier), oLabelledFeatureValues.GetFeatures(), double(oLabelledFeatureValues.GetChangedLabels(uint8(1),uint8(0))));
            
            vsParameterNames = obj.tHyperParameterStates.sName;
            vsModelParameterNames = obj.tHyperParameterStates.sNameInModel;
            
            dNumVariables = length(voOptimizableVariables);
            vbKeepVariable = false(dNumVariables,1);
            
            for dVarIndex=1:dNumVariables
                oOptVar = voOptimizableVariables(dVarIndex);
                
                vdIndices = find(vsParameterNames == oOptVar.Name);
                
                if ~isscalar(vdIndices)
                    vdIndices = find(vsModelParameterNames == oOptVar.Name);
                end
                
                if ~isscalar(vdIndices)
                    error(...
                        'MATLABClassifier:GetOptimizableVariables:VariableNotFoundInHyperParametersTable',...
                        ['The variable name "', oOptVar.Name, '" was not found in the hyper parameter table.']);
                end
                
                dHyperParameterRowIndex = vdIndices(1);
                
                if obj.tHyperParameterStates.bOptimize(dHyperParameterRowIndex)
                    vbKeepVariable(dVarIndex) = true;
                    voOptimizableVariables(dVarIndex).Optimize = true;
                    
                    if ~isempty(obj.tHyperParameterStates.c1xOptimizationDomain{dHyperParameterRowIndex})
                        voOptimizableVariables(dVarIndex).Range = obj.tHyperParameterStates.c1xOptimizationDomain{dHyperParameterRowIndex};
                    end
                end
            end
            
            voOptimizableVariables = voOptimizableVariables(vbKeepVariable);
        end
    end
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)
        
        function ValidateHyperParameterStatesForOptimization_ForUnitTest(obj)
            % ValidateHyperParameterStatesForOptimization_ForUnitTest(obj)
            %
            % SYNTAX:
            % ValidateHyperParameterStatesForOptimization_ForUnitTest(obj)
            %
            % DESCRIPTION:
            %  A function to give the unit tests access to the protected
            %    function ValidateHyperParameterStatesForOptimization
            %
            % INPUT ARGUMENTS:
            %   obj:    object of type MATLABClassifier
            %           The properties of this object includes the
            %           tHyperparametersTableStates which is being
            %           validated
            % OUTPUTS ARGUMENTS:
            
            % Primary Author: Carol Johnson
            % Created: Nov 28, 2019
            
            obj.ValidateHyperParameterStatesForOptimization();
            
        end
        
        function hClassifierHandle = GetClassifierHandle_ForUnitTest(obj)
            % hClassifierHandle = GetClassifierHandle_ForUnitTest(obj)
            %
            % SYNTAX:
            % hClassifierHandle = GetClassifierHandle_ForUnitTest(obj)
            %
            % DESCRIPTION:
            %  A function to give the unit tests access to the protected
            %    function GetClassifierHandle
            %
            % INPUT ARGUMENTS:
            %   obj:    object of type MATLABClassifier
            %
            % OUTPUTS ARGUMENTS:
            %   hClassifierHandle:  the stored function handle for the Classifier
            
            % Primary Author: Carol Johnson
            % Created: Apr. 23, 2021
            
            hClassifierHandle = obj.GetClassifierHandle();
            
        end
        
    end
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)

        function oExpectedTrainedClassifier = CreateExpectedTrainedClassifier_ForUnitTest(testCase)
            %oExpectedTrainedClassifier = CreateExpectedTrainedClassifier_ForUnitTest(testCase)
            %
            % SYNTAX:
            %  oExpectedTrainedClassifier = CreateExpectedTrainedClassifier_ForUnitTest(testCase)
            %
            % DESCRIPTION:
            %   A trained classifier object generated by a direct call to
            %   MATLAB (not through BOLT functions) is created and stored
            %   for comparison to the BOLT generated trained classifier.
            %
            % INPUT ARGUMENTS:
            %  testCase: unit test object
            %
            % OUTPUTS ARGUMENTS:
            %   oExpectedTrainedClassifier: trained classifier object
            %       created using direct call to MATLAB functions
            
            
            
            %%%%%% Expected trained classifier model: From direct call to MATLAB training
            
            % set up for direct MATLAB call
            % inputs required: 
            %       - training set features
            %       - training set labels (must be doubles)
            %       - classifier parameters for training: name,value pairs

            % create handler
            hFitcXXXFunction = str2func(testCase.chFitcFunctionName);
            
            %classifier parameters for training
            % (Get the 'parameters for training' from the BOLT valid
            %  classifier so that training by BOLT and by a direct call to
            %  MATLAB are using the same values.)
            c1xNameValuePairParameters =...
                MATLABClassifier.BuildNameValuePairsFromHyperParametersTable_ForUnitTest(...
                testCase.oValidTrainedClassifier.GetHyperParametersForTraining());
            
            % create expected trained classifier
            oExpectedTrainedClassifier = hFitcXXXFunction(...
                testCase.oTrainingSet.GetFeatures(),...
                double(testCase.oTrainingSet.GetChangedLabels(int16(1),int16(0))),...
                c1xNameValuePairParameters{:},'ClassNames',[0 1]);
            
        end
    
        function c1xNameValuePairs = BuildNameValuePairsFromHyperParametersTable_ForUnitTest(tInputHyperParameters)
            %c1xNameValuePairs = BuildNameValuePairsFromHyperParametersTable(tInputHyperParameters)
            %
            % SYNTAX:
            %  c1xNameValuePairs = BuildNameValuePairsFromHyperParametersTable(tInputHyperParameters)
            %
            % DESCRIPTION:
            %   This function is used to create a cell array of name value
            %   pairs based on values set in the input parameters table.
            %   Empty values are ignored.
            %   This can be used as input to the fitc function optimizer
            %   for classifier construction or for training a fitcXXX
            %   classifier.
            %
            % INPUTS:   tInputHyperParameters: the table of
            %           hyper-parameters to extract sName and c1xValue for
            %           any parameters that have a c1xValue. Any parameters
            %           that have an empty value are ignored
            %
            % OUTPUTS: c1xNameValuePairs: a cell array of 'name',value
            %           pairs
            
            % Primary Author: Carol Johnson
            % Created: May 6, 2021
            % 
            
            % initialize
            c1xNameValuePairs = {};
            dParametersIndexCounter = 1;

            for dRow = 1:size(tInputHyperParameters,1)
                if (~isempty(tInputHyperParameters.c1xValue{dRow}))

                    % add name
                    c1xNameValuePairs{dParametersIndexCounter} = string(tInputHyperParameters.sName{dRow});
                    dParametersIndexCounter = dParametersIndexCounter + 1;

                    % add value
                    c1xNameValuePairs{dParametersIndexCounter} = tInputHyperParameters.c1xValue{dRow};
                    dParametersIndexCounter = dParametersIndexCounter + 1;

                end
            end
            
        end
        
        function c1xExpectedValues = ExtractValuesFromClassifierModel_ForUnitTest(...
                oModel, vsParametersToExtract, tInputHyperParameters)
            %c1xExpectedValues = ExtractValuesFromClassifierModel(
            %   oModel, vsParametersToExtract, tInputHyperParameters)
            %
            % SYNTAX:
            %  c1xExpectedValues = ExtractValuesFromClassifierModel(...
            %   oModel, vsParametersToExtract, tInputHyperParameters)
            %
            % DESCRIPTION:
            %   This function is used to create a cell array of values that
            %   was stored in the classifier model.
            %   MATLAB classifiers store these parameters either at a
            %   high-level (in the Model object) or in the lower-level (in
            %   the Model object's property ModelParameters). 
            %   We use values stored in the property 'ModelParameters'
            %   (the low level) as a priority. If the value doesn't exist
            %   there, then we check the properties of the Model (the high level)
            %
            %   NOTE:   High level parameters reflect the values that were
            %           determined by the current sample set (if model was
            %           created using a tuning set, the high level 
            %           parameters reflect ideal values for the tuning set).
            %           The low-level parameters are then carried forward
            %           for the next stage (which may be training) high 
            %           level parameters reflect the values that were
            %           determined by the current sample set (if model was
            %           created using a tuning set, the high level
            %           parameters reflect ideal values for the tuning set).
            %           The low-level parameters are then carried forward
            %           for the next stage (which may be training).
            %
            %       Eg. differing inputs for fitcnb classifier, parameter Kernel
            %              User Input             Low Level               High Level
            %          --------------------|--------------------------|---------------------
            %                 []           |      'normal'            |  ['normal','normal']
            %       ['normal',' triangle'] |  ['normal',' triangle']  |  ['normal',' triangle']
            %            ['triangle']      |      'triangle'          |  ['triangle',' triangle']
            %             
            %                
            %
            %
            % INPUTS:   oModel: the classifier model object created 
            %           vsParametersToExtract: a vector of strings holding
            %               the parameters of interest to extract from the
            %               model
            %           tInputHyperParameters: the table of
            %               hyper-parameters to that were the input to the
            %               classifier during construction
            %
            % OUTPUTS: c1xExpectedValues: a cell array of values extracted
            %               from the model object for the parameters of
            %               interest
            
            % Primary Author: Carol Johnson
            % Created: May 6, 2021

            
            % Capture unit test defined parameters of interest
            % This ensures the same class stored in the cell gets
            % initialized in the resulting cell array 
            % (Sometimes the cell is initialized with an empty cell,
            % other times, with an empty array of type double or char,
            % etc.)
            c1xExpectedValues = tInputHyperParameters.c1xValue;

            % for each parameter, use the model name to extract the stored value
            for dIndex = 1 : size(vsParametersToExtract,1)
                xValue = {};
                bParameterExists = false;
                
                % check the 'low level' values stored in the property
                %   ModelParameters of the Model object
                % NOTE: For some classifiers, the ModelParameters are
                % stored in a struct (use isfield); Others store it in a
                % class (use isprop)
                if isstruct(oModel.ModelParameters)
                    if isfield(oModel.ModelParameters,vsParametersToExtract(dIndex))
                        xValue = oModel.ModelParameters.(vsParametersToExtract(dIndex));
                        bParameterExists = true;
                    end
                else
                    if isprop(oModel.ModelParameters,vsParametersToExtract(dIndex))
                        xValue = oModel.ModelParameters.(vsParametersToExtract(dIndex));
                        bParameterExists = true;
                    end
                end

                % if not found at lower level parameters...
                if ~bParameterExists
                    % check the 'High level' properties of the Model object
                    if isprop(oModel, vsParametersToExtract(dIndex))
                        xValue = oModel.(vsParametersToExtract(dIndex));
                        bParameterExists = true;
                    end
                end

                % update expected values
                if bParameterExists
                    tRowIndex = find(strcmp(tInputHyperParameters.sModelParameterName,...
                        vsParametersToExtract(dIndex)));
                    c1xExpectedValues(tRowIndex,1) = {xValue};
                end

            end
        end
    end
    
end