classdef MATLABMachineLearningHyperParameterOptimizer < HyperParameterOptimizer
    %MATLABMachineLearningHyperParameterOptimizer
    %
    % The MATLABMachineLearningHyperParameterOptimizer class is designed specifically
    % to optimize parameters for Matlab's machine learning classifiers
    % using a folded cross-validation scheme to minimize the ojective loss
    % function.
    %
    % See also: - Class HyperParameterOptimizer
    %           - UML Sequence Diagrams : Documentation\UML Sequence
    %              Diagrams\MATLABMachineLearningHyperParameterOptimizer.png
    
    % Primary Author: Carol Johnson
    % Created: Feb 21, 2019
    % Modified: Sep 24, 2019 (CJ) - tighten access rights for functions
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = protected, GetAccess = public)
    end
    
    properties (SetAccess = private, GetAccess = public)
        oHyperParameterOptimizationResults
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************

    methods  (Access = public, Static = false)
        
        function obj = MATLABMachineLearningHyperParameterOptimizer(chOptimizationParameterFilename, oLabelledFeatureValues)
            %obj =MATLABMachineLearningHyperParameterOptimizer(chOptimizationParameterFilename, oLabelledFeatureValues)
            %
            % SYNTAX:
            %  obj = MATLABMachineLearningHyperParameterOptimizer(chOptimizationParameterFilename, oLabelledFeatureValues)
            %
            % DESCRIPTION:
            %  Constructor for MATLABMachineLearningHyperParameterOptimizer
            %       - Creates an object based on the definition of the
            %         abstract parent class HyperParameterOptimizer
            %       - sets the implementation flag for Matlab machine
            %         learning
            %
            % INPUT ARGUMENTS:
            %  chOptimizationParameterFilename: character array holding the
            %           file name where the optimizer options are stored 
            %  oLabelledFeatureValues: object of type LabelledFeatureValues  
            %           holding the training set feature values and labels  
            %           to be used during parameter optimization.
            %
            % OUTPUT ARGUMENTS:
            %  obj: Constructed object
            
            obj@HyperParameterOptimizer(chOptimizationParameterFilename,oLabelledFeatureValues)
        end
        
        function oHyperParameterOptimizationResults = GetHyperParameterOptimizationResultsObject(obj)
            %oHyperParameterOptimizationResults = GetHyperParameterOptimizationResultsObject(obj)
            %
            % SYNTAX:
            %  oHyperParameterOptimizationResults = GetHyperParameterOptimizationResultsObject(obj))
            %
            % DESCRIPTION:
            %  Returns the results object after hyper-parameter
            %  optimization
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUT ARGUMENTS:
            %  oHyperParameterOptimizationResults: object belonging to the
            %           class of optimizer used. This object holds results
            %           of the hyperparameter optimization
            oHyperParameterOptimizationResults = obj.oHyperParameterOptimizationResults;
        end
        
        function dObjectiveFunctionValue = GetObjectiveFunctionValueAtOptimalHyperParameters(obj)
            %dObjectiveFunctionValue = GetObjectiveFunctionValueAtOptimalHyperParameters(obj)
            %
            % SYNTAX:
            %  dObjectiveFunctionValue = GetObjectiveFunctionValueAtOptimalHyperParameters(obj)
            %
            % DESCRIPTION:
            %  From the resulting objective function after hyper-parameter
            %  optimization, return the optimal function value.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  dObjectiveFunctionValue: value of best point for the
            %  resulting set of optimal hyper-parameters.
            
            % Primary Author: Your name here
            % Created: MMM DD, YYYY

            
            arguments
                obj (1,1) MATLABMachineLearningHyperParameterOptimizer {MustHavePerformedOptimization}
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
                    'MATLABMachineLearningHyperParameterOptimizer:GetObjectiveFunctionValueAtOptimalHyperParameters:NoObjectiveFunctionValueFound',...
                    'The best point was neither at the minimal objective function or minimal estimated objective function.');
            end
        end        
    end
    
    
        
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = false)   
        
        function MustHavePerformedOptimization(obj)
            if isempty(obj.oHyperParameterOptimizationResults)
                error(...
                    'MATLABMachineLearningHyperParameterOptimizer:MustHavePerformedOptimization:Invalid',...
                    'Object has not performed a hyper-parameter optimization.');
            end
        end    

        function [c1xNameValueLockDownParams,voOptimizeableHyperParams,stOptimizerOptions] = GetHyperParametersForOptimization(obj,oClassifier)
            % [c1xNameValueLockDownParams,voOptimizeableHyperParams,stOptimizerOptions] = GetHyperParametersForOptimization(obj,oClassifier)
            %
            % SYNTAX:
            %  [c1xNameValueLockDownParams,voOptimizeableHyperParams,stOptimizerOptions] = GetHyperParametersForOptimization(obj,oClassifier)
            %
            % DESCRIPTION:
            %   This function gets the variables from the tHyperParameters
            %   table and depending on the user's settings for the variable
            %   in the table, they are output with the appropriate syntax
            %   ready for the call to the optimizer.
            %
            %   Variables defined for optimization fall into 3 categories:
            %       - the 'locked down' values of the variables defined by
            %         user in the tHyperParameters table (variables not
            %         specifically set by the user will have default values
            %         assigned to them by MATLAB's underlying code during
            %         optimization)
            %       - the list of 'optimizeable variables' the user wants
            %         to be optimized (these have the bOptimize flag set to
            %         true)
            %       - the 'optimizer options' defined by the user in the 
            %         tOptions table (if not defined, defaults will be set
            %         by MATLAB's underlying code during optimization)
            %
            % INPUT ARGUMENTS:
            %   obj:    object of type MATLABMachineLearningHyperParameterOptimizer 
            %           The properties of this object includes the training feature values
            %           as well as the table of optimizer options. 
            %   oClassifier: the MATLAB implementation specific classifier object. 
            %           See abstract class 'Classifier' for property
            %           details.
            %
            % OUTPUT ARGUMENTS:
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
            %           MATLABMachineLearningHyperParameterOptimizer object's 
            %           tOptions table
            
            % Primary Author: Carol Johnson
            % Created: Feb 21, 2019
            % Modified: Sep 24, 2019 (CJ) change access to private
            
            % initialize some of the variables
            stOptimizerOptions = [];
            chClassifierFnName = func2str(oClassifier.GetClassifierHandle());

            % get hyperparameters for the optimizing function
            voOptimizeableHyperParams = hyperparameters(chClassifierFnName,...
                obj.GetLabelledFeatureValues().GetFeatures(),...
                double(obj.GetLabelledFeatureValues().GetLabels()));

            % initialization - turn off 'optimize' flag for all hyperparameters
            %   (only those requested by user will be turned on)
            for dOptimizeableHyperParams = 1:length(voOptimizeableHyperParams)
                voOptimizeableHyperParams(dOptimizeableHyperParams).Optimize = false;
            end
            
            % Build 'name-value' parameter array and update optimizable hyperparams objects
            % Get user defined values from Classifier parameter table
            vsNames = oClassifier.GetHyperParameterStatesNames();
            vbOptimize = oClassifier.GetHyperParameterStatesOptimize();
            c1xOptimizationDomain = oClassifier.GetHyperParameterStatesOptimizationDomain();
            c1xSantizedUserInputValues = oClassifier.GetHyperParameterStatesSantizedUserInputValues();
            
            % The number of locked down params will be the parameters that:
            % are set to not optimize AND that are non-empty
            dNumLockedDownParams = sum(~vbOptimize & cellfun(@(c) ~isempty(c),c1xSantizedUserInputValues));
            
            c1xNameValueLockDownParams = cell(1,dNumLockedDownParams);
            dLockDownIndexCounter = 1;
            
            dNumHyperParameters = length(vsNames);
            
            
            % loop through all hyperparameters in the classifer
            for dRow = 1:dNumHyperParameters
                sParamName = vsNames(dRow);
                % check if hyperparameter is to be optimized
                if vbOptimize(dRow)
                    
                    % find voOptimizeableHyperParams index that matches the
                    % sParamName
                    for dOptimizeableHyperParamIndex = 1:length(voOptimizeableHyperParams)
                        if sParamName == string(voOptimizeableHyperParams(dOptimizeableHyperParamIndex).Name) % found a match!
                            % set optimize flag to true
                            voOptimizeableHyperParams(dOptimizeableHyperParamIndex).Optimize = true;
                            
                            if ~isempty(c1xOptimizationDomain{dRow}) % if there is a set domain to optimize over set by the user, slot it in, otherwise don't touch it (MATLAB already set it to be default values)
                                voOptimizeableHyperParams(dOptimizeableHyperParamIndex).Range = c1xOptimizationDomain{dRow};
                            end
                            
                            break;
                        end
                    end
                else % if the user didn't want to optimize we'll set the lock down value...                    
                    % ...if field is non-empty
                    if ~isempty(c1xSantizedUserInputValues{dRow})
                        c1xNameValueLockDownParams{dLockDownIndexCounter} = sParamName;
                        c1xNameValueLockDownParams{dLockDownIndexCounter+1} = c1xSantizedUserInputValues{dRow};
                        
                        dLockDownIndexCounter = dLockDownIndexCounter + 2;
                    elseif sParamName == "CategoricalPredictors"
                        c1xNameValueLockDownParams{dLockDownIndexCounter} = sParamName;
                        c1xNameValueLockDownParams{dLockDownIndexCounter+1} = obj.oLabelledFeatureValues.IsFeatureCategorical();
                        
                        dLockDownIndexCounter = dLockDownIndexCounter + 2;
                    end
                end
            end
            
            % Add to optimizer structure if user defined an Optimizer-option value
            tOptimizerOptions = obj.GetOptimizerOptions();
            
            for dRow = 1:size(tOptimizerOptions)
                if (~isempty(tOptimizerOptions.c1xValue{dRow}))
                    % create structure for optimizer hyperparameters
                    if isstring(tOptimizerOptions.c1xValue{dRow})
                        xValue = char((tOptimizerOptions.c1xValue{dRow}));
                    else
                        xValue = tOptimizerOptions.c1xValue{dRow};
                    end
                    
                    stOptimizerOptions.(tOptimizerOptions.sName{dRow}) = xValue;
                end
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                  SPECIFIC CLASS ACCESS                            *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?MATLABClassifier}, Static = false)
        
        function [obj, oModel,oHyperParameterOptimizationResults] = OptimizeParameters(obj,oClassifier, NameValueArgs)
            % [obj, oModel,oHyperParameterOptimizationResults] = OptimizeParameters(obj,oClassifier, NameValueArgs)
            %
            % SYNTAX:
            %  [obj, oModel,oHyperParameterOptimizationResults] = OptimizeParameters(obj,oClassifier, NameValueArgs)
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
            %   obj:    object of type MATLABMachineLearningHyperParameterOptimizer 
            %           The properties of this object includes the labelled 
            %           training feature values as well as the table of 
            %           optimizer options.
            %   oClassifier: the MATLAB implementation specific classifier object. 
            %           See abstract class 'Classifier' for property
            %           details.
            %   NameValueArgs:
            %
            % OUTPUTS ARGUMENTS:
            %   obj:    optimized class object
            %   oModel: object of type ClassificationXXX where XXX is 
            %           defined by the Matlab classifier. This model holds
            %           the optimized parameters for the classifier.
            %   oHyperParameterOptimizationResults: object belonging to the
            %           class of optimizer used. This object holds results
            %           of the hyperparameter optimization.
            %
            %           NOTE: Matlab stores the results property in the
            %           model as HyperparameterOptimizationResults. The
            %           object in our toolkit wraps this in
            %           oHyperParameterOptimizationResults (using a "P"
            %           in the spelling)

            % Primary Author: Carol Johnson
            % Created: Feb 21, 2019
            % Modified: Sep 24, 2019 (CJ) change access to MATLABClassifier

            arguments
                obj
                oClassifier
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            % Change labels to integer 0s and 1s
            viChangedLabels = GetChangedLabels(obj.GetLabelledFeatureValues(),int16(1),int16(0)); %(values,pos,neg)

            % call to get user requested variables (locked or variable) 
            % into the proper syntax for the optimizer
            [c1xNameValueLockDownParams,voOptimizeableHyperParams,stOptimizerOptions] = ...
                obj.GetHyperParametersForOptimization(oClassifier);
            
            % perform optimization

            % Note: Due to inconsistencies in Matlab's handling of
            %   hyperparameter optimization results between classifiers ,
            %   the call for each group of classifiers must be hardcoded
            hClassifierHandle = oClassifier.GetClassifierHandle();
            chClassifierFunctionName = func2str(hClassifierHandle);
            
            if isfield(stOptimizerOptions, 'UseParallel') && stOptimizerOptions.UseParallel == true
                Experiment.StartParallelPool();
            end            
            

            try
                % Call to this classifier's optimizer returns the optimization
                %   result details as an output variable
                %
                % This code will throw an error if the classifier does not
                % return the optimization results as an output variable but
                % instead it is embedded within the model object. (eg.
                % fitclinear and fitckernel)
                % The catch will try the other method of calling for
                % optimization.
                [oModel,~,oHyperParameterOptimizationResults] = hClassifierHandle(...
                    obj.GetLabelledFeatureValues().GetFeatures(),...
                    double(viChangedLabels),...
                    c1xNameValueLockDownParams{:},...
                    'OptimizeHyperparameters',voOptimizeableHyperParams,...
                    'HyperparameterOptimizationOptions',stOptimizerOptions);
            catch oME
                if strcmp(oME.identifier,'MATLAB:TooManyOutputs')                    
                    % try the call that only returns one output parameter
                    % (eg. fitcknn, fitcsvm, fitctree, fitcnb, fitcdiscr)
                    %
                    % Call to this classifier's optimizer requires extraction of
                    %  the optimization result details from the model
                    oModel = hClassifierHandle(...
                        obj.GetLabelledFeatureValues().GetFeatures(),...
                        double(viChangedLabels),...
                        c1xNameValueLockDownParams{:},...
                        'OptimizeHyperparameters',voOptimizeableHyperParams,...
                        'HyperparameterOptimizationOptions',stOptimizerOptions);
                    oHyperParameterOptimizationResults = oModel.HyperparameterOptimizationResults;
                else
                    rethrow(oME)
                end

            end

            obj.oHyperParameterOptimizationResults = oHyperParameterOptimizationResults;
            
            % Journal:
            if NameValueArgs.JournalingOn && Experiment.IsRunning()
                Experiment.StartNewSubSection('Hyper Parameter Optimization');
                
                if isa(oHyperParameterOptimizationResults, 'BayesianOptimization')
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Optimizer: ', 'Bayesian Optimization'));
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Acquisition Function: ', stOptimizerOptions.AcquisitionFunctionName));
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Number of Iterations: ', num2str(oHyperParameterOptimizationResults.NumObjectiveEvaluations)));
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Time Elapse (s): ', num2str(oHyperParameterOptimizationResults.TotalElapsedTime)));
                    
                    tPerIterationResults = table(...
                        (1:oHyperParameterOptimizationResults.NumObjectiveEvaluations)', oHyperParameterOptimizationResults.ObjectiveTrace,...
                        'VariableNames', {'Iter. #', 'Objective Function'});
                    
                    tPerIterationResults = [tPerIterationResults, oHyperParameterOptimizationResults.XTrace];
                    
                    Experiment.AddToReport(ReportUtils.CreateTable(tPerIterationResults));
                    
                    oHyperParameterOptimizationResults.plot(@plotObjective);
                    hFig = gcf;
                    
                    chFigFilePath = Experiment.GetUniqueResultsFileNamePath();
                    savefig(hFig, chFigFilePath);
                    delete(hFig);
                    
                    Experiment.AddToReport(chFigFilePath);
                else
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('NO JOURNALLING IMPLEMENTED FOR NON-BAYESIAN OPTIMIZATION',''));
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
            %   obj:    object of type MATLABMachineLearningHyperParameterOptimizer 
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
            %           MATLABMachineLearningHyperParameterOptimizer object's 
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
            %   obj:    object of type MATLABMachineLearningHyperParameterOptimizer 
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

            [obj, oModel,oHyperParameterOptimizationResults] =...
                obj.OptimizeParameters(oClassifier);
            
            % NOTE: tHyperParameterStates is not updated after optimization
            % using this helper function.
        end

    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end
