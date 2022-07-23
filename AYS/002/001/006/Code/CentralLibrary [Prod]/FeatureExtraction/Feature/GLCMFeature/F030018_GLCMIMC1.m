classdef F030018_GLCMIMC1 < GLCMFeature
    %F030018_GLCMIMC1
    %
    % ROI GLCM information measure of correlation 1 calculation.
    
    % Primary Author: Ryan Alfano
    % Created: October 16, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        sFeatureName = "F030018"
        sFeatureDisplayName = "GLCM Information Measure of Correlation 1"
    end    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = public)
        
        function obj = F030018_GLCMIMC1()
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
            %  Extracts the gray level co-occurence matrix information measure of correlation 1 feature value.
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
            
            % Get the sum of the glcm in each direction
            vdHorizontalSum = sum(m2dGLCM,2);
            vdVerticalSum = sum(m2dGLCM,1);
            
            % Get some other coefficients
            vdProduct = vdHorizontalSum.*log2(vdHorizontalSum);
            vdProduct(isnan(vdProduct)==1) = 0;
            dCoeffHX = -sum(vdProduct);
            
            vdProduct = vdVerticalSum.*log2(vdVerticalSum);
            vdProduct(isnan(vdProduct)==1) = 0;
            dCoeffHY = -sum(vdProduct);
            
            vdProduct = m2dGLCM(:).*log2(m2dGLCM(:));
            vdProduct(isnan(vdProduct)==1) = 0;
            dCoeffHXY = -sum(vdProduct);
            
            % Get HXY1 - notice this is NATURAL log in Aerts et al, but we are
            % using log base 2
            Product = m2dGLCM(:).*log2(vdHorizontalSum(vdRows).*([vdVerticalSum(vdCols)]'));
            Product(isnan(Product)==1)=0; % The limit of this expression is zero when term2 approaches zero
            dCoeffHXY1 = -sum(Product);
            
            dValue = (dCoeffHXY-dCoeffHXY1) / max([dCoeffHX, dCoeffHY]);
            
            % Through experimentation by slightly perturbing a homogeneous
            % GLCM (i.e. [1,0,0;0,0,0;0,0,0;]) the result approaches a
            % value of 0.
            if numel(unique(m2dGLCM(:))) == 1
                dValue = 0;
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

