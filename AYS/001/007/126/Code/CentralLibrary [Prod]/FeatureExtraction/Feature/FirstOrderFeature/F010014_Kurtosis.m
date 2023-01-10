classdef F010014_Kurtosis < FirstOrderFeature
    %Image
    %
    % Based on MATLAB's kurtosis equation 
    
    
    % Primary Author: Salma Dammak
    % Created: May 06, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        sFeatureName = "F010014"
        sFeatureDisplayName = "Kurtosis"
    end    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = public)
        
        function obj = F010014_Kurtosis()
        end
    end
    methods (Access = protected)
        function dValue = ExtractFeature(obj,oImage, oFeatureExtractionParameters)
            % dValue = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            %
            % SYNTAX:
            % dValue = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            %
            % DESCRIPTION:
            %  Extracts the kurtosis feature value.
            %
            % INPUT ARGUMENTS:
            %  obj: Feature Extraction object
            %  oImageVolumeHandler: Image volume handler to define the ROI
            %   and image to extract the feature.
            %  oFeatureExtractionParameters: Object containing all
            %   feature extraction parameterrs.
            %
            % OUTPUTS ARGUMENTS:
            %  dValue: Resulting feature value.

            % Primary Author: Salma Dammak
            % Created: May 10, 2019
            
            % Get mean
            [m3xImageData, m3bMask] = oImage.GetCurrentRegionOfInterestImageDataAndMask(oFeatureExtractionParameters);
%             
            dMaskedImage = double(m3xImageData(m3bMask));
            dMean = sum(m3xImageData(m3bMask))/numel(m3xImageData(m3bMask)); % mean
%             
%             dNumerator = 1/numel(dMaskedImage)*sum((dMaskedImage-dMean).^4);
%             dDenominator = (sqrt(1/numel(dMaskedImage)* sum( (dMaskedImage-dMean).^2 ) ))^4; 
%             dValue = dNumerator/dDenominator;
            % while this formula matches pyradiomics result AND matlab, it doesn't match the formula on Aerts
            dValue = kurtosis(dMaskedImage(:));
            
            if numel(unique(dMaskedImage(:))) == 1
                vdPerturbedImageValues = repmat(dMean,1,numel(m3xImageData(m3bMask)));
                vdPerturbedImageValues(end+1) = dMean+1;
                vdPerturbedImageValues(end+1) = dMean-1;
                dValue = kurtosis(vdPerturbedImageValues);
            end               
        end

    end
  
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************

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

