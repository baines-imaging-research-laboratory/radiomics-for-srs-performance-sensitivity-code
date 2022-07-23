classdef F040010_GLRLMLongRunLowGrayLevelEmphasis < GLRLMFeature
    %F040010_GLRLMLongRunLowGrayLevelEmphasis
    %
    % ROI GLRLM long run low gray level emphasis calculation.
    
    % Primary Author: Ryan Alfano
    % Created: October 16, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        sFeatureName = "F040010"
        sFeatureDisplayName = "GLRLM Long Run Low Gray Level Emphasis"
    end    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = public)
       
        function obj = F040010_GLRLMLongRunLowGrayLevelEmphasis()
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
            %  Extracts the gray level run length matrix long run low gray level emphasis feature value.
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
            [vdCols,vdRows] = meshgrid(1:vdDims(1),1:vdDims(2));
            vdCols = vdCols';
            vdRows = vdRows';
            
            % Get the total number of runs
            dNumRuns = sum(m2dGLRLM(:));
            
            % Temporary term
            dCoefficient = m2dGLRLM.*(vdRows.^2)./(vdCols.^2);
            
            dValue = sum(sum(dCoefficient))/dNumRuns;
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

