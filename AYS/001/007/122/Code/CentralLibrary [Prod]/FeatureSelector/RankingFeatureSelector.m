classdef (Abstract) RankingFeatureSelector < FeatureSelector
    %RankingFeatureSelector
    %
    % Description: Parent class for all ranking based feature selection methods
    
    
    % Primary Author: David DeVries
    % Created: Nov 23, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Abstract, Access = public)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract)
        
        SelectFeatures(obj, oLabelledFeatureValues)
        
        GetRankedFeatureIndices(obj)
        
        GetOrderedFeatureMask(obj, NameValueArgs)
        
        GetFeatureMask(obj, NameValueArgs)
    end
    
    
    methods (Access = public, Static = false)        
    end
    
    
    methods (Access = public, Static = true)        
    end   
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
    end
    
    
    methods (Access = protected, Static = false)
        
        function obj = RankingFeatureSelector(chFeatureSelectionParameterFilePath)
            %obj = RankingFeatureSelector()
            %
            % SYNTAX:
            %  obj = RankingFeatureSelector()
            %
            % DESCRIPTION:
            %  Constructor for ranking feature selector
            %
            % INPUT ARGUMENTS:
            %  chFeatureSelectionParameterFilePath: Path to a parameter
            %  file
            %
            % OUTPUTS ARGUMENTS:
            %  -

            % Primary Author: Ryan Alfano
            % Created: 03 13, 2019
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

