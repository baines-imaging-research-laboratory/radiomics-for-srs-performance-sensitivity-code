classdef (Abstract) WrapperFeatureSelector < FeatureSelector
    %WrapperFeatureSelector
    %
    % Description: Parent class for all wrapper based feature selection
    % methods.
    
    
    % Primary Author: Ryan Alfano
    % Created: 04, 09 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Abstract, Access = public)
    end
    
    properties (SetAccess = immutable, GetAccess = public)        
        oObjectiveFunction MachineLearningObjectiveFunction {ValidationUtils.MustBeEmptyOrScalar} = KFoldCrossValidationObjectiveFunction.empty
    end
    
    properties (SetAccess = protected, GetAccess = public)
        dNumFeatures (1,1) double {mustBeInteger, mustBePositive} = 1
        
        oClassifier Classifier {ValidationUtils.MustBeEmptyOrScalar} = MATLABfitcsvm.empty
        
        % Returns
        m2dObjectiveFunctionValuePerCombination (:,:) double
        dFeatureComboObjectiveFunctionValue (1,1) double
        vdOrderedSelectedFeatures (1,:) double
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
        
        function sString = GetObjectiveFunctionDescriptionString(obj)
            %sString = GetObjectiveFunctionDescriptionString(obj)
            %
            % SYNTAX:
            %  sString = GetObjectiveFunctionDescriptionString(obj)
            %
            % DESCRIPTION:
            %  Returns the description string of the objective function.
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  sString: Description of objective function.
            
            % Primary Author: David Devries
            % Created: 09 23, 2019
            sString = "Minimization of " + obj.oObjectiveFunction.GetDescriptionString();
        end
        
        function oObjectiveFunction = GetObjectiveFunction(obj)
            %oObjectiveFunction = GetObjectiveFunction(obj)
            %
            % SYNTAX:
            %  oObjectiveFunction = GetObjectiveFunction(obj)
            %
            % DESCRIPTION:
            %  Returns the objective function object.
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  oObjectiveFunction: Objective function.
            
            % Primary Author: David Devries
            % Created: 09 23, 2019
            oObjectiveFunction = obj.oObjectiveFunction;
        end
        
        function m2dObjectiveFunctionValuePerCombination = GetObjectiveFunctionValuePerCombination(obj)
            %m2dObjectiveFunctionValuePerCombination = GetObjectiveFunctionValuePerCombination(obj)
            %
            % SYNTAX:
            %  m2dObjectiveFunctionValuePerCombination = GetObjectiveFunctionValuePerCombination(obj)
            %
            % DESCRIPTION:
            %  Returns matrix of resulting scoring criterion for each
            %  sequential addition or removal of a feature.
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  m2dObjectiveFunctionValuePerCombination: matrix displaying the scoring
            %  criterion when a specific feature is added or removed
            
            % Primary Author: Ryan Alfano
            % Created: 09 23, 2019
            m2dObjectiveFunctionValuePerCombination = obj.m2dObjectiveFunctionValuePerCombination;
        end
        
        function dFeatureComboObjectiveFunctionValue = GetObjectiveFunctionValueForFeatureCombination(obj)
            %dFeatureComboObjectiveFunctionValue = GetObjectiveFunctionValueForFeatureCombination(obj)
            %
            % SYNTAX:
            %  dFeatureComboObjectiveFunctionValue = GetObjectiveFunctionValueForFeatureCombination(obj)
            %
            % DESCRIPTION:
            %  Returns the resulting scoring metric for the final feature
            %  combination.
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  dFeatureComboObjectiveFunctionValue: resulting scoring metric
            
            % Primary Author: Ryan Alfano
            % Created: 09 23, 2019
            dFeatureComboObjectiveFunctionValue = obj.dFeatureComboObjectiveFunctionValue;
        end
        
        function vdOrderedSelectedFeatures = GetOrderedFeatureMask(obj)
            %vdOrderedSelectedFeatures = GetOrderedFeatureMask(obj)
            %
            % SYNTAX:
            %  vdOrderedSelectedFeatures = GetOrderedFeatureMask(obj)
            %
            % DESCRIPTION:
            %  Returns the resulting ordered selected features which will
            %  illustrates the order at which features were removed/added
            %  during feature selection
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdOrderedSelectedFeatures: resulting ordered selected
            %  features
            
            % Primary Author: Ryan Alfano
            % Created: 09 23, 2019
            vdOrderedSelectedFeatures = obj.vdOrderedSelectedFeatures;
        end
        
        function dNumFeatures = GetNumberOfFeatures(obj)
            %dNumFeatures = GetNumberOfFeatures(obj)
            %
            % SYNTAX:
            %  dNumFeatures = GetNumberOfFeatures(obj)
            %
            % DESCRIPTION:
            %  Returns the number of features chosen to be selected.
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  dNumFeatures: Number of features to select.
            
            % Primary Author: David Devries
            % Created: 09 23, 2019
            dNumFeatures = obj.dNumFeatures;
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
        
        function obj = WrapperFeatureSelector(chFeatureSelectionParameterFilePath, oObjectiveFunction)
            %obj = WrapperFeatureSelector(chFeatureSelectionParameterFilePath, oObjectiveFunction)
            %
            % SYNTAX:
            %  obj = WrapperFeatureSelector(chFeatureSelectionParameterFilePath, oObjectiveFunction)
            %
            % DESCRIPTION:
            %  Constructor for wrapper feature selection
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
            % Created: 03 13, 2019]
            
            arguments
                chFeatureSelectionParameterFilePath (1,:) char
                oObjectiveFunction (1,1) MachineLearningObjectiveFunction {MustBeValidForMinimaOptimization(oObjectiveFunction)}
            end
            
            obj@FeatureSelector();
            
            % Load the parameters
            [tFeatureSelectionParameters] = FileIOUtils.LoadMatFile(...
                chFeatureSelectionParameterFilePath,...
                'tFeatureSelectionParameters');
            
            % Error check for necessary parameters
            dNumFeatures = FeatureSelector.ExtractFeatureSelectionParameter(tFeatureSelectionParameters, "NumFeatures");
            dNumFeatures = WrapperFeatureSelector.ValidateNumFeatures(dNumFeatures);
            
            oClassifier = FeatureSelector.ExtractFeatureSelectionParameter(tFeatureSelectionParameters, "Classifier");
             
            if isempty(oClassifier) 
                
            else 
                if ~isa(oClassifier, 'Classifier') || ~isscalar(oClassifier)
                    error(...
                        'WrapperFeatureSelector:Classifier:InvalidInput',...
                        'Classifier for feature selection must be an object of type ''Classifier''.');
                end 
                
                obj.oClassifier = oClassifier;
            end 
            
            % set properities
            obj.dNumFeatures = dNumFeatures;
            obj.oObjectiveFunction = oObjectiveFunction;
        end
    end
    
    
    methods (Access = protected, Static = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Abstract)
    end
    
    
    methods (Access = private, Static = false)
    end
    
    
    methods (Access = private, Static = true)
        
        function dNumFeatures = ValidateNumFeatures(dNumFeatures)
            %dNumFeatures = ValidateNumFeatures(dNumFeatures)
            %
            % SYNTAX:
            %  dNumFeatures = ValidateNumFeatures(dNumFeatures)
            %
            % DESCRIPTION:
            %  Validation function to ensure that the number of features
            %  chosen to be selected is a positive integer.
            %
            % INPUT ARGUMENTS:
            %  dNumFeatures: Number of features to be selected.
            %
            % OUTPUTS ARGUMENTS:
            %  dNumFeatures: Number of features to be selected.
            
            % Primary Author: David Devries
            % Created: 09 23, 2019
            arguments
                dNumFeatures (1,1) double {mustBeInteger, mustBePositive}
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

