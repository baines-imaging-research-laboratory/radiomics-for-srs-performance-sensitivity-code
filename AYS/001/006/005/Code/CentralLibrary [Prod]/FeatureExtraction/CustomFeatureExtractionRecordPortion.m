classdef CustomFeatureExtractionRecordPortion < FeatureExtractionRecordPortion
    %CustomFeatureExtractionRecordPortion
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Apr 26, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = CustomFeatureExtractionRecordPortion(sDescription, m2dFeatures)
            %obj = CustomFeatureExtractionRecordPortion(sDescription, m2dFeatures)
            %
            % SYNTAX:
            %  obj = CustomFeatureExtractionRecordPortion(sDescription, m2dFeatures)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  input1: TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                sDescription (1,1) string
                m2dFeatures (:,:) double
            end
            
            % calculate number of samples
            dNumSamples = size(m2dFeatures, 1);
            
            % super-class call
            obj@FeatureExtractionRecordPortion(sDescription, dNumSamples);
        end 
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = protected) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private) % None
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

