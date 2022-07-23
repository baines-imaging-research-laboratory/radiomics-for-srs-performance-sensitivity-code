classdef (Abstract) Classifier < MachineLearningModel
    %Classifier
    %
    % Classifier is the ABSTRACT class (cannot be instianted) that
    % describes the user interface of any classifier in this
    % library. It also provides validation functions for some of the
    % methods and properties within its subclasses.Note that all 
    % classifiers at this point only work with labelled data.
    
    % Primary Author: Salma Dammak
    % Created: Feb 31, 2019
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
        
    properties (Abstract = true, SetAccess = immutable, GetAccess = public)
        % This the classifier name and must defined by the properties of 
        % the first concrete class down the class tree.
        sName 
    end
    
    properties (Constant = true, GetAccess = public)
        vsExpectedInputHyperParametersHeader =...
            ["sName", "c1xValue","bOptimize","c1xOptimizationDomain"];
    end
    
    properties (SetAccess = protected, GetAccess = public)      
        % Once the user gives these inputs at construction, they can never
        % modify them. This makes it so that they are less likely to report
        % incorrect hyperparameters or optimization parameters.         
        tHyperParameterStates = [];
        oHyperParameterOptimizer {ValidationUtils.MustBeEmptyOrScalar}
        
        % This gets set by the train function. 
        oTrainedClassifier = [];
    end
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    methods (Abstract = true, Access = public)  
        
        obj = Train(obj, oLabelledFeatureValues) 
        %obj = Train(obj, oLabelledFeatureValues) 
        %
        % SYNTAX:
        %  obj = Train(obj, oLabelledFeatureValues) 
        %
        % DESCRIPTION:
        %  Trains a classifier on labelled data.
        %
        % INPUT ARGUMENTS:
        %  obj: Classifier object
        %  oLabelledFeatureValues: object containing training data, its 
        %  corresponding labels and its tags.        
        %
        % OUTPUTS ARGUMENTS:
        %  obj: classifier object that has a trained version of the
        %   classifier in it.
        
        oGuessingResults = Guess (obj, oLabelledFeatureValues)
        %oGuessingResults = Guess (obj, oLabelledFeatureValues)
        %
        % SYNTAX:
        %  oGuessingResults = Guess (obj, oLabelledFeatureValues)
        %
        % DESCRIPTION:
        %  Tests a trained classifier on labelled test data.
        %
        % INPUT ARGUMENTS:
        %  obj: Classifier object
        %  oLabelledFeatureValues: object containing test data, their 
        %  corresponding labels and their tags.
        %
        % OUTPUTS ARGUMENTS:
        %  oGuessingResult: an object containing the classification and 
        %  confidences on the test data.
                
    end
    
    methods (Access = public, Static = false)
        
        function sName = GetClassifierName(obj)
            %sName = GetClassifierName(obj)
            %
            % SYNTAX:
            %  sName = GetClassifierName(obj)
            %
            % DESCRIPTION:
            %  A function to get the name of the classifier
            %
            % INPUT ARGUMENTS:
            %  obj: the Classifier object
            %
            % OUTPUTS ARGUMENTS:
            %  sName: returns the property sName which
            %           holds the name of the classifier (eg. fitcknn)
            
            % Primary Author: Carol Johnson
            % Created: Sep 25, 2019

            sName = obj.sName;
        end      
            
    end
    

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Abstract = true, Access = protected)   
        
        obj = ImplementationSpecificOptimizeHyperparameters(obj, NameValueArgs); 
        %obj = ImplementationSpecificOptimizeHyperparameters(obj)
        %
        % SYNTAX:
        %  obj = ImplementationSpecificOptimizeHyperparameters(obj) 
        %
        % DESCRIPTION:
        %  Calls a hyperparameter optimization method that is specific to
        %  and immidiate subclass.
        %
        % INPUT ARGUMENTS:
        %  obj: Classifier object       
        %
        % OUTPUTS ARGUMENTS:
        %  obj: classifier object that has optimized hyperparameters in
        %   addition to all its user-specified paramaters.  
        
        obj = IntializeHyperParameterStatesTable(obj, tHyperParameters)
        ValidateHyperParameterStatesForOptimization(obj)
        obj = SetHyperParameterStatesOptimizableFlag(obj)
    end
    
    
    methods (Access = {?Classifier, ?HyperParameterOptimizer})
        
        function tHyperParameters = GetHyperParametersTable(obj)
            %tHyperParameters = GetHyperParametersTable(obj)
            %
            % SYNTAX:
            %  tHyperParameters = GetHyperParametersTable(obj)
            %
            % DESCRIPTION:
            %  A function to get the table of hyper parameters for the
            %  classifier
            %
            % INPUT ARGUMENTS:
            %  obj: the Classifier object
            %
            % OUTPUTS ARGUMENTS:
            %  tHyperParameters: returns the property tHyperParameters which
            %           holds the table of hyperparameters for the classifier
            
            % Primary Author: Carol Johnson
            % Created: Sep 24, 2019
            
            tHyperParameters = obj.tHyperParameterStates;
        end
    end
    
       
    methods (Access = protected)
        function obj = Classifier(xClassifierHyperParametersFileNameOrHyperParametersTable)
            %obj = Classifier(chClassifierHyperParametersFileName)
            %
            % SYNTAX:
            %  obj = Classifier(chClassifierHyperParametersFileName)
            %  obj = Classifier(tHyperParameters)
            %
            % DESCRIPTION:
            %  ABSTRACT constructor for all classifiers. 
            %  TODO: implement a way to check the correct format for the
            %  paremeter input.
            %
            % INPUT ARGUMENTS:
            %  obj: TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: classifier object that has optimized hyperparameters in
            %   addition to all its user-specified paramaters.
            arguments
                xClassifierHyperParametersFileNameOrHyperParametersTable
            end
            
            if isempty(obj.tHyperParameterStates) % if a dual-inheritance child class is constructed, it will reach this constructor twice. This if statement stops the same code from being executed twice.
                if istable(xClassifierHyperParametersFileNameOrHyperParametersTable)
                    tHyperParameters = xClassifierHyperParametersFileNameOrHyperParametersTable;
                    
                    vstStackTrace = dbstack;
                    
                    bMATLABBayesianHyperParameterOptimizerFound = false;
                    
                    for dStackIndex=1:length(vstStackTrace)
                        if strcmp(vstStackTrace(dStackIndex).file, 'MATLABBayesianHyperParameterOptimizer.m')
                            bMATLABBayesianHyperParameterOptimizerFound = true;
                            break;
                        end
                    end
                    
                    if ~bMATLABBayesianHyperParameterOptimizerFound
                        error(...
                            'Classifier:Constructor:InvalidUsage',...
                            'The Classifier constructor can only be called directly with a hyperparameters table (as opposed to a .mat filepath) by the MATLABBayesianHyperParameterOptimizer class.');
                    end
                else 
                    chClassifierHyperParametersFileName = xClassifierHyperParametersFileNameOrHyperParametersTable;
                    
                    chClassifierHyperParametersFileName = ValidationUtils.CastAScalarStringOrCharToString(chClassifierHyperParametersFileName);
                    
                    Classifier.ValidateHyperParametersFile(chClassifierHyperParametersFileName)
                    tHyperParameters = FileIOUtils.LoadMatFile(chClassifierHyperParametersFileName,'tHyperParameters');
                end
                
                obj = IntializeHyperParameterStatesTable(obj,tHyperParameters);
            end
        end
        
        function obj = OptimizeHyperparameters(obj,oHyperParameterOptimizer, NameValueArgs)
            %obj = OptimizeHyperparameters(obj,oHyperParameterOptimizer)
            %
            % SYNTAX:
            %  obj = OptimizeHyperparameters(obj,oHyperParameterOptimizer)
            %
            % DESCRIPTION:
            %  Does some checks then calls subclass optimizer if they pass.
            %
            % INPUT ARGUMENTS:
            %  obj: Classifier object
            %  oHyperParameterOptimizer: an object created by the user that
            %   contains optimization hyperparameters. 
            %
            % OUTPUTS ARGUMENTS:
            %  obj: classifier object with tHyperParameters filled with
            %  both optimized hyperparameters and user-set ones, along with
            %  flags noting what was optimized. 
            %
            % Primary Author: C.Johnson
            % Created: Apr 2018
            % Modified: Sept 2019; Documentation updates; C.Johnson
            % 
            
            arguments
                obj
                oHyperParameterOptimizer
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            obj = SetHyperParameterStatesOptimizableFlag(obj);
            ValidateHyperParameterStatesForOptimization(obj);
            
            % If the optimization hyperparameters are given and at least
            % one parameter was requested to be optimized, and teh classifier has at least one
            % optimizable hyperparameter call a subclass         
            
            % Set parameters to be part of the classifier object
            % This information is needed in order to call the
            % appropriate subclass functions.
            
            % These parameters include the labelled feature values, the
            % optimization options (eg. maximum number of evaluations),
            % and the implementation for the type of optimization
            %  (eg. Matlab's machine learning toolbox)
            obj.oHyperParameterOptimizer = oHyperParameterOptimizer;
            % Call function to direct optimization of the hyperparameters
            % to be handled by the type of classifier that was created
            % (eg. from Classifier --> MATLABClassifier --> MATLABfitcknn)
            obj = ImplementationSpecificOptimizeHyperparameters(obj, 'JournalingOn', NameValueArgs.JournalingOn);
                

        end
           
        function obj = ValidateInputsToTrain(obj, oLabelledFeatureValues)
            % obj = ValidateInputsToTrain(obj, oLabelledFeatureValues)
            %
            % SYNTAX:
            %  obj = ValidateInputsToTrain(obj, oLabelledFeatureValues)
            %
            % DESCRIPTION:
            %  Check if input are given in the right order and that the
            %  first one is of type classifier and the second of type 
            %  labelledFeatureValues. The validation of the intricacies of 
            %  each of those objects is done at constructor level.
            % 
            % INPUT ARGUMENTS:
            %  obj: Classifier object
            %  oLabelledFeatureValues: object containing training data, its 
            %  corresponding labels and its tags.        
            %
            % OUTPUTS ARGUMENTS:
            %  obj: classifier object 
            
            
            if ~isa(obj,'Classifier')
                chUserInputClass = class(obj);
                error('Classifier:WrongFirstInputType',['The first input to Train must of type ',...
                    'Classifier. Your input was of type ',chUserInputClass,'.'])
            end

            if ~isa(oLabelledFeatureValues,'LabelledFeatureValues')
                chUserInputClass = class(oLabelledFeatureValues);
                error('Classifier:WrongSecondInputType',['The second input to Train must of type ',...
                    'LabelledFeatureValues. Your input was of type ',chUserInputClass,'.'])
            end
        end
    end
    
    
    methods (Access = protected, Static = true)
        
        function  ValidateHyperParametersFile(chClassifierHyperParametersFileName)
            
            % Check if tHyperParameters exists
            try                
                % Load .mat file containing classifier parameters. This is a
                % file which contains a table variable called tHyperParameters.
                % See tables with classifier specific parameters stored in the
                % ...\DefaultInputs directory.                
                tHyperParameters = FileIOUtils.LoadMatFile(chClassifierHyperParametersFileName,'tHyperParameters');
                
            catch oME
                if strcmp(oME.identifier,'FileIOUtils:LoadMatFile:NonExistentVariable')                    
                    % Give more meaningful error message if the required
                    % varibale name is missing/modified.                    
                    error('Classifier:ValidateHyperParametersFile:ParameterVariableWrongName',...
                        ['The .mat file you gave for the classifier parameters does not contain ',...
                        'a variable named ''tHyperParameters'' which is required.',newline,'Please change ',...
                        'the variable name to ''tHyperParameters'' or add it (no quotes) if it does not exist,',...
                        ' and proceed.'])
                else
                    rethrow(oME)
                end
            end
            
            % Check that tHyperParameters is a table
            if ~isa(tHyperParameters,'table')
                error("Classifier:ValidateHyperParametersFile:tHyperParametersNotTable",...
                "tHyperParameters, the variable in the hyperparameter input file  is not a table. "...
                +"It must be a table.");
            end
            
            % Check that tHyperParameters has the right header
            vsInputHeader = string(tHyperParameters.Properties.VariableNames);
            
            dNumExpectedHeaders = length(Classifier.vsExpectedInputHyperParametersHeader);
            bHeaderNotFound = false;
            
            for dHeaderIndex=1:dNumExpectedHeaders
                if ~any(vsInputHeader == Classifier.vsExpectedInputHyperParametersHeader(dHeaderIndex))
                    bHeaderNotFound = true;
                    break;
                end
            end
            
            if bHeaderNotFound
                error("Classifier:ValidateHyperParametersFile:tHyperParametersBadHeader",...
                "tHyperParameters, the variable in the hyperparameter input file  does not have "...
                + "the right header. The header must contain: " + newline ...
                + strjoin(Classifier.vsExpectedInputHyperParametersHeader)+ newline...
                +"The one you gave was: " + newline + strjoin(vsInputHeader));
            end
            
            
            % Check that the table columns are of the right type
            if ~isa(tHyperParameters.sName,'string')
                error("Classifier:ValidateHyperParametersFile:InvalidType",...
                    "The sName column in tHyperParameters must be of string type.")
            end
            if ~isa(tHyperParameters.c1xValue,'cell')
                error("Classifier:ValidateHyperParametersFile:InvalidType",...
                    "The c1xValue column in tHyperParameters must be of cell type.")
            end
            if ~isa(tHyperParameters.bOptimize,'logical')
                error("Classifier:ValidateHyperParametersFile:InvalidType",...
                    "The bOptimize column in tHyperParameters must be of logical type.")
            end
            if ~isa(tHyperParameters.c1xOptimizationDomain,'cell')
                error("Classifier:ValidateHyperParametersFile:InvalidType",...
                    "The c1xOptimizationDomain column in tHyperParameters must be of cell type.")
            end
            
            % Check that tHyperParameters has no empty parameter names
            if any(arrayfun(@(c) c == "", tHyperParameters.sName))
                error("Classifier:ValidateHyperParametersFile:EmptyHyperParameterNames",...
                    "One or more hyperparameters has an empty string as a name under the column sName.")
            end
            
            % Check that tHyperParameters has no duplicates
            % vdNameOccurenceIndices is a vector showing where each of the unique names was in the
            % input array. It uses a number from 1 to number of unique names as a code for the name. 
            [sUniqueNames,~,vdNameOccurenceIndices] = unique(tHyperParameters.sName);  
            
            if numel(sUniqueNames) < numel(tHyperParameters.sName)                
                dNameOccurenceCounts = histc(vdNameOccurenceIndices,1:numel(sUniqueNames));                
                vsRepeatedNames = tHyperParameters.sName(find(dNameOccurenceCounts>1));
                sRepeatedNames = strjoin(arrayfun(@(s) s +"     ",vsRepeatedNames));
                
                error("Classifier:ValidateHyperParametersFile:RepeatedHyperParameterNames",...
                    "One or more names are repeated in the list of hyperparameter names. "...
                    +"They are: " + newline + sRepeatedNames(:));              

            end
        end
    end
    
    

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?MATLABBayesianHyperParameterOptimizer}, Static = false)
        
        function oTrainedClassifier = GetTrainedClassifier(obj)
            oTrainedClassifier = obj.oTrainedClassifier;
        end
    end
    
    methods (Abstract = true, Access = {?KFoldCrossValidationUtils, ?Classifier})  
        
        oGuessingResults = GuessAllowDuplicatedSamples(obj, oLabelledFeatureValues, NameValueArgs)
                        
    end
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)        

            function tHyperParameters =...
                GetHyperParametersTable_ForUnitTest(obj)
            %tHyperParameters = GetHyperParametersTable_ForUnitTest(obj)
            %
            % SYNTAX:
            %tHyperParameters = GetHyperParametersTable_ForUnitTest(obj)
            %
            % DESCRIPTION:
            %  A function to give the unit tests access to the protected
            %    function GetHyperParametersTable
            %
            % INPUT ARGUMENTS:
            %   obj:    object of type MATLABClassifier 
            %
            % OUTPUTS ARGUMENTS:
            %   tHyperParameters: table of hyper-parameters for the
            %                     classifier
            
            % Primary Author: Carol Johnson
            % Created: Jan. 11, 2022

            tHyperParameters = obj.GetHyperParametersTable();
            end
    end

end