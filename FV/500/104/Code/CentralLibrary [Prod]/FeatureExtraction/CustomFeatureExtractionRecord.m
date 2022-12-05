classdef CustomFeatureExtractionRecord < FeatureExtractionRecord
    %CustomFeatureExtractionRecord
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Sept 9, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = CustomFeatureExtractionRecord(sFeatureSource, sDescription, m2dFeatureValues, oFeatureExtractionRecordUniqueKey)
            %obj = CustomFeatureExtractionRecord(sFeatureSource, sDescription, m2dFeatureValues, oFeatureExtractionRecordUniqueKey)
            %
            % SYNTAX:
            %  obj = CustomFeatureExtractionRecord(sFeatureSource, sDescription, m2dFeatureValues)
            %  obj = CustomFeatureExtractionRecord(__, __, __, oFeatureExtractionRecordUniqueKey)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed obj
            
            arguments
                sFeatureSource (1,1) string
                sDescription (1,1) string
                m2dFeatureValues (:,:) double
                oFeatureExtractionRecordUniqueKey FeatureExtractionRecordUniqueKey {ValidationUtils.MustBeEmptyOrScalar(oFeatureExtractionRecordUniqueKey)} = FeatureExtractionRecordUniqueKey.empty
            end
            
            % get portion
            oPortion = CustomFeatureExtractionRecordPortion(sDescription, m2dFeatureValues);
                    
            % super-class constructor
            if isempty(oFeatureExtractionRecordUniqueKey)
                varargin = {};
            else
                varargin = {oFeatureExtractionRecordUniqueKey};
            end
            
            obj@FeatureExtractionRecord(sFeatureSource, oPortion, varargin{:})
        end 
    end
    
    
    methods (Access = public, Sealed = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = protected) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true) % None
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

