classdef (Abstract) FeatureSelector < matlab.mixin.Copyable
    %FeatureSelector
    %
    % Description: Super class for all feature selection methods
    
    % Primary Author: Ryan Alfano
    % Created: 03 13, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Abstract, Access = public)
    end
    
    properties (Access = public)    
    end
    
    properties (SetAccess = protected, GetAccess = public)
        vbSelectedFeatureMask
        tFeatureSelectionParameters    
    end
        
    properties (Constant = true, GetAccess = public)
        sExperimentJournalingObjVarName = "oFeatureSelector"
        
        sParametersFileTableVarName = "tFeatureSelectionParameters"
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract = true)
        SelectFeatures(obj)
        %SelectFeatures(obj)
        %
        % SYNTAX:
        %  SelectFeatures(obj)
        %
        % DESCRIPTION:
        %  Runs the chosen feature selector.
        %
        % INPUT ARGUMENTS:
        %  obj: class object
        %

        % Primary Author: Ryan Alfano
        % Created: 03 13, 2019
    end
    
    methods (Access = public, Static = false)
        function vbSelectedFeatureMask = GetFeatureMask(obj)
            %vbSelectedFeatureMask = GetFeatureMask(obj)
            %
            % SYNTAX:
            %  vbSelectedFeatureMask = GetFeatureMask(obj)
            %
            % DESCRIPTION:
            %  Returns mask of selected features
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  vbSelectedFeatureMask: Binary mask of selected features

            % Primary Author: Ryan Alfano
            % Created: 03 13, 2019
            vbSelectedFeatureMask = obj.vbSelectedFeatureMask;
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
        function obj = FeatureSelector()
            %obj = FeatureSelector()
            %
            % SYNTAX:
            %  obj = FeatureSelector()
            %
            % DESCRIPTION:
            %  Runs select features on construction which is a method in
            %  the child class forced by the abstract method in the parent
            %  class. Also loads in the parameters file.
            %
            % INPUT ARGUMENTS:
            %
            % OUTPUTS ARGUMENTS:
            %  vbSelectedFeatureMask: Binary mask of selected features

            % Primary Author: Ryan Alfano
            % Created: 03 13, 2019
        end
    end
    
    
    methods (Access = protected, Static = true)
        
        function xParameter = ExtractFeatureSelectionParameter(tFeatureSelectionParameters, sParameterName)
            %xParameter = ExtractFeatureSelectionParameter(tFeatureSelectionParameters, sParameterName)
            %
            % SYNTAX:
            %  xParameter = ExtractFeatureSelectionParameter(tFeatureSelectionParameters, sParameterName)
            %
            % DESCRIPTION:
            %  Function that handles extraction of specific feature
            %  selection parameters out of the table.
            %
            % INPUT ARGUMENTS:
            %  tFeatureSelectionParameters: table of feature selection
            %  paramaters
            %  sParameterName: name of the parameter
            %
            % OUTPUTS ARGUMENTS:
            %  xParameter: value of the parameter

            % Primary Author: Ryan Alfano
            % Created: 03 13, 2019
            
            if (isempty(tFeatureSelectionParameters.c1xValue(tFeatureSelectionParameters.sName == sParameterName)))
                chMessage = (['The parameter "', char(sParameterName), '" could not be found in the loaded feature selection parameters file.']);
                error('FeatureSelector:ParameterNotFound',chMessage);
            end
            xParameter = tFeatureSelectionParameters.c1xValue(tFeatureSelectionParameters.sName == sParameterName);
            xParameter = xParameter{1};
        end
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

