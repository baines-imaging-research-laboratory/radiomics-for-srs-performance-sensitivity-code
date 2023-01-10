classdef F020013_NRLEntropy < ShapeAndSizeFeature
    % F020013_NRLEntropy
    %
    % ROI normalized radial length entropy calculation.
    
    % Primary Author: Ryan Alfano
    % Created: October 16, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        sFeatureName = "F020013"
        sFeatureDisplayName = "Normalized Radial Length Entropy"
        bIsValidFor2DImageVolumes = true
        bIsValidFor3DImageVolumes = true
    end    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    methods (Access = public)
        function obj = F020013_NRLEntropy()
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
            %  Extracts the norrmalized radial length entropy feature value.
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
            
            % Calculate the two terms for the entropy equation
            dTerm1 = vdNormalizedRadialLengths/sum(vdNormalizedRadialLengths);
            dTerm1(dTerm1==0) = [];
            
            dTerm2 = log2(dTerm1);
            
            % Calculate normalized radial length entropy
            dValue = -sum(dTerm1.*dTerm2);
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

