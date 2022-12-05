classdef MATLABBayesianHyperParameterOptimizer < HyperParameterOptimizer
    %MATLABBayesianHyperParameterOptimizer
    %
    % This optimizer uses the Bayesian optimization function to find the
    % optimal set of hyper-parameters by minimizing a customized objective
    % function.  
    % The customized objective function gives the user more control
    % over the cross-validation parameters (number of folds,
    % repetitions, balancing etc.)
    %
    % See available scripted optimization functions in folder 
    %           MachineLearningObjectiveFunction 
    
    % Primary Author: David DeVries
    % Created: Aug 31, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    properties (SetAccess = immutable, GetAccess = public)
        oObjectiveFunction MachineLearningObjectiveFunction {ValidationUtils.MustBeEmptyOrScalar} = KFoldCrossValidationObjectiveFunction.empty
        
        dMaxObjectiveEvaluationsOverride double {ValidationUtils.MustBeEmptyOrScalar} = []
        dVerboseOverride double {ValidationUtils.MustBeEmptyOrScalar} = []
    end
    
    properties (SetAccess = private, GetAccess = public)
        oHyperParameterOptimizationResults
    end
    

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************

    methods  (Access = public, Static = false)
        
        function obj = MATLABBayesianHyperParameterOptimizer(chOptimizationParameterFilename, oObjectiveFunction, oLabelledFeatureValues, NameValueArgs)
            %obj = MATLABBayesianHyperParameterOptimizer(chOptimizationOptionsFileName, oObjectiveFunction, oLabelledFeatureValues)
            %
            % SYNTAX:
            %  obj = MATLABBayesianHyperParameterOptimizer(chOptimizationOptionsFileName, oObjectiveFunction, oLabelledFeatureValues)
            %
            % DESCRIPTION:
            %  Function that calls the hyper-parameter optimizer with the
            %  labelled feature values, the table of optimizer options and
            %  the user defined customized objective function.
            %
            % INPUT ARGUMENTS:
            %  chOptimizationOptionsFileName: character array holding the
            %           file name where the optimizer options are stored 
            %  oObjectiveFunction: customized objective function to be 
            %           minimized in order to obtain the optimal set of
            %           hyper-parameters
            %  oLabelledFeatureValues: object of type LabelledFeatureValues  
            %           holding the training set feature values and labels  
            %           to be used during parameter optimization.
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            arguments
                chOptimizationParameterFilename (1,:) char
                oObjectiveFunction (1,1) MachineLearningObjectiveFunction {MustBeValidForMinimaOptimization(oObjectiveFunction)}
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                NameValueArgs.MaxObjectiveEvaluations double {ValidationUtils.MustBeEmptyOrScalar} = []
                NameValueArgs.Verbose double {ValidationUtils.MustBeEmptyOrScalar} = []
            end
            
            % super class call
            obj@HyperParameterOptimizer(chOptimizationParameterFilename, oLabelledFeatureValues);
            
            % local call
            obj.oObjectiveFunction = oObjectiveFunction;
            
            if ~isempty(NameValueArgs.MaxObjectiveEvaluations)
                obj.dMaxObjectiveEvaluationsOverride = NameValueArgs.MaxObjectiveEvaluations;
            end
            
            if ~isempty(NameValueArgs.Verbose)
                obj.dVerboseOverride = NameValueArgs.Verbose;
            end
        end

        function oObjectiveFunction = GetObjectiveFunction(obj)
            oObjectiveFunction = obj.oObjectiveFunction;
        end
        
        function dObjectiveFunctionValue = GetObjectiveFunctionValueAtOptimalHyperParameters(obj)
            arguments
                obj (1,1) MATLABBayesianHyperParameterOptimizer {MustHavePerformedOptimization}
            end
            
            c1BestPointX = table2cell(obj.oHyperParameterOptimizationResults.bestPoint);
            c1MinObjectiveX = table2cell(obj.oHyperParameterOptimizationResults.XAtMinObjective);
            c1MinEstimatedObjectiveX = table2cell(obj.oHyperParameterOptimizationResults.XAtMinEstimatedObjective);
            
            bBestPointEqualToMinObjectiveX = true;
            bBestPointEqualToMinEstimatedObjectiveX = true;
            
            for dDimIndex=1:length(c1BestPointX)
                if isnumeric(c1BestPointX{dDimIndex}) && isnan(c1BestPointX{dDimIndex}) && isnumeric(c1MinObjectiveX{dDimIndex}) && isnan(c1MinObjectiveX{dDimIndex})
                    % do nothing
                else
                    if ~isequal(c1BestPointX{dDimIndex}, c1MinObjectiveX{dDimIndex})
                        bBestPointEqualToMinObjectiveX = false;
                        break;
                    end
                end
            end
            
            for dDimIndex=1:length(c1BestPointX)
                if isnumeric(c1BestPointX{dDimIndex}) && isnan(c1BestPointX{dDimIndex}) && isnumeric(c1MinEstimatedObjectiveX{dDimIndex}) && isnan(c1MinEstimatedObjectiveX{dDimIndex})
                    % do nothing
                else
                    if ~isequal(c1BestPointX{dDimIndex}, c1MinEstimatedObjectiveX{dDimIndex})
                        bBestPointEqualToMinEstimatedObjectiveX = false;
                        break;
                    end
                end
            end
            
            if bBestPointEqualToMinObjectiveX
                dObjectiveFunctionValue = obj.oHyperParameterOptimizationResults.MinObjective;
            elseif bBestPointEqualToMinEstimatedObjectiveX
                dObjectiveFunctionValue = obj.oHyperParameterOptimizationResults.MinEstimatedObjective;
            else
                error(...
                    'MATLABBayesianHyperParameterOptimizer:GetObjectiveFunctionValueAtOptimalHyperParameters:NoObjectiveFunctionValueFound',...
                    'The best point was neither at the minimal objective function or minimal estimated objective function.');
            end
        end
        
        function oHyperParameterOptimizationResults = GetHyperParameterOptimizationResultsObject(obj)
            oHyperParameterOptimizationResults = obj.oHyperParameterOptimizationResults;
        end
    end
        
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = false)  
        
        function MustHavePerformedOptimization(obj)
            if isempty(obj.oHyperParameterOptimizationResults)
                error(...
                    'MATLABBayesianHyperParameterOptimizer:MustHavePerformedOptimization:Invalid',...
                    'Object has not performed a hyper-parameter optimization.');
            end
        end
        
        function dObjectiveFnValue = ObjectiveFunction(obj, tHyperParameterValues, oClassifier)
            
           oClassifier = obj.GetClassifierWithHyperParameterValuesSet(tHyperParameterValues, oClassifier);
           
           dObjectiveFnValue = obj.oObjectiveFunction.Evaluate(oClassifier, obj.oLabelledFeatureValues);
        end
        
        function oClassifier = GetClassifierWithHyperParameterValuesSet(obj, tHyperParameterValues, oClassifier)
            tHyperParameters = oClassifier.GetHyperParametersTable();
            
            tHyperParameters = tHyperParameters(:,1:5); % just get the hyper-parameters for input
            
            vsVariableNames = string(tHyperParameters.Properties.VariableNames);
            vsVariableNames(vsVariableNames == "sNameInModel") = "sModelParameterName";
            vsVariableNames(vsVariableNames == "c1xUserInputValue") = "c1xValue";
            tHyperParameters.Properties.VariableNames = cellstr(vsVariableNames);
            
            tHyperParameters.bOptimize(:) = false;
            tHyperParameters.c1xOptimizationDomain(:) = {false};
            
            vsHyperParameterNames = tHyperParameters.sName;
            
            if isfield(tHyperParameters, 'sModelParameterName')
                vsHyperParameterModelNames = tHyperParameters.sModelParameterName;
            else
                vsHyperParameterModelNames = vsHyperParameterNames;
            end
            
            fnClassifierConstructor = str2func(class(oClassifier));
            
            vsToSetHyperParameterNames = string(tHyperParameterValues.Properties.VariableNames);
            
            for dHyperParameterIndex=1:length(vsToSetHyperParameterNames)
                sToSetName = vsToSetHyperParameterNames(dHyperParameterIndex);
                
                vdIndices = find(sToSetName == vsHyperParameterNames);
                
                if ~isscalar(vdIndices)
                    vdIndices = find(sToSetName == vsHyperParameterModelNames);
                end
                
                if ~isscalar(vdIndices)
                    error(...
                        'MATLABBayesianHyperParameterOptimizer:GetClassifierWithHyperParameterValuesSet:HyperParameterNameNotFound',...
                        ['Hyperparameter "', char(sToSetName), '"not found in hyperparameter table.']);
                end
                
                dTableIndex = vdIndices(1);
                
                xValue = tHyperParameterValues{1,dHyperParameterIndex};
                
                if isnumeric(xValue) && isnan(xValue) % conditional constraint function sets bad values to NaN
                    xValue = []; 
                end
                
                if iscategorical(xValue)
                    xValue = char(xValue);
                end
                
                tHyperParameters.c1xValue{dTableIndex} = xValue;
            end
                        
            oClassifier = fnClassifierConstructor(tHyperParameters, 'JournalingOn', false);
        end

        function stOptions = GetHyperParameterOptions(obj)
            vsNames = obj.tOptions.sName;
            c1xValues = obj.tOptions.c1xValue;
            
            dNumOptions = length(vsNames);
            
            vbIncludeOptions = true(dNumOptions,1);
            
            for dOptionIndex=1:dNumOptions
                if ismissing(c1xValues{dOptionIndex})
                    vbIncludeOptions(dOptionIndex) = false;
                end
            end
            
            vsNames = vsNames(vbIncludeOptions);
            c1xValues = c1xValues(vbIncludeOptions);
            
            % allow for max obj. evals. to be override, as per the
            % name-value args to the constructor
            if ~isempty(obj.dMaxObjectiveEvaluationsOverride)
                dMatchIndex = find(vsNames == "MaxObjectiveEvaluations");
                
                if isempty(dMatchIndex)
                    vsNames = [vsNames; "MaxObjectiveEvaluations"];
                    c1xValues = [c1xValues; {obj.dMaxObjectiveEvaluationsOverride}];
                else
                    c1xValues{dMatchIndex} = obj.dMaxObjectiveEvaluationsOverride;
                end
            end
            
            % allow for verbose to be override, as per the
            % name-value args to the constructor
            if ~isempty(obj.dVerboseOverride)
                dMatchIndex = find(vsNames == "Verbose");
                
                if isempty(dMatchIndex)
                    vsNames = [vsNames; "Verbose"];
                    c1xValues = [c1xValues; {obj.dVerboseOverride}];
                else
                    c1xValues{dMatchIndex} = obj.dVerboseOverride;
                end
            end
            
            dNumIncludedOptions = length(vsNames);
            
            c1xVarargin = cell(1,2*dNumIncludedOptions);
            
            for dOptionIndex=1:dNumIncludedOptions
                c1xVarargin{(dOptionIndex*2)-1} = vsNames(dOptionIndex);
                c1xVarargin{(dOptionIndex*2)} = c1xValues{dOptionIndex};
            end
            
            stOptions = struct(c1xVarargin{:});
        end
        
    end
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                  SPECIFIC CLASS ACCESS                            *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?Classifier}, Static = false)
        
        function [obj, oModel, oHyperParameterOptimizationResults] = OptimizeParameters(obj, oClassifier, NameValueArgs)
            % [obj, oModel, oHyperParameterOptimizationResults] = OptimizeParameters(obj,oClassifier)
            %
            % SYNTAX:
            %  [obj, oModel,oHyperParameterOptimizationResults] = OptimizeParameters(obj,oClassifier)
            %
            % DESCRIPTION:
            %   This function calls the Matlab specific classifier (defined
            %   in oClassifier) to determine the parameter values that will
            %   produce the optimal classifier results.
            %
            %   Inputs to the classifier's optimizer include:
            %       - training feature values
            %       - associated labels
            %       - the 'locked down' values of the variables defined by
            %         user in the tHyperParameters table
            %       - the list of optimizeable variables the user wants to
            %         be optimized
            %       - the structure of optimizer options defined by the
            %         user in the tOptions table
            %
            % INPUT ARGUMENTS:
            %   obj:    object of type MATLABMachineLearningOptimizeParameters 
            %           The properties of this object includes the labelled 
            %           training feature values as well as the table of 
            %           optimizer options.
            %   oClassifier: the MATLAB implementation specific classifier object. 
            %           See abstract class 'Classifier' for property
            %           details.
            %
            % OUTPUTS ARGUMENTS:
            %   obj: class object
            %   oModel: object of type ClassificationXXX where XXX is 
            %           defined by the Matlab classifier. This model holds
            %           the optimized parameters for the classifier.
            %   oHyperParameterOptimizationResults: object belonging to the
            %           class of optimizer used. This object holds results
            %           of the hyperparameter optimization.
            
            arguments
                obj (1,1) MATLABBayesianHyperParameterOptimizer
                oClassifier (1,1) ClassifierWithHyperParameterConstraintFunctions
                NameValueArgs.JournalingOn (1,1) logical = true
            end

            hObjectiveFn = @(tHyperParameters) obj.ObjectiveFunction(tHyperParameters, oClassifier);
                        
            stOptimizerOptions = obj.GetHyperParameterOptions();
            c1xVarargin = namedargs2cell(stOptimizerOptions);
            
            if ~isfield(stOptimizerOptions, 'ConditionalVariableFcn')
                fnCondVarFcn = oClassifier.GetConditionalVariableFcn();
                
                if ~isempty(fnCondVarFcn)
                    c1xVarargin = [c1xVarargin, {'ConditionalVariableFcn', fnCondVarFcn}];
                end
            end
            
            if ~isfield(stOptimizerOptions, 'XConstraintFcn')
                fnXConstraintFcn = oClassifier.GetXConstraintFcn();
                
                if ~isempty(fnXConstraintFcn)
                    c1xVarargin = [c1xVarargin, {'XConstraintFcn', fnXConstraintFcn}];
                end
            end
            
            oHyperParameterOptimizationResults = bayesopt(hObjectiveFn, oClassifier.GetOptimizableVariables(obj.oLabelledFeatureValues), c1xVarargin{:});
            
            obj.oHyperParameterOptimizationResults = oHyperParameterOptimizationResults;
            
            tOptimalHyperParameters = oHyperParameterOptimizationResults.bestPoint;          
            
            oOptimizedClassifier = obj.GetClassifierWithHyperParameterValuesSet(tOptimalHyperParameters, oClassifier);
            oTrainedOptimizedClassifier = oOptimizedClassifier.Train(obj.oLabelledFeatureValues, 'JournalingOn', false);
            
            oModel = oTrainedOptimizedClassifier.GetTrainedClassifier();            
            
            % Journal:
            if NameValueArgs.JournalingOn && Experiment.IsRunning()
                Experiment.StartNewSubSection('Hyper Parameter Optimization');
                
                [bAddEntriesIntoExperimentReport, bSaveObjects, bSaveSummaryFiles] = Experiment.GetJournalingSettings();
                
                if bSaveObjects
                    sObjectFilePath = fullfile(Experiment.GetResultsDirectory(), "Journalled Variables.mat");
                    
                    FileIOUtils.SaveMatFile(sObjectFilePath, HyperParameterOptimizer.sExperimentJournalingObjVarName, obj);
                    
                    Experiment.AddToReport(ReportUtils.CreateLinkToMatFileWithVarNames("Hyper-parameter optimizer object saved to: ", sObjectFilePath, "Hyper-Parameter Optimizer Object", HyperParameterOptimizer.sExperimentJournalingObjVarName));
                end
                
                if bSaveSummaryFiles
                    sSummaryPdfFilePath = fullfile(Experiment.GetResultsDirectory, "Journalled Summary.pdf");
                    
                    oSummaryPdf = ReportUtils.InitializePDF(sSummaryPdfFilePath);
                                        
                    oSummaryPdf.add(ReportUtils.CreateParagraphWithBoldLabel('Acquisition Function: ', stOptimizerOptions.AcquisitionFunctionName));
                    
                    tPerIterationResults = table(...
                        (1:oHyperParameterOptimizationResults.NumObjectiveEvaluations)', oHyperParameterOptimizationResults.ObjectiveTrace,...
                        'VariableNames', {'Iter. #', 'Objective Function'});
                    
                    tPerIterationResults = [tPerIterationResults, oHyperParameterOptimizationResults.XTrace];
                    
                    oSummaryPdf.add(ReportUtils.CreateTable(tPerIterationResults));
                    
                    oSummaryPdf.close();
                                        
                    Experiment.AddToReport(ReportUtils.CreateLinkToFile("Hyper-parameter optimization summary saved to: ", sSummaryPdfFilePath));
                end
                
                if bAddEntriesIntoExperimentReport
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Optimizer: ', 'Bayesian Optimization'));
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Number of Iterations: ', num2str(oHyperParameterOptimizationResults.NumObjectiveEvaluations)));
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Time Elapsed (s): ', num2str(oHyperParameterOptimizationResults.TotalElapsedTime)));
                    
                    oHyperParameterOptimizationResults.plot(@plotObjective);
                    hFig = gcf;
                    hAxes = gca;
                    
                    hAxes.YLabel.String = [hAxes.YLabel.String, ' [', char(obj.oObjectiveFunction.GetDescriptionString()), ']'];
                    
                    chFigFilePath = fullfile(Experiment.GetResultsDirectory(), 'Obj. Fcn. vs. Iteration.fig');
                    savefig(hFig, chFigFilePath);
                    delete(hFig);
                    
                    Experiment.AddToReport(chFigFilePath);
                    
                    
                    
                    oHyperParameterOptimizationResults.plot(@plotMinObjective);
                    hFig = gcf;
                    hAxes = gca;
                    
                    hAxes.YLabel.String = [hAxes.YLabel.String, ' [', char(obj.oObjectiveFunction.GetDescriptionString()), ']'];
                    
                    chFigFilePath = fullfile(Experiment.GetResultsDirectory(), 'Min. Obj. Fcn. vs. Iteration.fig');
                    savefig(hFig, chFigFilePath);
                    delete(hFig);
                    
                    Experiment.AddToReport(chFigFilePath);
                end
                
                Experiment.EndCurrentSubSection();
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

        function [c1xNameValueLockDownParams,voOptimizeableHyperParams,stOptimizerOptions] = ...
                GetHyperParametersForOptimization_ForUnitTest(obj,oClassifier)
            %[c1xNameValueLockDownParams,voOptimizeableHyperParams,stOptimizerOptions] = ...
            %    GetHyperParametersForOptimization_ForUnitTest(obj,oClassifier)
            %
            % SYNTAX:
            %[c1xNameValueLockDownParams,voOptimizeableHyperParams,stOptimizerOptions] = ...
            %    GetHyperParametersForOptimization_ForUnitTest(obj,oClassifier)
            %
            % DESCRIPTION:
            %  A function to give the unit tests access to the private
            %    function GetHyperParametersForOptimization
            %
            % INPUT ARGUMENTS:
            %   obj:    object of type MATLABMachineLearningOptimizeParameters 
            %           The properties of this object includes the training feature values
            %           as well as the table of optimizer options. 
            %   oClassifier: the MATLAB implementation specific classifier object. 
            %           See abstract class 'Classifier' for property
            %           details.
            %
            % OUTPUTS ARGUMENTS:
            %   c1xNameValueLockDownParams: cell array of name-value pairs
            %           listing the variables (char array) and their values
            %           (of mixed type) that the user specified in the
            %           classifier object's tHyperParameters table
            %   voOptimizeableHyperParams: vector of objects of type
            %          (Matlab's) optimizeableVariable holding variables 
            %           in the tHyperParameters table that had the 
            %           bOptimize flag set by the user (and are defined as 
            %           optimizeable by the classifier)
            %   stOptimizerOptions: structure of fields holding the name
            %           and associated value of optimizer options as
            %           defined by the user in the 
            %           MATLABMachineLearningOptimizeParameters object's 
            %           tOptions table
            
            % Primary Author: Carol Johnson
            % Created: Sep 24, 2019
           
            [c1xNameValueLockDownParams,voOptimizeableHyperParams,stOptimizerOptions] = ...
                obj.GetHyperParametersForOptimization(oClassifier);
            
        end
        
        function [oModel,oHyperParameterOptimizationResults] =...
                OptimizeParameters_ForUnitTest(obj,oClassifier)
            %[oModel,oHyperParameterOptimizationResults] = ...
            %       obj.OptimizeParameters(oClassifier)
            %
            % SYNTAX:
            %[oModel,oHyperParameterOptimizationResults] = ...
            %       obj.OptimizeParameters(oClassifier)
            %
            % DESCRIPTION:
            %  A function to give the unit tests access to the private
            %    function OptimizeParameters
            %
            % INPUT ARGUMENTS:
            %   obj:    object of type MATLABMachineLearningOptimizeParameters 
            %           The properties of this object includes the labelled 
            %           training feature values as well as the table of 
            %           optimizer options.
            %   oClassifier: the MATLAB implementation specific classifier object. 
            %           See abstract class 'Classifier' for property
            %           details.
            %
            % OUTPUTS ARGUMENTS:
            %   oModel: object of type ClassificationXXX where XXX is 
            %           defined by the Matlab classifier. This model holds
            %           the optimized parameters for the classifier.
            %   oHyperParameterOptimizationResults: object belonging to the
            %           class of optimizer used. This object holds results
            %           of the hyperparameter optimization.
            
            % Primary Author: Carol Johnson
            % Created: Sep 24, 2019

            [oModel,oHyperParameterOptimizationResults] =...
                obj.OptimizeParameters(oClassifier);
        end

    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end
