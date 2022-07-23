classdef F040004_GLRLMRunLengthNonUniformity < GLRLMFeature
    %F040004_GLRLMRunLengthNonUniformity
    %
    % ROI GLRLM run length non uniformity calculation.
    
    % Primary Author: Ryan Alfano
    % Created: October 16, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        sFeatureName = "F040004"
        sFeatureDisplayName = "GLRLM Run Length Non-uniformity"
    end    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = public)
       
        function obj = F040004_GLRLMRunLengthNonUniformity()
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Static = true)
        
        function dValue = ExtractGLRLMFeature(m2dGLRLM, oFeatureExtractorParameters)
            % dValue = ExtractGLRLMFeature(m2dGLRLM, oFeatureExtractorParameters)
            %
            % SYNTAX:
            % dValue = ExtractGLRLMFeature(m2dGLRLM, oFeatureExtractorParameters)
            %
            % DESCRIPTION:
            %  Extracts the gray level run length matrix run length non uniformity feature value.
            %
            % INPUT ARGUMENTS:
            %  m2dGLRLM: Gray level run length matrix of the ROI
            %  oFeatureExtractorParameters: Object containing all
            %   feature extraction parameterrs.
            %
            % OUTPUTS ARGUMENTS:
            %  dValue: Resulting feature value.

            % Primary Author: Ryan Alfano
            % Created: October 16, 2019
            
            % Get the row and column subscripts of the GLRLM.
            vdDims = size(m2dGLRLM);
            vdRowIndices = 1:vdDims(1);
            
            % Get the total number of runs
            dNumRuns = sum(m2dGLRLM(:));
            
            % Run-Length Run-Number Vector: Represents the sum distribution of the number of runs with run length i.
            vdNumRunsOfEachLength = sum(m2dGLRLM);
            
            dValue = sum(vdNumRunsOfEachLength.^2)/dNumRuns;
        end
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

