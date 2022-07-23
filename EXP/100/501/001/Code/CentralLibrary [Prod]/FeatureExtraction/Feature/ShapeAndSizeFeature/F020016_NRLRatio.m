classdef F020016_NRLRatio < ShapeAndSizeFeature
    % F020016_NRLRatio
    %
    % ROI normalized radial length ratio calculation.
    
    % Primary Author: Ryan Alfano
    % Created: October 16, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        sFeatureName = "F020016"
        sFeatureDisplayName = "Normalized Radial Length Ratio"
        bIsValidFor2DImageVolumes = true
        bIsValidFor3DImageVolumes = true
    end    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    methods (Access = public)
        function obj = F020016_NRLRatio()
        end
    end
    methods (Access = protected)
        function dValue = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            % dValue = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            %
            % SYNTAX:
            % dValue = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            %
            % DESCRIPTION:
            %  Extracts the normalized radial length ratio feature value.
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

            % Primary Author: Ryan Alfano
            % Created: October 16, 2019
            
            % Fetch the radial lengths
            vdRadialLengths = oImageVolumeHandler.GetCurrentRegionOfInterestRadialLengths_mm(oFeatureExtractionParameters);
            
            % Find the max radial length
            dMaxRadialLength = max(vdRadialLengths);
            
            % Normalize the radial lengths
            vdNormalizedRadialLengths = vdRadialLengths./dMaxRadialLength;
            
            % Calculate the mean of the normalized lengths
            dMean = mean(vdNormalizedRadialLengths);
            
            % Calculate the number of boundary points
            dBoundaryPoints = numel(vdNormalizedRadialLengths);
            
            % Calculate the sum of the absolute difference
            dSumAbsDiff = sum(abs(vdNormalizedRadialLengths-dMean));
            
            % Calculate normalized radial length ratio
            dValue = dSumAbsDiff / (dBoundaryPoints*dMean);
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

