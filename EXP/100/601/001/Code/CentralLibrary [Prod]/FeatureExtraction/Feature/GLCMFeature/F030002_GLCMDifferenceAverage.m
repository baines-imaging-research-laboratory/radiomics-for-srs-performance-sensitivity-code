classdef F030002_GLCMDifferenceAverage < GLCMFeature
    %F030002_GLCMDifferenceAverage
    %
    % ROI GLCM difference average calculation.
    
    % Primary Author: Ryan Alfano
    % Created: October 16, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        sFeatureName = "F030002"
        sFeatureDisplayName = "GLCM Difference Average"
    end    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = public)
       
        function obj = F030002_GLCMDifferenceAverage()
        end      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Static = true)
        
        function dValue = ExtractGLCMFeature(m2dGLCM, oFeatureExtractorParameters)
            % dValue = ExtractGLCMFeature(m2dGLCM, oFeatureExtractorParameters)
            %
            % SYNTAX:
            % dValue = ExtractGLCMFeature(m2dGLCM, oFeatureExtractorParameters)
            %
            % DESCRIPTION:
            %  Extracts the gray level co-occurence matrix difference average feature value.
            %
            % INPUT ARGUMENTS:
            %  m2dGLCM: Gray level co-occurence matrix of the ROI
            %  oFeatureExtractorParameters: Object containing all
            %   feature extraction parameterrs.
            %
            % OUTPUTS ARGUMENTS:
            %  dValue: Resulting feature value.

            % Primary Author: Ryan Alfano
            % Created: October 16, 2019
            
            % Get the row and column subsbstripts (i,j in Aerts et al. Nat Commun. 2014;5:4006) of the normalized GLCM.
            
            vdDims = size(m2dGLCM);
            [vdCols, vdRows] = meshgrid(1:vdDims(1),1:vdDims(2));
            vdRows = vdRows(:);
            vdCols = vdCols(:);
            
            % first term = abs(i-j)
            vdTerm1 = abs(vdRows-vdCols);
            
            % second term is P(i,j);
            vdTerm2 = m2dGLCM(:);
            
            dValue = sum(vdTerm1.*vdTerm2);
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

