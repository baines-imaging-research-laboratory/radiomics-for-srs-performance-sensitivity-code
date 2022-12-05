classdef F030008_GLCMCorrelation < GLCMFeature
    %F030008_GLCMCorrelation
    %
    % ROI GLCM correlation calculation.
    
    % Primary Author: Ryan Alfano
    % Created: October 16, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        sFeatureName = "F030008"
        sFeatureDisplayName = "GLCM Correlation"
    end    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = public)
        
        function obj = F030008_GLCMCorrelation()
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
            %  Extracts the gray level co-occurence matrix correlation feature value.
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
            % Haralick, Robert & Shanmugam, K & Dinstein, Ih. (1973). Textural Features for Image Classification. IEEE Trans Syst Man Cybern. SMC-3. 610-621. 
            
            vdDims = size(m2dGLCM);
            [vdCols, vdRows] = meshgrid(1:vdDims(1),1:vdDims(2));
            vdRows = vdRows(:);
            vdCols = vdCols(:);
            
            % MATLAB Method - Refer to
            % http://www.fp.ucalgary.ca/mhallbey/glcm_mean.htm for an
            % explanation
            
            vdRowMeanProb = sum(vdRows .* m2dGLCM(:));
            vdColMeanProb = sum(vdCols .* m2dGLCM(:));
%             vdRowStdProb = sqrt(sum((vdRows - vdRowMeanProb.^2 .* m2dGLCM(:))));
            vdRowStdProb = sqrt(sum(m2dGLCM(:) .* (vdRows - vdRowMeanProb).^2));
%             vdColStdProb = sqrt(sum((vdCols - vdColMeanProb.^2 .* m2dGLCM(:))));
            vdColStdProb = sqrt(sum(m2dGLCM(:) .* (vdCols - vdColMeanProb).^2));
            
%             vdTerm1 = sum((vdRows - vdRowMeanProb).^2 .* m2dGLCM(:));
            vdTerm1 = sum(m2dGLCM(:) .* (vdRows - vdRowMeanProb) .* (vdCols - vdColMeanProb));
            vdTerm2 = vdRowStdProb * vdColStdProb;
            
            dValue = vdTerm1 / vdTerm2;
            
            % Value is NaN if the GLCM has a single spike with a value of 1
            % in it (i.e. [1,0,0;0,0,0;0,0,0;]) Found that the correlation
            % of a slightly perturbed, normalized GLCM also tended towards
            % 1.
            if isnan(dValue)
                dValue = 1.0000;
            end
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

