classdef (Abstract) PRToolsFeatureSelector < FeatureSelector
    %PRToolsFeatureSelector
    %
    % Description: Parent class for all PRTools feature selection methods
    
    
    % Primary Author: Ryan Alfano
    % Created: 10, 28 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Abstract, Access = public)
    end
    
    properties (Access = public)
    end
    
    properties (Access = public)
        iNumFeatures
        xCriterion
        
        % Helper variables
        viChangedLabels
        
        % Returns
        vdOrderedSelectedFeatures
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
    end
    
    methods (Access = public, Static = true)        
    end   
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
    end
    
    
    methods (Access = protected, Static = false)
        function obj = PRToolsFeatureSelector(chFeatureSelectionParameterFilePath)
            %obj = WrapperFeatureSelector()
            %
            % SYNTAX:
            %  obj = WrapperFeatureSelector()
            %
            % DESCRIPTION:
            %  Constructor for wrapper feature selection
            %
            % INPUT ARGUMENTS:
            %  chFeatureSelectionParameterFilePath: filepath of the
            %  feature selection parameters file
            %
            % OUTPUTS ARGUMENTS:
            %  -

            % Primary Author: Ryan Alfano
            % Created: 03 13, 2019]
            
            % Load the parameters
            [tFeatureSelectionParameters] = FileIOUtils.LoadMatFile(...
                chFeatureSelectionParameterFilePath,...
                'tFeatureSelectionParameters');
            
            % Error check for necessary parameters
            obj.iNumFeatures = FeatureSelector.ExtractFeatureSelectionParameter(tFeatureSelectionParameters, "NumFeatures");
            obj.xCriterion = FeatureSelector.ExtractFeatureSelectionParameter(tFeatureSelectionParameters, "Criterion");  
            
            % Check for acceptable input
            vsPossibleCriteria = ["in-in","maha-s","maha-m","eucl-s","eucl-m","NN"];
            if ~ismember(string(obj.xCriterion),vsPossibleCriteria)
                chMessage = (['The criterion you input is not valid for this method of PRTools feature selection. Please refer to: http://www.37steps.com/prhtml/prtools/feateval.html for more information on possible criteria']);
                error('PRToolsFeatureSelector:InvalidCriterion',chMessage);
            end
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

