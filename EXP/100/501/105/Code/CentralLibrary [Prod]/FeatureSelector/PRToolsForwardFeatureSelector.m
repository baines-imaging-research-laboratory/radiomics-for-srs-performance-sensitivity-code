classdef PRToolsForwardFeatureSelector < PRToolsFeatureSelector
    %PRToolsForwardFeatureSelector
    %
    % Class for forward wrapper based feature selection methods in PRTools
    
    
    % Primary Author: Ryan Alfano
    % Created: 10, 28 2019
    
    
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
        
        function obj = PRToolsForwardFeatureSelector(chFeatureSelectionParameterFilePath)
            %obj = PRToolsForwardFeatureSelector(chFeatureSelectionParameterFilePath)
            %
            % SYNTAX:
            %  obj = PRToolsForwardFeatureSelector(chFeatureSelectionParameterFilePath)
            %
            % DESCRIPTION:
            %  Constructor for forward wrapper feature selection using PRTools5.
            %
            % INPUT ARGUMENTS:
            %  chFeatureSelectionParameterFilePath: filepath of the
            %  feature selection parameters file
            %
            % OUTPUTS ARGUMENTS:
            %  -

            % Primary Author: Ryan Alfano
            % Created: 10 28, 2019
            
            obj@PRToolsFeatureSelector(chFeatureSelectionParameterFilePath);
        end
        
        function newObj = SelectFeatures(obj, oLabelledFeatureValues, NameValueArgs)
            % newObj = SelectFeatures(obj, oLabelledFeatureValues, NameValueArgs)
            %
            % SYNTAX:
            % newObj = SelectFeatures(obj, oLabelledFeatureValues, Name, Value)
            %
            % DESCRIPTION:
            %  Performs greedy iterative forward feature selection using
            %  PRTools
            %
            % INPUT ARGUMENTS:
            %  obj: Feature Selector object
            %  oFeatureValues: Feature values object containing all
            %   feature data
            %  NameValueArgs:
            %   'NumFeatures' - (1,1) double {mustBeInteger,
            %   mustBePositive} - Number of features to select when
            %   executed.
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copy of feature selection object.
            
            % Primary Author: Ryan Alfano
            % Created: 10 28, 2019
            
            % Args
            arguments
                obj
                oLabelledFeatureValues FeatureValues
                NameValueArgs.NumFeatures (1,1) {ValidationUtils.MustBeIntegerClass} = obj.iNumFeatures
            end
            
            % Warn the user of the changed parameters in the function
            % call if verbose is set.
            if NameValueArgs.NumFeatures ~= obj.iNumFeatures
                warning('ForwardWrapperFeatureSelector:ChangedNumFeatures',['Number of features has been changed by the user and does not match the value stored in the parameters file. Number of features entered: ', num2str(NameValueArgs.NumFeatures) '. Number of features in parameters file: ' num2str(obj.iNumFeatures) '.']);
            end
            
            % Change labels to integer 0s and 1s 
            obj.viChangedLabels = GetChangedLabels(oLabelledFeatureValues, int16(1),int16(0));
            
            % Reinitialize some parameters that were changed by the user
            obj.iNumFeatures = NameValueArgs.NumFeatures;
            
            % Initialize the return
            vdFeatureMatrixSize = oLabelledFeatureValues.size();
            vdSelectedFeatureMask = zeros(1,vdFeatureMatrixSize(2));
            vdOrderedSelectedFeatures = zeros(1,vdFeatureMatrixSize(2));
            
            % Prep PR tools data set 
            oPRTrainingSet = prdataset(GetFeatures(oLabelledFeatureValues),obj.viChangedLabels);
            
            % Perform feature selection
            [oPRFeatureSelectionResult,~] = featself(oPRTrainingSet,obj.xCriterion,obj.iNumFeatures);
            
            % Retrieve binary mask of selected features
            vdPRToolsSelectedFeatures = +oPRFeatureSelectionResult;
            vdSelectedFeatureMask(vdPRToolsSelectedFeatures) = 1;
            
            % Retrieve ordered selected features
            for iNumFeatureIdx = 1:size(vdPRToolsSelectedFeatures,2)
                vdOrderedSelectedFeatures(vdPRToolsSelectedFeatures(iNumFeatureIdx)) = iNumFeatureIdx;
            end
            
            obj.vbSelectedFeatureMask = logical(vdSelectedFeatureMask);
            obj.vdOrderedSelectedFeatures = vdOrderedSelectedFeatures;
            
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

