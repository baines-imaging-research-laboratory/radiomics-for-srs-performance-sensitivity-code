classdef F010021_BimodalityCoefficient < FirstOrderFeature
    %Image
    %
    % http://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_cluster_sect013.htm
    
    % Primary Author: Salma Dammak
    % Created: May 06, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        sFeatureName = "F010021"
        sFeatureDisplayName = "Bimodality Coefficient"
    end    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = public)
        
        function obj = F010021_GrayLevelBimodalityCoefficient()
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
            %  Extracts the bimodality coefficient feature value.
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
            dNumVoxels = numel(m3xImageData(m3bMask));
            
            oSkewnessFeature = F010013_Skewness;
            dSkewness = oSkewnessFeature.ExtractFeature(oImage, oFeatureExtractionParameters);
            
            oKurtosisFeature = F010014_Kurtosis;           
            dKurtosis = oKurtosisFeature.ExtractFeature(oImage, oFeatureExtractionParameters);
            
            dValue =  (dSkewness^2 + 1) /...
                      (dKurtosis + ...
                      ( (3*(dNumVoxels-1)^2)/ ((dNumVoxels-2)*(dNumVoxels-3)) )...
                       );
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

