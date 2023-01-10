classdef F010008_MeanAbsoluteDeviation < FirstOrderFeature
    %Image
    %
    % Based on Aerts et al. 2014, DOI: 10.1038/ncomms5006
    % Equation is on page 11 of supplementary materials
    
    % Primary Author: Salma Dammak
    % Created: May 06, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        sFeatureName = "F010008"
        sFeatureDisplayName = "Mean"
    end    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = public)
        
        function obj = F010008_MeanAbsoluteDeviation()
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
            %  Extracts the mean absolute deviation feature value.
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
            
            [m3xImageData, m3bMask] = oImage.GetCurrentRegionOfInterestImageDataAndMask(oFeatureExtractionParameters);
            
            dMean = sum(m3xImageData(m3bMask))/numel(m3xImageData(m3bMask)); % mean
            vdDeviationsFromMean = abs( double(m3xImageData(m3bMask)) - dMean); % absolute deviation from the mean
            
            dValue = sum(vdDeviationsFromMean)/numel(m3xImageData(m3bMask)); % absoulte mean deviation
               
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

