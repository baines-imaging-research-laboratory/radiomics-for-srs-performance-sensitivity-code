classdef ForwardWrapperFeatureSelector < WrapperFeatureSelector
    %ForwardWrapperFeatureSelector
    %
    % Class for forward wrapper based feature selection method
    
    
    % Primary Author: Ryan Alfano
    % Created: 03, 13 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Abstract, Access = public)
    end
    
    properties (Access = public)
    end
    
    properties (Access = protected)
    end
        
    properties (Access = private, Constant = false)
    end    
    
    properties (Access = private, Constant = true)        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = ForwardWrapperFeatureSelector(chFeatureSelectionParameterFilePath, oObjectiveFunction)
            %obj = ForwardWrapperFeatureSelector(chFeatureSelectionParameterFilePath, oObjectiveFunction)
            %
            % SYNTAX:
            %  obj = ForwardWrapperFeatureSelector(chFeatureSelectionParameterFilePath, oObjectiveFunction)
            %
            % DESCRIPTION:
            %  Constructor for forward wrapper feature selection.
            %
            % INPUT ARGUMENTS:            
            %  chFeatureSelectionParameterFilePath:
            %   filepath of the feature selection parameters file
            %  oObjectiveFunction:
            %   The objective function to be used to compare sets of
            %   features to one another. The objective function should be
            %   set to be used with a minima optimizer
            %
            % OUTPUTS ARGUMENTS:
            %  -

            % Primary Author: Ryan Alfano
            % Created: 03 13, 2019
            
            arguments
                chFeatureSelectionParameterFilePath (1,:) char
                oObjectiveFunction (1,1) MachineLearningObjectiveFunction {MustBeValidForMinimaOptimization(oObjectiveFunction)}                
            end
            
            % super-class call
            obj@WrapperFeatureSelector(chFeatureSelectionParameterFilePath, oObjectiveFunction);
        end
        
        function newObj = SelectFeatures(obj, oFeatureValues, NameValueArgs)
            % newObj = SelectFeatures(obj)
            %
            % SYNTAX:
            % newObj = obj.SelectFeatures(oFeatureValues, Name, Value)
            %
            % DESCRIPTION:
            %  Performs greedy iterative forward feature selection
            %
            % INPUT ARGUMENTS:
            %  obj: Feature Selector object
            %  oFeatureValues: Feature values object containing all
            %   feature data
            %  NameValueArgs:
            %   'Verbose' - (1,1) logical - Added verbosity in the command
            %   window
            %   'NumFeatures' - (1,1) double {mustBeInteger,
            %   mustBePositive} - Number of features to select when
            %   executed.
            %   'Classifier' - (1,1) Classifier - Classifier to use when
            %   feature selection is executed.
            %   'PreSelectedFeatures' - (1,:) double {mustBeInteger} - Boolean
            %   vector of features to keep when feature selection is
            %   executed.
            %   'JournalingOn' - (1,1) logical - Flag to turn off
            %    journalling (default: true)
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copy of feature selection object.

            % Primary Author: Ryan Alfano
            % Created: 04 09, 2019
            
            arguments
                obj
                oFeatureValues (:,:) FeatureValues
                NameValueArgs.Verbose (1,1) logical = false
                NameValueArgs.NumFeatures (1,1) double {mustBeInteger, mustBePositive} = obj.dNumFeatures
                NameValueArgs.Classifier (1,1) Classifier = obj.oClassifier
                NameValueArgs.PreSelectedFeatures (1,:) double {mustBeInteger} = []
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            % Warn the user of the changed parameters in the function
            % call if verbose is set.
            if NameValueArgs.Verbose && NameValueArgs.NumFeatures ~= obj.dNumFeatures
                warning('ForwardWrapperFeatureSelector:ChangedNumFeatures',['Number of features has been changed by the user and does not match the value stored in the parameters file. Number of features entered: ', num2str(NameValueArgs.NumFeatures) '. Number of features in parameters file: ' num2str(obj.dNumFeatures) '.']);
            end
            
            bUseParfor = false;
                            
            ForwardWrapperFeatureSelector.SelectFeatures_Generalized(obj, oFeatureValues, NameValueArgs, bUseParfor);
            
            % return copy of feature selector object
            % (since FeatureSelector inherits from handle, this allows for
            % this function to be used as an object from handle would
            % typically be used with no output agruments, or as a typical
            % Matlab object, with using a single output)
            newObj = copy(obj);
        end
        
        function SelectFeatures_Parallel(obj, oFeatureValues, NameValueArgs)
            % SelectFeatures_Parallel(obj)
            %
            % SYNTAX:
            % SelectFeatures_Parallel(obj)
            %
            % DESCRIPTION:
            %  Performs greedy iterative forward feature selection using
            %  a parallel server
            %
            % INPUT ARGUMENTS:
            %  obj: Feature Selector object
            %  oFeatureValues: Feature values object containing all
            %   feature data
            %  NameValueArgs:
            %   'Verbose' - (1,1) logical - Added verbosity in the command
            %   window
            %   'NumFeatures' - (1,1) double {mustBeInteger,
            %   mustBePositive} - Number of features to select when
            %   executed.
            %   'Classifier' - (1,1) Classifier - Classifier to use when
            %   feature selection is executed.
            %   'PreSelectedFeatures' - (1,:) double {mustBeInteger} - Boolean
            %   vector of features to keep when feature selection is
            %   executed.
            %   'JournalingOn' - (1,1) logical - Flag to turn off
            %    journalling (default: true)
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copy of feature selection object.
            
            % Primary Author: Ryan Alfano
            % Created: 05 14, 2019
            
            arguments
                obj
                oFeatureValues (:,:) FeatureValues
                NameValueArgs.Verbose (1,1) logical = false
                NameValueArgs.NumFeatures (1,1) double {mustBeInteger, mustBePositive} = obj.dNumFeatures
                NameValueArgs.Classifier (1,1) Classifier = obj.oClassifier
                NameValueArgs.PreSelectedFeatures (1,:) double {mustBeInteger} = []
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            % Warn the user of the changed parameters in the function
            % call if verbose is set.
            if NameValueArgs.Verbose && NameValueArgs.NumFeatures ~= obj.dNumFeatures
                warning('ForwardWrapperFeatureSelector:ChangedNumFeatures',['Number of features has been changed by the user and does not match the value stored in the parameters file. Number of features entered: ', num2str(NameValueArgs.NumFeatures) '. Number of features in parameters file: ' num2str(obj.dNumFeatures) '.']);
            end
            
            bUseParfor = true;
                        
            ForwardWrapperFeatureSelector.SelectFeatures_Generalized(obj, oFeatureValues, NameValueArgs, bUseParfor); 
            
            % return copy of feature selector object
            % (since FeatureSelector inherits from handle, this allows for
            % this function to be used as an object from handle would
            % typically be used with no output agruments, or as a typical
            % Matlab object, with using a single output)
            newObj = copy(obj);       
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
        
        function JournalFeatureSelection(obj, oFeatureValues, dStartingIndex)
            % JournalFeatureSelection(obj, oFeatureValues, dStartingIndex)
            %
            % SYNTAX:
            % JournalFeatureSelection(obj, oFeatureValues, dStartingIndex)
            %
            % DESCRIPTION:
            %  Function to journal the feature selection process.
            %
            % INPUT ARGUMENTS:
            %  obj: Feature Selector object
            %  oFeatureValues: Feature values object containing all
            %   feature data
            %  dStartingIndex: Feature number to start journalling.
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copy of feature selection object.

            % Primary Author: Ryan Alfano
            % Created: 05 14, 2019
            
            if Experiment.IsRunning()
                Experiment.StartNewSubSection("Feature Selection - Forward Wrapper");
                                
                [bAddEntriesIntoExperimentReport, bSaveObjects, bSaveSummaryFiles] = Experiment.GetJournalingSettings();
                
                if bSaveObjects
                    sObjectFilePath = fullfile(Experiment.GetResultsDirectory(), "Journalled Variables.mat");
                    
                    FileIOUtils.SaveMatFile(sObjectFilePath, ForwardWrapperFeatureSelector.sExperimentJournalingObjVarName, obj);
                    
                    Experiment.AddToReport(ReportUtils.CreateLinkToMatFileWithVarNames("Feature selector object saved to: ", sObjectFilePath, "Feature Selector Object", ForwardWrapperFeatureSelector.sExperimentJournalingObjVarName));
                end
                
                if bAddEntriesIntoExperimentReport
                    vsFeatureNames = oFeatureValues.GetFeatureNames();
                    
                    for dSelectedFeatureIndex=1:obj.dNumFeatures
                        dFeatureIndex = find(obj.vdOrderedSelectedFeatures == dSelectedFeatureIndex);
                        sFeatureName = vsFeatureNames(dFeatureIndex);
                        
                        if dSelectedFeatureIndex < dStartingIndex
                            chLabel = 'Pre-Selected Added Feature';
                            chErrorMetricStr = '';
                        else
                            chLabel = 'Added Feature';
                            chErrorMetricStr = [' (',...
                                char(obj.oObjectiveFunction.GetDescriptionString()),...
                                ': ',...
                                num2str(obj.m2dObjectiveFunctionValuePerCombination(dSelectedFeatureIndex, dFeatureIndex)),...
                                ')'];
                        end
                        
                        dRecordLinkIndex = oFeatureValues.vdLinkIndexPerFeature(dFeatureIndex);
                        sDescription = oFeatureValues.voFeatureValuesToFeatureExtractionRecordLinks(dRecordLinkIndex).oFeatureExtractionRecord.voFeatureExtractionRecordPortions.sDescription;
                                                
                        chLabel = [chLabel, ' ', num2str(dSelectedFeatureIndex), ': '];
                        chFeatureNameAndAuc = [...
                            'Feature ', num2str(dFeatureIndex), ' - ',...
                            char(sFeatureName), ' - ',...
                            char(sDescription),...
                            chErrorMetricStr];
                        
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel(chLabel, chFeatureNameAndAuc));
                    end
                end
                
                Experiment.EndCurrentSubSection();
            end
        end       
        
        function dObjectiveFunctionForFeatureCombo = EvaluateObjectiveFunctionForFeatureCombo(obj, oFeatureValues, vdSelectedFeatureMask, dFeatureCombinationIndex)
            %dObjectiveFunctionForFeatureCombo = EvaluateObjectiveFunctionForFeatureCombo(oFeatureSelectionObject, oFeatureValues, vdSelectedFeatureMask, dFeatureCombinationIndex)
            %
            % SYNTAX:
            %  dObjectiveFunctionForFeatureCombo = EvaluateObjectiveFunctionForFeatureCombo(oFeatureSelectionObject, oFeatureValues, vdSelectedFeatureMask, dFeatureCombinationIndex)
            %
            % DESCRIPTION:
            %  Calculates the objective function for a specific feature
            %  combination during the forward feature selection
            %
            % INPUT ARGUMENTS:
            %  oFeatureValues: feature values object
            %  vdSelectedFeatureMask: the selected feature mask that is
            %    ultimately returned to the user
            %  dFeatureCombinationIndex: the index of the loop for which
            %    feature combination we are to evaluate
            %
            % OUTPUTS ARGUMENTS:
            %  dObjectiveFunctionForFeatureCombo: Objective function value
            %  for the current feature combo

            % Primary Author: Ryan Alfano
            % Created: 03 13, 2019
            
            % Build feature table with corresponding selected features
            vdFeatureColumnIndices = zeros(1,nnz(vdSelectedFeatureMask)+1);
            dNumZeroSeen = 1;
            dFeatureColumnIndicesIdx = 1;
            
            for dBuildFeatureTableIndex = 1:size(vdSelectedFeatureMask,2)
                if vdSelectedFeatureMask(dBuildFeatureTableIndex) > 0 
                    vdFeatureColumnIndices(dFeatureColumnIndicesIdx) = dBuildFeatureTableIndex;
                    dFeatureColumnIndicesIdx = dFeatureColumnIndicesIdx + 1;
                else
                    if dNumZeroSeen == dFeatureCombinationIndex
                        vdFeatureColumnIndices(dFeatureColumnIndicesIdx) = dBuildFeatureTableIndex;
                        dNumZeroSeen = dNumZeroSeen + 1;
                        dFeatureColumnIndicesIdx = dFeatureColumnIndicesIdx + 1;
                    else
                        dNumZeroSeen = dNumZeroSeen + 1;
                    end
                end
            end
            
            oSelectedFeatureValues = oFeatureValues(:,vdFeatureColumnIndices);
            
            % evaluate objective function
            dObjectiveFunctionForFeatureCombo = obj.oObjectiveFunction.Evaluate(obj.oClassifier, oSelectedFeatureValues);
        end
        
        function vdSelectedFeatureMask = BuildSelectedFeaturesOutput(obj, vdSelectedFeatureMask, vdObjectiveFunctionPerFeatureCombo, dFeatureSelectedIndex)
            %vdSelectedFeatureMask = BuildSelectedFeaturesOutput(oFeatureSelectionObject, vdSelectedFeatureMask, stErrorMetricsPerFeatureCombo, dFeatureSelectedIndex)
            %
            % SYNTAX:
            %  vdSelectedFeatureMask = BuildSelectedFeaturesOutput(oFeatureSelectionObject, vdSelectedFeatureMask, stErrorMetricsPerFeatureCombo, dFeatureSelectedIndex)
            %
            % DESCRIPTION:
            %  Build the resulting selected features output based on the
            %  selected scoring criterion
            %
            % INPUT ARGUMENTS:
            %  oFeatureSelectionObject: object of feature selection
            %  vdSelectedFeatureMask: the selected feature mask that is
            %    ultimately returned to the user
            %  stErrorMetricsPerFeatureCombo: struct of error metrics
            %    evaluated for every feature combination
            %  iFeatureCombinationIndex: the index of the loop for which
            %    feature combination we are to evaluate
            %
            % OUTPUTS ARGUMENTS:
            %  vdSelectedFeatureMask: the selected feature mask that is
            %    ultimately returned to the user
            
            % Select the feature based on the minimum value of the
            % objective function
            
            [dMinValue, dMinFeatureIndex] = min(vdObjectiveFunctionPerFeatureCombo);
            
            obj.dFeatureComboObjectiveFunctionValue = dMinValue;

            % Now that we know which unused feature provided the best score,
            % lets go ahead and flag it

            dFeatureSelectionCounter = 1;
            
            for dFeatureSelectionIndex = 1:size(vdSelectedFeatureMask,2)
                if vdSelectedFeatureMask(dFeatureSelectionIndex) == 0 
                    if dFeatureSelectionCounter == dMinFeatureIndex
                        vdSelectedFeatureMask(dFeatureSelectionIndex) = dFeatureSelectedIndex;
                        dFeatureSelectionCounter = dFeatureSelectionCounter + 1;
                    else
                        dFeatureSelectionCounter = dFeatureSelectionCounter + 1;
                    end
                end
            end
        end
        
        function obj = BuildObjectiveFunctionCombinationOutput(obj, vdSelectedFeatureMask, dFeatureSelectedIndex, vdErrorMetricPerFeatureCombo)
            %oFeatureSelectionObject = BuildObjectiveFunctionCombinationOutput(oFeatureSelectionObject, vdSelectedFeatureMask, dFeatureSelectedIndex, stErrorMetricsPerFeatureCombo)
            %
            % SYNTAX:
            %  oFeatureSelectionObject = BuildObjectiveFunctionCombinationOutput(oFeatureSelectionObject, vdSelectedFeatureMask, dFeatureSelectedIndex, stErrorMetricsPerFeatureCombo)
            %
            % DESCRIPTION:
            %  Builds the error metrics combinations at each addition of a
            %  new feature up to the number of features selected
            %
            % INPUT ARGUMENTS:
            %  oFeatureSelectionObject: object of feature selection
            %  vdSelectedFeatureMask: the selected feature mask that is
            %    ultimately returned to the user
            %  stErrorMetricsPerFeatureCombo: struct of error metrics
            %    evaluated for every feature combination
            %  dFeatureSelectedIndex: how many features are being selected
            %    in that loop iteration
            %
            % OUTPUTS ARGUMENTS:
            %  oFeatureSelectionObject: object of feature selection
            
            % Assemble the output 
            dFeatureComboIterator = 1;
            
            for dObjectiveFunctionCombinationIndex = 1:length(vdSelectedFeatureMask)
                if vdSelectedFeatureMask(dObjectiveFunctionCombinationIndex) == 0 || vdSelectedFeatureMask(dObjectiveFunctionCombinationIndex) == dFeatureSelectedIndex
                    obj.m2dObjectiveFunctionValuePerCombination(dFeatureSelectedIndex,dObjectiveFunctionCombinationIndex) = vdErrorMetricPerFeatureCombo(dFeatureComboIterator);
                    dFeatureComboIterator = dFeatureComboIterator + 1;
                else
                    obj.m2dObjectiveFunctionValuePerCombination(dFeatureSelectedIndex,dObjectiveFunctionCombinationIndex) = NaN;
                end
            end
        end
    end
    
    
    methods (Access = private, Static = true)
                
        function dObjectiveFunctionForFeatureCombo = PerCombinationLoopIndex(obj, oFeatureValues, vdSelectedFeatureMask, dFeatureCombinationIndex, oLoopManager)
             %dObjectiveFunctionForFeatureCombo = PerCombinationLoopIndex(obj, oFeatureValues, vdSelectedFeatureMask, dFeatureCombinationIndex, oLoopManager)
            %
            % SYNTAX:
            %  dObjectiveFunctionForFeatureCombo = PerCombinationLoopIndex(obj, oFeatureValues, vdSelectedFeatureMask, dFeatureCombinationIndex, oLoopManager)
            %
            % DESCRIPTION:
            %  Returns the objective function value for the current feature
            %  combination
            %
            % INPUT ARGUMENTS:
            %  obj: object of feature selection
            %  oFeatureValues: the selected feature mask that is
            %    ultimately returned to the user
            %  vdSelectedFeatureMask: Mask of features selected from the
            %    feature selection algorithm thus far.
            %  dFeatureCombinationIndex: Index of the current feature
            %    combination.
            %  oLoopManager: Object that manages the current loop for
            %    parfor purposes.
            %
            % OUTPUTS ARGUMENTS:
            %  dObjectiveFunctionForFeatureCombo: Value of the objective
            %    function
            
             oLoopManager.PerLoopIndexSetup(dFeatureCombinationIndex);
                    
             dObjectiveFunctionForFeatureCombo = obj.EvaluateObjectiveFunctionForFeatureCombo(oFeatureValues, vdSelectedFeatureMask, dFeatureCombinationIndex);
             
             oLoopManager.PerLoopIndexTeardown();
        end 
        
        function SelectFeatures_Generalized(obj, oFeatureValues, NameValueArgs, bUseParfor)
            %SelectFeatures_Generalized(obj, oFeatureValues, NameValueArgs, bUseParfor)
            %
            % SYNTAX:
            %  SelectFeatures_Generalized(obj, oFeatureValues, NameValueArgs, bUseParfor)
            %
            % DESCRIPTION:
            %  Generalized inteernal select features call.
            %
            % INPUT ARGUMENTS:
            %  obj: object of feature selection
            %  oFeatureValues: the selected feature mask that is
            %    ultimately returned to the user
            %  NameValueArgs: NameValueArgs passed from the SelectFeatures
            %    call
            %  bUseParfor: Boolean to flag if parallel computing is to be
            %    used
            %
            % OUTPUTS ARGUMENTS:
            
            % Reinitialize some parameters that were changed by the user
            obj.dNumFeatures = NameValueArgs.NumFeatures;
            obj.oClassifier = NameValueArgs.Classifier;
            vdPreSelectedFeatures = NameValueArgs.PreSelectedFeatures;
            
            % Initialize the return
            obj.m2dObjectiveFunctionValuePerCombination = NaN(obj.dNumFeatures, oFeatureValues.GetNumberOfFeatures());
            
            if isempty(vdPreSelectedFeatures)            
                vdSelectedFeatureMask = zeros(1, oFeatureValues.GetNumberOfFeatures());
                dStartingIndex = 1;
            else
                ForwardWrapperFeatureSelector.MustBeValidPreSelectedFeatures(vdPreSelectedFeatures, oFeatureValues.GetNumberOfFeatures(), obj.dNumFeatures);
                            
                vdSelectedFeatureMask = vdPreSelectedFeatures;
                dStartingIndex = max(vdPreSelectedFeatures) + 1;
            end
             
            % Begin looping through each selected feature (1:N, N = number
            % of features to select)            
            if NameValueArgs.Verbose && dStartingIndex ~= 1
                disp([num2str(dStartingIndex-1), ' Features Pre-Selected']);
            end
            
            % iterate through selecting features
            for dFeatureSelectedIndex = dStartingIndex:obj.dNumFeatures
                if NameValueArgs.Verbose
                    disp(['Adding Feature: ', num2str(dFeatureSelectedIndex), '/', num2str(obj.dNumFeatures)]);
                end
                
                dNumCombinations = (oFeatureValues.GetNumberOfFeatures()-nnz(vdSelectedFeatureMask));
                
                % Allocating array into memory                
                vdObjectiveFunctionPerFeatureCombo = zeros(dNumCombinations,1);
                
                % For reproducibility/journaling on remote parfor workers
                oLoopManager = Experiment.GetLoopIterationManager(dNumCombinations);
                    
                if bUseParfor
                    parfor dFeatureCombinationIndex = 1:dNumCombinations
                        vdObjectiveFunctionPerFeatureCombo(dFeatureCombinationIndex) = ForwardWrapperFeatureSelector.PerCombinationLoopIndex(...
                            obj, oFeatureValues, vdSelectedFeatureMask, dFeatureCombinationIndex, oLoopManager);                        
                    end
                else
                    for dFeatureCombinationIndex = 1:dNumCombinations
                        vdObjectiveFunctionPerFeatureCombo(dFeatureCombinationIndex) = ForwardWrapperFeatureSelector.PerCombinationLoopIndex(...
                            obj, oFeatureValues, vdSelectedFeatureMask, dFeatureCombinationIndex, oLoopManager);                        
                    end
                end
                
                oLoopManager.PostLoopTeardown();
                
                % Build the output based on the scoring criterion
                vdSelectedFeatureMask = obj.BuildSelectedFeaturesOutput(vdSelectedFeatureMask, vdObjectiveFunctionPerFeatureCombo, dFeatureSelectedIndex);
                
                % Build the error metrics per feature combo
                obj = obj.BuildObjectiveFunctionCombinationOutput(vdSelectedFeatureMask, dFeatureSelectedIndex, vdObjectiveFunctionPerFeatureCombo);
            end
            
            obj.vbSelectedFeatureMask = logical(vdSelectedFeatureMask);
            obj.vdOrderedSelectedFeatures = vdSelectedFeatureMask;
            
            if NameValueArgs.JournalingOn
                obj.JournalFeatureSelection(oFeatureValues, dStartingIndex);
            end
        end
        
        function MustBeValidPreSelectedFeatures(vdPreSelectedFeatures, dNumTotalFeatures, dNumFeaturesToSelect)
            %MustBeValidPreSelectedFeatures(vdPreSelectedFeatures, dNumTotalFeatures, dNumFeaturesToSelect)
            %
            % SYNTAX:
            %  MustBeValidPreSelectedFeatures(vdPreSelectedFeatures, dNumTotalFeatures, dNumFeaturesToSelect)
            %
            % DESCRIPTION:
            %  Checks if the pre-selected features vector is valid for the
            %  algorithm.
            %
            % INPUT ARGUMENTS:
            %  vdPreSelectedFeatures: Vector of pre-selected features.
            %  dNumTotalFeatures: Number of total features in the feature
            %    values object.
            %  dNumFeaturesToSelect: Number of features that we are looking
            %    to select.
            %
            % OUTPUTS ARGUMENTS:
            %  -
            
            arguments
                vdPreSelectedFeatures (1,:) double {mustBeInteger}
                dNumTotalFeatures (1,1) double
                dNumFeaturesToSelect (1,1) double
            end
            
            if length(vdPreSelectedFeatures) ~= dNumTotalFeatures
                error(...
                    'ForwardWrapperFeatureSelector:MustBeValidPreSelectedFeatures:InvalidLength',...
                    'The length of the pre-selected features vector must be the same as the number of total features.');
            end
            
            vdSorted = sort(vdPreSelectedFeatures, 'ascend');
            vdSorted = vdSorted(vdSorted ~= 0);
            
            dMax = max(vdSorted);
            
            if any(vdSorted ~= 1:dMax)
                error(...
                    'ForwardWrapperFeatureSelector:MustBeValidPreSelectedFeatures:InvalidValues',...
                    'The pre-selected features vector must contain only 0s and a single occurence of the numbers 1 to n, where n is the number of pre-selected features.');
            end
            
            if dNumFeaturesToSelect <= dMax
                error(...
                    'ForwardWrapperFeatureSelector:MustBeValidPreSelectedFeatures:TooManyPreSelectedFeatures',...
                    'The number of pre-selected features must be less than the number of features to select.');
            end
        end
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

